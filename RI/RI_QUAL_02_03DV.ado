*! RI_QUAL_02_03DV version 1.03 - Biostat Global Consulting - 2019-08-23
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2019-07-17	1.02	Dale Rhoda		Allow RI26 to be missing
* 2019-08-23	1.03	Dale Rhoda		Make outcomes missing if psweight == 0
*******************************************************************************

program define RI_QUAL_02_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_02_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"

	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_02_${ANALYSIS_COUNTER}", clear

		gen ever_had_an_ri_card=(RI26==1) if !missing(RI26) & psweight>0 & !missing(psweight)
		label variable ever_had_an_ri_card "Ever had an RI card"

		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
