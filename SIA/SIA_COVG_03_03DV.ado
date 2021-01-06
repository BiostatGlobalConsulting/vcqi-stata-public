*! SIA_COVG_03_03DV version 1.07 - Biostat Global Consulting - 2019-08-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Add var label to lifetime_mcv_doses: 
* 2016-01-18	1.02	Dale Rhoda		Switched to vcqi_global
* 2017-02-13	1.03	Dale Rhoda		use int(HM29)
* 2017-03-07	1.04	Dale Rhoda		Fixed a typo in a comment
* 2017-08-26	1.05	Mary Prier		Added version 14.1 line
* 2018-04-26	1.06	Dale Rhoda		Added indicators for lifetime doses
*										regardless of age
* 2019-08-23	1.07	Dale Rhoda		Make outcomes missing if psweight == 0 | missing(psweight)
*******************************************************************************

program define SIA_COVG_03_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_03_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_03_${ANALYSIS_COUNTER}", clear
		
		gen lifetime_mcv_doses = 0
		replace lifetime_mcv_doses = lifetime_mcv_doses + 1 if inlist(SIA20,1,2)
		replace lifetime_mcv_doses = lifetime_mcv_doses + 1 if !missing(SIA28) | SIA29 == 1
		replace lifetime_mcv_doses = lifetime_mcv_doses + 1 if !missing(SIA30) | SIA31 == 1
		replace lifetime_mcv_doses = lifetime_mcv_doses + 1 if !missing(SIA32)
		replace lifetime_mcv_doses = lifetime_mcv_doses + 1 if !missing(SIA33)
		replace lifetime_mcv_doses = lifetime_mcv_doses + 1 if SIA27 == 1 & ///
				missing(SIA28) & missing(SIA29) & missing(SIA30) & ///
				missing(SIA31) & missing(SIA32) & missing(SIA33)
		label variable lifetime_mcv_doses "Number of lifetime mcv doses"
		
		* Variables to cover all ages
		
		gen lifetime_mcv_0 = lifetime_mcv_doses == 0 
		gen lifetime_mcv_1 = lifetime_mcv_doses == 1 
		gen lifetime_mcv_2 = lifetime_mcv_doses >= 2 
		
		label variable lifetime_mcv_0 "Lifetime MCV doses is 0"
		label variable lifetime_mcv_1 "Lifetime MCV doses is 1"
		label variable lifetime_mcv_2 "Lifetime MCV doses is 2+"
		
		* Lifetime doses by age cohort
		
		vcqi_global MIN_SIA_YEARS = int(${SIA_MIN_AGE}/365.25)
		vcqi_global MAX_SIA_YEARS = int(${SIA_MAX_AGE}/365.25)
		
		forvalues i = $MIN_SIA_YEARS/$MAX_SIA_YEARS {
			gen lifetime_mcv_0_`i' = lifetime_mcv_doses == 0 if int(HM29) == `i'
			gen lifetime_mcv_1_`i' = lifetime_mcv_doses == 1 if int(HM29) == `i'
			gen lifetime_mcv_2_`i' = lifetime_mcv_doses >= 2 if int(HM29) == `i'
			
			label variable lifetime_mcv_0_`i' "Age is `i' and lifetime MCV doses is 0"
			label variable lifetime_mcv_1_`i' "Age is `i' and lifetime MCV doses is 1"
			label variable lifetime_mcv_2_`i' "Age is `i' and lifetime MCV doses is 2+"
		}
		
		* Set outcomes to missing if weight is missing or zero
		foreach v of varlist lifetime_mcv_* {
			replace `v' = . if psweight == 0 | missing(psweight)
		}
		
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
