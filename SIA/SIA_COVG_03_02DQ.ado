*! SIA_COVG_03_02DQ version 1.02 - Biostat Global Consulting - 2017-02-04
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		removed global assignment of 
*										MIN_SIA_YEARS and MAX_SIA_YEARS as
*										these are defined in 03DV
* 2017-02-04	1.02	Dale Rhoda		Edited error msgs
*******************************************************************************

program define SIA_COVG_03_02DQ

	local oldvcp $VCP
	global VCP SIA_COVG_03_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/SIA_COVG_03_${ANALYSIS_COUNTER}", clear
			
		* Stop if the dataset contains unexpected values

		capture assert inlist(SIA20,1,2,3,99)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA20 contains values that are not the expected values of 1,2,3,99"
			di as error "SIA_COVG_03: SIA20 contains values that are not the expected values of 1,2,3,99"
			tab SIA20, m
			local exitflag 1
		}
		
		capture assert inlist(SIA27,1,2,3,99)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA27 contains values that are not the expected values of 1,2,3,99"
			di as error "SIA_COVG_03: SIA27 contains values that are not the expected values of 1,2,3,99"
			tab SIA27, m
			local exitflag 1
		}	
		
		capture assert inlist(SIA29,1,2,.)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA29 contains values that are not the expected values of 1,2,or ."
			di as error "SIA_COVG_03: SIA29 contains values that are not the expected values of 1,2,or ."
			tab SIA29, m
			local exitflag 1
		}
		
		capture assert inlist(SIA31,1,2,.)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "SIA31 contains values that are not the expected values of 1,2,or ."
			di as error "SIA_COVG_03: SIA31 contains values that are not the expected values of 1,2,or ."
			tab SIA31, m
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
