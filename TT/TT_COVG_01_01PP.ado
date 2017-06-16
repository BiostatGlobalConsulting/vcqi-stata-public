*! TT_COVG_01_01PP version 1.02 - Biostat Global Consulting - 2017-01-31
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.02	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
*******************************************************************************

* To-do: add some checks for register data
* To-do: consider checking to see if the dates on the card or register contradict
*        the self-reported years since last dose - if the card or register says
*        they got one more recently than history, then consider using the 
*        documented value.

program define TT_COVG_01_01PP

	version 14
	local oldvcp $VCP
	global VCP TT_COVG_01_01PP
	
	quietly {
		vcqi_log_comment $VCP 5 Flow "Starting"

		use "${VCQI_OUTPUT_FOLDER}/TT_with_ids", clear
		
		keep level1id level2id level3id stratumid clusterid respid TT09 ///
		TT16 TT27 TT30-TT42 psweight HH02 HH04 $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST
		
		save "${VCQI_OUTPUT_FOLDER}/TT_COVG_01_${ANALYSIS_COUNTER}", replace
		
		vcqi_global TT_COVG_01_TEMP_DATASETS $TT_COVG_01_TEMP_DATASETS TT_COVG_01_${ANALYSIS_COUNTER}
	}
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
