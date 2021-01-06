*! RI_QUAL_04_05TO version 1.05 - Biostat Global Consulting - 2018-05-30
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2018-01-17	1.04	Dale Rhoda		Updated var option
* 2018-05-30	1.05	Dale Rhoda		Removed noomitpriorn option
*******************************************************************************

program define RI_QUAL_04_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_04_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		local d `=lower("$RI_QUAL_04_DOSE_NAME")'
		local t `=int($RI_QUAL_04_AGE_THRESHOLD)'
		
		make_tables_from_unwtd_output, measureid(RI_QUAL_04) vid(`d'_`t') var(estimate n) sheet(RI_QUAL_04 ${ANALYSIS_COUNTER}) estlabel(Received `=upper("`d'")' Before Age `t' Days (%))
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
