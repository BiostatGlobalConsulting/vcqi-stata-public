*! check_RI_survey_metadata version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Put vcqi_log_global RI_DOSE_LIST on a new line, 
*										previously on same line as vcqi_log_comment 
* 2016-02-14	1.02	Dale Rhoda		Set VCQI_ERROR to 1 if exitflag == 1								
* 2017-01-12	1.03	Dale Rhoda		Set MAX and MIN age of survey 
*										eligibility if the user hasn't already
*										set them
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define check_RI_survey_metadata
	version 14.1
	
	local oldvcp $VCP
	global VCP check_RI_survey_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"	
	
	vcqi_log_global RI_DOSE_LIST

	local exitflag 0

	foreach g in EARLIEST_SVY_VACC_DATE_M EARLIEST_SVY_VACC_DATE_D EARLIEST_SVY_VACC_DATE_Y ///
				 LATEST_SVY_VACC_DATE_M LATEST_SVY_VACC_DATE_D LATEST_SVY_VACC_DATE_Y {
		vcqi_log_global `g'
		if "$`g'" == "" {
			di as error "check_RI_survey_metadata: missing expected parameter `g'"
			local exitflag 1
			vcqi_log_comment $VCP 1 Error "`g' is not specified in the survey parameters"
		}
	}
	
		if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	capture assert mdy($EARLIEST_SVY_VACC_DATE_M, $EARLIEST_SVY_VACC_DATE_D, $EARLIEST_SVY_VACC_DATE_Y) < ///
	               mdy($LATEST_SVY_VACC_DATE_M, $LATEST_SVY_VACC_DATE_D, $LATEST_SVY_VACC_DATE_Y)
	if _rc > 0 {
		di as error "Earliest survey vaccination date should be before latest survey vaccination date."
		local exitflag 1
		vcqi_log_comment $VCP 1 Error "`g' is not specified in the survey parameters"
	}				   
	
	local all3here 1
	foreach g in RI_RECORDS_NOT_SOUGHT RI_RECORDS_SOUGHT_FOR_ALL RI_RECORDS_SOUGHT_IF_NO_CARD {
		vcqi_log_global `g'
		if "$`g'" == "" {
			di as error "check_RI_survey_metadata: missing expected parameter `g'"
			local exitflag 1
			local all3here 0
			vcqi_log_comment $VCP 1 Error "`g' is not specified in the survey parameters"
		}
		
		* check that each is either 0 or 1
		if $`g' != 0 & $`g' != 1 {
			di as error "`g' should be 0 or 1"
			local exitflag 1
			vcqi_log_comment $VCP 1 Error "`g' should be 0 or 1"
		}
	}
		if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	* Check that one and only one is set to 1
	if `all3here' == 1 {
		if $RI_RECORDS_NOT_SOUGHT + ///
		   $RI_RECORDS_SOUGHT_FOR_ALL + ///
		   $RI_RECORDS_SOUGHT_IF_NO_CARD != 1 {
		   
			local exitflag 1

			di as error "Problem in check_RI_survey_metadata:"
			di as error "One of the following parameters should be 1 and the other two should be zero:"
			di as error "RI_RECORDS_NOT_SOUGHT, RI_RECORDS_SOUGHT_FOR_ALL and RI_RECORDS_SOUGHT_IF_NO_CARD"
			di as error "Currently: $RI_RECORDS_NOT_SOUGHT, $RI_RECORDS_SOUGHT_FOR_ALL and $RI_RECORDS_SOUGHT_IF_NO_CARD, respectively."
			
			vcqi_log_comment $VCP 1 Error "One and only one of the three RI_RECORDS globals should be set to 1"
		}
	}
	
	* Specify min and max age of survey eligibility if the user hasn't done so
	if "$VCQI_RI_MIN_AGE_OF_ELIGIBILITY" == "" vcqi_global VCQI_RI_MIN_AGE_OF_ELIGIBILITY 365
	if "$VCQI_RI_MAX_AGE_OF_ELIGIBILITY" == "" vcqi_global VCQI_RI_MAX_AGE_OF_ELIGIBILITY 731
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

		
