*! RI_ACC_01_05TO version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Moved titles & footnotes to control pgm
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_ACC_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_ACC_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"

	local dl `=lower("$RI_ACC_01_DOSE_NAME")'
	local du `=upper("`dl'")'
	
	make_tables_from_svyp_output, measureid(RI_ACC_01) vid(`dl') sheet(RI_ACC_01 ${ANALYSIS_COUNTER}) var(estimate ci stderr lcb ucb deff icc n nwtd) estlabel(Received `du' - Crude (%))
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
