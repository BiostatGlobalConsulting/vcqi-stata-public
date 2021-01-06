*! RI_QUAL_07B_05TO version 1.02 - Biostat Global Consulting - 2020-09-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-03-10	1.00	Mary Prier		Original version
* 2020-03-24	1.01	Dale Rhoda		Temporarily also output the % w valid cvg
* 2020-09-13	1.02	Dale Rhoda		Switch to MOV_OUTPUT_DOSE_LIST
*******************************************************************************

program define RI_QUAL_07B_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07B_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
				
		foreach d in $MOV_OUTPUT_DOSE_LIST {
			noi di _continue _col(5) "`d' "
			*make_tables_from_svyp_output, measureid(RI_QUAL_07B) vid(`d') sheet(RI_QUAL_07B_full) var(estimate ci stderr lcb ucb deff icc n nwtd) estlabel(Would have valid `=upper("`d'")' if no MOVs (%))
			make_tables_from_svyp_output, measureid(RI_COVG_02)  vid(`d'_a) sheet(RI_QUAL_07B ${ANALYSIS_COUNTER}) var(estimate) estlabel(Had valid `=upper("`d'")' (%))
			make_tables_from_svyp_output, measureid(RI_QUAL_07B) vid(`d') sheet(RI_QUAL_07B ${ANALYSIS_COUNTER}) var(estimate ci) estlabel(Would have valid `=upper("`d'")' if no MOVs (%))
		}
		noi di as text ""
		
		* add N at the far right of the table
		*make_tables_from_svyp_output, measureid(RI_QUAL_07B) vid(`=word("$MOV_OUTPUT_DOSE_LIST",1)') sheet(RI_QUAL_07B ${ANALYSIS_COUNTER}) var(n nwtd) estlabel(" ")
		make_tables_from_svyp_output, measureid(RI_QUAL_07B) vid(`=word("$RI_DOSE_LIST",1)') sheet(RI_QUAL_07B ${ANALYSIS_COUNTER}) var(n nwtd) estlabel(" ")
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
