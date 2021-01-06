*! RI_CCC_01 version 1.00 - Biostat Global Consulting - 2018-12-06
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-12-06	1.00	Mary Prier		Original version
*******************************************************************************

* This program makes cumulative coverage curve plots

program define RI_CCC_01
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CCC_01
	vcqi_log_comment $VCP 5 Flow "Starting"

	noi di as text "Calculating $VCP ..."
	RI_CCC_01_00GC
	if "$VCQI_PREPROCESS_DATA" 		== "1" noi di as text _col(3) "Pre-processing dataset"
	if "$VCQI_PREPROCESS_DATA" 		== "1" RI_CCC_01_01PP
	if "$VCQI_GENERATE_DVS" 		== "1" noi di as text _col(3) "Calculating derived variables"
	if "$VCQI_GENERATE_DVS" 		== "1" RI_CCC_01_03DV
	if "$MAKE_PLOTS" 				== "1" noi di as text _col(3) "Making plots"
	if "$MAKE_PLOTS"      			== "1" RI_CCC_01_06PO
	
	* We do not clean up the temp datasets here because they are sometimes
	* used by other indicators; they are cleaned up in 
	* vcqi_halt_immediately
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
