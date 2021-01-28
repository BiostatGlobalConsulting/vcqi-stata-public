*! check_VCQI_CM_metadata version 1.01 - Biostat Global Consulting - 2020-12-16
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-01-20	1.0		Dale Rhoda		Original version extracted from 
*										check_analysis_metadata.ado
* 2020-12-16	1.01	MK Trimner		Added code to generate province_id and urban_cluster
*										as missing if not provided in CM dataset
*										replaced *! (NAME) with correct program name check_VCQI_CM_metadata
*
*******************************************************************************

program define check_VCQI_CM_metadata
	version 14.1

	local oldvcp $VCP
	global VCP check_VCQI_CM_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {

		local exitflag 0	
		
		if "${VCQI_CM_DATASET}" == "" {
			di as error "Please set VCQI_CM_DATASET."
			vcqi_log_comment $VCP 1 Error "Please set VCQI_CM_DATASET"
			local exitflag 1
		}	
		else {

			if  "${VCQI_DATA_FOLDER}" != "" {					
				capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}.dta"
				if _rc==0 {
					use "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", clear

					* Determine which psweight is required
					if "${VCQI_RI_DATASET}" != "" | "${VCQI_TT_DATASET}" != ""  {
						local psw psweight_1year
					}
					else {
						if "${VCQI_SIA_DATASET}" != "" {
							local pws psweight_sia
						}
					}
					
					* Begin check
					foreach v in HH01 HH02 HH04 `psw' province_id urban_cluster {
						capture confirm variable `v' 

						* If the variable exists, confirm the variable is not missing and has the correct variable type
						if _rc==0 {

							local i numeric

							* all variables should be numeric except HH02 and HH04
							if inlist("`v'", "HH02", "HH04") {
								local i string
							}

							capture confirm `i' variable `v'
							if _rc!=0 {
								di as error "`v' should be a `i' variable in CM dataset."
								vcqi_log_comment $VCP 2 Warning "`v' should be a `i' variable in CM dataset."
							}

							if !inlist("`v'", "province_id", "urban_cluster") {
								capture assert !missing(`v')
								if _rc!=0 {
									di as error "`v' should not have a missing value in the CM dataset."
									vcqi_log_comment $VCP 2 Warning "`v' should not have a missing value in the CM dataset."
								}
							}

						}
						else {
							if _rc!=0 & inlist("`v'","province_id","urban_cluster") {
								capture gen `v' = .
								label var `v' "`v' - Created as missing to run VCQI"
								di as error "Variable `v' does not exist in CM dataset. It has been created as a missing variable to run VCQI."
								vcqi_log_comment $VCP 2 Warning "Variable `v' does not exist in CM dataset. It has been created as a missing variable to run VCQI."
								
							}
							if _rc!=0 & !inlist("`v'","province_id","urban_cluster"){
								di as error "Variable `v' does not exist in CM dataset and is required to run VCQI."
								vcqi_log_comment $VCP 1 Error "Variable `v' does not exist in CM dataset and is required to run VCQI."
								local exitflag 1
							}
						}
					}
				}
				else {
					if _rc!=0  {
						di as error "The file defined by global macros ${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET} does not exist." 
						vcqi_log_comment $VCP 1 Error  "The file defined by global macros ${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET} does not exist." 
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
