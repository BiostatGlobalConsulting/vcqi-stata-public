*! RI_CONT_01_05TO version 1.02 - Biostat Global Consulting 2016-03-08
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
*******************************************************************************

program define RI_CONT_01_05TO

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

			make_tables_from_unwtd_output, measureid(RI_CONT_01) sheet(RI_CONT_01 ${ANALYSIS_COUNTER}) noomitpriorn vid(`d1'_`d2') var(dropout_`d1'_`d2') estlabel(`=upper("`d1'")'-`=upper("`d2'")' Dropout (%))

		}
		noi di ""
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
