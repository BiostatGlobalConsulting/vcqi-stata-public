*! RI_QUAL_05_05TO version 1.05 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-02-29	1.02	Dale Rhoda		Added FOOTNOTE_2
* 2016-03-08	1.03	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-05-19	1.04	Dale Rhoda		Add threshold to database filename
* 2017-08-26	1.05	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_05_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_05_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"

	local d `=lower("$RI_QUAL_05_DOSE_NAME")' 
	local t `=int($RI_QUAL_05_INTERVAL_THRESHOLD)'
	
	make_tables_from_unwtd_output, measureid(RI_QUAL_05) vid(`d'_`t') var(short_interval_`d'_`t') sheet(RI_QUAL_05 ${ANALYSIS_COUNTER}) estlabel(`=upper("`d'")' Interval < `t' Days (%))
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
