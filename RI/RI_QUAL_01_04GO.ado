*! RI_QUAL_01_04GO version 1.05 - Biostat Global Consulting - 2018-10-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-05-17	1.01	Dale Rhoda		Also generate an unweighted table
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2018-08-08	1.03	MK Trimner		Added code to summarize the new variables 
*										that show the different type of cards
* 2018-10-04	1.04	MK Trimner		Changed "has" to "had"\
* 2018-10-24	1.05	Dale Rhoda		Always report had_card_or_register
*******************************************************************************

program define RI_QUAL_01_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local source card
	if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 ///
		local source `source' register
	
	foreach s in `source' {
		* This indicator tabulates weighted results...make that database
		make_svyp_output_database,  measureid(RI_QUAL_01) vid(`s')             var(had_`s')                     estlabel(RI `=proper("`s'")' Availability (%))
		make_svyp_output_database,  measureid(RI_QUAL_01) vid(`s'_dates)       var(had_`s'_with_dates)          estlabel(RI `=proper("`s'")' with Dates (%))
		make_svyp_output_database,  measureid(RI_QUAL_01) vid(`s'_dates_ticks) var(had_`s'_with_dates_or_ticks) estlabel(RI `=proper("`s'")' with Dates or Ticks (%))
		make_svyp_output_database,  measureid(RI_QUAL_01) vid(`s'_dates_clean) var(had_`s'_with_flawless_dates) estlabel(RI `=proper("`s'")' with Only Clean Dates (%))
	}

	make_svyp_output_database,  measureid(RI_QUAL_01) vid(card_or_register) var(had_card_or_register) estlabel(RI Card or Register Availability (%))
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

