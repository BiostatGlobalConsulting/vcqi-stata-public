*! SIA_COVG_01_05TO version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
*
* 2016-02-24	1.02	Dale Rhoda		No need to make table for vid(a) twice
* 2016-03-10	1.03	Dale Rhoda		Moved title & footnotes to control pgm
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define SIA_COVG_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
		make_tables_from_svyp_output, measureid(SIA_COVG_01) vid(c) sheet(SIA_COVG_01 ${ANALYSIS_COUNTER}) var(estimate ci  ) estlabel(Vaccinated during SIA, by card (%))
		make_tables_from_svyp_output, measureid(SIA_COVG_01) vid(h) sheet(SIA_COVG_01 ${ANALYSIS_COUNTER}) var(estimate ci  ) estlabel(Vaccinated during SIA, by history (%))
		if "$SIA_FINGERMARKS_SOUGHT" == "1" ///                    
		make_tables_from_svyp_output, measureid(SIA_COVG_01) vid(f) sheet(SIA_COVG_01 ${ANALYSIS_COUNTER}) var(estimate ci  ) estlabel(Vaccinated during SIA, by fingermark (%))

		make_tables_from_svyp_output, measureid(SIA_COVG_01) vid(a) sheet(SIA_COVG_01 ${ANALYSIS_COUNTER}) var(estimate ci stderr lcb ucb deff icc n nwtd) estlabel(Vaccinated during SIA (%))
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
