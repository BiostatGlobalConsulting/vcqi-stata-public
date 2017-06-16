*! SIA_COVG_03_05TO version 1.03 - Biostat Global Consulting - 2016-03-10
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-02-26	1.02	Dale Rhoda		Modified 2nd footnote
* 2016-03-10	1.03	Dale Rhoda		Moved title & footnotes to control pgm
*******************************************************************************

program define SIA_COVG_03_05TO

	local oldvcp $VCP
	global VCP SIA_COVG_03_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
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
		noi di ""
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
