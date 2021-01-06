*! RI_COVG_02_05TO version 1.05 - Biostat Global Consulting - 2017-10-27
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Move titles & footnotes to control pgm
* 2016-11-17	1.03	Dale Rhoda		Only calculate by age 1 if dose is 
*										given before age 1
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2017-10-27	1.05	Dale Rhoda		Added _BRIEF sheet
*******************************************************************************

program define RI_COVG_02_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_02_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		foreach d in $RI_DOSE_LIST {
		
			noi di _continue _col(5) "`d' "
		
			local du `=upper("`d'")'
		
			* output for valid coverage
			
			make_tables_from_svyp_output,     measureid(RI_COVG_02) var(estimate ci )                        sheet(RI_COVG_02 ${ANALYSIS_COUNTER}) vid(`d'_c)  estlabel(`du' valid coverage, by card (%))

			if $RI_RECORDS_SOUGHT_FOR_ALL | $RI_RECORDS_SOUGHT_IF_NO_CARD {
				make_tables_from_svyp_output, measureid(RI_COVG_02) var(estimate ci )                        sheet(RI_COVG_02 ${ANALYSIS_COUNTER}) vid(`d'_r)  estlabel(`du' valid coverage, by register (%))

				make_tables_from_svyp_output, measureid(RI_COVG_02) var(estimate ci )                        sheet(RI_COVG_02 ${ANALYSIS_COUNTER}) vid(`d'_cr) estlabel(`du' valid coverage, by card or register (%))

			}
			make_tables_from_svyp_output, measureid(RI_COVG_02) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_02 ${ANALYSIS_COUNTER}) vid(`d'_a)  estlabel(`du' valid coverage (%))
			make_tables_from_svyp_output, measureid(RI_COVG_02) var(estimate ci) sheet(RI_COVG_02_BRIEF ${ANALYSIS_COUNTER}) vid(`d'_a)  estlabel(`du' valid coverage (%))
			
			* Valid coverage by age 1
			
			if `=scalar(`=lower("`d'")'_min_age_days)'  < 365 {
		
				make_tables_from_svyp_output,     measureid(RI_COVG_02) var(estimate ci )                        sheet(RI_COVG_02 ${ANALYSIS_COUNTER}) vid(`d'_ca1)  estlabel(`du' valid coverage by age 1, by card (%))

				if $RI_RECORDS_SOUGHT_FOR_ALL | $RI_RECORDS_SOUGHT_IF_NO_CARD {
					make_tables_from_svyp_output, measureid(RI_COVG_02) var(estimate ci )                        sheet(RI_COVG_02 ${ANALYSIS_COUNTER}) vid(`d'_ra1)  estlabel(`du' valid coverage by age 1, by register (%))

					make_tables_from_svyp_output, measureid(RI_COVG_02) var(estimate ci )                        sheet(RI_COVG_02 ${ANALYSIS_COUNTER}) vid(`d'_cra1) estlabel(`du' valid coverage by age 1, by card or register (%))

				}
				make_tables_from_svyp_output, measureid(RI_COVG_02) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_02 ${ANALYSIS_COUNTER}) vid(`d'_aa1)  estlabel(`du' valid coverage by age 1 (%))
				make_tables_from_svyp_output, measureid(RI_COVG_02) var(estimate ci) sheet(RI_COVG_02_BRIEF ${ANALYSIS_COUNTER}) vid(`d'_aa1)  estlabel(`du' valid coverage by age 1 (%))
			}
		}	
		noi di as text ""
	}	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
