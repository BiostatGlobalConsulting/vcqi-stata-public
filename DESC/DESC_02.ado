*! DESC_02 version 1.01 - Biostat Global Consulting - 2017-03-07
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-03-07	1.01	Dale Rhoda		Announce the current DESC_02_VARIABLES
*										to the screen while running
*******************************************************************************

program define DESC_02

	local oldvcp $VCP
	global VCP DESC_02
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noi di "Calculating $VCP for ${DESC_02_VARIABLES}..."

	noi di _col(3) "Checking global macros"
	DESC_02_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA"		== "1" DESC_02_01PP
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di _col(3) "Checking data quality"
	*DESC_02_02DQ 
	if "$VCQI_GENERATE_DVS" 		== "1" noi di _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" DESC_02_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di _col(3) "Generating output databases"
	if "$VCQI_GENERATE_DATABASES" 	== "1" DESC_02_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" DESC_02_05TO
	*if "$MAKE_PLOTS" 				== "1" noi di _col(3) "Making plots"
	*if "$MAKE_PLOTS"      			== "1" DESC__06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
