*! SIA_COVG_02_05TO version 1.02 - Biostat Global Consulting - 2016-03-10
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-10	1.02	Dale Rhoda		Moved title & footnotes to control pgm
*******************************************************************************

program define SIA_COVG_02_05TO

	local oldvcp $VCP
	global VCP SIA_COVG_02_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"

	make_tables_from_svyp_output, measureid(SIA_COVG_02) vid(a) sheet(SIA_COVG_02 ${ANALYSIS_COUNTER}) var(estimate ci stderr lcb ucb deff icc n nwtd) estlabel(SIA Provided Childs First Measles Dose (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
