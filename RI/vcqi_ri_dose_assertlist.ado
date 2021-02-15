**! vcqi_ri_dose_assertlist version 1.01 - Mary Kay Trimner & Dale Rhoda - 2021-02-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name				What Changed
* 2020-10-14	1.00	Mary Kay Trimner	Original Version
* 2021-02-01	1.01	Dale Rhoda			Change varnames of RI09[m/d/y] to
*                                           include the new underscore (_)
*                                           Also run MULTI_2 and MULTI_3 thru
*                                           lower-case before running checks
* 2021-02-02	1.02	Dale Rhoda			Allow user to specify an listlist
*                               
*******************************************************************************
*
* Contact Dale Rhoda (Dale.Rhoda@biostatglobal.com) with comments & suggestions.
*
* This program runs basic assertlist checks for VCQI doses from globals
* aRI_SINGLE_DOSE_LIST, RI_MULTI_2_DOSE_LIST and RI_MULTI_3_DOSE_LIST
* It can be ran before VCQI to identify potential dose date issues.
*
program vcqi_ri_dose_assertlist
	version 16.1
	
	syntax [, LISTlist(varlist)]
	
	qui {
		
		
		* Do a check to see if the appropriate globals are set
		* We will set a local to determine if the program needs to exit based on these checks
		local exit_flag 0
		
		capture assert "$VCQI_OUTPUT_FOLDER" != "" 
		if _rc != 0 noi di as text "WARNING: If VCQI Global VCQI_OUTPUT_FOLDER from Code Block: RI-B in the RI Control Program" /// 
									" is not set, output will be sent to the current directory:" ///
									" `:pwd'" 
					noi di as text " "
					
		else cd "${VCQI_OUTPUT_FOLDER}"
		
		local file_exists 1
		foreach v in VCQI_DATA_FOLDER VCQI_RI_DATASET {
			capture assert "$`v'" != ""
			if _rc != 0 {
				local exit_flag 1
				local file_exists 0
				noi di as error "ERROR : VCQI Global `v' from Code Block: RI-B in the RI Control Program" /// 
									" must be set to run this program."
				noi di as text " "
			}
		}
		if `file_exists' == 1 {
			capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}.dta"
			if _rc != 0 {
				local exit_flag 1
				noi di as error `"ERROR: File "${VCQI_RI_DATASET}" provided in VCQI global VCQI_RI_DATASET"' ///
								`" does not exist in path "${VCQI_DATA_FOLDER}" from VCQI global VCQI_DATA_FOLDER."' ///
								" Please correct the globals located in Code Block: RI-B in the RI Control Program." 
				noi di as text " "
			}
		}

		if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1  {
			 capture assert "$VCQI_RIHC_DATASET" != ""
			if _rc != 0 {
				local exit_flag 1
				noi di as error "ERROR : VCQI Global VCQI_RIHC_DATASET from Code Block: RI-B in the Control Program" ///
								" must be set to run this program if either RI_RECORDS_SOUGHT_FOR_ALL or RI_RECORDS_SOUGHT_IF_NO_CARD global is set to 1"
				noi di as text " "
			}
			else {
				if "$VCQI_DATA_FOLDER" != "" capture confirm file "${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}.dta"
				if _rc != 0 {
					local exit_flag 1
					noi di as error `"ERROR : File "${VCQI_RIHC_DATASET}" provided in VCQI global VCQI_RI_DATASET"' ///
									`" does not exist in path "${VCQI_DATA_FOLDER}" from VCQI global VCQI_DATA_FOLDER."' ///
									" Please correct the globals located in Code Block: RI-B in the RI Control Program." 
					noi di as text " "
				}
			}
		}
		
		foreach v in EARLIEST_SVY_VACC_DATE_M EARLIEST_SVY_VACC_DATE_D EARLIEST_SVY_VACC_DATE_Y ///
					LATEST_SVY_VACC_DATE_M LATEST_SVY_VACC_DATE_D LATEST_SVY_VACC_DATE_Y ///
					RI_RECORDS_SOUGHT_FOR_ALL RI_RECORDS_SOUGHT_IF_NO_CARD {
			capture assert "$`v'" != ""
			if _rc != 0 {
				local exit_flag 1
				noi di as error "ERROR : VCQI Global `v' from Code Block: RI-D in the RI Control Program" /// 
									" must be set to run this program." 
				noi di as text " "
			}
		}
		
		capture assert "$RI_SINGLE_DOSE_LIST" != "" | "$RI_MULTI_2_DOSE_LIST" != "" | "$RI_MULTI_3_DOSE_LIST" != "" 
		if _rc != 0 {
			local exit_flag 1
			noi di as error "Error: This program requires at least one of the following VCQI Globals from Code Block: RI-D in the RI Control Program to be set:" ///
							" RI_SINGLE_DOSE_LIST, RI_MULTI_2_DOSE_LIST or RI_MULTI_3_DOSE_LIST."
			noi di as text " "
		}
		else {
			* We want to create the global that holds all the doses just like in the VCQI RI Control Program
			* First, list single dose vaccines 
			global RI_DOSE_LIST `=lower("$RI_SINGLE_DOSE_LIST")'

			* Then list each dose for two-dose vaccines 
			foreach i in $RI_MULTI_2_DOSE_LIST {
				global RI_DOSE_LIST "$RI_DOSE_LIST `=lower("`i'")'1 `=lower("`i'")'2"
			}

			* Finally, list each dose for three-dose vaccines 
			foreach i in $RI_MULTI_3_DOSE_LIST {
				global RI_DOSE_LIST "$RI_DOSE_LIST `=lower("`i'")'1 `=lower("`i'")'2 `=lower("`i'")'3"
			}

			* Confirm that the scalar for min age is set for each dose
			foreach v in $RI_DOSE_LIST {
				capture assert `v'_min_age_days != .
				if _rc != 0 {
					local exit_flag 1
					noi di as error "ERROR: scalar `v'_min_age_days from Code Block: RI-C from the RI Control Program must be set to run this program."
					noi di as text " "
				}
			}
		}
		
		if `exit_flag' == 1 {
			noi di as error "Program is exiting due to the above errors."
		}
		
		else {
			* Erase old version of output spreadsheet
			capture erase vcqi_ri_dose_date_assertions.xlsx
			
			use "${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}", clear
			tempfile vcqi_ri_dose_assertlist
			save `vcqi_ri_dose_assertlist', replace
			
			* Set local for ids
			local ids RI01 RI03 RI11 RI12
			
			* Set a local for the source to be used in the assertions
			local source card
			local check dob_history, dob_card
			
			if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 {
				
				* Add Register to the source	
				local source `source' register
				
				* Create the 4 id variables to merge in the Register data
				clonevar RIHC01 = RI01
				clonevar RIHC03 = RI03
				clonevar RIHC14 = RI11
				clonevar RIHC15 = RI12
				
				merge 1:1 RIHC01 RIHC03 RIHC14 RIHC15 using "${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}" , nogen
				gen dob_register = mdy(dob_date_register_m,dob_date_register_d,dob_date_register_y)
				format %td dob_register
				
				local check dob_history, dob_card, dob_register

				save `vcqi_ri_dose_assertlist', replace	
			}
			else {
				gen dob_date_register_m = .
				gen dob_date_register_d = .
				gen dob_date_register_y = .
			}
			
			
			* User requested additional variables as IDs
			*
			* Trim them from the list if they don't occur in the dataset
			
			if "`listlist'" != "" {
				foreach v in `listlist' {
					capture confirm variable `v'
					if _rc == 0 local ids `ids' `v'
					else di as error "The user specified `v' as part of the list() option to vcqi_ri_dose_assertlist but `v' is not a variable in the VCQI_RI_DATASET or VCQI_RIHC_DATASET so we are dropping `v' from the list()."
				}
			}
					
			
			/*  These are the date checks this program will perform:
			1.	DOB is sensical if populated
			2.	Interview date is sensical if populated
			3.	DOB is before interview date 
			4.	Dose date is sensical if populated
			5.	Dose date ≥ DOB 
			6.	Dose date ≤ interview date
			7.	Doses in a series do not use the same date
			8.	Doses in a series appear in order
			*/
			
			local output1 excel(vcqi_ri_dose_date_assertions) sheet(nonsensical dates) 
			local output2 excel(vcqi_ri_dose_date_assertions) sheet(date relationships) 

			* Create single date variables for each dose
			foreach d in $RI_DOSE_LIST {	
				foreach s in `source' {
					gen `d'_`s' = mdy(`d'_date_`s'_m,`d'_date_`s'_d,`d'_date_`s'_y)
					format %td `d'_`s'
				}
				local `d' = `d'_min_age_days
			}
			
			* Create single variables with interview date and other date values.
			capture gen RI09 		= mdy(RI09_m, RI09_d, RI09_y)
			gen dob_card 			= mdy(dob_date_card_m,dob_date_card_d,dob_date_card_y)
			gen dob_history 		= mdy(dob_date_history_m,dob_date_history_d,dob_date_history_y)
			
			* Create variables for the earliest and latest possible vaccination dates
			gen earliest_svy_date 	= mdy($EARLIEST_SVY_VACC_DATE_M,$EARLIEST_SVY_VACC_DATE_D,$EARLIEST_SVY_VACC_DATE_Y)
			gen latest_svy_date		= mdy($LATEST_SVY_VACC_DATE_M, $LATEST_SVY_VACC_DATE_D, $LATEST_SVY_VACC_DATE_Y)
			
			format %td RI09 dob_card dob_history earliest_svy_date latest_svy_date
			order RI09 earliest_svy_date latest_svy_date, after(RI09_y)		

			* We will compare where card and history are provided and they do not match
			* to determine the appropriate dob
			* We will also look at register when appropriate
			* If all dates are the same, it is simple we will use that. Otherwise we will use the earliest date
			gen dob = .
			gen dob_type = ""
			format %td dob
			order dob, after(dob_date_card_y)
			
			replace dob_type =  "History and Card" if dob_history == dob_card
			if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 {
				replace dob_type =  "History and Register" if dob_history == dob_register
				replace dob_type =  "History and Card and Register" if dob_history == dob_card & dob_history == dob_register
			}
						
			replace dob = min(`check')
						
			replace dob_type = "History" if min(`check') == dob_history & dob_history != dob_card
			replace dob = dob_history if dob_type == "History"
			
			replace dob_type = "Card" if min(`check') == dob_card & dob_history != dob_card
			replace dob = dob_card if dob_type == "Card"
			
			if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 {
				replace dob_type = "Register" if min(`check') == dob_register & (dob_history != dob_register | dob_register != dob_card) 
				replace dob = dob_register if dob_type == "Register"
			}
			
			order dob_type, after(dob)
			
			* Create single dob m d y values to use in assertions
			gen dob_m = month(dob)
			gen dob_d = day(dob)
			gen dob_y = year(dob)
			

			* Check to make sure the interview date is sensical
			assertlist !missing(RI09) if !missing(RI09_m) | !missing(RI09_d) | !missing(RI09_y), `output1' tag(Interview date is nonsensical) list(`ids' RI09 RI09_m RI09_d RI09_y)   	

			* First do an assertion to see which dobs are before interview date
			assertlist dob < RI09, list(`ids' dob RI09) ///
								`output2' tag(DOB from specified dob_type is after interview date)
																
			* Next check to see which dobs are before the earliest possible date
			assertlist dob > earliest_svy_date, list(`ids' dob earliest_svy_date) ///
							`output2' ///
							tag(DOB from specified dob_type is before earliest possible vx date making the child too old for survey)							

			* Now do dose specific assertions
			foreach s in `source' {
				foreach d in $RI_DOSE_LIST  {	
					local sign >
					if ``d'' == 0 local sign >=
					
					* Check to see if vaccination date is before dob or earliest_svy_date
					* Check that dose date is after (or equal to for birth doses) child's dob
					assertlist `d'_`s' `sign' dob if !missing(`d'_`s'), list(`ids' dob `d'_`s') ///
																`output2' tag(`d' date from `s' is before DOB from specified dob_type) 
																	
					* Check that dose date is before or equal to interview date												
					assertlist `d'_`s' <= RI09 if !missing(`d'_`s'), list(`ids' RI09 `d'_`s') ///
																	`output2' tag(`d' date from `s' is after interview date) 
					
					* Check that dose date is after or equal to earliest interview date
					assertlist `d'_`s' >= earliest_svy_date  if !missing(`d'_`s'), list(`ids' earliest_svy_date `d'_`s') ///
																	`output2' tag(`d' date from `s' is before earliest vx date) 
																	
					* Check that dose date is before or equal to latest possible survey date											
					assertlist `d'_`s' <= latest_svy_date if !missing(`d'_`s'), list(`ids' latest_svy_date `d'_`s') ///
																	`output2' tag(`d' date from `s' is after latest possible interview date) 									
					* Check for partial and nonsensical dates
					assertlist !missing(`d'_`s') if !missing(`d'_date_`s'_m) | !missing(`d'_date_`s'_d) | !missing(`d'_date_`s'_y), ///
												list(`ids' `d'_`s' `d'_date_`s'_m `d'_date_`s'_d `d'_date_`s'_y) ///
												`output1' tag(`d' date from `s' is a partial or nonsensical date)
				}

				* Now look at multi doses
				foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
					* Confirm that first dose is less than the second and third
					local `d'list `d'1_`s' `d'2_`s'
					local `d'list2 `d'1_date_`s'_m `d'1_date_`s'_d `d'1_date_`s'_y `d'2_date_`s'_m `d'2_date_`s'_d `d'2_date_`s'_y

					gen `d'1_`d'2_`s'_ooo = `d'1_`s' >= `d'2_`s'  if !missing(`d'1_`s')  & !missing(`d'2_`s')
					gen `d'_`s'_ooo = `d'1_`d'2_`s'_ooo == 1 
					
					* Confirm dose 1 is after dose 2 (This will also capture those that are equal)
					assertlist `d'_`s'_ooo == 0, `output2' tag(`d' series from `s' has doses equal or out of order) list(`ids' ``d'list' ``d'list2')  

				}

				* Now look at multi doses
				foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
					* Confirm that first dose is less than the second and third
					local `d'list `d'1_`s' `d'2_`s' `d'3_`s'
					local `d'list2 `d'1_date_`s'_m `d'1_date_`s'_d `d'1_date_`s'_y `d'2_date_`s'_m `d'2_date_`s'_d `d'2_date_`s'_y `d'3_date_`s'_m `d'3_date_`s'_d `d'3_date_`s'_y

					gen `d'1_`d'2_`s'_ooo = `d'1_`s' >= `d'2_`s'  if !missing(`d'1_`s')  & !missing(`d'2_`s')
					gen `d'_`s'_ooo = `d'1_`d'2_`s'_ooo == 1 

					gen `d'1_`d'3_`s'_ooo = `d'1_`s' >= `d'3_`s'  if !missing(`d'1_`s')  & !missing(`d'3_`s')
					gen `d'2_`d'3_`s'_ooo = `d'2_`s' >= `d'3_`s'  if !missing(`d'2_`s')  & !missing(`d'3_`s')
					replace `d'_`s'_ooo = 1 if `d'1_`d'3_`s'_ooo == 1 |  `d'2_`d'3_`s'_ooo ==1
					
					* Confirm dose 1 is after dose 2 (This will also capture those that are equal)
					assertlist `d'_`s'_ooo == 0, `output2' tag(`d' series from `s' has doses equal or out of order) list(`ids' ``d'list' ``d'list2')  

				}
			}

			* Create a single tab with ids
			* This will not work due to the fact that we did not include a list function
			assertlist_export_ids, excel(vcqi_ri_dose_date_assertions)
		}
	}
end
