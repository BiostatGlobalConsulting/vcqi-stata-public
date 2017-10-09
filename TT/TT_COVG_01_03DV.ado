*! TT_COVG_01_03DV version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		added varable labels
* 2016-02-17	1.02	MK Trimner		changed var name on most_recent_dose_c_or_h to years_since_last_dose_c_or_h
*										changed var name on most_recent_tt_r_or_h to years_since_last_dose_r_or_h
*										corrected all misspelled received
*										fixed var label name on line 99
*										changed all "Child was protected from TT at birth" to "Protected at Birth"
* 2016-02-17	1.03	MK Trimner		change variable lable on most_recent_dose_c_or_h
*										changed variable label on most_recent_tt_r_or_h
*										changed var name on line 102 to most_recent_tt_r_or_h was previously a copy paste error
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define TT_COVG_01_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP TT_COVG_01_03DV
	
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
		use "${VCQI_OUTPUT_FOLDER}/TT_COVG_01_${ANALYSIS_COUNTER}", clear
		
		gen lifetime_tt_doses_by_history = 0
		label variable lifetime_tt_doses_by_history "Lifetime TT doses per history"
			
		* sum up the doses recorded on the card, and allow the card
		* to over-ride the response to TT42 if the card shows a dose
		* that is more recent than TT42 does
		
		gen years_since_last_dose_c_or_h = TT42
		label variable years_since_last_dose_c_or_h "Years since last TT per card or history (0 means < 1)"
		gen lifetime_tt_doses_by_card = 0
		label variable lifetime_tt_doses_by_card "Lifetime TT doses per card"
			
		forvalues i = 30/35 {
		
			replace lifetime_tt_doses_by_card = lifetime_tt_doses_by_card + 1 if !missing(TT`i')
			replace years_since_last_dose_c_or_h = ( (TT09-TT`i') / 365 ) ///
					if !missing(TT`i') & !missing(TT09) & ///
				   ( (TT09-TT`i') / 365 ) < years_since_last_dose_c_or_h
			
		}
			
		replace lifetime_tt_doses_by_history = lifetime_tt_doses_by_history + TT37 if inlist(TT37,1,2,3)
		replace lifetime_tt_doses_by_history = lifetime_tt_doses_by_history + TT39 if !missing(TT39) & TT39 != 99
		replace lifetime_tt_doses_by_history = lifetime_tt_doses_by_history + TT41 if inlist(TT41,1,2,3,4,5,6,7)
		
		gen protected_at_birth_by_card = 0	
		replace protected_at_birth_by_card = 1 if lifetime_tt_doses_by_card >= 5
		replace protected_at_birth_by_card = 1 if years_since_last_dose_c_or_h>=0 & years_since_last_dose_c_or_h <=9 & lifetime_tt_doses_by_card == 4
		replace protected_at_birth_by_card = 1 if years_since_last_dose_c_or_h>=0 & years_since_last_dose_c_or_h <=4 & lifetime_tt_doses_by_card == 3
		replace protected_at_birth_by_card = 1 if years_since_last_dose_c_or_h>=0 & years_since_last_dose_c_or_h <=2 & lifetime_tt_doses_by_card == 2
		label variable protected_at_birth_by_card "Protected at birth per card"
		
		gen protected_at_birth_by_history = 0	
		replace protected_at_birth_by_history = 1 if lifetime_tt_doses_by_history >= 5
		replace protected_at_birth_by_history = 1 if years_since_last_dose_c_or_h>=0 & years_since_last_dose_c_or_h <=9 & lifetime_tt_doses_by_history == 4
		replace protected_at_birth_by_history = 1 if years_since_last_dose_c_or_h>=0 & years_since_last_dose_c_or_h <=4 & lifetime_tt_doses_by_history == 3
		replace protected_at_birth_by_history = 1 if years_since_last_dose_c_or_h>=0 & years_since_last_dose_c_or_h <=2 & lifetime_tt_doses_by_history == 2
		label variable protected_at_birth_by_history "Protected at birth per history"

		gen protected_at_birth_c_or_h = protected_at_birth_by_card == 1 | protected_at_birth_by_history == 1
		label variable protected_at_birth_c_or_h "Protected at birth per card or history"

		* put overview of results in the log
		
		local bigN `=_N'
		
		foreach o in by_card by_history c_or_h {
			count if protected_at_birth_`o' == 1
			local dropthis = r(N)
			vcqi_log_comment $VCP 3 Comment "`dropthis' of `bigN' are protected_at_birth_`o'"
		}
		
		* if this survey sought TT registry records, sum up the doses
		
		if $TT_RECORDS_NOT_SOUGHT != 1 {
		
			merge 1:1 respid using "${VCQI_OUTPUT_FOLDER}/TTHC_with_ids", keepusing(TTHC21 TTHC22 TTHC23 TTHC24 TTHC25 TTHC26)
			keep if _merge == 1 | _merge == 3
			drop _merge

			* sum up the doses recorded on the register, and allow the register
			* to over-ride the response to TT42 if the register shows a dose
			* that is more recent than TT42 does
		
			gen lifetime_tt_doses_by_register = 0
			label variable lifetime_tt_doses_by_register "Lifetime TT doses per register"
			
			gen years_since_last_dose_r_or_h = TT42
			label variable years_since_last_dose_r_or_h "Years since last TT per card or history (0 means < 1)"
			
			forvalues i = 21/26 {
			
				replace lifetime_tt_doses_by_register = lifetime_tt_doses_by_register + 1 if !missing(TTHC`i')

				replace years_since_last_dose_r_or_h = ( (TT09-TTHC`i') / 365 ) ///
						if !missing(TTHC`i') & !missing(TT09) & ///
						( (TT09-TTHC`i') / 365 ) < years_since_last_dose_r_or_h
			}
			
			gen protected_at_birth_by_register = 0	
			replace protected_at_birth_by_register = 1 if lifetime_tt_doses_by_register >= 5
			replace protected_at_birth_by_register = 1 if years_since_last_dose_r_or_h>=0 & years_since_last_dose_r_or_h <=9 & lifetime_tt_doses_by_register == 4
			replace protected_at_birth_by_register = 1 if years_since_last_dose_r_or_h>=0 & years_since_last_dose_r_or_h <=4 & lifetime_tt_doses_by_register == 3
			replace protected_at_birth_by_register = 1 if years_since_last_dose_r_or_h>=0 & years_since_last_dose_r_or_h <=2 & lifetime_tt_doses_by_register == 2
			label variable protected_at_birth_by_register "Protected at birth per register"
		
			gen protected_at_birth_c_or_h_or_r = protected_at_birth_c_or_h == 1 | protected_at_birth_by_register == 1	
			label variable protected_at_birth_c_or_h_or_r  "Protected at birth per register or card or history"

			foreach o in by_register c_or_h_or_r {
				count if protected_at_birth_`o' == 1
				local dropthis = r(N)
				vcqi_log_comment $VCP 3 Comment "`dropthis' of `bigN' are protected_at_birth_`o'"
			}
			
		}
		
		gen protected_at_birth_to_analyze = protected_at_birth_c_or_h
		label variable protected_at_birth_to_analyze "Protected at birth - TT_RECORDS_NOT_SOUGHT"
		
		* incorporate data from register for respondents with no card 
		if $TT_RECORDS_SOUGHT_IF_NO_CARD == 1 {
			replace protected_at_birth_to_analyze = protected_at_birth_c_or_h_or_r if TT27 != 1
			label variable protected_at_birth_to_analyze "Protected at birth - TT_RECORDS_SOUGHT_IF_NO_CARD"
		}
		* incorporate data from register if register sought for all respondents
		if $TT_RECORDS_SOUGHT_FOR_ALL == 1 {
			replace protected_at_birth_to_analyze = protected_at_birth_c_or_h_or_r 
			label variable protected_at_birth_to_analyze "Protected at birth - TT_RECORDS_SOUGHT_FOR_ALL"

		}
		
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
