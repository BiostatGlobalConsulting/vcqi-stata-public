*! DESC_03 version 1.02 - Biostat Global Consulting - 2018-01-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2018-01-17	1.02	MK Trimner		Added code for syntax option to clean up globals
*										and code at bottom to clean it up
*******************************************************************************

program define DESC_03

	syntax , [CLEANup]
	
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_03
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noi di as text "Calculating $VCP ..."

	noi di as text _col(3) "Checking global macros"
	DESC_03_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" DESC_03_01PP
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di as text _col(3) "Checking data quality"
	*DESC_03_02DQ 
	if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" DESC_03_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di as text _col(3) "Generating output databases"
	if "$VCQI_GENERATE_DATABASES" 	== "1" DESC_03_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di as text _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" DESC_03_05TO
	*if "$MAKE_PLOTS"      			== "1" RI_COVG_03_06PO
	*if "$MAKE_PLOTS"      			== "1" DESC_03_06PO
	
	* Clear out globals if requested by user
	if "`cleanup'"!="" {
		vcqi_global DESC_03_DATASET 
		vcqi_global DESC_03_VARIABLES

		vcqi_global DESC_03_WEIGHTED	
		vcqi_global DESC_03_DENOMINATOR	

		vcqi_global DESC_03_TO_TITLE 	
		vcqi_global DESC_03_TO_SUBTITLE
		
		vcqi_global DESC_03_SHORT_TITLE
		vcqi_global DESC_03_SELECTED_VALUE
		
		vcqi_global DESC_03_N_LABEL
		vcqi_global DESC_03_NTWD_LABEL
			
		forvalues i = 1/${DESC_03_N_RELABEL_LEVELS} {
			vcqi_global DESC_03_RELABEL_LEVEL_`i' 
			vcqi_global DESC_03_RELABEL_LABEL_`i'
		}
		
		vcqi_global DESC_03_N_RELABEL_LEVELS 
		
		forvalues i = 1/${DESC_03_N_SUBTOTALS} {
			vcqi_global DESC_03_SUBTOTAL_LEVELS_`i'	
			vcqi_global DESC_03_SUBTOTAL_LABEL_`i'	 
			vcqi_global DESC_03_SUBTOTAL_LIST_`i'	
		}

		vcqi_global DESC_03_N_SUBTOTALS	
		vcqi_global DESC_03_SHOW_SUBTOTALS_ONLY
		
		vcqi_global DESC_03_LIST_N_BEFORE_PCT 
		vcqi_global DESC_03_LIST_NWTD_BEFORE_PCT 
		
		forvalues i =1/100 {
			vcqi_global DESC_03_TO_FOOTNOTE_`i'
		}
	}


	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end


