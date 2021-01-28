*! RI_COVG_01_01PP version 1.05 - Biostat Global Consulting - 2020-12-18
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make list of temp datasets 
* 2017-01-12	1.02	Dale Rhoda		Keep age_at_interview
* 2017-01-31	1.03	Dale Rhoda		Added VCQI_LEVEL4_SET_VARLIST
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2020-12-18	1.05	MK Trimner		Added capture gen bcg_scar_history
*										as missing if not part of dataset
*******************************************************************************

program define RI_COVG_01_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_01_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"

	qui use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear

	*this program assumes dates and tick marks have been cleaned upstream
	
	* keep only the variables that pertain to evidence of vaccination
	* for those doses being analyzed
	
	local dlist	
	foreach d in `=lower("$RI_DOSE_LIST")' {
		local dlist `dlist' `d'_card_date `d'_register_date `d'_card_tick `d'_register_tick `d'_history
	
		if "`d'" == "bcg" {
		    local dlist `dlist' bcg_scar_history
			capture confirm var bcg_scar_history 
			if _rc != 0 {
			    gen bcg_scar_history = .
				label var bcg_scar_history "Created as empty for VCQI purposes"
			}
		}		
	}
		
	keep level1id level2id level3id stratumid clusterid respid RI01 RI03 RI11 RI12  ///
	     HH02 HH04 psweight $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST ///
		 `dlist' no_card age_at_interview
		 
	qui save "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}", replace

	vcqi_global RI_COVG_01_TEMP_DATASETS $RI_COVG_01_TEMP_DATASETS RI_COVG_01_${ANALYSIS_COUNTER}

	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
