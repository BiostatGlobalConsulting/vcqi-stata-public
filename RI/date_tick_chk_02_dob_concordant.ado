*! date_tick_chk_02_dob_concordant version 1.03 - Biostat Global Consulting - 2018-11-19
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2018-11-08	1.02	MK Trimner		Changed so register variables only created
*										if records sought
* 2018-11-19	1.03	MK Trimner		Updated if register local to reflect `ifreg'
*******************************************************************************

program define date_tick_chk_02_dob_concordant
	version 14.1

	local oldvcp $VCP
	global VCP date_tick_chk_02_dob_concordant
	vcqi_log_comment $VCP 5 Flow "Starting"

	noisily display as text "Checking dates of birth: concordance..."

	quietly {

		postfile dt_dob_concordance str20(d type) str32(var) n_0 n_1 n_01 using dt_dob_concordance , replace
		
		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS dt_dob_concordance
		
		* Create variables for card and register comparison
		local ifreg if "$RI_RECORDS_NOT_SOUGHT" != "1"
		
		* Create variable to show if card and history data are present, did they disagree? 
		gen     ct_dob_card_history = .
		replace ct_dob_card_history = (dob_date_card_d!=dob_date_history_d | dob_date_card_m!=dob_date_history_m | ///
									   dob_date_card_y!=dob_date_history_y) if ct_dob_card_sense==1 & ct_dob_history_sense==1 


		* Create variable to show if card and register data present, did the dates disagree?
		local varlist ct_dob_card_history 
		`ifreg' {
			gen     ct_dob_card_register = .
			replace ct_dob_card_register = (dob_date_card_d!=dob_date_register_d | dob_date_card_m!=dob_date_register_m | ///
										dob_date_card_y!=dob_date_register_y) if ct_dob_card_sense==1 & ct_dob_register_sense==1
		
			* Create variable to show if the register and history data are present, did they disagree? 
			gen     ct_dob_register_history = .
			replace ct_dob_register_history= (dob_date_register_d!=dob_date_history_d | dob_date_register_m!=dob_date_history_m | ///
										  dob_date_register_y!=dob_date_history_y) if ct_dob_register_sense == 1 & ct_dob_history_sense ==1 
										  
			local varlist ct_dob_card_register  ct_dob_card_history  ct_dob_register_history
			
		}
		
		foreach var in `varlist' {	
			count if `var' == 0
				  scalar n_0 = r(N)
			count if `var' == 1
				  scalar n_1 = r(N)
			count if `var' == 1 | `var' == 0
				  scalar n_01 = r(N)
			
			post dt_dob_concordance ("dob") ("concordance") ("`var'") (n_0) (n_1) (n_01)

		}

		capture postclose dt_dob_concordance
	}


	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end

