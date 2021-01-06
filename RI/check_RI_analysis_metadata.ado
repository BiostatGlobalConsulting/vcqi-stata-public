*! check_RI_analysis_metadata version 1.12 - Biostat Global Consulting - 2020-12-09
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
		if _rc != 0 {
			local exitflag 1 
			di as error ///
				"The file defined by global macros VCQI_DATA_FOLDER/VCQI_RI_DATASET (${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}.dta) does not exist"
			vcqi_log_comment $VCP 1 Error "RI dataset: ${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}.dta does not exist"

		}
		
		* Check that RI variables used across all indicators are present
		* and have the correct variable type
		else {
			use "${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}", clear
			
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
