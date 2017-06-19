*! SIA_QUAL_01_02DQ version 1.00 - Biostat Global Consulting - 2015-10-12
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-04-02	1.01	Dale Rhoda		Edited error msgs
*******************************************************************************

program define SIA_QUAL_01_02DQ

	local oldvcp $VCP
	global VCP SIA_QUAL_01_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
		use "${VCQI_OUTPUT_FOLDER}/SIA_QUAL_01_${ANALYSIS_COUNTER}", clear
			
		* Stop if the dataset contains unexpected values

		capture assert inlist(SIA20,1,2,3,99)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA20 contains values that are not the expected values of 1,2,3,99"
			di as error "SIA_QUAL_01: SIA20 contains values that are not the expected values of 1,2,3,99"
			tab SIA20, m
			local exitflag 1
		}
		
		capture assert inlist(SIA21,1,2,3,99,.)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA21 contains values that are not the expected values of 1,2,3,99 or missing"
			di as error "SIA_QUAL_01: SIA21 contains values that are not the expected values of 1,2,3,99 or missing"
			tab SIA21, m
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
