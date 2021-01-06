*! SIA_COVG_04_03DV version 1.02 - Biostat Global Consulting - 2019-01-10
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-15	1.00 	MK Trimner		Original version
* 2019-01-09	1.01	MK Trimner 		Added code to allow user to specify
*									    that the questionniare only asks 
* 										about a SINGLE prior dose
* 2019-01-10	1.02	Dale Rhoda		Generate a stratifier named
*										received_prior_doses
*******************************************************************************

program define SIA_COVG_04_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_04_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_04_${ANALYSIS_COUNTER}", clear
			
		* Create value label for new variable
		label define prior 0 "Zero" 1 "1 Dose" 2 "2+ Doses" 98 "Unknown" 99 "Dose Received, But Not Sure How Many" , replace
			
		* Create new variable, add variable and value label
		gen doses_prior_to_sia = 98 // Set all to UNKNOWN to start
			
		label var doses_prior_to_sia "Number of times dose received prior to SIA"
		label value doses_prior_to_sia prior
			
		* To code this variable we will need to look at SIA27, SIA28-SIA33
		* Create variable to show how many doses were received via card using SIA28-SIA33
		gen prior_sia_dosecount = 0

		* Increment prior dosecount if the RI record indicates they received the dose
		foreach i in 28 30 {
			
			* First check to see if both the SIA date and SIA tick variables exist
			capture confirm var SIA`i' SIA`=`i'+1'
			
			* If yes, we can increment dosecount with a single line of code
			if _rc == 0 replace prior_sia_dosecount = prior_sia_dosecount + 1 if !missing(SIA`i') | SIA`=`i'+1'==1
			else {
				* Otherwise we need two lines of code, protected by the capture command 
				capture replace prior_sia_dosecount = prior_sia_dosecount + 1 if !missing(SIA`i') 
				capture replace prior_sia_dosecount = prior_sia_dosecount + 1 if SIA`=`i'+1'==1 
			}
		}

		* Increment prior dosecount if prior SIA records indicate they got it
		forvalues i = 32/33 {
			capture replace prior_sia_dosecount = prior_sia_dosecount + 1 if !missing(SIA`i') & SIA`i' > 0
		}
		
		* Now we will look at the prior_sia_dosecount variable created above and SIA27
		* Here are the values for SIA27
		* 1 - Yes Dates on card
		* 2 - Yes, Recall/History
		* 3 - No
		* 99 - Do Not Know
		
		* Populate the prior_sia_dose variable based on the dosecount and SIA27
		replace doses_prior_to_sia = 2 if prior_sia_dosecount >= 2
		replace doses_prior_to_sia = 1 if prior_sia_dosecount == 1
		
		* Check to see if SIA27 exists as this will change how the next
		* replace statements are coded
		capture confirm var SIA27
		if _rc == 0 {
			replace doses_prior_to_sia = 0  if prior_sia_dosecount == 0 & SIA27 == 3 
			replace doses_prior_to_sia = 99 if prior_sia_dosecount == 0 & SIA27 == 2 // Recall/History - Received but do not know how many
			replace doses_prior_to_sia = 99 if prior_sia_dosecount == 0 & SIA27 == 1 // Says Date on Card but no doses counted

		}
		else replace doses_prior_to_sia = 0 if prior_sia_dosecount == 0 
		
		* If SINGLE specified in global, remove all values greater than 1 that are not 98
		* Set to 1
		if "$PRIOR_SIA_DOSE_MAX"=="SINGLE" {
			replace doses_prior_to_sia = 1 if inlist(doses_prior_to_sia,2,99)
			label define prior 0 "Zero" 1 "1+ Doses" 98 "Unknown", replace
		}
		
		* Finally...generate a yes/no stratifier: do we have evidence that this
		* respondent has received 1+ prior doses?
		gen received_prior_doses = inlist(doses_prior_to_sia,1,2,99)
		replace received_prior_doses = 98 if doses_prior_to_sia == 98
		label variable received_prior_doses "Received SIA dose at least once prior to SIA"
		label define rpd 0 "No" 1 "Yes" 98 "Unsure", replace
		label values received_prior_doses rpd
		
		save, replace
		
		vcqi_global VCQI_TEMP_STRATHOLDER SIA_COVG_04_${ANALYSIS_COUNTER}

	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
