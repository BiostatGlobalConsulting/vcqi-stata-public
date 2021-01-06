*! SIA_COVG_04_02DQ version 1.01 - Biostat Global Consulting - 2019-01-10
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
		
		forvalues i = 27/33 {
			capture confirm var SIA`i'
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
		
		local n 1
		foreach i in 28 30 {
			
			* First check to see if both the SIA date and SIA tick variables exist
			capture confirm var SIA`i' SIA`=`i'+1'
			
			* If yes, we can increment dosecount with a single line of code
			if _rc == 0 {
				qui count if !missing(SIA`i') | SIA`=`i'+1'==1
				if r(N) > 0 local ++prior_questions
			}
			else {
				* Otherwise we need two lines of code, protected by the capture command 
				qui count if !missing(SIA`i')
				if r(N) > 0  local ++prior_questions
				
				qui count if SIA`=`i'+1'==1 
				if r(N) > 0  local ++prior_questions
			}
			local ++n
		}

		* Increment prior dosecount if prior SIA records indicate they got it
		forvalues i = 32/33 {
			qui count if !missing(SIA`i') & SIA`i' > 0
			if r(N) > 0  local ++prior_questions
			local ++n
		}
	
		if "$PRIOR_SIA_DOSE_MAX"=="SINGLE" & `prior_questions' > 1 {
			vcqi_log_comment $VCP 2 Warning "SIA_COVG_04: Global macro PRIOR_SIA_DOSE_MAX is set to SINGLE, but dataset shows evidence of more than 1 opportunity for prior dose. All respondents who received 1+ prior doses before campaign will be grouped together in output."
			di as error "SIA_COVG_04: Global macro PRIOR_SIA_DOSE_MAX is set to SINGLE, but dataset shows evidence of more than 1 opportunity for prior dose. All respondents who received 1+ prior doses before campaign will be grouped together in output."
		}

	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
