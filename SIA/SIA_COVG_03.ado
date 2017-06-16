*! SIA_COVG_03 version 1.01 - Biostat Global Consulting - 2017-03-07
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-03-07	1.01	Dale Rhoda		Customized message for age
*******************************************************************************

program define SIA_COVG_03

	local oldvcp $VCP
	global VCP SIA_COVG_03
	vcqi_log_comment $VCP 5 Flow "Starting"

	noi di "Calculating $VCP ..."

	SIA_COVG_03_00GC

	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" SIA_COVG_03_01PP
	if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di _col(3) "Checking data quality"
	if "$VCQI_PREPROCESS_DATA" 		== "1" SIA_COVG_03_02DQ
	if "$VCQI_GENERATE_DVS" 		== "1" noi di _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" SIA_COVG_03_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di _col(3) "Generating output database for age:"
	if "$VCQI_GENERATE_DATABASES" 	== "1" SIA_COVG_03_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di _col(3) "Exporting to Excel for age:"
	if "$EXPORT_TO_EXCEL" 			== "1" SIA_COVG_03_05TO
	*if "$MAKE_PLOTS" 				== "1" noi di _col(3) "Making plots"
	*if "$MAKE_PLOTS"      			== "1" SIA_COVG_03_06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
