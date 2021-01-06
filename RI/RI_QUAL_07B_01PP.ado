*! RI_QUAL_07B_01PP version 1.01 - Biostat Global Consulting - 2020-03-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-03-10	1.00	Mary Prier		Original version 
* 2020-03-23	1.01	Mary Prier		Added $VCQI_LEVEL4_SET_VARLIST and 
* 										$VCQI_LEVEL4_STRATIFIER to the merge
*										keepusing option
*******************************************************************************

program define RI_QUAL_07B_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07B_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		local exitflag 0

		*Confirm calculate_MOV_flags has been run and RI_MOV_long_form_data.dta (i.e., Step07) is available
		capture confirm file `"${VCQI_OUTPUT_FOLDER}\RI_MOV_long_form_data.dta"'
		if _rc {
			di as error "RI_MOV_long_form_data.dta must exist before running RI_QUAL_07B. Set the vcqi-global VCQI_TESTING_CODE to 1 and run calculate_MOV_flags before running RI_QUAL_07B."
			vcqi_log_comment $VCP 1 Error "RI_MOV_long_form_data.dta must exist before running RI_QUAL_07B. Set the vcqi-global VCQI_TESTING_CODE to 1 and run calculate_MOV_flags before running RI_QUAL_07B."
			local exitflag 1
		}
		
		if `exitflag' == 1 {
			vcqi_global VCQI_ERROR 1
			vcqi_halt_immediately
		}
		
		use "${VCQI_OUTPUT_FOLDER}/RI_MOV_long_form_data", clear
		keep respid dob visitdate 
		
		* Merge back on variables needed in the _GO program
		merge m:1 respid using "${VCQI_OUTPUT_FOLDER}/RI_with_ids", keepusing(clusterid stratumid psweight ///
				level1id level1name level2id level2name level3id level3name $VCQI_LEVEL4_SET_VARLIST $VCQI_LEVEL4_STRATIFIER)
				
		save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_07B_${ANALYSIS_COUNTER}", replace
		vcqi_global RI_QUAL_07B_TEMP_DATASETS $RI_QUAL_07B_TEMP_DATASETS RI_QUAL_07B_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
