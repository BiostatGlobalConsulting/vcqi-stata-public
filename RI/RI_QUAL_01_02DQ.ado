*! RI_QUAL_01_02DQ version 1.00 - Biostat Global Consulting- 2015-10-14
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************

program define RI_QUAL_01_02DQ

	local oldvcp $VCP
	global VCP RI_QUAL_01_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}", clear

		capture assert inlist(RI27,1,2,.)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "RI27 contains values that are not the expected values of 1,2,."
			di as error "RI_QUAL_01: RI27 contains values that are not the expected values of 1,2,."
			tab RI27, m
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
