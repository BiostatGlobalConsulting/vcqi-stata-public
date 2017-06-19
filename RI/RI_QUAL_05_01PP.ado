*! RI_QUAL_05_01PP version 1.02 - Biostat Global Consulting - 2017-02-01
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-02-01	1.02	Dale Rhoda		Use saved RI_dose_intervals dataset
*******************************************************************************

program define RI_QUAL_05_01PP

	local oldvcp $VCP
	global VCP RI_QUAL_05_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		*Run Dose Interval Program using the RI_with_ids dataset
		RI_dose_intervals
		
		use "${VCQI_OUTPUT_FOLDER}/RI_dose_intervals", clear

		*Only keep specified dose
		local d `=lower("$RI_QUAL_05_DOSE_NAME")' 
		keep if early_dose=="`d'1" | early_dose=="`d'2" 

		save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_05_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_QUAL_05_TEMP_DATASETS $RI_QUAL_05_TEMP_DATASETS RI_QUAL_05_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
