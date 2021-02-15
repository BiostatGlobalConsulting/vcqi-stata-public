*! date_tick_chk_05_excel_report version 1.10 - Biostat Global Consulting - 2021-02-12
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2018-11-15	1.02	MK Trimner		Changed so register variables only created
*										if records sought &
* 										Cleaned up program and made subprograms
*										to remove duplicate code
* 2018-11-19	1.03	MK Trimner		Aligned register local with `ifreg'		
* 2020-08-04	1.04	MK Trimner		Added code for dose series quality report tabs
*										Added code to add right line in Dose summary top section to be consistent with other tabs
* 2020-10-07	1.05	Dale Rhoda		Changed `ifreg' to if "$RI_RECORDS_NOT_SOUGHT" != "1" in lines 1000 and 1063 
*                                       to clear a screwy curly-bracket error in Colombia 2005 run
* 2020-12-10	1.06	MK Trimner		Modified code to account for different denominators for DOB and DOSES for each source
*										Added footnotes to say excluding BCG Scar data
*										had to change formatting from rows being hard coded to being a little more flexible
*										Updated the label for Tick mark: Yes to clarify the difference between tick and history.
* 2021-01-25	1.07	Dale Rhoda		Fixed a typo in a row label
* 2021-01-30	1.08	MK Trimner		Added a new tab to summarize the categories for why VCQI changed dates to ticks
* 2020-02-07	1.09	MK Trimner		Added new column to VCQI changed dates to tick to include those changed due to later dose in series present.
* 2020-02-12 	1.10	Dale Rhoda		Change black fill in 'Dates changed to Ticks' to lightgray instead
*******************************************************************************

program define date_tick_chk_05_excel_report
	version 14.1

	local oldvcp $VCP
	global VCP date_tick_chk_05_excel_report
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	noisily display as text "Writing DOB & date quality results to Excel..."
	
	quietly {
	
		set more off
		use dt_dob_present, clear
		append using dt_doses_concordance
		append using dt_multi_series
				
		* Drop if type is combined for first part of tables...
		capture drop if type == "card-register"
		capture drop if type == "card-history"
		capture drop if type == "register-history"

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
		
		* Create variables for card and register comparison
		local ifreg if "$RI_RECORDS_NOT_SOUGHT" != "1" 
		local register
		local tick_label
		`ifreg'	local register register
		`ifreg' local tick_label " & Register"
		
		foreach t in card `register' history {
			if "`t'"=="register" {
				local s reg
			}
			else {
				local s `t'
			}
			
			foreach d in dob `=lower("$RI_DOSE_LIST")' {
				
				local type dose
				if "`d'"=="dob" local type dob
			
				replace q = "How many do not have data from source?" if var=="dc_`s'_`type'_no"  
				replace rowcount = 1 if var=="dc_`s'_`type'_no" 
				replace group = "P1" if rowcount == 1
				
				replace type="`t'" if var=="dc_`s'_`type'_no"

				replace q = "How many have data from source?" if var=="dc_`s'_`type'_yes"
				replace rowcount = 2 if var=="dc_`s'_`type'_yes"
				replace group = "P1" if rowcount == 2

				replace type="`t'" if var=="dc_`s'_`type'_yes"
				
				replace q = "How many missing?" if var=="ct_`d'_`t'_miss"
				replace rowcount = 3 if var=="ct_`d'_`t'_miss"
				replace group = "P2" if rowcount == 3

				replace q = "How many partially missing?" if var=="ct_`d'_`t'_parmiss" 
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

				replace q = "Tick mark: Yes (for Card`tick_label') or History: Yes (for History)" if var=="ct_`d'_`t'_tick"
				replace rowcount = 11 if var=="ct_`d'_`t'_tick"

			}
		}
				
		foreach t in card `register' {
			local multi2 
			local multi3
			if "$RI_MULTI_2_DOSE_LIST" == "" local multi2 `""""'			
			if "$RI_MULTI_3_DOSE_LIST" == "" local multi3 `""""'
			
			
			foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")'  {
				
				replace q = "How many where both the 1st and 2nd dose in series are within proper range?" if var=="ct_`d'_`t'_within_range"
				replace rowcount = 1 if var=="ct_`d'_`t'_within_range"
				replace group = "P1" if rowcount == 1 & var=="ct_`d'_`t'_within_range"

				replace q = "How many 1st and 2nd doses in series have the same date?" if var=="ct_`d'_`t'_same" 
				replace rowcount = 2 if var=="ct_`d'_`t'_same"
				replace group = "P2" if rowcount == 2 & var=="ct_`d'_`t'_same"

				replace q = "How many 1st and 2nd doses in series have different dates?" if var=="ct_`d'_`t'_diff"
				replace rowcount = 3 if var=="ct_`d'_`t'_diff"
				replace group = "P2" if rowcount == 3 & var=="ct_`d'_`t'_diff"
				
				replace q = "How many 1st and 2nd doses in series with different dates have 2nd dose before 1st?"  if var=="ct_`d'12_`t'_ooo"
				replace rowcount = 4 if var=="ct_`d'12_`t'_ooo"
				replace group = "P3" if rowcount == 4 & var=="ct_`d'12_`t'_ooo"

				replace q = "How many 1st and 2nd dose in series with different dates are in correct chronological order?"  if var=="ct_`d'12_`t'_all_in_order"
				replace rowcount = 5 if var=="ct_`d'12_`t'_all_in_order"
				replace group = "P3" if rowcount == 5 & var=="ct_`d'12_`t'_all_in_order"
				
				local multi2 `"`multi2', "`=upper("`d'")'2""'
			}	
						
			foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")'  {
				
				replace q = "How many where only the 1st and 2nd dose in series are within proper range?" if var=="ct_`d'12_`t'_within_range"
				replace rowcount = 1 if var=="ct_`d'12_`t'_within_range"
				replace group = "P1" if rowcount == 1 & var=="ct_`d'12_`t'_within_range"

				replace q = "How many with only 1st and 2nd doses in series within range have the same date?" if var=="ct_`d'12_`t'_same" 
				replace rowcount = 2 if var=="ct_`d'12_`t'_same"
				replace group = "P2" if rowcount == 2 & var=="ct_`d'12_`t'_same"

				replace q = "How many with only 1st and 2nd doses in series within range have different dates?" if var=="ct_`d'12_`t'_diff"
				replace rowcount = 3 if var=="ct_`d'12_`t'_diff"
				replace group = "P2" if rowcount == 3 & var=="ct_`d'12_`t'_diff"
				
				replace q = "How many with only 1st and 2nd doses in series with different dates have 2nd dose before 1st?"  if var=="ct_`d'12_`t'_ooo"
				replace rowcount = 4 if var=="ct_`d'12_`t'_ooo"
				replace group = "P3" if rowcount == 4 & var=="ct_`d'12_`t'_ooo"

				replace q = "How many with only 1st and 2nd dose in series with different dates are in correct chronological order?"  if var=="ct_`d'12_`t'_all_inorder"
				replace rowcount = 5 if var=="ct_`d'12_`t'_all_inorder"
				replace group = "P3" if rowcount == 5 & var=="ct_`d'12_`t'_all_inorder"
				
				replace q = ""  if var=="ct_`d'12_`t'_blank1"
				replace rowcount = 6 if var=="ct_`d'12_`t'_blank1"
				replace group = "P9" if rowcount == 6 & var=="ct_`d'12_`t'_blank1"
				
				replace q = "`=proper("`d'")' with only 1st and 3rd doses in series"  if var=="ct_`d'12_`t'_blank2"
				replace rowcount = 7 if var=="ct_`d'12_`t'_blank2"
				replace group = "P9" if rowcount == 7 & var=="ct_`d'12_`t'_blank2"
				
				****************************************************************
				
				replace q = "How many where only the 1st and 3rd dose in series are within proper range?" if var=="ct_`d'13_`t'_within_range"
				replace rowcount = 8 if var=="ct_`d'13_`t'_within_range"
				replace group = "P4" if rowcount == 8 & var=="ct_`d'13_`t'_within_range"

				replace q = "How many with only 1st and 3rd doses in series within range have the same date?" if var=="ct_`d'13_`t'_same" 
				replace rowcount = 9 if var=="ct_`d'13_`t'_same"
				replace group = "P5" if rowcount == 9 & var=="ct_`d'13_`t'_same"

				replace q = "How many with only 1st and 3rd doses in series within range have different dates?" if var=="ct_`d'13_`t'_diff"
				replace rowcount = 10 if var=="ct_`d'13_`t'_diff"
				replace group = "P5" if rowcount == 10 & var=="ct_`d'13_`t'_diff"
				
				replace q = "How many with only 1st and 3rd doses in series with different dates have 2nd dose before 1st?"  if var=="ct_`d'13_`t'_ooo"
				replace rowcount = 11 if var=="ct_`d'13_`t'_ooo"
				replace group = "P6" if rowcount == 11 & var=="ct_`d'13_`t'_ooo"

				replace q = "How many with only 1st and 3rd dose in series with different dates are in correct chronological order?"  if var=="ct_`d'13_`t'_all_inorder"
				replace rowcount = 12 if var=="ct_`d'13_`t'_all_inorder"
				replace group = "P6" if rowcount == 12 & var=="ct_`d'13_`t'_all_inorder"
				
				replace q = ""  if var=="ct_`d'13_`t'_blank1"
				replace rowcount = 13 if var=="ct_`d'13_`t'_blank1"
				replace group = "P9" if rowcount == 13 & var=="ct_`d'13_`t'_blank1"
				
				replace q = "`=proper("`d'")' with only 2nd and 3rd doses in series"  if var=="ct_`d'13_`t'_blank2"
				replace rowcount = 14 if var=="ct_`d'13_`t'_blank2"
				replace group = "P9" if rowcount == 14 & var=="ct_`d'13_`t'_blank2"
				
				****************************************************************
				
				replace q = "How many where only the 2nd and 3rd dose in series are within proper range?" if var=="ct_`d'23_`t'_within_range"
				replace rowcount = 15 if var=="ct_`d'23_`t'_within_range"
				replace group = "P7" if rowcount == 15 & var=="ct_`d'23_`t'_within_range"

				replace q = "How many with only 2nd and 3rd doses in series within range have the same date?" if var=="ct_`d'23_`t'_same" 
				replace rowcount = 16 if var=="ct_`d'23_`t'_same"
				replace group = "P8" if rowcount == 16 & var=="ct_`d'23_`t'_same"

				replace q = "How many with only 2nd and 3rd doses in series within range have different dates?" if var=="ct_`d'23_`t'_diff"
				replace rowcount = 17 if var=="ct_`d'23_`t'_diff"
				replace group = "P8" if rowcount == 17 & var=="ct_`d'23_`t'_diff"
				
				replace q = "How many with only 2nd and 3rd doses in series with different dates have 2nd dose before 1st?"  if var=="ct_`d'23_`t'_ooo"
				replace rowcount = 18 if var=="ct_`d'23_`t'_ooo"
				replace group = "P9" if rowcount == 18 & var=="ct_`d'23_`t'_ooo"

				replace q = "How many with only 2nd and 3rd dose in series with different dates are in correct chronological order?"  if var=="ct_`d'23_`t'_all_inorder"
				replace rowcount = 19 if var=="ct_`d'23_`t'_all_inorder"
				replace group = "P9" if rowcount == 19 & var=="ct_`d'23_`t'_all_inorder"
				
				replace q = ""  if var=="ct_`d'23_`t'_blank1"
				replace rowcount = 20 if var=="ct_`d'23_`t'_blank1"
				replace group = "P9" if rowcount == 20 & var=="ct_`d'23_`t'_blank1"
				
				replace q = "`=proper("`d'")' with all 3 doses in series"  if var=="ct_`d'23_`t'_blank2"
				replace rowcount = 21 if var=="ct_`d'23_`t'_blank2"
				replace group = "P9" if rowcount == 21 & var=="ct_`d'23_`t'_blank2"
				
				****************************************************************
				
				replace q = "How many where all 3 doses in series are within proper range?" if var=="ct_`d'123_`t'_withinrange"
				replace rowcount = 22 if var=="ct_`d'123_`t'_withinrange"
				replace group = "P10" if rowcount == 22 & var=="ct_`d'123_`t'_withinrange"

				replace q = "How many where all 3 doses in series are within range and have the same date?" if var=="ct_`d'123_`t'_all_same" 
				replace rowcount = 23 if var=="ct_`d'123_`t'_all_same"
				replace group = "P11" if rowcount == 23 & var=="ct_`d'123_`t'_all_same"
				
				replace q = "How many where all 3 doses in series are within range and 1st and 2nd dose have the same date?" if var=="ct_`d'123_`t'_12_same" 
				replace rowcount = 24 if var=="ct_`d'123_`t'_12_same"
				replace group = "P11" if rowcount == 24 & var=="ct_`d'123_`t'_12_same"
				
				replace q = "How many where all 3 doses in series are within range and 1st and 3rd dose have the same date?" if var=="ct_`d'123_`t'_13_same" 
				replace rowcount = 25 if var=="ct_`d'123_`t'_13_same"
				replace group = "P11" if rowcount == 25 & var=="ct_`d'123_`t'_13_same"
				
				replace q = "How many where all 3 doses in series are within range and 2nd and 3rd dose have the same date?" if var=="ct_`d'123_`t'_23_same" 
				replace rowcount = 26 if var=="ct_`d'123_`t'_23_same"
				replace group = "P11" if rowcount == 26 & var=="ct_`d'123_`t'_23_same"

				replace q = "How many where all 3 doses in series are within range and have different dates?" if var=="ct_`d'123_`t'_all_diff"
				replace rowcount = 27 if var=="ct_`d'123_`t'_all_diff"
				replace group = "P11" if rowcount == 27 & var=="ct_`d'123_`t'_all_diff"
				
				replace q = "How many where all 3 doses in series are within range and have different dates and 2nd dose is before 1st?"  if var=="ct_`d'123_`t'_12_ooo"
				replace rowcount = 28 if var=="ct_`d'123_`t'_12_ooo"
				replace group = "P12" if rowcount == 28 & var=="ct_`d'123_`t'_12_ooo"
				
				replace q = "How many where all 3 doses in series are within range and have different dates and 3rd dose is before 2nd?"  if var=="ct_`d'123_`t'_23_ooo"
				replace rowcount = 29 if var=="ct_`d'123_`t'_23_ooo"
				replace group = "P12" if rowcount == 29 & var=="ct_`d'123_`t'_23_ooo"
				
				replace q = "How many where all 3 doses in series are within range and have different dates and 3rd dose is before 1st?"  if var=="ct_`d'123_`t'_13_ooo"
				replace rowcount = 30 if var=="ct_`d'123_`t'_13_ooo"
				replace group = "P12" if rowcount == 30 & var=="ct_`d'123_`t'_13_ooo"
				
				replace q = "How many where all 3 doses in series are within range with different dates and in chronological order?"  if var=="ct_`d'123_`t'_all_inorder"
				replace rowcount = 31 if var=="ct_`d'123_`t'_all_inorder"
				replace group = "P12" if rowcount == 31 & var=="ct_`d'123_`t'_all_inorder"
				
				****************************************************************
				
				local multi3 `"`multi3',"`=upper("`d'")'3""'
				
			}
				
		}
		
		* Clean up the locals to use in criteria for exporting
		forvalues i = 2/3 {
			local multi`i' = subinstr(`"`multi`i''"',",","",1)
		}
				
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
		capture label variable numreg "n" 
		capture label variable percentreg "%" 
		capture label variable denomreg  "denom" 
		label variable numhistory   "n" 
		label variable percenthistory "%"  
		label variable denomhistory "denom" 
		label variable group	"group"

		* Replace the values with 0 if not applicable
		local reg
		`ifreg' local reg reg
		foreach v in num percent denom {
			foreach s in card `reg' {
				replace `v'`s'=0 if missing(`v'`s') 
			}
		}

		* save dataset to be used for summary page
		save completeness_dataset, replace 

		vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS completeness_dataset

		* Start with a clean, empty Excel file for tabulated output (TO)
		capture erase "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx"	
		sleep 1000
	
		`ifreg' local elist q numcard percentcard denomcard ///
						 numreg percentreg denomreg ///
						 numhistory  percenthistory denomhistory group
						 				 
		else local elist q numcard percentcard denomcard ///
						 numhistory  percenthistory denomhistory group
						 
		`ifreg' local multilist q numcard percentcard denomcard ///
						 numreg percentreg denomreg ///
						 group
						 
		else local multilist q numcard percentcard denomcard ///
							 group				 

		* Export to separate spreadsheet tab for each dose- for first table: Data present
		foreach d in  DOB `=upper("$RI_DOSE_LIST")'{
			if "`d'"=="DOB" local table dob
			else local table all
			export excel `elist' using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
			if table==lower("`table'"), sheet("`d'", modify) cell(A2)  firstrow(varlabels) 
			noisily di as text "Writing info re: data present for `d'..."
			sleep 1000	
			
			forvalues i = 2/3 {
				if inlist("`d'",`multi`i'') {				
					export excel `multilist'  using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
					if table=="`=lower("`=subinstr("`d'","`i'","",.)'")'", sheet("`=subinstr("`d'","`i'","",.)' SERIES", replace) cell(A2)  firstrow(varlabels) 
					noisily di as text "Writing info re: data for `=subinstr("`d'","`i'","",.)' dose series..."
					sleep 1000	
					
					capture drop if table == "`=lower("`=subinstr("`d'","`i'","",.)'")'"
				}
			}
		}
		
		* Export to separate spreadsheet tab for each dose- for first table: Data present
		foreach d in `=upper("$RI_DOSE_LIST")' {
			export excel `elist' ///
				using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
			   if table==lower("`d'"), sheet("`d'", modify) cell(A5)  
			noisily di as text "Writing info re: data complete for `d'..."
			sleep 1000	   
		}

		* Take dataset and collapse by 
		* Export the count for each source into the first two columns
		
		* But we must first drop the DOB source counts
		capture drop if table == "dob"
		
		export excel `elist' ///
			using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
			if table==lower("all"), sheet("DOSE SUMMARY", modify) cell(A2) firstrow(varlabels) 
		noisily di as text "Writing dose summary info..."  
		sleep 1000
		
		* drop the above two rows from the dataset
		capture drop if table=="all"
		
		drop percent* table
	  
		* summarize the numerators and denominators of all doses for the summary tab
		`ifreg' local slist numcard denomcard numhistory denomhistory numregister denomregister
		else local slist numcard denomcard numhistory denomhistory 
		collapse (sum) `slist', by(rowcount q group)
	  
		* Calculate the percent for summary tab
		foreach s in card history `reg' {
			gen percent`s'=num`s'/denom`s'
			order percent`s', after(num`s')
		}

		* Export Completeness data for summarized data across all doses to Summary tab
		export excel `elist' using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx", ///
					sheet("DOSE SUMMARY", modify) cell(A5)  
		sleep 1000
				
		********************************************************************************
		* Export data for DOB Concordance 
		
		use dt_dob_concordance, clear

		local row 1
		
		* Create variable to identify type of data and what row it belongs to in the table
		gen q = ""
		gen rowcount = .
		`ifreg' {
			replace q = "Card/register?" if var=="ct_dob_card_register"
			replace rowcount = `row' if var=="ct_dob_card_register"
			local ++row
		}

		replace q = "Card/history?" if var=="ct_dob_card_history"
		replace rowcount = `row' if var=="ct_dob_card_history"
		local ++row

		`ifreg' {
			replace q = "Register/history?" if var=="ct_dob_register_history"
			replace rowcount = `row' if var=="ct_dob_register_history"
			local ++row
		}
		
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
		noisily di as text "Writing info re: DOB concordance..."
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
		replace q = "How many assigned using the earliest birthdate?" if var=="ct_dob_min_valid_dose_calc"
		replace rowcount = 3 if var=="ct_dob_min_valid_dose_calc"

		* Row 3 show how many had a single birthdate
		replace q = "How many assigned using the single birthdate?" if var=="unambiguous_dob"
		replace rowcount = 4 if var=="unambiguous_dob"

		* Create variables to populate these values for each category above
		gen num=n_1
		replace num=0 if num==.
		gen percent=n_1/n_01
		replace percent=0 if percent==.
		gen denom=n_01
		replace denom=0 if denom==.
			
		* Create labels to use as column headers for table.
		label variable q "Assigned for timeliness calculations"
		label variable num "n"
		label variable percent "%"
		label variable denom "denom"

		sort rowcount
		
		local row 22
		`ifreg' local row 24

		export excel  q num percent denom using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx", ///
				sheet("DOB", modify) cell(A`row')  firstrow(varlabels) 
				
		sleep 1000

		********************************************************************************
		* Export Dose Concordance data 
		use dt_doses_concordance, clear

		* keep types to show the different combinations
		`ifreg' keep if type=="card-register" | type=="card-history" | type=="register-history"
		else keep if type =="card-history"
		
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

		`ifreg' {
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
		`ifreg' {
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

		local crh "card-history"
		`ifreg' local crh "card-register card-history register-history"
		local numcell_singledose 20 38 50

		local n : word count `crh'
	
		forvalues i = 1/`n' {
			local a : word `i' of `crh'
			local b : word `i' of `numcell_singledose'
			
			local qlab `=strproper(subinstr("`a'","-"," & ",.))'
		
			label variable q "`qlab'"
			
			noisily di as text "Writing info re: concordance between `a'..."

			foreach d in `=upper("$RI_DOSE_LIST")' {
			    local b`d' `b'
			    if "`d'"=="BCG" local b`d' `=`b'+1'
				export excel q num percent denom group using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("all") & type=="`a'", sh("`d'", modify) cell(A`b`d'') firstrow(varlabels) 
				sleep 1000 
			}

			foreach d in `=upper("$RI_DOSE_LIST")' {
				export excel q num percent denom group using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'") & type=="`a'", sh("`d'", modify) cell(A`=`b`d''+5') 
				sleep 1000 
			}
		}

		********************************************************************************
		********************************************************************************
		* Add tab showing how many dates were switched to ticks by VQCI
		use date_tick_in_progress, clear
		noi di as text "Writing info re: DATES CHANGED TO TICKS BY VCQI..."
		
		* Only keep the variables we need... these are the ct_ derived variables for card and register
		drop *dob* *history* *_diff *_within*range *all_in*order *_full *_sense
		keep ct_*
		
		* Create an id for reshaping purposes
		gen id = _n
		
		* Now we want to look at out of order and same variables and determine which single dose is changed due to out of order
		local multidose_list 
		foreach s in card `register' {
			foreach v in `=lower("$RI_MULTI_2_DOSE_LIST")' {
				* Create variable to show if tick set due to later dose received and earlier one missing
				gen ct_`v'1_`s'_tick_gap =1 if (ct_`v'2_`s'_miss == 0 | ct_`v'2_`s'_tick ==1) & (ct_`v'1_`s'_miss == 1 & ct_`v'1_`s'_tick!=1)

				* Create variables to show if changed to tick due to out of order
				gen ct_`v'1_`s'_due_ooo = 1 if ct_`v'12_`s'_ooo ==1
				gen ct_`v'2_`s'_due_ooo = 1 if ct_`v'12_`s'_ooo ==1					
				
				* Create variables to show if tick set due to same date
				gen ct_`v'1_`s'_due_same = 1 if ct_`v'_`s'_same == 1
				gen ct_`v'2_`s'_due_same = 1 if ct_`v'_`s'_same == 1
				
				drop ct_`v'12_`s'_ooo ct_`v'_`s'_same ct_`v'2_`s'_miss ct_`v'2_`s'_tick ct_`v'1_`s'_miss ct_`v'1_`s'_tick
			}
				
			foreach v in `=lower("$RI_MULTI_3_DOSE_LIST")' {
				* Create variables to show if tick set due to later dose received and earlier one missing
				gen ct_`v'1_`s'_tick_gap =1 if (ct_`v'2_`s'_miss == 0 | ct_`v'2_`s'_tick ==1) & (ct_`v'1_`s'_miss == 1 & ct_`v'1_`s'_tick!=1)
				replace ct_`v'1_`s'_tick_gap =1 if (ct_`v'3_`s'_miss == 0 | ct_`v'3_`s'_tick ==1) & (ct_`v'1_`s'_miss == 1 & ct_`v'1_`s'_tick!=1) & ct_`v'1_`s'_tick_gap!=1
				gen ct_`v'2_`s'_tick_gap =1 if (ct_`v'3_`s'_miss == 0 | ct_`v'3_`s'_tick ==1 ==1) & (ct_`v'2_`s'_miss == 1 & ct_`v'2_`s'_tick!=1)
				
				* Create variables to show if tick changed due to out of order
				gen ct_`v'1_`s'_due_ooo = 1 if ct_`v'12_`s'_ooo == 1 | ct_`v'13_`s'_ooo == 1 |  ct_`v'123_`s'_12_ooo == 1 | ct_`v'123_`s'_13_ooo == 1
				gen ct_`v'2_`s'_due_ooo = 1 if ct_`v'12_`s'_ooo == 1 |  ct_`v'23_`s'_ooo == 1  | ct_`v'123_`s'_12_ooo == 1 | ct_`v'123_`s'_23_ooo == 1	
				gen ct_`v'3_`s'_due_ooo = 1 if ct_`v'13_`s'_ooo == 1 |  ct_`v'23_`s'_ooo == 1  |  ct_`v'123_`s'_13_ooo == 1	| ct_`v'123_`s'_23_ooo == 1  
				
				
				* Cleanup_dates_and_ticks also changes the second dose to a tick if dose date is provided and dose 1 and 3 are out of order. So we want to also capture that
				replace ct_`v'2_`s'_due_ooo = 1 if ct_`v'123_`s'_13_ooo == 1
				
				gen ct_`v'1_`s'_due_same = 1 if ct_`v'12_`s'_same == 1 | ct_`v'13_`s'_same == 1 |  ct_`v'123_`s'_12_same == 1 | ct_`v'123_`s'_13_same == 1 | ct_`v'123_`s'_all_same == 1
				gen ct_`v'2_`s'_due_same = 1 if ct_`v'12_`s'_same == 1 |  ct_`v'23_`s'_same == 1  | ct_`v'123_`s'_12_same == 1 | ct_`v'123_`s'_23_same == 1	| ct_`v'123_`s'_all_same == 1
				gen ct_`v'3_`s'_due_same = 1 if ct_`v'13_`s'_same == 1 |  ct_`v'23_`s'_same == 1  |  ct_`v'123_`s'_13_same == 1	| ct_`v'123_`s'_23_same == 1  | ct_`v'123_`s'_all_same == 1								   
												   				
				drop ct_`v'12_`s'_ooo ct_`v'13_`s'_ooo ct_`v'23_`s'_ooo ct_`v'123_`s'_12_ooo ct_`v'123_`s'_13_ooo ct_`v'123_`s'_23_ooo ///
				ct_`v'12_`s'_same ct_`v'13_`s'_same ct_`v'23_`s'_same ct_`v'123_`s'_12_same ct_`v'123_`s'_13_same ct_`v'123_`s'_23_same ct_`v'123_`s'_all_same ///
				ct_`v'3_`s'_miss ct_`v'3_`s'_tick ct_`v'2_`s'_miss ct_`v'2_`s'_tick ct_`v'1_`s'_miss ct_`v'1_`s'_tick
			}
			if "`=lower("$RI_MULTI_3_DOSE_LIST")'" != "" | 	"`=lower("$RI_MULTI_2_DOSE_LIST")'" != "" local multidose_list `multidose_list' ///
			ct_@_`s'_due_ooo ct_@_`s'_due_same ct_@_`s'_tick_gap
			
		}
		
		drop ct_*_miss ct_*_tick

		* Reshape so we have 1 row per dose	
		* Create local with register variables
		local reshape_list
		`ifreg' local reshape_list ct_@_register_parmiss ct_@_register_nonsense ct_@_register_too_early ct_@_register_late
		
		reshape long ct_@_card_parmiss ct_@_card_nonsense ct_@_card_too_early ct_@_card_late `multidose_list' `reshape_list', i(id) j(dose) string
		
		* Reshape again to get the source type
		if "`=lower("$RI_MULTI_3_DOSE_LIST")'" != "" | 	"`=lower("$RI_MULTI_2_DOSE_LIST")'" != "" local multidose_list ct__@_due_ooo ct__@_due_same ct__@_tick_gap 
		reshape long ct__@_parmiss ct__@_nonsense  ct__@_too_early ct__@_late `multidose_list', i(id dose) j(type) string 

		* We no longer need id
		drop id
		
		* Rename the tick_gap variable to be consistent
		capture rename ct__tick_gap ct___tick_gap


		* Collapse to get the totals for each category
		if "`=lower("$RI_MULTI_3_DOSE_LIST")'" != "" | 	"`=lower("$RI_MULTI_2_DOSE_LIST")'" != "" local multidose_list ct___due_ooo ct___due_same ct___tick_gap
		collapse (rawsum) ct___parmiss ct___nonsense  ct___too_early ct___late `multidose_list', by(dose type)
		
		* Remove the "ct__" from each var name
		foreach v of varlist * {
		    rename `v' `=subinstr("`v'","ct__","",.)'
		}
		
		* Finally reshape wide to set up for excel format
		if "`=lower("$RI_MULTI_3_DOSE_LIST")'" != "" | 	"`=lower("$RI_MULTI_2_DOSE_LIST")'" != "" local multidose_list @_due_ooo @_due_same @_tick_gap
		reshape wide @_parmiss @_nonsense @_too_early @_late `multidose_list', i(dose) j(type) string

		* Clean up the dose name format to be consistent with other tabs 
		replace dose = upper(dose) 
		
		* Wipe out the 0s from single doses in multi dose only categories
		foreach v in $RI_SINGLE_DOSE_LIST {
		    foreach s in card `register' {
				capture replace `s'_due_ooo = . if dose == "`v'"
				capture replace `s'_due_same = . if dose == "`v'"
				capture replace `s'_tick_gap = . if dose == "`v'"
			}   
		}
		
		* We also want to wipe out any values for last dose in the series for tick_gap
		forvalues i = 2/3 {
			foreach v in ${RI_MULTI_`i'_DOSE_LIST} {
				foreach s in card `register' {
					capture replace `s'_tick_gap = . if dose == "`v'`i'"
				}
			}
		}

		* Grab a list of rows that need wiped out in the excel sheet to be used in formatting below
		local blackout_list
		local blackout_list2
		if "`=lower("$RI_MULTI_3_DOSE_LIST")'" != "" | 	"`=lower("$RI_MULTI_2_DOSE_LIST")'" != "" { 
			forvalues i = 1/`=_N' {
				if card_due_ooo[`i'] == . local blackout_list `blackout_list' `i'
				if card_tick_gap[`i'] == .  local blackout_list2 `blackout_list2' `i'
			}
		}
		* Pass through the local
		c_local blackout_list `blackout_list'

		* Export to excel the results
		export excel using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx", sh("DATES VCQI CHANGED TO TICKS", replace) cell(A3)	
				
		********************************************************************************
		********************************************************************************
		* Code to create table to show number of doses received
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
		foreach v in history `register' {
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
		`ifreg' local nlist card_hist_no card_hist_yes card_no_hist_yes card_no_reg_yes ///
						card_reg_no card_reg_yes card_yes_hist_no card_yes_reg_no ///
						reg_hist_no reg_hist_yes reg_no_hist_yes reg_yes_hist_no
						
		else local nlist card_hist_no card_hist_yes card_no_hist_yes ///
					 card_yes_hist_no 			 
					 
		foreach d in `nlist' {
			rename n_1`d' `d'
		}

		* Export to summarized data to excel
		local r 24

		noisily di as text "Writing info re: dose summary..."

		foreach d in `=lower("$RI_DOSE_LIST")' {
		
			* Set starting column name
			mata: st_local("xlcolname", invtokens(numtobase26(2)))

			* Create matrix for card and register
			`ifreg' {
					
				export excel card_reg_yes card_no_reg_yes  using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(`xlcolname'`r') 
			
				sleep 1000 

				export excel card_yes_reg_no card_reg_no using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(`xlcolname'`=`r' + 1')
				   
		  		mata: st_local("xlcolname", invtokens(numtobase26(6)))
			}
			
			* Create matrix for card and hist
			export excel card_hist_yes card_no_hist_yes  using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(`xlcolname'`r') 
			sleep 1000 

			export excel card_yes_hist_no card_hist_no using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
				   if table==lower("`d'"), sh("Dose Summary", modify) cell(`xlcolname'`=`r' + 1') 

			`ifreg' {
			
		  		mata: st_local("xlcolname", invtokens(numtobase26(10)))

				* Create matrix for reg and hist
				export excel reg_hist_yes  reg_no_hist_yes  using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
					   if table==lower("`d'"), sh("Dose Summary", modify) cell(`xlcolname'`r') 
				sleep 1000 

				export excel reg_yes_hist_no reg_hist_no using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx" ///
					   if table==lower("`d'"), sh("Dose Summary", modify) cell(`xlcolname'`=`r' + 1') 
			}
			local r `=`r' + 6'	
			if "`d'" == "bcg" local ++r
		}
		
		********************************************************************************
		********************************************************************************
		noisily di as text "Formatting worksheets..."		
	
		* Use mata to populate column labels and worksheet titles and footnotes for each SINGLE DOSE
		mata: b = xl()
		mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_dates_ticks.xlsx")
		mata: b.set_mode("open")
		
		top_data, sheet(DOB) row(18) ifreg(`ifreg')
		
		* Add shading to first line of third table
		mata: b.set_fill_pattern(`xlrow2',(1,4),"solid","lightgray")
		
		top_footnotes, row(13)
		
		top_pink_fill, xlcol1(`xlcol1')
			
		*****************************************************************************
			
		mata: b.put_string(18, 1, "Date discordance: Full date DOBs disagree")
		mata: b.set_font_bold(18, 1, "on")
		mata: b.set_font_bold(`xlrow2', 1, "on")
		
		* Shade cells if greater than zero, indicating incomplete or nonsensical dates
		foreach d of numlist 19/`xlrow4' {
			pink_fill, row(`d') col(2)
		}

		* Foot Notes
		pink_footnotes, srow(`=`xlrow2'-2')
		
		`ifreg' mata: b.put_string(`=`xlrow3'+1',1,`"Note: If card, register & history yield 2+ birthdates then VCQI assigned the earliest plausible birthdate for timeliness calculations."')
		else mata: b.put_string(`=`xlrow3'+1',1, `"Note: If card & history yield 2 birthdates then VCQI assigned the earliest plausible birthdate for timeliness calculations."')
		
		style_font, row(`=`xlrow3'+1')
		
		*Set borders
		create_box_boarders, srow(1) erow(12) scol(1) ecol(`xlcol2')
		create_box_boarders, srow(18) erow(`xlrow4') scol(1) ecol(4)
		create_box_boarders, srow(`xlrow2') erow(`xlrow3') scol(1) ecol(4)
		
		* Make borders for card, register and history...
		mata: b.set_right_border((1,12),(4,4), "thin","black")
		mata: b.set_right_border((1,12),(7,7), "thin","black")
		`ifreg' mata: b.set_right_border((1,12),(10,10), "thin","black")
		
		format_to_percent, width(50) ifreg(`ifreg')
												   
		sleep 1000
	
		********************************************************************************
		********************************************************************************
		* Dose table formatting
		foreach d in  `=upper("$RI_DOSE_LIST")' {
		    local row1 19
			local row2 38
			local row3 50
			local row1e 35
			local row2e 47
			local row3e 59
			local row1group 21,35
			local row2group 39,47
			local row3group 51,59
				
		    if "`d'"=="BCG" {
			    local row1 20
				local row2 39
				local row3 51
				local row1group 22,36
				local row2group 40,48
				local row3group 52,60
				local row1e 36
				local row2e 48
				local row3e 60

			}

			top_data, sheet(`d') row(`row1') ifreg(`ifreg')
			
			* Add shading to 2nd line of second table
			mata: b.set_fill_pattern(`=`xlrow1'+1',(1,4),"solid","lightgray")

			mata: b.set_horizontal_align(`=`row1'+1',(2, 5),"center")
			mata: b.set_fill_pattern((`row1',`=`row1'+1'),(1,5),"solid","lightgray")
		
			`ifreg' {
				mata: b.set_horizontal_align(`row2',(2, 5),"center")
				mata: b.set_fill_pattern(`row2',(1,5),"solid","lightgray")
			
				mata: b.set_horizontal_align(`row3',(2, 5),"center")
				mata: b.set_fill_pattern(`row3',(1,5),"solid","lightgray")
			}
			
			* align group data to the right like all other text
			mata: b.set_horizontal_align((3,13),(`xlcol2',`xlcol2'),"right")
			mata: b.set_horizontal_align((`row1group'),(5,5),"right")
			`ifreg' mata: b.set_horizontal_align((`row2group'),(5,5),"right")
			`ifreg' mata: b.set_horizontal_align((`row3group'),(5,5),"right")

			*mata: b.set_column_width(1,1,70)
			
			mata: b.put_string(`row1', 1, "`d': Concordance of evidence")
			mata: b.set_font_bold(`row1', 1, "on")
			
			****************************************************************************
			* Add Footnotes
			local row 14
			local pinkrows 36 48 60
			local pinkrows2 30
			local pinkrows3 28/35
			local pinkrows4 27/29
			if "`d'"=="BCG" {
			    mata: b.put_string(`row',1,"Note: BCG Scar data is excluded from these tables.")
				style_font, row(`row')
				local ++row		
				local pinkrows 37 49 61
				local pinkrows2 31
				local pinkrows3 29/36
				local pinkrows4 28/30
			}
			
			top_footnotes, row(`row')
			
			`ifreg' {
				foreach v in `pinkrows' {
					pink_footnotes, srow(`v')
				}
			}
			else {
			    pink_footnotes, srow(`pinkrows2') 
			}
			
			* Shade cells if they are greater than zero, inidicating incomplete or nonsensical dates
			top_pink_fill, xlcol1(`xlcol1')
						
			`ifreg' {
				foreach d in `row2' `row3' {
					forvalues v = 7/9 {
						pink_fill, row(`=`d'+`v'') col(2)
					}
				}
			
				forvalues d = `pinkrows3' {
					pink_fill, row(`d') col(2)
				}
			}
			else {
				forvalues i = `pinkrows4' {
					pink_fill, row(`i') col(2)
				}
			}

			****************************************************************************
			
			*Set borders
			create_box_boarders, srow(1) erow(13) scol(1) ecol(`xlcol2')
			
			`ifreg' {
				create_box_boarders, srow(`row1') erow(`row1e') scol(1) ecol(5)
				create_box_boarders, srow(`row2') erow(`row2e') scol(1) ecol(5)
				create_box_boarders, srow(`row3') erow(`row3e') scol(1) ecol(5)
			}
			
			else {
			    create_box_boarders, srow(`row1') erow(`=`row1'+10') scol(1) ecol(5)
			}
			
			* Make borders for card, register and history...
			mata: b.set_right_border((1,13),(4,4), "thin","black")
			mata: b.set_right_border((1,13),(7,7), "thin","black")
			`ifreg' mata: b.set_right_border((1,13),(10,10), "thin","black")
			
			* Make borders to separate group from Concordance boxes
			`ifreg' {
				mata: b.set_right_border((`row1',`row1e'),(4,4), "thin","black")
				mata: b.set_right_border((`row2',`row2e'),(4,4), "thin","black")
				mata: b.set_right_border((`row3',`row3e'),(4,4), "thin","black")
			}
			else {
				mata: b.set_right_border((`row1',`=`row1'+10'),(4,4), "thin","black")
			}
			
			foreach i in `numcell_singledose' {
			    if "`d'"=="BCG" local ++i
				mata: b.set_font_underline(`i', 1, "on")
			}

			format_to_percent, width(70) ifreg(`ifreg')
			sleep 1000 
		}
		
		********************************************************************************
		********************************************************************************
		* Dose table formatting
		if "$RI_MULTI_2_DOSE_LIST" != "" {
			foreach d in  `=upper("$RI_MULTI_2_DOSE_LIST")' {
				local dose = "`d'"
				
				top_data, sheet(`d' SERIES) row(7) ifreg(`ifreg')

				* align group data to the right like all other text
				mata: b.set_horizontal_align((3,7),(2,`xlcol2'),"right")

*				mata: b.set_horizontal_align((3,7),(2,4),"right")
				mata: b.set_column_width(1,1,70)
				
				mata: b.put_string(1, 1, "`d' Series: Quality of date order for 2 doses")
				mata: b.put_string(2, 1, "`d' with both first and second doses in series")
				mata: b.set_font_bold(2, 1, "on")
		
				
				****************************************************************************
				* Add Footnotes
				
				* Shade cells if they are greater than zero, inidicating the dates are not valid in series						
				if "$RI_RECORDS_NOT_SOUGHT" != "1" {
					foreach d in 4 6 {
						forvalues v = 2(3)6 {
							pink_fill, row(`d') col(`v')
						}
					}
				}
				else {
					foreach d in 4 6 {
						pink_fill, row(`d') col(2)
					}
				}
		
				****************************************************************************
				
				*Set borders
				create_box_boarders, srow(1) erow(7) scol(1) ecol(`xlcol2')
										
				* Make borders for card, register and history...
				mata: b.set_right_border((1,7),(4,4), "thin","black")
				`ifreg' mata: b.set_right_border((1,7),(7,7), "thin","black")

				format_to_percent, width(85) ifreg(`ifreg')
				sleep 1000 
			
				* Add footnotes
				mata: b.put_string(8,1,"Note: The denominator for those in proper range includes only those with that source. Therefore the rest of the denominator columns will not add up to 100% as some respondents with that source may have none or only 1 `dose' date.")
				mata: b.put_string(9,1,"Note: Within proper range means that both dates are sensical and within the specified survey timeframe.")
				mata: b.put_string(10,1,"Note: If the pink cells hold non-zero numbers, that is an indication of dose dates within the series that can not be used to determine if dose was valid.")
				mata: b.put_string(11,1,"Note: Within each group, the numbers in the n column must sum up to the denominator and the % numbers add up to 100%. The rows within each group are mutually exclusive and exhaustive.")
			
				
				forvalues i = 8/11 {
					style_font, row(`i')
				}
			}
		}
				
		***************************************************************************
		***************************************************************************
		***************************************************************************
		* Dose table formatting
		
		
		if "$RI_MULTI_3_DOSE_LIST" != "" {
			foreach d in  `=upper("$RI_MULTI_3_DOSE_LIST")' {
				local dose = "`d'"			

				top_data, sheet(`d' SERIES) row(9) ifreg(`ifreg')
				
				* align group data to the right like all other text
				mata: b.set_horizontal_align((3,7),(`xlcol2',`xlcol2'),"right")

				mata: b.set_column_width(1,1,90)
				
				mata: b.put_string(1, 1, "`d' Series: Quality of date order for 2 or more doses")
				mata: b.put_string(2, 1, "`=proper("`d'")' with only first and second doses in series")
				mata: b.set_font_bold(2, 1, "on")
				
				****************************************************************************
				* Add Footnotes
				
				* Shade cells if they are greater than zero, inidicating the dates are not valid in series						
				if "$RI_RECORDS_NOT_SOUGHT" != "1" {
					foreach d in 4 6 11 13 18 20 26 27 28 30 31 32 {
						forvalues v = 2(3)6 {
							pink_fill, row(`d') col(`v')
						}
					}
				}
				else {
					foreach d in 4 6 11 13 18 20 26 27 28 30 31 32 {
						pink_fill, row(`d') col(2)
					}
				}

				****************************************************************************
				*Set borders
				local start 1
				local end = `xlcol2'
				foreach i in 7 14 21 33 {
			
					create_box_boarders, srow(`start') erow(`i') scol(1) ecol(`xlcol2')
					mata: b.set_font_bold(`start', 1, "on")
					
					* Make borders for card, register and history...
					mata: b.set_right_border((`start',`i'),(4,4), "thin","black")
					`ifreg' mata: b.set_right_border((`start',`i'),(7,7), "thin","black")
					
					* Make the font go to the right
					mata: b.set_horizontal_align((`start'),(2,`end'),"center")
					if `start' == 1  {
						mata: b.set_horizontal_align((`=`start'+1'),(2,`end'),"center")
						mata: b.set_horizontal_align((`=`start'+2'),(2,`end'),"right")
					}
					else mata: b.set_horizontal_align((`=`start'+1',`i'),(2,`end'),"right")
				
					* Wipe out the columns that should be blank
					if "`i'" != "33" {
						forvalues n = 2/`end' {
							mata: b.put_string(`=`i'+1',`n'," ")
						}
					}
					* Add column headers for each section
					if "`i'" != "33" {
						forvalues n = 2(3)`=`end'-1' {
							mata: b.put_string(`=`i'+2',`n',"n")
							mata: b.put_string(`=`i'+2',`=`n'+1',"%")
							mata: b.put_string(`=`i'+2',`=`n'+2',"denom")
						}
						mata: b.put_string(`=`i'+2',`end',"group")
						mata: b.set_fill_pattern(`=`i'+2',(1,`end'),"solid","lightgray")
					}
					
					local start = `i' + 2
				}
							
				* format cells
				format_to_percent, width(95) ifreg(`ifreg')
				sleep 1000 
			
				* Add footnotes
				mata: b.put_string(34,1,"Note: The denominator for those in proper range includes only those with that source. Therefore the rest of the denominator columns will not add up to 100% as some respondents with that source may have none or only 1 `dose' date.")
				mata: b.put_string(35,1,"Note: Within proper range means that dates are sensical and within the specified survey timeframe.")
				mata: b.put_string(36,1,"Note: If the pink cells hold non-zero numbers, that is an indication of dose dates within the series that can not be used to determine if dose was valid.")
				mata: b.put_string(37,1,"Note: Within each group (except group 12), the numbers in the n column must sum up to the denominator and the % numbers add up to 100%. The rows within each group are mutually exclusive and exhaustive.")
				mata: b.put_string(38,1,"Note: Within group 12, a row may be repeated within categories in rows 30,31 and 32. Therefore the n column may be more the denominator and the % may add up to more than 100%. These categories are not mutually exclusive and exhaustive.")

				
				forvalues i = 34/38 {
					style_font, row(`i')
				}
			}
		}

		***************************************************************************
		***************************************************************************
		***************************************************************************
		* Format the Dose summary page
		mata: b.set_sheet("DOSE SUMMARY")

		* Fill in table text in DOSE SUMMARY sheet
		top_data, sheet(DOSE SUMMARY) row(20) ifreg(`ifreg')

		* Make borders for card, register and history...
		mata: b.set_right_border((1,13),(4,4), "thin","black")
		mata: b.set_right_border((1,13),(7,7), "thin","black")
		`ifreg' mata: b.set_right_border((1,13),(10,10), "thin","black")

		
		* Add a gray shading for 1 line
		mata: b.set_fill_pattern(`=`xlrow1'+1',(1,4),"solid","lightgray")
		
		****************************************************************************
		* Create boarders
		create_box_boarders, srow(1) erow(13) scol(1) ecol(`xlcol2')
		* Add Footnotes
		mata: b.put_string(14,1,"Note: Rows 3-4 count the number of participants of the entire survey as the denominator, while rows 5-13 look at all potential dates.")
		style_font, row(14)
		
		top_footnotes, row(15) 
		
		* Shade cells if they are greater than zero, inidicating incomplete or nonsensical dates
		top_pink_fill, xlcol1(`xlcol1')
					
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
		
		* Create local to show how far to fill in gray
		local fill 4
		`ifreg' local fill `xlcol2'
		mata: b.set_fill_pattern((`=`r'-4',`=`r'-3'), (1,`fill'),"solid","lightgray") 
		

		foreach d in `=upper("$RI_DOSE_LIST")' { 
			
			local c 2
			
			*Add borders
			create_box_boarders, srow(`r') erow(`=`r'+1') scol(`c') ecol(`=`c'+1')
			
			* Shade areas that would indicate discordance
			pink_fill, row(`r') col(`=`c'+1')
			pink_fill, row(`=`r'+1') col(`c')
			
			* Format the numbers to include commas
			mata: b.set_number_format((`r',`=`r'+1'),(`c',`=`c'+1'), "number_sep")

			
			`ifreg' {
				local c `=`c'+4'
			
				* Add borders
				create_box_boarders, srow(`r') erow(`=`r'+1') scol(`c') ecol(`=`c'+1')
				
				* Shade areas that would indicate discordance
				pink_fill, row(`r') col(`=`c'+1')
				pink_fill, row(`=`r'+1') col(`c')
				* Format the numbers to include commas
				mata: b.set_number_format((`r',`=`r'+1'),(`c',`=`c'+1'), "number_sep")


				local c `=`c'+4'
				
				* Add borders
				create_box_boarders, srow(`r') erow(`=`r'+1') scol(`c') ecol(`=`c'+1')

				* Shade areas that would indicate discordance
				pink_fill, row(`r') col(`=`c'+1')
				pink_fill, row(`=`r'+1') col(`c')
				
				* Format the numbers to include commas
				mata: b.set_number_format((`r',`=`r'+1'),(`c',`=`c'+1'), "number_sep")

			}
			
		*********

			
			* Add Strings to identify tables and format strings
			mata: b.put_string(`=`r'-2',1,"`d'")
			mata: b.set_font_bold(`=`r'-2',1,"on")
			
			`ifreg' {
				local c 2
				mata: b.put_string(`=`r'-2', `c',"Card & Register")
				mata: b.set_sheet_merge("DOSE SUMMARY", (`=`r'-2',`=`r'-2'), (`c',`=`c'+2'))
				mata: b.set_font_bold(`=`r'-2',`c',"on")
				mata: b.set_horizontal_align(`=`r'-2',`c',"center")
				
				mata: b.put_string(`=`r'-1', `c',"Card Yes")	
				mata: b.put_string(`=`r'-1', `=`c'+1',"Card No")	
				mata: b.put_string(`r', 1,"Register Yes")
				mata: b.set_horizontal_align(`r', 1,"right")

				mata: b.put_string(`=`r'+1', 1,"Register No")
				mata: b.set_horizontal_align(`=`r' +1', 1,"right")

				local c `=`c'+ 4'
			}

			mata: b.put_string(`=`r'-2', `c',"Card & History")
			mata: b.set_sheet_merge("DOSE SUMMARY", (`=`r'-2',`=`r'-2'), (`c',`=`c'+1'))
			mata: b.set_horizontal_align(`=`r'-2',`c',"center")

			mata: b.set_font_bold(`=`r'-2',`c',"on")
			
			mata: b.put_string(`=`r'-1', `c',"Card Yes")	
			mata: b.put_string(`=`r'-1', `=`c'+1',"Card No")	
			mata: b.put_string(`r', `=`c'-1',"History Yes")
			mata: b.set_horizontal_align(`r', `=`c'-1',"right")

			mata: b.put_string(`=`r'+1', `=`c'-1',"History No")
			mata: b.set_horizontal_align(`=`r'+1', `=`c'-1',"right")
			
			local c `=`c' + 4'
			
			`ifreg' {
				mata: b.put_string(`=`r'-2',`c',"Register & History")
				mata: b.set_font_bold(`=`r'-2',`c',"on")
				mata: b.set_sheet_merge("DOSE SUMMARY", (`=`r'-2',`=`r'-2'), (`c',`=`c'+1'))
				mata: b.set_horizontal_align(`=`r'-2',`c',"center")
				
				mata: b.put_string(`=`r'-1', `c',"Register Yes")	
				mata: b.put_string(`=`r'-1', `=`c'+1',"Register No")	
				mata: b.put_string(`r', `=`c'-1',"History Yes")
				mata: b.set_horizontal_align(`r', `=`c'-1',"right")

				mata: b.put_string(`=`r'+1', `=`c'-1',"History No")
				mata: b.set_horizontal_align(`=`r'+1', `=`c'-1',"right")
			
				mata: b.set_horizontal_align((`=`r'-2',`=`r'-2'),(2,`=`c'+1'),"center")
			}
			
			* Add footnote
			if "`d'"=="BCG" {
				mata: b.put_string(`=`r'+2',1, "BCG Scar data is excluded from these tables.")
				style_font, row(`=`r'+2')
				local ++r
			}
			pink_footnotes, srow(`=`r'+2')
			
			local r `=`r' + 6'
		}
		
		
			
		* Set borders
		create_box_boarders, srow(`=`i'-4') erow(`=`r'-4') scol(1) ecol(`fill')
		
		* Format columns to percent and add commas
		foreach num of numlist 1/14 {
			 mata: b.set_number_format(`num', 3, "percent")
			 mata: b.set_number_format(`num', 6, "percent")
			 mata: b.set_number_format(`num', 9, "percent")
 			 mata: b.set_number_format(`num', 2, "number_sep")
			 mata: b.set_number_format(`num', 5, "number_sep")
			 mata: b.set_number_format(`num', 8, "number_sep")
  			 mata: b.set_number_format(`num', 4, "number_sep")
			 mata: b.set_number_format(`num', 7, "number_sep")
			 mata: b.set_number_format(`num', 10, "number_sep")
		}

		* Set column width
		mata: b.set_column_width(1, 1, 70)
		
		mata: b.set_column_width(2,2, 11)
		mata: b.set_column_width(3,3, 11)
		
		`ifreg' {
			mata: b.set_column_width(6,6, 11)
			mata: b.set_column_width(7, 7, 11)
			mata: b.set_column_width(10, 10, 11)
			mata: b.set_column_width(11, 11, 11)
		}
		
		************************************************************************
		* Format the tab with details about doses changed to ticks
		mata: b.set_sheet("DATES VCQI CHANGED TO TICKS")
		
		local tick_row = wordcount("$RI_DOSE_LIST") + 2
		local tick_end 8
		`ifreg' local tick_end 15

		* Put the header in
		mata: b.put_string(2, 1, "Number of Dates VCQI Changed to Tick by Dose and Reason")
		mata: b.set_text_wrap(2,1,"on")
		mata: b.set_font_bold(2, 1, "on")
		
		* align the text
		mata: b.set_horizontal_align((3,`tick_row'),1, "right")
		mata: b.set_horizontal_align((1,2),(2,`tick_end'), "center")
		
		* Add the Card header
		mata: b.put_string(1,2,"Card")
		mata: b.set_sheet_merge("DATES VCQI CHANGED TO TICKS",(1,1),(2,8))
		
		`ifreg' {
		    * add Register header
		    mata: b.set_sheet_merge("DATES VCQI CHANGED TO TICKS", (1,1), (9,15))
			mata: b.put_string(1,9,"Register")
		}
				
		* Make borders for card and register
		mata: b.set_right_border((1,`tick_row'),(8,8), "thin","black")
		`ifreg' mata: b.set_right_border((1,`tick_row'),(`tick_end',`tick_end'), "thin","black")
		
		* Add a gray shading for top 2 lines
		mata: b.set_fill_pattern((1,2),(1,`tick_end'),"solid","lightgray")
		
		* Blackout Multi dose categories for the cells that are for single doses
		foreach b in `blackout_list' {
		    local b = `b' + 2
		    mata: b.set_fill_pattern(`b',(6,8),"solid","lightgray")
			`ifreg' mata: b.set_fill_pattern(`b',(13,15),"solid","lightgray")
		}
		foreach b in `blackout_list2' {
			local b = `b' + 2
			mata: b.set_fill_pattern(`b',8,"solid","lightgray")
			`ifreg' mata: b.set_fill_pattern(`b',15,"solid","lightgray")
		}
		
		* Add the column headers
		mata: b.put_string(2,2,"Partial Dates")
		mata: b.put_string(2,3,"Nonsensical Dates")  
		mata: b.set_text_wrap(2,(4,8),"on")
		mata: b.put_string(2,4,"Dates Before Earliest Possible Date") 
		mata: b.put_string(2,5,"Dates Past Survey Date") 
		mata: b.put_string(2,6,"Dates Out of Order Within Series") 
		mata: b.put_string(2,7,"Same Dates Within Series")
		mata: b.put_string(2,8,"To be consistent with evidence of a later dose")
		`ifreg' {
		    mata: b.put_string(2,13,"Register")
		    mata: b.put_string(2,9,"Partial Dates")
			mata: b.put_string(2,10,"Nonsensical Dates")  
			mata: b.set_text_wrap(2,(11,15),"on")
			mata: b.put_string(2,11,"Dates Before Earliest Possible Date") 
			mata: b.put_string(2,12,"Dates Past Survey Date") 
			mata: b.put_string(2,13,"Dates Out of Order Within Series") 
			mata: b.put_string(2,14,"Same Dates Within Series")
			mata: b.put_string(2,15,"To be consistent with evidence of a later dose")

		}
		
		****************************************************************************
		* Create boarders
		create_box_boarders, srow(1) erow(`tick_row') scol(1) ecol(`tick_end')
		
		* Add Footnotes
		mata: b.put_string(`=`tick_row'+1',1,"Note: These are the details around why VCQI changed dates to tick marks for each dose.")
		mata: b.put_string(`=`tick_row'+2',1,"Note: For multi dose series the second dose is also changed to a tick if dose 1 and 3 are out of order and dose 2 is within range.")
		style_font, row(`=`tick_row'+1')
		style_font, row(`=`tick_row'+2')
		
		* Adjust column width
		mata: b.set_column_width(1, 1, 25)
		forvalues i = 2/`tick_end' {
			mata: b.set_column_width(`i',`i', 17)
		}
		
		* format numbers to include commas
		mata: b.set_number_format((2,`tick_end'),(3,`tick_row'),"number_sep")
		
		mata: b.close_book()	
	}
end		
   

capture program drop top_data
program define top_data
	
	syntax, sheet(string asis) row(int) ifreg(string asis)
	
	local sheet `=upper("`sheet'")'
	mata: b.set_sheet("`sheet'") 

	* Fill in table text in DOB sheet
	if strpos("`sheet'", "SERIES") == 0 mata: b.put_string(1, 1, "`sheet': Present")
	if "`sheet'"=="DOSE SUMMARY" mata: b.put_string(1, 1, "Doses: Present")
	
	mata: b.set_font_bold(1, 1, "on")
	mata: b.put_string(1, 2,"Card")	
	local xlcol1 5
	
	`ifreg' mata: b.put_string(1, `xlcol1',"Register")	
	`ifreg' local xlcol1 `= `xlcol1' + 3'
	if strpos("`sheet'", "SERIES") == 0 mata: b.put_string(1, `xlcol1',"History")
	
	* Grab the last column
	if strpos("`sheet'", "SERIES") == 0 local xlcol2 `= `xlcol1' + 3' 
	else local xlcol2 = `xlcol1'
	* Merge cells
	if strpos("`sheet'", "SERIES") == 0 mata: b.set_sheet_merge("`sheet'", (1, 2), (1, 1))
	mata: b.set_sheet_merge("`sheet'", (1, 1), (2, 4))
	if strpos("`sheet'", "SERIES") == 0 mata: b.set_sheet_merge("`sheet'", (1, 1), (5, 7))
	`ifreg' & strpos("`sheet'", "SERIES") > 0 mata: b.set_sheet_merge("`sheet'", (1, 1), (5, 7))
	`ifreg' & strpos("`sheet'", "SERIES") == 0 mata: b.set_sheet_merge("`sheet'", (1, 1), (8, 10))

	* Center headers
	mata: b.set_horizontal_align((1, 2),(1, 1),"left")
	mata: b.set_horizontal_align(1,(2, 4),"center")
	mata: b.set_horizontal_align(1,(5, 7),"center")
	`ifreg' mata: b.set_horizontal_align(1,(8, 11),"center")

	* Set local for rows
	local xlrow1 `row' //18
	local xlrow2 `=`xlrow1' + 4' //22
	
	`ifreg' local xlrow2 `=`xlrow1' + 6' //24
	mata: b.set_horizontal_align(2,(2, `xlcol2'),"center")
	mata: b.set_horizontal_align(`xlrow1',(2, `xlcol2'),"center")
	*if `register' mata: b.set_horizontal_align(`xlrow2',(2, 11),"center")

	* align group data to the right like all other text
	mata: b.set_horizontal_align((3,13),(`xlcol2',`xlcol2'),"right")

	* Add color fill
	mata: b.set_fill_pattern((1,2),(1,`xlcol2'),"solid","lightgray")
	if strpos("`sheet'", "SERIES") == 0 mata: b.set_fill_pattern(`xlrow1',(1,4),"solid","lightgray")
	
	local xlrow3 `=`xlrow2' + 4'
	local xlrow4 `=`xlrow2'-3' 
		
	forvalues i = 1/4 {
		c_local xlrow`i' `xlrow`i''
	}
	
	c_local xlcol1 `xlcol1'
	c_local xlcol2 `xlcol2'

end

capture program drop top_footnotes 
program define top_footnotes

	syntax, row(int)

	* Add Footnotes
	mata: b.put_string(`row',1,"Note: Nonsensical dates refer to participants who had all three date components that did not result a calendar date... eg 2/29/2012, 6/31/2014, 14/2/0214 etc.")
	style_font, row(`row')
	local ++row

	mata: b.put_string(`row',1,"Note: Sensible dates refer to participants who had all three date components that resulted in a true calendar date... eg 2/28/2012, 6/1/2014 etc.")
	style_font, row(`row')
	local ++row
	
	mata: b.put_string(`row',1,"Note: If the pink cells hold non-zero numbers, that is an indication of incomplete or nonsensical dates.")
	style_font, row(`row')
	local ++row 
	
	mata: b.put_string(`row',1,"Note: Within each group, the numbers in the n column must sum up to the denominator and the % numbers add up to 100%. The rows within each group are mutually exclusive and exhaustive.")
	style_font, row(`row')
		
end

capture program drop style_font
program define style_font

	syntax , row(int) 
	
	mata: b.set_font_italic(`row',1,"on")
	mata: b.set_font_bold(`row',1,"on")

end

capture program drop pink_fill
capture program define pink_fill
	syntax, row(int) col(int)
	
	mata: b.set_fill_pattern(`row',`col',"solid","pink")

end

capture program drop top_pink_fill
program define top_pink_fill
	syntax , xlcol1(int)

	* Shade cells if they are greater than zero, inidicating incomplete or nonsensical dates
	foreach v in 5 6 8 10 11 {
		forvalues d = 2(3)`xlcol1' {
			pink_fill, row(`v') col(`d')
		}
	}

end

capture program drop create_box_boarders
program define create_box_boarders

	syntax , srow(int) erow(int) scol(int) ecol(int)

	*Set borders
	mata: b.set_left_border((`srow',`erow'),(`scol',`scol'), "medium","black")
	mata: b.set_right_border((`srow',`erow'),(`ecol',`ecol'), "medium","black")
	mata: b.set_top_border((`srow',`srow'),(`scol',`ecol'), "medium","black")
	mata: b.set_bottom_border((`erow',`erow'),(`scol',`ecol'), "medium","black")

end		
		
		************************************************
capture program drop format_to_percent
program define format_to_percent

	syntax , width(int) ifreg(string asis)

	mata: b.set_column_width(1, 1, `width')
		
	* Set format to % and add comma 
	foreach num of numlist 1/100 {
	    mata: b.set_number_format(`num', 2, "number_sep")
		mata: b.set_number_format(`num', 4, "number_sep")
		mata: b.set_number_format(`num', 5, "number_sep")
		mata: b.set_number_format(`num', 7, "number_sep")
		`ifreg' mata: b.set_number_format(`num', 8, "number_sep")
		`ifreg' mata: b.set_number_format(`num', 10, "number_sep")

		 mata: b.set_number_format(`num', 3, "percent")
		 mata: b.set_number_format(`num', 6, "percent")
		`ifreg' mata: b.set_number_format(`num', 9, "percent")
	}

end

capture program drop pink_footnotes
program define pink_footnotes

	syntax , srow(int)

	mata: b.put_string(`srow',1,"Note: If the pink cells hold non-zero numbers, that is an indication of discordance between sources.")
	mata: b.set_font_italic(`srow',1,"on")
	mata: b.set_font_bold(`srow',1,"on")	
	
end


