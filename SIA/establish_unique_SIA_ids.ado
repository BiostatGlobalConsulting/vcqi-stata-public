*! establish_unique_SIA_ids version 1.08 - Biostat Global Consulting - 2020-10-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make a list of TT_TEMP_DATASETS
*										to erase later if the users says to
* 2016-09-19	1.02	Dale Rhoda		Only run if VCQI_CHECK_INSTEAD_OF_RUN
*										is not 1
* 2017-06-07	1.03	MK Trimner		Removed code that makes level3 dataset
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2019-08-23	1.06	Dale Rhoda		Keep CM rows that do not match the
*										dataset (for DOF purposes)
* 2019-12-04	1.07	Dale Rhoda		Set clusterid and stratumid if we have
* 										clusters with no respondents
* 2020-10-13	1.08	Dale Rhoda		Use clonevar instead of gen for rare
*                                       RI03 of type double
*******************************************************************************

program define establish_unique_SIA_ids
	version 14.1
	
	local oldvcp $VCP
	global VCP establish_unique_SIA_ids
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
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
			vcqi_global SIA_TEMP_DATASETS $SIA_TEMP_DATASETS level2namesforlevel3 
			
			* now add ID variables to the SIA household interview dataset
			use "${VCQI_DATA_FOLDER}/${VCQI_SIA_DATASET}", clear

			save "${VCQI_OUTPUT_FOLDER}/SIA_with_ids", replace
			
			vcqi_global SIA_TEMP_DATASETS $SIA_TEMP_DATASETS SIA_with_ids
			
			gen stratumid = SIA01

			egen clusterid = group(SIA01 SIA03)

			egen hhid = group(SIA01 SIA03 SIA11)

			egen respid = group(SIA01 SIA03 SIA11 SIA12)

			clonevar HH01 = SIA01
			clonevar HH03 = SIA03

			merge m:1 HH01 HH03 using "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", keepusing(urban_cluster psweight_sia province_id HH04 HH02)
			*keep if _merge == 1 | _merge == 3
			* We want to keep clusters that do not appear in the dataset, for purposes of calculating degrees of freedom.
			* Be sure to set their weight to zero so they are included properly in the calculations.
			* Note that all outcomes will be missing for these respondents, so they will not affect point estimates, but their
			* presence will help make the DOF calculation right.
			replace psweight_sia = 0 if _merge == 2
			replace SIA01 = HH01 if _merge == 2
			replace stratumid = HH01 if _merge == 2
			capture gen SIA02 = ""
			capture replace SIA02 = HH02 if _merge == 2
			replace SIA03 = HH03 if _merge == 2
			replace clusterid = HH03 if _merge == 2
			capture gen SIA04 = ""
			capture replace SIA04 = HH04 if _merge == 2
			replace SIA11 = "1" if _merge == 2
			replace SIA12 = 1 if _merge == 2
			drop _merge

			gen level1id = 1
			gen level2id = province_id
			gen level3id = SIA01	
			
			rename psweight_sia psweight
			
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

		}	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
