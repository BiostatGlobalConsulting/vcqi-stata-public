*! RI_QUAL_12_01PP version 1.04 - Biostat Global Consulting - 2017-03-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-02-12	1.02	Dale Rhoda		Make list of temp datasets 
* 2017-01-31	1.03	Dale Rhoda		Reworked to be one row per child
* 2017-03-09	1.04	Dale Rhoda		Remove temp dataset	
*******************************************************************************

program define RI_QUAL_12_01PP

	local oldvcp $VCP
	global VCP RI_QUAL_12_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear
		
		local dlist 
		
		forvalues j = 1/`=wordcount("$RI_QUAL_12_DOSE_PAIR_LIST")' {
			local d1 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
			local dlist `dlist' `d1'_card_date `d1'_register_date
		}
		
		keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
			 HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
			 `dlist' no_card 
		
		save "${VCQI_OUTPUT_FOLDER}/RI_QUAL_12_${ANALYSIS_COUNTER}", replace

		vcqi_global RI_QUAL_12_TEMP_DATASETS $RI_QUAL_12_TEMP_DATASETS RI_QUAL_12_${ANALYSIS_COUNTER}

	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
