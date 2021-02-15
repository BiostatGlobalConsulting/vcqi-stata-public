*! establish_unique_RI_ids version 1.10 - Biostat Global Consulting - 2021-02-14
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Make a list of RI_TEMP_DATASETS
*										to erase later if the users says to
* 2016-09-19	1.02	Dale Rhoda		Only run if VCQI_CHECK_INSTEAD_OF_RUN
*										is not 1
* 2017-02-17	1.03	Dale Rhoda		Use RI03 for clusterid if it is 
*										already unique within RI01; otherwise
*										make a new unique clusterid
* 2017-06-07	1.04	MK Trimner		removed code to create level3names dataset
* 2017-08-26	1.05	Mary Prier		Added version 14.1 line
* 2018-01-24	1.06	Dale Rhoda		Merge in the level1name and level3name
*										variables
* 2019-07-17	1.07	Dale Rhoda		Keep CM rows that do not match the
*										dataset (for DOF purposes)
* 2019-10-12	1.08	Dale Rhoda		Fix RI11 type mismatch in 1.07 change
* 2020-10-13	1.09	Dale Rhoda		Use clonevar instead of gen for rare
*                                       RI03 of type double
* 2021-02-14	1.10	Dale Rhoda		tostring RI11 if necessary
*******************************************************************************

program define establish_unique_RI_ids
	version 14.1
	
	local oldvcp $VCP
	global VCP establish_unique_RI_ids
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		if "$VCQI_CHECK_INSTEAD_OF_RUN" != "1" {
		
			* make a little dataset named level2namesforlevel3
			use "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", clear
			keep HH01 province_id
			duplicates drop
			rename HH01 level3id
			rename province_id level2id
			merge m:1 level2id using "$LEVEL2_NAME_DATASET"
			keep if _merge == 1 | _merge == 3
			drop _merge
			rename level2name level2nameforlevel3
			save level2namesforlevel3, replace
			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS level2namesforlevel3

			* now add ID variables to the RI household interview dataset
			use "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}_clean", clear
			
			capture tostring RI11, replace

			save "${VCQI_OUTPUT_FOLDER}/RI_with_ids", replace

			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS RI_with_ids

			clonevar HH01 = RI01
			clonevar HH03 = RI03

			merge m:1 HH01 HH03 using "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", keepusing(urban_cluster psweight_1year province_id HH04 HH02)
			*keep if _merge == 1 | _merge == 3
			* We want to keep clusters that do not appear in the dataset, for purposes of calculating degrees of freedom.
			* Be sure to set their weight to zero so they are included properly in the calculations.
			* Note that all outcomes will be missing for these respondents, so they will not affect point estimates, but their
			* presence will help make the DOF calculation right.
			replace psweight_1year = 0 if _merge == 2
			replace RI01 = HH01 if _merge == 2
			capture gen RI02 = ""
			capture replace RI02 = HH02 if _merge == 2
			replace RI03 = HH03 if _merge == 2
			capture gen RI04 = ""
			capture replace RI04 = HH04 if _merge == 2
			replace RI11 = "1" if _merge == 2
			replace RI12 = 1 if _merge == 2
			drop _merge
			
			rename psweight_1year psweight

			gen stratumid = RI01
			
			* If RI03 is unique within RI01 then we can simply use RI03
			* as the clusterid; otherwise we want to make a unique clusterid
			
			bysort RI01 RI03: gen dropthis1 = _n == 1
			bysort RI03:     egen dropthis2 = total(dropthis1)
			capture assert dropthis2 == 1 
			if _rc == 0 clonevar clusterid = RI03
			else egen clusterid = group(RI01 RI03)
			drop dropthis1 dropthis2

			sort RI01 RI03 RI11
			egen hhid = group(RI01 RI03 RI11)

			egen respid = group(RI01 RI03 RI11 RI12)

			gen level1id = 1
			gen level2id = province_id
			gen level3id = RI01	
			
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
			
			* check for level4 stratifiers and merge them in if necessary
			foreach v in $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST {
				capture confirm variable `v'
				if _rc == 0 noi di as text "The stratifier `v' is already part of the RI dataset."
				else {
					noi di as text "Variable `v' is not in the RI dataset; try to merge from HM"
					capture drop HM01 
					capture drop HM03
					capture drop HM09
					capture drop HM22
					gen HM01 = RI01
					gen HM03 = RI03
					gen HM09 = RI11
					gen HM22 = RI12
					*exit 99
					capture merge 1:1 HM01 HM03 HM09 HM22 using "${VCQI_DATA_FOLDER}/$VCQI_HM_DATASET", keepusing(`v')
					if _rc == 0 {
						keep if _merge == 1 | _merge == 3
						drop _merge
					}
					capture confirm variable `v'
					if _rc == 0 noi di as text "Variable `v' found in HM dataset"
					else {
						noi di as text "Trying to merge from HH"
						capture drop HH01
						capture drop HH03
						capture drop HH14
						rename HM01 HH01
						rename HM03 HH03 
						rename HM09 HH14
						capture merge m:1 HH01 HH03 HH14 using "${VCQI_DATA_FOLDER}/$VCQI_HH_DATASET", keepusing(`v')
						if _rc == 0 {
							keep if _merge == 1 | _merge == 3
							drop _merge
						}
					}
					capture confirm variable `v'
					if _rc == 0 noi di as text "Variable `v' found in HH dataset"
					else {
						noi di as text "Trying to merge from CM"
						capture merge m:1 HH01 HH03 using "${VCQI_DATA_FOLDER}/$VCQI_CM_DATASET", keepusing(`v')
						if _rc == 0 {
							keep if _merge == 1 | _merge == 3
							drop _merge
						}
					}
					capture confirm variable `v'
					if _rc == 0 noi di as text "Variable `v' found in CM dataset"
					else noi di as text "Did not merge `v' onto RI dataset"
				}
			}
			capture drop HM01 
			capture drop HM03 
			capture drop HM09 
			capture drop HM22
			capture drop HH01
			capture drop HH03
			capture drop HH14
			
			compress
			
			save, replace
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
