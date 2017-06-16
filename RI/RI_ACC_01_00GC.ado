*! RI_ACC_01_00GC version 1.00 - Biostat Global Consulting 2015-11-04
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-02	1.01	Dale Rhoda		Cosmetic changes
*******************************************************************************

program define RI_ACC_01_00GC

	local oldvcp $VCP
	global VCP RI_ACC_01_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	 
	vcqi_log_global RI_ACC_01_DOSE_NAME
	vcqi_log_global RI_DOSE_LIST
	
	local exitflag 0
	
	*Confirm global RI_ACC_01_DOSE_NAME is defined
	if "$RI_ACC_01_DOSE_NAME"=="" {
		di as error "You must define global variable RI_ACC_01_DOSE_NAME."
		vcqi_log_comment $VCP 1 Error "You must define global variable RI_ACC_01_DOSE_NAME."
		local exitflag 1
	}
	
	* Confirm it's a single dose
	if `=wordcount("$RI_ACC_01_DOSE_NAME")' != 1 {
		di as error "Please specify the name of a single vaccine dose in RI_ACC_01_DOSE_NAME (e.g., PENTA1)"
		vcqi_log_comment $VCP 1 Error "Please specify the name of a single vaccine dose in RI_ACC_01_DOSE_NAME (e.g., PENTA1)"
		local exitflag 1
	}	
	
	*Confirm dose name in global RI_ACC_01_DOSE_NAME is part of the RI_DOSE_LIST global
	local match 0
	foreach d in `=lower("$RI_DOSE_LIST")' {
		if "`d'" == "`=lower("$RI_ACC_01_DOSE_NAME")'" local match 1
	}
	if `match'!= 1 {
		di as error "Dose name for global variable RI_ACC_01_DOSE_NAME is not included in the RI_DOSE_LIST provided."
		vcqi_log_comment $VCP 1 Error  "Dose name for global variable RI_ACC_01_DOSE_NAME is not included in the RI_DOSE_LIST provided."
		local exitflag 1
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		di `exitflag'
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end


