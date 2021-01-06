*! RI_QUAL_01_03DV version 1.06 - Biostat Global Consulting - 2019-08-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2018-08-01	1.02	MK Trimner		Added code to create 4 new card variables
*										that will be used to identify if they had a card
*										and how useful it was. 
*										1. Indicated had card
*										2. Has card with dates - just renamed org var
*										3. Has card with dates or ticks
*										4. Has card with only dates - no ticks
*										Also created variable to show tick count
* 2018-08-15	1.03	MK Trimner		Created the same variables above for Register
*										And variable to show if Card or Register seen
* 2018-08-30	1.03	MK Trimner		correcting has_<card/register> variables to reflect 
*										if have data or say it was seen. 
* 2018-10-04	1.04	MK Trimner		changed "has" to "had"
* 2018-10-24	1.05	Dale Rhoda		Always calculate had_card_or_register
* 2019-08-23	1.06	Dale Rhoda		Make outcomes missing if psweight == 0
*******************************************************************************

program define RI_QUAL_01_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_01_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}", clear
		
		local source card
		if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 ///
			local source `source' register
			
		foreach s in `source' {

			gen `s'_date_count = 0 if psweight > 0 & !missing(psweight)
			label variable `s'_date_count "Number of Dates on `=proper("`s'")'"
			
			gen `s'_tick_count = 0 if psweight > 0 & !missing(psweight)
			label variable `s'_tick_count "Number of Tick Marks on `=proper("`s'")'"

			foreach d in $RI_DOSE_LIST {
				replace `s'_date_count= `s'_date_count + 1 if !missing(`d'_`s'_date)
				replace `s'_tick_count= `s'_tick_count + 1 if `d'_`s'_tick == 1
			}
		}
		
		* Create variable to show if Interviewer indicated a card was seen
		gen had_card = RI27 == 1 | card_date_count > 0 | card_tick_count > 0
		label variable had_card "Card Seen by Interviewer"
		
		* Create variable to show if card had dates
		gen had_card_with_dates = card_date_count > 0	
		label variable had_card_with_dates "Card Seen - Dates listed on Card"
		
		* Create variable to show if card had dates or ticks
		gen had_card_with_dates_or_ticks = card_date_count > 0 | card_tick_count > 0
		label variable had_card_with_dates_or_ticks "Card Seen - Dates or Tick Marks listed on Card"

		* Create variable to show if card had clean dates only
		gen had_card_with_flawless_dates = card_date_count > 0 & card_tick_count == 0
		label variable had_card_with_flawless_dates "Card Seen - Only Clean Dates, No Tick Marks" 
		
		replace had_card 					 = . if psweight == 0 | missing(psweight)
		replace had_card_with_dates 		 = . if psweight == 0 | missing(psweight)
		replace had_card_with_dates_or_ticks = . if psweight == 0 | missing(psweight)
		replace had_card_with_flawless_dates = . if psweight == 0 | missing(psweight)
		
		if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 {

			* Create variable to show if Interviewer indicated a register was seen
			gen had_register = register_date_count > 0 | register_tick_count > 0
			label variable had_register "Register Seen by Interviewer"
			
			* Create variable to show if register had dates
			gen had_register_with_dates = register_date_count > 0	
			label variable had_register_with_dates "Register Seen - Dates listed on register"
			
			* Create variable to show if register had dates or ticks
			gen had_register_with_dates_or_ticks = register_date_count > 0 | register_tick_count > 0
			label variable had_register_with_dates_or_ticks "Register Seen - Dates or Tick Marks listed on register"

			* Create variable to show if register had clean dates only
			gen had_register_with_flawless_dates = register_date_count > 0 & register_tick_count == 0
			label variable had_register_with_flawless_dates "Register Seen - Only clean Dates, No Tick Marks" 
			
			replace had_register 					 = . if psweight == 0 | missing(psweight)
			replace had_register_with_dates 		 = . if psweight == 0 | missing(psweight)
			replace had_register_with_dates_or_ticks = . if psweight == 0 | missing(psweight)
			replace had_register_with_flawless_dates = . if psweight == 0 | missing(psweight)			
		}
		
		* Create variable to show if card or register was seen
		gen had_card_or_register = 0 
		capture replace had_card_or_register = 1 if had_card == 1
		capture replace had_card_or_register = 1 if had_register == 1
		label var had_card_or_register "Card or Register seen by Interviewer"
		
		replace had_card_or_register = . if psweight == 0 | missing(psweight)
		
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

