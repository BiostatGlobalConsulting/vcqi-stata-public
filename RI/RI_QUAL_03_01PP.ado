*! RI_QUAL_03_01PP version 1.02 - Biostat Global Consulting - 2017-01-31
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.02	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
*******************************************************************************

program define RI_QUAL_03_01PP

	local oldvcp $VCP
	global VCP RI_QUAL_03_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear

		local d `=lower("$RI_QUAL_03_DOSE_NAME")' 

		local dlist	
		foreach s in card register {
			local dlist `dlist' `d'_`s'_date
		}

		keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
				 HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
				 `dlist' dob_for_valid_dose_calculations no_card

		save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_03_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_QUAL_03_TEMP_DATASETS $RI_QUAL_03_TEMP_DATASETS RI_QUAL_03_${ANALYSIS_COUNTER}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

