*! RI_QUAL_01_04GO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-05-17	1.01	Dale Rhoda		Also generate an unweighted table
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_01_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	* This indicator tabulates weighted results...make that database
	make_svyp_output_database,  measureid(RI_QUAL_01) vid(ca) var(showed_card_with_dates) estlabel(RI Card Availability (%))
	
	* For other purposes some people may wish to have a record of the number
	* of cards seen with a date on it, so save those figures in an unweighted database
	make_unwtd_output_database, measureid(RI_QUAL_01) vid(ca_unwtd) var(showed_card_with_dates) estlabel(Showed a card with 1+ dates (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

