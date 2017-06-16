*! check_SIA_analysis_metadata version 1.02 - Biostat Global Consulting - 2016-03-07
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
*******************************************************************************
program define check_SIA_analysis_metadata

	local oldvcp $VCP
	global VCP check_SIA_analysis_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	
	if "$VCQI_SIA_DATASET" == "" {
		di as error "Please set VCQI_SIA_DATASET."
		vcqi_log_comment $VCP 1 Error "Please set VCQI_SIA_DATASET."
		local exitflag 1
	}	
	
	* Check that SIA dataset exists
	
	vcqi_log_global VCQI_DATA_FOLDER
	vcqi_log_global VCQI_SIA_DATASET
	
	capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_SIA_DATASET}.dta"
	if _rc != 0 {
		local exitflag 1 
		di as error ///
			"The file defined by global macros VCQI_DATA_FOLDER/VCQI_SIA_DATASET.dta does not exist"
		vcqi_log_comment $VCP 1 Error "The file defined by global macros VCQI_DATA_FOLDER/VCQI_SIA_DATASET.dta does not exist"
	}
	
	if "`exitflag'" == "1" {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	* Check the generic analysis-related globals
	
	check_analysis_metadata

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
