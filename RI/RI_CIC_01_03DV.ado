*! RI_CIC_01_03DV version 1.00 - Biostat Global Consulting - 2019-01-10
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2019-01-10	1.00	Mary Prier		Original version
*******************************************************************************

program define RI_CIC_01_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CIC_01_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_CIC_01_${ANALYSIS_COUNTER}", clear
		
		* This chunk of code was copied from RI_dose_intervals.ado
		* Create variables for each dose intervals 1-2 from both card and register
		global dose_interval_groups
		foreach s in card register {	
			foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' `=lower("$RI_MULTI_3_DOSE_LIST")' {
				gen `s'_interval_days_`d'_1_2=(`d'2_`s'_date-`d'1_`s'_date)
				label variable `s'_interval_days_`d'_1_2 "Days between `d' dose 1 and 2 `s'"
				global dose_interval_groups $dose_interval_groups `s'_interval_days_`d'_1_2
			}
		}

		* Create variables for each dose intervals 2-3 from both card and register
		foreach s in card register {	
			foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
				gen `s'_interval_days_`d'_2_3=(`d'3_`s'_date-`d'2_`s'_date)
				label variable `s'_interval_days_`d'_2_3 "Days between `d' dose 2 and 3 `s'"
				global dose_interval_groups $dose_interval_groups `s'_interval_days_`d'_2_3
			}
		}
			
		* Calculate x-max...
		local loop_over 
		global dose_pair
		foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
			local loop_over `loop_over' `d'2
			global dose_pair $dose_pair `d'_1_2
		}
		foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
			local loop_over `loop_over' `d'2 `d'3
			global dose_pair $dose_pair `d'_1_2 `d'_2_3
		}

		foreach cr in card register {
			gen xmax_temp_`cr' = .
			* First, set the max to the min_interval_days according to the schedule...
			foreach d in `loop_over' {
				replace xmax_temp_`cr' = max(xmax_temp_`cr', `d'_min_interval_days)
			}			
			* Now update var based on the data...
			foreach d in $dose_pair {
				replace xmax_temp_`cr' = max(xmax_temp, `cr'_interval_days_`d')
			}
			egen xmax_temp2_`cr' = max(xmax_temp_`cr')
			gen xmax_`cr' = $RI_CIC_01_XMAX_INTERVAL * ceil(xmax_temp2_`cr'/$RI_CIC_01_XMAX_INTERVAL) // round up to the nearest xmax_interval (default is 50)
			drop xmax_temp_`cr' xmax_temp2_`cr'
			global XMAX_`cr' = xmax_`cr'[1]
		}
				
		save "${VCQI_OUTPUT_FOLDER}/RI_CIC_01_${ANALYSIS_COUNTER}", replace
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
