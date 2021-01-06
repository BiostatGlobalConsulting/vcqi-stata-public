*! vcqi_to_uwplot version 1.15 - Biostat Global Consulting - 2020-12-12
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		vcqi_log_comment missing "Error" added to the below lines:
*										vcqi_log_comment $VCP 1 Error "The VCQI database passed in to this program does not seem to exist."
*										vcqi_log_comment $VCP 1 Error "The database named was `database'."			
* 2016-09-08	1.02	Dale Rhoda		Added Plots_IW_UW folder
* 2016-09-19	1.03	Dale Rhoda		Added sort fix when showing level 1 and 3
* 2017-01-31	1.04	Dale Rhoda		Cleaned up code...
* 2017-02-15	1.05	Dale Rhoda		Allow plotting with LEVEL4_SET_VARLIST
*										and use lighter shade for level4 rows
* 2017-03-18	1.06	Dale Rhoda		Only shade level 1 if we are also 
*										showing results from level 2 or 3
* 2017-05-16	1.07	Dale Rhoda		Restructured to also make level2 plots
*										if the user requests them 
*										& change to default blue colors
* 2017-05-19	1.08	Dale Rhoda		Fix a problem with quotation marks
* 2017-05-26	1.09	Dale Rhoda		Handle vertical lines when national 
*										results are at the top or bottom row
* 2017-08-22	1.10	Dale Rhoda		Force level4name to be a string
* 2017-08-26	1.11	Mary Prier		Added version 14.1 line
* 2019-03-18	1.12	Mary Prier		Added user option/global "SORT_PLOT_LOW_TO_HIGH";
*										  Option high to low (global=1) requires gsort;
* 										  Default is sorting low to high and using sort
* 2020-04-28	1.13	Dale Rhoda		Allow user to specify that right-side
*                                       point estimate should be wrapped in ()
*                                       if 25 <= N < 50 and that N should be
*                                       followed by a double-dagger if N < 25.
*                                       (Set global UWPLOT_ANNOTATE_LOW_MED = 1)
*                                       (Also make the 25 and 50 programmable
*                                        using globals UWPLOT_ANNOTATE_LOW_N 
*                                        and UWPLOT_ANNOTATE_LOW_N.)
* 2020-12-09	1.14	Dale Rhoda		Allow the user to plot strata in table order
* 2020-12-12	1.15	Dale Rhoda		Allow the user to SHOW_LEVEL_4_ALONE
*******************************************************************************

program define vcqi_to_uwplot
	version 14.1
	
	syntax , DATABASE(string asis) FILETAG(string) ///
	[ TITLE(string asis) NAME(string) SUBTITLE(string asis) ]
	* The twoway 'note' is supplied below, so the user may not provide one.
	
	local oldvcp $VCP
	global VCP vcqi_to_uwplot
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	capture confirm file "`database'.dta"
	
	if _rc != 0 {
		di as error "vcqi_to_uwplot: The VCQI database passed in to this program does not seem to exist."
		di as error "vcqi_to_uwplot: The database named was `database'."
		
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
	
	capture gen level4name = "" // in case it is not populated
	capture tostring level4name, replace // in case it is not a string
	replace name = level4name if `show4' & !missing(level4id)
	
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
		merge 1:m level1id level2id level3id level4id using table_order_TO
		keep if _merge == 1 | _merge == 3
		drop _merge
		sort table_bottom_to_top_row_order
	}

	keep name n estimate level level*id outcome
		
	gen nparams  = 6
	gen param1 = n
	gen param2 = estimate*100
	gen param3 = _n
	gen param4 = "T"
	gen param5 = "1.5"
	

	* User specifies the colors for levels 1-4 in their adopath
	* 
	* There are files named color-vcqilevel1.style (and 2, 3, 4)
	* and color-vcqioutline.style
	* somewhere in the adopath...change the RGB values of those
	* files to get different colors in the plots.
	
	gen param6 = ""
	forvalues i = 1/3 {
		replace param6 = "vcqi_level`i'" if level == `i'
	}
	replace param6 = "vcqi_outline" if !missing(level4id)

	gen shadebehind = "gs15" if level == 1 & (`show2' + `show3' > 0)
	gen outline = !missing(level4id) // If you want the level 4 shapes to have white centers
	

	gen rowname = name
	
	gen dn = param3

	save "Plots_IW_UW/uwplot_params_base", replace
	save "Plots_IW_UW/uwplot_params_`filetag'_`show1'`show2'`show3'`show4'", replace
	

	local pass_thru_options
	if `"`title'"' != "" local pass_thru_options `pass_thru_options' title(`title')
	if `"`subtitle'"' != "" local pass_thru_options `pass_thru_options' subtitle(`subtitle')
	if `"`note'"' != "" local pass_thru_options `pass_thru_options' note(`note')
	if `"`caption'"' != "" local pass_thru_options `pass_thru_options' caption(`caption')
		
	unweighted_plotit, filetag(`filetag') show1(`show1') show2(`show2') show3(`show3') ///
	        show4(`show4') `pass_thru_options' name(`name')
			
	if $DELETE_TEMP_VCQI_DATASETS == 1 capture erase "Plots_IW_UW/uwplot_params_`filetag'_`show1'`show2'`show3'`show4'.dta"

			
	* Make plot for every level 2 stratum, if requested

	if `show2' == 1 & "$VCQI_MAKE_LEVEL2_UWPLOTS" == "1" {
	
		use "$VCQI_DATA_FOLDER/level2names", clear
		forvalues i = 1/`=_N' {
			local l2name_`=level2id[`i']' = subinstr("`=level2name[`i']'"," ","_",.)
		}
		levelsof level2id, local(l2list)
		
		foreach l2l in `l2list' {

			use "Plots_IW_UW/uwplot_params_base", clear
			
			keep if level == 1 | level2id == `l2l'
			
			replace dn = _n
			
			replace param3 = _n
			
			save "Plots_IW_UW/uwplot_params_`filetag'_l2_`l2l'_`show1'`show2'`show3'`show4'", replace
			
			unweighted_plotit, filetag(`filetag'_l2_`l2l') show1(`show1') show2(`show2') show3(`show3') ///
					show4(`show4') `pass_thru_options' name(`name'_l2_`l2l'_`l2name_`l2l'')
				
			vcqi_log_comment $VCP 3 Comment "Unweighted proportion plot was created and exported."
			
			if $DELETE_TEMP_VCQI_DATASETS == 1 capture erase "Plots_IW_UW/uwplot_params_`filetag'_l2_`l2l'_`show1'`show2'`show3'`show4'.dta"
		
			graph drop _all
		}
	}
	
	if $DELETE_TEMP_VCQI_DATASETS == 1 capture erase "Plots_IW_UW/uwplot_params_base.dta"
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
	
program define unweighted_plotit
	version 14.1
	
	syntax ,  FILETAG(string) show1(integer) show2(integer) show3(integer) show4(integer) ///
	[ TITLE(string asis) NAME(string) SUBTITLE(string asis) NOTE(string asis) CAPTION(string asis) ]
	  
	use "Plots_IW_UW/uwplot_params_`filetag'_`show1'`show2'`show3'`show4'", clear	
	
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

	local note Text at right: Unweighted sample proportion (%) and N, size(small) span
	
	
	* If user says they want to annotate low and medium N, do three checks.
	* If low is undefined, set it to 25; if medium is undefined set it to 50.
	* If the user specified both, but low is > med, then over-ride their choice and use 25 and 50.
	if "$UWPLOT_ANNOTATE_LOW_MED" != "" | "$UWPLOT_ANNOTATE_MED_N" < "UWPLOT_ANNOTATE_LOW_N" {
		if "$UWPLOT_ANNOTATE_LOW_N" == "" vcqi_global UWPLOT_ANNOTATE_LOW_N 25
		if "$UWPLOT_ANNOTATE_MED_N" == "" vcqi_global UWPLOT_ANNOTATE_MED_N 50
	}	
	
	* By the way, this website has a nice list of unicode math symbols:
	* https://www.w3schools.com/charsets/ref_utf_math.asp
	
	if "$UWPLOT_ANNOTATE_LOW_MED" != "" local note = `""Text at right: Unweighted sample proportion (%) and N" "Parentheses () mean ${UWPLOT_ANNOTATE_LOW_N} `=uchar(8804)' N < ${UWPLOT_ANNOTATE_MED_N} and `=uchar(8225)' means N < ${UWPLOT_ANNOTATE_LOW_N}.", size(small) span"'
	
	local saving
	if $SAVE_VCQI_GPH_FILES ///
		local saving saving("Plots_IW_UW/`name'_`show1'`show2'`show3'`show4'", replace)

	uwplot_vcqi , ///
		inputdata("Plots_IW_UW/uwplot_params_`filetag'_`show1'`show2'`show3'`show4'") ///
		xtitle("Sample Proportion %") ///
		righttext(1) ///
		horlinesdata("`horlines'") ///
		title(`title', span) ///
		subtitle(`subtitle',span) ///
		note(`note') ///
		name(`=substr("`name'",1,min(32,length("`name'")))', replace) `saving' ///
		export(Plots_IW_UW/`name'_`show1'`show2'`show3'`show4'.png)

	if $DELETE_TEMP_VCQI_DATASETS == 1 capture erase "Plots_IW_UW/uwplot_`filetag'_`show1'`show2'`show3'`show4'.dta"

end

