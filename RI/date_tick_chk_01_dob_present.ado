*! date_tick_chk_01_dob_present version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define date_tick_chk_01_dob_present
	version 14.1

	local oldvcp $VCP
	global VCP date_tick_chk_01_dob_present
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noisily display "Checking dates of birth: completeness..."
	
	quietly {
		
		postfile dt_dob_present str20(d type) str32(var) n_0 n_1 n_01 using dt_dob_present , replace
		
		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS dt_dob_present

		* Create variables to show if card was received
		gen dc_card_yes =cond(RI27==1,1,0) 
		gen dc_card_no  =cond(dc_card_yes ==0,1,0)


		* Create variable to show if register document available
		gen dc_reg_yes  =0

		 * Create variable to show if history shows data
		gen dc_history_yes = 0 

		foreach v in `=lower("$RI_DOSE_LIST")' {
		
			foreach vv in `v'_date_register_d `v'_date_register_m `v'_date_register_y `v'_tick_register {
				capture confirm variable `vv'
				if _rc != 0 gen `vv' = .
				replace dc_reg_yes = 1 if !missing(`vv')
			}
										
			replace dc_history_yes = 1 if !missing(`v'_history)
		}

		foreach d in m d y {
			capture confirm variable dob_date_register_`d'
			if _rc != 0 gen dob_date_register_`d' = .			
			replace dc_reg_yes=1 if !missing(dob_date_register_`d')
			
			replace dc_history_yes=1 if !missing(dob_date_history_`d')
		}


		* Create variable to show if reg document not available
		gen dc_reg_no      = cond(dc_reg_yes ==0,1,0)

		gen dc_history_no  = cond(dc_history_yes==.,1,0)

			  
		foreach t in card register history {
		
			if "`t'"=="register" {
				local s reg
			}
			else {
				local s `t'
			}

			* Generate variable to show if all three date components are present for dob
			gen ct_dob_`t'_full = .
			replace ct_dob_`t'_full = !missing(dob_date_`t'_m) & !missing(dob_date_`t'_d) & !missing(dob_date_`t'_y)  if dc_`s'_yes==1

			* Generate variable to show if the date of birth is missing for each source
			gen ct_dob_`t'_miss = .
			replace ct_dob_`t'_miss = missing(dob_date_`t'_m) & missing(dob_date_`t'_d) & missing(dob_date_`t'_y)	if dc_`s'_yes==1

			* Generate variable to show if any date component is missing
			gen ct_dob_`t'_parmiss = .
			replace ct_dob_`t'_parmiss =missing(dob_date_`t'_m) | missing(dob_date_`t'_d) | missing(dob_date_`t'_y) if dc_`s'_yes==1
			replace ct_dob_`t'_parmiss=0 if ct_dob_`t'_miss == 1 & dc_`s'_yes==1	// this variable will only show if a date component is missing, not all three.

			* Generate variable to show if all date componenets are present, but the date is invalid
			gen ct_dob_`t'_nonsense = . 
			replace ct_dob_`t'_nonsense = mdy(dob_date_`t'_m, dob_date_`t'_d, dob_date_`t'_y)==. | dob_date_`t'_y < 2000 ///
										if ct_dob_`t'_full ==1

			* Create variable to show if all date components were provided for dose for each source, and a valid date resulted from mdy command
			gen ct_dob_`t'_sense = .
			replace ct_dob_`t'_sense = mdy(dob_date_`t'_m, dob_date_`t'_d, dob_date_`t'_y)!=. & dob_date_`t'_y > 2000 if ct_dob_`t'_full == 1 
								
			* Create variable to show if all sensible dates are within the acceptable ranger per dob and surveydates
			* Make sure dates are not before dob
			* If no dob, make sure dates are after earliest date
			gen ct_dob_`t'_too_early=.
			replace ct_dob_`t'_too_early=mdy(dob_date_`t'_m, dob_date_`t'_d, dob_date_`t'_y)<earliest_svy_vacc_date ///
										if ct_dob_`t'_sense==1 // if dose date is prior to dob
										
			* Create variable to flag if dose date is after survey date
			gen ct_dob_`t'_late=.
			replace ct_dob_`t'_late=mdy(dob_date_`t'_m, dob_date_`t'_d, dob_date_`t'_y)>latest_svy_vacc_date if ct_dob_`t'_sense==1 
			
			* Create variable to show if dose was received within acceptable date range
			gen ct_dob_`t'_within_range=.
			replace ct_dob_`t'_within_range=ct_dob_`t'_too_early==0 & ct_dob_`t'_late==0 if ct_dob_`t'_sense==1   
				
				
		   * Grab the count for each of the above variables
			foreach var in ct_dob_`t'_full ct_dob_`t'_nonsense ct_dob_`t'_miss  ct_dob_`t'_parmiss ct_dob_`t'_sense ///
							ct_dob_`t'_within_range ct_dob_`t'_late ct_dob_`t'_too_early {	
				count if `var' == 0
					  scalar n_0 = r(N)
				count if `var' == 1
					  scalar n_1 = r(N)
				count if `var' == 1 | `var' == 0
					  scalar n_01 = r(N)
				
				post dt_dob_present ("dob") ("`t'") ("`var'") (n_0) (n_1) (n_01)

			}
		}
		
		capture postclose dt_dob_present
		
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end

