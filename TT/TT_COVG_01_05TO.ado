*! TT_COVG_01_05TO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define TT_COVG_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP TT_COVG_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
		make_tables_from_svyp_output, measureid(TT_COVG_01) var(estimate ci) sheet(TT_COVG_01 ${ANALYSIS_COUNTER}) vid(c)  estlabel(Protected at birth, by card (%))
		make_tables_from_svyp_output, measureid(TT_COVG_01) var(estimate ci) sheet(TT_COVG_01 ${ANALYSIS_COUNTER}) vid(h)  estlabel(Protected at birth, by history (%))
		make_tables_from_svyp_output, measureid(TT_COVG_01) var(estimate ci) sheet(TT_COVG_01 ${ANALYSIS_COUNTER}) vid(ch) estlabel(Protected at birth, by card or history (%))
		if $TT_RECORDS_SOUGHT_FOR_ALL == 1 | $TT_RECORDS_SOUGHT_IF_NO_CARD == 1 {
			make_tables_from_svyp_output, measureid(TT_COVG_01) var(estimate ci) sheet(TT_COVG_01 ${ANALYSIS_COUNTER}) vid(r)   estlabel(Protected at birth, by register (%))
			make_tables_from_svyp_output, measureid(TT_COVG_01) var(estimate ci) sheet(TT_COVG_01 ${ANALYSIS_COUNTER}) vid(chr) estlabel(Protected at birth, by card or history or register (%))
		}
		make_tables_from_svyp_output, measureid(TT_COVG_01) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(TT_COVG_01 ${ANALYSIS_COUNTER}) vid(a)   estlabel(Protected at birth (%)) 
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
