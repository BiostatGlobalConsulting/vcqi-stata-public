*! RI_COVG_03 version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Delete temp datasets at user's request
* 2017-01-27	1.02	Dale Rhoda		Add call to GC
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_03
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_03
	vcqi_log_comment $VCP 5 Flow "Starting"

	noi di "Calculating $VCP ..."

	noi di _col(3) "Checking global macros"
	RI_COVG_03_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" RI_COVG_03_01PP
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di _col(3) "Checking data quality"
	*RI_COVG_03_02DQ
	if "$VCQI_GENERATE_DVS" 		== "1" noi di _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" RI_COVG_03_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di _col(3) "Generating output databases"
	if "$VCQI_GENERATE_DATABASES" 	== "1" RI_COVG_03_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" RI_COVG_03_05TO
	if "$MAKE_PLOTS" 				== "1" noi di _col(3) "Making plots"
	if "$MAKE_PLOTS"      			== "1" RI_COVG_03_06PO
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
		
end
