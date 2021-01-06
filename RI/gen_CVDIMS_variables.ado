*! gen_CVDIMS_variables version 1.04 - Biostat Global Consulting - 2020-09-18
********************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-02-28	1.00	Mary Prier		Original
*
* 2020-03-27	1.01	Mary Prier		Replaced evim_sequence_`vc' to missing
* 										 if it is a string "0" (instead of if
*										 has_card_with_dob_and_dosedate is 0 or .);  
*										 this accounts for respids who don't have  
*										 a card but have register data and their
*										 evim seq should not be wiped out
*
* 2020-04-04	1.02	Mary Prier		Updated sequence to be EVIMS where E is
* 										 # of eligible valid doses & S is  
* 										 # of scheduled doses (goes with MOVs).
* 										 Note, the "old" E is now the new "S", 
* 										 and the new E is based off credit_valid
*									 	 for both valid & crude evims cases and 
*										 may be larger than S as in the PAHO setting;
*
*										Also updated V flag to appear when child rec'd
*										 dose after min interval time but before 
*										 scheduled time (to account for valid doses 
*										 rec'd in PAHO setting)
*
* 2020-04-19	1.03	Mary Prier		Updated sequence to be CVDIMS where C is
*										 is back to # of doses we'd give credit 
*										 (from calc_mov credit vars), D is NEW &
*										 is # doses child got at that visit, & S
*										 is # of doses scheduled for (from calc_mov
*									   	 eligible vars)
*
* 2020-09-18	1.04	Dale Rhoda		Fixed an issue with "V"; it's important
*                                        that they received a valid dose that 
*                                        they would get credit for...not just
*                                        that they received any old dose
*
*                                       Also changed got_`d'1_`vc' to 
*                                       got_`d'1_`valid' in logic for C
*
********************************************************************************
* This program makes a dataset that is 1 row per respondent with 3 variables: 
*   respid, cvdims_sequence_crude & cvdims_sequence_valid

program define gen_CVDIMS_variables
	version 14.1
	
	local oldvcp $VCP
	global VCP gen_CVDIMS_variables
	vcqi_log_comment $VCP 5 Flow "Starting"	
	
	quietly {
	
		* If running VCQI, will need to define $RI_DOSE_LIST_MINUS_VISIT
		if missing("$RI_DOSE_LIST_MINUS_VISIT") {
			global RI_DOSE_LIST_MINUS_VISIT $RI_DOSE_LIST
		}
		
		* Variables from RI_MOV_long_form_data.dta that need to be kept
		local dlist	
		foreach d in $RI_DOSE_LIST {
			local dlist `dlist' elig_`d'_crude elig_`d'_valid got_`d'_crude got_`d'_valid credit_`d'_valid cum_`d'_valid got_`d'_tick
		}	
		
		* Add to the list variables with the prefix of the dose family name (i.e., opv or pcv or bcg)
		global RI_SINGLE_DOSE_LIST_MINUS_VISIT = subinstr("$RI_SINGLE_DOSE_LIST","VISIT","",1)
		foreach d in `=lower("$RI_SINGLE_DOSE_LIST_MINUS_VISIT")' `=lower("$RI_MULTI_2_DOSE_LIST")' `=lower("$RI_MULTI_3_DOSE_LIST")' {
			local dlist `dlist' got_`d'
		}		

		* Merge RI_with_IDs & RI_MOV_long_form_data (used to be RI_MOV_visit_flags_to_merge but that changed in version 1.02)
		* NOTE: RI_MOV_long_form_data.dta is the same as RI_MOV_step07.dta
		use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear
		merge 1:m respid using "${VCQI_OUTPUT_FOLDER}/RI_MOV_long_form_data", keepusing(respid visitdate mov_for_anydose_valid mov_for_anydose_crude `dlist')
		keep if _merge == 1 | _merge == 3
		drop _merge	

		* Generate CVDIMS (C: # doses we'd give credit for; V: Valid; D: # doses child got; I: Invalid; M: MOV; S: # doses child scheduled for (i.e., eligible))
		* NOTE: For C V D I & S, we consider all the doses in the $RI_DOSE_LIST_MINUS_VISIT,
		*       but for M, we only consider doses in $MOV_OUTPUT_DOSE_LIST
		label define yesno01 0 "0: No" 1 "1: Yes"
		foreach vc in valid crude {
			gen C_credit_numdoses_`vc' = 0
			label var C_credit_numdoses_`vc' "Number of doses child would be given credit for a valid dose at this visit"
		
			gen V_validdose_recd_`vc' = "-"  // used to be set numerically to 0
			label var V_validdose_recd_`vc' "Had 1+ valid doses at this visit"
			*label values V_validdose_recd_`vc' yesno01
			
			gen D_numdoses_got_`vc' = 0
			label var D_numdoses_got_`vc' "Number of doses child received at this visit"
			
			gen I_invaliddose_recd_`vc' = "-"  // used to be set numerically to 0
			label var I_invaliddose_recd_`vc' "Had 1+ invalid doses at this visit"
			*label values I_invaliddose_recd_`vc' yesno01

			clonevar M_mov_occurred_`vc'_int = mov_for_anydose_`vc'
			gen M_mov_occurred_`vc' = "-"
			replace M_mov_occurred_`vc' = "M" if M_mov_occurred_`vc'_int==1
			drop M_mov_occurred_`vc'_int
			
			gen S_sched_numdoses_`vc' = 0
			label var S_sched_numdoses_`vc' "Number of doses child was scheduled for at this visit"
			
			* Update C & V & D & I & S
			* NOTE: The "if" statements use both dose name and dose family name (e.g., opv1 & opv),
			*   so break up the loops into single, multi-2 & multi-3
			foreach d in `=lower("$RI_SINGLE_DOSE_LIST_MINUS_VISIT")' {
				replace C_credit_numdoses_`vc' = C_credit_numdoses_`vc' + 1 if credit_`d'_valid==1 & (cum_`d'_valid==0 | got_`d'_valid==1) & got_`d'_tick==0 // Hard code valid bc credit_`d'_crude will always be 1
				replace V_validdose_recd_`vc' = "V" if credit_`d'_valid==1 & got_`d'_valid==1   // Updated 4/4/2020 to account for PAHO setting (dose valid if given after min interval); hard code valid bc credit_`d'_crude is always 1 
				replace D_numdoses_got_`vc' = D_numdoses_got_`vc' + 1 if `d'_card_date==visitdate & `d'_card_date!=.
				replace I_invaliddose_recd_`vc' = "I" if elig_`d'_crude==0 & got_`d'==1  // Hard code elig_`d'_crude==1 bc elig_`d'_valid will never be 1 if dose is early
				replace S_sched_numdoses_`vc' = S_sched_numdoses_`vc' + 1 if elig_`d'_`vc'==1 & got_`d'_tick==0
			}
			
			foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
				* On 2020-09-18 changed got_`d'1_`vc' to `valid' to correct problem with Bolivia 1986 repondent 540 (early DPT1; later visit where they got DPT2 (valid DPT1) was showing 0 for C)
				replace C_credit_numdoses_`vc' = C_credit_numdoses_`vc' + 1 if credit_`d'1_valid==1 & (cum_`d'1_valid==0 | got_`d'1_valid==1) &  got_`d'1_tick==0 // Hard code valid bc credit_`d'_crude will always be 1; 
				replace C_credit_numdoses_`vc' = C_credit_numdoses_`vc' + 1 if credit_`d'2_valid==1 & (cum_`d'2_valid==0 | got_`d'2_valid==1) & (got_`d'1_tick==0 & got_`d'2_tick==0) // Hard code valid bc credit_`d'_crude will always be 1
				
				replace V_validdose_recd_`vc' = "V" if credit_`d'1_valid==1 & got_`d'1_valid==1   // Updated 4/4/2020 to account for PAHO setting (dose valid if given after min interval); hard code valid bc credit_`d'_crude is always 1 
				replace V_validdose_recd_`vc' = "V" if credit_`d'2_valid==1 & got_`d'2_valid==1 & got_`d'1_tick==0  // Updated 4/4/2020 to account for PAHO setting (dose valid if given after min interval); hard code valid bc credit_`d'_crude is always 1 
				replace D_numdoses_got_`vc' = D_numdoses_got_`vc' + 1 if `d'1_card_date==visitdate & `d'1_card_date!=.
				replace D_numdoses_got_`vc' = D_numdoses_got_`vc' + 1 if `d'2_card_date==visitdate & `d'2_card_date!=.
				
				replace I_invaliddose_recd_`vc' = "I" if elig_`d'1_crude==0 & elig_`d'2_crude==0 & got_`d'==1  // hard code elig_`d'_crude==1 bc elig_`d'_valid will never be 1 if dose is early  
				
				replace S_sched_numdoses_`vc' = S_sched_numdoses_`vc' + 1 if elig_`d'1_`vc'==1 &  got_`d'1_tick==0
				replace S_sched_numdoses_`vc' = S_sched_numdoses_`vc' + 1 if elig_`d'2_`vc'==1 & (got_`d'1_tick==0 & got_`d'2_tick==0)
			}
			
			foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
				replace C_credit_numdoses_`vc' = C_credit_numdoses_`vc' + 1 if credit_`d'1_valid==1 & (cum_`d'1_valid==0 | got_`d'1_valid==1) &  got_`d'1_tick==0 // Hard code valid bc credit_`d'_crude will always be 1
				replace C_credit_numdoses_`vc' = C_credit_numdoses_`vc' + 1 if credit_`d'2_valid==1 & (cum_`d'2_valid==0 | got_`d'2_valid==1) & (got_`d'1_tick==0 & got_`d'2_tick==0) // Hard code valid bc credit_`d'_crude will always be 1
				replace C_credit_numdoses_`vc' = C_credit_numdoses_`vc' + 1 if credit_`d'3_valid==1 & (cum_`d'3_valid==0 | got_`d'3_valid==1) & (got_`d'1_tick==0 & got_`d'2_tick==0 & got_`d'3_tick==0) // Hard code valid bc credit_`d'_crude will always be 1	
				
				replace V_validdose_recd_`vc' = "V" if credit_`d'1_valid==1 & got_`d'1_valid==1   // Updated 4/4/2020 to account for PAHO setting (dose valid if given after min interval); hard code valid bc credit_`d'_crude is always 1 
				replace V_validdose_recd_`vc' = "V" if credit_`d'2_valid==1 & got_`d'2_valid==1 & got_`d'1_tick==0   // Updated 4/4/2020 to account for PAHO setting (dose valid if given after min interval); hard code valid bc credit_`d'_crude is always 1 
				replace V_validdose_recd_`vc' = "V" if credit_`d'3_valid==1 & got_`d'3_valid==1 & got_`d'1_tick==0 & got_`d'2_tick==0   // Updated 4/4/2020 to account for PAHO setting (dose valid if given after min interval); hard code valid bc credit_`d'_crude is always 1 
				
				replace D_numdoses_got_`vc' = D_numdoses_got_`vc' + 1 if `d'1_card_date==visitdate & `d'1_card_date!=.
				replace D_numdoses_got_`vc' = D_numdoses_got_`vc' + 1 if `d'2_card_date==visitdate & `d'2_card_date!=.
				replace D_numdoses_got_`vc' = D_numdoses_got_`vc' + 1 if `d'3_card_date==visitdate & `d'3_card_date!=.
				
				replace I_invaliddose_recd_`vc' = "I" if elig_`d'1_crude==0 & elig_`d'2_crude==0 & elig_`d'3_crude==0 & got_`d'==1  // Hard code elig_`d'_crude==1 bc elig_`d'_valid will never be 1 if dose is early
				
				replace S_sched_numdoses_`vc' = S_sched_numdoses_`vc' + 1 if elig_`d'1_`vc'==1 &  got_`d'1_tick==0
				replace S_sched_numdoses_`vc' = S_sched_numdoses_`vc' + 1 if elig_`d'2_`vc'==1 & (got_`d'1_tick==0 & got_`d'2_tick==0)
				replace S_sched_numdoses_`vc' = S_sched_numdoses_`vc' + 1 if elig_`d'3_`vc'==1 & (got_`d'1_tick==0 & got_`d'2_tick==0 & got_`d'3_tick==0)
			}
		}	
	
		/* Put together the 3 VIM variables
		label define vim 0 "---" 1 "V--" 2 "-I-" 3 "VI-" 4 "--M" 5 "V-M" 6 "-IM" 7 "VIM"
		foreach vc in valid crude {	
			gen vim_`vc' = .
			replace vim_`vc' =  0 if V_validdose_recd_`vc'==0 & I_invaliddose_recd_`vc'==0 & M_mov_occurred_`vc'==0
			replace vim_`vc' =  1 if V_validdose_recd_`vc'==1 & I_invaliddose_recd_`vc'==0 & M_mov_occurred_`vc'==0
			replace vim_`vc' =  2 if V_validdose_recd_`vc'==0 & I_invaliddose_recd_`vc'==1 & M_mov_occurred_`vc'==0
			replace vim_`vc' =  3 if V_validdose_recd_`vc'==1 & I_invaliddose_recd_`vc'==1 & M_mov_occurred_`vc'==0
			replace vim_`vc' =  4 if V_validdose_recd_`vc'==0 & I_invaliddose_recd_`vc'==0 & M_mov_occurred_`vc'==1
			replace vim_`vc' =  5 if V_validdose_recd_`vc'==1 & I_invaliddose_recd_`vc'==0 & M_mov_occurred_`vc'==1
			replace vim_`vc' =  6 if V_validdose_recd_`vc'==0 & I_invaliddose_recd_`vc'==1 & M_mov_occurred_`vc'==1
			replace vim_`vc' =  7 if V_validdose_recd_`vc'==1 & I_invaliddose_recd_`vc'==1 & M_mov_occurred_`vc'==1
			label values vim_`vc' vim
		}
		*/
		
		* Concatentate CVDIMS variables
		foreach vc in valid crude {	
			* First convert numeric variables to string variables
			tostring C_credit_numdoses_`vc', gen(C_credit_numdoses_`vc'_str) 
			tostring D_numdoses_got_`vc', gen(D_numdoses_got_`vc'_str)
			tostring S_sched_numdoses_`vc', gen(S_sched_numdoses_`vc'_str) 
			*decode vim_`vc', generate(vim_`vc'_str)  // use decode because want the value label saved as the string variable
			
			* Concatentate all the string variables
			gen cvdims_`vc' = C_credit_numdoses_`vc'_str + V_validdose_recd_`vc' + D_numdoses_got_`vc'_str + I_invaliddose_recd_`vc' + M_mov_occurred_`vc' + S_sched_numdoses_`vc'_str
			
			* Build CVDIMS sequence
			bysort respid visitdate: gen cvdims_build_seq_`vc' = cvdims_`vc' if _n==1
			by respid: replace cvdims_build_seq_`vc' = cvdims_build_seq_`vc'[_n-1] + " | " + cvdims_`vc'[_n] if inrange(_n, 2, _N) 
			
			* Now smear the last sequence date (i.e., seq in row _N) for all rows with the given respid
			*  This is so when we drop to one row per respid, the evims_sequence for all the dates of the respid is preserved
			bysort respid: gen cvdims_sequence_`vc' = cvdims_build_seq_`vc'[_N]
			drop cvdims_build_seq_`vc'
			
			* For kids with no cards or cards with no dates, set their evims_sequence_`vc' to missing
			*  (Based on the code above, they would have had a value of "0-0--0")
			* Note: The missing value is added to grab the observations that are associated with
			*       clusters in the survey design that yielded no participants/children (and so have missing
			* 		values for all RI variables...only have non-missing CM variables)
			*replace cvdims_sequence_`vc' = "" if inlist(has_card_with_dob_and_dosedate,0,.)
			* NOTE: Could make the following line of code more robust to check if respondent has has_card_with_dob_and_dosedate 
			*       or has_reg_with_dob_and_dosedate, the latter variable does not currently exist
			*replace evims_sequence_`vc' = "" if evims_sequence_`vc'=="00"  // change made 3/27/2020 to account for respids who don't have a card but have register data
			replace cvdims_sequence_`vc' = "" if cvdims_sequence_`vc'=="0-0--0"  
		}
		
		save CVDIMS_variables_long_all_vars, replace 
		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS CVDIMS_variables_long_all_vars
		
		* Subset dataset to 1 row per child & save CVDIMS dataset
		keep respid cvdims_sequence_crude cvdims_sequence_valid 
		bysort respid: keep if _n==1
		save CVDIMS_variables, replace			
		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS CVDIMS_variables
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
