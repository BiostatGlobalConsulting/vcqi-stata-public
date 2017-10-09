*! DESC_01_01PP version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-11-28 	1.01	-Dale 			-Added line to generate register_has_dates in the TT dataset
*                   					if TT_RECORDS_NOT_SOUGHT is 1
* 2016-02-13	1.02	Dale Rhoda		Make list of temp datasets 
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define DESC_01_01PP
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_01_01PP
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		* This program does prep work with a number of datasets to assemble the
		* variables needed to summarize the survey dataset

		* Make dataset with got_register variable in it
		if "$DESC_01_DATASET" == "TT" {
			use "$VCQI_OUTPUT_FOLDER/TT_with_ids", clear
			if $TT_RECORDS_NOT_SOUGHT == 1 gen register_has_dates = 0
			keep TT01 TT03 TT11 TT12 register_has_dates
			rename register_has_dates got_register
			rename TT01 HM01
			rename TT03 HM03
			rename TT11 HM09
			rename TT12 HM22
			save "$VCQI_OUTPUT_FOLDER/DESC_01_TT_got_register", replace
			vcqi_global DESC_01_TEMP_DATASETS $DESC_01_TEMP_DATASETS DESC_01_TT_got_register

		}

		if "$DESC_01_DATASET" == "RI" {
			use "${VCQI_OUTPUT_FOLDER}/RI_with_ids", clear
			keep RI01 RI03 RI11 RI12 no_register
			rename RI01 HM01
			rename RI03 HM03
			rename RI11 HM09
			rename RI12 HM22
			gen got_register = (no_register == 0)
			drop no_register
			save "$VCQI_OUTPUT_FOLDER/DESC_01_RI_got_register", replace
			vcqi_global DESC_01_TEMP_DATASETS $DESC_01_TEMP_DATASETS DESC_01_RI_got_register
		}

		if "$DESC_01_DATASET" == "SIA" {
			use "$VCQI_OUTPUT_FOLDER/SIA_with_ids", clear
			keep SIA01 SIA03 SIA11 SIA12 
			rename SIA01 HM01
			rename SIA03 HM03
			rename SIA11 HM09
			rename SIA12 HM22
			gen got_register = 0
			save "$VCQI_OUTPUT_FOLDER/DESC_01_SIA_got_register", replace
			vcqi_global DESC_01_TEMP_DATASETS $DESC_01_TEMP_DATASETS DESC_01_SIA_got_register
		}	


		use "${VCQI_DATA_FOLDER}/${VCQI_HH_DATASET}", clear

			* drop records for unoccupied structures
			drop if HH12 != 1

			sort HH01 HH03 HH14
			egen hhid =group(HH01 HH03 HH14)

			keep HH01 HH03 HH14 hhid HH18 HH23 HH24 HH25 
			* HH18 = resident or neighbor
			* HH23 = # eligible for RI
			* HH24 = # eligible for TT
			* HH25 = # eligible for SIA
			
			rename HH23 RI_eligible_in_hh
			rename HH24 TT_eligible_in_hh
			rename HH25 SIA_eligible_in_hh
			
			keep HH01 HH03 HH14 hhid HH18 ${DESC_01_DATASET}_eligible_in_hh

			* This dataset has one row per HH
		save "$VCQI_OUTPUT_FOLDER/DESC_01_HH_DATASET", replace		
		vcqi_global DESC_01_TEMP_DATASETS $DESC_01_TEMP_DATASETS DESC_01_HH_DATASET

		use "${VCQI_DATA_FOLDER}/${VCQI_HM_DATASET}", clear

			sort HM01 HM03 HM09 
			egen hhid = group(HM01 HM03 HM09)

			keep HM01 HM03 HM09 hhid HM19 HM20 HM21 HM22 HM27 HM29 ///
				 HM30 HM31 HM32 HM33 HM34 HM35 HM36 ///
				 HM37 HM38 HM39 HM40 HM41 HM42 HM43 HM44 HM45 
			
			gen male = HM27 == 1
			label define male 0 "Female" 1 "Male"
			label values male male
			
			gen HM_disp = HM21
			replace HM_disp = HM20 if missing(HM_disp)
			replace HM_disp = HM19 if missing(HM_disp)
				
			label values HM_disp `: value label HM19'
			
			drop HM19 HM20 HM21
				
			rename HM31 RI_eligible
			rename HM32 RI_selected
			rename HM33 RI_disp1
			rename HM34 RI_disp2
			rename HM35 RI_disp3
				
			rename HM36 TT_eligible
			rename HM37 TT_selected
			rename HM38 TT_disp1
			rename HM39 TT_disp2
			rename HM40 TT_disp3
				
			rename HM41 SIA_eligible
			rename HM42 SIA_selected
			rename HM43 SIA_disp1
			rename HM44 SIA_disp2
			rename HM45 SIA_disp3

			local notRI  TT* SIA*
			local notTT  RI* SIA*
			local notSIA TT* RI*

			drop `not${DESC_01_DATASET}'

			*drop if ${DESC_01_DATASET}_eligible != 1

			gen     survey_disp = ${DESC_01_DATASET}_disp3
			replace survey_disp = ${DESC_01_DATASET}_disp2 if missing(survey_disp)
			replace survey_disp = ${DESC_01_DATASET}_disp1 if missing(survey_disp)

			label values survey_disp `: value label ${DESC_01_DATASET}_disp1'

			rename ${DESC_01_DATASET}_eligible eligible
			rename ${DESC_01_DATASET}_selected selected
			drop *disp1 *disp2 *disp3
				
			* This dataset has one row per HH member who was eligible for the survey
		save "$VCQI_OUTPUT_FOLDER/DESC_01_HM_DATASET", replace
		vcqi_global DESC_01_TEMP_DATASETS $DESC_01_TEMP_DATASETS DESC_01_HM_DATASET

		use "$VCQI_OUTPUT_FOLDER/DESC_01_HH_DATASET", clear

		merge 1:m hhid using "$VCQI_OUTPUT_FOLDER/DESC_01_HM_DATASET", keepusing(HM_disp survey_disp)
			drop _merge

			replace HH18 = . if inlist(HM_disp,1,.) & HH18 == 1

			bysort hhid: keep if _n == 1

			*drop disp
			
		save "$VCQI_OUTPUT_FOLDER/DESC_01_HH_DATASET", replace

		*/

		use "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", clear

			keep HH01 HH03 expected_hh_to_visit urban_cluster province_id
			rename province_id level2id

			* This dataset has one row per cluster
		save "$VCQI_OUTPUT_FOLDER/DESC_01_CM_DATASET", replace

		vcqi_global DESC_01_TEMP_DATASETS $DESC_01_TEMP_DATASETS DESC_01_CM_DATASET
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
