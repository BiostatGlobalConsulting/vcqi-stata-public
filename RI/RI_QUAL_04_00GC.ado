*! RI_QUAL_04_00GC version 1.01 - Biostat Global Consulting 2017-02-02
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-02	1.01	Dale Rhoda		Edited error messages
*******************************************************************************

program define RI_QUAL_04_00GC

	local oldvcp $VCP
	global VCP RI_QUAL_04_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	vcqi_log_global RI_QUAL_04_AGE_THRESHOLD 
	vcqi_log_global RI_QUAL_04_DOSE_NAME
	vcqi_log_global RI_DOSE_LIST
	
	local exitflag 0
	
	*Confirm global RI_QUAL_04_DOSE_NAME is defined
	if "$RI_QUAL_04_DOSE_NAME"=="" {
		di as error "You must define global RI_QUAL_04_DOSE_NAME."
		vcqi_log_comment $VCP 1 Error "You must define global RI_QUAL_04_DOSE_NAME."
		local exitflag 1
	}
	
	*Confirm only 1 dose name is provided for this measurement
	if `=wordcount("$RI_QUAL_04_DOSE_NAME")' != 1 {
		di as error "RI_QUAL_04_DOSE_NAME should specify the name of a single dose (e.g., MCV1)"
		vcqi_log_comment $VCP 1 Error "RI_QUAL_04_DOSE_NAME should specify the name of a single dose (e.g., MCV1)"
		local exitflag 1
	}	
	
	if "$RI_QUAL_04_AGE_THRESHOLD"=="" {
		di as error "You must define global RI_QUAL_04_AGE_THRESHOLD."
		vcqi_log_comment $VCP 1 Error "You must define global RI_QUAL_04_AGE_THRESHOLD."
		local exitflag 1
	}
	
	*Verify the threshold is a numeric value
	capture confirm number $RI_QUAL_04_AGE_THRESHOLD 
	if _rc!=0 {
		di as error "Global RI_QUAL_04_AGE_THRESHOLD must be a number (age in days)."
		vcqi_log_comment $VCP 1 Error "Global RI_QUAL_04_AGE_THRESHOLD must be a number (age in days)."
		local exitflag 1
	}

	*Confirm dose name in global RI_QUAL_04_DOSE_NAME is part of the RI_DOSE_LIST global
	local match 0
	foreach d in `=lower("$RI_DOSE_LIST")' {
		if "`d'" == "`=lower("$RI_QUAL_04_DOSE_NAME")'" local match 1 
	}
	if `match'!= 1 {
		di as error "Dose name for global RI_QUAL_04_DOSE_NAME is not included in the RI_DOSE_LIST."
		vcqi_log_comment $VCP 1 Error  "Dose name for global RI_QUAL_04_DOSE_NAME is not included in the RI_DOSE_LIST."
		local exitflag 1
	}

	*Verify that the age threshold provided seems reasonable
	if $RI_QUAL_04_AGE_THRESHOLD < 42 {
		di as error "Global RI_QUAL_04_AGE_THRESHOLD appears small, double check to make sure this value is filled in with the number of days and not the number of weeks, months or years."
		vcqi_log_comment $VCP 2 Warning "Global RI_QUAL_04_AGE_THRESHOLD appears small, double check to make sure this value is filled in with the number of days and not the number of weeks, months or years."
	}

	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
