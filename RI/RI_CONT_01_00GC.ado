*! RI_CONT_01_00GC version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-02	1.01	Dale Rhoda		changed wording in some error msgs
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_CONT_01_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CONT_01_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	vcqi_log_global RI_CONT_01_DROPOUT_LIST
	vcqi_log_global RI_DOSE_LIST

	local exitflag 0
	
	*Confirm global RI_CONT_01_DROPOUT_LIST is defined
	if "$RI_CONT_01_DROPOUT_LIST"=="" {
		di as error "You must define global variable RI_CONT_01_DROPOUT_LIST."
		vcqi_log_comment $VCP 1 Error "You must define global variable RI_CONT_01_DROPOUT_LIST."
		local exitflag 1
	}
		
	*Confirm dose names in global RI_CONT_01_DROPOUT_LIST are found in global RI_DOSE_LIST 
	local match 0
	foreach g in `=lower("$RI_CONT_01_DROPOUT_LIST")' {
		foreach d in `=lower("$RI_DOSE_LIST")' {
			if "`d'" == "`g'" local ++match 
		}
	}
	if `match' != `=wordcount("$RI_CONT_01_DROPOUT_LIST")' {
		di as error "Some dose names in global RI_CONT_01_DROPOUT_LIST are not included in the RI_DOSE_LIST."
		vcqi_log_comment $VCP 1 Error  "Some dose names in global RI_CONT_01_DROPOUT_LIST are not included in the RI_DOSE_LIST."
		local exitflag 1
	}
	
	*Confirm global RI_CONT_01_DROPOUT_LIST is a multiple of 2
	if mod(`=wordcount("$RI_CONT_01_DROPOUT_LIST")',2) != 0 {
		di as error "RI_CONT_01_DROPOUT_LIST does not contain an even number of dose names."
		vcqi_log_comment $VCP 1 Error  "RI_CONT_01_DROPOUT_LIST does not contain an even number of dose names."
		local exitflag 1
	}

	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end



