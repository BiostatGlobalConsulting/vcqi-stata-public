*! establish_unique_TT_ids version 1.09 - Biostat Global Consulting - 2020-10-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make a list of TT_TEMP_DATASETS
*										to erase later if the users says to
* 2016-09-20	1.02	Dale Rhoda		Run only if VCQI_CHECK_INSTEAD_OF_RUN
*										is not 1
* 2017-06-07	1.03	MK Trimner		Remove code that creates level3names dataset
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2019-07-17	1.05	Dale Rhoda		Keep CM rows that do not match the
*										dataset (for DOF purposes)
* 2019-10-12	1.06	Dale Rhoda		Fix TT11 type mismatch in 1.05
* 2019-12-04	1.07	Dale Rhoda		Set stratumid and clusterid if we have 
*										clusters with no respondents
* 2020-05-14	1.08	Dale Rhoda		Fix TTHC14 type mismatch in 1.05
* 2020-10-13	1.09	Dale Rhoda		Use clonevar instead of gen for rare
*                                       RI03 of type double
*******************************************************************************

program define establish_unique_TT_ids
	version 14.1
	
	local oldvcp $VCP
	global VCP establish_unique_TT_ids
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	if "$VCQI_CHECK_INSTEAD_OF_RUN" != "1" {
	
		* make a little dataset named level2namesforlevel3
		use "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", clear
		keep HH01 province_id
		duplicates drop
		rename HH01 level3id
		rename province_id level2id
		merge m:1 level2id using "${LEVEL2_NAME_DATASET}"
		keep if _merge == 1 | _merge == 3
		drop _merge
		rename level2name level2nameforlevel3
		save level2namesforlevel3, replace
		vcqi_global TT_TEMP_DATASETS $TT_TEMP_DATASETS level2namesforlevel3

		* now add ID variables to the TT household interview dataset
		use "${VCQI_DATA_FOLDER}/${VCQI_TT_DATASET}", clear

		save "${VCQI_OUTPUT_FOLDER}/TT_with_ids", replace
		vcqi_global TT_TEMP_DATASETS $TT_TEMP_DATASETS TT_with_ids

		gen stratumid = TT01
		
		sort TT01 TT03 TT11 TT12
		
		egen clusterid = group(TT01 TT03)

		egen hhid = group(TT01 TT03 TT11)

		egen respid = group(TT01 TT03 TT11 TT12)

		clonevar HH01 = TT01
		clonevar HH03 = TT03

		merge m:1 HH01 HH03 using "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", keepusing(urban_cluster psweight_1year province_id HH04 HH02)
		*keep if _merge == 1 | _merge == 3
		* We want to keep clusters that do not appear in the dataset, for purposes of calculating degrees of freedom.
		* Be sure to set their weight to zero so they are included properly in the calculations.
		* Note that all outcomes will be missing for these respondents, so they will not affect point estimates, but their
		* presence will help make the DOF calculation right.
		replace psweight_1year = 0 if _merge == 2
		replace TT01 = HH01 if _merge == 2
		replace stratumid = HH01 if _merge == 2
		capture gen TT02 = ""
		capture replace TT02 = HH02 if _merge == 2
		replace TT03 = HH03 if _merge == 2
		replace clusterid = TT03 if _merge == 2
		capture gen TT04 = ""
		capture replace TT04 = HH04 if _merge == 2
		replace TT11 = "1" if _merge == 2
		replace TT12 = 1 if _merge == 2
		drop _merge

		gen level1id = 1
		gen level2id = province_id
		gen level3id = TT01	
		
		* obtain level1 names from a small dataset for that purpose
		merge m:1 level1id using "$LEVEL1_NAME_DATASET"
		keep if _merge == 1 | _merge == 3
		drop _merge
		
		* obtain province names from a small dataset for that purpose
		merge m:1 level2id using "$LEVEL2_NAME_DATASET"
		keep if _merge == 1 | _merge == 3
		drop _merge
		
		* obtain stratum names from a small dataset for that purpose
		merge m:1 level3id using "$LEVEL3_NAME_DATASET"
		keep if _merge == 1 | _merge == 3
		drop _merge
			
		save, replace

		* add IDs to registry data, if present
		*
		* Be careful to use the same IDs that were established in the TT dataset
		* rather than construct new, possibly conflicting IDs
		
		if $TT_RECORDS_NOT_SOUGHT != 1 {
			
			use "${VCQI_DATA_FOLDER}/${VCQI_TTHC_DATASET}", clear
			
			gen TT01 = TTHC01
			gen TT03 = TTHC03
			gen TT11 = TTHC14
			gen TT12 = TTHC15
			
			merge 1:1 TT01 TT03 TT11 TT12 using "${VCQI_OUTPUT_FOLDER}/TT_with_ids", ///
					  keepusing(level1id level2id level3id stratumid ///
					  clusterid hhid respid level2name)
					  
			* do not keep kids in register dataset only...we only keep them if they 
			* had a household interview
			keep if _merge == 2 | _merge == 3
			drop _merge

			gen HH01 = TTHC01
			gen HH03 = TTHC03

			merge m:1 HH01 HH03 using "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", keepusing(urban_cluster psweight_1year province_id)
			*keep if _merge == 1 | _merge == 3
			* We want to keep clusters that do not appear in the dataset, for purposes of calculating degrees of freedom.
			* Be sure to set their weight to zero so they are included properly in the calculations.
			* Note that all outcomes will be missing for these respondents, so they will not affect point estimates, but their
			* presence will help make the DOF calculation right.
			replace psweight_1year = 0 if _merge == 2
			replace TTHC01 = HH01 if _merge == 2
			capture gen TTHC02 = ""
			capture replace TTHC02 = HH02 if _merge == 2
			replace TTHC03 = HH03 if _merge == 2
			capture gen TTHC04 = ""
			capture replace TTHC04 = HH04 if _merge == 2
			replace TTHC14 = "1" if _merge == 2
			replace TTHC15 = 1 if _merge == 2
			drop _merge

			drop TT01 TT03 TT11 TT12 HH01 HH03
			
			rename psweight_1year psweight
			
			gen register_has_dates = 0
			forvalues i = 21/26 {
				replace register_has_dates = 1 if !missing(TTHC`i')
			}
			label variable register_has_dates "TT HC record has at least one TT vaccination date on it"
			
			save "${VCQI_OUTPUT_FOLDER}/TTHC_with_ids", replace
			vcqi_global TT_TEMP_DATASETS $TT_TEMP_DATASETS TTHC_with_ids
			
			use "${VCQI_OUTPUT_FOLDER}/TT_with_ids", clear
			merge 1:1 respid using "${VCQI_OUTPUT_FOLDER}/TTHC_with_ids", keepusing(register_has_dates) nogen
			save, replace

		}

	}	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
