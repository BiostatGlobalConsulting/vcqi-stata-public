*! DESC_03_01PP version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-13	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.02	Dale Rhoda		Added $VCQI_LEVEL4_SET_VARLIST
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define DESC_03_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_03_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"

	use "${VCQI_OUTPUT_FOLDER}/${DESC_03_DATASET}_with_ids", clear
	quietly {
		* The user may call this measure several times with different combinations
		* of inputs, so track a counter so each dataset gets saved for later
		* examination, if necessary
		
		if "$DESC_03_COUNTER" != "" global DESC_03_COUNTER = $DESC_03_COUNTER + 1
		if "$DESC_03_COUNTER" == "" global DESC_03_COUNTER 1
		
		keep level1id level2id level3id stratumid clusterid respid ///
			 HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
			 $DESC_03_VARIABLES

		save "${VCQI_OUTPUT_FOLDER}/DESC_03_${ANALYSIS_COUNTER}_${DESC_03_COUNTER}", replace

		vcqi_global DESC_03_TEMP_DATASETS $DESC_03_TEMP_DATASETS DESC_03_${ANALYSIS_COUNTER}_${DESC_03_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

