*! RI_COVG_04_05TO version 1.05 - Biostat Global Consulting - 2017-10-27
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Move titles & footnotes to control pgm
* 2016-01-07	1.03	Dale Rhoda		Skip valid dose tables if no respondent
*										has DOB data
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2017-10-27	1.05	Dale Rhoda		Added _BRIEF sheet
*******************************************************************************

program define RI_COVG_04_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_04_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
		
	make_tables_from_svyp_output, measureid(RI_COVG_04) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_04 ${ANALYSIS_COUNTER}) vid(nvc)  estlabel(Not vaccinated - crude)
	make_tables_from_svyp_output, measureid(RI_COVG_04) var(estimate ci) sheet(RI_COVG_04_BRIEF ${ANALYSIS_COUNTER}) vid(nvc)  estlabel(Not vaccinated - crude)

	if "$VCQI_NO_DOBS" != "1" {
		make_tables_from_svyp_output, measureid(RI_COVG_04) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_04 ${ANALYSIS_COUNTER}) vid(nvv)  estlabel(Not vaccinated - valid)
		make_tables_from_svyp_output, measureid(RI_COVG_04) var(estimate ci) sheet(RI_COVG_04_BRIEF ${ANALYSIS_COUNTER}) vid(nvv)  estlabel(Not vaccinated - valid)

		make_tables_from_svyp_output, measureid(RI_COVG_04) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_04 ${ANALYSIS_COUNTER}) vid(nva1) estlabel(No valid doses by age 1)
		make_tables_from_svyp_output, measureid(RI_COVG_04) var(estimate ci) sheet(RI_COVG_04_BRIEF ${ANALYSIS_COUNTER}) vid(nva1) estlabel(No valid doses by age 1)
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
