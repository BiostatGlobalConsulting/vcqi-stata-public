*! RI_COVG_03_03DV version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 
* 2017-01-09	1.01	Dale Rhoda		Skip valid dose calculations if none
*										of the respondents have complete DOB
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
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
			gen fv_count_`v'=0
			label variable fv_count_`v' "Count of `v' vaccinations from full vaccination list"

			foreach d in `=lower("$RI_DOSES_TO_BE_FULLY_VACCINATED")' {
				replace fv_count_`v'=fv_count_`v' + 1 if got_`v'_`d'_to_analyze==1

			}
		}
		
		foreach v in `cv' {
			gen fully_vaccinated_`v'=fv_count_`v'==`=wordcount("$RI_DOSES_TO_BE_FULLY_VACCINATED")'
			label variable fully_vaccinated_`v' "Fully Vaccinated - `v'"
		}

		* Do valid dose by age 1 calcs if some respondents have DOB
		if "$VCQI_NO_DOBS" != "1" {

			gen fvb1_count=0
			foreach d in `=lower("$RI_DOSES_TO_BE_FULLY_VACCINATED")'{
				replace fvb1_count=fvb1_count + 1 if valid_`d'_age1_to_analyze==1
				label variable fvb1_count "Count of valid vaccinations by age 1"
			}
			
			gen fully_vaccinated_by_age1=fvb1_count==`=wordcount("$RI_DOSES_TO_BE_FULLY_VACCINATED")'
			label variable fully_vaccinated_by_age1 "Fully Vaccinated with Valid Doses by Age 1"

		}
		
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

