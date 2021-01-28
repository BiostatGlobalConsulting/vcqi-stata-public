*! SIA_COVG_02_03DV version 1.03 - Biostat Global Consulting - 2021-01-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2019-08-23	1.02	Dale Rhoda		Make outcomes missing if psweight == 0 | missing(psweight)
* 2021-01-13	1.-3	Dale Rhoda		Update SIA27 if SIA28-33 indicate a 
*                                       previous dose, but SIA27 didn't catch it
*******************************************************************************

program define SIA_COVG_02_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_02_${ANALYSIS_COUNTER}", clear
		
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
		
		* Set aside original SIA27
		clonevar SIA27_original = SIA27
		label variable SIA27_original "SIA27 from the input dataset"
		
		* Update SIA27 if it fails to capture some of the evidence of
		* previous RI or SIA doses
		replace SIA27 = 1 if num_previous_doses > 0
		label variable SIA27 "SIA27 updated with prior RI and SIA evidence"
		
		count if SIA27 != SIA27_original
		if r(N) > 0 vcqi_log_comment $VCP 2 Warning "SIA27 has been updated to reflect the RI or prior-SIA evidence for `=r(N)' respondents."		
	
		gen sia_is_first_measles_dose = inlist(SIA20,1,2) & SIA27 == 3 if psweight>0 & !missing(psweight)
		label variable sia_is_first_measles_dose "SIA Provided Child's First Measles Dose"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
