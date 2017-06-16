*! RI_COVG_05 version 1.01 - Biostat Global Consulting - 2015-10-14
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added 3 for vqci_log_comment type:
*										vcqi_log_comment $VCP 5 Flow "Starting"
*******************************************************************************

program define RI_COVG_05

	local oldvcp $VCP
	global VCP RI_COVG_05
	vcqi_log_comment $VCP 5 Flow "Starting"

	noi di "Calculating $VCP ..."

	noi di _col(3) "Checking global macros"
	RI_COVG_05_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" RI_COVG_05_01PP
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di _col(3) "Checking data quality"
	*RI_COVG_05_02DQ
	if "$VCQI_GENERATE_DVS" 		== "1" noi di _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" RI_COVG_05_03DV
	*if "$VCQI_GENERATE_DATABASES" 	== "1" noi di _col(3) "Generating output databases"
	*RI_COVG_05_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" RI_COVG_05_05TO
	*if "$MAKE_PLOTS" 				== "1" noi di _col(3) "Making plots"
	*if "$MAKE_PLOTS"      			== "1" RI_COVG_05_06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
