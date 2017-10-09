*! SIA_QUAL_01_05TO version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-10	1.02	Dale Rhoda		Moved title & footnotes to control pgm
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define SIA_QUAL_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_QUAL_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_tables_from_unwtd_output, measureid(SIA_QUAL_01) vid(s) var(campaign_card_seen)   estlabel(Vaccinated Respondent Received SIA Card - Seen (%)) 	sheet(SIA_QUAL_01 ${ANALYSIS_COUNTER})
	make_tables_from_unwtd_output, measureid(SIA_QUAL_01) vid(u) var(campaign_card_unseen) estlabel(Vaccinated Respondent Received SIA Card - Unseen (%)) 	sheet(SIA_QUAL_01 ${ANALYSIS_COUNTER})
	make_tables_from_unwtd_output, measureid(SIA_QUAL_01) vid(a) var(got_campaign_card)    estlabel(Vaccinated Respondent Received SIA Card(%)) 			sheet(SIA_QUAL_01 ${ANALYSIS_COUNTER})

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
