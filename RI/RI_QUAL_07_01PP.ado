*! RI_QUAL_07_01PP version 1.04 - Biostat Global Consulting - 2019-11-08
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.02	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2019-11-08	1.04	Dale Rhoda		Introduced MOV_OUTPUT_DOSE_LIST
*******************************************************************************

program define RI_QUAL_07_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		local vc  `=lower("$RI_QUAL_07_VALID_OR_CRUDE")'

		*Verify RI_COVG_02_03DV exists
		check_RI_COVG_02_03DV
		
		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}", clear
		merge 1:1 respid using RI_MOV_flags_to_merge
		keep if _merge == 1 | _merge == 3
		drop _merge

		local dlist	
		foreach d in $MOV_OUTPUT_DOSE_LIST {
			local dlist `dlist' got_valid_`d'_to_analyze flag_uncor_mov_`d'_`vc'
		}

		keep level1id level2id level3id stratumid clusterid respid ///
			 RI01 RI03 RI11 RI12 HH02 HH04 ///
			 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST `dlist'
				
		save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_07_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_QUAL_07_TEMP_DATASETS $RI_QUAL_07_TEMP_DATASETS RI_QUAL_07_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
