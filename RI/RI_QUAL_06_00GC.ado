*! RI_QUAL_06_00GC version 1.01 - Biostat Global Consulting 2017-02-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-01	1.01	Dale Rhoda		Edit comments
*******************************************************************************

program define RI_QUAL_06_00GC

	local oldvcp $VCP
	global VCP RI_QUAL_06_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	vcqi_log_global RI_QUAL_06_DOSE_NAME
	vcqi_log_global RI_DOSE_LIST
	
	local exitflag 0
	
	*Confirm global RI_QUAL_06_DOSE_NAME is defined
	if "$RI_QUAL_06_DOSE_NAME"=="" {
		di as error "You must define global variable RI_QUAL_06_DOSE_NAME."
		vcqi_log_comment $VCP 1 Error "You must define global variable RI_QUAL_06_DOSE_NAME."
		local exitflag 1
	}
		
	*Confirm only 1 dose name is provided for this measurement
	if `=wordcount("$RI_QUAL_06_DOSE_NAME")' != 1 {
		di as error "Please specify the name of a single dose RI_QUAL_06_DOSE_NAME (e.g., MCV1)"
		vcqi_log_comment $VCP 1 Error "Please specify the name of a single dose RI_QUAL_06_DOSE_NAME (e.g., MCV1)"
		local exitflag 1
	}	
	
	*Confirm dose name in global RI_QUAL_06_DOSE_NAME is part of the RI_DOSE_LIST global
	local match 0
	foreach d in `=lower("$RI_DOSE_LIST")' {
		if "`d'" == "`=lower("$RI_QUAL_06_DOSE_NAME")'" local match `=`match' + 1' 
	}
	if `match'!= 1 {
		di as error "Dose name for global variable RI_QUAL_06_DOSE_NAME is not included in the RI_DOSE_LIST provided."
		vcqi_log_comment $VCP 1 Error  "Dose name for global variable RI_QUAL_06_DOSE_NAME is not included in the RI_DOSE_LIST provided."
		local exitflag 1
	}
	
	* Note that the threshold for RI_COVG_06 is always 12 months, so there is no
	* need to do any logic check on the threshold

	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end


