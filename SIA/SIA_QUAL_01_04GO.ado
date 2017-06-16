*! SIA_QUAL_01_04GO version 1.00 - Biostat Global Consulting - 2015-10-12

program define SIA_QUAL_01_04GO

	local oldvcp $VCP
	global VCP SIA_QUAL_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_unwtd_output_database, measureid(SIA_QUAL_01) vid(s) var(campaign_card_seen) estlabel(Vaccinated Respondent Received SIA Card - Seen)
	make_unwtd_output_database, measureid(SIA_QUAL_01) vid(u) var(campaign_card_unseen) estlabel(Vaccinated Respondent Received SIA Card - Unseen)
	make_unwtd_output_database, measureid(SIA_QUAL_01) vid(a) var(got_campaign_card) estlabel(Vaccinated Respondent Received SIA Card)

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

