*! RI_QUAL_09_05TO version 1.04 - Biostat Global Consulting 2017-05-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-02-26	1.02	Dale Rhoda		moved footnote 4 to 7
* 2016-03-08	1.03	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-05-17	1.04	Dale Rhoda		Send progress to screen
*******************************************************************************

program define RI_QUAL_09_05TO

	local oldvcp $VCP
	global VCP RI_QUAL_09_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local vc  `=lower("$RI_QUAL_09_VALID_OR_CRUDE")'
		
		foreach d in $RI_DOSE_LIST {
		
			noi di _continue _col(5) "`d' "

			make_tables_from_RI_QUAL_09, measureid(RI_QUAL_09) sheet(RI_QUAL_09 ${ANALYSIS_COUNTER}) dose(`d') 

		}
		
		noi di _continue _col(5) "Totals..."

		make_tables_from_RI_QUAL_09, measureid(RI_QUAL_09) sheet(RI_QUAL_09 ${ANALYSIS_COUNTER}) dose(anydose) 
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
