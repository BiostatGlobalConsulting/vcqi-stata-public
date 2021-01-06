*! COVG_DIFF_02 version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define COVG_DIFF_02
	version 14.1

	local oldvcp $VCP
	global VCP COVG_DIFF_02
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noi di as text "Calculating $VCP ..."

	noi di as text _col(3) "Checking global macros"
	COVG_DIFF_02_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" COVG_DIFF_02_01PP
	*COVG_DIFF_02_02DQ 
	*COVG_DIFF_02_03DV
	if "$VCQI_GENERATE_DATABASES" 	== "1" noi di as text _col(3) "Generating output databases"
	if "$VCQI_GENERATE_DATABASES" 	== "1" COVG_DIFF_02_04GO
	
	* The program to export to excel is called 
	* by vcqi_halt_immediately...not by this program.
	
	*if "$EXPORT_TO_EXCEL" == "1" COVG_DIFF_02_05TO
	*if "$MAKE_PLOTS"      == "1" COVG_DIFF_02_06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
