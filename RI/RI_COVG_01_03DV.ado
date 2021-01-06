*! RI_COVG_01_03DV version 1.04 - Biostat Global Consulting - 2019-07-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-06-06	1.01	Dale Rhoda		Added card or register
* 2017-01-13	1.02	Dale Rhoda		Remove respondent from denominator if
*										the dose eligibility age is > the 
*										survey eligibility age and if the age
*										of the respondent is not clearly >
*										the dose eligibility age
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2019-07-17	1.04	Dale Rhoda		Make outcomes missing if psweight == 0 | missing(psweight)
*******************************************************************************

program define RI_COVG_01_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_01_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", clear

		*This code assumes that dates and tick marks have been renamed and verified
		foreach d in $RI_DOSE_LIST {
			gen got_crude_`d'_by_card = ( !missing(`d'_card_date) | `d'_card_tick==1 )
			gen got_crude_`d'_by_history = ( `d'_history == 1 )
			gen got_crude_`d'_by_register = ( !missing(`d'_register_date) | `d'_register_tick==1 )
			gen got_crude_`d'_c_or_h = ( got_crude_`d'_by_card == 1 | got_crude_`d'_by_history == 1 )
			gen got_crude_`d'_c_or_r = ( got_crude_`d'_by_card == 1 | got_crude_`d'_by_register == 1 )
			gen got_crude_`d'_c_or_h_or_r = ( got_crude_`d'_c_or_h == 1 | got_crude_`d'_by_register==1 )
			
			label variable got_crude_`d'_by_card "Got `d', by card"
			label variable got_crude_`d'_by_history "Got `d', by history"
			label variable got_crude_`d'_by_register "Got `d', by register"
			label variable got_crude_`d'_c_or_h "Got `d', by card or history"
			label variable got_crude_`d'_c_or_r "Got `d', by card or register"
			label variable got_crude_`d'_c_or_h_or_r "Got `d', by card, history or register"
			
			if lower("`d'") == "bcg" {
				gen got_crude_bcg_by_scar = (bcg_scar_history == 1)
				replace got_crude_bcg_c_or_h     =1 if bcg_scar_history==1 
				replace got_crude_bcg_c_or_h_or_r=1 if bcg_scar_history==1 
				
				capture label variable got_crude_bcg_by_scar "Got bcg, by scar"
				label variable got_crude_`d'_c_or_h "Got bgc, by card or history or scar"
				label variable got_crude_`d'_c_or_h_or_r "Got bgc, by card, history, scar or register"

			}
			
			if $RI_RECORDS_NOT_SOUGHT {
				capture drop got_crude_`d'_by_register
				capture drop got_crude_`d'_by_c_or_r
				capture drop got_crude_`d'_c_or_h_or_r
				gen got_crude_`d'_to_analyze = got_crude_`d'_c_or_h
			}
			
			* use card if available, otherwise use register
			if $RI_RECORDS_SOUGHT_IF_NO_CARD {
				gen got_crude_`d'_to_analyze = got_crude_`d'_c_or_h
				replace got_crude_`d'_to_analyze = (got_crude_`d'_by_register == 1 | got_crude_`d'_by_history == 1) if no_card == 1
				if "`d'" == "bcg" replace got_crude_bcg_to_analyze = 1 if bcg_scar_history == 1
			}
			
			* use positive outcome from any source
			if $RI_RECORDS_SOUGHT_FOR_ALL {
				gen got_crude_`d'_to_analyze = got_crude_`d'_c_or_h_or_r
			}

			label variable got_crude_`d'_to_analyze "Got `d', to analyze"
			
			* For (uncommon) doses where the age of dose-eligibility is older than
			* the age of survey-eligibility (e.g., 2nd dose of measles in 2nd 
			* year of life) remove respondents from the denominator if they are
			* not clearly age-eligible for the dose		
			
			capture replace got_crude_`d'_by_card 		= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)
			capture replace got_crude_`d'_by_history 	= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)  
			capture replace got_crude_`d'_by_register 	= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days) 
			capture replace got_crude_`d'_c_or_h	 	= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days) 
			capture replace got_crude_`d'_c_or_r 		= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days) 
			capture replace got_crude_`d'_c_or_h_or_r 	= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days) 
			capture replace got_crude_`d'_to_analyze 	= . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days) 

			if "`d'" == "bcg"	capture replace got_crude_`d'_by_scar = . if `d'_min_age_days > $VCQI_RI_MIN_AGE_OF_ELIGIBILITY & ( missing(age_at_interview) | age_at_interview < `d'_min_age_days)

			
			* Sometimes there will be rows in the dataset with all empty input variables, and a value of 0 for psweight
			* 
			* These are placeholders for clusters that did not yield any kids
			*
			* They do not represent actual children, so the outcome should be missing for any row where the weight is 0.
			*
			
			capture replace got_crude_`d'_by_card 		= . if psweight == 0 | missing(psweight)
			capture replace got_crude_`d'_by_history 	= . if psweight == 0 | missing(psweight)   
			capture replace got_crude_`d'_by_register 	= . if psweight == 0 | missing(psweight)
			capture replace got_crude_`d'_c_or_h	 	= . if psweight == 0 | missing(psweight)
			capture replace got_crude_`d'_c_or_r 		= . if psweight == 0 | missing(psweight)
			capture replace got_crude_`d'_c_or_h_or_r 	= . if psweight == 0 | missing(psweight)
			capture replace got_crude_`d'_to_analyze 	= . if psweight == 0 | missing(psweight)
			
			if "`d'" == "bcg" replace got_crude_bcg_by_scar = . if psweight == 0  | missing(psweight)
		}

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
