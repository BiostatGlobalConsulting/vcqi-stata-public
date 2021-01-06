*! DESC_02 version 1.03 - Biostat Global Consulting - 2018-01-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-03-07	1.01	Dale Rhoda		Announce the current DESC_02_VARIABLES
*										to the screen while running
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2018-01-17	1.03	MK Trimner		Added code for syntax option to clean up globals
*										and code at bottom to clean it up
*******************************************************************************

program define DESC_02

	syntax , [CLEANup]
	
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_02
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noi di as text "Calculating $VCP for ${DESC_02_VARIABLES}..."

	noi di as text _col(3) "Checking global macros"
	DESC_02_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA"		== "1" DESC_02_01PP
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di as text _col(3) "Checking data quality"
	*DESC_02_02DQ 
	if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" DESC_02_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di as text _col(3) "Generating output databases"
	if "$VCQI_GENERATE_DATABASES" 	== "1" DESC_02_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di as text _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" DESC_02_05TO
	*if "$MAKE_PLOTS" 				== "1" noi di as text _col(3) "Making plots"
	*if "$MAKE_PLOTS"      			== "1" DESC__06PO
	
	
	* Clear out globals if specified
	if "`cleanup'"!="" {
		vcqi_global DESC_02_DATASET 
		vcqi_global DESC_02_VARIABLES

		vcqi_global DESC_02_WEIGHTED	
		vcqi_global DESC_02_DENOMINATOR	

		vcqi_global DESC_02_TO_TITLE 	
		vcqi_global DESC_02_TO_SUBTITLE
		
		vcqi_global DESC_02_N_LABEL
		vcqi_global DESC_02_NTWD_LABEL
		
		
		forvalues i = 1/${DESC_02_N_RELABEL_LEVELS} {
			vcqi_global DESC_02_RELABEL_LEVEL_`i' 
			vcqi_global DESC_02_RELABEL_LABEL_`i'
		}
		
		vcqi_global DESC_02_N_RELABEL_LEVELS 
		
		forvalues i = 1/${DESC_02_N_SUBTOTALS} {
			vcqi_global DESC_02_SUBTOTAL_LEVELS_`i'	
			vcqi_global DESC_02_SUBTOTAL_LABEL_`i'	 
			vcqi_global DESC_02_SUBTOTAL_LIST_`i'	
		}

		vcqi_global DESC_02_N_SUBTOTALS	
		vcqi_global DESC_02_SHOW_SUBTOTALS_ONLY
		
		vcqi_global DESC_02_LIST_N_BEFORE_PCT 
		vcqi_global DESC_02_LIST_NWTD_BEFORE_PCT 
		
		forvalues i =1/100 {
			vcqi_global DESC_02_TO_FOOTNOTE_`i'
		}
	}

	

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
