*! RI_QUAL_01_05TO version 1.05 - Biostat Global Consulting - 2018-10-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2018-08-15	1.04	MK Trimner		Added code to accomodate the new card and 
*										register variables
* 2018-10-24	1.05	Dale Rhoda		Always report had_card_or_register
*******************************************************************************

program define RI_QUAL_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	* Create local with document source type
	local source card
	if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 ///
		local source `source' register
			
	foreach s in `source' {
		make_tables_from_svyp_output,  measureid(RI_QUAL_01) vid(`s')             sheet(RI_QUAL_01 ${ANALYSIS_COUNTER}) var(estimate ci) estlabel(RI `=proper("`s'")' Availability (%))
		make_tables_from_svyp_output,  measureid(RI_QUAL_01) vid(`s'_dates)       sheet(RI_QUAL_01 ${ANALYSIS_COUNTER}) var(estimate ci) estlabel(RI `=proper("`s'")' with Dates (%))
		make_tables_from_svyp_output,  measureid(RI_QUAL_01) vid(`s'_dates_ticks) sheet(RI_QUAL_01 ${ANALYSIS_COUNTER}) var(estimate ci) estlabel(RI `=proper("`s'")' with Dates or Ticks (%))
		make_tables_from_svyp_output,  measureid(RI_QUAL_01) vid(`s'_dates_clean) sheet(RI_QUAL_01 ${ANALYSIS_COUNTER}) var(estimate ci) estlabel(RI `=proper("`s'")' with Only Clean Dates (%))
	}
	
	* Make table for card or register availabilty
	make_tables_from_svyp_output,  measureid(RI_QUAL_01) vid(card_or_register) sheet(RI_QUAL_01 ${ANALYSIS_COUNTER}) var(estimate ci stderr lcb ucb deff icc n nwtd) estlabel(RI Card or Register Availability (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
