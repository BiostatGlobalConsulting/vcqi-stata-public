*! check_SIA_analysis_metadata version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Added code for 3 new globals:
*											DELETE_VCQI_DATABASES_AT_END
*											DELETE_TEMP_VCQI_DATASETS
*											SAVE_VCQI_GPH_FILES
* 2016-03-07	1.02	Dale Rhoda		Set VCQI_ERROR before calling halt
* 										Send error messages to the log file
* 2017-06-07	1.03	MK Trimner		Added checks for SIA variables
* 2017-07-05	1.03	MK Trimner		Moved generic check analysis program to the top
* 										Added local exitflag 0 under it
* 2017-07-18	1.03	MK Trimner		Added variable checks within check loop to see 
*										if global set and dataset exists
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define check_SIA_analysis_metadata
	version 14.1
	
	local oldvcp $VCP
	global VCP check_SIA_analysis_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	* Check the generic analysis-related globals
	check_analysis_metadata


	if "$VCQI_SIA_DATASET" == "" {
		di as error "Please set VCQI_SIA_DATASET."
		vcqi_log_comment $VCP 1 Error "Please set VCQI_SIA_DATASET."
		local exitflag 1
	}	
	
	* Check that SIA dataset exists
	
	vcqi_log_global VCQI_DATA_FOLDER
	vcqi_log_global VCQI_SIA_DATASET
	
	else if "$VCQI_SIA_DATASET" != "" {
		capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_SIA_DATASET}.dta"
		if _rc != 0 {
			local exitflag 1 
			di as error ///
				"The file defined by global macros VCQI_DATA_FOLDER/VCQI_SIA_DATASET.dta does not exist"
			vcqi_log_comment $VCP 1 Error "The file defined by global macros VCQI_DATA_FOLDER/VCQI_SIA_DATASET.dta does not exist"
		}
		
		* Check that SIA variables used across all Indicators are present
		* and have the correct variable type
		else {
			use "${VCQI_DATA_FOLDER}/${VCQI_SIA_DATASET}", clear
			
			foreach v in SIA01 SIA03 SIA11 SIA12 SIA20  {
				capture confirm variable `v' 
				if _rc==0 {
					* If the variable exists, confirm the variable is not missing and has the correct variable type
					capture confirm numeric variable `v'
					if _rc!=0 & "`v'" != "SIA11" {
						di as error "`v' needs to be a numeric variable in SIA dataset."
						vcqi_global VCQI_ERROR 1
						vcqi_log_comment $VCP 1 Error "`v' needs to be a numeric variable in SIA dataset."
						local exitflag 1
					}
					
					capture assert !missing(`v') if "`v'"!="SIA22" 
					if _rc!=0 {
						di as error "`v' cannot have a missing value in the SIA dataset."
						vcqi_global VCQI_ERROR 1
						vcqi_log_comment $VCP 1 Error "`v' cannot have a missing value in the SIA dataset."
						local exitflag 1
					}
				}

				else {
					di as error "Variable `v' does not exist in SIA dataset and is required to run VCQI."
					vcqi_global VCQI_ERROR 1
					vcqi_log_comment $VCP 1 Error "Variable `v' does not exist in SIA dataset and is required to run VCQI."
					local exitflag 1
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
