*! RI_COVG_05_01PP version 1.03 - Biostat Global Consulting - 2019-07-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2019-07-17	1.03	Dale Rhoda		Drop if psweight == 0 | missing(psweight)
*										(we are not interested in clusters
* 										 that are simply placeholders for DOF)
*******************************************************************************

program define RI_COVG_05_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_05_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		check_RI_COVG_01_03DV

		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", clear

		local dlist	
		foreach d in `=lower("$RI_COVG_05_DOSE_LIST")' {
			local dlist `dlist' got_crude_`d'_to_analyze
		}

		keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
			 HH02 HH04 psweight `dlist' 
			 
		rename HH02 stratum_name
		rename HH04 cluster_name
		
		drop if psweight == 0 | missing(psweight)

		save "${VCQI_OUTPUT_FOLDER}/RI_COVG_05_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_COVG_05_TEMP_DATASETS $RI_COVG_05_TEMP_DATASETS RI_COVG_05_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
