*! check_RI_analysis_metadata version 1.15 - Biostat Global Consulting - 2021-01-21
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added vcqi_log_comment type number 1:
*										Changed Log error and screen error to match: Please set `g'		
* 2016-02-12	1.02	Dale Rhoda		Added code for 3 new globals:
*											DELETE_VCQI_DATABASES_AT_END
*											DELETE_TEMP_VCQI_DATASETS
*											SAVE_VCQI_GPH_FILES
* 2016-02-15	1.03	Dale Rhoda		Set VCQI_ERROR to 1 if exitflag == 1
* 2016-03-07	1.04	Dale Rhoda		Call generic checking program								
* 2016-09-08	1.05	Dale Rhoda		Set default VCQI_REPORT_DATA_QUALITY
* 2017-01-31	1.06	Dale Rhoda		Cosmetic edits
* 2017-06-07	1.07	MK Trimner		Added checks for required RI variables
* 2017-07-05	1.07	MK Trimner		Moved generic check analysis metadata program to the top of the program
* 2017-07-18	1.07	MK Trimner		Moved dataset checks within main dataset check.. will not run if dataset not set
* 2017-07-18	1.08	Dale Rhoda		Syntax cleanup
* 2017-08-26	1.09	Mary Prier		Added version 14.1 line
* 2019-11-08	1.10	Dale Rhoda		Introduced MOV_OUTPUT_DOSE_LIST
* 2020-01-20	1.11	Dale Rhoda		Made check_VCQI_CM_metadata its own program
* 2020-12-09	1.12	Dale Rhoda		Add missing quotation mark
* 2021-01-16	1.13	MK Trimner		Added code for a DQ check and to program for backward compatibility with the Interview variable names
*										that were mistakenly inconsistent VCQI’s (now consistent) _m, _d, _y convention
*										Code will check the different Interview date variable options
*										Make sure they match and if so pass forward a single value in the form of RI09_m, RI09_d and RI09_y
* 2021-01-19	1.14	MK Trimner		Saved preclean changes to OUTPUT folder and added to the TEMP datasets global
* 2021-01-21	1.15	Dale Rhoda		Always copy RI dataset to INPUT folder
*******************************************************************************

program define check_RI_analysis_metadata
	version 14.1
	
	local oldvcp $VCP
	global VCP check_RI_analysis_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	* Check the generic analysis-related globals
	check_analysis_metadata
	
	* Check the CM dataset
	check_VCQI_CM_metadata

	local exitflag 0
	
	* Check that user has specified doses to analyze
	
	vcqi_log_global RI_SINGLE_DOSE_LIST
	vcqi_log_global RI_MULTI_2_DOSE_LIST
	vcqi_log_global RI_MULTI_3_DOSE_LIST
	
	if "$RI_SINGLE_DOSE_LIST" == "" & "$RI_MULTI_2_DOSE_LIST" == "" & ///
	   "$RI_MULTI_3_DOSE_LIST" == "" {
		di as error "No RI doses are identified for analysis...so quit"
		vcqi_log_comment $VCP 1 Error "No RI doses are identified for analysis...so quit"
		local exitflag 1
	}
	
	if "$VCQI_RI_DATASET" == "" {
		di as error "Please set VCQI_RI_DATASET."
		vcqi_log_comment $VCP 1 Error "Please set VCQI_RI_DATASET."
		local exitflag 1
	}	
	else if "$VCQI_RI_DATASET" != "" { 
	
		* Check that RI dataset exists
		
		vcqi_log_global VCQI_DATA_FOLDER
		vcqi_log_global VCQI_RI_DATASET
		vcqi_log_global VCQI_RIHC_DATASET
		
		capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}.dta"
		* If yes, make a copy in the OUTPUT folder
		if _rc == 0 {
		    copy "${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}.dta" "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}.dta", replace
			vcqi_global RI_TEMP_DATASETS ${VCQI_RI_DATASET}
		}
		* If no, throw an error and stop at the bottom of this program
		if _rc != 0 {
			local exitflag 1 
			di as error ///
				"The file defined by global macros VCQI_DATA_FOLDER/VCQI_RI_DATASET (${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}.dta) does not exist"
			vcqi_log_comment $VCP 1 Error "RI dataset: ${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}.dta does not exist"

		}
		
		* Check that RI variables used across all indicators are present
		* and have the correct variable type
		else {
			use "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}", clear
			
			local dlist 
			foreach v in $RI_DOSE_LIST {
				local dlist `dlist' `v'_date_card_d `v'_date_card_m `v'_date_card_y `v'_tick_card ///
									`v'_history
									
				if "`v'" == "bcg" {
					local dlist `dlist' bcg_scar_history
				}
			}
			
			foreach v in RI01 RI03 RI11 RI12 `dlist' dob_date_card_d dob_date_card_m dob_date_card_y dob_date_history_m dob_date_history_d dob_date_history_y {
				capture confirm variable `v' 
				if _rc == 0 {
					* If the variable exists, confirm the variable is not missing and has the correct variable type
					if "`v'" != "RI11" {
						capture confirm numeric variable `v'
						if _rc != 0 {
							di as error "`v' needs to be a numeric variable in RI dataset."
							vcqi_log_comment $VCP 1 Error "`v' needs to be a numeric variable in RI dataset."
							local exitflag 1
						}
					}
					
					if inlist("`v'", "RI01", "RI03", "RI11", "RI12") {
						capture assert !missing(`v')  
						if _rc != 0 {
							di as error "`v' cannot have a missing value in the RI dataset."
							vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the RI dataset."
							local exitflag 1
						}
					}
				}

				else {
					di as error "Variable `v' does not exist in RI dataset and is required to run VCQI."
					vcqi_log_comment $VCP 1 Error "Variable `v' does not exist in RI dataset and is required to run VCQI."
					local exitflag 1
				}
			}
			* Run the check_interview_date subprogram to check:
			* 1. Was interview date provided
			* 2. Was it provided in more than 1 variable?
			* 3. If more than 1 interview date variable, do these values match?
			check_interivew_date, exitflag(`exitflag')
		}
	}
	
	* If we are using RIHC records, check that the dataset exists
	if "$RI_RECORDS_SOUGHT_FOR_ALL" == "1" | "$RI_RECORDS_SOUGHT_IF_NO_CARD" == "1" {
		if "${VCQI_RIHC_DATASET}" == "" {
			di as error "Please set VCQI_RIHC_DATASET."
			vcqi_log_comment $VCP 1 Error "Please set VCQI_RIHC_DATASET."
			local exitflag 1
		}
		else if "${VCQI_RIHC_DATASET}" != "" {
			
			capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}.dta"
			if _rc != 0 {
				local exitflag 1 
				di as error ///
					"The file defined by global macros VCQI_DATA_FOLDER/VCQI_RIHC_DATASET (${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}.dta) does not exist"
				vcqi_log_comment $VCP 1 Error "RI dataset: ${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}.dta does not exist"
			}
			else {
				use "${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}", clear
				
				local dlist 
				foreach v in $RI_DOSE_LIST {
					local dlist `dlist' `v'_date_register_d `v'_date_register_m `v'_date_register_y `v'_tick_register 
				}
				
				foreach v in RIHC01 RIHC03 RIHC14 RIHC15 `dlist'{
					capture confirm variable `v' 
					if _rc == 0 {
					
						* If the variable exists, confirm the variable is not missing and has the correct variable type
						if "`v'" != "RIHC14" {
							capture confirm numeric variable `v'
							if _rc != 0 {
								di as error "`v' needs to be a numeric variable in RIHC dataset."
								vcqi_log_comment $VCP 1 Error "`v' needs to be a numeric variable in RIHC dataset."
								local exitflag 1
							}
						}
						
						if inlist("`v'", "RIHC01", "RIHC03", "RIHC14", "RIHC15") {
							capture assert !missing(`v')  
							if _rc != 0 {
								di as error "`v' cannot have a missing value in the RIHC dataset."
								vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the RIHC dataset."
								local exitflag 1
							}
						}
					}

					else {
						di as error "Variable `v' does not exist in RIHC dataset and is required to run VCQI."
						vcqi_log_comment $VCP 1 Error "Variable `v' does not exist in RIHC dataset and is required to run VCQI."
						local exitflag 1
					}
				}
			}
		}
	}
	
	* Default is to NOT calculate report on data quality; user can turn it on
	if "$VCQI_REPORT_DATA_QUALITY" == "" 	vcqi_global VCQI_REPORT_DATA_QUALITY 0
	
	* If the user specifies an MOV_OUTPUT_DOSE_LIST, check to be sure all the doses in that list are also in RI_DOSE_LIST
	if "$MOV_OUTPUT_DOSE_LIST" != "" {
		vcqi_log_global MOV_OUTPUT_DOSE_LIST
		local ndoses_not_found 0
		foreach w in $MOV_OUTPUT_DOSE_LIST {
			local dose_found 0
			forvalues i = 1/`=wordcount("$RI_DOSE_LIST")' {
				if "`w'" == word("$RI_DOSE_LIST",`i') local dose_found 1
			}
			if `dose_found' == 0 {
				local ++ndoses_not_found
				di as error                     "The global macro MOV_OUTPUT_DOSE_LIST includes the string `w', which does not appear in the global macro RI_DOSE_LIST; VCQI will remove it from MOV_OUTPUT_DOSE_LIST"
				vcqi_log_comment $VCP 2 Warning "The global macro MOV_OUTPUT_DOSE_LIST includes the string `w', which does not appear in the global macro RI_DOSE_LIST; VCQI will remove it from MOV_OUTPUT_DOSE_LIST."
				global MOV_OUTPUT_DOSE_LIST = stritrim(subinstr("$MOV_OUTPUT_DOSE_LIST","`w'","",1))
			}
			if `ndoses_not_found' > 0 vcqi_log_global RI_DOSE_LIST
		}
	} 
	else global MOV_OUTPUT_DOSE_LIST $RI_DOSE_LIST
	global MOV_OUTPUT_DOSE_LIST = lower("$MOV_OUTPUT_DOSE_LIST")
	vcqi_log_global MOV_OUTPUT_DOSE_LIST
	
	if "`exitflag'" == "1" {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

***********************************************************************************************************************************************
***********************************************************************************************************************************************
* We want to do a DQ check on the Interview Date variables for backward compatibility with the variable names that were mistakenly inconsistent
* This will make changes to the RI dataset and ultimately pass through 3 interview date variables: RI09_m, RI09_d, and RI09_y
* Check to see which RI09 variables are provided
capture program drop check_interivew_date
program define check_interivew_date
	
	syntax, exitflag(int)

	* First check to see if provided in single variable RI09
	capture confirm var RI09
	local RI09 = _rc

	* Create a local to see if second option of RI09 variables were provided: RI09m, RI09d, and RI09y
	* Create a local to see if third option of RI09 variables were provided: RI09_m, RI09_d and RI09_y
	* Create a list of variables for each to see which components are provided
	* If for the second and third RI09 options all 3 components are not provided, send error to screen and exit
	local 2 
	local 3 _
	forvalues i = 2/3 {
		local RI09_`i'_list
		foreach v in RI09``i''m RI09``i''d RI09``i''y {
			capture confirm var `v'
			local `v' = _rc
			if ``v'' == 0 local RI09_`i'_list `RI09_`i'_list' `v' 
		}
							
		* Grab the count
		local RI09_`i'_count = wordcount("`RI09_`i'_list'")

		if inlist(`RI09_`i'_count',1,2) {
			local RI09_`i'_list = subinstr("`RI09_`i'_list'"," "," and ",.)
			local exitflag 1
			noi di as error "If providing the interview date components the dataset must include all 3 variables: RI09``i''m, RI09``i''d, and RI09``i''y. Dataset only has: `RI09_`i'_list'."
			vcqi_log_comment $VCP 1 Error "If providing the interview date components the dataset must include all 3 variables: RI09``i''m, RI09``i''d, and RI09``i''y. Dataset only has: `RI09_`i'_list'."
		} 
	}

	* Create a local to show variable options provided
	local RI09_1 = `RI09' 							// Single interview date
	local RI09_2 = `RI09m' + `RI09d' + `RI09y'		// Interview date components without underscore
	local RI09_3 = `RI09_m' + `RI09_d' + `RI09_y'	// Interview date components with underscore
					
	* Grab the count of how many interview dates provided
	local RI09_count = 0
	forvalues i = 1/3 {
		if `RI09_`i''== 0	local ++RI09_count    
	}

	* Create a local with the list of variables reviewed
	local interview_variables
	if `RI09_1' == 0 local interview_variables variable RI09
	if `RI09_2' == 0 local interview_variables `interview_variables' and variables RI09m/RI09d/RI09y	
	if `RI09_3' == 0 local interview_variables `interview_variables' and variables RI09_m/RI09_d/RI09_y

	if "`=word("`interview_variables'",1)'" == "and" local interview_variables = substr("`interview_variables'",5,.)

	* If more than 1 interview date is present we need to confirm they all match
	local interview_date_mismatch 0
	if `RI09_count' == 3 {
		capture assert month(RI09) == RI09m & RI09m == RI09_m
		if _rc != 0 local interview_date_mismatch 1
		capture assert day(RI09) == RI09d & RI09d == RI09_d
		if _rc != 0 local interview_date_mismatch 1
		capture assert year(RI09) == RI09y & RI09y == RI09_y
		if _rc != 0 local interview_date_mismatch 1
		if `interview_date_mismatch' == 1 {
			local exitflag 1
			noi di as error ///
			"The 3 different interview dates provided in variable RI09, variables RI09m/RI09d/RI09y and variables RI09_m/RI09_d/_RI09_y do not match. Either provide a single interview date or correct values."
			vcqi_log_comment $VCP 1 Error ///
			"The 3 different interview dates provided in variable RI09, variables RI09m/RI09d/RI09y and variables RI09_m/RI09_d/_RI09_y do not match. Either provide a single interview date or correct values."
			
		}
	}

	if `RI09_count' == 2 & `RI09_1' + `RI09_2' == 0 {
		capture assert month(RI09) == RI09m
		if _rc != 0 local interview_date_mismatch 1
		capture assert day(RI09) == RI09d
		if _rc != 0 local interview_date_mismatch 1
		capture assert year(RI09) == RI09y
		if _rc != 0 local interview_date_mismatch 1
		if `interview_date_mismatch' == 1 {
			local exitflag 1
			noi di as error "The 2 different interview dates provided in variable RI09 and variables RI09m/RI09d/RI09y do not match. Either provide a single interview date or correct values."
			vcqi_log_comment $VCP 1 Error "The 2 different interview dates provided in variable RI09 and variables RI09m/RI09d/RI09y do not match. Either provide a single interview date or correct values."

		}	
	}

	if `RI09_count' == 2 & `RI09_1' + `RI09_3' == 0 {
		capture assert month(RI09) == RI09_m
		if _rc != 0 local interview_date_mismatch 1
		capture assert day(RI09) == RI09_d
		if _rc != 0 local interview_date_mismatch 1
		capture assert year(RI09) == RI09_y
		if _rc != 0 local interview_date_mismatch 1
		if `interview_date_mismatch' == 1 {
			local exitflag 1
			noi di as error "The 2 different interview dates provided in variable RI09 and variables RI09_m/RI09_d/RI09_y do not match. Either provide a single interview date or correct values."
			vcqi_log_comment $VCP 1 Error "The 2 different interview dates provided in variable RI09 and variables RI09_m/RI09_d/RI09_y do not match. Either provide a single interview date or correct values."
		}	
	}

	if `RI09_count' == 2 & `RI09_2' + `RI09_3' == 0 {
		capture assert RI09m == RI09_m
		if _rc != 0 local interview_date_mismatch 1
		capture assert RI09d == RI09_d
		if _rc != 0 local interview_date_mismatch 1
		capture assert RI09y == RI09_y
		if _rc != 0 local interview_date_mismatch 1
		if `interview_date_mismatch' == 1 {
			local exitflag 1
			noi di as error "The 2 different interview dates provided in variables RI09m/RI09d/RI09y and variables RI09_m/RI09_d/RI09_y do not match. Either provide a single interview date or correct values."
			vcqi_log_comment $VCP 1 Error ///
			"The 2 different interview dates provided in variables RI09m/RI09d/RI09y and variables RI09_m/RI09_d/RI09_y do not match. Either provide a single interview date or correct values."

		}	
	}
	
	* Interview date is required, if not provided send error to screen and set exitflag
	if `RI09_count' == 0 {
		local exitflag 1
		noi di as error "Interview date is a required variable to run VCQI RI analysis. Add variables RI09_m, RI09_d and RI09_y to your dataset."
		vcqi_log_comment $VCP 1 Error "Interview date is a required variable to run VCQI RI analysis. Add variables RI09_m, RI09_d and RI09_y to your dataset."

	}
	
	* Pass through the exitflag local to the rest of check_RI_analysis_metadata program
	c_local exitflag `exitflag'

	* If  all dates match or a single interview date is provided we want to make sure the variable VCQI uses is populated
	local changed_interview_date_varname 0
	if `interview_date_mismatch' == 0 & inlist(`RI09_2_count',0,3) & inlist(`RI09_3_count',0,3) & `RI09_count' > 0 {
		if `RI09_count' > 1 {
			noi di as text "The `RI09_count' different interview dates provided in `interview_variables' all match"
			vcqi_log_comment $VCP 3 Comment "The `RI09_count' different interview dates provided in `interview_variables' all match"
		}
		
		* If the user is not just running a check we will want to rename variables if RI09_m, RI09_d and RI09_y not provided
		if "$VCQI_CHECK_INSTEAD_OF_RUN" != "1"  {	
			* If only one set of Interview date components was provided
			* Make sure they are the ones with the underscore
			if `RI09_2' == 0 & `RI09_3' != 0 {
				local changed_interview_date_varname 1
				* rename these variables to include the underscore
				foreach m in m d y {
					noi di as text "Variable RI09`m' was renamed RI09_`m' for VCQI consistency."
					vcqi_log_comment $VCP 2 Warning "Variable RI09`m' was renamed RI09_`m' for VCQI consistency."
					rename RI09`m' RI09_`m'
				}
				local RI09_3 0
				local RI09_2 111
			}

			* If a single interview date variable was provided and variables without underscore were not
			* we want to break apart the RI09 into date components
			if `RI09_1' == 0 & `RI09_3' != 0 {
				local changed_interview_date_varname 1
				noi di as text "Breaking variable RI09 into three separate date component variables: RI09_m, RI09_d and RI09_y"
				vcqi_log_comment $VCP 3 Comment "Breaking variable RI09 into three separate date component variables: RI09_m, RI09_d and RI09_y"
				gen RI09_m = month(RI09)	
				label var RI09_m "Month of interview taken from variable RI09"
				gen RI09_d = day(RI09)
				label var RI09_d "Day or interview taken from variable RI09"
				gen RI09_y = year(RI09)
				label var RI09_y "Year of interview taken from variable RI09"
				local RI09_3 0
				local RI09_1 111
			}
		}

		* Save as a new file name to preserve the original version of the dataset if changes made to variables
		* And point the VCQI_RI_DATASET global to new dataset
		if `changed_interview_date_varname' == 1 {
			di as text "Dataset with interview date changes saved as ${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}_preclean"
			vcqi_log_comment $VCP 3 Comment "Dataset with interview date changes saved as ${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}_preclean"
			save "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}_preclean", replace
			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS ${VCQI_RI_DATASET}_preclean
			vcqi_global VCQI_RI_DATASET ${VCQI_RI_DATASET}_preclean
			
			
		}
	}
end
***********************************************************************************************************************************************
***********************************************************************************************************************************************
