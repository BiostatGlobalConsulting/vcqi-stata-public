*! SIA_COVG_03_05TO version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-02-26	1.02	Dale Rhoda		Modified 2nd footnote
* 2016-03-10	1.03	Dale Rhoda		Moved title & footnotes to control pgm
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define SIA_COVG_03_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_03_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {

		noi di _continue _col(3) "All ages "
		make_tables_from_svyp_output, measureid(SIA_COVG_03) vid(all0d) sheet(SIA_COVG_03 ${ANALYSIS_COUNTER}) var(estimate)   estlabel(All ages: 0 doses (%))
		make_tables_from_svyp_output, measureid(SIA_COVG_03) vid(all1d) sheet(SIA_COVG_03 ${ANALYSIS_COUNTER}) var(estimate)   estlabel(All ages: 1 doses (%))
		make_tables_from_svyp_output, measureid(SIA_COVG_03) vid(all2d) sheet(SIA_COVG_03 ${ANALYSIS_COUNTER}) var(estimate n) estlabel(All ages: 2+ doses (%))
	
		local d0 0
		local d1 1
		local d2 2+
		
		local vlist0 estimate
		local vlist1 estimate
		local vlist2 estimate n
		
		local k 1
		forvalues i = $MIN_SIA_YEARS/$MAX_SIA_YEARS {
			noi di _continue _col(3) "`i' "
			forvalues j = 0/2 {
				make_tables_from_svyp_output, measureid(SIA_COVG_03) vid(`k') sheet(SIA_COVG_03 ${ANALYSIS_COUNTER}) var(`vlist`j'') estlabel(Age: `i' - `d`j'' doses (%))
				local ++k
			}
		}
		noi di as text ""
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
