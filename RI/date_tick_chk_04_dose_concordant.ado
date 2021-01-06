*! date_tick_chk_04_dose_concordant version 1.07 - Biostat Global Consulting - 2020-12-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2018-05-30	1.02	MK Trimner		Removed code that limited nonsenical dose
*										dates. criteria: | dob_date_`t'_y < 2000 
*										Removed code that limited senical dose dates:
*										criteria: & dob_date_`t'_y > 2000 
* 2018-11-08	1.03	MK Trimner		Changed so register variables only created
*										if records sought
* 2018-11-19	1.04	MK Trimner		Adjusted to align with `ifreg' local
* 2020-02-27	1.05	MK Trimner		Changed code for bcg_history_tick to only replace
*										to 1 if bcg_scar_history is 1 instead of replacing
*										bcg_history_tick = bcg_scar_history == 1
* 2020-08-04	1.06	MK Trimner		Added counts for multi doses for same dates and out of order
* 2020-12-01	1.07	MK Trimner		Replaced dc_*source*_yes variable with the dose specific dc_*source*_dose_yes to code 
*										Changed the program so that bcg_scar_history is no longer included in the 
*										concordance tables since it is from the interviewer and not a history/card/register source
*										Corrected error in multi dose series section... was hard coded for card when should be *source* so can be ran for card or register
*******************************************************************************

program define date_tick_chk_04_dose_concordant
	version 14.1

	local oldvcp $VCP
	global VCP date_tick_chk_04_dose_concordant
	vcqi_log_comment $VCP 5 Flow "Starting"

	noisily display as text "Checking dose dates: presence & concordance..."
	
	quietly {
	
		local ifreg if "$RI_RECORDS_NOT_SOUGHT" != "1" 
		local register
		`ifreg'	local register register
		
		postfile dt_doses_concordance str20(d type) str32(var) n_0 n_1 n_01 using  dt_doses_concordance , replace

		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS dt_doses_concordance

		foreach d in `=lower("$RI_DOSE_LIST")'{
		* Part 1: Doses present

			foreach t in card `register' {
				if "`t'"=="register" {
					local s reg
				}
				else {
					local s `t'
				}
			
				* Clear out tick mark if there is any date component provided
				replace `d'_tick_`t'=. if !missing(`d'_date_`t'_m) |!missing(`d'_date_`t'_d)| !missing(`d'_date_`t'_y) & dc_`s'_dose_yes==1

				* Create variable to show if all date components were provided for dose for each source
				gen ct_`d'_`t'_full = .
				replace ct_`d'_`t'_full =!missing(`d'_date_`t'_m) & !missing(`d'_date_`t'_d) & !missing(`d'_date_`t'_y) if dc_`s'_dose_yes==1

				* Create variable to show if all date components were missing for dose for each source
				gen ct_`d'_`t'_miss = .
				replace ct_`d'_`t'_miss = missing(`d'_date_`t'_m) & missing(`d'_date_`t'_d) & missing(`d'_date_`t'_y) if dc_`s'_dose_yes==1
				
				* Create variable to show if any date component was missing but not all three date compo
				gen ct_`d'_`t'_parmiss =. 
				replace ct_`d'_`t'_parmiss = (missing(`d'_date_`t'_m) | missing(`d'_date_`t'_d) | missing(`d'_date_`t'_y)) if dc_`s'_dose_yes==1
				replace ct_`d'_`t'_parmiss =  0 if ct_`d'_`t'_miss== 1 & dc_`s'_dose_yes==1 //Only set to 1 less than 3 date components are missing
							 
				* Create variable to show if all date components were provided for dose for each source, but a valid date did not result
				gen ct_`d'_`t'_nonsense = . 
				replace ct_`d'_`t'_nonsense = mdy(`d'_date_`t'_m, `d'_date_`t'_d, `d'_date_`t'_y)==. ///
											if ct_`d'_`t'_full ==1
				
				* Create variable to show if all date components were provided for dose for each source, and a valid date resulted from mdy command
				gen ct_`d'_`t'_sense = .
				replace ct_`d'_`t'_sense = mdy(`d'_date_`t'_m, `d'_date_`t'_d, `d'_date_`t'_y)!=. if ct_`d'_`t'_full == 1 
											
				* Create variable to show if all sensible dates are within the acceptable ranger per dob and surveydates
				* Make sure dates are not before dob
				* If no dob, make sure dates are after earliest date
				gen ct_`d'_`t'_too_early=.
				replace ct_`d'_`t'_too_early=`d'_`t'_date_dq_flag21 if ct_`d'_`t'_sense==1 // if dose date is prior to dob
				replace ct_`d'_`t'_too_early=`d'_`t'_date_dq_flag20 if ct_`d'_`t'_sense==1 & ct_dob_no_valid_dose_calc==1 //if no dob and dose date is
																														  //prior to earliest survey date
				* Create variable to flag if dose date is after survey date
				gen ct_`d'_`t'_late=.
				replace ct_`d'_`t'_late=`d'_`t'_date_dq_flag22 if ct_`d'_`t'_sense==1 
				
				* Create variable to show if dose was received within acceptable date range
				gen ct_`d'_`t'_within_range=.
				replace ct_`d'_`t'_within_range=ct_`d'_`t'_too_early==0 & ct_`d'_`t'_late==0 if ct_`d'_`t'_sense==1
				
				* Create variable to show if there was a tick marck
				gen ct_`d'_`t'_tick=.
				replace ct_`d'_`t'_tick=`d'_tick_`t'==1 if dc_`s'_dose_yes==1
					
				foreach var in ct_`d'_`t'_full ct_`d'_`t'_nonsense  ct_`d'_`t'_miss  ct_`d'_`t'_parmiss  ///
								ct_`d'_`t'_sense ct_`d'_`t'_too_early ct_`d'_`t'_late ct_`d'_`t'_within_range ct_`d'_`t'_tick {	
					count if `var' == 0
						  scalar n_0 = r(N)
					count if `var' == 1
						  scalar n_1 = r(N)
					count if `var' == 1 | `var' == 0
						  scalar n_01 = r(N)
					
					post dt_doses_concordance ("`d'") ("`t'") ("`var'") (n_0) (n_1) (n_01)

				}	
			}


			* Create all these variables for history to show as missing except tick mark
			foreach t in history {
				* Create variable to show if all date components were provided for dose for each source
				gen ct_`d'_`t'_full = .

				* Create variable to show if all date components were missing for dose for each source
				gen ct_`d'_`t'_miss = .

				* Create variable to show if any date component was missing but not all three date compo
				gen ct_`d'_`t'_parmiss =. 
							 
				* Create variable to show if all date components were provided for dose for each source, but a valid date did not result
				gen ct_`d'_`t'_nonsense = . 
				* Create variable to show if all date components were provided for dose for each source, and a valid date resulted from mdy command
				gen ct_`d'_`t'_sense = .

				* Create variable to show if all sensible dates are within the acceptable ranger per dob and surveydates
				* Make sure dates are not before dob
				* If no dob, make sure dates are after earliest date
				gen ct_`d'_`t'_too_early=.
																														  //prior to earliest survey date
				* Create variable to flag if dose date is after survey date
				gen ct_`d'_`t'_late=.

				* Create variable to show if dose was received within acceptable date range
				gen ct_`d'_`t'_within_range=.

				* Create variable to show if there was a tick mark
				gen ct_`d'_`t'_tick=.
				replace ct_`d'_`t'_tick=`d'_`t'==1 if dc_`t'_dose_yes==1 

				foreach var in ct_`d'_`t'_full ct_`d'_`t'_nonsense  ct_`d'_`t'_miss  ct_`d'_`t'_parmiss  ///
								ct_`d'_`t'_sense ct_`d'_`t'_too_early ct_`d'_`t'_late ct_`d'_`t'_within_range ct_`d'_`t'_tick {	
					count if `var' == 0
						  scalar n_0 = r(N)
					count if `var' == 1
						  scalar n_1 = r(N)
					count if `var' == 1 | `var' == 0
						  scalar n_01 = r(N)
					
					post dt_doses_concordance ("`d'") ("`t'") ("`var'") (n_0) (n_1) (n_01)
				}
			}
		}
		
********************************************************************************************************************************************
********************************************************************************************************************************************
********************************************************************************************************************************************
* Look at the multi doses and check to see how many have the same dates within a series
* and how many are out of chronological order


* Start with those with only two doses
postfile dt_multi_series str20(d type) str32(var) n_0 n_1 n_01 using dt_multi_series, replace

foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
	
	foreach t in card `register' {
		if "`t'"=="register" {
			local s reg
		}
		else {
			local s `t'
		}
	
		gen ct_`d'_`t'_within_range = ct_`d'1_`t'_within_range == 1 & ct_`d'2_`t'_within_range == 1 if dc_`s'_dose_yes==1
		
		gen ct_`d'_`t'_same = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) == mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) ///
						  if ct_`d'_`t'_within_range == 1
						  
		gen ct_`d'_`t'_diff = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) != mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) ///
						   if ct_`d'_`t'_within_range == 1
						  
		gen ct_`d'12_`t'_ooo = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) > mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) if ct_`d'_`t'_diff == 1
		
		gen ct_`d'12_`t'_all_in_order = ct_`d'12_`t'_ooo == 0 if ct_`d'_`t'_diff == 1
		
		foreach var in ct_`d'_`t'_within_range ct_`d'_`t'_same ct_`d'_`t'_diff ct_`d'12_`t'_ooo ct_`d'12_`t'_all_in_order {	
			count if `var' == 0
				  scalar n_0 = r(N)
			count if `var' == 1
				  scalar n_1 = r(N)
			count if `var' == 1 | `var' == 0
				  scalar n_01 = r(N)
			
			post dt_multi_series ("`d'") ("`t'") ("`var'") (n_0) (n_1) (n_01)
			
		}	
	}
}

* Add multi temp dataset to global to erase file at end of program
if "$RI_MULTI_2_DOSE_LIST" != "" | "$RI_MULTI_3_DOSE_LIST" != "" vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS dt_multi_series

********************************************************************************************************************************************
********************************************************************************************************************************************
********************************************************************************************************************************************

foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
	
	foreach t in card `register' {
		if "`t'"=="register" {
			local s reg
		}
		else {
			local s `t'
		}
		
		* Start with just those that have the first and second dose in series
		gen ct_`d'12_`t'_within_range = ct_`d'1_`t'_within_range == 1 & ct_`d'2_`t'_within_range == 1 & ct_`d'3_`t'_within_range != 1 if dc_`s'_dose_yes==1
		
		gen ct_`d'12_`t'_same = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) == mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) ///
						  if ct_`d'12_`t'_within_range == 1
						  
		gen ct_`d'12_`t'_diff = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) != mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) ///
						   if ct_`d'12_`t'_within_range == 1
						 
		gen ct_`d'12_`t'_ooo = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) > mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) if ct_`d'12_`t'_diff == 1
		
		gen ct_`d'12_`t'_all_inorder = ct_`d'12_`t'_ooo == 0 if ct_`d'12_`t'_diff == 1
		

		********************************************************************************************************************************************

				
		* Then do those that just have first and third dose in series
		gen ct_`d'13_`t'_within_range = ct_`d'1_`t'_within_range == 1 & ct_`d'2_`t'_within_range != 1 & ct_`d'3_`t'_within_range == 1 if dc_`s'_dose_yes==1
		
		gen ct_`d'13_`t'_same = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) == mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
						  if ct_`d'13_`t'_within_range == 1
						  
		gen ct_`d'13_`t'_diff = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) != mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
						   if ct_`d'13_`t'_within_range == 1
						 
		gen ct_`d'13_`t'_ooo = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) > mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) if ct_`d'13_`t'_diff == 1

		gen ct_`d'13_`t'_all_inorder = ct_`d'13_`t'_ooo == 0 if ct_`d'13_`t'_diff == 1
		
		********************************************************************************************************************************************

		
		* Then do those that just have second and third dose in series
		gen ct_`d'23_`t'_within_range = ct_`d'1_`t'_within_range != 1 & ct_`d'2_`t'_within_range == 1 & ct_`d'3_`t'_within_range == 1 if dc_`s'_dose_yes==1
		
		gen ct_`d'23_`t'_same = mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) == mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
						  if ct_`d'23_`t'_within_range == 1
						  
		gen ct_`d'23_`t'_diff = mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) != mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
						   if ct_`d'23_`t'_within_range == 1
						 
		gen ct_`d'23_`t'_ooo = mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) > mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) if ct_`d'23_`t'_diff == 1

		gen ct_`d'23_`t'_all_inorder = ct_`d'23_`t'_ooo == 0 if ct_`d'23_`t'_diff == 1
		
		********************************************************************************************************************************************
		
		* Lastly do this for those that have all 3 dates in range
		gen ct_`d'123_`t'_withinrange = ct_`d'1_`t'_within_range == 1 & ct_`d'2_`t'_within_range == 1 & ct_`d'3_`t'_within_range == 1 if dc_`s'_dose_yes==1
		
		gen ct_`d'123_`t'_all_same = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) == mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) & ///
								 mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) == mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
								 if ct_`d'123_`t'_withinrange == 1
								 
		gen ct_`d'123_`t'_12_same = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) == mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) & ///
								 mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) != mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
								 if ct_`d'123_`t'_withinrange == 1	
								 
		gen ct_`d'123_`t'_13_same = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) == mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) & ///
								 mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) != mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
								 if ct_`d'123_`t'_withinrange == 1	
								 
		gen ct_`d'123_`t'_23_same = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) != mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) & ///
								 mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) == mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
								 if ct_`d'123_`t'_withinrange == 1						 
								 
		gen ct_`d'123_`t'_all_diff = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) != mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) & ///
								 mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) != mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) ///
								 if ct_`d'123_`t'_withinrange == 1		
		
						 
		gen ct_`d'123_`t'_12_ooo = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) > mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) if ct_`d'123_`t'_all_diff == 1
		
		gen ct_`d'123_`t'_23_ooo = mdy(`d'2_date_`t'_m, `d'2_date_`t'_d, `d'2_date_`t'_y) > mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) if ct_`d'123_`t'_all_diff == 1
		
		gen ct_`d'123_`t'_13_ooo = mdy(`d'1_date_`t'_m, `d'1_date_`t'_d, `d'1_date_`t'_y) > mdy(`d'3_date_`t'_m, `d'3_date_`t'_d, `d'3_date_`t'_y) if ct_`d'123_`t'_all_diff == 1
		
		gen ct_`d'123_`t'_all_inorder = ct_`d'123_`t'_12_ooo == 0 & ct_`d'123_`t'_23_ooo == 0 & ct_`d'123_`t'_13_ooo == 0 if ct_`d'123_`t'_all_diff == 1
		
				
		foreach var in ct_`d'12_`t'_within_range ct_`d'12_`t'_same ct_`d'12_`t'_diff  ct_`d'12_`t'_ooo ct_`d'12_`t'_all_inorder ///
			ct_`d'13_`t'_within_range ct_`d'13_`t'_same ct_`d'13_`t'_diff ct_`d'13_`t'_ooo ct_`d'13_`t'_all_inorder ///
			ct_`d'23_`t'_within_range ct_`d'23_`t'_same ct_`d'23_`t'_diff  ct_`d'23_`t'_ooo ct_`d'23_`t'_all_inorder ///
			ct_`d'123_`t'_withinrange ct_`d'123_`t'_all_same ct_`d'123_`t'_12_same ///
			ct_`d'123_`t'_13_same ct_`d'123_`t'_23_same ct_`d'123_`t'_all_diff ct_`d'123_`t'_12_ooo ct_`d'123_`t'_23_ooo ct_`d'123_`t'_13_ooo ct_`d'123_`t'_all_inorder {	
			count if `var' == 0
				  scalar n_0 = r(N)
			count if `var' == 1
				  scalar n_1 = r(N)
			count if `var' == 1 | `var' == 0
				  scalar n_01 = r(N)
			
			post dt_multi_series ("`d'") ("`t'") ("`var'") (n_0) (n_1) (n_01) 
			
			if inlist("`var'", "ct_`d'12_`t'_all_inorder","ct_`d'13_`t'_all_inorder","ct_`d'23_`t'_all_inorder") {
			    post dt_multi_series ("`d'") ("`t'") ("`=subinstr("`var'","all_inorder","blank1",.)'") (.) (.) (.)
				post dt_multi_series ("`d'") ("`t'") ("`=subinstr("`var'","all_inorder","blank2",.)'") (.) (.) (.)
			}
		}	
	}
}

capture postclose dt_multi_series


********************************************************************************************************************************************
********************************************************************************************************************************************
********************************************************************************************************************************************
********************************************************************************

		foreach d in `=lower("$RI_DOSE_LIST")' {

			* Create variable to show if card indicates dose was received
			gen dc_`d'_card_gotit  =(!missing(`d'_date_card_d) | ///
									!missing(`d'_date_card_m) | ///
									!missing(`d'_date_card_y) | ///
									`d'_tick_card==1) if dc_card_dose_yes==1  
								   
			`ifreg' {
				gen dc_`d'_reg_gotit  = .
				replace dc_`d'_reg_gotit=(!missing(`d'_date_register_d) | ///
										  !missing(`d'_date_register_m) | ///
										  !missing(`d'_date_register_y) | ///
											  `d'_tick_reg==1) if dc_reg_dose_yes ==1
			}
			
			* Create variable to indicate if dose received via history
			gen dc_`d'_history_gotit = `d'_history==1 if dc_history_dose_yes==1

		}	
		
********************************************************************************	
		  

********************************************************************************
		* Part 2: Doses concordance

		* Part 2a: Card & reg
		local varlist 
		`ifreg' {
			/*1*/  gen dc_no_card_no_reg    = cond(dc_card_dose_no==1 & dc_reg_dose_no==1,1,0)
			/*2*/  gen dc_has_card_no_reg   = cond(dc_card_dose_yes==1 & dc_reg_dose_no==1,1,0)  
			/*3*/  gen dc_no_card_has_reg   = cond(dc_card_dose_no==1 & dc_reg_dose_yes==1,1,0)  
			/*4*/  gen dc_has_card_has_reg  = cond(dc_card_dose_yes==1 & dc_reg_dose_yes==1,1,0)

			foreach d in `=lower("$RI_DOSE_LIST")' {
			
				/*4.2*/  /*has_card_has_reg: both show no vaccination */		
				gen     dc_cr_`d'_nogotit_both = . 
				`ifreg' replace dc_cr_`d'_nogotit_both =	dc_`d'_card_gotit == 0 & dc_`d'_reg_gotit == 0 ///
													if dc_has_card_has_reg==1									
			 

				/*4.1*/  /*has_card_has_reg: both show vaccination */
				gen     dc_cr_`d'_gotit_both = . 
				`ifreg' replace dc_cr_`d'_gotit_both = 	dc_`d'_card_gotit == 1 & dc_`d'_reg_gotit == 1 ///
												if dc_has_card_has_reg==1
			  
				/*4.1.1*/  /*has_card_has_reg: both show vaccination and in perfect agreement*/
				gen         dc_cr_`d'_gotit_perfect_agr = .
				`ifreg' replace 	dc_cr_`d'_gotit_perfect_agr =	`d'_date_register_d==`d'_date_card_d & ///
															`d'_date_register_m==`d'_date_card_m & ///
															`d'_date_register_y==`d'_date_card_y & /// 
															`d'_tick_card==`d'_tick_reg if dc_cr_`d'_gotit_both ==1 
				//gotit_both captures if they had card and register
				//Since this is about the original
				//data it does not matter if the dates make sense, 
				//just comparing data	

				/*4.1.2*/  /*has_card_has_reg: both show vaccination but some discordance*/		
				gen     dc_cr_`d'_gotit_discord_dates =.
				`ifreg' replace dc_cr_`d'_gotit_discord_dates = dc_cr_`d'_gotit_perfect_agr==0 ///
														if dc_cr_`d'_gotit_both==1
																											 
				********************************************************************************																		
				/*4.1.2.2*/  /*has_card_has_reg: both show vaccination but some discordance - disagree on dates*/
				* Both have full dates that disagree
				gen     dc_cr_`d'_fulldates_disag=.
				`ifreg' replace dc_cr_`d'_fulldates_disag=	ct_`d'_card_full==1 & ct_`d'_register_full==1 & ///
													mdy(`d'_date_card_m,    `d'_date_card_d,    `d'_date_card_y)  != ///
													mdy(`d'_date_register_m,`d'_date_register_d,`d'_date_register_y) ///
													if dc_cr_`d'_gotit_discord_dates==1

				* Both have partial dates that disagree
				gen     dc_cr_`d'_pardates_disag=.
				`ifreg' replace dc_cr_`d'_pardates_disag=	ct_`d'_card_parmiss==1 & ct_`d'_register_parmiss==1 & ///
													mdy(`d'_date_card_m,    `d'_date_card_d,    `d'_date_card_y)  != ///
													mdy(`d'_date_register_m,`d'_date_register_d,`d'_date_register_y) ///
													if dc_cr_`d'_gotit_discord_dates==1


				* One has full and One has partial date
				gen     dc_cr_`d'_1full_1par_disag=.
				`ifreg' replace dc_cr_`d'_1full_1par_disag=	(ct_`d'_card_parmiss==1 & ct_`d'_register_full==1) |  ///
													(ct_`d'_card_full==1    & ct_`d'_register_parmiss==1) ///
													if dc_cr_`d'_gotit_discord_dates==1


				* One date (full or parital) and one tick
				gen     dc_cr_`d'_1date_1tick_disag=.
				`ifreg' replace dc_cr_`d'_1date_1tick_disag=((ct_`d'_card_parmiss==1     | ct_`d'_card_full==1)     & `d'_tick_register==1) | ///
													((ct_`d'_register_parmiss==1 | ct_`d'_register_full==1) & `d'_tick_card==1)       ///
													if dc_cr_`d'_gotit_discord_dates==1			
											
				********************************************************************************											
											
				/*4.3*/  /*has_card_has_reg: card shows vaccination, reg says no */	

				* Create variable to show if the two sources do not agree on if dose received
				gen     dc_cr_`d'_onegotit=.
				`ifreg' replace dc_cr_`d'_onegotit= (dc_`d'_card_gotit == 0 & dc_`d'_reg_gotit == 1) | ///
											(dc_`d'_card_gotit == 1 & dc_`d'_reg_gotit == 0)   ///
											if dc_has_card_has_reg==1
											
				gen     dc_cr_`d'_cardgotit_noreg = . 			
				`ifreg' replace dc_cr_`d'_cardgotit_noreg =(dc_`d'_card_gotit == 1 & dc_`d'_reg_gotit == 0) ///
												if dc_cr_`d'_onegotit==1

				gen     dc_cr_`d'_reggotit_nocard= .
				`ifreg' replace dc_cr_`d'_reggotit_nocard=(dc_`d'_card_gotit == 0 & dc_`d'_reg_gotit == 1) ///
											if dc_cr_`d'_onegotit==1	
				
			 }
			 
			 *******************************************************************************
			 *******************************************************************************
			  

			foreach d in `=lower("$RI_DOSE_LIST")' {
				foreach var in 	dc_cr_`d'_nogotit_both ///
								dc_cr_`d'_gotit_both ///
								dc_cr_`d'_gotit_perfect_agr ///
								dc_cr_`d'_gotit_discord_dates ///
								dc_cr_`d'_fulldates_disag ///
								dc_cr_`d'_pardates_disag ///
								dc_cr_`d'_1full_1par_disag ///
								dc_cr_`d'_1date_1tick_disag ///
								dc_cr_`d'_onegotit ///
								dc_cr_`d'_cardgotit_noreg ///
								dc_cr_`d'_reggotit_nocard {	
					count if `var' == 0
						  scalar n_0 = r(N)
					count if `var' == 1
						  scalar n_1 = r(N)
					count if `var' == 1 | `var' == 0
						  scalar n_01 = r(N)
					
					post dt_doses_concordance ("`d'") ("card-register") ("`var'") (n_0) (n_1) (n_01)
				}
			}
		}
		  
		********************************************************************************
		 
		* Create variables to show they have card and history.. 
		gen dc_no_card_no_hist    = dc_card_dose_no==1  & dc_history_dose_no==1
		gen dc_has_card_no_hist   = dc_card_dose_yes==1 & dc_history_dose_no==1
		gen dc_no_card_has_hist   = dc_card_dose_no==1  & dc_history_dose_yes==1
		gen dc_has_card_has_hist  = dc_card_dose_yes==1 & dc_history_dose_yes==1
		   
		 
		* Part 2b: Card & History
		foreach d in `=lower("$RI_DOSE_LIST")' {

			* both card and history show no vaccination			
			gen     dc_ch_`d'_nogotit_both = .
			replace dc_ch_`d'_nogotit_both =	dc_`d'_card_gotit == 0 & dc_`d'_history_gotit==0 ///
												if dc_has_card_has_hist==1 

			* both card and history show vaccination 
			gen     dc_ch_`d'_gotit_both = . 
			replace dc_ch_`d'_gotit_both = 	dc_`d'_card_gotit == 1 & dc_`d'_history_gotit == 1 ///
											if dc_has_card_has_hist==1 
											
			* one shows vaccination and other source shows no vaccination	
			gen     dc_ch_`d'_onegotit=.
			replace dc_ch_`d'_onegotit=	(dc_`d'_history_gotit==1 & dc_`d'_card_gotit==0) | ///
										(dc_`d'_history_gotit==0 & dc_`d'_card_gotit==1) if dc_has_card_has_hist==1  


			gen     dc_ch_`d'_c_yes_h_no = .
			replace dc_ch_`d'_c_yes_h_no =(dc_`d'_card_gotit == 1 & dc_`d'_history_gotit ==0) ///
											if dc_ch_`d'_onegotit==1 
					
			gen     dc_ch_`d'_h_yes_c_no=.
			replace dc_ch_`d'_h_yes_c_no= (dc_`d'_card_gotit == 0 & dc_`d'_history_gotit ==1) ///
											if dc_ch_`d'_onegotit==1 
											
		}

			
		foreach d in `=lower("$RI_DOSE_LIST")' {	
			foreach var in 	dc_ch_`d'_gotit_both dc_ch_`d'_nogotit_both dc_ch_`d'_onegotit ///
							dc_ch_`d'_h_yes_c_no dc_ch_`d'_c_yes_h_no {	
				count if `var' == 0
					  scalar n_0 = r(N)
				count if `var' == 1
					  scalar n_1 = r(N)
				count if `var' == 1 | `var' == 0
					  scalar n_01 = r(N)
				
				post  dt_doses_concordance ("`d'") ("card-history") ("`var'") (n_0) (n_1) (n_01)
			}
		}
							
		********************************************************************************   

		* Part 2c: Register & History 
		`ifreg' {
			* Create variables to show the if have register and history..
			gen dc_no_reg_no_hist    = dc_reg_dose_no==1  & dc_history_dose_no==1
			gen dc_has_reg_no_hist   = dc_reg_dose_yes==1 & dc_history_dose_no==1
			gen dc_no_reg_has_hist   = dc_reg_dose_no==1  & dc_history_dose_yes==1
			gen dc_has_reg_has_hist  = dc_reg_dose_yes==1 & dc_history_dose_yes==1 

			foreach d in `=lower("$RI_DOSE_LIST")' {

				* Create variable to show if register available

				* both register and history show vaccination 
				gen dc_rh_`d'_gotit_both = . 
				`ifreg' replace dc_rh_`d'_gotit_both = dc_`d'_reg_gotit == 1 & dc_`d'_history_gotit == 1 if dc_has_reg_has_hist==1 


				* both register and history show no vaccination			
				gen dc_rh_`d'_nogotit_both = .
				`ifreg' replace 	dc_rh_`d'_nogotit_both = dc_`d'_reg_gotit == 0 & dc_`d'_history_gotit==0 ///
												if dc_has_reg_has_hist==1 
						

				* one shows vaccination and other source shows no vaccination	
				gen dc_rh_`d'_onegotit=.
				`ifreg' replace dc_rh_`d'_onegotit=	(dc_`d'_history_gotit==1 & dc_`d'_reg_gotit==0) | ///
											(dc_`d'_history_gotit==0 & dc_`d'_reg_gotit==1) if dc_has_reg_has_hist==1  

											
				gen dc_rh_`d'_r_yes_h_no = .
				`ifreg' replace 	dc_rh_`d'_r_yes_h_no =(dc_`d'_reg_gotit == 1 & dc_`d'_history_gotit ==0) ///
												if dc_rh_`d'_onegotit==1 
						
				gen dc_rh_`d'_h_yes_r_no=.
				`ifreg' replace dc_rh_`d'_h_yes_r_no= (dc_`d'_reg_gotit == 0 & dc_`d'_history_gotit ==1) ///
												if dc_rh_`d'_onegotit==1 
												
			}

					
			foreach d in `=lower("$RI_DOSE_LIST")'{	
				foreach var in  dc_rh_`d'_gotit_both ///
								dc_rh_`d'_nogotit_both ///
								dc_rh_`d'_onegotit ///
								dc_rh_`d'_h_yes_r_no ///
								dc_rh_`d'_r_yes_h_no {	
					di as text "`var'"
					count if `var' == 0
						  scalar n_0 = r(N)
					count if `var' == 1
						  scalar n_1 = r(N)
					count if `var' == 1 | `var' == 0
						  scalar n_01 = r(N)
				
					post  dt_doses_concordance ("`d'") ("register-history") ("`var'") (n_0) (n_1) (n_01)
				}
			}
		}
				
			********************************************************************************
			*For counts that are not dose specific, populate with all as dose
			`ifreg' local a1 dc_no_card_no_reg dc_has_card_no_reg dc_no_card_has_reg dc_has_card_has_reg
			`ifreg' local a2 dc_no_reg_no_hist dc_no_reg_has_hist dc_has_reg_no_hist dc_has_reg_has_hist
			local a3 dc_no_card_no_hist dc_no_card_has_hist dc_has_card_no_hist dc_has_card_has_hist dc_card_dose_yes dc_card_dose_no 
			`ifreg' local a4 dc_reg_dose_yes dc_reg_dose_no 
			local a5 dc_history_dose_yes dc_history_dose_no

			foreach var in `a1' `a2' `a3' `a4' `a5' {
				if "`var'"=="dc_no_card_no_reg" | "`var'"=="dc_has_card_no_reg" | "`var'"=="dc_no_card_has_reg" | "`var'"=="dc_has_card_has_reg"  {
					local i card-register
				}
				else if "`var'"=="dc_no_reg_no_hist" | "`var'"=="dc_no_reg_has_hist" | "`var'"=="dc_has_reg_no_hist" | "`var'"=="dc_has_reg_has_hist"  {
					local i register-history
				}
				else if "`var'"=="dc_no_card_no_hist" | "`var'"=="dc_no_card_has_hist" | "`var'"=="dc_has_card_no_hist" | "`var'"=="dc_has_card_has_hist"  {
					local i card-history
				}
				else if "`var'"=="dc_card_dose_yes" | "`var'"=="dc_card_dose_no" | "`var'"=="dc_reg_dose_yes" | "`var'"=="dc_reg_dose_no" | "`var'"=="dc_history_dose_yes" | "`var'"=="dc_history_dose_no"  {
					local i all
				}
			 
				count if `var' == 0
					  scalar n_0 = r(N)
				count if `var' == 1
					  scalar n_1 = r(N)
				count if `var' == 1 | `var' == 0
					  scalar n_01 = r(N)
				
				post dt_doses_concordance ("all") ("`i'") ("`var'") (n_0) (n_1) (n_01)
			}
			   
			********************************************************************************
			* Create variables to show how many doses were received from each source...
			foreach d in `=lower("$RI_DOSE_LIST")' { 
			`ifreg' { 
				gen `d'_card_register_yes       = dc_`d'_card_gotit==1 & dc_`d'_reg_gotit==1 if dc_has_card_has_reg==1  
				gen `d'_card_register_no        = dc_`d'_card_gotit==0 & dc_`d'_reg_gotit==0 if dc_has_card_has_reg==1  
				gen `d'_card_yes_register_no    = dc_`d'_card_gotit==1 & dc_`d'_reg_gotit==0 if dc_has_card_has_reg==1  
				gen `d'_card_no_register_yes    = dc_`d'_card_gotit==0 & dc_`d'_reg_gotit==1 if dc_has_card_has_reg==1  
			}
				
			gen `d'_card_history_yes        = dc_`d'_card_gotit==1 & dc_`d'_history_gotit==1 if dc_has_card_has_hist==1  
			gen `d'_card_history_no         = dc_`d'_card_gotit==0 & dc_`d'_history_gotit==0 if dc_has_card_has_hist==1  
			gen `d'_card_yes_history_no     = dc_`d'_card_gotit==1 & dc_`d'_history_gotit==0 if dc_has_card_has_hist==1  
			gen `d'_card_no_history_yes     = dc_`d'_card_gotit==0 & dc_`d'_history_gotit==1 if dc_has_card_has_hist==1  

			`ifreg' {
				gen `d'_register_history_yes    = dc_`d'_reg_gotit==1 & dc_`d'_history_gotit==1 if dc_has_reg_has_hist==1  
				gen `d'_register_history_no     = dc_`d'_reg_gotit==0 & dc_`d'_history_gotit==0 if dc_has_reg_has_hist==1  
				gen `d'_register_yes_history_no = dc_`d'_reg_gotit==1 & dc_`d'_history_gotit==0 if dc_has_reg_has_hist==1  
				gen `d'_register_no_history_yes = dc_`d'_reg_gotit==0 & dc_`d'_history_gotit==1 if dc_has_reg_has_hist==1  
			}
		}
			
			
		foreach d in `=lower("$RI_DOSE_LIST")'  {
		
			local varlist
			`ifreg' local varlist `d'_card_register_yes    `d'_card_register_no    `d'_card_yes_register_no    `d'_card_no_register_yes
			local varlist `varlist' `d'_card_history_yes `d'_card_history_no `d'_card_yes_history_no  `d'_card_no_history_yes 
			`ifreg' local varlist `varlist' `d'_register_history_yes `d'_register_history_no `d'_register_yes_history_no `d'_register_no_history_yes

			foreach var in 	`varlist' {
				count if `var' == 0
					  scalar n_0 = r(N)
				count if `var' == 1
					  scalar n_1 = r(N)
				count if `var' == 1 | `var' == 0
					  scalar n_01 = r(N)
				
				post dt_doses_concordance ("`d'") ("num_doses") ("`var'") (n_0) (n_1) (n_01)
			}
		}
			   
		capture postclose dt_doses_concordance	
	
		save date_tick_in_progress, replace
	
		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS date_tick_in_progress
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	
end
