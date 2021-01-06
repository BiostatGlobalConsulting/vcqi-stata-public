*! RI_QUAL_12_05TO version 1.05 - Biostat Global Consulting - 2018-01-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-02-03	1.03	Dale Rhoda		Switched to _DOSE_PAIR_LIST
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2018-01-17	1.05	Dale Rhoda		Updated var option
*****************************************************************************

program define RI_QUAL_12_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_12_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local j 1
		local i 1
		while `i' <= `=wordcount("$RI_QUAL_12_THRESHOLD_LIST")' {
			local t `=word("$RI_QUAL_12_THRESHOLD_LIST",`i')'
			local d1 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
			local ++j
			local d2 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
			local ++j
			noi di _continue _col(5) "`d1' & `d2' "

			make_tables_from_unwtd_output, measureid(RI_QUAL_12) sheet(RI_QUAL_12 ${ANALYSIS_COUNTER}) vid(`d1'_`d2'_`t') var(estimate n) estlabel(`=upper("`d1'")'-`=upper("`d2'")' Interval > `t' Days (%))

			local ++i
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
