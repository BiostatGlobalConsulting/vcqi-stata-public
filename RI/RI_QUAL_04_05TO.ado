*! RI_QUAL_04_05TO version 1.02 - Biostat Global Consulting 2016-03-08
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
*******************************************************************************

program define RI_QUAL_04_05TO

	local oldvcp $VCP
	global VCP RI_QUAL_04_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		local d `=lower("$RI_QUAL_04_DOSE_NAME")'
		local t `=int($RI_QUAL_04_AGE_THRESHOLD)'
		
		make_tables_from_unwtd_output, measureid(RI_QUAL_04) noomitpriorn vid(`d'_`t') var(early_`d'_`t') sheet(RI_QUAL_04 ${ANALYSIS_COUNTER}) estlabel(Received `=upper("`d'")' Before Age `t' Days (%))
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
