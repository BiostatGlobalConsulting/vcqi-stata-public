*! RI_QUAL_08_05TO version 1.04 - Biostat Global Consulting - 2019-11-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2019-11-09	1.04 	Dale Rhoda		Introduced MOV_OUTPUT_DOSE_LIST
*******************************************************************************

program define RI_QUAL_08_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_08_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local vc  `=lower("$RI_QUAL_08_VALID_OR_CRUDE")'
				
		foreach d in $MOV_OUTPUT_DOSE_LIST {
		
			noi di _continue _col(5) "`d' "

			make_tables_from_unwtd_output, measureid(RI_QUAL_08) sheet(RI_QUAL_08 ${ANALYSIS_COUNTER}) vid(`d') var(estimate n) estlabel(Visits with MOV for `=upper("`d'")' (%))

		}
		
		noi di as text _col(5) "Totals..."

		make_tables_from_unwtd_output, measureid(RI_QUAL_08) sheet(RI_QUAL_08 ${ANALYSIS_COUNTER}) vid(any) var(estimate n) estlabel(Visits with MOV for any dose (%))

		* This last measure is not a percent...it is a ratio, so specify the ratio option to keep from scaling the estimate up by x100.
		make_tables_from_unwtd_output, measureid(RI_QUAL_08) sheet(RI_QUAL_08 ${ANALYSIS_COUNTER}) vid(rate) var(estimate n) ratio estlabel(MOVs per Visit)
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
