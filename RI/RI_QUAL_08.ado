*! RI_QUAL_08 version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-09	1.01	Dale Rhoda		Skip if no respondents have DOB
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_08
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_08
	vcqi_log_comment $VCP 5 Flow "Starting"

	if "$VCQI_NO_DOBS" == "1" {
		vcqi_log_comment $VCP 2 Warning "User requested RI_QUAL_08 but no respondents have full date of birth info, so the indicator will be skipped."
	}
	else {

		noi di as text "Calculating $VCP ..."

		noi di as text _col(3) "Checking global macros"
		RI_QUAL_08_00GC
		if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
		if "$VCQI_PREPROCESS_DATA" 		== "1" RI_QUAL_08_01PP
		*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di as text _col(3) "Checking data quality"
		*RI_QUAL_08_02DQ
		*if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating derived variables"
		*RI_QUAL_08_03DV
		if "$VCQI_GENERATE_DATABASES" 	== "1" noi di as text _col(3) "Generating output databases"
		if "$VCQI_GENERATE_DATABASES" 	== "1" RI_QUAL_08_04GO
		if "$EXPORT_TO_EXCEL" 			== "1" noi di as text _col(3) "Exporting to Excel"
		if "$EXPORT_TO_EXCEL" 			== "1" RI_QUAL_08_05TO
		if "$MAKE_PLOTS" 				== "1" noi di as text _col(3) "Making plots"
		if "$MAKE_PLOTS"      			== "1" RI_QUAL_08_06PO
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
