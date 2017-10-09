*! RI_QUAL_03_00GC version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-09-21	1.01	Dale Rhoda		Exit if user specifies dose2 or 3 in 
*										a multi-dose list
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_03_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_03_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	vcqi_log_global RI_QUAL_03_DOSE_NAME
	vcqi_log_global RI_DOSE_LIST
	
	local exitflag 0
	
	*Confirm global RI_QUAL_03_DOSE_NAME is defined
	if "$RI_QUAL_03_DOSE_NAME"=="" {
		di as error "You must define global variable RI_QUAL_03_DOSE_NAME."
		vcqi_log_comment $VCP 1 Error "You must define global variable RI_QUAL_03_DOSE_NAME."
		local exitflag 1
	}
	
	*Confirm only 1 dose name is provided for this measurement
	if `=wordcount("$RI_QUAL_03_DOSE_NAME")' != 1 {
		di as error "Please specify the name of a single dose RI_QUAL_03_DOSE_NAME (e.g., PENTA1)"
		vcqi_log_comment $VCP 1 Error "Please specify the name of a single dose RI_QUAL_03_DOSE_NAME (e.g., PENTA1)"
		local exitflag 1
	}	
	
	*Confirm dose name in global RI_QUAL_03_DOSE_NAME is part of the RI_DOSE_LIST global
	local match 0
	foreach d in `=lower("$RI_DOSE_LIST")' {
		if "`d'" == "`=lower("$RI_QUAL_03_DOSE_NAME")'" local match 1
	}
	if `match'!= 1 {
		di as error "Dose name for global variable RI_QUAL_03_DOSE_NAME is not included in the RI_DOSE_LIST."
		vcqi_log_comment $VCP 1 Error  "Dose name for global variable RI_QUAL_03_DOSE_NAME is not included in the RI_DOSE_LIST."
		local exitflag 1
	}
	
	* Confirm dose name is not a 2nd or 3rd dose
	if inlist(substr("$RI_QUAL_03_DOSE_NAME",-1,1),"2","3") {
		di as error "Dose name for global variable RI_QUAL_03_DOSE_NAME can only be a single dose or the first in a series; current value is $RI_QUAL_03_DOSE_NAME"	
		vcqi_log_comment $VCP 1 Error  "Dose name for global variable RI_QUAL_03_DOSE_NAME can only be a single dose or the first in a series; current value is $RI_QUAL_03_DOSE_NAME"
		local exitflag 1
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

