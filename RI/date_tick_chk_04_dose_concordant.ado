*! date_tick_chk_04_dose_concordant version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define date_tick_chk_04_dose_concordant
	version 14.1

	local oldvcp $VCP
	global VCP date_tick_chk_04_dose_concordant
	vcqi_log_comment $VCP 5 Flow "Starting"

	noisily display "Checking dose dates: presence & concordance..."
	
	quietly {
	
		if "$RI_RECORDS_NOT_SOUGHT" == "1" local register
		else local register register
	
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
				replace `d'_tick_`t'=. if !missing(`d'_date_`t'_m) |!missing(`d'_date_`t'_d)| !missing(`d'_date_`t'_y) & dc_`s'_yes==1

				* Create variable to show if all date components were provided for dose for each source
				gen ct_`d'_`t'_full = .
				replace ct_`d'_`t'_full =!missing(`d'_date_`t'_m) & !missing(`d'_date_`t'_d) & !missing(`d'_date_`t'_y) if dc_`s'_yes==1

				* Create variable to show if all date components were missing for dose for each source
				gen ct_`d'_`t'_miss = .
				replace ct_`d'_`t'_miss = missing(`d'_date_`t'_m) & missing(`d'_date_`t'_d) & missing(`d'_date_`t'_y) if dc_`s'_yes==1
				
				* Create variable to show if any date component was missing but not all three date compo
				gen ct_`d'_`t'_parmiss =. 
				replace ct_`d'_`t'_parmiss = (missing(`d'_date_`t'_m) | missing(`d'_date_`t'_d) | missing(`d'_date_`t'_y)) if dc_`s'_yes==1
				replace ct_`d'_`t'_parmiss =  0 if ct_`d'_`t'_miss== 1 & dc_`s'_yes==1 //Only set to 1 less than 3 date components are missing
							 
				* Create variable to show if all date components were provided for dose for each source, but a valid date did not result
				gen ct_`d'_`t'_nonsense = . 
				replace ct_`d'_`t'_nonsense = mdy(`d'_date_`t'_m, `d'_date_`t'_d, `d'_date_`t'_y)==. | `d'_date_`t'_y < 2000  ///
											if ct_`d'_`t'_full ==1
				
				* Create variable to show if all date components were provided for dose for each source, and a valid date resulted from mdy command
				gen ct_`d'_`t'_sense = .
				replace ct_`d'_`t'_sense = mdy(`d'_date_`t'_m, `d'_date_`t'_d, `d'_date_`t'_y)!=. & `d'_date_`t'_y > 2000 if ct_`d'_`t'_full == 1 
											
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
				replace ct_`d'_`t'_tick=`d'_tick_`t'==1 if dc_`s'_yes==1
					
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

				* Create variable to show if there was a tick marck
				gen ct_`d'_`t'_tick=.
				replace ct_`d'_`t'_tick=`d'_`t'==1 if dc_`t'_yes==1 

				if "`d'"=="bcg" {
					replace ct_`d'_`t'_tick=`d'_scar_history==1 if dc_`t'_yes==1
				}

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


********************************************************************************

		foreach d in `=lower("$RI_DOSE_LIST")' {

			* Create variable to show if card indicates dose was received
			gen dc_`d'_card_gotit  =(!missing(`d'_date_card_d) | ///
									!missing(`d'_date_card_m) | ///
									!missing(`d'_date_card_y) | ///
									`d'_tick_card==1) if dc_card_yes==1  
								   
			 * Create variable to indicate if dose was received via reg document 
			if "$RI_RECORDS_NOT_SOUGHT" == "1" {
				gen dc_`d'_reg_gotit  = 0
			}
			else {
				gen dc_`d'_reg_gotit  = .
				replace dc_`d'_reg_gotit=(!missing(`d'_date_register_d) | ///
										  !missing(`d'_date_register_m) | ///
										  !missing(`d'_date_register_y) | ///
											  `d'_tick_reg==1) if dc_reg_yes ==1
			}
			* Create variable to indicate if dose received via history
			gen dc_`d'_history_gotit = `d'_history==1 if dc_history_yes==1

		}	
		
********************************************************************************	
		  

********************************************************************************
		* Part 2: Doses concordance

		* Part 2a: Card & reg
		 

		/*1*/  gen dc_no_card_no_reg    = cond(dc_card_no==1 & dc_reg_no==1,1,0)
		/*2*/  gen dc_has_card_no_reg   = cond(dc_card_yes==1 & dc_reg_no==1,1,0)  
		/*3*/  gen dc_no_card_has_reg   = cond(dc_card_no==1 & dc_reg_yes==1,1,0)  
		/*4*/  gen dc_has_card_has_reg  = cond(dc_card_yes==1 & dc_reg_yes==1,1,0)


		* Create variables for card and register comparison
		
		local ifreg if "$RI_RECORDS_NOT_SOUGHT" != "1"
		
		
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
			//gotit_both captures if they had card and registe
			//Since this is about the original
			// data it does not matter if the dates make sense, 
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

		  
		********************************************************************************
		 
		* Create variables to show they have card and history.. 
		gen dc_no_card_no_hist    = dc_card_no==1  & dc_history_no==1
		gen dc_has_card_no_hist   = dc_card_yes==1 & dc_history_no==1
		gen dc_no_card_has_hist   = dc_card_no==1  & dc_history_yes==1
		gen dc_has_card_has_hist  = dc_card_yes==1 & dc_history_yes==1
		   
		 
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

		* Create variables to show the if have register and history..
		gen dc_no_reg_no_hist    = dc_reg_no==1  & dc_history_no==1
		gen dc_has_reg_no_hist   = dc_reg_yes==1 & dc_history_no==1
		gen dc_no_reg_has_hist   = dc_reg_no==1  & dc_history_yes==1
		gen dc_has_reg_has_hist  = dc_reg_yes==1 & dc_history_yes==1 

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
				di "`var'"
				count if `var' == 0
					  scalar n_0 = r(N)
				count if `var' == 1
					  scalar n_1 = r(N)
				count if `var' == 1 | `var' == 0
					  scalar n_01 = r(N)
			
				post  dt_doses_concordance ("`d'") ("register-history") ("`var'") (n_0) (n_1) (n_01)
			}
		}
			
		********************************************************************************
		*For counts that are not dose specific, populate with all as dose
		local a1 dc_no_card_no_reg dc_has_card_no_reg dc_no_card_has_reg dc_has_card_has_reg
		local a2 dc_no_reg_no_hist dc_no_reg_has_hist dc_has_reg_no_hist dc_has_reg_has_hist
		local a3 dc_no_card_no_hist dc_no_card_has_hist dc_has_card_no_hist dc_has_card_has_hist 
		local a4 dc_card_yes dc_card_no dc_reg_yes dc_reg_no dc_history_yes dc_history_no

		foreach var in `a1' `a2' `a3' `a4' {
			if "`var'"=="dc_no_card_no_reg" | "`var'"=="dc_has_card_no_reg" | "`var'"=="dc_no_card_has_reg" | "`var'"=="dc_has_card_has_reg"  {
				local i card-register
			}
			else if "`var'"=="dc_no_reg_no_hist" | "`var'"=="dc_no_reg_has_hist" | "`var'"=="dc_has_reg_no_hist" | "`var'"=="dc_has_reg_has_hist"  {
				local i register-history
			}
			else if "`var'"=="dc_no_card_no_hist" | "`var'"=="dc_no_card_has_hist" | "`var'"=="dc_has_card_no_hist" | "`var'"=="dc_has_card_has_hist"  {
				local i card-history
			}
			else if "`var'"=="dc_card_yes" | "`var'"=="dc_card_no" | "`var'"=="dc_reg_yes" | "`var'"=="dc_reg_no" | "`var'"=="dc_history_yes" | "`var'"=="dc_history_no"  {
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
			gen `d'_card_register_yes       = dc_`d'_card_gotit==1 & dc_`d'_reg_gotit==1 if dc_has_card_has_reg==1  
			gen `d'_card_register_no        = dc_`d'_card_gotit==0 & dc_`d'_reg_gotit==0 if dc_has_card_has_reg==1  
			gen `d'_card_yes_register_no    = dc_`d'_card_gotit==1 & dc_`d'_reg_gotit==0 if dc_has_card_has_reg==1  
			gen `d'_card_no_register_yes    = dc_`d'_card_gotit==0 & dc_`d'_reg_gotit==1 if dc_has_card_has_reg==1  

			gen `d'_card_history_yes        = dc_`d'_card_gotit==1 & dc_`d'_history_gotit==1 if dc_has_card_has_hist==1  
			gen `d'_card_history_no         = dc_`d'_card_gotit==0 & dc_`d'_history_gotit==0 if dc_has_card_has_hist==1  
			gen `d'_card_yes_history_no     = dc_`d'_card_gotit==1 & dc_`d'_history_gotit==0 if dc_has_card_has_hist==1  
			gen `d'_card_no_history_yes     = dc_`d'_card_gotit==0 & dc_`d'_history_gotit==1 if dc_has_card_has_hist==1  

			gen `d'_register_history_yes    = dc_`d'_reg_gotit==1 & dc_`d'_history_gotit==1 if dc_has_reg_has_hist==1  
			gen `d'_register_history_no     = dc_`d'_reg_gotit==0 & dc_`d'_history_gotit==0 if dc_has_reg_has_hist==1  
			gen `d'_register_yes_history_no = dc_`d'_reg_gotit==1 & dc_`d'_history_gotit==0 if dc_has_reg_has_hist==1  
			gen `d'_register_no_history_yes = dc_`d'_reg_gotit==0 & dc_`d'_history_gotit==1 if dc_has_reg_has_hist==1  
			
		}
		 
		foreach d in `=lower("$RI_DOSE_LIST")'  {
			foreach var in 	`d'_card_register_yes    `d'_card_register_no    `d'_card_yes_register_no    `d'_card_no_register_yes ///
							`d'_card_history_yes     `d'_card_history_no     `d'_card_yes_history_no     `d'_card_no_history_yes ///
							`d'_register_history_yes `d'_register_history_no `d'_register_yes_history_no `d'_register_no_history_yes {
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
