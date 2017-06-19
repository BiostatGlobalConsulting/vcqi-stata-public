*! RI_QUAL_02_03DV version 1.00 - Biostat Global Consulting - 2015-10-14
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*******************************************************************************
program define RI_QUAL_02_03DV

	local oldvcp $VCP
	global VCP RI_QUAL_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_02_${ANALYSIS_COUNTER}", clear

		gen ever_had_an_ri_card=(RI26==1)
		label variable ever_had_an_ri_card "Ever had an RI card"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
