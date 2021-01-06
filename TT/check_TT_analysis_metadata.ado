*! check_TT_analysis_metadata version 1.08 - Biostat Global Consulting - 2020-01-20
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Added code for 3 new globals:
*											DELETE_VCQI_DATABASES_AT_END
*											DELETE_TEMP_VCQI_DATASETS
*											SAVE_VCQI_GPH_FILES
* 2016-03-07	1.02	Dale Rhoda		Call generic checking program
* 2017-06-07	1.03	MK Trimner		Added checks for required variables
* 2017-07-05	1.04	MK Trimner		Moved generic check_analysis_metadata program to the top of this program
* 2017-07-18	1.05	MK Trimner		Added variable checks within check if dataset is set and exists
*										Changed language in TT/TTHC dataset check error message.
* 2017-08-26	1.06	Mary Prier		Added version 14.1 line
* 2019-03-19	1.07	Mary Prier		Removed variable TT11 from first foreach loop;
*										 Added if !="TTHC14" to check numeric
* 2020-01-20	1.08	Dale Rhoda		Made check_VCQI_CM_metadata its own program
*******************************************************************************

program define check_TT_analysis_metadata
	version 14.1
	
	local oldvcp $VCP
	global VCP check_TT_analysis_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	* Check the generic analysis-related globals
	check_analysis_metadata
	
	* Check the CM dataset
	check_VCQI_CM_metadata
	
	if "$VCQI_TT_DATASET" == "" {
		di as error "Please set VCQI_TT_DATASET."
		vcqi_log_comment $VCP 1 Error "Please set VCQI_TT_DATASET."
		local exitflag 1
	}	
	
	* Check that TT dataset exists
	
	vcqi_log_global VCQI_DATA_FOLDER
	vcqi_log_global VCQI_TT_DATASET
	vcqi_log_global VCQI_TTHC_DATASET
	
	else if "$VCQI_TT_DATASET" != "" {
	
		capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_TT_DATASET}.dta"
		if _rc != 0 {
			local exitflag 1 
			di as error ///
				"The file ${VCQI_DATA_FOLDER}/${VCQI_TT_DATASET} does not exist"
		}
		
		else {
			use "${VCQI_DATA_FOLDER}/${VCQI_TT_DATASET}", clear
			
			foreach v in TT01 TT03 TT12 TT16 TT27 TT30 TT31 TT32 TT33 TT34 TT35 TT36 TT37 TT38 TT39 TT40 TT41 TT42 {
				capture confirm variable `v' 
				if _rc==0 {
					* If the variable exists, confirm the variable is not missing and has the correct variable type
					if "`v'" != "TT11" {
						capture confirm numeric variable `v'
						if _rc!=0 {
							di as error "`v' needs to be a numeric variable in TT dataset."
							vcqi_global VCQI_ERROR 1
							vcqi_log_comment $VCP 1 Error "`v' needs to be a numeric variable in TT dataset."
							local exitflag 1
						}
					}
					
					capture assert !missing(`v') if inlist("`v'", "TT01", "TT03", "TT11", "TT12") 
					if _rc!=0 {
						di as error "`v' cannot have a missing value in the TT dataset."
						vcqi_global VCQI_ERROR 1
						vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the TT dataset."
						local exitflag 1
					}
				}

				else {
					di as error "Variable `v' does not exist in TT dataset and is required to run VCQI."
					vcqi_global VCQI_ERROR 1
					vcqi_log_comment $VCP 1 Error "Variable `v' does not exist in TT dataset and is required to run VCQI."
					local exitflag 1
				}
			}
		}
	}
	* If we are using TTHC records, check that the dataset exists
	if "$TT_RECORDS_SOUGHT_FOR_ALL" == "1" | "$TT_RECORDS_SOUGHT_IF_NO_CARD" == "1" {
		if "${VCQI_TTHC_DATASET}"=="" {
			di as error "Please set VCQI_TTHC_DATASET."
			vcqi_log_comment $VCP 1 Error "Please set VCQI_TTHC_DATASET."
			local exitflag 1
		}
		else {
			capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_TTHC_DATASET}.dta"
			if _rc != 0 {
				local exitflag 1 
				di as error ///
					"The file ${VCQI_DATA_FOLDER}/${VCQI_TTHC_DATASET}.dta does not exist"
			}
			else {
				use "${VCQI_DATA_FOLDER}/${VCQI_TTHC_DATASET}", clear
				
				foreach v in TTHC01 TTHC03 TTHC14 TTHC15 TTHC21 TTHC22 TTHC23 TTHC24 TTHC25 TTHC26 {
					capture confirm variable `v' 
					if _rc==0 {
						* If the variable exists, confirm the variable is not missing and has the correct variable type
						if "`v'" != "TTHC14" {
							capture confirm numeric variable `v'
							if _rc!=0 {
								di as error "`v' needs to be a numeric variable in TTHC dataset."
								vcqi_global VCQI_ERROR 1
								vcqi_log_comment $VCP 1 Error "`v' needs to be a numeric variable in TTHC dataset."
								local exitflag 1
							}
						}
						capture assert !missing(`v') if inlist("`v'", "TTHC01", "TTHC03", "TTHC14", "TTHC15") 
						if _rc!=0 {
							di as error "`v' cannot have a missing value in the TTHC dataset."
							vcqi_global VCQI_ERROR 1
							vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the TTHC dataset."
							local exitflag 1
						}
					}

					else {
						di as error "Variable `v' does not exist in TTHC dataset and is required to run VCQI."
						vcqi_global VCQI_ERROR 1
						vcqi_log_comment $VCP 1 Error "Variable `v' does not exist in TTHC dataset and is required to run VCQI."
						local exitflag 1
					}
				}
			}
		}
	}

	if "`exitflag'" == "1" {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	


	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
