*! RI_dose_intervals version 1.05 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-31	1.01	Dale Rhoda		Added $VCQI_LEVEL4_SET_VARLIST 
* 2017-02-01	1.02	Dale Rhoda		Save RI_dose_intervals dataset
* 2017-03-17	1.03	Dale Rhoda		Include psweight in the dataset
* 2017-05-17	1.04	Dale Rhoda		Trim down the reshape i() list 
* 2017-08-26	1.05	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_dose_intervals
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_dose_intervals
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear
		
		local dlist	
		foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' `=lower("$RI_MULTI_3_DOSE_LIST")' {
			local dlist `dlist' `d'1_card_date `d'1_register_date `d'2_card_date `d'2_register_date	
		}
		foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
			local dlist `dlist' `d'3_card_date `d'3_register_date	
		}
		
		*Only keep variables necessary to calculate dose intervals
		keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
			 $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST `dlist' no_card psweight
		
		*Create variables for each dose interval from both card and register
		
		foreach s in card register {	
			foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' `=lower("$RI_MULTI_3_DOSE_LIST")' {
				gen `s'_interval_days_`d'_1_2=(`d'2_`s'_date-`d'1_`s'_date)
				label variable `s'_interval_days_`d'_1_2 "Days between `d' dose 1 and 2 `s'"
			}
		}

		foreach s in card register {	
			foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
				gen `s'_interval_days_`d'_2_3=(`d'3_`s'_date-`d'2_`s'_date)
				label variable `s'_interval_days_`d'_2_3 "Days between `d' dose 2 and 3 `s'"
			}
		}

		*Reshape to have each interval on a separate line
		reshape long card_interval_days register_interval_days, ///
			i(level1id level2id level3id stratumid clusterid respid) j(dose_interval) string
			
		drop if missing(card_interval_days) & missing(register_interval_days)

		keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
				$VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST no_card psweight ///
				dose_interval card_interval_days register_interval_days
		
		*Create new variables to identify the early and later dose
		gen early_dose=subinstr(dose_interval,"_","",.)
		label variable early_dose "Earliest dose in sequence"

		gen later_dose=subinstr(dose_interval,"_","",.)
		label variable later_dose "Later dose in sequence"

		replace early_dose=subinstr(early_dose,"12","1",.)
		replace early_dose=subinstr(early_dose,"23","2",.)
		
		replace later_dose=subinstr(later_dose,"12","2",.)
		replace later_dose=subinstr(later_dose,"23","3",.)
		
		drop dose_interval
		
		capture label variable card_interval_days "Interval (days) per vaccination card"
		capture label variable register_interval_days "Interval (days) per EPI register"

		order level1id level2id level3id stratumid clusterid respid ///
		$VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST no_card psweight ///
		early_dose later_dose card_interval_days register_interval_days
		
		save "${VCQI_OUTPUT_FOLDER}/RI_dose_intervals", replace
		vcqi_global RI_QUAL_05_TEMP_DATASETS $RI_QUAL_05_TEMP_DATASETS RI_dose_intervals
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
