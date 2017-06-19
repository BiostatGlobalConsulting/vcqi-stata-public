*! date_tick_chk_03_sensible_dob v 1.00  Biostat Global Consulting 2016-08-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************
capture program drop date_tick_chk_03_sensible_dob
program define       date_tick_chk_03_sensible_dob

	local oldvcp $VCP
	global VCP date_tick_chk_03_sensible_dob
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noisily display "Checking dates of birth: sensible dates..."
	
	quietly {
		postfile dt_dob_valid_dose_calculations str20(d type) str32(var) n_0 n_1 n_01 using dt_dob_sensible_dob_calculations , replace
		
		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS dt_dob_sensible_dob_calculations

		* Create variable to show if there was no dob_for_valid_dose_calculations determined
		gen ct_dob_no_valid_dose_calc = cond(missing(dob_for_valid_dose_calculations),1,0)

		* Create variable to show if there was a valid dob determined
		gen ct_dob_yes_valid_dose_calc = ct_dob_no_valid_dose_calc==0

		* Create variable to show if the min date of all possible dob dates was used
		gen     ct_dob_min_valid_dose_calc = plausible_birthdate if ct_dob_yes_valid_dose_calc==1 //apply logic for if missing dob_for_valid_dose_calculations
		replace ct_dob_min_valid_dose_calc = 0 if ct_dob_min_valid_dose_calc==. & ct_dob_yes_valid_dose_calc==1

		* Create variable to show if there were no conflicts
		gen unambiguous_dob=single_birthdate if ct_dob_yes_valid_dose_calc==1

		* Grab count for each of the above variables to be used later
		foreach var in ct_dob_no_valid_dose_calc ct_dob_min_valid_dose_calc unambiguous_dob ct_dob_yes_valid_dose_calc {	
			count if `var' == 0
				  scalar n_0 = r(N)
			count if `var' == 1
				  scalar n_1 = r(N)
			count if `var' == 1 | `var' == 0
				  scalar n_01 = r(N)
			
			post dt_dob_valid_dose_calculations ("dob") ("sensible dob calculations") ("`var'") (n_0) (n_1) (n_01)

		}

		capture postclose dt_dob_valid_dose_calculations
	}

	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

