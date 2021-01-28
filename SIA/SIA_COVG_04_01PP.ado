*! SIA_COVG_04_01PP version 1.01 - Biostat Global Consulting - 2021-01-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-10-25	1.00	MK Trimner		Original
* 2021-01-13	1.01	Dale Rhoda		Tweak list of variables that hold info
*                                       about previous doses
*******************************************************************************

program define SIA_COVG_04_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP SIA_COVG_04_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		* Confirm that SIA_COVG_01 has been ran
		check_SIA_COVG_01_03DV

		* Open SIA with IDS dataset from establish unique ids
		use "${VCQI_OUTPUT_FOLDER}/SIA_with_ids", clear
		
		* Merge in SIA_COVG_01 dataset to grab got_sia_dose variables
		merge 1:1 respid using "SIA_COVG_01_${ANALYSIS_COUNTER}", keepusing(got_sia_dose) nogen
			
		* Only keep variables needed for analysis
		keep level1id level2id level3id stratumid clusterid respid SIA01 SIA03 ///
		     SIA11 SIA12 HH02 HH04 psweight ///
			 SIA27 SIA28* SIA29 SIA30* SIA31 SIA32* SIA33* got_sia_dose 
			 
		rename HH02 stratum_name
		rename HH04 cluster_name

		save "${VCQI_OUTPUT_FOLDER}/SIA_COVG_04_${ANALYSIS_COUNTER}", replace

		vcqi_global SIA_COVG_04_TEMP_DATASETS $SIA_COVG_04_TEMP_DATASETS SIA_COVG_04_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
