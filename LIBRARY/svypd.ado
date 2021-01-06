*! svypd version 1.08 - Biostat Global Consulting - 2020-05-25
********************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-10-22	1.00	Dale Rhoda		Original version, improvement to
*										older version that calculated
*										confidence intervals for a single
*										value of LEVEL

*
* 2016-11-15	1.01	Dale			Handle case where phat is 0 or 100%
* 2017-01-09	1.02	Dale Rhoda		Change svyp to svypd in error msgs
* 2017-08-18	1.03	Dale Rhoda		Remove arcsine and Anscombe methods
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2018-05-11	1.05	Dale Rhoda		Count all clusters in strata in df
*                                       calculation, whether they held 
*                                       respondents in the subpopulation or not
* 2019-05-21	1.06	Dale Rhoda		Change cluster logic to accomodate
*										calculations without strata
* 2020-04-22	1.07	Dale Rhoda		When stderr < 1E-16, set it to 0
*                                       and when stderr is 0, set df to N-1
* 2020-05-25	1.08	Dale Rhoda		When stderr is missing, set it to 0

********************************************************************************

program define svypd
	version 14.1
	
	syntax varlist (min=1 max=1 numeric) [if]   ///
		[, LEVEL(numlist >0 <100 min=1 max=1)   ///
		CILEVELLIST(numlist >0 <100 ascending)  ///
		Method(string) ADJust TRUNCate]
		
	* This program assumes that there is a svyset dataset in memory.
	
	* Uses nomenclature from
	*		Dean, Natalie, and Marcello Pagano. 
	*		"Evaluating confidence interval methods 
	*		for binomial proportions in clustered 
	*		surveys." Journal of Survey Statistics 
	*		and Methodology 3.4 (2015): 484-503.
	*
	
	* variable is an indicator variable that takes values 0, 1, or .
	* LEVEL is 100-alpha
	* CILEVELLIST is a list of LEVELS for which we want to calculate CIs
	* - If we only want the 100-alpha CI, then CILEVELLIST should be blank
	* - If we want more than one CI, e.g., to make an inchworm plot, specify
	*   the levels here (e.g., if you want the 0.01% 10% 50% 95% and 99.99% CIs
	*   then set CILEVELLIST(0.01 10 50 95 99.99)
	* METHOD:	WALD, WILSON, CLOPPER-PEARSON, LOGIT, AGRESTI-COULL
	*			JEFFREYS or FLEISS 
	*			(Note that if P is 0 or 1 and method is WALD, WILSON
	*			 or AGRESTI-COULL then the program calculates 
	*			 CLOPPER-PEARSON intervals.)
	* If the Adjust option is specified, then the CI calculations will
	* be adjusted for design degrees of freedom.
	*
	* If the Truncate option is specified then if the design effect happens
	* to be < 1 then the DEFF is truncated at 1 and the CI is calculated
	* using the full sample size, as if it were a simple random sample.
	
********************************************************************************

	local v `varlist'

	* we need the local macro `if' to be populated in the code
	* so load it up if it is empty
	if `"`if'"' == "" local if `"if 1==1 "'
		
	* Halt if the variable of interest takes values other than 0,1,.
	
	capture assert inlist(`v',0,1,.)
	
	if _rc != 0 {
		display as error "To use the svypd command, the variable `v' should contain only 0's, 1's, and missing values."
		if "VCQI_LOGOPEN" == "1" {  // Send an error to the VCQI log if appropriate
			vcqi_log_comment svypd 1 Error "To use the svypd command, the variable `v' should contain only 0's, 1's, and missing values."
			vcqi_halt_immediately
		}
		else exit 99
	}
	
	* Halt if there are no 0's or 1's in variable of interest
	
	capture assert `v' == .
	if _rc == 0 svyp_null_result
	
	/*if _rc == 0 {
		display as error "All values of `v' are missing.  Proportion calculation is not meaningful."
		if "VCQI_LOGOPEN" == "1" {
			vcqi_log_comment svypd 1 Error "All values of `v' are missing.  Proportion calculation is not meaningful."
			vcqi_halt_immediately
		}
		else exit 99
	}
	*/
	
	* Fail gracefully if no observations meet the `if' criterion
	qui count `if' & !missing(`v') 
	if r(N) == 0 svyp_null_result	
	else {
	
		************************************************************************
						
		* Estimate parameters
		
		tempname phat se Nact df_strata df_cluster df_N df out Nwtd
		
		qui svy, subpop(`if') : proportion `v' 
		
		matrix `out' = r(table)
		
		* If the variable is 100% 0s or 100% 1s, then set phat, se, and Nwtd 
		* appropriately
		*
		* and if the variable is a mix of 1s and 0s, then use output from 
		* svyp: proportion to set phat, se, Nwtd
		
		if `out'[1,1] == 1  {
			qui count `if' & `v' == 1
			scalar `phat' = r(N) > 0
			scalar `se'   = 0
			matrix `out' = e(_N_subp)
			scalar `Nwtd' = `out'[1,1]
		}
		else {
			scalar `phat' = `out'[1,2]
			scalar `se'   = `out'[2,2]
			if `se' < 1E-16 | missing(`se') scalar `se' = 0
		
			matrix `out' = e(_N_subp)
			scalar `Nwtd' = `out'[1,2]
		}
			
		************************************************************************
		
		* Calculate degrees of freedom
		
		qui count `if' & inlist(`v',0,1)
		scalar `df_N' = r(N)
		
		* obtain name of cluster and strata variables for 1st stage of sampling
		qui svyset
		local strata  = r(strata1)
		local cluster = r(su1)

		if "`strata'" == "." local strata
		if "`cluster'" == "." local cluster
		
		* count the number of strata and clusters involved in 
		* the prevalence estimation
		if "`strata'" != "" {
			qui tab `strata' `if'
			scalar `df_strata' = r(r)
		}
		else scalar `df_strata' = 0
		
		* The df calculation should include ALL clusters in strata
		* where there are respondents who match the `if' criteria;
		* Use tempvars to be sure to count all those clusters, even
		* though some of the clusters may NOT contain respondents
		* who match the `if' criteria.
		*
		* This point is mentioned specifically in  
		* West, B. T., Berglund, P., & Heeringa, S. G. (2008). A closer 
		* examination of subpopulation analysis of complex-sample survey 
		* data. Stata J, 8(4), 520-31.
		
		if "`cluster'" != "" {
			tempvar markit1
			qui gen `markit1' = 1 `if'
			tempvar markit2
			if `df_strata' > 0 qui bysort `strata': egen `markit2' = max(`markit1')
			else egen `markit2' = max(`markit1')
			qui tab `cluster' if `markit2' == 1
			scalar `df_cluster' = r(r)	
		}
		else scalar `df_cluster' = 0
		
		* if strata and clusters then df = # clusters - # strata
		if "`strata'" != "" & "`cluster'" != "" {
			scalar `df' = `df_cluster' - `df_strata'
		}
		* if no clusters, then df = N - # strata
		if "`strata'" != "" & "`cluster'" == "" {
			scalar `df' = `df_N' - `df_strata'
		}
		* if not stratified, then df = # clusters - 1
		if "`strata'" == "" & "`cluster'" != "" {
			scalar `df' = `df_cluster' - 1
		}
		* if no clusters or strata, then df = N - 1
		if "`strata'" == "" & "`cluster'" == "" {
			scalar `df' = `df_N' - 1
		}
		* if the standard error is zero, there is no 
		* clustering effect so we set df = N - 1
		if `=scalar(`se')' == 0 {
			scalar `df' = `df_N' - 1
		}
		
		************************************************************************

		svyp_ci_calc, p(`=scalar(`phat')') 					///
					  stderr(`=scalar(`se')') 				///
					  n(`=scalar(`df_N')') 					///
					  dof(`=scalar(`df')')    				///
					  level(`level') 						///
					  cilevellist(`cilevellist')            ///
					  nweighted(`=scalar(`Nwtd')') 			///
					  nclusters(`=scalar(`df_cluster')')    ///
					  method(`method') `adjust' `truncate'
	}
		
end
