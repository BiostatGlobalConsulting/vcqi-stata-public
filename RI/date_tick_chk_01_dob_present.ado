*! date_tick_chk_01_dob_present version 1.05 - Biostat Global Consulting - 2020-12-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2018-05-30	1.02	MK Trimner		Removed code that was limiting nonsenical dob
*										dates. criteria: | dob_date_`t'_y < 2000 
*										Removed code that limited senical dob dates:
*										criteria: & dob_date_`t'_y > 2000 
* 2018-11-19	1.03	MK Trimner		Changed to only create register variables if
*										register document sought &
*										Updated if register statement to align with `ifreg' local
* 2020-02-27 	1.04	MK Trimner		Corrected No history N value to be if dc_history_yes == 0 instead of missing
* 2020-12-01	1.05	MK Trimner		Created new variables to distinguish between dob and dose for if they had each source
*******************************************************************************

program define date_tick_chk_01_dob_present
	version 14.1

	local oldvcp $VCP
	global VCP date_tick_chk_01_dob_present
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noisily display as text "Checking dates of birth: completeness..."
	
	quietly {
		
		postfile dt_dob_present str20(d type) str32(var) n_0 n_1 n_01 using dt_dob_present , replace
		
		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS dt_dob_present
		
		* Create variables for card and register comparison
		local ifreg if "$RI_RECORDS_NOT_SOUGHT" != "1"

		* Check to make sure all the Register variables are created if the Register was sought
		* If the variables are not present, create them as empty
		`ifreg' {
			 foreach v in dob `=lower("$RI_DOSE_LIST")' {
			    foreach m in m d y {
					capture confirm var `v'_date_register_`m'
					if _rc != 0 gen `v'_date_register_`m'= .
				}
				if "`v'"!="dob" {
				    capture confirm var `v'_tick_register
					if _rc != 0 gen `v'_tick_register = .
				}
			}
		}
		
		* Create variable to show if document was available for dob and doses for all sources 		
		`ifreg' local reg register 
		foreach t in card history `reg' {
		    if "`t'"=="register" {
				local s reg
			}
			else {
				local s `t'
			}
		    
			* Create the yes variables for both dob and dose and set them to 0
			gen dc_`s'_dob_yes = 0
			gen dc_`s'_dose_yes = 0
			
			* replace the dob yes variables to 1 if a dob date component is populated
			foreach dob in dob_date_`t'_m dob_date_`t'_d dob_date_`t'_y {
			    replace dc_`s'_dob_yes = 1 if !missing(`dob')
			}
			
			* Do the same for the dose yes variables. 
			* We use the same logic for card and register but a different one for history
			* since the variables are different for this source
			if "`t'"!="history" {
				* Now we will do the same for doses
				foreach v in `=lower("$RI_DOSE_LIST")' {
					foreach dose in `v'_date_`t'_m `v'_date_`t'_d `v'_date_`t'_y `v'_tick_`t' {
						replace dc_`s'_dose_yes = 1 if !missing(`dose')
					}
				}
			}
			else {
   				foreach v in `=lower("$RI_DOSE_LIST")' {
					replace dc_`s'_dose_yes = 1 if !missing(`v'_`t')
				}
			}
			
			* Create variable to show if document not available for dob and doses for all sources 
			gen dc_`s'_dob_no = cond(dc_`s'_dob_yes==0,1,0)
			gen dc_`s'_dose_no = cond(dc_`s'_dose_yes==0,1,0)
		}		

		foreach t in card history `reg' {
		
			if "`t'"=="register" {
				local s reg
			}
			else {
				local s `t'
			}

			* Generate variable to show if all three date components are present for dob
			gen ct_dob_`t'_full = .
			replace ct_dob_`t'_full = !missing(dob_date_`t'_m) & !missing(dob_date_`t'_d) & !missing(dob_date_`t'_y)  if dc_`s'_dob_yes==1

			* Generate variable to show if the date of birth is missing for each source
			gen ct_dob_`t'_miss = .
			replace ct_dob_`t'_miss = missing(dob_date_`t'_m) & missing(dob_date_`t'_d) & missing(dob_date_`t'_y)	if dc_`s'_dob_yes==1

			* Generate variable to show if any date component is missing
			gen ct_dob_`t'_parmiss = .
			replace ct_dob_`t'_parmiss =missing(dob_date_`t'_m) | missing(dob_date_`t'_d) | missing(dob_date_`t'_y) if dc_`s'_dob_yes==1
			replace ct_dob_`t'_parmiss=0 if ct_dob_`t'_miss == 1 & dc_`s'_dob_yes==1	// this variable will only show if a date component is missing, not all three.

			* Generate variable to show if all date componenets are present, but the date is invalid
			gen ct_dob_`t'_nonsense = . 
			replace ct_dob_`t'_nonsense = mdy(dob_date_`t'_m, dob_date_`t'_d, dob_date_`t'_y)==. ///
										if ct_dob_`t'_full ==1

			* Create variable to show if all date components were provided for dose for each source, and a valid date resulted from mdy command
			gen ct_dob_`t'_sense = .
			replace ct_dob_`t'_sense = mdy(dob_date_`t'_m, dob_date_`t'_d, dob_date_`t'_y)!=. if ct_dob_`t'_full == 1 
								
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
							ct_dob_`t'_within_range ct_dob_`t'_late ct_dob_`t'_too_early dc_`s'_dob_yes dc_`s'_dob_no {	
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
