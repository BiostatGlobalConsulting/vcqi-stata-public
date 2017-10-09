*! SIA_COVG_01 version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define SIA_COVG_01
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_01
	vcqi_log_comment $VCP 5 Flow "Starting"

	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" SIA_COVG_01_01PP
	if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di _col(3) "Checking data quality"
	if "$VCQI_PREPROCESS_DATA" 		== "1" SIA_COVG_01_02DQ
	if "$VCQI_GENERATE_DVS" 		== "1" noi di _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" SIA_COVG_01_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di _col(3) "Generating output databases"
	if "$VCQI_GENERATE_DATABASES" 	== "1" SIA_COVG_01_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" SIA_COVG_01_05TO
	if "$MAKE_PLOTS" 				== "1" noi di _col(3) "Making plots"
	if "$MAKE_PLOTS"      			== "1" SIA_COVG_01_06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
