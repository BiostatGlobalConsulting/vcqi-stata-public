*! SIA_COVG_01_03DV version 1.00 - Biostat Global Consulting - 2015-09-28
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define SIA_COVG_01_03DV

	local oldvcp $VCP
	global VCP SIA_COVG_01_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_${ANALYSIS_COUNTER}", clear
		
		gen got_sia_dose_by_card    = SIA20 == 1
		gen got_sia_dose_by_history = SIA20 == 2
		gen got_sia_dose = got_sia_dose_by_card == 1 | got_sia_dose_by_history == 1
		label variable got_sia_dose_by_card "Got SIA dose, by card"
		label variable got_sia_dose_by_history "Got SIA dose, by history"
		label variable got_sia_dose "Got SIA dose, by card or history"
		
		if "$SIA_FINGERMARKS_SOUGHT" == "1" {
			gen got_sia_dose_by_fingermark = SIA22 == 1
			replace got_sia_dose = got_sia_dose == 1 | got_sia_dose_by_fingermark == 1
			label variable got_sia_dose_by_fingermark "Got SIA dose, by fingermark"
			label variable got_sia_dose "Got SIA dose, by card, history or fingermark"
		}
		
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
