*! RI_ACC_01 version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-02	1.01	Dale Rhoda		Cosmetic changes
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_ACC_01
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_ACC_01
	vcqi_log_comment $VCP 5 Flow "Starting"

	noi di "Calculating $VCP ..."

	noi di _col(3) "Checking global macros"
	RI_ACC_01_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" RI_ACC_01_01PP
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di _col(3) "Checking data quality"
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" RI_ACC_01_02DQ
	*if "$VCQI_GENERATE_DVS" 		== "1" noi di _col(3) "Calculating derived variables"
	*if "$VCQI_GENERATE_DVS" 		== "1" RI_ACC_01_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di _col(3) "Generating output databases"
	if "$VCQI_GENERATE_DATABASES" 	== "1" RI_ACC_01_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" RI_ACC_01_05TO
	* The graphic for ACC_01 is generated as part of COVG_01
	*if "$MAKE_PLOTS" 				== "1" noi di _col(3) "Making plots"
	*if "$MAKE_PLOTS"      			== "1" RI_ACC_01_06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
