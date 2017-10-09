*! check_TT_schedule_metadata version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************
* I am tempted to put the protected at birth parameters in a set of 
* scalars or global variables so it would be straightforward to calculate
* PAB using different definitions
*
* Leave this flexibility for next year, but this is a placeholder 
* reminder
*
program define check_TT_schedule_metadata
	version 14.1
	
	local oldvcp $VCP
	global VCP check_TT_schedule_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
