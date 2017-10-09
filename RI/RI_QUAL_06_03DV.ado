*! RI_QUAL_06_03DV version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Added var label to valid_`d'_before_age1
* 2017-02-01	1.02	Dale Rhoda		Cosmetic changes
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_06_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_06_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_06_${ANALYSIS_COUNTER}", clear

		local d `=lower("$RI_QUAL_06_DOSE_NAME")' 

		gen valid_`d'_before_age1 = valid_`d'_age1_to_analyze if got_valid_`d'_to_analyze == 1
		label variable valid_`d'_before_age1 "Valid `d' received before age 1"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
