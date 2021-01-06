*! RI_QUAL_02_02DQ version 1.03 - Biostat Global Consulting - 2019-08-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-03-07	1.01	Dale Rhoda		cleaned up exitflag
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2019-08-23	1.03	Dale Rhoda		Allow RI26 to tke a missing value
*******************************************************************************

program define RI_QUAL_02_02DQ
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_02_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_02_${ANALYSIS_COUNTER}", clear

		capture assert inlist(RI26,1,2,99,.)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "RI26 contains values that are not the expected values of 1,2,99,."
			di as error "RI_QUAL_02: RI26 contains values that are not the expected values of 1,2,99,."
			tab RI26, m
			local exitflag 1
		}

		if "`exitflag'" == "1" {
			vcqi_global VCQI_ERROR 1
			vcqi_halt_immediately
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
