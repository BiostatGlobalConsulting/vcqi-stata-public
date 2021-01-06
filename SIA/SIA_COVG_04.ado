*! SIA_COVG_04 version 1.02 - Biostat Global Consulting - 2020-03-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-25	1.00	MK Trimner		Original 
* 2019-10-09	1.01	Dale Rhoda		Turn off plotting
* 2020-03-26	1.02	Dale Rhoda		Restore two missing if conditions
*******************************************************************************

program define SIA_COVG_04
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_04
	vcqi_log_comment $VCP 5 Flow "Starting"

	noi di as text "Calculating $VCP ..."

	noi di as text _col(3) "Checking global macros"
	SIA_COVG_04_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" SIA_COVG_04_01PP
	if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di as text _col(3) "Checking data quality"
	if "$VCQI_PREPROCESS_DATA"	 	== "1" SIA_COVG_04_02DQ
	
	if "$EXIT_SIA_COVG_04" != "1" {
	
		if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating derived variables"
		if "$VCQI_GENERATE_DVS" 		== "1" SIA_COVG_04_03DV

		************************************************************************
		* Set aside user specified inputs and hard-wire some level 4 output
		
		* Set aside the user-specified level 4 stratifier for now
		vcqi_global VCQI_LEVEL4_SA_VARLIST $VCQI_LEVEL4_SET_VARLIST
		vcqi_global VCQI_LEVEL4_SA_LAYOUT  $VCQI_LEVEL4_SET_LAYOUT
		
		* Hard wire the level 4 stratifier to be doses_prior_to_sia; clear out the layout
		vcqi_global VCQI_LEVEL4_SET_VARLIST doses_prior_to_sia
		vcqi_global VCQI_LEVEL4_SET_LAYOUT
		
		* Set aside copies of the globals that specify which levels to show
		vcqi_global SA_SHOW_LEVEL_1_ALONE         = $SHOW_LEVEL_1_ALONE        
		vcqi_global SA_SHOW_LEVEL_2_ALONE         = $SHOW_LEVEL_2_ALONE        
		vcqi_global SA_SHOW_LEVEL_3_ALONE         = $SHOW_LEVEL_3_ALONE         
		vcqi_global SA_SHOW_LEVELS_2_3_TOGETHER   = $SHOW_LEVELS_2_3_TOGETHER  

		vcqi_global SA_SHOW_LEVELS_1_4_TOGETHER   = $SHOW_LEVELS_1_4_TOGETHER  
		vcqi_global SA_SHOW_LEVELS_2_4_TOGETHER   = $SHOW_LEVELS_2_4_TOGETHER  
		vcqi_global SA_SHOW_LEVELS_3_4_TOGETHER   = $SHOW_LEVELS_3_4_TOGETHER  
		vcqi_global SA_SHOW_LEVELS_2_3_4_TOGETHER = $SHOW_LEVELS_2_3_4_TOGETHER

		* If not already showing level 4, add it now
		if $SHOW_LEVEL_1_ALONE         == 1 vcqi_global SHOW_LEVELS_1_4_TOGETHER   = 1
		if $SHOW_LEVEL_2_ALONE         == 1 vcqi_global SHOW_LEVELS_2_4_TOGETHER   = 1 
		if $SHOW_LEVEL_3_ALONE         == 1 vcqi_global SHOW_LEVELS_3_4_TOGETHER   = 1  
		if $SHOW_LEVELS_2_3_TOGETHER   == 1 vcqi_global SHOW_LEVELS_2_3_4_TOGETHER = 1 

		* Temporarily clear out the globals that show unstratified output
		vcqi_global SHOW_LEVEL_1_ALONE         = 0
		vcqi_global SHOW_LEVEL_2_ALONE         = 0
		vcqi_global SHOW_LEVEL_3_ALONE         = 0 
		vcqi_global SHOW_LEVELS_2_3_TOGETHER   = 0
		
		* Make a level4 layout dataset that does NOT include a title row
		* Re-populate the LEVEL4_SET globals to over-ride what happens 
		* automatically in check_analysis_metadata
		quietly {
			check_analysis_metadata		
		
			use "VCQI_LEVEL4_SET_LAYOUT_automatic", clear
			drop in 1 // we do not want to label the level 4 stratifier over and over again
			replace order = _n
			* Populate the globals with the contents of the layout dataset
			sort order
			save, replace
			global LEVEL4_SET_NROWS = _N
			* Clean up the variables, if needed
			replace rowtype   = trim(upper(rowtype))
			replace condition = trim(condition)
			replace condition = substr(condition,4,.) if lower(substr(condition,1,3)) == "if "
			replace label     = trim(label)
			forvalues i = 1/`=_N' {
				global LEVEL4_SET_ROWTYPE_`i'   `=rowtype[`i']'
				global LEVEL4_SET_ORDER_`i'     `=order[`i']'
				global LEVEL4_SET_LABEL_`i'     `=label[`i']'
				global LEVEL4_SET_CONDITION_`i' `=condition[`i']'
			}
		}
		
		************************************************************************
		
		if "$VCQI_GENERATE_DATABASES" 	== "1" noi di as text _col(3) "Generating output databases"
		if "$VCQI_GENERATE_DATABASES" 	== "1" SIA_COVG_04_04GO
		if "$EXPORT_TO_EXCEL" 			== "1" noi di as text _col(3) "Exporting to Excel"
		if "$EXPORT_TO_EXCEL" 			== "1" SIA_COVG_04_05TO
		
		* If there are very few strata then an inchworm plot might make sense, but 
		* in practice these turn out to be very tall and not aesthetically pleasing 
		* because there are numerous rows per stratum.  So turn off the plotting for now.
		*if "$MAKE_PLOTS" 				== "1" noi di as text _col(3) "Making plots"
		*if "$MAKE_PLOTS"      			== "1" SIA_COVG_04_06PO
		
		************************************************************************
		* Set globals back to user-specified values
		
		* Set level 4 stratifier back to user-specified value
		vcqi_global VCQI_LEVEL4_SET_VARLIST $VCQI_LEVEL4_SA_VARLIST 
		vcqi_global VCQI_LEVEL4_SET_LAYOUT  $VCQI_LEVEL4_SA_LAYOUT 
		
		* Reset user-specified inputs on what levels to show
		* Set aside copies of the globals that specify which levels to show
		vcqi_global SHOW_LEVEL_1_ALONE         = $SA_SHOW_LEVEL_1_ALONE        
		vcqi_global SHOW_LEVEL_2_ALONE         = $SA_SHOW_LEVEL_2_ALONE        
		vcqi_global SHOW_LEVEL_3_ALONE         = $SA_SHOW_LEVEL_3_ALONE         
		vcqi_global SHOW_LEVELS_2_3_TOGETHER   = $SA_SHOW_LEVELS_2_3_TOGETHER  
                                                  
		vcqi_global SHOW_LEVELS_1_4_TOGETHER   = $SA_SHOW_LEVELS_1_4_TOGETHER  
		vcqi_global SHOW_LEVELS_2_4_TOGETHER   = $SA_SHOW_LEVELS_2_4_TOGETHER  
		vcqi_global SHOW_LEVELS_3_4_TOGETHER   = $SA_SHOW_LEVELS_3_4_TOGETHER  
		vcqi_global SHOW_LEVELS_2_3_4_TOGETHER = $SA_SHOW_LEVELS_2_3_4_TOGETHER
		
		quietly check_analysis_metadata

		************************************************************************
	}
	
	else noi di as error "SIA_COVG_04 cannot be completed. See Log for details."
		
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
