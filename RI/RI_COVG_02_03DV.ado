*! RI_COVG_02_03DV version 1.07 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added end double quote " to label variable got_valid_`d'_by_`s' "Valid dose recived for `d' on `s'"
*
*										Added missing var labels to the below generated variables
*										got_valid_`d'_to_analyze
*											label variable got_valid_`d'_to_analyze "Received valid dose for `d'- RI_RECORDS_SOUGHT_FOR_ALL"
*											label variable got_valid_`d'_to_analyze "Received valid dose for `d'- RI_RECORDS_SOUGHT_IF_NO_CARD"
*											label variable got_valid_`d'_to_analyze "Received valid dose for `d'- RI_RECORDS_NOT_SOUGHT"
*										valid_`d'_age1_to_analyze
*											label variable age_at_`d'_`s' "Age when `d' was received on `s'"
*										age_at_valid_`d'
*											label variable age_at_valid_`d' "Age received valid dose for `d'- RI_RECORDS_SOUGHT_FOR_ALL"
*											label variable age_at_valid_`d' "Age received valid dose for `d'- RI_RECORDS_SOUGHT_IF_NO_CARD"
*											label variable age_at_valid_`d' "Age received valid dose for `d'- RI_RECORDS_NOT_SOUGHT"
*										age_at_`d'_`s'
*											label variable age_at_`d'_`s' "Age when `d' was received on `s'"
*
* 2016-05-19	1.02	Dale Rhoda		added scalar for max age at valid dose
*
* 2016-07-06	1.03	Dale Rhoda		Added calculation for age_at_valid_*
*   									for the doses in RI_MULTI_2_DOSE_LIST

* 2017-01-12	1.04	Dale Rhoda		Remove respondent from denominator if
*										the dose eligibility age is > the 
*										survey eligibility age and if the age
*										of the respondent is not clearly >
*										the dose eligibility age
*
* 2017-01-30	1.05	Dale Rhoda		Fixed a typo in a variable label
* 2017-02-01	1.06	Dale Rhoda		Edited comment
* 2017-08-26	1.07	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_02_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}", clear

		*Create new age_dose_received variables
		foreach s in card register {
			foreach d in $RI_DOSE_LIST {
				gen age_at_`d'_`s' = `d'_`s'_date - dob_for_valid_dose_calculations
				label variable age_at_`d'_`s' "Age when `d' was received on `s'"
			}
		}

		*Generate variables to determine if the dose was received in a valid timeframe 
		foreach s in card register {
			foreach d in `=lower("$RI_SINGLE_DOSE_LIST")' {
				*Assume age_at_`d' was calculated using a valid dob and valid vaccination date.
				*Assume min_age scalar already in memory
				gen got_valid_`d'_by_`s'=(age_at_`d'_`s' >=`d'_min_age_days) & !missing(age_at_`d'_`s')
				label variable got_valid_`d'_by_`s' "Valid dose received for `d' on `s'"
				
				* Occasionally users will specify a maximum age at which a dose is 
				* considered valid (e.g., for one of the birth doses) so check
				* here to see if they have specified a max; if so, enforce it
				capture confirm scalar `d'_max_age_days
				if _rc == 0 replace got_valid_`d'_by_`s'= 0 if (age_at_`d'_`s' > `d'_max_age_days) & !missing(age_at_`d'_`s')
				
				* For (uncommon) doses where the age of dose-eligibility is older than
				* the age of survey-eligibility (e.g., 2nd dose of measles in 2nd 
				* year of life) remove respondents from the denominator if they are
				* not clearly age-eligible for the dose		
				
				capture replace  got_valid_`d'_by_`s' = . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)
			}
		}


		*Create variables with 2 doses
		*Create variables for Card with 3 doses
		foreach s in card register {
			foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
				gen got_valid_`d'1_by_`s'=0
				label variable got_valid_`d'1_by_`s' "Valid dose recived for `d'1 on `s'"

				gen which_valid_`d'1_by_`s'=.
				label variable which_valid_`d'1_by_`s' "Dose number valid for `d'1 on `s'"
				
				* Count backward...because the second recorded dose might be the first valid dose

				replace got_valid_`d'1_by_`s'  =1 if (age_at_`d'2_`s'>=`d'1_min_age_days) & !missing(age_at_`d'2_`s')
				replace which_valid_`d'1_by_`s'=2 if (age_at_`d'2_`s'>=`d'1_min_age_days) & !missing(age_at_`d'2_`s')
			
				* Or maybe the first recorded dose is the first valid dose...
				
				replace got_valid_`d'1_by_`s'  =1 if (age_at_`d'1_`s'>=`d'1_min_age_days) & !missing(age_at_`d'1_`s')
				replace which_valid_`d'1_by_`s'=1 if (age_at_`d'1_`s'>=`d'1_min_age_days) & !missing(age_at_`d'1_`s')

				* For (uncommon) doses where the age of dose-eligibility is older than
				* the age of survey-eligibility (e.g., 2nd dose of measles in 2nd 
				* year of life) remove respondents from the denominator if they are
				* not clearly age-eligible for the dose		
				
				capture replace  got_valid_`d'1_by_`s' = . if `d'1_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'1_min_age_days)
					
			}
		}
				
		foreach s in card register {
			foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
				gen got_valid_`d'2_by_`s'=0
				label variable got_valid_`d'2_by_`s' "Valid dose recived for `d'2 on `s'"

				gen which_valid_`d'2_by_`s'=.
				label variable which_valid_`d'2_by_`s' "Dose number valid for `d'2 on `s'"
						
				* For the second dose to be valid, there must have been a first valid 
				* dose and the minimum interval between doses must be met
				replace which_valid_`d'2_by_`s'=2  if ///
					which_valid_`d'1_by_`s' == 1 & ///
					(age_at_`d'2_`s' - age_at_`d'1_`s') >= `d'2_min_interval_days & ///
					!missing(age_at_`d'2_`s') & !missing(age_at_`d'1_`s') 
					
				replace got_valid_`d'2_by_`s' = 1 if which_valid_`d'2_by_`s' == 2

				* For (uncommon) doses where the age of dose-eligibility is older than
				* the age of survey-eligibility (e.g., 2nd dose of measles in 2nd 
				* year of life) remove respondents from the denominator if they are
				* not clearly age-eligible for the dose		
				
				capture replace  got_valid_`d'2_by_`s' = . if `d'2_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'2_min_age_days)

			}
		}


		* Now assess validity in vaccines with 3 doses
		
		foreach s in card register {
			foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
			
				* Set up and label the variables
				forvalues i = 1/3 {
					gen got_valid_`d'`i'_by_`s' = 0
					label variable got_valid_`d'`i'_by_`s' ///
						"Valid dose recived for `d'`i' on `s'"
					
					gen which_valid_`d'`i'_by_`s' = .
					label variable which_valid_`d'`i'_by_`s' ///
						"Dose number valid for `d'`i' on `s'"
				}

				* Check for a valid first dose
				
				* Count backward, checking to see if the 3rd, and then 2nd, and
				* then 1st recorded dose is the first valid dose of the series
				
				forvalues i = 3(-1)1 {
					replace which_valid_`d'1_by_`s'=`i' if ///
						(age_at_`d'`i'_`s'>=`d'1_min_age_days) & ///
						!missing(age_at_`d'`i'_`s')
				}				

				replace got_valid_`d'1_by_`s' = 1 if ///
					inlist(which_valid_`d'1_by_`s',1,2,3)
		
				* If there was a first valid dose...check to see if there was a second...

				* If it was the third recorded dose that was the first valid dose,
				* then there was not a second valid dose
				
				* If the second recorded dose was the first valid dose,
				* then the only way there can be a valid second dose is for there
				* to have been a third dose and for the interval between 2 and 3 
				* to exceed the minimum
			
				replace which_valid_`d'2_by_`s' = 3 if ///
					which_valid_`d'1_by_`s' == 2 & ///
					(age_at_`d'3_`s' - age_at_`d'2_`s') >= `d'2_min_interval_days & ///
					!missing(age_at_`d'3_`s') & !missing(age_at_`d'2_`s')
			
				* If the first recorded dose was valid, then either the 2nd
				* or 3rd recorded dose might serve as the 2nd valid dose
				
				* Check the 3rd first, and replace it with the 2nd if appropriate

				replace which_valid_`d'2_by_`s' = 3 if ///
					which_valid_`d'1_by_`s' == 1 & ///
					(age_at_`d'3_`s' - age_at_`d'1_`s') >= `d'2_min_interval_days & ///
					!missing(age_at_`d'3_`s') & !missing(age_at_`d'1_`s')
		
				replace which_valid_`d'2_by_`s' = 2 if ///
					which_valid_`d'1_by_`s' == 1 & ///
					(age_at_`d'2_`s' - age_at_`d'1_`s') >= `d'2_min_interval_days & ///
					!missing(age_at_`d'2_`s') & !missing(age_at_`d'1_`s')
		
				replace got_valid_`d'2_by_`s'=1 if inlist(which_valid_`d'2_by_`s',2,3)
		
				* And now...there can only be a valid third dose if there was a 
				* valid first and second dose, and if the interval between the
				* second and third recorded doses meets the required interval

				replace which_valid_`d'3_by_`s' = 3 if ///
					which_valid_`d'2_by_`s' == 2 & ///
					(age_at_`d'3_`s' - age_at_`d'2_`s') >= `d'3_min_interval_days & ///
					!missing(age_at_`d'3_`s') & !missing(age_at_`d'2_`s')
			
				replace got_valid_`d'3_by_`s' = 1 if which_valid_`d'3_by_`s' == 3

				* For (uncommon) doses where the age of dose-eligibility is older than
				* the age of survey-eligibility (e.g., 2nd dose of measles in 2nd 
				* year of life) remove respondents from the denominator if they are
				* not clearly age-eligible for the dose		
				
				capture replace  got_valid_`d'1_by_`s' = . if `d'1_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'1_min_age_days)
				capture replace  got_valid_`d'2_by_`s' = . if `d'2_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'2_min_age_days)
				capture replace  got_valid_`d'3_by_`s' = . if `d'3_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'3_min_age_days)
				
			}
		}

		* Generate the variable for valid dose by card or register
		* Generate the variable to analyze, based on whether & how 
		* RI records were sought at the health centers
		
		
		* Generate the age at valid dose by card and register variables here
		
		foreach s in card register {
		
			foreach d in `=lower("$RI_SINGLE_DOSE_LIST")' {
				gen age_at_valid_`d'_`s' = age_at_`d'_`s' if got_valid_`d'_by_`s' == 1
				label variable age_at_valid_`d'_`s' "Age at valid `d' by `s'"	

				capture replace  age_at_valid_`d'_`s' = . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)
			}
			
			* Note that for multi-dose vaccines, early doses may have been invalid
			* so the date at valid Xn might be the date when they received dose 
			* X(n+1) or X(n+2); loop over j and use the which_valid_Xn_by_s 
			* variable to sort this out properly
			
			foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
				forvalues i = 1/2 {
					gen age_at_valid_`d'`i'_`s' = .
					label variable age_at_valid_`d'`i'_`s' "Age at valid `d'`i' by `s'"
					forvalues j = 1/2 {
						replace age_at_valid_`d'`i'_`s' = age_at_`d'`j'_`s' if which_valid_`d'`i'_by_`s' == `j'
					}
					capture replace  age_at_valid_`d'`i'_`s' = . if `d'`i'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'`i'_min_age_days)
				}
			}
			
			foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
				forvalues i = 1/3 {
					gen age_at_valid_`d'`i'_`s' = .
					label variable age_at_valid_`d'`i'_`s' "Age at valid `d'`i' by `s'"
					forvalues j = 1/3 {
						replace age_at_valid_`d'`i'_`s' = age_at_`d'`j'_`s' if which_valid_`d'`i'_by_`s' == `j'
					}
					capture replace  age_at_valid_`d'`i'_`s' = . if `d'`i'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'`i'_min_age_days)
				}
			}
		}
		
		foreach d in $RI_DOSE_LIST {
			gen got_valid_`d'_c_or_r = (got_valid_`d'_by_card==1 | got_valid_`d'_by_register==1) 
			label variable got_valid_`d'_c_or_r "Either card or register indicate `d' was valid."
		
			if $RI_RECORDS_SOUGHT_FOR_ALL { //if either card or register say it is valid dose count as valid
				* assign value from card initially
				gen got_valid_`d'_to_analyze = got_valid_`d'_by_card==1 | ///
											   got_valid_`d'_by_register==1 
				label variable got_valid_`d'_to_analyze "Received valid dose for `d'- RI_RECORDS_SOUGHT_FOR_ALL"
				
				gen age_at_valid_`d' = age_at_valid_`d'_card if got_valid_`d'_by_card == 1
				label variable age_at_valid_`d' "Age received valid dose for `d'- RI_RECORDS_SOUGHT_FOR_ALL"

				* replace with value from register if card is missing or register
				* is valid
				replace age_at_valid_`d' = age_at_valid_`d'_register if ///
					got_valid_`d'_by_card != 1 & got_valid_`d'_by_register == 1
			}
			else if $RI_RECORDS_SOUGHT_IF_NO_CARD { //only use register if card is missing
				gen got_valid_`d'_to_analyze = got_valid_`d'_by_card
				label variable got_valid_`d'_to_analyze "Received valid dose for `d'- RI_RECORDS_SOUGHT_IF_NO_CARD"

				gen age_at_valid_`d' = age_at_valid_`d'_card if got_valid_`d'_by_card == 1
				label variable age_at_valid_`d' "Age received valid dose for `d'- RI_RECORDS_SOUGHT_IF_NO_CARD"

				* replace with value from register if card is missing or register
				* is valid
				replace got_valid_`d'_to_analyze = got_valid_`d'_by_register if no_card == 1 
				replace age_at_valid_`d' = age_at_valid_`d'_register if no_card == 1 & ///
					got_valid_`d'_by_register == 1
			}		
			else if $RI_RECORDS_NOT_SOUGHT { //Should this be populated with just Card information??
				gen got_valid_`d'_to_analyze = got_valid_`d'_by_card
				label variable got_valid_`d'_to_analyze "Received valid dose for `d'- RI_RECORDS_NOT_SOUGHT"

				gen age_at_valid_`d' = age_at_valid_`d'_card if got_valid_`d'_by_card == 1
				label variable age_at_valid_`d' "Age received valid dose for `d'- RI_RECORDS_NOT_SOUGHT"

			}

			capture replace  got_valid_`d'_c_or_r 		= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)
			capture replace  got_valid_`d'_to_analyze 	= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)
			capture replace  age_at_valid_`d'	 		= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)

		}
		
		*Generate variable to determine if vaccine was received by their first birthday
		foreach s in card register {
			foreach d in $RI_DOSE_LIST {
				gen valid_`d'_age1_`s'= ///
					got_valid_`d'_by_`s'==1 & (age_at_`d'_`s'<=365) 
				label variable valid_`d'_age1_`s' "Received valid `d' by age 1, by `s'"

				capture replace  valid_`d'_age1_`s'	= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)

			}
		}

		*Generate variable to indicate if the vaccine was valid and timely on either card or register
		foreach d in $RI_DOSE_LIST {
			gen valid_`d'_age1_c_or_r = ///
				(valid_`d'_age1_card==1 | valid_`d'_age1_register==1)	
			label variable valid_`d'_age1_c_or_r "Received valid `d' by age 1, by card or register"		
		
			if $RI_RECORDS_SOUGHT_FOR_ALL { //if either card or register say it is valid dose count as valid
				gen valid_`d'_age1_to_analyze = ///
					(valid_`d'_age1_card==1 | valid_`d'_age1_register==1)
				label variable valid_`d'_age1_to_analyze "Received valid dose for `d' by age 1- RI_RECORDS_SOUGHT_FOR_ALL"
			}
			else if $RI_RECORDS_SOUGHT_IF_NO_CARD { //only use register if card is missing
				gen valid_`d'_age1_to_analyze = ///
					(valid_`d'_age1_card==1 | ///
					(valid_`d'_age1_register==1 & no_card == 1))	
				label variable valid_`d'_age1_to_analyze "Received valid dose for `d' by age 1- RI_RECORDS_SOUGHT_IF_NO_CARD"

			}
			else if $RI_RECORDS_NOT_SOUGHT { //Should this be populated with just Card information??
				gen valid_`d'_age1_to_analyze = valid_`d'_age1_card
				label variable valid_`d'_age1_to_analyze "Received valid dose for `d' by age 1- RI_RECORDS_NOT_SOUGHT "

			}
			capture replace  valid_`d'_age1_c_or_r	    = . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)
			capture replace  valid_`d'_age1_to_analyze	= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)
		}	
		
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
