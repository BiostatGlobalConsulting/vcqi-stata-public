*! establish_unique_RI_ids version 1.02 - Biostat Global Consulting - 2016-09-19
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
*******************************************************************************

program define establish_unique_RI_ids

	local oldvcp $VCP
	global VCP establish_unique_RI_ids
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		if "$VCQI_CHECK_INSTEAD_OF_RUN" != "1" {
		
			* make a little dataset named level3names
			use "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", clear
			keep HH01 HH02
			duplicates drop
			rename HH01 level3id
			rename HH02 level3name
			save level3names, replace	
			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS level3names
			
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

			save "${VCQI_OUTPUT_FOLDER}/RI_with_ids", replace

			vcqi_global RI_TEMP_DATASETS $RI_TEMP_DATASETS RI_with_ids

			gen stratumid = RI01
			
			* If RI03 is unique within RI01 then we can simply use RI03
			* as the clusterid; otherwise we want to make a unique clusterid
			
			bysort RI01 RI03: gen dropthis1 = _n == 1
			bysort RI03:     egen dropthis2 = total(dropthis1)
			capture assert dropthis2 == 1 
			if _rc == 0 gen clusterid = RI03
			else egen clusterid = group(RI01 RI03)
			drop dropthis1 dropthis2

			sort RI01 RI03 RI11
			egen hhid = group(RI01 RI03 RI11)

			egen respid = group(RI01 RI03 RI11 RI12)

			gen HH01 = RI01
			gen HH03 = RI03

			merge m:1 HH01 HH03 using "${VCQI_DATA_FOLDER}/${VCQI_CM_DATASET}", keepusing(urban_cluster psweight_1year province_id HH04 HH02)
			keep if _merge == 1 | _merge == 3
			drop _merge
			
			rename psweight_1year psweight

			gen level1id = 1
			gen level2id = province_id
			gen level3id = RI01	
			
			* obtain province names from a small dataset for that purpose
			merge m:1 level2id using "$LEVEL2_NAME_DATASET"
			keep if _merge == 1 | _merge == 3
			drop _merge
			
			* check for level4 stratifiers and merge them in if necessary
			foreach v in $VCQI_LEVEL4_STRATIFIER $VCQI_LEVEL4_SET_VARLIST {
				capture confirm variable `v'
				if _rc == 0 noi di "The stratifier `v' is already part of the RI dataset."
				else {
					noi di "Variable `v' is not in the RI dataset; try to merge from HM"
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
					if _rc == 0 noi di "Variable `v' found in HM dataset"
					else {
						noi di "Trying to merge from HH"
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
					if _rc == 0 noi di "Variable `v' found in HH dataset"
					else {
						noi di "Trying to merge from CM"
						capture merge m:1 HH01 HH03 using "${VCQI_DATA_FOLDER}/$VCQI_CM_DATASET", keepusing(`v')
						if _rc == 0 {
							keep if _merge == 1 | _merge == 3
							drop _merge
						}
					}
					capture confirm variable `v'
					if _rc == 0 noi di "Variable `v' found in CM dataset"
					else noi di "Did not merge `v' onto RI dataset"
				}
			}
			capture drop HM01 
			capture drop HM03 
			capture drop HM09 
			capture drop HM22
			capture drop HH01
			capture drop HH03
			capture drop HH14
			
			save, replace
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
