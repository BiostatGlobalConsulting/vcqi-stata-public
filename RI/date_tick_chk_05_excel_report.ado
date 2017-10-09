*! date_tick_chk_05_excel_report version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define date_tick_chk_05_excel_report
	version 14.1

	local oldvcp $VCP
	global VCP date_tick_chk_05_excel_report
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noisily display "Writing DOB & date quality results to Excel..."
	
	quietly {
	
		set more off
		use dt_dob_present, clear
		append using dt_doses_concordance

		* Drop if type is combined for first part of tables...
		drop if type == "card-register"
		drop if type == "card-history"
		drop if type == "register-history"

		* Create variable to identify which table the data will belong to (dob or dose name)
		gen table = d

		* drop if contains the number of doses received
		drop if strpos(var,"num_doses")>0

		* Create variable to show the type of data
		gen q=""

		* Create variable to show what row the data belongs in
		gen rowcount=.

		* Create variable to show what group the row belongs to 
		* (which will add up to a new denominator/100%)
		gen group=""

		foreach t in card register history {
			if "`t'"=="register" {
				local s reg
			}
			else {
				local s `t'
			}
			
			replace q = "How many do not have data from source?" if var=="dc_`s'_no"  
			replace rowcount = 1 if var=="dc_`s'_no" 
			replace group = "P1" if rowcount == 1
			
			replace type="`t'" if var=="dc_`s'_no"

			replace q = "How many have data from source?" if var=="dc_`s'_yes"
			replace rowcount = 2 if var=="dc_`s'_yes"
			replace group = "P1" if rowcount == 2

			replace type="`t'" if var=="dc_`s'_yes"

			foreach d in dob `=lower("$RI_DOSE_LIST")' {
				
				replace q = "How many missing?" if var=="ct_`d'_`t'_miss"
				replace rowcount = 3 if var=="ct_`d'_`t'_miss"
				replace group = "P2" if rowcount == 3

				replace q = "How many partialy missing?" if var=="ct_`d'_`t'_parmiss" 
				replace rowcount = 4 if var=="ct_`d'_`t'_parmiss"
				replace group = "P2" if rowcount == 4

				replace q = "How many full dates?" if var=="ct_`d'_`t'_full"
				replace rowcount = 5 if var=="ct_`d'_`t'_full"
				replace group = "P2" if rowcount == 5
				
				replace q = "How many full, but nonsensical dates?"  if var=="ct_`d'_`t'_nonsense"
				replace rowcount = 6 if var=="ct_`d'_`t'_nonsense"
				replace group = "P3" if rowcount == 6

				replace q = "How many full and sensible dates?"  if var=="ct_`d'_`t'_sense"
				replace rowcount = 7 if var=="ct_`d'_`t'_sense"
				replace group = "P3" if rowcount == 7
				
				replace q = "How many sensible dates prior to earliest possible date?"  if var=="ct_`d'_`t'_too_early"
				replace rowcount = 8 if var=="ct_`d'_`t'_too_early"
				replace group = "P4" if rowcount == 8
									
				replace q = "How many sensible dates past survey date?"  if var=="ct_`d'_`t'_late"
				replace rowcount = 9 if var=="ct_`d'_`t'_late"
				replace group = "P4" if rowcount == 9
			
				replace q = "How many sensible dates within proper range?"  if var=="ct_`d'_`t'_within_range"
				replace rowcount = 10 if var=="ct_`d'_`t'_within_range"
				replace group = "P4" if rowcount == 10

				replace q = "Tick mark: Yes" if var=="ct_`d'_`t'_tick"
				replace rowcount = 11 if var=="ct_`d'_`t'_tick"

			}
		}

		* Create variables to populate table values

		* Create variable for the N value for each column
		gen num=n_1

		* Create variable that shows the percent that fit the category over 
		* all that it applies to... using n_1 and n_01.. need to adjust code 
		* that calculates
		gen percent=n_1/n_01
		replace percent =0 if missing(percent)
		gen denom=n_01

		* drop unneeded variables
		drop n_* d var
		keep if rowcount!=.

		* Reshape table
		reshape wide num percent denom, i(table rowcount) j(type) string

		sort table rowcount  
		order table rowcount q

		* Set labels to be used for column headers
		label variable q " "
		label variable numcard "n"
		label variable percentcard "%" 
		label variable denomcard "denom"  
		label variable numreg "n" 
		label variable percentreg "%" 
		label variable denomreg  "denom" 
		label variable numhistory   "n" 
		label variable percenthistory "%"  
		label variable denomhistory "denom" 
		label variable group	"group"

		* Replace the values with 0 if not applicable
		foreach v in num percent denom {
			foreach s in card reg {
				replace `v'`s'=0 if missing(`v'`s') 
			}
		}

		* save dataset to be used for summary page
		save completeness_dataset, replace 

		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS completeness_dataset

		* Start with a clean, empty Excel file for tabulated output (TO)
		capture erase "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx"	
		sleep 1000
		* Export to separate spreadsheet tab for each dose- for first table: Data present
		foreach d in  DOB `=upper("$RI_DOSE_LIST")'{
			export excel q numcard percentcard denomcard ///
						 numreg percentreg denomreg ///
						 numhistory  percenthistory denomhistory group using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
			   if table==lower("all"), sheet("`d'", modify) cell(A2)  firstrow(varlabels) 
			noisily di "Writing info re: data present for `d'..."
			sleep 1000
		}	

		* Export to separate spreadsheet tab for each dose- for first table: Data present
		foreach d in  DOB `=upper("$RI_DOSE_LIST")' {
			export excel q numcard percentcard denomcard ///
						 numreg percentreg denomreg ///
						 numhistory  percenthistory denomhistory group using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
			   if table==lower("`d'"), sheet("`d'", modify) cell(A5)  
			noisily di "Writing info re: data complete for `d'..."
			sleep 1000
			   
		}	

		* Take dataset and collapse by 
		* Export the count for each source into the first two columns
		export excel q numcard percentcard denomcard ///
					 numreg percentreg denomreg ///
					 numhistory  percenthistory denomhistory group using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
		   if table==lower("all"), sheet("DOSE SUMMARY", modify) cell(A2) firstrow(varlabels) 
		noisily di "Writing dose summary info..."  
		sleep 1000
		   
		* drop the above two rows from the dataset
		drop if table=="all"
		drop percent* table
	  
		* summarize the numerators and denominators of all doses for the summary tab
		collapse (sum) numcard denomcard numhistory denomhistory numregister denomregister, by(rowcount q group)
	  
		* Calculate the percent for summary tab
		foreach s in card history register {
			gen percent`s'=num`s'/denom`s'
			order percent`s', after(num`s')
		}

		* Export Completeness data for summarized data across all doses to Summary tab
		export excel q numcard percentcard denomcard ///
					 numregister percentregister denomregister ///
					 numhistory  percenthistory denomhistory group using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx", ///
					sheet("DOSE SUMMARY", modify) cell(A5)  
		sleep 1000
				

		********************************************************************************
		* Export data for DOB Concordance 
		
		use dt_dob_concordance, clear

		* Create variable to identify type of data and what row it belongs to in the table
		gen q = "Card/register?" if var=="ct_dob_card_register"
		gen rowcount = 1 if var=="ct_dob_card_register"

		replace q = "Card/history?" if var=="ct_dob_card_history"
		replace rowcount = 2 if var=="ct_dob_card_history"

		replace q = "Register/history?" if var=="ct_dob_register_history"
		replace rowcount = 3 if var=="ct_dob_register_history"

		* Create variable to show the total in that category and percent over total that applies
		gen num=n_1
		replace num=0 if num==.
		gen percent=n_1/n_01
		replace percent=0 if percent==.
		gen denom=n_01
		replace denom=0 if denom==.

		* Create variable labels for column headers in table	
		label variable q "How many full dates disagree between"
		label variable num "n"
		label variable percent "%"
		label variable denom "denom"

		sort rowcount

		export excel  q num percent denom using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx", ///
				sheet("DOB", modify) cell(A18)  firstrow(varlabels) 
		noisily di "Writing info re: DOB concordance..."
		sleep 1000

		********************************************************************************
		* Export data for DOB sensible dose calculations 
		use dt_dob_sensible_dob_calculations, clear

		* Create variable to show what data is being looked at- How many chilren do not have dobs...
		gen  q = "How many DOBs not assigned?" if var=="ct_dob_no_valid_dose_calc"
		gen rowcount = 1 if var=="ct_dob_no_valid_dose_calc"

		* Create variable to show what data is being looked at- How many chilren have dobs...
		replace  q = "How many DOBs assigned?" if var=="ct_dob_yes_valid_dose_calc"
		replace rowcount = 2 if var=="ct_dob_yes_valid_dose_calc"

		* Row 2 show how many are using the min of the dates
		replace q = "How many assigned using 'min'?" if var=="ct_dob_min_valid_dose_calc"
		replace rowcount = 3 if var=="ct_dob_min_valid_dose_calc"

		* Row 3 show how many had a single birthdate
		replace q = "How many assigned using single birthdate?" if var=="unambiguous_dob"
		replace rowcount = 4 if var=="unambiguous_dob"

		* Create variables to populate these values for each category above
		gen num=n_1
		replace num=0 if num==.
		gen percent=n_1/n_01
		replace percent=0 if percent==.
		gen denom=n_01
		replace denom=0 if denom==.
			
		* Create labels to use as column headers for table.
		label variable q "Assigned for sensible dose calculations"
		label variable num "n"
		label variable percent "%"
		label variable denom "denom"

		sort rowcount

		export excel  q num percent denom using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx", ///
				sheet("DOB", modify) cell(A24)  firstrow(varlabels) 
				
		sleep 1000

		********************************************************************************
		* Export Dose Concordance data 
		set trace off
		use dt_doses_concordance, clear

		* keep types to show the different combinations
		keep if type=="card-register" | type=="card-history" | type=="register-history"

		* Create variable to show what table the data will belong in
		gen table = d

		* Create variable that shows the number are in that category
		gen num=n_1

		* Create variable that shows the total number possible for that category
		gen denom=n_01
		 
		* Create variable that will show the different concordence and row to show where placement will be in this table
		gen q=""
		gen rowcount=.
		gen group=""

		* Replace q with the concodence looked at that will be used in the table
		replace q = "1. Have neither card or register" if var=="dc_no_card_no_reg" & type=="card-register"
		replace rowcount = 1 if var=="dc_no_card_no_reg" & type=="card-register"
		replace group="CR1" if rowcount==1 & type=="card-register"
										   
		replace q = "2. Have card but no register"  if var=="dc_has_card_no_reg" & type=="card-register" 
		replace rowcount = 2 if var=="dc_has_card_no_reg" & type=="card-register"
		replace group="CR1" if rowcount==2 & type=="card-register"
		
		replace q = "3. Have register but no card"  if var=="dc_no_card_has_reg" & type=="card-register"
		replace rowcount = 3 if var=="dc_no_card_has_reg" & type=="card-register"
		replace group="CR1" if rowcount==3 & type=="card-register"
		
		replace q = "4. Have both card and register"  if var=="dc_has_card_has_reg" & type=="card-register" 
		replace rowcount = 4 if var=="dc_has_card_has_reg" & type=="card-register"
		replace group="CR1" if rowcount==4 & type=="card-register"
			
		foreach d in `=lower("$RI_DOSE_LIST")' {
			replace q = "        4.1. Card&Register agree: did not get it" if var=="dc_cr_`d'_nogotit_both" & type=="card-register" 
			replace rowcount = 5 if var=="dc_cr_`d'_nogotit_both"  & type=="card-register"
			replace group="CR2" if rowcount==5 & type=="card-register"
			
			replace q = "        4.2. Card&Register agree: got it" if var=="dc_cr_`d'_gotit_both" & type=="card-register" 
			replace rowcount = 6 if var=="dc_cr_`d'_gotit_both"  & type=="card-register"
			replace group="CR2" if rowcount==6 & type=="card-register"
			
			replace q = "           4.2.1. Card&Register agree: perfect agreement on date or tick" if var=="dc_cr_`d'_gotit_perfect_agr" & type=="card-register" 
			replace rowcount = 7 if var=="dc_cr_`d'_gotit_perfect_agr" & type=="card-register"
			replace group="CR3" if rowcount==7 & type=="card-register"
			
			replace q = "           4.2.2. Card&Register agree: but some discordance about evidence" if var=="dc_cr_`d'_gotit_discord_dates" & type=="card-register"
			replace rowcount = 8 if var=="dc_cr_`d'_gotit_discord_dates" & type=="card-register"
			replace group="CR3" if rowcount==8 & type=="card-register"
			
			replace q = "               4.2.2.1.  both have full dates that disagree" if var=="dc_cr_`d'_fulldates_disag" & type=="card-register" 
			replace rowcount = 9 if var=="dc_cr_`d'_fulldates_disag" & type=="card-register"
			replace group="CR4" if rowcount==9 & type=="card-register"
			
			replace q = "               4.2.2.2.  both have partial dates that disagree" if var=="dc_cr_`d'_pardates_disag" & type=="card-register" 
			replace rowcount = 10 if var=="dc_cr_`d'_pardates_disag" & type=="card-register"
			replace group="CR4" if rowcount==10 & type=="card-register"
			
			replace q = "               4.2.2.3.  one full and one partial date" if var=="dc_cr_`d'_1full_1par_disag" & type=="card-register" 
			replace rowcount = 11 if var=="dc_cr_`d'_1full_1par_disag" & type=="card-register"
			replace group="CR4" if rowcount==11 & type=="card-register"
			
			replace q = "               4.2.2.4.  one date (full or partial) and one tick" if var=="dc_cr_`d'_1date_1tick_disag" & type=="card-register" 
			replace rowcount = 12 if var=="dc_cr_`d'_1date_1tick_disag" & type=="card-register"
			replace group="CR4" if rowcount==12 & type=="card-register"
			
			replace q = "        4.3. Card&Register disagree:One got it, Other did not" if var=="dc_cr_`d'_onegotit" & type=="card-register" 
			replace rowcount = 13 if var=="dc_cr_`d'_onegotit" & type=="card-register"
			replace group="CR2" if rowcount==13 & type=="card-register"
			
			replace q = "       	4.3.1 Card got it, Register did not" if var=="dc_cr_`d'_cardgotit_noreg" & type=="card-register"
			replace rowcount = 14 if var=="dc_cr_`d'_cardgotit_noreg" & type=="card-register"
			replace group="CR5" if rowcount==14 & type=="card-register"
			
			replace q = "       	4.3.2 Card did not get it, Register did" if var=="dc_cr_`d'_reggotit_nocard" & type=="card-register" 
			replace rowcount = 15 if var=="dc_cr_`d'_reggotit_nocard" & type=="card-register"
			replace group="CR5" if rowcount==15 & type=="card-register"
		}
		********************************************************************************


		replace q = "1. Have neither card or history" if var=="dc_no_card_no_hist" & type=="card-history"
		replace rowcount = 1 if var=="dc_no_card_no_hist" & type=="card-history"
		replace group="CH1" if rowcount==1 & type=="card-history"

		replace q = "2. Have card but no history"  if var=="dc_has_card_no_hist" & type=="card-history"
		replace rowcount = 2 if var=="dc_has_card_no_hist" & type=="card-history"
		replace group="CH1" if rowcount==2 & type=="card-history"
		
		replace q = "3. Have history but no card"  if var=="dc_no_card_has_hist" & type=="card-history"
		replace rowcount = 3 if var=="dc_no_card_has_hist" & type=="card-history"
		replace group="CH1" if rowcount==3 & type=="card-history"
		
		replace q = "4. Have both card and history"  if var=="dc_has_card_has_hist" & type=="card-history"
		replace rowcount = 4 if var=="dc_has_card_has_hist" & type=="card-history"
		replace group="CH1" if rowcount==4 & type=="card-history"
			
		foreach d in `=lower("$RI_DOSE_LIST")' {
			
			replace q = "        4.1. Card&History agree: did not get it" if var=="dc_ch_`d'_nogotit_both" & type=="card-history"
			replace rowcount = 5 if var=="dc_ch_`d'_nogotit_both"  & type=="card-history"
			replace group="CH2" if rowcount==5 & type=="card-history"

			replace q = "        4.2. Card&History agree: got it" if var=="dc_ch_`d'_gotit_both" & type=="card-history"
			replace rowcount = 6 if var=="dc_ch_`d'_gotit_both"  & type=="card-history"
			replace group="CH2" if rowcount==6 & type=="card-history"
			
			replace q = "        4.3. Card&History one got it, other not" if var=="dc_ch_`d'_onegotit" & type=="card-history"
			replace rowcount = 7 if var=="dc_ch_`d'_onegotit"  & type=="card-history"
			replace group="CH2" if rowcount==7 & type=="card-history"
			
			replace q = "        	4.3.1 Card got it, history did not" if var=="dc_ch_`d'_c_yes_h_no" & type=="card-history"
			replace rowcount = 8 if var=="dc_ch_`d'_c_yes_h_no"  & type=="card-history"
			replace group="CH3" if rowcount==8 & type=="card-history"
			
			replace q = "        	4.3.2 History got it, card did not" if var=="dc_ch_`d'_h_yes_c_no" & type=="card-history"
			replace rowcount = 9 if var=="dc_ch_`d'_h_yes_c_no"  & type=="card-history"
			replace group="CH3" if rowcount==9 & type=="card-history"

		}
		********************************************************************************

		replace q = "1. Have neither reg or history" if var=="dc_no_reg_no_hist" & type=="register-history"
		replace rowcount = 1 if var=="dc_no_reg_no_hist" & type=="register-history"
		replace group="RH1" if rowcount==1 & type=="register-history"

		replace q = "2. Have reg but no history"  if var=="dc_has_reg_no_hist" & type=="register-history"
		replace rowcount = 2 if var=="dc_has_reg_no_hist" & type=="register-history"
		replace group="RH1" if rowcount==2 & type=="register-history"
		
		replace q = "3. Have history but no reg"  if var=="dc_no_reg_has_hist" & type=="register-history"
		replace rowcount = 3 if var=="dc_no_reg_has_hist" & type=="register-history"
		replace group="RH1" if rowcount==3 & type=="register-history"
		
		replace q = "4. Have both reg and history"  if var=="dc_has_reg_has_hist" & type=="register-history"
		replace rowcount = 4 if var=="dc_has_reg_has_hist" & type=="register-history"
		replace group="RH1" if rowcount==4 & type=="register-history"
			
		foreach d in `=lower("$RI_DOSE_LIST")' {
			
			replace q = "        4.1. Register&History agree: did not get it" if var=="dc_rh_`d'_nogotit_both" & type=="register-history"
			replace rowcount = 5 if var=="dc_rh_`d'_nogotit_both"  & type=="register-history"
			replace group="RH2" if rowcount==5 & type=="register-history"

			replace q = "        4.2. Register&History agree: got it" if var=="dc_rh_`d'_gotit_both" & type=="register-history"
			replace rowcount = 6 if var=="dc_rh_`d'_gotit_both"  & type=="register-history"
			replace group="RH2" if rowcount==6 & type=="register-history"
			
			replace q = "        4.3. Register&History one got it, other not" if var=="dc_rh_`d'_onegotit" & type=="register-history"
			replace rowcount = 7 if var=="dc_rh_`d'_onegotit"  & type=="register-history"
			replace group="RH2" if rowcount==7 & type=="register-history"
			
			replace q = "        	4.3.1 Register got it, history did not" if var=="dc_rh_`d'_r_yes_h_no" & type=="register-history"
			replace rowcount = 8 if var=="dc_rh_`d'_r_yes_h_no"  & type=="register-history"
			replace group="RH3" if rowcount==8 & type=="register-history"
			
			replace q = "        	4.3.2 History got it, register did not" if var=="dc_rh_`d'_h_yes_r_no" & type=="register-history"
			replace rowcount = 9 if var=="dc_rh_`d'_h_yes_r_no"  & type=="register-history"
			replace group="RH3" if rowcount==9 & type=="register-history"

		}
		********************************************************************************

		* Create variable that shows the percent that fit the category over all that it applies to... using n_1 and n_01
		gen percent=n_1/n_01
		replace percent =0 if missing(percent)

		* drop unneeded variables
		drop n_* d var
		keep if rowcount!=.

		sort table rowcount  
		order table rowcount q

		* Set labels to be used for column headers
		label variable q " "
		label variable num "n"
		label variable percent "%" 
		label variable denom "denom"  
		label variable group	"group"

		local crh "card-register card-history register-history"
		local numcell_singledose 20 38 50

		local n : word count `crh'
		di "`n'"

		forvalues i = 1/`n' {
			local a : word `i' of `crh'
			local b : word `i' of `numcell_singledose'
			
			di "`a'"
			di "`b'"

			local qlab `=strproper(subinstr("`a'","-"," & ",.))'
			di "`qlab'"

			label variable q "`qlab'"
			
			noisily di "Writing info re: concordance between `a'..."

			foreach d in `=upper("$RI_DOSE_LIST")' {
				export excel q num percent denom group using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("all") & type=="`a'", sh("`d'", modify) cell(A`b') firstrow(varlabels) 
				sleep 1000 
			}
				   
				   
			foreach d in `=upper("$RI_DOSE_LIST")' {
				export excel q num percent denom group using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'") & type=="`a'", sh("`d'", modify) cell(A`=`b'+5') 
				sleep 1000 
			}
		}


		********************************************************************************
		********************************************************************************
		* Code to create table to show number of doses received
		set more off
		use dt_dob_present, clear
		append using dt_doses_concordance

		* drop if contains the number of doses received
		keep if type=="num_doses"

		* Create variable to identify which table the data will belong to (dose name)
		gen table = d

		* Replace var to remove dose names for reshaping purposes
		foreach d in `=lower("$RI_DOSE_LIST")' {
			replace var = subinstr(var,"`d'_","",.) if strpos(var, "`d'_")>0
		}

		* Collapse dataset to obtain summarized data
		collapse (sum) n_1, by(table var)

		* replace history and register to shorter terms to avoid errors in reshaping due to exceeding character limit
		foreach v in history register {
			if "`v'"=="history" {
				local i hist
			}
			else if "`v'"=="register" {
				local i reg
			}
			replace var= subinstr(var, "`v'","`i'",.)
		}

		* Reshape table to align with desired table format...
		reshape wide n_1, i(table) j(var) string

		* Remove n_1 from variable names
		foreach d in card_hist_no card_hist_yes card_no_hist_yes card_no_reg_yes ///
					 card_reg_no card_reg_yes card_yes_hist_no card_yes_reg_no ///
					 reg_hist_no reg_hist_yes reg_no_hist_yes reg_yes_hist_no {
					
			rename n_1`d' `d'
		}

		* Export to summarized data to excel
		local r 24

		noisily di "Writing info re: dose summary..."

		foreach d in `=lower("$RI_DOSE_LIST")' {
			* Create matrix for card and register
			export excel card_reg_yes card_no_reg_yes  using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(B`r') 
			sleep 1000 

			export excel  card_yes_reg_no card_reg_no using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(B`=`r' + 1') 


			* Create matrix for card and hist
			export excel card_hist_yes card_no_hist_yes  using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(F`r') 
			sleep 1000 

			export excel card_yes_hist_no card_hist_no using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(F`=`r' + 1') 


			* Create matrix for reg and hist
			export excel reg_hist_yes  reg_no_hist_yes  using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(J`r') 
			sleep 1000 

			export excel reg_yes_hist_no reg_hist_no using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(J`=`r' + 1') 
				   
			local r `=`r' + 6'	   
		}	
		********************************************************************************
		********************************************************************************

		noisily di "Formatting worksheets..."		
		
		* Use mata to populate column labels and worksheet titles and footnotes for each SINGLE DOSE
		mata: b = xl()
		mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx")
		mata: b.set_mode("open")

		mata: b.set_sheet("DOB")

		* Fill in table text in DOB sheet
		mata: b.put_string(1, 1, "DOB: Present")
		mata: b.set_font_bold(1, 1, "on")
		mata: b.put_string(1, 2,"Card")	
		mata: b.put_string(1, 5,"Register")	
		mata: b.put_string(1, 8,"History")

		* Merge cells
		mata: b.set_sheet_merge("DOB", (1, 2), (1, 1))
		mata: b.set_sheet_merge("DOB", (1, 1), (2, 4))
		mata: b.set_sheet_merge("DOB", (1, 1), (5, 7))
		mata: b.set_sheet_merge("DOB", (1, 1), (8, 10))

		* Center headers
		mata: b.set_horizontal_align((1, 2),(1, 1),"left")
		mata: b.set_horizontal_align(1,(2, 4),"center")
		mata: b.set_horizontal_align(1,(5, 7),"center")
		mata: b.set_horizontal_align(1,(8, 11),"center")

		mata: b.set_horizontal_align(2,(2, 11),"center")
		mata: b.set_horizontal_align(18,(2, 11),"center")
		mata: b.set_horizontal_align(24,(2, 11),"center")

		* align group data to the right like all other text
		mata: b.set_horizontal_align((3,13),(11,11),"right")

		* Add color fill
		mata: b.set_fill_pattern((1,2),(1,11),"solid","lightgray")
		mata: b.set_fill_pattern(18,(1,4),"solid","lightgray")
		mata: b.set_fill_pattern(24,(1,4),"solid","lightgray")

		* Add Footnotes
		mata: b.put_string(13,1,"Note: Nonsensical dates refer to participants who had all three date components that did not result a calendar date... eg 2/29/2012, 6/31/2014, 14/2/0214 etc.")
		mata: b.set_font_italic(13,1,"on")
		mata: b.set_font_bold(13,1,"on")

		mata: b.put_string(14,1,"Note: Sensible dates refer to participants who had all three date components that resulted in a true calendar date... eg 2/28/2012, 6/1/2014 etc.")
		mata: b.set_font_italic(14,1,"on")
		mata: b.set_font_bold(14,1,"on")

		mata: b.put_string(15,1,"Note: If the pink cells hold non-zero numbers, that is an indication of incomplete or nonsensical dates.")
		mata: b.set_font_italic(15,1,"on")
		mata: b.set_font_bold(15,1,"on")

		mata: b.put_string(16,1,"Note: Within each group, the numbers in the `n' column must sum up to the denominator and the % numbers add up to 100%. The rows within each group are mutually exclusive and exhaustive.")
		mata: b.set_font_italic(16,1,"on")
		mata: b.set_font_bold(16,1,"on")

		* Shade cells if they are greater than zero, inidicating incomplete or nonsensical dates
		foreach d in 2 5 8 {
			mata: b.set_fill_pattern(5,`d',"solid","pink") 
			mata: b.set_fill_pattern(6,`d',"solid","pink") 
			mata: b.set_fill_pattern(8,`d',"solid","pink") 
			mata: b.set_fill_pattern(10,`d',"solid","pink") 
			mata: b.set_fill_pattern(11,`d',"solid","pink") 
		}
			
		*****************************************************************************
			
		mata: b.put_string(18, 1, "Date disconcordance: Full date DOBs disagree")
		mata: b.set_font_bold(18, 1, "on")
		mata: b.set_font_bold(24, 1, "on")
		
		* Shade cells if greater than zero, indicating incomplete or nonsensical dates
		foreach d in 19 20 21 {
			mata: b.set_fill_pattern(`d',2,"solid","pink") 
		}

		* Foot Notes
		mata: b.put_string(22,1,"Note: If the pink cells hold non-zero numbers, that is an indication of date discordance")
		mata: b.set_font_italic(22,1,"on")
		mata: b.set_font_bold(22,1,"on")

		mata: b.put_string(29,1,"Note: If card, register & history yield 2+ birthdates then VCQI assigned the `min' or earliest plausible birthdate for valid dose calculations.")
		mata: b.set_font_italic(29,1,"on")
		mata: b.set_font_bold(29,1,"on")

		*Set borders
		mata: b.set_left_border((1,12),(1,1), "medium","black")
		mata: b.set_right_border((1,12),(11,11), "medium","black")
		mata: b.set_top_border((1,1),(1,11), "medium","black")
		mata: b.set_bottom_border((12,12),(1,11), "medium","black")
		
		mata: b.set_left_border((18,21),(1,1), "medium","black")
		mata: b.set_right_border((18,21),(4,4), "medium","black")
		mata: b.set_top_border((18,18),(1,4), "medium","black")
		mata: b.set_bottom_border((21,21),(1,4), "medium","black")
		
		mata: b.set_left_border((24,28),(1,1), "medium","black")
		mata: b.set_right_border((24,28),(4,4), "medium","black")
		mata: b.set_top_border((24,24),(1,4), "medium","black")
		mata: b.set_bottom_border((28,28),(1,4), "medium","black")
		
		* Make borders for card, register and history...
		mata: b.set_right_border((1,12),(4,4), "thin","black")
		mata: b.set_right_border((1,12),(7,7), "thin","black")
		mata: b.set_right_border((1,12),(10,10), "thin","black")
		
		mata: b.set_column_width(1, 1, 50)
		
		foreach num of numlist 1/100 {
			 mata: b.set_number_format(`num', 3, "percent")
			 mata: b.set_number_format(`num', 6, "percent")
			 mata: b.set_number_format(`num', 9, "percent")
		}							   
										   
		sleep 1000
		********************************************************************************
		********************************************************************************
		* Dose table formatting
		foreach d in  `=upper("$RI_DOSE_LIST")' {

			mata: b.set_sheet("`d'")

			mata: b.put_string(1, 1, "`d': Present")
			mata: b.set_font_bold(1, 1, "on")
			mata: b.put_string(1, 2,"Card")	
			mata: b.put_string(1, 5,"Register")	
			mata: b.put_string(1, 8,"History")
			mata: b.set_fill_pattern(1,(1,11),"solid","lightgray")
			
			* Merge cells
			mata: b.set_sheet_merge("`d'", (1, 2), (1, 1))
			mata: b.set_sheet_merge("`d'", (1, 1), (2, 4))
			mata: b.set_sheet_merge("`d'", (1, 1), (5, 7))
			mata: b.set_sheet_merge("`d'", (1, 1), (8, 10))
			
			* Center headers
			mata: b.set_horizontal_align(1,(2, 4),"center")
			mata: b.set_horizontal_align(1,(5, 7),"center")
			mata: b.set_horizontal_align(1,(8, 10),"center")
			
			mata: b.set_horizontal_align(2,(2, 11),"center")
			mata: b.set_fill_pattern(2,(1,11),"solid","lightgray")

			mata: b.set_horizontal_align(20,(2, 5),"center")
			mata: b.set_fill_pattern((19,20),(1,5),"solid","lightgray")

			mata: b.set_horizontal_align(38,(2, 5),"center")
			mata: b.set_fill_pattern(38,(1,5),"solid","lightgray")
			
			mata: b.set_horizontal_align(50,(2, 5),"center")
			mata: b.set_fill_pattern(50,(1,5),"solid","lightgray")
			
			* align group data to the right like all other text
			mata: b.set_horizontal_align((3,13),(11,11),"right")
			mata: b.set_horizontal_align((21,35),(5,5),"right")
			mata: b.set_horizontal_align((39,47),(5,5),"right")
			mata: b.set_horizontal_align((51,59),(5,5),"right")

			mata: b.set_column_width(1,1,70)
			
			mata: b.put_string(19, 1, "`d': Concordance of evidence")
			mata: b.set_font_bold(19, 1, "on")
			
			****************************************************************************
			* Add Footnotes
			mata: b.put_string(14,1,"Note: Nonsensical dates refer to participants who had all three date components that did not result a calendar date... eg 2/29/2012, 6/31/2015, 15/2/0215 etc.")
			mata: b.set_font_italic(14,1,"on")
			mata: b.set_font_bold(14,1,"on")
			
			mata: b.put_string(15,1,"Note: Sensible dates refer to participants who had all three date components that resulted in a true calendar date... eg 2/28/2012, 6/1/2015 etc.")
			mata: b.set_font_italic(15,1,"on")
			mata: b.set_font_bold(15,1,"on")

			mata: b.put_string(16,1,"Note: If the pink cells hold non-zero numbers, that is an indication of incomplete or nonsensical dates.")
			mata: b.set_font_italic(16,1,"on")
			mata: b.set_font_bold(16,1,"on")

			mata: b.put_string(17,1,"Note: Within each group, the numbers in the `n' column must sum up to the denominator and the % numbers add up to 100%. The rows within each group are mutually exclusive and exhaustive.")
			mata: b.set_font_italic(17,1,"on")
			mata: b.set_font_bold(17,1,"on")
			
			mata: b.put_string(36,1,"Note: If the pink cells hold non-zero numbers, that is an indication of discordance between sources.")
			mata: b.set_font_italic(36,1,"on")
			mata: b.set_font_bold(36,1,"on")
			
			mata: b.put_string(48,1,"Note: If the pink cells hold non-zero numbers, that is an indication of discordance between sources.")
			mata: b.set_font_italic(48,1,"on")
			mata: b.set_font_bold(48,1,"on")

			mata: b.put_string(60,1,"Note: If the pink cells hold non-zero numbers, that is an indication of discordance between sources.")
			mata: b.set_font_italic(60,1,"on")
			mata: b.set_font_bold(60,1,"on")

			* Shade cells if they are greater than zero, inidicating incomplete or nonsensical dates
			foreach d in 2 5 8 {
				mata: b.set_fill_pattern(5,`d',"solid","pink") 
				mata: b.set_fill_pattern(6,`d',"solid","pink") 
				mata: b.set_fill_pattern(8,`d',"solid","pink") 
				mata: b.set_fill_pattern(10,`d',"solid","pink") 
				mata: b.set_fill_pattern(11,`d',"solid","pink") 
			}
			
			foreach d in 38 50 {
				mata: b.set_fill_pattern(`=`d' + 7',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 8',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 9',2,"solid","pink") 
			}
			
			foreach d in 20 {
				mata: b.set_fill_pattern(`=`d' + 8',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 9',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 10',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 11',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 12',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 13',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 14',2,"solid","pink") 
				mata: b.set_fill_pattern(`=`d' + 15',2,"solid","pink") 
			}

			****************************************************************************
			
			*Set borders
			mata: b.set_left_border((1,13),(1,1), "medium","black")
			mata: b.set_right_border((1,13),(11,11), "medium","black")
			mata: b.set_top_border((1,1),(1,11), "medium","black")
			mata: b.set_bottom_border((13,13),(1,11), "medium","black")
			
			mata: b.set_left_border((19,35),(1,1), "medium","black")
			mata: b.set_right_border((19,35),(5,5), "medium","black")
			mata: b.set_top_border((19,19),(1,5), "medium","black")
			mata: b.set_bottom_border((35,35),(1,5), "medium","black")
			
			mata: b.set_left_border((38,47),(1,1), "medium","black")
			mata: b.set_right_border((38,47),(5,5), "medium","black")
			mata: b.set_top_border((38,38),(1,5), "medium","black")
			mata: b.set_bottom_border((47,47),(1,5), "medium","black")
			
			mata: b.set_left_border((50,59),(1,1), "medium","black")
			mata: b.set_right_border((50,59),(5,5), "medium","black")
			mata: b.set_top_border((50,50),(1,5), "medium","black")
			mata: b.set_bottom_border((59,59),(1,5), "medium","black")
			
			* Make borders for card, register and history...
			mata: b.set_right_border((1,13),(4,4), "thin","black")
			mata: b.set_right_border((1,13),(7,7), "thin","black")
			mata: b.set_right_border((1,13),(10,10), "thin","black")
			
			* Make borders to separate group from Concordance boxes
			mata: b.set_right_border((19,35),(4,4), "thin","black")
			mata: b.set_right_border((38,47),(4,4), "thin","black")
			mata: b.set_right_border((50,59),(4,4), "thin","black")
			
			foreach i in `numcell_singledose' {
				mata: b.set_font_underline(`i', 1, "on")
			}

			foreach num of numlist 1/100 {
				 mata: b.set_number_format(`num', 3, "percent")
				 mata: b.set_number_format(`num', 6, "percent")
				 mata: b.set_number_format(`num', 9, "percent")
			}
			sleep 1000 
			
		}
			
		***************************************************************************
		* Format the Dose summary page
		mata: b.set_sheet("DOSE SUMMARY")

		* Fill in table text in DOB sheet
		mata: b.put_string(1, 1, "Doses: Present")
		mata: b.set_font_bold(1, 1, "on")
		mata: b.put_string(1, 2,"Card")	
		mata: b.put_string(1, 5,"Register")	
		mata: b.put_string(1, 8,"History")
		
			* Merge cells
		mata: b.set_sheet_merge("DOSE SUMMARY", (1, 2), (1, 1))
		mata: b.set_sheet_merge("DOSE SUMMARY", (1, 1), (2, 4))
		mata: b.set_sheet_merge("DOSE SUMMARY", (1, 1), (5, 7))
		mata: b.set_sheet_merge("DOSE SUMMARY", (1, 1), (8, 10))

		* Add borders for first box
		mata: b.set_left_border((1,13),(1,1), "medium","black")
		mata: b.set_right_border((1,13),(11,11), "medium","black")
		mata: b.set_top_border((1,1),(1,11), "medium","black")
		mata: b.set_bottom_border((13,13),(1,11), "medium","black")

		* Make borders for card, register and history...
		mata: b.set_right_border((1,13),(4,4), "thin","black")
		mata: b.set_right_border((1,13),(7,7), "thin","black")
		mata: b.set_right_border((1,13),(10,10), "thin","black")
		
		* Shade first row of table
		mata: b.set_fill_pattern(1,(1,11),"solid","lightgray")
		
		* Center headers
		mata: b.set_horizontal_align(1,(2, 4),"center")
		mata: b.set_horizontal_align(1,(5, 7),"center")
		mata: b.set_horizontal_align(1,(8, 10),"center")
		
		mata: b.set_horizontal_align(2,(2, 11),"center")
		mata: b.set_fill_pattern(2,(1,11),"solid","lightgray")

		* align group data to the right like all other text
		mata: b.set_horizontal_align((3,13),(11,11),"right")
		
		****************************************************************************
		* Add Footnotes
		mata: b.put_string(14,1,"Note: Rows 3-4 count the number of participants of the entire survey as the denominator, while rows 5-13 look at all potential dates.")
		mata: b.set_font_italic(14,1,"on")
		mata: b.set_font_bold(14,1,"on")

		mata: b.put_string(15,1,"Note: Nonsensical dates refer to participants who had all three date components that did not result a calendar date... eg 2/29/2012, 6/31/2015, 15/2/0215 etc.")
		mata: b.set_font_italic(15,1,"on")
		mata: b.set_font_bold(15,1,"on")
		
		mata: b.put_string(16,1,"Note: Sensible dates refer to participants who had all three date components that resulted in a true calendar date... eg 2/28/2012, 6/1/2016 etc.")
		mata: b.set_font_italic(16,1,"on")
		mata: b.set_font_bold(16,1,"on")

		mata: b.put_string(17,1,"Note: If the pink cells hold non-zero numbers, that is an indication of incomplete or nonsensical dates.")
		mata: b.set_font_italic(17,1,"on")
		mata: b.set_font_bold(17,1,"on")

		mata: b.put_string(18,1,"Note: Within each group, the numbers in the `n' column must sum up to the denominator and the % numbers add up to 100%. The rows within each group are mutually exclusive and exhaustive.")
		mata: b.set_font_italic(18,1,"on")
		mata: b.set_font_bold(18,1,"on")
		
		* Shade cells if they are greater than zero, inidicating incomplete or nonsensical dates
		foreach d in 2 5 8 {
			mata: b.set_fill_pattern(5,`d',"solid","pink") 
			mata: b.set_fill_pattern(6,`d',"solid","pink") 
			mata: b.set_fill_pattern(8,`d',"solid","pink") 
			mata: b.set_fill_pattern(10,`d',"solid","pink") 
			mata: b.set_fill_pattern(11,`d',"solid","pink") 

		}
		
			
		* Put in a loop so that the row numbers adjust
		local r 24 
		
		* Set local to use as original starting point
		local i `r'
		
		* Add header for the below tabls
		mata: b.put_string(`=`r'-4', 1, "All Dates: Concordance of evidence")
		mata: b.set_font_bold(`=`r'-4', 1, "on")
		
		mata: b.put_string(`=`r'-3',1, "Dose Numbers: Comparison between sources")
		mata: b.set_font_bold(`=`r'-3', 1, "on")
		
		mata: b.set_sheet_merge("DOSE SUMMARY", (`=`r'-4',`=`r'-4'), (1, 4))
		mata: b.set_sheet_merge("DOSE SUMMARY", (`=`r'-3',`=`r'-3'), (1, 4))
		mata: b.set_fill_pattern((`=`r'-4',`=`r'-3'), (1, 11),"solid","lightgray") 

		foreach d in `=upper("$RI_DOSE_LIST")' { 
			
			local c 2
			
			*Add borders
			mata: b.set_left_border((`r',`=`r'+1'),(`c',`c'), "medium","black")
			mata: b.set_right_border((`r',`=`r'+1'),(`=`c'+1',`=`c'+1'), "medium","black")
			mata: b.set_top_border((`r',`r'),(`c',`=`c'+1'), "medium","black")
			mata: b.set_bottom_border((`=`r'+1',`=`r'+1'),(`c',`=`c'+1'), "medium","black")
			
			* Shade areas that would indicate discordance
			mata: b.set_fill_pattern(`r',`=`c'+1',"solid","pink") 
			mata: b.set_fill_pattern(`=`r'+1',`c',"solid","pink") 
			
			local c `=`c'+4'
			
			* Add borders
			mata: b.set_left_border((`r',`=`r'+1'),(`c',`c'), "medium","black")
			mata: b.set_right_border((`r',`=`r'+1'),(`=`c'+1',`=`c'+1'), "medium","black")
			mata: b.set_top_border((`r',`r'),(`c',`=`c'+1'), "medium","black")
			mata: b.set_bottom_border((`=`r'+1',`=`r'+1'),(`c',`=`c'+1'), "medium","black")
			
			* Shade areas that would indicate discordance
			mata: b.set_fill_pattern(`r',`=`c'+1',"solid","pink") 
			mata: b.set_fill_pattern(`=`r'+1',`c',"solid","pink") 

			local c `=`c'+4'
			
			* Add borders
			mata: b.set_left_border((`r',`=`r'+1'),(`c',`c'), "medium","black")
			mata: b.set_right_border((`r',`=`r'+1'),(`=`c'+1',`=`c'+1'), "medium","black")
			mata: b.set_top_border((`r',`r'),(`c',`=`c'+1'), "medium","black")
			mata: b.set_bottom_border((`=`r'+1',`=`r'+1'),(`c',`=`c'+1'), "medium","black")
			
			* Shade areas that would indicate discordance
			mata: b.set_fill_pattern(`r',`=`c'+1',"solid","pink") 
			mata: b.set_fill_pattern(`=`r'+1',`c',"solid","pink") 

			* Add footnote
			mata: b.put_string(`=`r'+2',1,"Note: If the pink cells hold non-zero numbers, that is an indication of discordance.")
			mata: b.set_font_italic(`=`r'+2',1,"on")
			mata: b.set_font_bold(`=`r'+2',1,"on")

			* Add Strings to identify tables and format strings
			
			mata: b.put_string(`=`r'-2',1,"`d'")
			mata: b.set_font_bold(`=`r'-2',1,"on")
			
			mata: b.put_string(`=`r'-2', 2,"Card & Register")
			mata: b.set_sheet_merge("DOSE SUMMARY", (`=`r'-2',`=`r'-2'), (2,3))


			mata: b.set_font_bold(`=`r'-2',2,"on")
			mata: b.set_horizontal_align(`=`r'-2',2,"right")

			mata: b.put_string(`=`r'-1', 2,"Card Yes")	
			mata: b.put_string(`=`r'-1', 3,"Card No")	
			mata: b.put_string(`r', 1,"Register Yes")
			mata: b.set_horizontal_align(`r', 1,"right")

			mata: b.put_string(`=`r'+1', 1,"Register No")
			mata: b.set_horizontal_align(`=`r' +1', 1,"right")

			mata: b.put_string(`=`r'-2', 6,"Card & History")
			
			mata: b.set_sheet_merge("DOSE SUMMARY", (`=`r'-2',`=`r'-2'), (6,7))
			mata: b.set_horizontal_align(`=`r'-2',6,"right")

			mata: b.set_font_bold(`=`r'-2',6,"on")
			
			mata: b.put_string(`=`r'-1', 6,"Card Yes")	
			mata: b.put_string(`=`r'-1', 7,"Card No")	
			mata: b.put_string(`r', 5,"History Yes")
			mata: b.set_horizontal_align(`r', 5,"right")

			mata: b.put_string(`=`r'+1', 5,"History No")
			mata: b.set_horizontal_align(`=`r'+1', 5,"right")
			
			mata: b.put_string(`=`r'-2', 10,"Register & History")
			mata: b.set_font_bold(`=`r'-2',10,"on")
			mata: b.set_sheet_merge("DOSE SUMMARY", (`=`r'-2',`=`r'-2'), (10,11))
			mata: b.set_horizontal_align(`=`r'-2',10,"right")
			
			mata: b.put_string(`=`r'-1', 10,"Register Yes")	
			mata: b.put_string(`=`r'-1', 11,"Register No")	
			mata: b.put_string(`r', 9,"History Yes")
			mata: b.set_horizontal_align(`r', 9,"right")

			mata: b.put_string(`=`r'+1', 9,"History No")
			mata: b.set_horizontal_align(`=`r'+1', 9,"right")
		
			mata: b.set_horizontal_align((`=`r'-2',`=`r'-2'),(2,11),"center")

			local r `=`r' + 6'
		}
			
		* Set borders
		mata: b.set_left_border((`=`i'-4',`=`r'-4'),(1,1), "medium","black")
		mata: b.set_right_border((`=`i'-4',`=`r'-4'),(`=`c'+1',`=`c'+1'), "medium","black")
		mata: b.set_top_border((`=`i'-4',`=`i'-4'),(1,`=`c'+1'), "medium","black")
		mata: b.set_bottom_border((`=`r'-4',`=`r'-4'),(1,`=`c'+1'), "medium","black")

		* format as a percent
		foreach num of numlist 1/14 {
			 mata: b.set_number_format(`num', 3, "percent")
			 mata: b.set_number_format(`num', 6, "percent")
			 mata: b.set_number_format(`num', 9, "percent")
		}

		* Set column width

		mata: b.set_column_width(1, 1, 70)

		mata: b.set_column_width(3,3, 11)
		mata: b.set_column_width(6,6, 11)
		mata: b.set_column_width(7, 7, 11)
		mata: b.set_column_width(10, 10, 11)
		mata: b.set_column_width(11, 11, 11)

		mata: b.close_book()	
	
	}
end		   

	
	

	
