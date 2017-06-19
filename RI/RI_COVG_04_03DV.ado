*! RI_COVG_04_03DV version 1.01 - Biostat Global Consulting - 2017-01-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-07	1.01	Dale Rhoda		Skip valid dose tables if no respondent
*										has DOB data
*******************************************************************************
program define RI_COVG_04_03DV

	local oldvcp $VCP
	global VCP RI_COVG_04_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}", clear
		
		gen not_vaccinated_crude = fv_count_crude == 0
		label variable not_vaccinated_crude "Not Vaccinated - crude"
		
		* Skip valid dose calculations if no respondent had DOB data

		if "$VCQI_NO_DOBS" != "1" {
		
			gen not_vaccinated_valid = fv_count_valid == 0
			label variable not_vaccinated_valid "Not Vaccinated - valid"

			gen not_vaccinated_by_age1 = fvb1_count == 0
			label variable not_vaccinated_by_age1 "No Valid Doses from Fully Vaccinated List by Age 1"
		}

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

