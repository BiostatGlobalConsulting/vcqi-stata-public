*! parse_CVDIMS_variables version 1.00 - Biostat Global Consulting - 2020-04-19
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-04-19	1.00	Mary Prier		Original version
*
*******************************************************************************

program define parse_CVDIMS_variables
	version 14.1

	local oldvcp $VCP
	global VCP parse_CVDIMS_variables
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {

		local exitflag 0	
			
		* Check CVDIMS dataset exists
		capture confirm file "${VCQI_OUTPUT_FOLDER}/CVDIMS_variables.dta"
		if _rc != 0 {
			local exitflag 1 
			di as error ///
				"CVDIMS_variables.dta does not exist. Re-run calculate_MOV_flags in the control program with vcqi_global DELETE_TEMP_VCQI_DATASETS set to 0."
			vcqi_log_comment $VCP 1 Error "CVDIMS_variables.dta does not exist. Re-run calculate_MOV_flags in the control program with vcqi_global DELETE_TEMP_VCQI_DATASETS set to 0."
		}
		else {
			* Read-in CVDIMS dataset
			use "${VCQI_OUTPUT_FOLDER}/CVDIMS_variables.dta", clear

			* Parse CVDIMS codes for valid & crude
			foreach vc in valid crude {
				split cvdims_sequence_`vc', p(" | ") g(`vc'_visit)
				gen num_visits_`vc' = length(cvdims_sequence_`vc') - length(subinstr(cvdims_sequence_`vc', "|", "", .)) + 1
			}
			
			* Save dataset with new variables
			save "${VCQI_OUTPUT_FOLDER}/CVDIMS_variables_parsed.dta", replace
			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS CVDIMS_variables_parsed
		}

		if "`exitflag'" == "1" {
			vcqi_global VCQI_ERROR 1
			noi vcqi_halt_immediately
		}
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

