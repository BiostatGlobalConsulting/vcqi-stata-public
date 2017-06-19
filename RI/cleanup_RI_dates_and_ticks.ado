*! cleanup_RI_dates_and_ticks v 1.10  Biostat Global Consulting 2017-05-12
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Corrected var label for latest_svy_vacc_date 
* 2016-02-14	1.02	Dale Rhoda		Set VCQI_ERROR to 1 if exitflag == 1
* 2016-09-19	1.03	Dale Rhoda		Only run if VCQI_CHECK_INSTEAD_OF_RUN
*										is not 1
* 2016-11-22	1.04	Dale Rhoda		Set tick to missing if original tick and
*										original date were missing; this allows
*										the variable no_register to be 1
* 2016-12-01	1.05	Dale Rhoda		Set tick to 0 if appropriate; fixes bug
*										introduced in 1.04
* 2017-01-09	1.06	Dale Rhoda		Check to see if 1+ respondents have
*										a complete DOB; if not, set the global
*										VCQI_NO_DOB so some indicators can
*										be gracefully skipped downstream.
* 2017-01-30	1.07	Dale Rhoda		Check to see if doses in 
*										RI_MULTI_2_DOSE_LIST are out of order
* 2017-04-27	1.08	MK Trimner		Added code to set tick for earlier dose if later dose received
*										but missing earlier dose
* 2017-05-11	1.09	MK Trimner		In line 419 for dq_flag_22.. change >= to just > latest_svy_vacc_date
*
* 2017-05-12	1.10	Dale Rhoda		Fixed a typo
*
*******************************************************************************

* This program accomplishes several things:
* - It merges the RI and RIHC datasets (if RIHC records were sought)
*
* - It checks to be sure there are date and tick variables for each
*   dose in the RI_DOSE_LIST (both in the card and register datasets)
*
* - If RIHC records were not sought, it puts empty register variables in 
*   the dataset.
*
* - It assigns a dob_for_valid_dose_calculations, if there are m, d, and y 
*   data elements in the dob from card, history, or register.
*
* - It looks at the vaccination dates on the cards and in the register,
*   checking to see that they occured a) after the child's birthdate, if known,
*   b) after the earliest possible birthdate in the survey if the child's dob
*   is not known, c) before the survey began, and d) if a dose in a series, it
*   checks to be sure that sequential doses occur in chronologic order.  
*
* - Where it finds a vaccine date on dose or register that does not have these
*   properties, it sets the date to missing and marks a tick mark instead, so
*   the child will get credit for having the dose, but the nonsensical date
*   will not be passed into the measures that interpret vaccination dates.
*
* - Finally it merges the new dataset containing clean dates and ticks with
*   the full RI dataset.
*
* The dataset that comes from this program will need unique IDs and then it 
* should have everything needed to calculate the RI analyses.
*   

program define cleanup_RI_dates_and_ticks

	local oldvcp $VCP
	global VCP cleanup_RI_dates_and_ticks
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		if "$VCQI_CHECK_INSTEAD_OF_RUN" != "1" {
		
			use "${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}", clear

			if ${RI_RECORDS_SOUGHT_FOR_ALL} == 1 | ${RI_RECORDS_SOUGHT_IF_NO_CARD} == 1 {
			
				local register register
			
				gen RIHC01 = RI01
				gen RIHC03 = RI03
				gen RIHC14 = RI11
				gen RIHC15 = RI12
				
				merge 1:1 RIHC01 RIHC03 RIHC14 RIHC15 using ///
					"${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}", ///
					keepusing(*date_register_d *date_register_m *date_register_y *tick_register)
					
				keep if _merge == 1 | _merge == 3 
				drop _merge
			
				local exitflag 0
			
				foreach s in card `register' {
				
					foreach d in dob $RI_DOSE_LIST {
					
						capture confirm variable `d'_date_`s'_d
						if _rc > 0 {
							di as error "cleanup_RI_dates_and_ticks: Expected to find `d'_date_`s'_d in the RI dataset"
							di as error "RI_RECORDS_SOUGHT_FOR_ALL is ${RI_RECORDS_SOUGHT_FOR_ALL}"
							di as error "RI_RECORDS_SOUGHT_IF_NO_CARD is ${RI_RECORDS_SOUGHT_IF_NO_CARD}"
							local exitflag 1
						}
						
						capture confirm variable `d'_date_`s'_m
						if _rc > 0 {
							di as error "cleanup_RI_dates_and_ticks: Expected to find `d'_date_`s'_m in the RI dataset"
							di as error "RI_RECORDS_SOUGHT_FOR_ALL is ${RI_RECORDS_SOUGHT_FOR_ALL}"
							di as error "RI_RECORDS_SOUGHT_IF_NO_CARD is ${RI_RECORDS_SOUGHT_IF_NO_CARD}"
							local exitflag 1
						}
						
						capture confirm variable `d'_date_`s'_y
						if _rc > 0 {
							di as error "cleanup_RI_dates_and_ticks: Expected to find `d'_date_`s'_y in the RI dataset"
							di as error "RI_RECORDS_SOUGHT_FOR_ALL is ${RI_RECORDS_SOUGHT_FOR_ALL}"
							di as error "RI_RECORDS_SOUGHT_IF_NO_CARD is ${RI_RECORDS_SOUGHT_IF_NO_CARD}"
							local exitflag 1
						}
					}

					foreach d in $RI_DOSE_LIST {

						capture confirm variable `d'_tick_`s'
						if _rc > 0 {
							di as error "cleanup_RI_dates_and_ticks: Expected to find `d'_tick_`s' in the RI dataset"
							di as error "RI_RECORDS_SOUGHT_FOR_ALL is ${RI_RECORDS_SOUGHT_FOR_ALL}"
							di as error "RI_RECORDS_SOUGHT_IF_NO_CARD is ${RI_RECORDS_SOUGHT_IF_NO_CARD}"
							local exitflag 1
						}
				
					}
				}
				if `exitflag' == 1 {
					vcqi_global VCQI_ERROR 1
					vcqi_halt_immediately
				}
			}
			
			if ${RI_RECORDS_NOT_SOUGHT} == 1 {
			
				local register 
				
				foreach d in $RI_DOSE_LIST {
					gen `d'_register_tick = .
					gen `d'_register_date = .
					gen `d'_date_register_m = .
					gen `d'_date_register_d = .
					gen `d'_date_register_y = .
				}
				gen dob_date_register_m = .
				gen dob_date_register_d = .
				gen dob_date_register_y = .	
				gen dob_register_date = .
			
			}
			
			********************************************************************************
			********************************************************************************
			* Identify respondents with an unambiguous date of birth and assign it for
			* valid dose calculations
			*
			* If there are several values specified for dob (across card, history, and 
			* register) then use the earliest one (because it will yield the highest
			* count of valid vaccination dates)
			*
			********************************************************************************
			********************************************************************************

			* Is there a single m, single d, and single y specified across all three
			* sources?  Note that the m, d, and y can come from different sources...but
			* if they comprise together a valid date, let's use it.
			
			count
			local t = r(N)
			
			gen single_birthdate = 1
			foreach e in m d y {
				replace single_birthdate = 0 if ///
				   max(dob_date_card_`e', dob_date_history_`e', dob_date_register_`e') != ///
				   min(dob_date_card_`e', dob_date_history_`e', dob_date_register_`e') 
				replace single_birthdate = 0 if ///
				   max(dob_date_card_`e', dob_date_history_`e', dob_date_register_`e') == .
			}
			
			
			* If yes, use that value
			gen dob_for_valid_dose_calculations = mdy( ///
				   max(dob_date_card_m, dob_date_history_m, dob_date_register_m), ///
				   max(dob_date_card_d, dob_date_history_d, dob_date_register_d), ///
				   max(dob_date_card_y, dob_date_history_y, dob_date_register_y)) ///
				   if single_birthdate == 1

			* Drop the value if it is outside the range of valid birth dates	   
			replace dob_for_valid_dose_calculations = . if ///
					dob_for_valid_dose_calculations < ///
					mdy($EARLIEST_SVY_VACC_DATE_M, $EARLIEST_SVY_VACC_DATE_D, ///
						$EARLIEST_SVY_VACC_DATE_Y) |  ///
					dob_for_valid_dose_calculations > ///
					mdy($LATEST_SVY_VACC_DATE_M, $LATEST_SVY_VACC_DATE_D, ///
						$LATEST_SVY_VACC_DATE_Y)
			
			replace single_birthdate = 0 if ///
					dob_for_valid_dose_calculations < ///
					mdy($EARLIEST_SVY_VACC_DATE_M, $EARLIEST_SVY_VACC_DATE_D, ///
						$EARLIEST_SVY_VACC_DATE_Y) |  ///
					dob_for_valid_dose_calculations > ///
					mdy($LATEST_SVY_VACC_DATE_M, $LATEST_SVY_VACC_DATE_D, ///
						$LATEST_SVY_VACC_DATE_Y)
						
			count if single_birthdate == 1
			vcqi_log_comment $VCP 4 Data ///
			"Of the `t' children in the survey, `=scalar(r(N))' had a valid unambiguious date of birth between card, register and history."
				   
			* Otherwise, use the earliest plausible dob from card, register, or history 
			foreach s in card register history {
				gen dob_`s' = mdy(dob_date_`s'_m, dob_date_`s'_d, dob_date_`s'_y)
				replace dob_`s' = . if dob_`s' < ///
					mdy($EARLIEST_SVY_VACC_DATE_M, $EARLIEST_SVY_VACC_DATE_D, ///
						$EARLIEST_SVY_VACC_DATE_Y) | dob_`s' > ///
					mdy($EARLIEST_SVY_VACC_DATE_M, $EARLIEST_SVY_VACC_DATE_D, ///
						$EARLIEST_SVY_VACC_DATE_Y)+365
			}
			
			gen plausible_birthdate=1 if missing(dob_for_valid_dose_calculations) & !missing(min(dob_card, dob_history, dob_register))

			replace dob_for_valid_dose_calculations = ///
				min(dob_card, dob_history, dob_register) if ///
					dob_for_valid_dose_calculations == .

			count if single_birthdate == 0 & !missing(dob_for_valid_dose_calculations)
			vcqi_log_comment $VCP 4 Data ///
			"Of the `t' children in the survey, `=scalar(r(N))' used the earliest valid birth date provided from card, register and history"  
			
			count if missing(dob_for_valid_dose_calculations)
			vcqi_log_comment $VCP 4 Data ///
			"Of the `t' children in the survey, `=scalar(r(N))' did not have a valid dob on card, register or history."  
				
			format %td dob_for_valid_dose_calculations
			label variable dob_for_valid_dose_calculations "Date of birth for valid dose calculations"
			
			
			************************************************************************
			* Calculate age at time of survey
			*
			* Age is calculated using four steps
			*
			* If the respondent has DOB and a date of the interview 
			* then we use those two dates to calculate age
			*
			* Else if they have dob and no date of interview then we use the 
			* LATEST_SVY_VACC_DATE as the date of the interview
			*
			* Else if they have no dob then we use completed age in month * 30.4
			*
			* Else if they have only completed years then we use that * 365
			*
			gen age_at_interview = .
			label variable age_at_interview "Age at interview (days)"
			
			gen date_of_interview = .
			label variable date_of_interview "Date of interview (from RI09)"
			
			capture confirm variable RI09m
			local ri09m = _rc
			capture confirm variable RI09d
			local ri09d = _rc
			capture confirm variable RI09y
			local ri09y = _rc
			capture confirm variable RI09
			local ri09  = _rc
			
			if `ri09m' + `ri09d' + `ri09y' != 0 & `ri09' == 0 {
				gen RI09m = month(RI09)
				gen RI09d = day(RI09)
				gen RI09y = year(RI09)
			}
			capture confirm variable RI09m
			local ri09m = _rc
			capture confirm variable RI09d
			local ri09d = _rc
			capture confirm variable RI09y
			local ri09y = _rc
			
			if `ri09m' + `ri09d' + `ri09y' == 0 {
				replace date_of_interview = mdy(RI09m,RI09d,RI09y)
				replace age_at_interview = date_of_interview - dob_for_valid_dose_calculations if missing(age_at_interview)
			}
			gen date_of_last_possible_vacc = mdy($LATEST_SVY_VACC_DATE_M,$LATEST_SVY_VACC_DATE_D,$LATEST_SVY_VACC_DATE_Y)
			label variable date_of_last_possible_vacc "Date of last possible Vx (from global LATEST_SVY_VACC_DATE)"
			replace age_at_interview = date_of_last_possible_vacc - dob_for_valid_dose_calculations if missing(age_at_interview)
			
			capture confirm variable RI25
			if _rc == 0 replace age_at_interview = round(RI25 * 30.4,1) if missing(age_at_interview)
			
			capture confirm variable RI24
			if _rc == 0 replace age_at_interview = round(RI24 * 365.25) if missing(age_at_interview)

			/*create variables to determine the following:
				FLAGs 01-19 require date
				flag01-missing month
				flag02-missing day
				flag03-missing year
				flag04-missing only day
				flag05-missing all (month day and year)
				flag06-missing any (month or day or year)
				flag07-nonsense date(all components but mdy function results in missing)	
				
				FLAGs 20-50 based on final date from flags 01-07
				flag20-dose date before earliest possible dob in survey	
				flag21-dose date before dob
				flag22-dose date after survey date
				

				flag00-one or more of the above flags is set to 1
			*/

			*Logical statements to create flags 01-06
			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST {

					local l `:var label `v'_date_`s'_d'

					gen `v'_`s'_date_dq_flag01= missing(`v'_date_`s'_m)
					label variable `v'_`s'_date_dq_flag01 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Missing Month"
						
					gen `v'_`s'_date_dq_flag02= missing(`v'_date_`s'_d)
					label variable `v'_`s'_date_dq_flag02 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Missing Day"

					gen `v'_`s'_date_dq_flag03= missing(`v'_date_`s'_y)
					label variable `v'_`s'_date_dq_flag03 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Missing Year"

					gen `v'_`s'_date_dq_flag04=(`v'_`s'_date_dq_flag01==0 & `v'_`s'_date_dq_flag02==1 & `v'_`s'_date_dq_flag03==0)
					label variable `v'_`s'_date_dq_flag04 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Missing Day Only"
					
					gen `v'_`s'_date_dq_flag05=(`v'_`s'_date_dq_flag01 + `v'_`s'_date_dq_flag02 + `v'_`s'_date_dq_flag03 == 3)
					label variable `v'_`s'_date_dq_flag05 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Missing Complete Date"

					gen `v'_`s'_date_dq_flag06=(`v'_`s'_date_dq_flag01 + `v'_`s'_date_dq_flag02 + `v'_`s'_date_dq_flag03 > 0)
					label variable `v'_`s'_date_dq_flag06 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Missing Any Date Component"

					gen `v'_`s'_date_dq_flag07=mdy(`v'_date_`s'_m, `v'_date_`s'_d, `v'_date_`s'_y)==. & `v'_`s'_date_dq_flag06==0
					label variable `v'_`s'_date_dq_flag07 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -All date components result to nonsense date"
				}
			}

			*Logical statement for DOB

			*Creating new full date variable if flags01-07 equal zero
			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST{
					local l `:var label `v'_date_`s'_d'
					gen `v'_`s'_date = mdy(`v'_date_`s'_m, `v'_date_`s'_d, `v'_date_`s'_y) if ///
									  (`v'_`s'_date_dq_flag01 + `v'_`s'_date_dq_flag02  + ///
									   `v'_`s'_date_dq_flag03 + `v'_`s'_date_dq_flag04  + ///
									   `v'_`s'_date_dq_flag05 + `v'_`s'_date_dq_flag06  + ///
									   `v'_`s'_date_dq_flag07 ==0)
					format %td `v'_`s'_date 
					label variable `v'_`s'_date "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -With No Missing Components"
				}
			}

			
			*generate history dob in one variable for flag21
			gen dob_date_history=mdy(dob_date_history_m, dob_date_history_d, dob_date_history_y)
			format %td dob_date_history
			label variable dob_date_history "Date of birth - history"

			*generate card dob in one variable
			gen dob_date_card=mdy(dob_date_card_m, dob_date_card_d, dob_date_card_y)
			format %td dob_date_card
			label variable dob_date_card "Date of birth - card"

			*Generate one variable for start date and end date
			gen earliest_svy_vacc_date=mdy($EARLIEST_SVY_VACC_DATE_M, $EARLIEST_SVY_VACC_DATE_D, $EARLIEST_SVY_VACC_DATE_Y )
			format %td earliest_svy_vacc_date
			label variable earliest_svy_vacc_date "Earliest possible vaccinaton date in this survey"

			gen latest_svy_vacc_date=mdy($LATEST_SVY_VACC_DATE_M, $LATEST_SVY_VACC_DATE_D, $LATEST_SVY_VACC_DATE_Y )
			format %td latest_svy_vacc_date
			label variable latest_svy_vacc_date "Latest possible vaccinaton date in this survey"

			* Drop DOB if too early
			replace dob_date_card      = . if dob_date_card     < earliest_svy_vacc_date
			replace dob_date_history   = . if dob_date_history  < earliest_svy_vacc_date

			* Drop DOB if too late
			replace dob_date_card      = . if dob_date_card     > latest_svy_vacc_date
			replace dob_date_history   = . if dob_date_history  > latest_svy_vacc_date


			gen dob_card_dqd_date = dob_date_card
			label variable dob_card_dqd_date "DOB from card- DQD"

			gen dob_history_dqd_date = dob_date_history
			label variable dob_history_dqd_date "DOB from history - DQD"
			
			if ${RI_RECORDS_SOUGHT_FOR_ALL} == 1 | ${RI_RECORDS_SOUGHT_IF_NO_CARD} == 1 {
			
				*generate register dob in one variable
				gen dob_date_register=mdy(dob_date_register_m, dob_date_register_d, dob_date_register_y)
				format %td dob_date_register
				label variable dob_date_register "Date of birth - register"
				
				replace dob_date_register  = . if dob_date_register < earliest_svy_vacc_date
				replace dob_date_register  = . if dob_date_register > latest_svy_vacc_date
				
				gen dob_register_dqd_date = dob_date_register
				label variable dob_register_dqd_date "DOB from register- DQD"
				
			}
			
			*Logical statements for flags20-22			
			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST {

					local l `:var label `v'_date_`s'_d'
							
					gen `v'_`s'_date_dq_flag20=((`v'_`s'_date < earliest_svy_vacc_date) & !missing(`v'_`s'_date))
					label variable `v'_`s'_date_dq_flag20 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Before Earliest Possible Vacc Date in Survey"
					
					gen `v'_`s'_date_dq_flag21=((`v'_`s'_date < dob_for_valid_dose_calculations) & (!missing(`v'_`s'_date) & !missing(dob_for_valid_dose_calculations)))
					label variable `v'_`s'_date_dq_flag21 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Before DOB"
							
					gen `v'_`s'_date_dq_flag22 = (`v'_`s'_date>latest_svy_vacc_date) & !missing(`v'_`s'_date)
					label variable `v'_`s'_date_dq_flag22 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -After Latest Possible Vacc Date in Survey"

				}
			}

			*Create overall flag for flags 01-07 and 20-22
			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST {

					local l `:var label `v'_date_`s'_d'

					gen `v'_`s'_date_dq_flag00 = 0
					foreach i in 01 02 03 04 05 06 07 20 21 22 {
						replace `v'_`s'_date_dq_flag00 = 1 if `v'_`s'_date_dq_flag`i' == 1
						label variable `v'_`s'_date_dq_flag00 "`=substr("`l'",1,`=strpos("`l'","of vacc")'-1)' -Flag Problem(s) with Date"
					}
				}			
			}
						
			*Create new variable with Date if there are no flags set
			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST {

					local l `:var label `v'_date_`s'_d'
					
					gen `v'_`s'_dqd_date=`v'_`s'_date if `v'_`s'_date_dq_flag00==0
					label variable `v'_`s'_dqd_date "`=substr("`l'",1,`=strpos("`l'","date of vacc")'-1)' -RI Date DQD"
					format %td `v'_`s'_dqd_date
					capture drop `v'_`s'_date
						
				}
			}
			
			* If the user requests a report on data quality, issue it now
			
			if "$VCQI_REPORT_DATA_QUALITY" == "1" {
				noi date_tick_chk_01_dob_present
				noi date_tick_chk_02_dob_concordant
				noi date_tick_chk_03_sensible_dob
				noi date_tick_chk_04_dose_concordant
				noi date_tick_chk_05_excel_report

				use date_tick_in_progress, clear
			}
			
			* Create new variable for tick mark to indicate if there was no good date- 
			* did they have a tick mark OR 
			* did the document indicate it with an invalid date
			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST {
				
					local l `:var label `v'_date_`s'_d'

					gen `v'_`s'_dqd_tick= (`v'_tick_`s'==1 ) | (`v'_`s'_date_dq_flag00==1) // the card had a tick, or it had a date with a problem
					* ahhh...but we don't want to set a tick if the original variable was missing the entire date and missing the tick
					replace `v'_`s'_dqd_tick=0 if `v'_tick_`s'!=1 & `v'_`s'_date_dq_flag05==1
					replace `v'_`s'_dqd_tick=. if missing(`v'_tick_`s') & `v'_`s'_date_dq_flag05==1

					label variable `v'_`s'_dqd_tick "`=substr("`l'",1,`=strpos("`l'","date of vacc")'-1)' -RI dose received-tick mark or part of a date"
				}
			}
			
			
			*Count the total number of dates populated
			local dd 0
			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST {
					count if `v'_`s'_date_dq_flag05==0
					local dd = `dd' + r(N)		
				}
			}
			
			*Post to log if tick was changed to yes due to invalid date
			local iv_date_tick 0
			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST {
					count if `v'_`s'_dqd_tick==1 & `v'_tick_`s'==0
					local iv_date_tick = `iv_date_tick' + r(N)
				}
			}
			vcqi_log_comment $VCP 4 Data ///
			"Of the `dd' dose dates in the survey, `iv_date_tick' dates were incomplete or fell outside the possible vaccination date range for children eligibe for this survey so the dates were made missing, and the corresponding tick variable made a yes."
			

			* If register records were not sought then we faked some register data 
			* to get thru this program... and we set the local macro register to
			* be register, but here we clear it out
			
			if ${RI_RECORDS_NOT_SOUGHT} == 1 local register	
			
			* rename to take 'dqd' out of the variable name

			foreach s in card `register' {
				foreach v in $RI_DOSE_LIST {
					rename `v'_`s'_dqd_date `v'_`s'_date
					rename `v'_`s'_dqd_tick `v'_`s'_tick
				}
					rename dob_`s'_dqd_date dob_`s'_date
			}
			rename dob_history_dqd_date dob_history_date

			* fix dates and ticks if consecutive doses are out of order

			foreach s in card `register' {

				foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
					*flags to indicate that doses were given out of order (ooo)
					gen `d'12_`s'_ooo = `d'1_`s'_date > `d'2_`s'_date & !missing(`d'1_`s'_date) & !missing(`d'2_`s'_date)
					
					count if `d'12_`s'_ooo == 1
					if r(N) > 0 vcqi_log_comment $VCP 4 Data ///
					"The `s' date for dose 2 of `d' occurred before dose 1 in `=scalar(r(N))' instances. Both dates were set to missing and tick set to yes."
					
					* If 1 and 2 were out of order, knock out the dates and
					* mark the ticks
					replace `d'1_`s'_date = . if `d'12_`s'_ooo == 1
					replace `d'2_`s'_date = . if `d'12_`s'_ooo == 1
					replace `d'1_`s'_tick = 1 if `d'12_`s'_ooo == 1
					replace `d'2_`s'_tick = 1 if `d'12_`s'_ooo == 1
					
					drop `d'*_`s'_ooo
				}
			
				foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
					*flags to indicate that doses were given out of order (ooo)
					gen `d'12_`s'_ooo = `d'1_`s'_date > `d'2_`s'_date & !missing(`d'1_`s'_date) & !missing(`d'2_`s'_date)
					gen `d'23_`s'_ooo = `d'2_`s'_date > `d'3_`s'_date & !missing(`d'2_`s'_date) & !missing(`d'3_`s'_date)
					gen `d'13_`s'_ooo = `d'1_`s'_date > `d'3_`s'_date & !missing(`d'1_`s'_date) & !missing(`d'3_`s'_date)
					
					count if `d'12_`s'_ooo == 1
					if r(N) > 0 vcqi_log_comment $VCP 4 Data ///
					"The `s' date for dose 2 of `d' occurred before dose 1 in `=scalar(r(N))' instances. Both dates were set to missing and tick set to yes."
					
					count if `d'23_`s'_ooo == 1
					if r(N) > 0 vcqi_log_comment $VCP 4 Data ///
					"The `s' date for dose 3 of `d' occurred before dose 2 in `=scalar(r(N))' instances. Both dates were set to missing and tick set to yes."

					count if `d'13_`s'_ooo == 1
					if r(N) > 0 vcqi_log_comment $VCP 4 Data ///
					"The `s' date for dose 3 of `d' occurred before dose 1 in `=scalar(r(N))' instances. All 3 dates were set to missing and tick set to yes."

					* If 1 and 2 were out of order, knock out the dates and
					* mark the ticks
					replace `d'1_`s'_date = . if `d'12_`s'_ooo == 1
					replace `d'2_`s'_date = . if `d'12_`s'_ooo == 1
					replace `d'1_`s'_tick = 1 if `d'12_`s'_ooo == 1
					replace `d'2_`s'_tick = 1 if `d'12_`s'_ooo == 1
					
					* If 2 and 3 were out of order, knock out those dates and
					* mark the ticks
					replace `d'2_`s'_date = . if `d'23_`s'_ooo == 1
					replace `d'3_`s'_date = . if `d'23_`s'_ooo == 1
					replace `d'2_`s'_tick = 1 if `d'23_`s'_ooo == 1
					replace `d'3_`s'_tick = 1 if `d'23_`s'_ooo == 1

					* If 1 and 3 were out of order, knock out all three dates
					* and mark the ticks
					replace `d'1_`s'_tick = 1 if `d'13_`s'_ooo == 1
					replace `d'2_`s'_tick = 1 if `d'13_`s'_ooo == 1 & !missing(`d'2_`s'_date)
					replace `d'3_`s'_tick = 1 if `d'13_`s'_ooo == 1
					replace `d'1_`s'_date = . if `d'13_`s'_ooo == 1
					replace `d'2_`s'_date = . if `d'13_`s'_ooo == 1 
					replace `d'3_`s'_date = . if `d'13_`s'_ooo == 1

					drop `d'*_`s'_ooo
				}
			
			
				* For multiple doses, check to see if later dose received, but earlier dose missing
				foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
					gen `d'2_no_`d'1_`s'= 1 if (!missing(`d'2_`s'_date) | `d'2_`s'_tick ==1) & (missing(`d'1_`s'_date) & `d'1_`s'_tick!=1)
					
					* Set tick to yes if earlier dose missing and later dose received
					replace `d'1_`s'_tick=1 if `d'2_no_`d'1_`s'==1
					
					* Post comment out to the log
					count if `d'2_no_`d'1_`s' == 1
						if r(N) > 0 vcqi_log_comment $VCP 4 Data ///
						"The `s' date for `d'2 was received but `d'1 was not in `=scalar(r(N))' instances. `=upper("`d'")'1 tick set to yes."
				}
				
				foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
					gen `d'2_no_`d'1_`s'=1 if (!missing(`d'2_`s'_date) | `d'2_`s'_tick ==1) & (missing(`d'1_`s'_date) & `d'1_`s'_tick!=1)
					gen `d'3_no_`d'1_`s'=1 if (!missing(`d'3_`s'_date) | `d'3_`s'_tick ==1) & (missing(`d'1_`s'_date) & `d'1_`s'_tick!=1) & `d'2_no_`d'1_`s'!=1
					gen `d'3_no_`d'2_`s'=1 if (!missing(`d'3_`s'_date) | `d'3_`s'_tick ==1) & (missing(`d'2_`s'_date) & `d'2_`s'_tick!=1)
					
					* Set tick for earlier dose if missing, but later dose received
					replace `d'1_`s'_tick=1 if `d'2_no_`d'1_`s'==1
					replace `d'1_`s'_tick=1 if `d'3_no_`d'1_`s'==1
					replace `d'2_`s'_tick=1 if `d'3_no_`d'2_`s'==1
					
					* Post comments out to the log
					count if `d'2_no_`d'1_`s' == 1
						if r(N) > 0 vcqi_log_comment $VCP 4 Data ///
						"The `s' date for dose `d'2 was received but `d'1 was not in `=scalar(r(N))' instances. `=upper("`d'")'1 tick set to yes."

					count if `d'3_no_`d'1_`s' == 1
						if r(N) > 0 vcqi_log_comment $VCP 4 Data ///
						"The `s' date for dose `d'3 was received but `d'1 was not in `=scalar(r(N))' instances. `=upper("`d'")'1 tick set to yes."

					count if `d'3_no_`d'2_`s' == 1
						if r(N) > 0 vcqi_log_comment $VCP 4 Data ///
						"The `s' date for dose `d'3 was received but `d'2 was not in `=scalar(r(N))' instances. `=upper("`d'")'2 tick set to yes."
					
					drop `d'*_no_*
				}
			}
			
			* create flags to indicate no card or no register
			
			gen no_card = 1
			gen no_register = 1
			label variable no_card     "No Card with Dates in Dataset"
			label variable no_register "No Register Record with Dates in Dataset"
			
			foreach d in $RI_DOSE_LIST {
				foreach s in card `register' {
					replace no_`s' = 0 if !missing(`d'_`s'_date) | !missing(`d'_`s'_tick)
				}
			}
			
			count if no_card == 1
			vcqi_log_comment $VCP 4 Data ///
			"`=scalar(r(N))' respondents did not have a card record in the dataset with dates or ticks recorded on it."
			
			count if no_register == 1
			vcqi_log_comment $VCP 4 Data ///
			"`=scalar(r(N))' respondents did not have a register record with dates or ticks recorded on it."
			

			* save a file with flags
			save "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}_dq_flags", replace
			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS ${VCQI_RI_DATASET}_dq_flags
			
			keep RI01 RI03 RI11 RI12 *card_date *card_tick no_card ///
				no_register *register_date *register_tick ///
				dob_for_valid_dose_calculations age_at_interview *history
				
			drop dob_history

			* save a file with the cleaned up and renamed date, tick, history, and 
			* dob variables
			aorder
			save "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}_dqd", replace
			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS ${VCQI_RI_DATASET}_dqd
			
			* merge the new clean variables on to the RI survey dataset
			use "${VCQI_DATA_FOLDER}/${VCQI_RI_DATASET}", clear
			merge 1:1 RI01 RI03 RI11 RI12 using "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}_dqd"
			keep if _merge == 1 | _merge == 3
			drop _merge
			
			save "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}_clean", replace
			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS ${VCQI_RI_DATASET}_clean
			
			
			* Check to see if the DOB is missing for all records in the dataset.
			* If so...set a global so we can later gracefully skip over indicators
			* that require a DOB.
			
			count if !missing(dob_for_valid_dose_calculations)
			
			if r(N) == 0 {

				vcqi_log_comment $VCP 2 Warning "None of the records in the dataset have a full date of birth, so VCQI will not be able to calculate some RI indicators."
				vcqi_global VCQI_NO_DOBS 1

			}	
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
