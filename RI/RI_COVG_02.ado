*! RI_COVG_02 version 1.02 - Biostat Global Consulting - 2017-01-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Delete temp datasets at user's request
*
* 2017-01-09	1.02	Dale Rhoda		Skip if everyone is missing DOB
*******************************************************************************

program define RI_COVG_02
	
	local oldvcp $VCP
	global VCP RI_COVG_02
	vcqi_log_comment $VCP 5 Flow "Starting"

	if "$VCQI_NO_DOBS" == "1" {
		vcqi_log_comment $VCP 2 Warning "User requested RI_COVG_02 but no respondents have full date of birth info, so the indicator will be skipped."
	}
	else {

		noi di "Calculating $VCP ..."

		if "$VCQI_PREPROCESS_DATA" 		== "1" noi di _col(3) "Pre-processing dataset"
		if "$VCQI_PREPROCESS_DATA" 		== "1" RI_COVG_02_01PP
		*RI_COVG_02_02DQ
		if "$VCQI_GENERATE_DVS" 		== "1" noi di _col(3) "Calculating derived variables"
		if "$VCQI_GENERATE_DVS" 		== "1" RI_COVG_02_03DV
		if "$VCQI_GENERATE_DATABASES" 	== "1" noi di _col(3) "Generating output databases"
		if "$VCQI_GENERATE_DATABASES" 	== "1" RI_COVG_02_04GO
		if "$EXPORT_TO_EXCEL" 			== "1" noi di _col(3) "Exporting to Excel"
		if "$EXPORT_TO_EXCEL" 			== "1" RI_COVG_02_05TO
		if "$MAKE_PLOTS" 				== "1" noi di _col(3) "Making plots"
		if "$MAKE_PLOTS"      			== "1" RI_COVG_02_06PO
	
	}
		
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
