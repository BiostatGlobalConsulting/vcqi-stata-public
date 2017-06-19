*! check_TT_survey_metadata version 1.01 - Biostat Global Consulting - 2015-03-10
*
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-03-10	1.01	Dale Rhoda		Put error in log and set VCQI_ERROR								
*******************************************************************************

program define check_TT_survey_metadata

	version 14
	local oldvcp $VCP
	global VCP check_TT_survey_metadata
	vcqi_log_comment $VCP 5 Flow "Starting"

	* Check that one and only one is set
	local all3here 1
	
	if "$TT_RECORDS_NOT_SOUGHT" != "0" & "$TT_RECORDS_NOT_SOUGHT" != "1" {
		local exitflag 1
		local all3here 0
		di as error "TT_RECORDS_NOT_SOUGHT is not set"
		vcqi_log_comment $VCP 1 Error "TT_RECORDS_NOT_SOUGHT is not set"
	}
	
	if "$TT_RECORDS_SOUGHT_FOR_ALL" != "0" & "$TT_RECORDS_SOUGHT_FOR_ALL" != "1" {
		local exitflag 1
		local all3here 0
		di as error "TT_RECORDS_SOUGHT_FOR_ALL is not set"
		vcqi_log_comment $VCP 1 Error "TT_RECORDS_SOUGHT_FOR_ALL is not set"
	}	
	
	if "$TT_RECORDS_SOUGHT_IF_NO_CARD" != "0" & "$TT_RECORDS_SOUGHT_IF_NO_CARD" != "1" {
		local exitflag 1
		local all3here 0
		di as error "TT_RECORDS_NOT_SOUGHT is not set"
		vcqi_log_comment $VCP 1 Error "TT_RECORDS_NOT_SOUGHT is not set"
	}
	
	if `all3here' == 1 {
	
		if $TT_RECORDS_NOT_SOUGHT + ///
		   $TT_RECORDS_SOUGHT_FOR_ALL + ///
		   $TT_RECORDS_SOUGHT_IF_NO_CARD != 1 {
		   
			local exitflag 1

			di as error "Problem in check_TT_survey_metadata:"
			di as error "One of the following parameters should be 1 and the other two should be zero:"
			di as error "TT_RECORDS_NOT_SOUGHT, TT_RECORDS_SOUGHT_FOR_ALL and TT_RECORDS_SOUGHT_IF_NO_CARD"
			di as error "Currently: $TT_RECORDS_NOT_SOUGHT, $TT_RECORDS_SOUGHT_FOR_ALL and $TT_RECORDS_SOUGHT_IF_NO_CARD, respectively."

			vcqi_log_comment $VCP 1 Error "Problem in check_TT_survey_metadata:"
			vcqi_log_comment $VCP 1 Error "One of the following parameters should be 1 and the other two should be zero:"
			vcqi_log_comment $VCP 1 Error "TT_RECORDS_NOT_SOUGHT, TT_RECORDS_SOUGHT_FOR_ALL and TT_RECORDS_SOUGHT_IF_NO_CARD"
			vcqi_log_comment $VCP 1 Error "Currently: $TT_RECORDS_NOT_SOUGHT, $TT_RECORDS_SOUGHT_FOR_ALL and $TT_RECORDS_SOUGHT_IF_NO_CARD, respectively."
			
		}
	}
	
	if "`exitflag'" == "1" {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

		
