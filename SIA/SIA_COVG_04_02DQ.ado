*! SIA_COVG_04_02DQ version 1.02 - Biostat Global Consulting - 2021-01-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-26	1.00	MK Trimner		Original
* 2019-01-10	1.01	MK Trimner		Added check to see how many variables provided
*										to show prior doses received.
*										If "$PRIOR_SIA_DOSE_MAX"=="SINGLE" and more than
*										one group of prior doses provided, warning sent to log
* 2021-01-13	1.02	Dale Rhoda		Update logic for assessing how many 
*                                       questions hold evidence of prior doses
*******************************************************************************

program define SIA_COVG_04_02DQ
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_04_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_04_${ANALYSIS_COUNTER}", clear
		
		* Make sure that at least one of the variables exist that is necessary
		* to create the doses_prior_to_sia program
		vcqi_global EXIT_SIA_COVG_04 1
		
		foreach v in SIA28 SIA28_m SIA28_d SIA28_y SIA29 SIA30 SIA30_m SIA30_d SIA30_y SIA31 SIA32 SIA32_m SIA32_d SIA32_y SIA33 SIA33_m SIA33_d SIA33_y {
			capture confirm var `v'
			if _rc ==0 {
				vcqi_global EXIT_SIA_COVG_04 0
			}
		}
		if $EXIT_SIA_COVG_04 == 1 {
			vcqi_log_comment $VCP 2 Warning "SIA_COVG_04: Variables SIA27 thru SIA33 are all missing from dataset. Indicator requires that at least one variable is present."
			di as error "SIA_COVG_04: Variables SIA27 thru SIA33 are all missing from dataset. Indicator requires that at least one variable is present."
		}
		
		* Check to see how many questions used to capture the number of prior doses
		* Create local to show how many doses were received via card using SIA28-SIA33
		local prior_questions 0
		
		gen received_ri_1st_dose = !inlist(SIA28,0,.)
		replace received_ri_1st_dose = 1 if SIA29 == 1
		capture replace received_ri_1st_dose = 1 if !missing(SIA28_m)
		capture replace received_ri_1st_dose = 1 if !missing(SIA28_d)
		capture replace received_ri_1st_dose = 1 if !missing(SIA28_y)
			
		gen received_ri_2nd_dose = !inlist(SIA30,0,.)
		replace received_ri_2nd_dose = 1 if SIA31 == 1
		capture replace received_ri_2nd_dose = 1 if !missing(SIA30_m)
		capture replace received_ri_2nd_dose = 1 if !missing(SIA30_d)
		capture replace received_ri_2nd_dose = 1 if !missing(SIA30_y)
		
		gen received_sia_1st_dose = !inlist(SIA32,0,2,.)
		capture replace received_sia_1st_dose = 1 if !missing(SIA32_m)
		capture replace received_sia_1st_dose = 1 if !missing(SIA32_d)
		capture replace received_sia_1st_dose = 1 if !missing(SIA32_y)	
		
		gen received_sia_2nd_dose = !inlist(SIA33,0,2,.)
		capture replace received_sia_2nd_dose = 1 if !missing(SIA33_m)
		capture replace received_sia_2nd_dose = 1 if !missing(SIA33_d)
		capture replace received_sia_2nd_dose = 1 if !missing(SIA33_y)	
								 
		label variable received_ri_1st_dose  "SIA28 or 29 have evidence of 1st RI dose"
		label variable received_ri_2nd_dose  "SIA30 or 31 have evidence of 2nd RI dose"
		label variable received_sia_1st_dose "SIA32 has evidence of 1st prior SIA dose"
		label variable received_sia_2nd_dose "SIA33 has evidence of 2nd prior SIA dose"
		
		count if received_ri_1st_dose == 1
		if r(N) > 0 local ++prior_questions
		
		count if received_ri_2nd_dose == 1
		if r(N) > 0 local ++prior_questions
		
		count if received_sia_1st_dose == 1
		if r(N) > 0 local ++prior_questions
		
		count if received_sia_2nd_dose == 1
		if r(N) > 0 local ++prior_questions
		
		if "$PRIOR_SIA_DOSE_MAX"=="SINGLE" & `prior_questions' > 1 {
			vcqi_log_comment $VCP 2 Warning "SIA_COVG_04: Global macro PRIOR_SIA_DOSE_MAX is set to SINGLE, but dataset shows evidence of more than 1 opportunity for prior dose. All respondents who received 1+ prior doses before campaign will be grouped together in output."
			di as error "SIA_COVG_04: Global macro PRIOR_SIA_DOSE_MAX is set to SINGLE, but dataset shows evidence of more than 1 opportunity for prior dose. All respondents who received 1+ prior doses before campaign will be grouped together in output."
		}

	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
