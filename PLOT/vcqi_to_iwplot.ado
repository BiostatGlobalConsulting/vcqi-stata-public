*! vcqi_to_iwplot version 1.21 - Biostat Global Consulting - 2021-01-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		vcqi_log_comment missing "Error" added to the below lines:
*										vcqi_log_comment $VCP 1 Error "The VCQI database passed in to this program does not seem to exist."
*										vcqi_log_comment $VCP 1 Error "The database named was `database'."			
*
* 2016-01-12	1.02	D. Rhoda		Updated to go with iwplot_vcqi v. 1.10
*
* 2016-08-07 	1.04	D. Rhoda		Updated with default iwplot NL value
* 2016-09-08	1.05	D. Rhoda		Added Plots_IW_UW folder
* 2016-09-15	1.06	D. Rhoda		Added caption option
* 2017-01-31	1.07	D. Rhoda		Cleaned up code
* 2017-02-15	1.08	Dale Rhoda		Allow plotting with LEVEL4_SET_VARLIST
*										and use lighter shade for level4 rows
* 2017-02-21	1.09	Dale Rhoda		Put lines across plot if showing 
*										Levels 2 & 4 together
* 2017-03-18	1.10	Dale Rhoda		Only shade level 1 if we are also 
*										showing results from level 2 or 3
* 2017-05-16	1.11	Dale Rhoda		Restructured to also make level2 plots
*										if the user requests them 
* 2017-05-18	1.12	Dale Rhoda		Change to default blue colors
* 2017-05-19	1.13	Dale Rhoda		Fix a problem with quotation marks
* 2017-05-26	1.14	Dale Rhoda		Handle vertical lines when national 
*										results are at the top or bottom row
* 2017-08-26	1.15	Mary Prier		Added version 14.1 line
* 2018-01-16	1.16	MK Trimner 		Added $VCQI_SVYSET_SYNTAX
* 2019-03-18	1.17	Mary Prier		Added user option/global "SORT_PLOT_LOW_TO_HIGH";
*										  Option high to low (global=1) requires gsort;
* 										  Default is sorting low to high and using sort
* 2020-04-18	1.18	Dale Rhoda		Added VCQI_IWPLOT_CITEXT option; takes
*                                       values 1, 2, 3, 4 or 5 in accorance with
*                                       iwplot_svyp.  Adjust the note accordingly.
* 2020-12-09	1.19	Dale Rhoda		Allow the user to plot strata in table order
* 2020-12-12	1.20	Dale Rhoda		Allow the user to SHOW_LEVEL_4_ALONE
* 2021-01-13	1.21	Dale Rhoda		Adjust note syntax to handle CITEXT 3 and 4
*******************************************************************************

program define vcqi_to_iwplot
	version 14.1
	
	syntax , DATABASE(string asis) FILETAG(string) ///
	[ DATAFILE(string asis) TITLE(string asis) NAME(string) ///
	  SUBTITLE(string asis) NOTE(string asis) CAPTION(string asis) ]
	
	local oldvcp $VCP
	global VCP vcqi_to_iwplot
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	capture confirm file "`database'.dta"
	
	if _rc != 0 {
		di as error "vcqi_to_iwplot: The VCQI database passed in to this program does not seem to exist."
		di as error "vcqi_to_iwplot: The database named was `database'."
		
		vcqi_log_comment $VCP 1 Error "The VCQI database passed in to this program does not seem to exist."
		vcqi_log_comment $VCP 1 Error "The database named was `database'."
		
		vcqi_halt_immediately
	}

	use "`database'", clear
	
	* Drop Level 4 labels if using the SET nomenclature
	if "$VCQI_LEVEL4_SET_VARLIST" != "" & "$LEVEL4_SET_CONDITION_1" == "" drop if level4id == 1
	
	local show4 = $SHOW_LEVEL_4_ALONE         + ///
				  $SHOW_LEVELS_1_4_TOGETHER   + ///
				  $SHOW_LEVELS_2_4_TOGETHER   + ///
				  $SHOW_LEVELS_3_4_TOGETHER   + ///
				  $SHOW_LEVELS_2_3_4_TOGETHER > 0
				   
	local show3 = $SHOW_LEVEL_3_ALONE         + ///
				  $SHOW_LEVELS_2_3_TOGETHER   + ///
				  $SHOW_LEVELS_3_4_TOGETHER   + ///
				  $SHOW_LEVELS_2_3_4_TOGETHER > 0 

	local show2 = $SHOW_LEVEL_2_ALONE         + ///
				  $SHOW_LEVELS_2_3_TOGETHER   + ///
				  $SHOW_LEVELS_2_4_TOGETHER   + ///
				  $SHOW_LEVELS_2_3_4_TOGETHER > 0 
				   
	local show1 = $SHOW_LEVEL_1_ALONE + $SHOW_LEVEL_4_ALONE + $SHOW_LEVELS_1_4_TOGETHER > 0			   

	if `show4' == 0 drop if level4id != .

	if `show3' == 0 drop if level == 3

	if `show2' == 0 drop if level == 2

	if `show1' == 0 drop if level == 1

	forvalues i = 1/4 {
		if `show`i'' == 1 local showmax `i'
	}
	forvalues i = 4(-1)1 {
		if `show`i'' == 1 local showmin `i'
	}

	local show2plus = (`show4' + `show3' + `show2' + `show1') > 1

	local l3est
	local l2est

	if `show3' == 1 & `show4' == 1 {
		gen level3_dropthis = estimate if level == 3 & level4id == .
		bysort level3id: egen level3_estimate = max(level3_dropthis)
		drop level3_dropthis
		replace level3_estimate = . if level3id == .
		local l3est level3_estimate level3id
	}
	if `show3' == 1 & `show4' == 0 gen level3_estimate = estimate
	capture order level3_estimate, after(outcome)

	if `show2' == 1 & (`show3' == 1 | `show4' == 1) {
		gen level2_dropthis = estimate if level == 2 & level4id == .
		bysort level2id: egen level2_estimate = max(level2_dropthis)
		drop level2_dropthis
		replace level2_estimate = . if level2id == .
		local l2est level2_estimate level2id
	}
	if `show2' == 1 & (`show3' + `show4' == 0 ) gen level2_estimate = estimate
	capture order level2_estimate, after(outcome)

	if `show1' == 1 & (`show2' == 1 | `show3' == 1 | `show4' == 1) {
		gen level1_dropthis = estimate if level == 1 & level4id == .
		bysort level1id: egen level1_estimate = max(level1_dropthis)
		drop level1_dropthis
		order level1_estimate, after(outcome)
	}

	if `show1' == 1 & `show2' == 1 replace level2_estimate = level1_estimate if level2_estimate == .
	if `show1' == 1 & `show2' == 0 & `show3' == 1 replace level3_estimate = level1_estimate if level3_estimate == .
	if `show2' == 1 & `show3' == 1 replace level3_estimate = level2_estimate if level3_estimate == .

	* Sort proportions based on user request 
	*  Default is sorting proportions low at bottom of plot to high at top of plot
	if("$SORT_PLOT_LOW_TO_HIGH"=="0") {  // meaning, sort prop high to low
		* Expand locals so that each element gets a negative sign;
		* This code doesn't assign minus sign to empty locals, because don't 
		*   want a floating minus sign
		* First, l2est
		local gsort_l2est 
		local n_l2est : word count `l2est'
		if(`n_l2est'>0) {
			forvalues i=1/`n_l2est' {
				local gsort_l2est `gsort_l2est' -`: word `i' of `l2est''  // add the minus to the element
			} 
		}  
	
		* Now, l3est
		local gsort_l3est 
		local n_l3est : word count `l3est'
		if(`n_l3est'>0) {
			forvalues i=1/`n_l3est' {
				local gsort_l3est `gsort_l3est' -`: word `i' of `l3est''  // add the minus to the element
			} 
		}  

		* Finally, do the gsort
		gsort `gsort_l2est' `gsort_l3est' -estimate 
		if `show4' == 1 gsort `gsort_l2est' `gsort_l3est' -estimate -level4id
	}
	else {
		sort `l2est' `l3est' estimate 
		if `show4' == 1 sort `l2est' `l3est' estimate level4id
	}
	
	* If user wants strata plotted in table order, merge the table order
	* and sort accordingly
	
	if "$PLOT_OUTCOMES_IN_TABLE_ORDER" == "1" {

		vcqi_log_comment $VCP 3 Comment "User has requested that outcomes be plotted in table order instead of sorting by indicator outcome."
		preserve
		make_table_order_database
		make_table_order_dataset
		restore
			
		replace level2id = 0 if missing(level2id)
		replace level3id = 0 if missing(level3id)
		replace level4id = 0 if missing(level4id)		
		merge 1:m level1id level2id level3id level4id using "${VCQI_OUTPUT_FOLDER}/table_order_TO"
		keep if _merge == 1 | _merge == 3
		drop _merge
		sort table_bottom_to_top_row_order
	}
	
	keep if !missing(estimate)
		
	keep name n deff estimate level level*id outcome
		
	* populate param4, 5, 6, and 7 in case the user decides to plot distributions from the data later
	gen rightid = .
	replace rightid = level3id if level == 3
	replace rightid = level2id if level == 2
	replace rightid = level1id if level == 1
	gen param7 = "if level" + string(level) + "id == " + string(rightid)
	if "$VCQI_LEVEL4_STRATIFIER"  != "" replace param7 = param7 + " & $VCQI_LEVEL4_STRATIFIER == " + string(level4id) if !missing(level4id) 
	if "$VCQI_LEVEL4_SET_VARLIST" != "" {
		forvalues i = 1/$LEVEL4_SET_NROWS {
			replace param7 = param7 + " & ${LEVEL4_SET_CONDITION_`i'} " if level4id == `i' & "${LEVEL4_SET_CONDITION_`i'}" != ""
		}
	}

	gen param6 = "$VCQI_SVYSET_SYNTAX"
	gen param5 = outcome
	gen param4 = "`datafile'"

	gen source  = "DATASET"
	gen disttype = "SVYP"
	gen nparams  = 7
	gen param1 = round(n/deff,1) // effective sample size
	gen param2 = estimate
	gen param3 = "$VCQI_CI_METHOD" 
	
	gen outlinecolor = "vcqi_outline"

	* User specifies the colors for levels 1-4 in their adopath
	* 
	* There are files named color-vcqilevel1.style (and 2, 3, 4)
	* and color-vcqioutline.style
	* somewhere in the adopath...change the RGB values of those
	* files to get different colors in the plots.
	
	gen areacolor = ""
	forvalues i = 1/3 {
		replace areacolor = "vcqi_level`i'" if level == `i'
	}
	replace areacolor = "vcqi_level4" if !missing(level4id)

	gen markvalue = .
	gen clip = 95
	gen lcb  = 95
	gen ucb  = 95
	gen lcbcolor = "gs7"
	gen ucbcolor = "gs7"
	gen shadebehind = "gs15" if level == 1 & (`show2' + `show3' > 0)

	gen rowname = name
	
	keep if !missing(estimate)

	save "Plots_IW_UW/iwplot_params_base", replace
	save "Plots_IW_UW/iwplot_params_`filetag'_`show1'`show2'`show3'`show4'", replace

	local pass_thru_options
	if `"`title'"' != "" local pass_thru_options `pass_thru_options' title(`title')
	if `"`subtitle'"' != "" local pass_thru_options `pass_thru_options' subtitle(`subtitle')
	if `"`note'"' != "" local pass_thru_options `pass_thru_options' note(`note')
	if `"`caption'"' != "" local pass_thru_options `pass_thru_options' caption(`caption')
		
	inchworm_plotit, filetag(`filetag') show1(`show1') show2(`show2') show3(`show3') ///
	        show4(`show4') `pass_thru_options' name(`name')
			
	* Make inchworm plot for every level 2 stratum, if requested

	if `show2' == 1 & "$VCQI_MAKE_LEVEL2_IWPLOTS" == "1" {
		use "$VCQI_DATA_FOLDER/level2names", clear
		forvalues i = 1/`=_N' {
			local l2name_`=level2id[`i']' = subinstr("`=level2name[`i']'"," ","_",.)
		}
		levelsof level2id, local(l2list)
		foreach l2l in `l2list' {

			use "Plots_IW_UW/iwplot_params_base", clear
			
			keep if level == 1 | level2id == `l2l'
			
			save "Plots_IW_UW/iwplot_params_`filetag'_l2_`l2l'_`show1'`show2'`show3'`show4'", replace
			
			inchworm_plotit, filetag(`filetag'_l2_`l2l') show1(`show1') show2(`show2') show3(`show3') ///
					show4(`show4') `pass_thru_options' name(`name'_l2_`l2l'_`l2name_`l2l'')
				
			vcqi_log_comment $VCP 3 Comment "Inchworm plot was created and exported."
		
			graph drop _all
		}
	}
	
	if $DELETE_TEMP_VCQI_DATASETS == 1 capture erase "Plots_IW_UW/iwplot_params_base"
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
	
program define inchworm_plotit
	version 14.1
	
	syntax ,  FILETAG(string) show1(integer) show2(integer) show3(integer) show4(integer) ///
	[ TITLE(string asis) NAME(string) ///
	  SUBTITLE(string asis) NOTE(string asis) CAPTION(string asis) ]
	  
	use "Plots_IW_UW/iwplot_params_`filetag'_`show1'`show2'`show3'`show4'", clear
	
	* Decide where to plot lines across the plot
	* For now, we only add horizontal lines where we transition between level2
	* strata and we only do it if we are showing both level 2 and level 3 strata

	if `show2' == 1 & `show3' == 1 {
		local ylist
		forvalues i = 1/`=_N-1' {
			if level2id[`i'] != level2id[`=`i'+1'] local ylist `ylist' `=`i'+0.5'
		}
		* Add a line above if the top row is showing national results
		if level[`=_N'] == 1 local ylist `ylist' `=_N + 0.5'
		* Add a line at the bottom if the first row shows national results
		if level[1]     == 1 local ylist 0.5 `ylist'		
	}
	
	if "`ylist'" != "" {
		
		clear
		set obs `=wordcount("`ylist'")'
		gen ycoord 		= .
		gen xstart 		= 0
		gen xstop  		= 100
		gen color		= "gs12"
		gen thickness 	= "thin"
		gen style     	= "foreground"
		forvalues i = 1/`=_N' {
			replace ycoord = real(word("`ylist'",`i')) in `i'
		}
		
		tempfile horlines
		
		save `horlines', replace
	}
	
	* override the user-specified note because we are using citext 1 and have
	* a particular note to go with that
	
	* Default to point estimate and 2-sided 95% CI
	if "$VCQI_IWPLOT_CITEXT" == "" vcqi_global VCQI_IWPLOT_CITEXT 2
	
	if "$VCQI_IWPLOT_CITEXT" == "1" ///
	local note Text at right: 1-sided 95% LCB | Point Estimate | 1-sided 95% UCB
	if "$VCQI_IWPLOT_CITEXT" == "2" ///
	local note Text at right: Point Estimate (2-sided 95% Confidence Interval)
	if "$VCQI_IWPLOT_CITEXT" == "3" ///
	local note Text at right: Point Estimate (2-sided 95% Confidence Interval) (0, 1-sided 95% UCB]
	if "$VCQI_IWPLOT_CITEXT" == "4" ///
	local note Text at right: Point Estimate (2-sided 95% Confidence Interval) [1-sided 95% LCB, 100)
	if "$VCQI_IWPLOT_CITEXT" == "5" ///
	local note Text at right: Point Estimate (2-sided 95% CI) (0, 1-sided 95% UCB] [1-sided 95% LCB, 100)

	local saving
	if $SAVE_VCQI_GPH_FILES ///
		local saving saving(Plots_IW_UW/`name'_`show1'`show2'`show3'`show4', replace)
		
	local export export(Plots_IW_UW/`name'_`show1'`show2'`show3'`show4'.png , width(2000) replace)	
	
	local clean 
	if $DELETE_TEMP_VCQI_DATASETS == 1 local clean cleanwork(YES)
	
	* If the user has not specified a value for NL, use a default of 30
	* (sometimes the user might specify a lower value to make fast, draft-quality plots
	*  but a value of 30 or 50 should be used for final product plots)
	
	if "$VCQI_IWPLOT_NL" == "" vcqi_global VCQI_IWPLOT_NL 30
	
	iwplot_svyp , ///
		inputdata("Plots_IW_UW/iwplot_params_`filetag'_`show1'`show2'`show3'`show4'") ///
		nl($VCQI_IWPLOT_NL) ///
		xtitle("Estimated Coverage %") ///
		citext($VCQI_IWPLOT_CITEXT) ///
		horlinesdata("`horlines'") ///
		note(`"`note'"', size(vsmall) span ) ///
		caption(`caption') ///
		title(`title', span) ///
		subtitle(`subtitle', span) ///
		name(`=substr("`name'",1,min(32,length("`name'")))', replace) `saving' `clean' `export' 		
		
	if $DELETE_TEMP_VCQI_DATASETS == 1 capture erase "Plots_IW_UW/iwplot_params_`filetag'_`show1'`show2'`show3'`show4'.dta"
end

