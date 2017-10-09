*! RI_COVG_01_02DQ version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-03-07	1.01	Dale Rhoda		cleaned up exitflag
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_01_02DQ
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_01_02DQ
	vcqi_log_comment $VCP 5 Flow "Starting"

	qui use "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", clear
	
	local exitflag 0

	* This program assumes dates and tick marks have been cleaned
	* Only validates repsonses to bcg_scar_history 
	* - Interviewer sees evidence of scar on child
	
	if strpos("$RI_DOSE_LIST","bcg") > 0 {
		capture assert inlist(bcg_scar_history,1,2,3,.)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "RI_COVG_01: bcg_scar_history contains values that are not the expected values of 1,2,3 or missing"
			di as error "RI_COVG_01: bcg_scar_history contains values that are not the expected values of 1,2,3 or missing"
			tab bcg_scar_history, m
			local exitflag 1
		}
	}
	
	* Run DQ on history responses, too

	foreach d in $RI_DOSE_LIST {
		capture assert inlist(`d'_history,1,2,99,.)
		if _rc != 0 {
			vcqi_log_comment $VCP 1 Error "RI_COVG_01: `d'_history contains values that are not the expected values of 1,2,99 or missing"
			di as error "`d'_history contains values that are not the expected values of 1,2,99 or missing"
			tab `d'_history, m
			local exitflag 1
		}
	}

	if "`exitflag'" == "1" {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
