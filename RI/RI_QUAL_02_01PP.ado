*! RI_QUAL_02_01PP version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.02	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_02_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_02_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear

		keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
			 HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
			 RI26

		save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_02_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_QUAL_02_TEMP_DATASETS $RI_QUAL_02_TEMP_DATASETS RI_QUAL_02_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
