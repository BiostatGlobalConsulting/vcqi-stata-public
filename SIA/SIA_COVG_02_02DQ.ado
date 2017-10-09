*! SIA_COVG_02_02DQ version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-04	1.01	Dale Rhoda		Edited error msgs
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define SIA_COVG_02_02DQ
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_02_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_02_${ANALYSIS_COUNTER}", clear
			
		* Stop if the dataset contains unexpected values

		capture assert inlist(SIA20,1,2,3,99)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA20 contains values that are not the expected values of 1,2,3,99"
			di as error "SIA_COVG_02: SIA20 contains values that are not the expected values of 1,2,3,99"
			tab SIA20, m
			local exitflag 1
		}
		
		capture assert inlist(SIA27,1,2,3,99)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA27 contains values that are not the expected values of 1,2,3,99"
			di as error "SIA_COVG_02: SIA27 contains values that are not the expected values of 1,2,3,99"
			tab SIA27, m
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
