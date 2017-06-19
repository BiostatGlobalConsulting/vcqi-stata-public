*! SIA_COVG_02_04GO version 1.00 - Biostat Global Consulting - 2015-10-12
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define SIA_COVG_02_04GO

	local oldvcp $VCP
	global VCP SIA_COVG_02_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	make_svyp_output_database, measureid(SIA_COVG_02) vid(a) var(sia_is_first_measles_dose) estlabel(SIA Provided Childs First Measles Dose)

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

