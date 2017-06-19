*! RI_QUAL_08_05TO version 1.02 - Biostat Global Consulting 2016-03-08
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
*******************************************************************************

program define RI_QUAL_08_05TO

	local oldvcp $VCP
	global VCP RI_QUAL_08_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local vc  `=lower("$RI_QUAL_08_VALID_OR_CRUDE")'
				
		foreach d in $RI_DOSE_LIST {
		
			noi di _continue _col(5) "`d' "

			make_tables_from_unwtd_output, measureid(RI_QUAL_08) sheet(RI_QUAL_08 ${ANALYSIS_COUNTER}) noomitpriorn vid(`d') var(Visits_with_MOV_`=upper("`d'")') estlabel(Visits with MOV for `=upper("`d'")' (%))

		}
		
		noi di _col(5) "Totals..."

		make_tables_from_unwtd_output, measureid(RI_QUAL_08) sheet(RI_QUAL_08 ${ANALYSIS_COUNTER}) noomitpriorn vid(any) var(Visits_with_MOV_any_dose) estlabel(Visits with MOV for any dose (%))

		* This last measure is not a percent...it is a ratio, so specify the ratio option to keep from scaling the estimate up by x100.
		make_tables_from_unwtd_output, measureid(RI_QUAL_08) sheet(RI_QUAL_08 ${ANALYSIS_COUNTER}) noomitpriorn vid(rate) var(MOVs_per_visit) ratio estlabel(MOVs per Visit)
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
