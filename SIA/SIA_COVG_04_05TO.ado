*! SIA_COVG_04_05TO version 1.00 - Biostat Global Consulting - 2019-01-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2019-01-01	1.00	Dale Rhoda		Original Version
*******************************************************************************

program define SIA_COVG_04_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_04_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
		make_tables_from_svyp_output, measureid(SIA_COVG_04) vid(b) sheet(SIA_COVG_04 ${ANALYSIS_COUNTER}) var(estimate ci nwtd_est nwtd) estlabel(Vaccinated during SIA (%))
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
