*! RI_QUAL_07_00GC version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_07_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	vcqi_log_global RI_QUAL_07_VALID_OR_CRUDE
	vcqi_log_global RI_DOSE_LIST
	
	local exitflag 0
	
	*Confirm global RI_QUAL_07_VALID_OR_CRUDE is defined and has the appropriate values
	if !inlist("`=upper("$RI_QUAL_07_VALID_OR_CRUDE")'","VALID","CRUDE") {
		di as error "RI_QUAL_07_VALID_OR_CRUDE must be either VALID or CRUDE.  The current value is $RI_QUAL_07_VALID_OR_CRUDE."
		vcqi_log_comment $VCP 1 Error "RI_QUAL_07_VALID_OR_CRUDE must be either VALID or CRUDE.  The current value is $RI_QUAL_07_VALID_OR_CRUDE."
		local exitflag 1
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
