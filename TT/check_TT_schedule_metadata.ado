*! check_TT_schedule_metadata version 1.00 - Biostat Global Consulting - 2015-09-28
*
* I am tempted to put the protected at birth parameters in a set of 
* scalars or global variables so it would be straightforward to calculate
* PAB using different definitions
*
* Leave this flexibility for next year, but this is a placeholder 
* reminder
*
program define check_TT_schedule_metadata

	version 14
	local oldvcp $VCP
	global VCP check_TT_schedule_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
