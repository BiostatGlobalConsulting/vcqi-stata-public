*! RI_COVG_03_05TO version 1.03 - Biostat Global Consulting - 2017-01-09
*
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Move titles & footnotes to control pgm
* 2017-01-09	1.03	Dale Rhoda		Skip valid dose calculations if none
*										of the respondents have complete DOB
*******************************************************************************

program define RI_COVG_03_05TO

	local oldvcp $VCP
	global VCP RI_COVG_03_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_tables_from_svyp_output, measureid(RI_COVG_03) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_03 ${ANALYSIS_COUNTER})  vid(fvc)  estlabel(Fully vaccinated - crude)
	if "$VCQI_NO_DOBS" != "1" make_tables_from_svyp_output, measureid(RI_COVG_03) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_03 ${ANALYSIS_COUNTER})  vid(fvv)  estlabel(Fully vaccinated - valid)
	if "$VCQI_NO_DOBS" != "1" make_tables_from_svyp_output, measureid(RI_COVG_03) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_03 ${ANALYSIS_COUNTER})  vid(fva1) estlabel(Fully vaccinated with valid doses by age 1)
		
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
