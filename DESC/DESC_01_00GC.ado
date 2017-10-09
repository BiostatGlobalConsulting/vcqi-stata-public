*! DESC_01_00GC version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define DESC_01_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_01_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	vcqi_log_global DESC_01_DROPOUT_LIST
	vcqi_log_global RI_DOSE_LIST

	local exitflag 0
	
	*Confirm global DESC_01_DATASET is set to RI, SIA or TT
		*Confirm DESC_01_DATASET is a valid dataset type and defined
	if !inlist("`=upper("$DESC_01_DATASET")'","RI","SIA", "TT") {
		di as error "DESC_01_DATASET must be RI, SIA or TT.  The current value is $DESC_01_DATASET."
		vcqi_log_comment $VCP 1 Error "DESC_01_DATASET must be RI, SIA or TT.  The current value is $DESC_01_DATASET."
		local exitflag 1
	}
		
	*If RI dataset is used global VCQI_RI_DATASET must be set
	if "`=upper("$DESC_01_DATASET")'"=="RI" {
		if "$VCQI_RI_DATASET"=="" {
			di as error "VCQI_RI_DATASET must be defined"
			vcqi_log_comment $VCP 1 Error "VCQI_RI_DATASET must be defined"
			local exitflag 1
		}
	}
	
	*Confirm selected dataset exists
	capture confirm file "${VCQI_OUTPUT_FOLDER}/${DESC_01_DATASET}_with_ids.dta" 
	if _rc!=0 {
		di as error ///
		"${VCQI_OUTPUT_FOLDER}/${DESC_01_DATASET}_with_ids.dta does not exist. Run establish_unique_${DESC_01_DATASET}_ids"
		vcqi_log_comment $VCP 1 Error "Dataset does not exist to run this measurement"
		local exitflag 1
		}
		
	*Confirm the below globals are set and files exist
	foreach g in VCQI_CM_DATASET VCQI_HM_DATASET VCQI_HH_DATASET {
		if "${`g'}"=="" {
			di as error "`g' must be defined"
			vcqi_log_comment $VCP 1 Error "`g' must be defined"
			local exitflag 1
		}
		if "${`g'}"!="" {
		capture confirm file "${VCQI_DATA_FOLDER}/${`g'}.dta" 
			if _rc!=0 {
				di as error "${`g'}.dta does not exist."
				vcqi_log_comment $VCP 1 Error "${`g'}.dta does not exist."
				local exitflag 1
			}
		}
	}
	
	*Confirm global ANALYSIS_COUNTER is set to appropriate values
	if "$ANALYSIS_COUNTER"=="" {
		di as error "Global ANALYSIS_COUNTER must be defined."
		vcqi_log_comment $VCP 1 Error "Global ANALYSIS_COUNTER must be defined."
		local exitflag 1
	}


	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
