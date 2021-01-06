*! SIA_COVG_05_01PP version 1.03 - Biostat Global Consulting - 2019-08-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-25	1.00	MK Trimner		Original copied from RI_COVG_05
* 2018-11-05	1.01	MK Trimner		Added the SIA01, SIA03, SAI11 and SIA12 variables
*										to keep list to carry over true clusterid
* 2019-01-10	1.02	Dale Rhoda		Start with SIA_with_ids and merge in
*										got_sia_dose
* 2019-08-23	1.03	Dale Rhoda		Drop if psweight == 0 | missing(psweight)
*										(we are not interested in clusters
* 										 that are simply placeholders for DOF)
*******************************************************************************

program define SIA_COVG_05_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_05_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		check_SIA_COVG_01_03DV

		use "${VCQI_OUTPUT_FOLDER}/SIA_with_ids", clear

		merge 1:1 respid using "${VCQI_OUTPUT_FOLDER}/SIA_COVG_01_${ANALYSIS_COUNTER}", keepusing(got_sia_dose) nogen
		
		keep level1id level2id level3id stratumid clusterid respid SIA01 SIA03 SIA11 SIA12 HH02 HH04 psweight got_sia_dose
			 
		rename HH02 stratum_name
		rename HH04 cluster_name
		
		drop if psweight == 0 | missing(psweight)

		save "${VCQI_OUTPUT_FOLDER}/SIA_COVG_05_${ANALYSIS_COUNTER}", replace

		vcqi_global SIA_COVG_05_TEMP_DATASETS $SIA_COVG_05_TEMP_DATASETS SIA_COVG_05_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
