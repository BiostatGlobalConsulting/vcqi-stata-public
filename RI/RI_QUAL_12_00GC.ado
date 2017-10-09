*! RI_QUAL_12_00GC version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-03	1.01	Dale Rhoda		Switched to DOSE_PAIR_LIST
*										and added check to see if thresholds
*										are too short (consistent with other
*										indicators that take interval
*										thresholds as input)
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_12_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_12_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	* If the user has specified RI_QUAL_12_DOSE_PAIR but not RI_QUAL_12_DOSE_PAIR_LIST, copy the contents
	if "$RI_QUAL_12_DOSE_PAIR" != "" & "$RI_QUAL_12_DOSE_PAIR_LIST" == "" vcqi_global RI_QUAL_12_DOSE_PAIR_LIST $RI_QUAL_12_DOSE_PAIR
	
	vcqi_log_global RI_QUAL_12_DOSE_PAIR_LIST
	vcqi_log_global RI_QUAL_12_THRESHOLD_LIST
	vcqi_log_global RI_DOSE_LIST

	local exitflag 0
	
	*Confirm global RI_QUAL_12_DOSE_PAIR_LIST is defined
	if "$RI_QUAL_12_DOSE_PAIR_LIST" == "" {
		di as error "You must define global RI_QUAL_12_DOSE_PAIR_LIST."
		vcqi_log_comment $VCP 1 Error "You must define global RI_QUAL_12_DOSE_PAIR_LIST."
		local exitflag 1
	}
	
	*Confirm global RI_QUAL_12_THRESHOLD_LIST is defined
	if "$RI_QUAL_12_THRESHOLD_LIST" == "" {
		di as error "You must define global RI_QUAL_12_THRESHOLD_LIST."
		vcqi_log_comment $VCP 1 Error "You must define global RI_QUAL_12_THRESHOLD_LIST."
		local exitflag 1
	}

	*Confirm dose names in global RI_QUAL_12_THRESHOLD_LIST are found in global RI_DOSE_LIST 
	local match 0
	foreach g in `=lower("$RI_QUAL_12_DOSE_PAIR_LIST")' {
		foreach d in `=lower("$RI_DOSE_LIST")' {
			if "`d'" == "`g'" local ++match 
		}
	}
	if `match'!= `=wordcount("$RI_QUAL_12_DOSE_PAIR_LIST")' {
		di as error "All dose names for RI_QUAL_12_DOSE_PAIR_LIST are not included in the RI_DOSE_LIST."
		vcqi_log_comment $VCP 1 Error  "All dose name for RI_QUAL_12_DOSE_PAIR_LIST are not included in the RI_DOSE_LIST."
		local exitflag 1
	}
	
	*Confirm global RI_QUAL_12_DOSE_PAIR_LIST is a multiple of 2
	if mod(`=wordcount("$RI_QUAL_12_DOSE_PAIR_LIST")',2)!=0 {
		di as error "The global RI_QUAL_12_DOSE_PAIR_LIST should hold an even number of dose names."
		vcqi_log_comment $VCP 1 Error  "The global RI_QUAL_12_DOSE_PAIR_LIST should hold an even number of dose names."
		local exitflag 1
	}

	*Confirm global RI_QUAL_12_THRESHOLD_LIST has a threshold for each dose pair
	if `=wordcount("$RI_QUAL_12_DOSE_PAIR_LIST")'/`=wordcount("$RI_QUAL_12_THRESHOLD_LIST")'!=2 {
		di as error "One threshold must be provided for each pair of doses in RI_QUAL_12_DOSE_PAIR_LIST."
		vcqi_log_comment $VCP 1 Error  "One threshold must be provided for each pair of doses in RI_QUAL_12_DOSE_PAIR_LIST."
		local exitflag 1
	}
	
	*Verify that the interval threshold provided seems reasonable
	foreach t in $RI_QUAL_12_THRESHOLD_LIST {
		if `t' < 4 {
			di as error "The global RI_QUAL_12_THRESHOLD_LIST is set to: $RI_QUAL_12_THRESHOLD_LIST"
			di as error "At least one of the intervals in RI_QUAL_12_THRESHOLD_LIST appears small, double check to make sure this value is filled in with the number of days and not the number of weeks, months or years."
			vcqi_log_comment $VCP 2 Warning "At least one of the intervals in RI_QUAL_12_THRESHOLD_LIST appears small, double check to make sure this value is filled in with the number of days and not the number of weeks, months or years."
		}
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

