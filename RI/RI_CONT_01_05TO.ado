*! RI_CONT_01_05TO version 1.04 - Biostat Global Consulting - 2018-01-16
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2018-01-16	1.04	Dale Rhoda		Remove noomitpriorn and update var option
*******************************************************************************

program define RI_CONT_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CONT_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
		local j 1
		while `j' <= `=wordcount("$RI_CONT_01_DROPOUT_LIST")' {
			local d1 `=word(lower("$RI_CONT_01_DROPOUT_LIST"),`j')'
			local ++j
			local d2 `=word(lower("$RI_CONT_01_DROPOUT_LIST"),`j')'
			local ++j
			noi di _continue _col(5) "`d1' to `d2' "

			make_tables_from_unwtd_output, measureid(RI_CONT_01) sheet(RI_CONT_01 ${ANALYSIS_COUNTER}) vid(`d1'_`d2') var(estimate n) estlabel(`=upper("`d1'")'-`=upper("`d2'")' Dropout (%))

		}
		noi di as text ""
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
