*! SIA_COVG_03_03DV version 1.08 - Biostat Global Consulting - 2021-01-13
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
* 2021-01-13	1.08	Dale Rhoda      Update logic for lifetime_mcv_doses
*                                       to allow possibility of _m or _d or _y
*                                       on SIA32 and 33
*******************************************************************************

program define SIA_COVG_03_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_03_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_03_${ANALYSIS_COUNTER}", clear

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
		
		gen num_previous_doses = received_ri_1st_dose  + ///
								 received_ri_2nd_dose  + ///
								 received_sia_1st_dose + ///
								 received_sia_2nd_dose
								 
		label variable received_ri_1st_dose  "SIA28 or 29 have evidence of 1st RI dose"
		label variable received_ri_2nd_dose  "SIA30 or 31 have evidence of 2nd RI dose"
		label variable received_sia_1st_dose "SIA32 has evidence of 1st prior SIA dose"
		label variable received_sia_2nd_dose "SIA33 has evidence of 2nd prior SIA dose"
		label variable num_previous_doses    "Number of previous doses of campaign vaccine"		
				
		gen lifetime_mcv_doses = num_previous_doses + inlist(SIA20,1,2)

		label variable lifetime_mcv_doses "Number of lifetime MCV doses"
		
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
