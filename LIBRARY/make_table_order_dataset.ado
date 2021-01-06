*! make_table_order_dataset version 1.01 - Biostat Global Consulting - 2020-12-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
********************************************************************************
* 2020-12-09	1.00	Dale Rhoda		Original version (from make_tables_from_unwtd_output.ado)
* 2020-12-25	1.01	Dale Rhoda		Pass the logical condition into the TO dataset
*******************************************************************************

program define make_table_order_dataset
	version 14.1
				
	local oldvcp $VCP
	global VCP make_table_order_dataset
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		capture postclose to_dataset

		postfile to_dataset str50 stratum block level substratum level1id ///
		            level2id level3id level4id str200 condition using ///
					"${VCQI_OUTPUT_FOLDER}/table_order_TO", replace

		global MISC_TEMP_DATASETS ${MISC_TEMP_DATASETS} table_order_TO

		use "${VCQI_OUTPUT_FOLDER}/table_order_database", clear
		
		* Preparatory work and tidying of variables	
		
		* calculate maximum number of characters in the stratum name
		gen stratum_name_length = ustrlen(name)
		qui summarize stratum_name_length
		local max_stratum_name_length = r(max)
		drop stratum_name_length
		
		* generate a new 0/1 flag that indicates which rows in the output 
		* are showing results for sub-strata defined by level 4
		
		gen substratum = !missing(level4id)
		
		* bring in information about what order the user wants to list rows from
		* levels 2, 3, and 4.  If the user has NOT specifed datasets with sort 
		* order, then they are simply listed in numerical or alphabetical order 
		* of their respective ids
		
		if "$LEVEL2_ORDER_DATASET" != "" {
			merge m:1 level2id using "$LEVEL2_ORDER_DATASET"
			keep if _merge == 1 | _merge == 3
			drop _merge
			order level2order, after(level2id)
		}
		else {
			gen level2order = level2id
		}
		replace level2order = 0 if missing(level2order)
		
		if "$LEVEL3_ORDER_DATASET" != "" {
			merge m:1 level3id using "$LEVEL3_ORDER_DATASET"
			keep if _merge == 1 | _merge == 3
			drop _merge
			order level3order, after(level3id)
		}
		else {
			gen level3order = level3id
		}
		replace level3order = 0 if missing(level3order)

		if "$VCQI_LEVEL4_STRATIFIER" != "" & "$LEVEL4_ORDER_DATASET" != "" {
			merge m:1 level4id using "$LEVEL4_ORDER_DATASET"
			keep if _merge == 1 | _merge == 3
			drop _merge
		}
		else if "$VCQI_LEVEL4_SET_LAYOUT" != "" & "$LEVEL4_ORDER_DATASET" != "" {
			* Use the level4_layout order as the level4order
			gen level4order = int(level4id)
		}
		else {
			gen level4order = level4id
		}
		replace level4order = 0 if missing(level4order)
		order level4order, after(level4id)
		
		***********************************************************
		*
		* Now we have eight blocks of code to generate different 
		* types of blocks of output.  The user might select only
		* one of these, or a subset.  It would probably be unusual 
		* to ask for all 8 blocks to be put out, as that would be
		* quite repetitive, but the code will happily do it if the
		* user asks for it.
		*
		* What people select will depend on what they are doing
		* with the tables and what sort of detail they want.
		*
		***********************************************************

		* Only show results that are aggregated up to the national level (1)
		if $SHOW_LEVEL_1_ALONE == 1 {
			preserve 
			keep if level == 1 & missing(level4id)
			local i 1
			post to_dataset (name[`i']) (1) (1) (0) ///
			        (level1id[`i']) (level2id[`i']) (level3id[`i']) (level4id[`i'])	("`=condition[`i']'")
			restore
		}
		
		* In this block we only show the sub-national or province level (2) results
		if $SHOW_LEVEL_2_ALONE == 1 {
			preserve
			keep if level == 2 & missing(level4id)
			sort level2order
			forvalues i = 1/`=_N' {
				post to_dataset (name[`i']) (2) (level[`i']) (substratum[`i']) ///
			        (level1id[`i']) (level2id[`i']) (level3id[`i']) (level4id[`i'])	("`=condition[`i']'")
			}
			restore
		}

			
		* Only show the sub-sub-national level (3) without aggregating upward	
		if $SHOW_LEVEL_3_ALONE == 1 {
			preserve
			keep if level == 3 & missing(level4id)
			sort level3order
			forvalues i = 1/`=_N' {
				post to_dataset (name[`i']) (3) (level[`i']) (substratum[`i']) ///
			        (level1id[`i']) (level2id[`i']) (level3id[`i']) (level4id[`i'])	("`=condition[`i']'")
			}
			restore
		}
		
		* Show each level 2 stratum (sorted in the order the user asked for)
		* and underneath the level 2 row, list one row for each of the level 3
		* strata that are in the level 2 stratum.  e.g., Show a row for each
		* province and then show a row for each district within the province.  
		*
		* After showing all districts for the first province, (optionally) post
		* a blank row and then post results for the next province and its districts
		if $SHOW_LEVELS_2_3_TOGETHER == 1 {
			preserve
			keep if inlist(level,2,3) & missing(level4id)
			sort level2order level3order
			forvalues i = 1/`=_N' {
				post to_dataset (name[`i']) (4) (level[`i']) (substratum[`i']) ///
			        (level1id[`i']) (level2id[`i']) (level3id[`i']) (level4id[`i'])	("`=condition[`i']'")
			}
			restore
		}

		* Show national results along with the sub-strata (e.g., urban/rural)
		if $SHOW_LEVELS_1_4_TOGETHER == 1 {
			preserve
			keep if inlist(level,1) 
			sort level4order
			forvalues i = 1/`=_N' {
				post to_dataset (name[`i']) (5) (level[`i']) (substratum[`i']) ///
			        (level1id[`i']) (level2id[`i']) (level3id[`i']) (level4id[`i'])	("`=condition[`i']'")
			}
			restore
		}

		* Show sub-national results along with substrata in each sub-national stratum
		* e.g., each province and then that province's results broken out by 
		* urban/rural
		if $SHOW_LEVELS_2_4_TOGETHER == 1 {
			preserve
			keep if inlist(level,2) 
			sort level2order level4order
			forvalues i = 1/`=_N' {
				post to_dataset (name[`i']) (6) (level[`i']) (substratum[`i']) ///
			        (level1id[`i']) (level2id[`i']) (level3id[`i']) (level4id[`i'])	("`=condition[`i']'")
			}
			restore
		}
		
		* Show each level 3 stratum and then disaggregate it by the level 4 
		* stratifier (e.g., each district's results and then the district 
		* results broken out by urban/rural
		if $SHOW_LEVELS_3_4_TOGETHER == 1 {
			preserve
			keep if inlist(level,3) 
			sort level3order level4order
			forvalues i = 1/`=_N' {
				post to_dataset (name[`i']) (7) (level[`i']) (substratum[`i']) ///
			        (level1id[`i']) (level2id[`i']) (level3id[`i']) (level4id[`i'])	("`=condition[`i']'")
			}
			restore
		}
		
		* Show the level 2 stratum results at the top of a block, then break it down
		* urban/rural; then show the first level 3 stratum within the level 2 
		* stratum and break THAT down urban/rural...show the next level 3 stratum
		* and break it down, until all level 3 strata in this level 2 stratum have
		* been listed.  Then skip a row and move on to the next level 2 stratum.
		if $SHOW_LEVELS_2_3_4_TOGETHER == 1 {
			preserve
			keep if inlist(level,2,3) 
			sort level2order level3order level4order
			forvalues i = 1/`=_N' {
				post to_dataset (name[`i']) (8) (level[`i']) (substratum[`i']) ///
			        (level1id[`i']) (level2id[`i']) (level3id[`i']) (level4id[`i'])	("`=condition[`i']'")
			}
			restore
		}

		capture postclose to_dataset
		
		* Now the table should look pretty good in the to_dataset.
		* Do a little housecleaning and then export it to Excel.
		
		use "${VCQI_OUTPUT_FOLDER}/table_order_TO", clear
		qui compress
		
		replace level2id = 0 if missing(level2id)
		replace level3id = 0 if missing(level3id)
		replace level4id = 0 if missing(level4id)
		
		gen table_top_to_bottom_row_order = _n
		gen table_bottom_to_top_row_order = _N + 1 - _n
		
		label variable table_top_to_bottom_row_order "Top-down table row order"
		label variable table_bottom_to_top_row_order "Bottom-up table row order"
		save, replace
				
		vcqi_log_comment $VCP 3 Comment "Table output order established and saved in dataset named table_order_TO"	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
