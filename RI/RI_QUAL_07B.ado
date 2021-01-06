*! RI_QUAL_07B version 1.00 - Biostat Global Consulting - 2020-03-10
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-03-10	1.00	Mary Prier		Original version
*
*******************************************************************************

program define RI_QUAL_07B
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07B
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	if "$VCQI_NO_DOBS" == "1" {
		vcqi_log_comment $VCP 2 Warning "User requested RI_QUAL_07B but no respondents have full date of birth info, so the indicator will be skipped."
	}
	else {

		noi di as text "Calculating $VCP ..."

		*noi di as text _col(3) "Checking global macros"  // there are no global macros for RI_QUAL_07B, so nothing for GC program to check
		*RI_QUAL_07B_00GC
		if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
		if "$VCQI_PREPROCESS_DATA" 		== "1" RI_QUAL_07B_01PP
		*if "$VCQI_PREPROCESS_DATA"	 	== "1" noi di as text _col(3) "Checking data quality"
		*RI_QUAL_07B_02DQ
		if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating derived variables"
		if "$VCQI_GENERATE_DVS" 		== "1" RI_QUAL_07B_03DV
		if "$VCQI_GENERATE_DATABASES" 	== "1" noi di as text _col(3) "Generating output databases"
		if "$VCQI_GENERATE_DATABASES" 	== "1" RI_QUAL_07B_04GO
		if "$EXPORT_TO_EXCEL" 			== "1" noi di as text _col(3) "Exporting to Excel"
		if "$EXPORT_TO_EXCEL" 			== "1" RI_QUAL_07B_05TO
		if "$MAKE_PLOTS" 				== "1" noi di as text _col(3) "Making plots"
		if "$MAKE_PLOTS"      			== "1" RI_QUAL_07B_06PO
	}	
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
