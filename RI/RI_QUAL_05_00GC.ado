*! RI_QUAL_05_00GC version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-31	1.01	Dale Rhoda		Fixed typo in comment
* 2017-02-01	1.02	Dale Rhoda		Improved error message
* 2017-02-02	1.03	Dale Rhoda		Improved error messages
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_05_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_05_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	

	foreach g in RI_QUAL_05_DOSE_NAME RI_QUAL_05_INTERVAL_THRESHOLD RI_MULTI_2_DOSE_LIST RI_MULTI_3_DOSE_LIST {
		vcqi_log_global `g'
	}
	
	local exitflag 0
	
	*Confirm global RI_QUAL_05_DOSE_NAME is defined
	if "$RI_QUAL_05_DOSE_NAME"=="" {
		di as error "You must define global RI_QUAL_05_DOSE_NAME."
		vcqi_log_comment $VCP 1 Error "You must define global RI_QUAL_05_DOSE_NAME."
		local exitflag 1
	}
	
	* Confirm that only a single dose name is listed
	if `=wordcount("$RI_QUAL_05_DOSE_NAME")' != 1 {
		di as error "Please specify the name of a multi-dose vaccine in RI_QUAL_05_DOSE_NAME (e.g., OPV, PENTA, ROTA)"
		vcqi_log_comment $VCP 1 Error "Please specify the name of a multi-dose vaccine in RI_QUAL_05_DOSE_NAME (e.g., OPV, PENTA, ROTA)"
		local exitflag 1
	}		
	
	if "$RI_QUAL_05_INTERVAL_THRESHOLD"=="" {
		di as error "You must define global RI_QUAL_05_INTERVAL_THRESHOLD."
		vcqi_log_comment $VCP 1 Error "You must define global RI_QUAL_05_INTERVAL_THRESHOLD."
		local exitflag 1
	}
	
	*Verify the threshold is a numeric value
	capture confirm number $RI_QUAL_05_INTERVAL_THRESHOLD 
	if _rc!=0 {
		di as error "Global RI_QUAL_04_INTERVAL_THRESHOLD must be a number."
		vcqi_log_comment $VCP 1 Error "Global RI_QUAL_04_INTERVAL_THRESHOLD must be a number."
		local exitflag 1
	}

	*Confirm the name of the multi-dose-series in global RI_QUAL_05_DOSE_NAME is 
	*one of those listed in RI_MULTI_2_DOSE_LIST or RI_MULTI_3_DOSE_LIST 
	local match 0
	foreach d in `=lower("$RI_MULTI_2_DOSE_LIST $RI_MULTI_3_DOSE_LIST")' {
		if "`d'" == "`=lower("$RI_QUAL_05_DOSE_NAME")'" local match 1
	}
	if `match' == 0 {
		di as error "RI_QUAL_05_DOSE_NAME is not specified in RI_MULTI_2_DOSE_LIST or RI_MULTI_3_DOSE_LIST."
		vcqi_log_comment $VCP 1 Error  "RI_QUAL_05_DOSE_NAME is not specified in RI_MULTI_2_DOSE_LIST or RI_MULTI_3_DOSE_LIST."
		local exitflag 1
	}
	
	*Verify that the interval threshold provided seems reasonable
	if $RI_QUAL_05_INTERVAL_THRESHOLD < 4 {
		di $RI_QUAL_05_INTERVAL_THRESHOLD 
		di as error "Global RI_QUAL_05_INTERVAL_THRESHOLD appears small, double check to make sure this value is filled in with the number of days and not the number of weeks, months or years."
		vcqi_log_comment $VCP 2 Warning "Global RI_QUAL_05_INTERVAL_THRESHOLD appears small, double check to make sure this value is filled in with the number of days and not the number of weeks, months or years."
	}


	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

