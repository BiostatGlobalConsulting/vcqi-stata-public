*! svyp_ci_calc version 1.11 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed

* 2016-10-23	1.0		Dale Rhoda		First version
*										This program is used as a 
*										stand-alone calculator and is also
*										called by svypd

* 2016-11-15	1.01	Dale Rhoda		Changed Logit formula to use neff

* 2016-11-15	1.02	Dale Rhoda		Improved arcsine interval with 
*										min and max to induce asymptotic 
*										behavior near 0 and 1
*
* 2016-11-16    1.03	Dale Rhoda		Switched from using scalars to
*										using double-precision variables
*
* 										Added Fleiss & Anscombe intervals
*
* 2016-11-30	1.04	Dale Rhoda		Cosmetic changes
*
* 2017-01-03	1.05	Dale Rhoda		Correct DEFF calculation
*
* 2017-01-04	1.06	Dale Rhoda		Replace neff with n if using
*										Clopper-Pearson and sample proportion
*										is 0 or 1
*
* 2017-01-09	1.07	Dale Rhoda		Change svyp to svypd in error msgs
*
* 2017-05-15	1.08	Dale Rhoda		Pass stderr as an output
*
* 2017-08-16  	1.09  	Dale Rhoda    	Fix two problems with Agresti-Coull CI code
*
* 2017-08-18	1.10	Dale Rhoda		Remove arcsine and Anscombe options
*										because of their problems with wrap-
*										around when p-hat is near 0 or 1
*
* 2017-08-26	1.11	Mary Prier		Added version 14.1 line
*-------------------------------------------------------------------------------

program define svyp_ci_calc, rclass	
	version 14.1
	
	syntax , P(numlist >=0 <=1 min=1 max=1)			///
	         STDERR(real) N(real) 					///
		     [LEVEL(numlist >0 <100 min=1 max=1)  	///
			  CILEVELLIST(numlist >0 <100)     		///
			  Method(string) DOF(integer -999) 		///
			  Adjust TRUNCate 						///
			  NWeighted(numlist >=0 min=1 max=1) 	///
			  NCLUSTers(integer -999)	]

	
	* Uses nomenclature from
	*		Dean, Natalie, and Marcello Pagano. 
	*		"Evaluating confidence interval methods 
	*		for binomial proportions in clustered 
	*		surveys." Journal of Survey Statistics 
	*		and Methodology 3.4 (2015): 484-503.
	*
	* P   = estimated proportion
	*
	* N   = sample size
	*
	* STDERR  = std error
	*
	* DOF = degrees of freedom (if not specified, DOF is set to N-1)
	*
	* User sets either LEVEL ( a single number: 100-alpha ) or 
	*                  CILEVELLIST ( a list of levels: a CI is calc'd for each)
	
	* CILEVELLIST is a list of LEVELS for which we want to calculate CIs
	* - If we only want the 100-alpha CI, then CILEVELLIST should be blank
	* - If we want more than one CI, e.g., to make an inchworm plot, specify
	*   the levels here (e.g., if you want the 0.01% 10% 50% 95% and 99.99% CIs
	*   then set CILEVELLIST(0.01 10 50 95 99.99)
	*
	* METHOD:	Wald, Wilson, Clopper, Clopper-Pearson, Jeffreys, Agresti, Agresti-Coull, Logit, Fleiss or Wilsoncc 
	*
	*			Note that if P is 0 or 1 and method is WALD or WILSON
	*			then the program calculates a CLOPPER-PEARSON intervals.
	*
	* ADJUST	If the 'Adjust' option is used, then the effective sample size
	*		    is adjusted for design degrees of freedom, using the effective 
	*			sample size calculated as suggested in Dean & Pagano, 2015 
	*
	* TRUNCATE  If this option is specified, then if DEFF < 1, the effective
	*			sample size is clipped to go no higher than N and the DEFF
	*			is set to 1.  If the option is NOT specified, DEFF can be < 1
	*			and NEFF can be > N.
	*
	* NWEIGHTED	This is a pass-thru option, when this function is called
	*			from svyp_with_levellist.  It passes the number thru as an 
	*			output.
	*
	* NCLUSTERS	This is also a pass-thru.
	*
	*
********************************************************************************

	quietly {
	
		* Check the method option
		
		if `"`method'"' == "" local method Logit
			
		* Make sure method is valid
		
		local method = proper("`method'")
		if !inlist("`method'","Wald","Wilson","Clopper","Clopper-Pearson") & ///
		   !inlist("`method'","Jeffreys","Agresti","Agresti-Coull","Logit") & ///
		   !inlist("`method'","Arcsine","Fleiss","Wilsoncc","Anscombe") 	{
			noi display as error                  "The method option must be either Wald, Wilson, Clopper, Clopper-Pearson, Jeffreys, Agresti, Agresti-Coull, Logit, Fleiss or Wilsoncc"
			if "$VCQI_LOGOPEN" == "1" {
				vcqi_log_comment svypd 1 Error "The method option must be either Wald, Wilson, Clopper, Clopper-Pearson, Jeffreys, Agresti, Agresti-Coull, Logit, Fleiss, or Wilsoncc"
				vcqi_halt_immediately
			}
			else exit 99
		}
		
		* User may not specify both LEVEL and CILEVELLIST
		
		if "`level'" != "" & "`cilevellist'" != "" {
			noi display as error "For svy_ci_calculator: specify LEVEL or CILEVELLIST, but not both"
			if "$VCQI_LOGOPEN" == "1" {
				vcqi_log_comment svypd 1 Error "For svy_ci_calculator: specify LEVEL or CILEVELLIST, but not both"
				vcqi_halt_immediately
			}
			else exit 99
		}

	********************************************************************************

		* Set the cilevellist
			
		if "`level'" != "" {
			local minus -
			if `level' > 50 local cilevellist `level' `= 100 - 2*(100 `minus' `level')'
			else local cilevellist `level'
		}
				
		* Default level of 95
		
		if "`cilevellist'" == "" & "`level'" == "" local cilevellist 95 90			

		local ncis = wordcount("`cilevellist'")

	********************************************************************************
		
		* Prepare building blocks for each element of the CILEVELLIST
		
		preserve
		
		clear
		
		qui set obs `ncis'
		
		qui gen double level = .
		
		forvalues i = 1/`ncis' {
			qui replace level = real( word("`cilevellist'",`i') ) in `i'
		}
		
		gen double phat    = `p'
		gen double pqhat   = phat * ( 1 - phat )
		gen double se      = `stderr'
		gen double n       = `n'
		
		local pstring  = strofreal(`p',     "%5.3f")
		local sestring = strofreal(`stderr',"%5.3f")
		
		gen double neff = pqhat / se^2
		
		if ("`pstring'"  == "1.000" | "`pstring'" == "0.000" | ///
			"`sestring'" == "0.000" ) replace neff = n
						
		gen double df_N  = round(n,1)
		
		if "`dof'" != "-999" gen double df = `dof'
		else gen double df = df_N - 1
		
		gen double DEFF = (df_N-1) / neff
		
		replace DEFF = 1 if abs(DEFF-1) < 0.00001		
		
		gen double ao2     = (100 - level) / 100 / 2  
		gen double zao2    = invnormal(1-ao2)
		gen double acc		 = (zao2^2)/2 // Agresti-Coull c
		
		*noi di "df_n = `=df_N[1]'; df = `=df[1]'"
		
		gen double tdfNao2 = invt(df_N-1,1-ao2) // not used here...we would use it if we used the K&G 1998 neff
		gen double tddfao2 = invt(df,1-ao2)
		
		*noi di "t1 = `=tdfNao2[1]'; t2 = `=tddfao2[1]'"
			
		* Adjust the Neff if user has specifed the adjust option 
		if "`adjust'" != ""  {
			*noi di "neff = `=neff[1]'"
			qui replace neff = neff * (zao2 / tddfao2)^2 
			*qui replace neff = neff * (tdfNao2 / tddfao2)^2 // use this line instead of the former line to calculate K&G 1998 neff
			*noi di "neff = `=neff[1]'"
		}
			
		* Replace effective sample size with actual sample size if 
		* DEFF < 1 and user has asked to truncate the DEFF to be >= 1
		if "`truncate'" != "" & DEFF[1] < 1 {
			qui replace neff = `n'
			qui replace DEFF = 1
		}
		
	********************************************************************************
	********************************************************************************
		
		if "`method'" == "Wald" {
		
			* If p is 0 or 1, skip the Wald calculation  and go to Clopper-Pearson
			if real("`p'") == 0 | real("`p'") == 1 local method = "Clopper-Pearson"
			else {
				gen lcb_2sided = phat - abs(zao2 * sqrt(pqhat/neff))
				gen ucb_2sided = phat + abs(zao2 * sqrt(pqhat/neff))
			}
		}


	********************************************************************************
	********************************************************************************
		
		if "`method'" == "Logit" {
			* If p is 0 or 1, skip the Logit calculation  and go to Clopper-Pearson
			if real("`p'") == 0 | real("`p'") == 1 local method = "Clopper-Pearson"
			else {
				gen double term1 = ln(phat/(1-phat))
				gen double term2 = zao2 / sqrt( neff * pqhat )
				
				gen double combo1 = term1 - term2
				gen double lcb_2sided = exp(combo1) / (1 + exp(combo1))
				
				gen double combo2 = term1 + term2
				gen double ucb_2sided = exp(combo2) / (1 + exp(combo2))
				
				drop term1 term2 combo1 combo2
			}
		}

	********************************************************************************
	********************************************************************************
		
		if "`method'" == "Wilson" {

			* If p is 0 or 1, skip the Wilson calculation  and go to Clopper-Pearson
			if real("`p'") == 0 | real("`p'") == 1 local method = "Clopper-Pearson"
			else {
				gen double term1 = phat + ((zao2)^2)/(2*neff)
				gen double term2 = zao2 * sqrt((pqhat/neff) + ((zao2)^2)/((2*neff)^2))
				gen double term3 = 1 + ((zao2)^2)/neff
			
				gen double lcb_2sided = (term1 - term2) / term3
				gen double ucb_2sided = (term1 + term2) / term3

				drop term1 term2 term3
			}
		}

	********************************************************************************
	********************************************************************************
		
		if "`method'" == "Jeffreys" {

			gen double x = phat*neff
			gen double alpha1 = x + 0.5
			gen double beta1  = neff - x + 0.5
				
			gen double lcb_2sided = invibeta(alpha1,beta1,  ao2)
			gen double ucb_2sided = invibeta(alpha1,beta1,1-ao2)
			
			replace lcb_2sided = 0 if phat == 0
			replace ucb_2sided = 1 if phat == 1
			
			drop x alpha1 beta1
		}

	********************************************************************************
	********************************************************************************
		
		if inlist("`method'", "Agresti", "Agresti-Coull") {
				
			gen double xtilde  = phat*neff + acc
			gen double ntilde  =      neff + 2*acc
			gen double ptilde  = xtilde / ntilde
			gen double pqtilde = ptilde * ( 1 - ptilde )
				
			gen double lcb_2sided = ptilde - zao2 * sqrt( pqtilde / ntilde ) 
			gen double ucb_2sided = ptilde + zao2 * sqrt( pqtilde / ntilde )

			drop xtilde ntilde ptilde pqtilde
		}

	********************************************************************************
	********************************************************************************
		
		if inlist("`method'", "Fleiss", "Wilsoncc" ) {
				
			gen double term1l = 2*neff*phat + zao2^2 - 1
			gen double term2l = zao2*sqrt(zao2^2 - ( 2 + (1/neff)) + 4*phat*(neff*(1-phat)+1))
			gen double term3  = 2*(neff+zao2^2)
			
			gen double lcb_2sided = (term1l - term2l)/term3

			gen double term1u = term1l + 2
			gen double term2u = zao2*sqrt(zao2^2 + ( 2 - (1/neff)) + 4*phat*(neff*(1-phat)-1))
			
			gen double ucb_2sided = (term1u + term2u)/term3
			
			replace lcb_2sided = 0 if phat == 0
			replace ucb_2sided = 1 if phat == 1

			drop term1l term2l term1u term2u term3
		}

	********************************************************************************
	********************************************************************************

		if inlist("`method'", "Clopper-Pearson", "Clopper") {
		
			* If the sample proportion is 0 or 1, consider the 
			* effective sample size to be equal to the actual sample size
			if real("`p'") == 0 | real("`p'") == 1 qui replace neff = n

			gen double  x = phat*neff
			gen double v1 = 2*x
			gen double v2 = 2*(neff-x+1)
			gen double v3 = 2*(x+1)
			gen double v4 = 2*(neff-x)
			
			forvalues j = 1/4 {
				qui replace v`j' = max(2e-10,v`j')
				qui replace v`j' = min(2e+17,v`j')
			}					
					
			gen double fao2       = invF(v1,v2,ao2)
			gen double lcb_2sided = (v1*fao2)/(v2 + v1*fao2)

			gen double f1mao2     = invF(v3,v4,1-ao2)
			gen double ucb_2sided = (v3*f1mao2) / (v4 + v3*f1mao2)
			
			* If v4 is very small, the UCB ratio is set to missing 
			* instead of 1, so check for this condition here
			qui replace    ucb_2sided = 1 if v4 <= 2e-10 
			
			drop x v1 v2 v3 v4 fao2 f1mao2
		}

	********************************************************************************

		* Put results in a matrix named ci_list

		capture matrix drop ci_list
		mkmat                     level lcb_2sided ucb_2sided, matrix(ci_list)
		matrix colnames ci_list = level lcb_2sided ucb_2sided

		* Return scalars, macros, and matrices 
		
		tempname svyp clusters Nwtd
		
		* Adjust the point estimate if user requested Agresti-Coull method;
		* Otherwise pass thru p as the output svyp.
		if inlist("`method'", "Agresti", "Agresti-Coull") scalar `svyp' = (phat[1]*neff[1]+acc[1]) / (neff[1]+acc[1]+acc[1])
		else scalar `svyp' = `p'
			
		if "`nclusters'" == "-999" scalar `clusters' = .
		else scalar `clusters' = `nclusters'
		
		if "`nweighted'" == "" scalar `Nwtd' = .
		else scalar `Nwtd' = `nweighted'
		
		return scalar clusters = `clusters'
		return scalar Nwtd = `Nwtd'
		return scalar N = `n'
		
		return local method = "`method'"
		
		return scalar deff = DEFF[1]
		return scalar df   = df[1]
		return local cilevellist = "`cilevellist'"

		* Put bounds of 100-alpha and 100-(2*alpha) CIs in scalars
		* if the user specified level and it was > 50
		if "`cilevellist'" == "95 90" | ("`level'" != "" & `ncis' == 2) {
			return scalar ub_2alpha  = ci_list[2,3]
			return scalar lb_2alpha  = ci_list[2,2]
		}

		return scalar ub_alpha   = ci_list[1,3]
		return scalar lb_alpha   = ci_list[1,2]
		
		if "`level'" != "" local lvl `level'
		else local lvl 95
		
		return scalar stderr = `stderr'
			
		*noi di "svyp: " string(`p',"%5.3f") ///
		*   " (" string(ci_list[1,2],"%5.3f")	///
		*   "-"   string(ci_list[1,3],"%5.3f") ")"  ///
		*   " Level: `lvl'  `method'"

		return scalar svyp = `svyp'

		return matrix ci_list   = ci_list
		
		restore
	}
end
