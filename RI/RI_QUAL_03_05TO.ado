*! RI_QUAL_03_05TO version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_03_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_03_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
		
	local d = lower("$RI_QUAL_03_DOSE_NAME")
	
	make_tables_from_unwtd_output, measureid(RI_QUAL_03) vid(`d') var(got_invalid_`d') sheet(RI_QUAL_03 ${ANALYSIS_COUNTER}) estlabel(Received Invalid `=upper("`d'")' (%))
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
