*! RI_QUAL_06_01PP version 1.02 - Biostat Global Consulting - 2017-01-31
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.02	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
*******************************************************************************

program define RI_QUAL_06_01PP

	local oldvcp $VCP
	global VCP RI_QUAL_06_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		*Verify RI_COVG_02_03DV exists
		check_RI_COVG_02_03DV
		
		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}", clear

		local d `=lower("$RI_QUAL_06_DOSE_NAME")' 
		local dlist got_valid_`d'_to_analyze valid_`d'_age1_to_analyze age_at_valid_`d'
			
		keep level1id level2id level3id stratumid clusterid respid ///
			 RI01 RI03 RI11 RI12 HH02 HH04 ///
			 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST `dlist'
		
		save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_06_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_QUAL_06_TEMP_DATASETS $RI_QUAL_06_TEMP_DATASETS RI_QUAL_06_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
