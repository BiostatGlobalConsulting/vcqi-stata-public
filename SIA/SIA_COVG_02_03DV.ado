*! SIA_COVG_02_03DV version 1.02 - Biostat Global Consulting - 2019-08-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2019-08-23	1.02	Dale Rhoda		Make outcomes missing if psweight == 0 | missing(psweight)
*******************************************************************************

program define SIA_COVG_02_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_02_${ANALYSIS_COUNTER}", clear
	
		gen sia_is_first_measles_dose = inlist(SIA20,1,2) & SIA27 == 3 if psweight>0 & !missing(psweight)
		label variable sia_is_first_measles_dose "SIA Provided Child's First Measles Dose"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
