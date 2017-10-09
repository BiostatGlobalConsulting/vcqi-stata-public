*! RI_QUAL_07_05TO version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-01-18	1.02	Dale Rhoda		Fixed numbering of footnote 3
* 2016-03-08	1.03	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_07_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local vc  `=lower("$RI_QUAL_07_VALID_OR_CRUDE")'
		
		foreach d in $RI_DOSE_LIST {
			noi di _continue _col(5) "`d' "
			*make_tables_from_svyp_output, measureid(RI_QUAL_07) vid(`d') sheet(RI_QUAL_07_full) var(estimate ci stderr lcb ucb deff icc n nwtd) estlabel(Would have valid `=upper("`d'")' if no MOVs (%))
			make_tables_from_svyp_output, measureid(RI_QUAL_07) vid(`d'_`vc') sheet(RI_QUAL_07 ${ANALYSIS_COUNTER}) var(estimate ci ) estlabel(Would have valid `=upper("`d'")' if no MOVs (%))
		}
		noi di ""
		
		* add N at the far right of the table
		make_tables_from_svyp_output, measureid(RI_QUAL_07) vid(`=word("$RI_DOSE_LIST",1)'_`vc') sheet(RI_QUAL_07 ${ANALYSIS_COUNTER}) var(n nwtd) estlabel(" ")
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
