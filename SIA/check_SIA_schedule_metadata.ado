*! check_SIA_schedule_metadata version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-03-10	1.01	Dale Rhoda		Added exitflag
* 2016-04-26	1.02	Dale Rhoda		Removed checks
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define check_SIA_schedule_metadata
	version 14.1
	
	local oldvcp $VCP
	global VCP check_SIA_schedule_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
		
	local exitflag 0
	
	if "`exitflag'" == "1" {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
