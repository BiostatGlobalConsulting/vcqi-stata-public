*! check_RI_schedule_metadata version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-14	1.01	Dale Rhoda		Set VCQI_ERROR to 1 if exitflag == 1
* 2017-04-25	1.02	MK Trimner		Added code to check the length of each dose name
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line						
*******************************************************************************

program define check_RI_schedule_metadata
	version 14.1
	
	local oldvcp $VCP
	global VCP check_RI_schedule_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	local exitflag 0
	
	foreach d in `=lower("$RI_SINGLE_DOSE_LIST")' {
	
		if length("`d'") > 6 {
			di as error "Dose name `d' specified in global RI_SINGLE_DOSE_LIST is too long"
			di as error "it must be less than 6 characters"
			di as error "Please reference the User's Guide section 3.1 Vaccination Schedule Metadata: A Note on Dose Names"
			di as error "if you have any specific questions about the dose naming convention"
			
			local exitflag 1
			
			vcqi_log_comment $VCP 1 Error "RI_SINGLE_DOSE_LIST name `d' is greater than the 6 character limit"
		}
		else {
		
			vcqi_log_comment $VCP 3 Comment "RI_SINGLE_DOSE_LIST name `d' is within than the 6 character limit"
		}
		
		
		capture confirm scalar `d'_min_age_days
		if _rc > 0 {
			di as error "check_RI_schedule_metadata: RI_SINGLE_DOSE_LIST includes `d'"
			di as error "but the vaccination schedule does not include a scalar "
			di as error "named `d'_min_age_days"
			
			local exitflag 1
			
			vcqi_log_comment $VCP 1 Error "`d'_min_age_days is not specified in the RI schedule"

		}
		else {
			vcqi_log_comment $VCP 3 RI_Schedule "`d'_min_age_days is `=scalar(`d'_min_age_days)'"
		}
	}
	
	foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
		if length("`d'") > 5 {
			di as error "Dose name `d' specified in global RI_MULTI_2_DOSE_LIST is too long"
			di as error "it must be less than 5 characters"
			di as error "Please reference the User's Guide section 3.1 Vaccination Schedule Metadata: A Note on Dose Names"
			di as error "if you have any specific questions about the dose naming convention"
			
			local exitflag 1
			
			vcqi_log_comment $VCP 1 Error "RI_MULTI_2_DOSE_LIST name `d' is greater than the 5 character limit"
		}
		else {
		
			vcqi_log_comment $VCP 3 Comment "RI_MULTI_2_DOSE_LIST name `d' is within than the 5 character limit"
		}

		
		capture confirm scalar `d'1_min_age_days
		if _rc > 0 {
			di as error "check_RI_schedule_metadata: RI_MULTI_2_DOSE_LIST includes `d'"
			di as error "but the vaccination schedule does not include a scalar "
			di as error "named `d'1_min_age_days"
			
			local exitflag 1
			
			vcqi_log_comment $VCP 1 Error "`d'1_min_age_days is not specified in the RI schedule"

		}	
		else {
			vcqi_log_comment $VCP 3 RI_Schedule "`d'1_min_age_days is `=scalar(`d'1_min_age_days)'"
		}
		
		capture confirm scalar `d'2_min_interval_days
		if _rc > 0 {
			di as error "check_RI_schedule_metadata: RI_MULTI_2_DOSE_LIST includes `d'"
			di as error "but the vaccination schedule does not include a scalar "
			di as error "named `d'2_min_interval_days"
			
			local exitflag 1

			vcqi_log_comment $VCP 1 Error "`d'2_min_interval_days is not specified in the RI schedule"

		}
		else {
			vcqi_log_comment $VCP 3 RI_Schedule "`d'2_min_interval_days is `=scalar(`d'2_min_interval_days)'"
		}
	}
	
	foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
		if length("`d'") > 5 {
			di as error "Dose name `d' specified in global RI_MULTI_3_DOSE_LIST is too long"
			di as error "it must be less than 5 characters"
			di as error "Please reference the User's Guide section 3.1 Vaccination Schedule Metadata: A Note on Dose Names"
			di as error "if you have any specific questions about the dose naming convention"
			
			local exitflag 1
			
			vcqi_log_comment $VCP 1 Error "RI_MULTI_3_DOSE_LIST name `d' is greater than the 5 character limit"
		}
		else {
		
			vcqi_log_comment $VCP 3 Comment "RI_MULTI_3_DOSE_LIST name `d' is within than the 5 character limit"
		}
		
		
		capture confirm scalar `d'1_min_age_days
		if _rc > 0 {
			di as error "check_RI_schedule_metadata: RI_MULTI_3_DOSE_LIST includes `d'"
			di as error "but the vaccination schedule does not include a scalar "
			di as error "named `d'1_min_age_days"
			
			local exitflag 1

			vcqi_log_comment $VCP 1 Error "`d'1_min_age_days is not specified in the RI schedule"

		}
		else {
			vcqi_log_comment $VCP 3 RI_Schedule "``d'1_min_age_days is `=scalar(`d'1_min_age_days)'"
		}
		
		capture confirm scalar `d'2_min_interval_days
		if _rc > 0 {
			di as error "check_RI_schedule_metadata: RI_MULTI_3_DOSE_LIST includes `d'"
			di as error "but the vaccination schedule does not include a scalar "
			di as error "named `d'2_min_interval_days"
			
			local exitflag 1

			vcqi_log_comment $VCP 1 Error "`d'2_min_interval_days is not specified in the RI schedule"

		}
		else {
			vcqi_log_comment $VCP 3 RI_Schedule "`d'2_min_interval_days is `=scalar(`d'2_min_interval_days)'"
		}
		
		capture confirm scalar `d'3_min_interval_days
		if _rc > 0 {
			di as error "check_RI_schedule_metadata: RI_MULTI_3_DOSE_LIST includes `d'"
			di as error "but the vaccination schedule does not include a scalar "
			di as error "named `d'3_min_interval_days"
			
			local exitflag 1
			
			vcqi_log_comment $VCP 1 Error "`d'3_min_interval_days is not specified in the RI schedule"

		}
		else {
			vcqi_log_comment $VCP 3 RI_Schedule "`d'3_min_interval_days is `=scalar(`d'3_min_interval_days)'"
		}
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
