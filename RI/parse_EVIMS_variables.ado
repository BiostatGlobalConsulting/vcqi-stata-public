*! parse_EVIMS_variables version 1.00 - Biostat Global Consulting - 2020-04-04
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-04-04	1.00	Mary Prier		Original version
*
*******************************************************************************

program define parse_EVIMS_variables
	version 14.1

	local oldvcp $VCP
	global VCP parse_EVIMS_variables
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {

		local exitflag 0	
			
		*global VCQI_OUTPUT_FOLDER "Q:\PAHO MOV Tool\2020 updates\EVIM\Output - EVIM miss-vcqi faux data - Elbow plots"  //eventually delete this line

		* Check EVIMS dataset exists
		capture confirm file "${VCQI_OUTPUT_FOLDER}/EVIMS_variables.dta"
		if _rc != 0 {
			local exitflag 1 
			di as error ///
				"EVIMS_variables.dta does not exist. Re-run calculate_MOV_flags in the control program with vcqi_global DELETE_TEMP_VCQI_DATASETS set to 0."
			vcqi_log_comment $VCP 1 Error "EVIMS_variables.dta does not exist. Re-run calculate_MOV_flags in the control program with vcqi_global DELETE_TEMP_VCQI_DATASETS set to 0."
		}
		else {
			* Read-in EVIMS dataset
			use "${VCQI_OUTPUT_FOLDER}/EVIMS_variables.dta", clear

			* Parse EVIMS codes for valid & crude
			foreach vc in valid crude {
				split evims_sequence_`vc', p(" | ") g(`vc'_visit)
				gen num_visits_`vc' = length(evims_sequence_`vc') - length(subinstr(evims_sequence_`vc', "|", "", .)) + 1
			}
			
			* Save dataset with new variables
			save "${VCQI_OUTPUT_FOLDER}/EVIMS_variables_parsed.dta", replace
			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS EVIMS_variables_parsed
		}

		if "`exitflag'" == "1" {
			vcqi_global VCQI_ERROR 1
			noi vcqi_halt_immediately
		}
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

