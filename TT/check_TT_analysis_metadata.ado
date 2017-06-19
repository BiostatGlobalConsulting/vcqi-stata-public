*! check_TT_analysis_metadata version 1.02 - Biostat Global Consulting - 2016-03-07
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
*******************************************************************************

program define check_TT_analysis_metadata

	version 14
	local oldvcp $VCP
	global VCP check_TT_analysis_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	if "$VCQI_TT_DATASET" == "" {
		di as error "Please set VCQI_TT_DATASET."
		vcqi_log_comment $VCP 1 Error "Please set VCQI_TT_DATASET."
		local exitflag 1
	}	
	
	* Check that TT dataset exists
	
	vcqi_log_global VCQI_DATA_FOLDER
	vcqi_log_global VCQI_TT_DATASET
	vcqi_log_global VCQI_TTHC_DATASET
	
	capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_TT_DATASET}.dta"
	if _rc != 0 {
		local exitflag 1 
		di as error ///
			"The file defined by global macros VCQI_DATA_FOLDER/VCQI_TT_DATASET.dta does not exist"
	}
	
	* If we are using TTHC records, check that the dataset exists
	if "$TT_RECORDS_SOUGHT_FOR_ALL" == "1" | "$TT_RECORDS_SOUGHT_IF_NO_CARD" == "1" {
		capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_TTHC_DATASET}.dta"
		if _rc != 0 {
			local exitflag 1 
			di as error ///
				"The file defined by global macros VCQI_DATA_FOLDER/VCQI_TTHC_DATASET.dta does not exist"
		}
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
