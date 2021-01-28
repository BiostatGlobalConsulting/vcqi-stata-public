*! RI_QUAL_13 version 1.03 - Biostat Global Consulting - 2021-01-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-09	1.01	Dale Rhoda		Skip if no respondents have DOB
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2021-01-13	1.03	Dale Rhoda		Send deprecation msg to log
*******************************************************************************

program define RI_QUAL_13
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_13
	vcqi_log_comment $VCP 5 Flow "Starting"

	if "$VCQI_NO_DOBS" == "1" {
		vcqi_log_comment $VCP 2 Warning "User requested RI_QUAL_13 but no respondents have full date of birth info, so the indicator will be skipped."
	}
	else {
	
		noi di as text "NOTE: We recommend you call RI_QUAL_04 instead of RI_QUAL_13 ..."
		
		vcqi_log_comment $VCP 2 Warning "RI_QUAL_13 has been deprecated. VCQI will run RI_QUAL_13 for you for purposes of backward-compatibility, but it is no longer maintained or recommended. You should edit the control program and call RI_QUAL_04 instead."
		
		noi di as text "Calculating $VCP ..."

		noi di as text _col(3) "Checking global macros"
		RI_QUAL_13_00GC
		if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
		if "$VCQI_PREPROCESS_DATA" 		== "1" RI_QUAL_13_01PP
		*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di as text _col(3) "Checking data quality"
		*RI_QUAL_13_02DQ
		if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating derived variables"
		if "$VCQI_GENERATE_DVS" 		== "1" RI_QUAL_13_03DV
		if "$VCQI_GENERATE_DATABASES" 	== "1" noi di as text _col(3) "Generating output databases"
		if "$VCQI_GENERATE_DATABASES" 	== "1" RI_QUAL_13_04GO
		if "$EXPORT_TO_EXCEL" 			== "1" noi di as text _col(3) "Exporting to Excel"
		if "$EXPORT_TO_EXCEL" 			== "1" RI_QUAL_13_05TO
		if "$MAKE_PLOTS" 				== "1" noi di as text _col(3) "Making plots"
		if "$MAKE_PLOTS"      			== "1" RI_QUAL_13_06PO

	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
