*! RI_CCC_02_03DV version 1.01 - Biostat Global Consulting - 2020-04-22
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-12-06	1.00	Mary Prier		Original version
* 2020-04-22	1.01	Dale Rhoda		Allow user to specify CCC_XMAX
*******************************************************************************

program define RI_CCC_02_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CCC_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_CCC_02_${ANALYSIS_COUNTER}", clear
		
		* Calculate the age child was when s/he rec'd dose
		foreach d in `=lower("$RI_DOSE_LIST")' {
			gen age_at_`d'_card = (`d'_card_date - dob_for_valid_dose_calculations) if !missing(`d'_card_date)
			gen age_at_`d'_register = (`d'_register_date - dob_for_valid_dose_calculations) if !missing(`d'_register_date)
		}
		
		* Make indicator if child had a card with at least one date on it
		foreach cr in card register {
			local list_`cr'
			foreach d in `=lower("$RI_DOSE_LIST")' {
				local list_`cr' `list_`cr'' !missing(`d'_`cr'_date) | 
			}
			local list_`cr' = substr("`list_`cr''",1,`=length("`list_`cr''")-2')  // remove last " |" in local string
			
			gen `cr'_with_dates = .
			replace `cr'_with_dates = 1 if `list_`cr''
			
			gen denom_`cr' = .
			replace denom_`cr' = 1 if `cr'_with_dates==1 & !missing(dob_for_valid_dose_calculations)
		}
		
		* Calculate x-max...
		foreach cr in card register {
			gen xmax_temp_`cr' = .
			* First, use the max of the schedule...
			foreach d in `=lower("$RI_DOSE_LIST")' {
				replace xmax_temp_`cr' = max(xmax_temp_`cr', `d'_min_age_days)
			}			
			* Now update xmax_card & xmax_register based on the data...
			foreach d in `=lower("$RI_DOSE_LIST")' {
				replace xmax_temp_`cr' = max(xmax_temp_`cr', age_at_`d'_`cr')
			}
			egen xmax_temp2_`cr' = max(xmax_temp_`cr')
			gen xmax_`cr' = $RI_CCC_02_XMAX_INTERVAL * ceil(xmax_temp2_`cr'/$RI_CCC_02_XMAX_INTERVAL) // round up to the nearest xmax_interval (default is 50)
			drop xmax_temp_`cr' xmax_temp2_`cr'
			global XMAX_`cr' = xmax_`cr'[1]
			
			* Allow the user to over-ride the xmax by setting the global CCC_XMAX
			if "$CCC_XMAX" != "" global XMAX_`cr' = $CCC_XMAX
		}
				
		save "${VCQI_OUTPUT_FOLDER}/RI_CCC_02_${ANALYSIS_COUNTER}", replace
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
