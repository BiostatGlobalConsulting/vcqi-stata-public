*! SIA_COVG_01_02DQ version 1.00 - Biostat Global Consulting - 2015-09-28
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-03	1.01	Dale Rhoda		Edit error messages
*******************************************************************************

program define SIA_COVG_01_02DQ

	local oldvcp $VCP
	global VCP SIA_COVG_01_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_${ANALYSIS_COUNTER}", clear
			
		* Stop if the dataset contains unexpected values

		capture assert inlist(SIA20,1,2,3,99)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA20 contains values that are not the expected values of 1,2,3,99"
			di as error "SIA_COVG_01: SIA20 contains values that are not the expected values of 1,2,3,99"
			tab SIA20, m
			local exitflag 1
		}
		
		capture assert inlist(SIA22,1,2,3,99,.)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA22 contains values that are not the expected values of 1,2,3,99 or ."
			di as error "SIA_COVG_01: SIA22 contains values that are not the expected values of 1,2,3,99 or ."
			tab SIA22, m
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
