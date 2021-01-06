*! SIA_COVG_02_04GO version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define SIA_COVG_02_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_02_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_svyp_output_database, measureid(SIA_COVG_02) vid(a) var(sia_is_first_measles_dose) estlabel(SIA Provided Childs First Measles Dose (%))

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

