*! SIA_COVG_03_03DV version 1.04 - Biostat Global Consulting - 2017-03-07
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Add var label to lifetime_mcv_doses: 
* 2016-01-18	1.02	Dale Rhoda		Switched to vcqi_global
* 2017-02-13	1.03	Dale Rhoda		use int(HM29)
* 2017-03-07	1.04	Dale Rhoda		Fixed a typo in a comment
*******************************************************************************

program define SIA_COVG_03_03DV

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
		
		* Note: This measure assumes observations where SIA17 != 1 have been removed
		*       or their weights have been set to zero
		
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

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
