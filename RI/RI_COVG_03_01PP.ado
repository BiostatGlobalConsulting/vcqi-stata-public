*! RI_COVG_03_01PP version 1.03 - Biostat Global Consulting - 2017-01-31
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
*
* 2017-01-09	1.02	Dale Rhoda		Skip valid dose calcs if no 
*										respondent has a DOB
* 2017-01-31	1.03	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
*******************************************************************************

program define RI_COVG_03_01PP

	local oldvcp $VCP
	global VCP RI_COVG_03_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		check_RI_COVG_01_03DV
		if "$VCQI_NO_DOBS" != "1" {
		
			check_RI_COVG_02_03DV

			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}", clear
			merge 1:1 respid using "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}"
			drop _merge
			
		}
		else use "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", clear
		
		local dlist	
		foreach d in $RI_DOSE_LIST {
			local dlist `dlist' got_crude_`d'_to_analyze 
			if "$VCQI_NO_DOBS" != "1" local dlist `dlist' got_valid_`d'_to_analyze valid_`d'_age1_to_analyze
		}

		keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
			HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
			`dlist' 

		save "${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_COVG_03_TEMP_DATASETS $RI_COVG_03_TEMP_DATASETS RI_COVG_03_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
