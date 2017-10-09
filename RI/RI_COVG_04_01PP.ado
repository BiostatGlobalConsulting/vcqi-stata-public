*! RI_COVG_04_01PP version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_04_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_04_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		* This analysis uses derived variables that are calculated as part 
		* of RI_COVG_03, so load up the output from that program.
		
		check_RI_COVG_03_03DV
		
		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_03_${ANALYSIS_COUNTER}", clear

		drop fully_vaccinated*
			
		save "${VCQI_OUTPUT_FOLDER}/RI_COVG_04_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_COVG_04_TEMP_DATASETS $RI_COVG_04_TEMP_DATASETS RI_COVG_04_${ANALYSIS_COUNTER}

	}
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
