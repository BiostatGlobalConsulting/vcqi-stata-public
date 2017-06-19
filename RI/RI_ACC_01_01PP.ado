*! RI_ACC_01_01PP version 1.02 - Biostat Global Consulting - 2017-01-31
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.02	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
*******************************************************************************

program define RI_ACC_01_01PP

	local oldvcp $VCP
	global VCP RI_ACC_01_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		*verify RI_COVG_01 ran	
		check_RI_COVG_01_03DV
		
		*copy database from RI_COVG_01 and only look specified variable
		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", clear
			
		keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
			 HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
			 got_crude_`=lower("$RI_ACC_01_DOSE_NAME")'_to_analyze 

		save "${VCQI_OUTPUT_FOLDER}/RI_ACC_01_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_ACC_01_TEMP_DATASETS $RI_ACC_01_TEMP_DATASETS RI_ACC_01_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
