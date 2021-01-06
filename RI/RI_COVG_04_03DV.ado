*! RI_COVG_04_03DV version 1.03 - Biostat Global Consulting - 2019-07-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-07	1.01	Dale Rhoda		Skip valid dose tables if no respondent
*										has DOB data
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2019-07-17	1.03	Dale Rhoda		Set outcome to . if psweight == 0
*******************************************************************************

program define RI_COVG_04_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_04_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}", clear
		
		gen not_vaccinated_crude = fv_count_crude == 0 if psweight != 0 & !missing(psweight)
		label variable not_vaccinated_crude "Not Vaccinated - crude"
		
		* Skip valid dose calculations if no respondent had DOB data

		if "$VCQI_NO_DOBS" != "1" {
		
			gen not_vaccinated_valid = fv_count_valid == 0 if psweight != 0 & !missing(psweight)
			label variable not_vaccinated_valid "Not Vaccinated - valid"

			gen not_vaccinated_by_age1 = fvb1_count == 0 if psweight != 0 & !missing(psweight)
			label variable not_vaccinated_by_age1 "No Valid Doses from Fully Vaccinated List by Age 1"
		}

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

