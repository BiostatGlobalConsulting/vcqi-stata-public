*! RI_COVG_03_02DQ version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_03_02DQ
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_03_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"


	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
