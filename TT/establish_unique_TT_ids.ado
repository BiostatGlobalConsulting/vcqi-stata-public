*! establish_unique_TT_ids version 1.02 - Biostat Global Consulting - 2015-09-20
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make a list of TT_TEMP_DATASETS
*										to erase later if the users says to
* 2016-09-20	1.02	Dale Rhoda		Run only if VCQI_CHECK_INSTEAD_OF_RUN
*										is not 1
*******************************************************************************

program define establish_unique_TT_ids

	version 14
	local oldvcp $VCP
	global VCP establish_unique_TT_ids
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	if "$VCQI_CHECK_INSTEAD_OF_RUN" != "1" {
	
		* make a little dataset named level3names
		use "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", clear
		keep HH01 HH02
		duplicates drop
		rename HH01 level3id
		rename HH02 level3name
		save level3names, replace	
		vcqi_global TT_TEMP_DATASETS $TT_TEMP_DATASETS level3names
		
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

		gen HH01 = TT01
		gen HH03 = TT03

		merge m:1 HH01 HH03 using "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", keepusing(urban_cluster psweight_1year province_id HH04 HH02)
		keep if _merge == 1 | _merge == 3
		drop _merge

		gen level1id = 1
		gen level2id = province_id
		gen level3id = TT01	
		
		* obtain province names from a small dataset for that purpose
		merge m:1 level2id using "${LEVEL2_NAME_DATASET}"
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
			keep if _merge == 1 | _merge == 3
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
