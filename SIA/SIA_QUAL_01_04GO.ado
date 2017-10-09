*! SIA_QUAL_01_04GO version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define SIA_QUAL_01_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_QUAL_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_unwtd_output_database, measureid(SIA_QUAL_01) vid(s) var(campaign_card_seen) estlabel(Vaccinated Respondent Received SIA Card - Seen)
	make_unwtd_output_database, measureid(SIA_QUAL_01) vid(u) var(campaign_card_unseen) estlabel(Vaccinated Respondent Received SIA Card - Unseen)
	make_unwtd_output_database, measureid(SIA_QUAL_01) vid(a) var(got_campaign_card) estlabel(Vaccinated Respondent Received SIA Card)

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

