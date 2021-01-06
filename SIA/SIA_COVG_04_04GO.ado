*! SIA_COVG_04_04GO version 1.00 - Biostat Global Consulting - 2019-01-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2019-01-01	1.00	Dale Rhoda		Original version
*******************************************************************************

program define SIA_COVG_04_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_04_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {	
		make_svyp_output_database, measureid(SIA_COVG_04) vid(b) var(got_sia_dose) estlabel(Vaccinated during SIA (%))
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

