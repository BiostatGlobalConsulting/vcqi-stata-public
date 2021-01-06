*! SIA_COVG_05 version 1.00 - Biostat Global Consulting - 2018-10-25
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-25	1.00	MK Trimner		Original copied from RI_COVG_05
*******************************************************************************

program define SIA_COVG_05
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_05
	vcqi_log_comment $VCP 5 Flow "Starting"

	noi di as text "Calculating $VCP ..."

	noi di as text _col(3) "Checking global macros"
	SIA_COVG_05_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" SIA_COVG_05_01PP
	*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di as text _col(3) "Checking data quality"
	*SIA_COVG_05_02DQ
	if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" SIA_COVG_05_03DV
	*if "$VCQI_GENERATE_DATABASES" 	== "1" noi di as text _col(3) "Generating output databases"
	*SIA_COVG_05_04GO
	if "$EXPORT_TO_EXCEL" 			== "1" noi di as text _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" SIA_COVG_05_05TO
	*if "$MAKE_PLOTS" 				== "1" noi di as text _col(3) "Making plots"
	*if "$MAKE_PLOTS"      			== "1" SIA_COVG_05_06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
