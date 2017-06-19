*! RI_CONT_01 version 1.00 - Biostat Global Consulting - 2015-10-14
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define RI_CONT_01

	local oldvcp $VCP
	global VCP RI_CONT_01
	vcqi_log_comment $VCP 5 Flow "Starting"

	noi di "Calculating $VCP ..."

	noi di _col(3) "Checking global macros"
	RI_CONT_01_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" RI_CONT_01_01PP
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di _col(3) "Checking data quality"
	*RI_CONT_01_02DQ
	if "$VCQI_GENERATE_DVS" 		== "1" noi di _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" RI_CONT_01_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di _col(3) "Generating output databases"
	if "$VCQI_GENERATE_DATABASES" 	== "1" RI_CONT_01_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" RI_CONT_01_05TO
	if "$MAKE_PLOTS" 				== "1" noi di _col(3) "Making plots"
	if "$MAKE_PLOTS"      			== "1" RI_CONT_01_06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
