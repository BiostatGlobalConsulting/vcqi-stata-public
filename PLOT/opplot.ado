*! opplot version 1.05 - Biostat Global Consulting - 2016-09-10
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*-------------------------------------------------------------------------------
* 2015-12-21	1.01	MK Trimner		Added Starting comment and VCP globals
*
*										Put error to the vcqi_log as well as screen
*
* 2016-02-24	1.02	Dale Rhoda		Only set VCP and call vcqi_log_comment
*          								if VCQI is running; allows the possibility
*										to call the program from outside VCQI
* 										
* 2016-03-12	1.03	Dale Rhoda		Added option to save the plotting dataset
* 
* 2016-07-04	1.04	Dale Rhoda		I'm seeing ties in coverage across 
*										many strata (often at 100%) and so
* 										added a condition that sorts the plots
*										in descending order of coverage, with
*										ties broken by descending order of
*										weight, and ascending order of 
*										cluster ID (clustvar)
*
* 2016-09-10	1.05	Dale Rhoda		Improve option to save plotting dataset
*
*******************************************************************************

*******************************************************************************
*******************************************************************************
*
* This program makes so-called organ pipe plots, as described briefly in 
* the new World Health Organization Expanded Programme on Immunization 
* Vaccination Coverage Cluster Survey Reference Manual
*
* http://www.who.int/entity/immunization/monitoring_surveillance/Vaccination_coverage_cluster_survey.pdf 
*
* http://www.who.int/entity/immunization/monitoring_surveillance/Vaccination_coverage_cluster_survey_annex.pdf 
*
* I will write a help file soon.
*
* There is an accompanying small program that demonstrates some of the 
* options on data from a real survey.
*
* Contact Dale Rhoda at Biostat Global Consulting with questions
*
* Dale.Rhoda@biostatglobal.com
* +1 (614) 499-2351
*
*******************************************************************************
*******************************************************************************

program define opplot

	syntax varlist(max=1) [if] [in], CLUSTVAR(varname fv) ///
	[STRATVAR(varname fv) STRATUM(string) WEIGHTvar(varname) ///
	 TITLE(string) SUBtitle(string) FOOTnote(string) ///
	 BARCOLOR1(string) LINECOLOR1(string) ///
	 BARCOLOR2(string) LINECOLOR2(string) ///
	 XTITLE(string) YTITLE(string) XLABEL(string) YLABEL(string) ///
	 EXPORTSTRAtumname EXPORT(string) EXPORTWidth(integer 2000) ///
	 SAVING(string asis) NAME(string) SAVEDATA(string asis) ///
	 XSIZE(real -9) YSIZE(real -9) ]
	
	if "$VCQI_LOGOPEN" == "1" {		
		local oldvcp $VCP
	global VCP opplot
		vcqi_log_comment $VCP 5 Flow "Starting"
	}
	tokenize "`varlist'"
	local yvar `1'
	
	quietly {
	
		preserve
		
		tempvar wclust wstrat bartop barwidth yweight wsum1 barheight cumulative_barwidth clustvar_copy n_respondents
		
		* Make a copy of clustvar to save at the end of the program
		clonevar `clustvar_copy' = `clustvar'
		
		* if the user doesn't specify a stratum, generate one for the program to use
		if "`stratvar'" == "" {
			tempvar stratumvariable 
			gen `stratumvariable' = 1
			local stratvar `stratumvariable'
			local stratum 1
		}
		
		* if the user doesn't specify a weight variable, generate one
		if "`weightvar'" == "" {
			tempvar weightvariable
			gen `weightvariable' = 1
			local weightvar `weightvariable'
		}
		
		* if y contains anything but 0 or 1 or . then fail
		capture tostring `stratvar', replace force
		capture assert inlist(`yvar',0,1,.) if `stratvar' == "`stratum'"
		if _rc == 9 {
			display as error "opplot Error: `yvar' should only have values of 0 or 1 or . when `stratvar' == `stratum'."

			if "$VCQI_LOGOPEN" == "1" {
				vcqi_log_comment $VCP 1 Error "opplot Error: `yvar' should only have values of 0 or 1 or . when `stratvar' == `stratum'."
				vcqi_halt_immediately
			}
		}
		
		* establish default values if the user doesn't specify them
		if "`ylabel'" == "" local ylabel 0(50)100, angle(h)
		if "`ytitle'" == "" local ytitle Percent of Cluster
		if "`barcolor1'"  == "" local barcolor1 pink
		if "`linecolor1'" == "" local linecolor1 `barcolor'*1.5
		if "`barcolor2'"  == "" local barcolor2 white
		if "`linecolor2'" == "" local linecolor2 black*0.5
		if "`exportstratumname'" != "" {
			local export `stratum'.png
		}
		if `"`name'"' != "" local namestring name(`=substr("`name'",1,min(32,length("`name'")))')
		if `"`saving'"' != "" local savingstring saving(`saving')
		if `xsize'  != -9 local xsizestring xsize(`xsize')
		if `ysize'  != -9 local ysizestring ysize(`ysize')

		* keep track of the number of respondents per cluster
		bysort `stratvar' `clustvar': gen `n_respondents' = _N

		* calculate sum of survey weights in each cluster and stratum
		bysort `stratvar' `clustvar': egen `wclust' = total(`weightvar')
		bysort `stratvar'           : egen `wstrat' = total(`weightvar')
		
		* calculate the proportion of the stratum weight in each cluster
		* (this corresponds to the bar width)
		gen `barwidth' = 100 * `wclust' / `wstrat'

		* calculate sum of survey weights for respondents with outcome = 1
		gen `yweight' = `yvar' * `weightvar'
		bysort `stratvar' `clustvar': egen `wsum1' = total(`yweight')

		* the height of each bar is the weighted proportion of respondents
		* with outcome = 1
		gen `barheight' = round(100*`wsum1'/`wclust')

		* keep only one observation per cluster
		bysort `stratvar' `clustvar': keep if _n == 1
		
		* keep only observations in the stratum of interest
		keep if `stratvar' == "`stratum'"
		
		* sort the bars, left-to-right, in descending order of height and width
		* (and if there are ties...then sort the ties by ascending clusterID)
		gsort -`barheight' -`barwidth' `clustvar'
		
		* the background bars always have a height of 100%
		gen `bartop' = 100	
		
		* Stata's facility for barcharts with varying widths requires a 
		* variable that codes the cumulative barwidth
		gen `cumulative_barwidth' = sum(`barwidth')
			
		* add an extra row onto the dataset to make the x values work out correctly
		set obs `=_N+1'
		* shift the width up by one observation to make the x values 
		* work out correctly
		forvalues i = `=_N'(-1)2 {
			replace `cumulative_barwidth' = `=`cumulative_barwidth'[`=`i'-1']' in `i'
		}
		replace `cumulative_barwidth' = 0 in 1
			
		graph twoway ///
		(bar `bartop' `cumulative_barwidth', bartype(spanning) fcolor(`barcolor2') ///
			lpattern(solid) lcolor(`linecolor2') lwidth(*.1) ) ///
		(bar `barheight' `cumulative_barwidth', bartype(spanning) fcolor(`barcolor1') ///
			lpattern(solid) lcolor(`linecolor1') lwidth(*.1) ) ,  ///
		graphregion(fcolor(white)) legend(off) ///
		xtitle("`xtitle'") xlabel(none) ///
		ytitle("`ytitle'") ylabel(`ylabel') ///
		title(`title') subtitle(`subtitle') note(`footnote') ///
		`namestring' `savingstring' `xsizestring' `ysizestring'

		if "`export'" != "" {
			graph export "`export'", width(`exportwidth') replace
		}
		
		* If the user has asked for underlying data to be saved, then
		* trim down to a small dataset that summarizes what is shown in 
		* the bars; this is to help users identify the clusterid of a
		* particular bar in the figure; the order in which clusterids
		* appear in the saved dataset is the same order they appear in 
		* the plot

		if "`savedata'" != "" {
			drop in `=_N'
			capture drop yvar
			gen yvar = "`yvar'"
			capture drop stratvar
			gen stratvar = "`stratvar'"
			capture drop stratum
			gen stratum = "`stratum'"
			capture drop cluster
			gen cluster = "`clustvar'"
			capture drop `clustvar'
			rename `clustvar_copy' `clustvar'
			capture drop n_respondents
			rename `n_respondents' n_respondents
			capture drop barorder
			gen barorder = _n
			capture drop barwidth
			rename `barwidth' barwidth
			* replace cumulative barwidth with values that start at the width of bar 1
			capture drop cumulative_barwidth
			gen cumulative_barwidth = sum(barwidth)	
			capture drop barheight
			rename `barheight' barheight
			keep  yvar stratvar stratum cluster `clustvar' n_respondents barorder barwidth cumulative_barwidth barheight		
			order yvar stratvar stratum cluster `clustvar' n_respondents barorder barwidth cumulative_barwidth barheight		
			capture save "`savedata'", replace
		}
	}
	
	if "$VCQI_LOGOPEN" == "1" {
		vcqi_log_comment $VCP 5 Flow "Exiting"
		global VCP `oldvcp'
	}
end
