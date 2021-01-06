*! RI_COVG_03_03DV version 1.04 - Biostat Global Consulting - 2020-04-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 
* 2017-01-09	1.01	Dale Rhoda		Skip valid dose calculations if none
*										of the respondents have complete DOB
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2019-07-17	1.03	Dale Rhoda		Set outcome to . if psweight == 0
* 2020-04-24	1.04	Dale Rhoda		Calculate fully_vaccinated_for_age_crude
*                                       and fully_vaccinated_for_age_valid
*******************************************************************************

program define RI_COVG_03_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_03_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}", clear
		
		* If no one has DOB, then only do calculations for crude doses
		if "$VCQI_NO_DOBS" != "1" local cv crude valid
		else local cv crude

		foreach v in `cv' {	
			gen fv_count_`v' = 0 if psweight != 0 & !missing(psweight)
			label variable fv_count_`v' "Count of `v' vaccinations from full vaccination list"

			foreach d in `=lower("$RI_DOSES_TO_BE_FULLY_VACCINATED")' {
				replace fv_count_`v'=fv_count_`v' + 1 if got_`v'_`d'_to_analyze==1

			}
		}
		
		foreach v in `cv' {
			gen fully_vaccinated_`v'=fv_count_`v'==`=wordcount("$RI_DOSES_TO_BE_FULLY_VACCINATED")' if psweight != 0 & !missing(psweight)
			label variable fully_vaccinated_`v' "Fully Vaccinated - `v'"
		}

		* Do valid dose by age 1 calcs if some respondents have DOB
		if "$VCQI_NO_DOBS" != "1" {

			gen fvb1_count = 0 if psweight != 0 & !missing(psweight)
			foreach d in `=lower("$RI_DOSES_TO_BE_FULLY_VACCINATED")'{
				replace fvb1_count=fvb1_count + 1 if valid_`d'_age1_to_analyze==1
				label variable fvb1_count "Count of valid vaccinations by age 1"
			}
			
			gen fully_vaccinated_by_age1=fvb1_count==`=wordcount("$RI_DOSES_TO_BE_FULLY_VACCINATED")' if psweight != 0 & !missing(psweight)
			label variable fully_vaccinated_by_age1 "Fully Vaccinated with Valid Doses by Age 1"

		}
		
		* Are they fully-vaccinated for their age?
		
		* Doses required for their age
		gen fv_doses_reqd_for_age = 0 
		label variable fv_doses_reqd_for_age       "Number of doses to be fully vaccinated (for their age)"
		
		* Doses received (from the required list)
		gen fv_doses_recd_for_age_crude = 0 
		gen fv_doses_recd_for_age_valid = 0 
		label variable fv_doses_recd_for_age_crude "Number of crude doses received from list needed (for their age)"
		label variable fv_doses_recd_for_age_valid "Number of valid doses received from list needed (for their age)"
		
		foreach d in $RI_DOSES_TO_BE_FULLY_VACCINATED {
			replace fv_doses_reqd_for_age = fv_doses_reqd_for_age + 1 if age_at_interview >= `=lower("`d'")'_min_age_days & !missing(age_at_interview)
			replace fv_doses_recd_for_age_crude = fv_doses_recd_for_age_crude + 1 if got_crude_`=lower("`d'")'_to_analyze == 1
			replace fv_doses_recd_for_age_valid = fv_doses_recd_for_age_valid + 1 if got_valid_`=lower("`d'")'_to_analyze == 1
		}

		gen fully_vaccinated_for_age_crude = (fv_doses_reqd_for_age == fv_doses_recd_for_age_crude) & (fv_doses_reqd_for_age > 0)
		gen fully_vaccinated_for_age_valid = (fv_doses_reqd_for_age == fv_doses_recd_for_age_valid) & (fv_doses_reqd_for_age > 0)
		label variable fully_vaccinated_for_age_crude "Fully Vaccinated with Crude Doses (for their age) "
		label variable fully_vaccinated_for_age_valid "Fully Vaccinated with Valid Doses (for their age) "

		* Set to missing if this child is not eligible for any doses, or we do not know their age at interview
		replace fully_vaccinated_for_age_crude = . if psweight == 0 | missing(psweight) | missing(age_at_interview) | fv_doses_reqd_for_age == 0 
		replace fully_vaccinated_for_age_valid = . if psweight == 0 | missing(psweight) | missing(age_at_interview) | fv_doses_reqd_for_age == 0 

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

