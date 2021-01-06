*! RI_QUAL_03_03DV version 1.05 - Biostat Global Consulting - 2019-07-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-09-19	1.01	Dale Rhoda		Require age at vaccination to declare
* 										that the dose was invalid
* 2016-09-21	1.02	Dale Rhoda		Bring in logic from RI_COVG_02
* 2017-02-01	1.03	Dale Rhoda		Clarified the SOUGHT logic
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2019-07-17	1.05	Dale Rhoda		Set outcomes to . if psweight == 0
*******************************************************************************

program define RI_QUAL_03_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_03_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_03_${ANALYSIS_COUNTER}", clear

		local d `=lower("$RI_QUAL_03_DOSE_NAME")'
		
		*Create new age_dose_received variables
		foreach s in card register {
			gen age_at_`d'_`s' = `d'_`s'_date - dob_for_valid_dose_calculations
			label variable age_at_`d'_`s' "Age when `d' was received on `s'"
		}

		*Generate variables to determine if the dose was received in a valid timeframe 
		foreach s in card register {
			*Assume age_at_`d' was calculated using a valid dob and valid vaccination date.
			*Assume min_age scalar already in memory
			gen got_invalid_`d'_by_`s'=(age_at_`d'_`s' < `d'_min_age_days) if psweight > 0 & !missing(psweight)
			replace got_invalid_`d'_by_`s' = . if missing(dob_for_valid_dose_calculations) 
			replace got_invalid_`d'_by_`s' = . if missing(age_at_`d'_`s') 
			
			label variable got_invalid_`d'_by_`s' "Invalid dose received for `d' on `s'"
				
			* Occasionally users will specify a maximum age at which a dose is 
			* considered valid (e.g., for one of the birth doses) so check
			* here to see if they have specified a max; if so, enforce it
			capture confirm scalar `d'_max_age_days
			if _rc == 0 replace got_invalid_`d'_by_`s'= 1 if (age_at_`d'_`s' > `d'_max_age_days) & !missing(age_at_`d'_`s')
				
		}
					
		if $RI_RECORDS_NOT_SOUGHT {
			gen got_invalid_`d' = got_invalid_`d'_by_card
		}
				
		if $RI_RECORDS_SOUGHT_FOR_ALL {
			gen     got_invalid_`d' = got_invalid_`d'_by_card
			replace got_invalid_`d' = got_invalid_`d'_by_register if ///
				missing(got_invalid_`d') | got_invalid_`d'_by_register == 0
		}
		if $RI_RECORDS_SOUGHT_IF_NO_CARD {
			gen     got_invalid_`d' = got_invalid_`d'_by_card 
			replace got_invalid_`d' = got_invalid_`d'_by_register if no_card == 1
		}
			
		label variable got_invalid_`d' "Invalid `d' Received"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
