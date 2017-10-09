*! cleanup_TT_dates_and_ticks version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

* This program is much simpler than its RI counterpart.
*
* It is so simple that it is probably mis-named - it doesn't really 
* clean the dates so much as it constructs got it variables for the TT doses.
*
* VCQI currently doesn't use the TT dates for anything other than a
* yes/no response...is a dose recorded or not.  The only important 
* thing is whether the card or register indicates that the woman 
* received a dose.  The code checks to see if any element of the TT 
* dates are non-missing; if so, then it sets a got_TT variable.
*
* If the _m and _d and _y are populated and combine to make an
* intelligible calendar date, this program runs the MDY() 
* function to assign a date but it does not do any checking on the 
* plausibility of the date.  So it could be before the woman's 
* birthdate, after the survey, or anything in between.
*
* In fact this program does not use the birthdate at all.
*
* If the logic of the TT indicators ever switches to actually use the dates
* for date calculations then the logic here will need to be enhanced,
* possibly to adopt some of the logic from the corresponding RI program to 
* evaluate whether the dates are plausible, etc.
*
* That said, this program does the following:
*
* - It merges the TT and TTHC datasets (if TTHC records were sought)
*
* - If TTHC records were not sought, it puts empty register variables in 
*   the dataset.
*
* populates got_TT* variables and TTx_card_date and TTx_register_date variables.
*
* The dataset that comes from this program will need unique IDs and then it 
* should have everything needed to calculate the TT analyses.
*   

program define cleanup_TT_dates_and_ticks
	version 14.1
	
	local oldvcp $VCP
	global VCP cleanup_TT_dates_and_ticks
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	use "${VCQI_DATA_FOLDER}/${VCQI_TT_DATASET}", clear
		
	* construct flags to indicate if there are non-missing elements
	* in the dates of the TT doses on the card
	
	* run the mdy function to construct dates out of any that have
	* all three components
		
	forvalues i = 30/35 {
		local j = `i' - 29
		gen got_TT`j'_card = 0
		label variable got_TT`j'_card "Card indicates that respondent received TT`j'"
		replace got_TT`j'_card = 1 if !missing(TT`i'_m)
		replace got_TT`j'_card = 1 if !missing(TT`i'_d)
		replace got_TT`j'_card = 1 if !missing(TT`i'_y)
		
		gen TT`j'_card_date = mdy(TT`i'_m, TT`i'_d, TT`i'_y)
		label variable got_TT`j'_card_date "Date of TT`j' vaccination - card"
			
		order got_TT`j'_card TT`j'_card_date, before(TT`i'm)
	}

	if ${TT_RECORDS_SOUGHT_FOR_ALL} == 1 | ${TT_RECORDS_SOUGHT_IF_NO_CARD} == 1 {
	
		local register register
	
		gen TTHC01 = TT01
		gen TTHC03 = TT03
		gen TTHC14 = TT11
		gen TTHC15 = TT12
		
		merge 1:1 TTHC01 TTHC03 TTHC14 TTHC15 using ///
			"${VCQI_DATA_FOLDER}/${VCQI_TTHC_DATASET}", ///
			keepusing(TTHC21* TTHC22* TTHC23* TTHC24* TTHC25* TTHC26*)
			
		* Note that we are not currently using the mother's date of birth,
		* so do not clutter up the dataset with it, but if we want it later
		* then add it to the keepusing list above (TTHC19 and TTHC20)
		
		* construct flags to indicate if there are non-missing elements
		* in the dates of the TT doses on the register
		
		* run the mdy function to construct dates out of any that have
		* all three components
			
		forvalues i = 21/26 {
			local j = `i' - 20
			gen got_TT`j'_register = 0
			label variable got_TTHC`j'_card "Register indicates that respondent received TT`j'"
			replace got_TT`j'_register = 1 if !missing(TTHC`i'_m)
			replace got_TT`j'_register = 1 if !missing(TTHC`i'_d)
			replace got_TT`j'_register = 1 if !missing(TTHC`i'_y)

			gen TT`j'_register_date = mdy(TTHC`i'_m, TTHC`i'_d, TTHC`i'_y)
			label variable got_TT`j'_register_date "Date of TT`j' vaccination - register"
			
			order got_TT`j'_register TT`j'_register_date, before(TTHC`i'm)
		}
		
		keep if _merge == 1 | _merge == 3 
		drop _merge
		
	}
	
	if ${TT_RECORDS_NOT_SOUGHT} == 1 {
			
		foreach d in TT1 TT2 TT3 TT4 TT5 TT6 {
			gen got_`d'_register  = .
			gen `d'_register_date = .
		}
		gen dob_date_register_m = .
		gen dob_date_register_d = .
		gen dob_date_register_y = .	
		gen dob_register_date = .
	
	}
	
	save "${VCQI_DATA_FOLDER}/${VCQI_TT_DATASET}_clean", replace
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
