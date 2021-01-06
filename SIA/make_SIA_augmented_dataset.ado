*! make_SIA_augmented_dataset version 1.03 - Biostat Global Consulting - 2018-07-31
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-10	1.00	MK Trimner		Original version
* 2017-08-22	1.01	Dale Rhoda		Removed VCQI billboard from the end
*										(because we usually run this in VCQI)
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
* 2018-07-31	1.03	MK Trimner		Made changes to align with RI ADS changes
*******************************************************************************

* This program creates one SIA dataset containing the original SIA dataset provided in VCQI 
* And all SIA Indicator datasets found in the OUTPUTPATH. 

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
* 1. During SIA Control Program by placing the program sytax before vcqi_cleanup. 
* 2. Separate from VCQI Control Program. This requires that vcqi_global DELETE_TEMP_VCQI_DATASETS be set to 0 to save the temp datasets.
*
* This program can only be ran on SIA Indicators that result in a dataset with a single line per person. 

********************************************************************************

program define make_SIA_augmented_dataset
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

		* Setup global SIALIST to contain all indicators that could have been run...
		* Note: Anytime a new SIA indicator is created it will need to be added to this list
		* Note: This program will only work for indicators where the dataset has 1 row per person
		
		global SIALIST SIA_COVG_01 SIA_COVG_02 SIA_COVG_03 SIA_COVG_04 SIA_QUAL_01
							
		******************************************************************************** 
		******************************************************************************** 
		******************************************************************************** 
		******************************************************************************** 
		* Delete dataset if it already existis
		capture confirm file "SIA_augmented_dataset.dta"
		if !_rc erase "SIA_augmented_dataset.dta"
		
		* First step is to check to see which SIA VCQI datasets have been created...
		* Note this will NOT capture any DESC of COVG DIFF datasets

		* Begin by making a file list of all applicable datasets					
		local filelist 
		foreach v in $SIALIST {
			* Check to see if there are files with multiple analysis counters
			forvalues i =1/`analysiscounter' {
			* Confirm which datasets exist and add them to the filelist
				quietly capture confirm file `v'_`i'.dta
				if !_rc local filelist `filelist' `v'_`i'
			}
		}
			
				
		* For all datasets, create a local with the varlist and with dataset name to be used later on
		forvalues i = 1/`=wordcount("`filelist'")' {
		
			local fileuse `=word("`filelist'",`i')' 

			use "`fileuse'", clear
			sort respid stratumid clusterid
									
			* Save a copy of the dataset file that will be edited with any variable renames
			save "VCQI_ADS_`fileuse'", replace
				
			foreach v of varlist * {
				local VARLIST_`fileuse' `VARLIST_`fileuse'' `v' 
				
				* Create chars with varname, analysis counter and SIA indicator
				char `v'[Varname] `v'
				char `v'[Analysiscounter] `=substr("`fileuse'",-1,.)'
				char `v'[Indicator] `=substr("`fileuse'",1,length("`fileuse'")-2)'
				
				* add a note so the user will think to look at chars
				note `v': Type <char list> to view augmented dataset characteristics.
			}
			
			save "VCQI_ADS_`fileuse'", replace
		}
		
		* Start the dataset with the original SIA dataset provided in VCQI
		use "${VCQI_DATA_FOLDER}/${VCQI_SIA_DATASET}", clear
				
		save "SIA_augmented_dataset", replace
		
		*Merge together with the first file in SIA_LIST
		merge 1:1 SIA01 SIA03 SIA11 SIA12 using "VCQI_ADS_`=word("`filelist'",1)'", update nogen
		
		* Save as the augmented dataset for merging purposes
		save "SIA_augmented_dataset", replace
		
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
					use "SIA_augmented_dataset", clear
					keep respid clusterid stratumid `u'	
									
					* Save as a new name
					save "SIA_augmented_dataset_`i'_`u'", replace
					
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
					merge 1:1 respid clusterid stratumid using "SIA_augmented_dataset_`i'_`u'"
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
						erase "SIA_augmented_dataset_`i'_`u'.dta" 
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
			use SIA_augmented_dataset, clear
			merge 1:1 respid stratumid clusterid using "VCQI_ADS_`fn'", update nogen
			save SIA_augmented_dataset, replace
			
		}	
		postclose vcqiadsvarlist	

		* Erase all copies of datasets
		foreach v in `filelist' {
			erase "VCQI_ADS_`v'.dta"
		}
		
		* drop any variables that are not unique per user's instructions
		if "`identicaldups'"!="" {
			
			noi di as text "Dropping variables that are duplicates with identical values, per user's instruction."
			
			use SIA_augmented_dataset, clear
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
	
	di as text "VCQI Augmented Dataset was saved as SIA_augmented_dataset.dta".

	di as text ""

end
	
