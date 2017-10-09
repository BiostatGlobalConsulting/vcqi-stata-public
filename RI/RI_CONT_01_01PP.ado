*! RI_CONT_01_01PP version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.02	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
* 2017-02-02	1.03	Dale Rhoda		Cosmetic changes
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_CONT_01_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CONT_01_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		*Verify RI_COVG_01 ran
		check_RI_COVG_01_03DV	

		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", clear
		
		local r 1
		local dlist	
		foreach d in `=lower("$RI_CONT_01_DROPOUT_LIST")'{
			local dlist `dlist' got_crude_`d'_to_analyze 
		}
			
		keep level1id level2id level3id stratumid clusterid respid ///
			 RI01 RI03 RI11 RI12 HH02 HH04 ///
			 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST `dlist' 
			 
		save "${VCQI_OUTPUT_FOLDER}/RI_CONT_01_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_CONT_01_TEMP_DATASETS $RI_CONT_01_TEMP_DATASETS RI_CONT_01_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
