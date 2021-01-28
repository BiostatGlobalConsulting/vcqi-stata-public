*! aggregate_vcqi_databases 1.08 - Biostat Global Consulting - 2021-01-16
******************************************************************************* 
* Change log 
* 				Updated 
*				version 
* Date 			number 	Name			What Changed 
* 2020-02-04	1.00	MK Trimner		Original
* 2020-02-18	1.01	MK Trimner		Added level orders to be merged into program
* 2020-03-24	1.02	Dale Rhoda		Added special case for new indicator
*                                       RI_QUAL_07B
* 2020-04-15	1.03	MK Trimner		Created two globals with Aggregated and non aggregated databases
* 										If no aggregated indicators were completed the steps are skipped
*										strips the non aggregated databases from VCQI_DATABASES so they are not deleted
* 										Added level4name to varlist checks
* 2020-04-15	1.04	Dale Rhoda		Special case for SIA databases 
*                                       (one more character in the indicator name)
* 2020-12-08	1.05	Dale Rhoda		Add db_id and db_rownum variables for
*                                       easy reconstruction of individual 
*                                       database datasets
* 2020-12-15	1.06	Dale Rhoda		Be sure to label all the level variables
* 2021-01-08	1.07	Dale Rhoda		Store the name of the original database, too
* 2021-01-16	1.08	Dale Rhoda		Exclude SIA_COVG_05 from aggregation
******************************************************************************** 
* This takes all the vcqi databases and creates one single database. Then deletes all of them
capture program drop aggregate_vcqi_databases
program define aggregate_vcqi_databases

	vcqi_log_comment $VCP 3 Comment "User has specified that VCQI databases should all be kept. Consolidating into one database and erasing all individual databases."
		
	preserve
	
	* Erase the datasets that will be created by this program if they already exist
	foreach f in unweighted weighted other all {
		capture erase "${VCQI_OUTPUT_FOLDER}/VCQI_aggregated_databases_`f'.dta"
	}
	
	* Create two globals ... one for the aggregated databases and one for all others
	global VCQI_AGGREGATED_DATABASES 
	global VCQI_NON_AGGREGATED_DATABASES
	foreach d in $VCQI_DATABASES {
		if  `=strpos("`d'","RI_COVG_05")' > 0  | `=strpos("`d'","SIA_COVG_05")' > 0  | `=strpos("`d'","DESC")' > 0 | `=strpos("`d'","COVG_DIFF")' > 0 | `=strpos("`d'","table_order")' > 0 ///
			global VCQI_NON_AGGREGATED_DATABASES $VCQI_NON_AGGREGATED_DATABASES `d'
			
		else global VCQI_AGGREGATED_DATABASES $VCQI_AGGREGATED_DATABASES `d'
	}
	
	vcqi_global VCQI_AGGREGATED_DATABASES $VCQI_AGGREGATED_DATABASES
	vcqi_global VCQI_NON_AGGREGATED_DATABASES $VCQI_NON_AGGREGATED_DATABASES
		
	* Reset the VCQI_DATABASES global to be the AGGREGATED_DATABASES so the NON_AGGREGATED_DATABASES are not deleted
	vcqi_global VCQI_DATABASES $VCQI_AGGREGATED_DATABASES
		
	if "$VCQI_AGGREGATED_DATABASES" != "" {
		
		* Set locals
		local first_weighted 0
		local first_unweighted 0
		local first_other 0
		local first_desc 0
		local n 1
		foreach f in $VCQI_AGGREGATED_DATABASES {
			use "${VCQI_OUTPUT_FOLDER}/`f'.dta", clear
			
			gen db_rownum = _n
			label variable db_rownum "Row number in original database"
			
			gen db_id = `n'
			label variable db_id "Unique ID for this database"
			
			gen db_name = "`f'"
			label variable db_name "Name of original database"
														
			local strcount 10
			if `=strpos("`f'","RI_ACC_")' > 0 local strcount `=`strcount'- 1'
			if substr("`f'",1,11) == "RI_QUAL_07B" | substr("`f'",1, 3) == "SIA" local strcount 11
				
			local indicator =substr("`f'",1,`strcount')
			local analysis_counter = substr("`f'",`=`strcount'+ 2',1)
			local `n'_name1 =subinstr("`f'","_database","",.)
			local `n'_name2 =substr("``n'_name1'",`=`strcount'+ 4',.)
			 
			 * Determine if weight or unweighted dataset
			qui d, varl
			local `n'_var `r(varlist)'
			
			local weighted other
			if "``n'_var'" == "level id level4id level4name outcome estimate n" local weighted unweighted
			if "``n'_var'" == "level name level1id level1name level2id level2name level3id level3name level4id level4name id outcome estimate n" local weighted unweighted
			if "``n'_var'" == ///
			"level name level1id level1name level2id level2name level3id level3name level4id level4name id outcome estimate stderr cilevel cill ciul lcb ucb deff icc n nwtd nclusters nwtd_est" ///
			local weighted weighted
			
			if "`indicator'"=="RI_QUAL_09" local weighted unweighted
			local first_`weighted' `=`first_`weighted''+1'
			
			* Create local with values that will be used for indicator variables
			local weighted_value 1
			if "`weighted'" == "unweighted" local weighted_value 2
			if "`weighted'" == "other" local weighted_value 3
			
			* Create variables to identify which database the data is from
			gen vcqi_db_indicator = "`indicator'"
			label var vcqi_db_indicator "Indicator name from VCQI DATABASE file name"
			
			gen vcqi_db_indicator_type = `weighted_value'
			label define weighted_value 1 "Weighted" 2 "Unweighted" 3 "Other", replace
			label value vcqi_db_indicator_type weighted_value
			label var vcqi_db_indicator_type "Type of dataset"
			
			* Create variable with the label
			capture confirm var estimate
			if _rc == 0 {
				gen vcqi_db_label = "`:var label estimate'"
			}
			else gen vcqi_db_label = "`f'"
			label var vcqi_db_label "Database label"
			
			gen vcqi_db_analysis_counter = `analysis_counter'
			label var vcqi_db_analysis_counter "Analysis counter from VCQI DATABASE file name"
			
			gen vcqi_db_additional_file_info = "``n'_name2'"
			label var vcqi_db_additional_file_info "Additional information from VCQI DATABASE file name"
		
			order vcqi_db_*

			vcqi_log_comment $VCP 3 Comment "Appending `f'.dta to VCQI_aggregated_databases_`weighted'.dta"
			
			* Append into one large file
			if `n' == 1 save "${VCQI_OUTPUT_FOLDER}/VCQI_aggregated_databases_all.dta", replace
			else {
				append using "${VCQI_OUTPUT_FOLDER}/VCQI_aggregated_databases_all.dta"
				save "${VCQI_OUTPUT_FOLDER}/VCQI_aggregated_databases_all.dta", replace
			}
			
			local ++n
		}	
			
		* Now go and add the level orders to this database
		forvalues i = 2/3 {
			merge m:1 level`i'id using "${VCQI_DATA_FOLDER}/level`i'order", keepusing(level`i'order) 
			keep if _merge == 1 | _merge == 3
			drop _merge
			order level`i'order, after(level`i'name)
		}
		
		sort db_id db_rownum
		
		compress
		
		capture label variable level1name  "Level1 name"
		capture label variable level2id    "Level2 ID"
		capture label variable level2name  "Level2 stratum name"
		capture label variable level2order "Level 2 stratum table order"
		capture label variable level3id    "Level3 ID"
		capture label variable level3name  "Level3 stratum name"
		capture label variable level3order "Level3 stratum table order"
		capture	label variable level4id    "Sub-stratum ID"
		capture label variable level4name  "Sub-stratum name"	
		capture label variable level4order "Sub-stratum table order"
	
		save "${VCQI_OUTPUT_FOLDER}/VCQI_aggregated_databases_all.dta", replace
	}
	restore

end