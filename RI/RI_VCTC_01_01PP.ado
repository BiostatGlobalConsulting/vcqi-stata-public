*! RI_VCTC_01_01PP version 1.00 - Biostat Global Consulting - 2020-09-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-09-24	1.00	Dale Rhoda		Original version
*******************************************************************************

program define RI_VCTC_01_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_VCTC_01_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	if $VCQI_CHECK_INSTEAD_OF_RUN != 1 {

		quietly {
			
			*Verify RI_COVG_01 & _02 ran
			check_RI_COVG_01_03DV	
			check_RI_COVG_02_03DV
			
			** Also check to see if RI_QUAL_01 ran

			use "${VCQI_OUTPUT_FOLDER}/RI_COVG_02_${ANALYSIS_COUNTER}", clear
			merge 1:1 respid using "${VCQI_OUTPUT_FOLDER}/RI_COVG_01_${ANALYSIS_COUNTER}"
			drop _merge
			merge 1:1 respid using "${VCQI_OUTPUT_FOLDER}/RI_QUAL_01_${ANALYSIS_COUNTER}"
			drop _merge
			merge m:1 respid using RI_with_ids, keepusing(level1name level2name level3name)
			
			* For now we are not facilitating Vx Coverage & Timeliness Charts (VCVCs) for level 4 strata
			
			local dlist 
			
			foreach d in `=lower("$TIMELY_DOSE_ORDER")' {
				local dlist `dlist' age_at_`d'_card got_crude_`d'_to_analyze
				if $RI_RECORDS_NOT_SOUGHT local dlist `dlist' age_at_`d'_register
			}
			
			keep level1id level2id level3id level1name level2name level3name ///
				 stratumid clusterid respid RI01 RI03 RI11 RI12  ///
				 HH02 HH04 psweight $TIMELY_HBR_LINE_VARIABLE `dlist' 

			$VCQI_SVYSET_SYNTAX
			
			save "${VCQI_OUTPUT_FOLDER}/RI_VCTC_01_${ANALYSIS_COUNTER}", replace

			vcqi_global RI_VCTC_01_TEMP_DATASETS $RI_VCTC_01_TEMP_DATASETS RI_VCTC_01_${ANALYSIS_COUNTER}
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
