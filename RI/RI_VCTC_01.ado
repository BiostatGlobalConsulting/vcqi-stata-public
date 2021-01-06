*! RI_VCTC_01 version 1.00 - Biostat Global Consulting - 2020-09-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-09-24	1.00	Dale Rhoda		Original version
*******************************************************************************

program define RI_VCTC_01
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_VCTC_01
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noi di as text "Calculating $VCP ..."
	
	capture mkdir Plots_VCTC

	noi di as text _col(3) "Checking global macros"
	RI_VCTC_01_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" RI_VCTC_01_01PP
	if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating bar chart coordinates"
	if "$VCQI_GENERATE_DVS" 		== "1" RI_VCTC_01_03DV
	if "$EXPORT_TO_EXCEL" 			== "1" noi di as text _col(3) "Exporting to Excel"
	if "$EXPORT_TO_EXCEL" 			== "1" RI_VCTC_01_05TO
	if "$MAKE_PLOTS" 				== "1" noi di as text _col(3) "Making plots"
	if "$MAKE_PLOTS"      			== "1" RI_VCTC_01_06PO

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
