*! check_RI_analysis_metadata version 1.06 - Biostat Global Consulting - 2017-01-31
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
*******************************************************************************

program define check_RI_analysis_metadata

	local oldvcp $VCP
	global VCP check_RI_analysis_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
	
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
	
	* If we are using RIHC records, check that the dataset exists
	if "$RI_RECORDS_SOUGHT_FOR_ALL" == "1" | "$RI_RECORDS_SOUGHT_IF_NO_CARD" == "1" {
		capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}.dta"
		if _rc != 0 {
			local exitflag 1 
			di as error ///
				"The file defined by global macros VCQI_DATA_FOLDER/VCQI_RIHC_DATASET (${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}.dta) does not exist"
			vcqi_log_comment $VCP 1 Error "RI dataset: ${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}.dta does not exist"
		}
	}
	
	* Default is to NOT calculate report on data quality; user can turn it on
	if "$VCQI_REPORT_DATA_QUALITY" == "" 	vcqi_global VCQI_REPORT_DATA_QUALITY 0

	if "`exitflag'" == "1" {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	* Check the generic analysis-related globals
	
	check_analysis_metadata

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
