*! SIA_COVG_01_03DV version 1.02 - Biostat Global Consulting - 2019-08-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2019-08-23	1.02	Dale Rhoda		Make outcomes missing if psweight == 0 | missing(psweight)
*******************************************************************************

program define SIA_COVG_01_03DV
	version 14.1
	
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

		* Set outcomes to missing if weight is missing or zero
		foreach v of varlist got_sia_dose got_sia_dose_by_* {
			replace `v' = . if psweight == 0 | missing(psweight)
		}
		
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
