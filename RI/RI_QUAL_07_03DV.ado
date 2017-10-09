*! RI_QUAL_07_03DV version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_QUAL_07_03DV
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_07_03DV
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		local vc  `=lower("$RI_QUAL_07_VALID_OR_CRUDE")'

		use "${VCQI_OUTPUT_FOLDER}/RI_QUAL_07_${ANALYSIS_COUNTER}", clear

		foreach d in $RI_DOSE_LIST {
			gen valid_`d'_if_no_movs = (got_valid_`d'_to_analyze==1 | flag_uncor_mov_`d'_`vc'==1)

			label variable valid_`d'_if_no_movs "Would have valid `=upper("`d'")' if no MOVs"
		}
		
		save, replace
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
