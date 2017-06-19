*! SIA_COVG_02_03DV version 1.00 - Biostat Global Consulting - 2015-09-28
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define SIA_COVG_02_03DV

	local oldvcp $VCP
	global VCP SIA_COVG_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_02_${ANALYSIS_COUNTER}", clear
	
		gen sia_is_first_measles_dose = inlist(SIA20,1,2) & SIA27 == 3
		label variable sia_is_first_measles_dose "SIA Provided Child's First Measles Dose"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
