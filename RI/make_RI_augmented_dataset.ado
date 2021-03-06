*! make_RI_augmented_dataset version 1.14 - Biostat Global Consulting - 2021-01-21
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-10	1.00	MK Trimner		Original version
* 2017-01-30	1.01	Dale Rhoda		Make outputpath optional; add note
* 2017-01-31	1.02	Dale Rhoda		Formatted run-time messages to 
*										screen & cosmetic code edits
* 2017-02-21	1.03	MK Trimner		Added RI_QUAL_12 to RI_LIST
*										Added original RI and RIHC dataset to 
*										augmented dataset
* 2017-02-28	1.04	MK Trimner		Added code to account for if there is no RICH dataset
* 2017-04-25	1.05	MK Trimner		Added comments about syntax to align with User's guide
* 2017-07-19	1.06	MK Trimner		Added code to allow for dups to be spelled with an "e"- noidenticaldupes
* 2017-08-22	1.07	Dale Rhoda		Removed VCQI billboard at end of run
*										(because we usually run this within VCQI)
* 2017-08-26	1.08	Mary Prier		Added version 14.1 line
* 2018-06-27	1.09	MK Trimner		Removed DS_TYPE as not used to show indicator
* 2018-07-31	1.10	MK Trimner		Added code to include levels of variables
* 2018-10-04	1.11	Dale Rhoda		Cleaned up ${LEVEL`v'_NAME_DATASET} merge
* 2018-11-26	1.12	MK Trimner		Added code to include Indicator datasets 
*										that have more than 1 line per person
*										corrected by making these wide RI_QUAL_05
* 2018-12-10	1.13	MK Trimner		Removed RI_COVG_05 as this Indicator
*										is completed at the Cluster level and not
*										Individual
*										Corrected file name and local names so i
* 										is not wiped out incase multiple analysis counters used
* 2021-01-21	1.14	Dale Rhoda		Always use the version of VCQI_RI_DATASET
*                                       that resides in the VCQI_OUTPUT_FOLDER
*******************************************************************************

* This program creates one RI dataset containing the original RI dataset provided in VCQI 
* And all RI Indicator datasets found in the OUTPUTPATH. 

********************************************************************************
* Program Syntax
*
* There are no required inputs for this program to run.
********************************************************************************
* Optional Options:
*
* OUTPUTPATH 	-- format: 			string
*				description:	Folder where you would like the Augmented dataset to be saved.
*				default value:	Current Directory
*
* ANALYSISCOUNTER -- format: 	integer
*               description:	The Analysis Counter is a global that is set when you run VCQI. 
*								This program will look in the OUTPUTpath for VCQI datasets with the ANALYSIScounter suffix. 
*								Enter in the highest ANALYSIScounter you used for this VCQI dataset 
*								if you would like it to be part of the augmented dataset.  
* 				default value:	5
*				note1: 			If the Analysis Counter is greater than 5 this will need to be populated.
*
* NOIDENTICALDUPS -- format: 	noidenticaldups	
*               description:	Variables are used across VCQI Indicators. 
*								This option allows the user to delete any repeated variables that contain the same value.
*		        default value:	BLANK
*				note1: 			If not specified, duplicate variables will be kept.
* 
* NOERASE 		-- format: 		noerase
*				description:	Datasets are created for each VCQI variable to determine if it is a unique variable and 
*								if there are conflicting values. This option determines if these datasets are kept. 				
*		       	default value:	BLANK
*       	   	note1: 			If not specified, the datasets are deleted.
********************************************************************************
* General Notes:
* This program uses the VCQI temp datasets. 
*
* There are two ways you can run this program:
*
* 1. During RI Control Program by placing the program sytax before vcqi_cleanup. 
* 2. Separate from VCQI Control Program. This requires that vcqi_global DELETE_TEMP_VCQI_DATASETS be set to 0 to save the temp datasets.
*
* This program can only be ran on RI Indicators that result in a dataset with a single line per person. 
* RI_COVG_05 will not be included.
*
********************************************************************************

program define make_RI_augmented_dataset
	version 14.1
	
	syntax  , [ OUTPUTpath(string asis) ANALYSIScounter(integer 5) noidenticaldups noidenticaldupes noerase]
	
	quietly {
	
		set more off
		
		* Set local to allow for either spelling of dups
		if "`identicaldupes'" != "" local identicaldups "noidenticaldups"
		
		* This program will be used to take the individual indicator datasets to make 
		* one large VCQI dataset

		* Note: Be sure to change the vcqi_global DELETE_TEMP_VCQI_DATASETS to 0 so the datasets are saved

		* Set directory to be where the VCQI DATASETS are located
		if "`outputpath'" != "" cd `"`outputpath'"'

		* Setup global RILIST to contain all indicators that could have been run...
		* Note: Anytime a new RI indicator is created it will need to be added to this list
		* Note: This program will only work for indicators where the dataset has 1 row per person
		* RI_COVG_05 is an indicator completed at the Cluster level and 
		* is not included in the augmented dataset
		
		global RILIST RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04 ///
					  RI_ACC_01  RI_CONT_01 RI_QUAL_01 RI_QUAL_02 ///
					  RI_QUAL_03 RI_QUAL_04 RI_QUAL_06 RI_QUAL_07 RI_QUAL_07B ///
					  RI_QUAL_08 RI_QUAL_09 RI_QUAL_12 RI_QUAL_13 
							
		******************************************************************************** 
		******************************************************************************** 
		******************************************************************************** 
		******************************************************************************** 
		* Delete dataset if it already existis
		capture confirm file "RI_augmented_dataset.dta"
		if !_rc erase "RI_augmented_dataset.dta"
		
		* First step is to check to see which RI VCQI datasets have been created...
		* Note this will NOT capture any DESC of COVG DIFF datasets

		* Begin by making a file list of all applicable datasets					
		local filelist 
		foreach v in $RILIST {
			* Check to see if there are files with multiple analysis counters
			forvalues i =1/`analysiscounter' {
			* Confirm which datasets exist and add them to the filelist
				quietly capture confirm file `v'_`i'.dta
				if !_rc local filelist `filelist' `v'_`i'
			}
		}
		
		* Now we will check to see if the Indicators that create multiple rows per
		* person were ran.
		* If they were, reshape so there is only 1 row per person
		check_multi_row_indicators, analysiscounter(`analysiscounter') filelist(`filelist')
				
		* For all datasets, create a local with the varlist and with dataset name to be used later on
		forvalues i = 1/`=wordcount("`filelist'")' {
		
			local fileuse `=word("`filelist'",`i')' 

			use "`fileuse'", clear
			sort respid stratumid clusterid
			
			* Save a copy of the dataset file that will be edited with any variable renames
			save "VCQI_ADS_`fileuse'", replace
				
			foreach v of varlist * {
				local VARLIST_`fileuse' `VARLIST_`fileuse'' `v' 
				
				* Create chars with varname, analysis counter and RI indicator
				char `v'[Varname] `v'
				char `v'[Analysiscounter] `=substr("`fileuse'",-1,.)'
				char `v'[Indicator] `=substr("`fileuse'",1,length("`fileuse'")-2)'
				
				* add a note so the user will think to look at chars
				note `v': Type <char list> to view augmented dataset characteristics.
			}
			
			save "VCQI_ADS_`fileuse'", replace
		}


		* Start the dataset with the original RI dataset provided in VCQI
	
		* Merge in the RIHC dataset it it exists
		* Open the RIHC dataset and rename Stratum, Cluster, HH and childid for merging purposes
		if "$VCQI_RIHC_DATASET" !="" {
			use "${VCQI_DATA_FOLDER}/${VCQI_RIHC_DATASET}", clear
			rename RIHC01 RI01
			rename RIHC03 RI03
			rename RIHC14 RI11
			rename RIHC15 RI12
			
			* Merge with RI dataset
			merge 1:1 RI01 RI03 RI11 RI12 using "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}", update nogen
		}
		
		else if "$VCQI_RIHC_DATASET" == "" {
			use "${VCQI_OUTPUT_FOLDER}/${VCQI_RI_DATASET}", clear
		}
		
		save "RI_augmented_dataset", replace
		
		* If the levels of datasets are defined, add the variables to the dataset
		* Do this from the RI_with_ids dataset
		* create a keep list first
		local keep
		if $SHOW_LEVEL_1_ALONE == 1 | $SHOW_LEVELS_1_4_TOGETHER == 1 local keep level1id
		if $SHOW_LEVEL_2_ALONE == 1 | $SHOW_LEVELS_2_4_TOGETHER == 1 | $SHOW_LEVELS_2_3_4_TOGETHER == 1 local keep `keep' level2id
		if $SHOW_LEVEL_3_ALONE == 1 | $SHOW_LEVELS_2_3_TOGETHER == 1 | $SHOW_LEVELS_3_4_TOGETHER == 1 | $SHOW_LEVELS_2_3_4_TOGETHER == 1 local keep `keep' level3id
		if "$VCQI_LEVEL4_SET_VARLIST" != "" local keep `keep' $VCQI_LEVEL4_SET_VARLIST
		
		merge 1:1 RI01 RI03 RI11 RI12 using "RI_with_ids", keepusing(`keep') nogen
		save "RI_augmented_dataset", replace
		
		* Now pull in all the names associated with them for levels 1/3
		* Remove the level4 variables and the word "level" and "id"
		local keep `=subinstr("`keep'","$VCQI_LEVEL4_SET_VARLIST","",.)'
		local keep `=subinstr("`keep'","level","",.)'
		local keep `=subinstr("`keep'","id","",.)'
	
		* For any levels 1-3, we need to pull in the names that go with the id
		foreach v in `keep' {
			merge m:1 level`v'id using "${LEVEL`v'_NAME_DATASET}", nogen
			order level`v'name, after(level`v'id)
			save "RI_augmented_dataset", replace
		}
				
		*Merge together with the first file in RI_LIST
		merge 1:1 RI01 RI03 RI11 RI12 using "VCQI_ADS_`=word("`filelist'",1)'", update nogen
	
		* Save as the augmented dataset for merging purposes
		save "RI_augmented_dataset", replace

		* Next compare the varlists for each dataset and create one large varlist  
		* Set the variables as the varlist and dstype from first dataset	
		local VARLIST `VARLIST_`=word("`filelist'",1)''

		* Foreach variable, post the variable and message about variable to log
		capture postclose vcqiadsvarlist
		postfile vcqiadsvarlist str500 (variable dataset analysis_counter message new_var_name) using vcqi_ads_logfile, replace

		foreach v in `VARLIST' {
			post vcqiadsvarlist("`v'") ("``v'[Indicator]'") ("``v'[Analysiscounter]'") ("Variable added to varlist from this dataset") ("")
		}

		*Compare the remaining datasets varlists and values 
		local dup 0
		forvalues i = 2/`=wordcount("`filelist'")' {
			local fn `=word("`filelist'",`i')'
			foreach u in `VARLIST_`fn'' {
				if strpos("`VARLIST'","`u' ") >= 1 {
				
					noi di as text "`fn': Match for `u'..." _continue
				
					* Create two small datasets with specified variable and the identifiers to compare values
					use "RI_augmented_dataset", clear
					keep respid clusterid stratumid `u'			
					
					* Save as a new name
					save "RI_augmented_dataset_`i'_`u'", replace
					
					use "VCQI_ADS_`fn'", clear
					keep respid stratumid clusterid `u'	
					
					* If the specified variable is an identifying variable, create a clone variable
					if inlist("`u'","respid", "stratumid", "clusterid") {
						clonevar `=substr("`u'_`fn'",1,32)'=`u'
						save "VCQI_ADS_`fn'_`i'_`u'", replace
					}
					
					else {
						rename `u' `=substr("`u'_`fn'",1,32)'
						save "VCQI_ADS_`fn'_`i'_`u'", replace
					}
					
					* Merge the two datasets together
					merge 1:1 respid clusterid stratumid using "RI_augmented_dataset_`i'_`u'"
					save "COMPARISON_VCQI_ADS_`fn'_`i'_`u'", replace
						
					* Confirm the values of the specified variable match
					capture assert `u'==`=substr("`u'_`fn'",1,32)' 
					
					* If the values match, no action is needed other than to post in the log...
					if _rc!=9 {
					
						noi di as text "found identical values."

						* Increase the local dup by 1 for first dup variable found
						if `dup'==0 local dup 1
			
						use "VCQI_ADS_`fn'", clear
						
						if inlist("`u'","respid", "stratumid", "clusterid") {
							clonevar ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'=`u'
							* Add unique characteristic for variable
							char ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'[Unique] "Duplicate with identical values"
							local VARLIST `VARLIST' ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'
							save , replace
						}
						else {
							rename `u' ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'
							* Add unique characteristic for variable
							char ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'[Unique] "Duplicate with identical values"

							local VARLIST `VARLIST' ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'
							save , replace
						}
						
						* Post to log what happened
						post vcqiadsvarlist("`u'") ("`ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'[Indicator]'") ("`ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'[Analysiscounter]'") ("Variable existed in previous dataset(s) but had no conflicting values") ("ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'")
					
						* Increase the dup variable each time there is a dup variable
						local ++dup

					}
					
					* If values differ, then the new variable will need to be renamed and added to the varlist
					if _rc==9 {

						noi di as text "found some differences."
					
						* Increase the local dup by 1 for first dup variable found
						if `dup'==0 local dup 1
					
						use "VCQI_ADS_`fn'", clear
											
						* Rename the variable so it can be merged
						* If the variable is an identifying variable, a clone will need to be created rather than renaming
						if inlist("`u'","respid", "stratumid", "clusterid") {
							clonevar ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'=`u'
							char ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'[Unique] "Duplicate with different values"
							
							* Add variable to VARLIST local 
							local VARLIST `VARLIST' ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'

							save, replace
						}
								
						else {
							rename `u' ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'
							char ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'[Unique] "Duplicate with different values"

							* Add variable to VARLIST local 
							local VARLIST `VARLIST' ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'

							save, replace
						}
				
						* Post to the log
						post vcqiadsvarlist("`u'") ("`ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'[Indicator]'") ("`ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'[Analysiscounter]'") ("Variable existed in previous dataset(s) with conflicting values") ("ADS_DUPVAR_`dup'_`=substr("`fn'",1,length("`fn'")-2)'")
		
						* Increase the dup variable each time there is a dup variable
						local ++dup 
					}		
									
					* If l is set to erase comparison datasets, erase them...
					if "`erase'" == "" {
						erase "RI_augmented_dataset_`i'_`u'.dta" 
						erase "VCQI_ADS_`fn'_`i'_`u'.dta"
						erase "COMPARISON_VCQI_ADS_`fn'_`i'_`u'.dta"
					}
				}
				
				* If the variable does not exist in any previous datasets, add it to the augmented log and post
				else if strpos("`VARLIST'","`u' ") == 0 {

					noi di as text "`fn': `u' is unique so far."
				
					local VARLIST `VARLIST' `u'
						
					* log to file
					post vcqiadsvarlist("`u'") ("``u'[Indicator]'") ("``u'[Analysiscounter]'") ("Variable added to varlist from this dataset") ("")

				}	
			}
					
			* Merge file with new variables to original file to form an augmented dataset
			use RI_augmented_dataset, clear
			merge 1:1 respid stratumid clusterid using "VCQI_ADS_`fn'", update nogen
			save RI_augmented_dataset, replace
			
		}	
		postclose vcqiadsvarlist	

		* Erase all copies of datasets
		foreach v in `filelist' {
			erase "VCQI_ADS_`v'.dta"
		}
		
		* drop any variables that are not unique per user's instructions
		if "`identicaldups'"!="" {
		
			noi di as text "Dropping variables that are duplicates with identical values, per user's instruction."
			
			use RI_augmented_dataset, clear
			local droplist 
			foreach v of varlist * {
				if "``v'[Unique]'"=="Duplicate with identical values" ///
					local droplist `droplist' `v'
			}
			
			if "`droplist'"!="" {
				noi di as text "Dropping `droplist'"
				drop `droplist'
			}
			else {
				noi di as text "No duplicate variables to drop"
			}
			save, replace
		}
			
		* Compress dataset
		compress
		save, replace	
		
		* Compress the log file
		qui use vcqi_ads_logfile, clear
		compress
		save, replace
	
	}
	
	di as text ""
	di as text "VCQI Augmented Dataset Program identified `dup' variables that had conflicting values between the VCQI indicator datasets."
	di as text "Please reference the log: vcqi_ads_logfile.dta for details."
	di as text ""
	
	di as text "VCQI Augmented Dataset was saved as RI_augmented_dataset.dta".

	di as text ""


end

capture program drop check_multi_row_indicators
program define check_multi_row_indicators

	syntax , analysiscounter(int) filelist(string asis)

	* Check to see if there are files with multiple analysis counters
	forvalues i =1/`analysiscounter' {
	* Confirm which datasets exist and add them to the filelist
		quietly capture confirm file RI_QUAL_05_`i'.dta
			if !_rc {
									
				* Open dataset
				use RI_QUAL_05_`i', clear
				
				if "${RI_QUAL_05_DOSE_NAME}"=="" ///
				global RI_QUAL_05_DOSE_NAME `=lower("`=substr(early_dose[1],1,length(early_dose[1])-1)'")'
				
				if "${RI_QUAL_05_INTERVAL_THRESHOLD}"=="" {
					local z 0
					foreach v of varlist * {
						if "`z'" == "0" {
							if `=strpos("`v'","short_interval")' > 0 local z "`v'"
						}
					}
					global RI_QUAL_05_INTERVAL_THRESHOLD `=substr("`z'",length("`z'")-3,2)' 
					global RI_QUAL_05_INTERVAL_THRESHOLD `=subinstr("$RI_QUAL_05_INTERVAL_THRESHOLD","_","",.)'
				}
				
				* Set local with first letter of dose name
				local p `=lower("`=substr("${RI_QUAL_05_DOSE_NAME}",1,1)'")'
				
				* Create variable that combines early and later dose
				gen dose_combo = ""
				forvalues n = 1/`=_N' {
					replace dose_combo = "_`p'`=substr(early_dose[`n'], -1,1)'_`p'`=substr(later_dose[`n'], -1,1)'" in `n'
				}
				
				* Drop early and later doses as these throw off reshape
				drop early_dose later_dose
				
				* Reshape so there is one row per person
				* pull the dose name in lower case
				local p `=lower("${RI_QUAL_05_DOSE_NAME}")'
			
				reshape wide card_interval_days register_interval_days ///
				short_interval_`p'_${RI_QUAL_05_INTERVAL_THRESHOLD}_c ///
				short_interval_`p'_${RI_QUAL_05_INTERVAL_THRESHOLD}_r ///
				short_interval_`p'_${RI_QUAL_05_INTERVAL_THRESHOLD}, ///
				i(respid) j(dose_combo) string
				
				save "RI_QUAL_05_wide_`i'", replace
				
				* Add to file list
				local filelist `filelist' RI_QUAL_05_wide_`i'
				global RILIST $RILIST RI_QUAL_05_wide
				
				c_local filelist `filelist'	
		}
	}

end
