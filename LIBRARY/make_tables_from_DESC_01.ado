*! make_tables_from_DESC_01 version 1.07 - Biostat Global Consulting - 2021-01-06
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-12	1.01	Dale Rhoda		Add TO to the list of temp datasets
* 										to possibly be deleted later, per the
* 										user's request
* 2016-02-26	1.02	Dale Rhoda		Switch FOOTNOTE code to while loop
* 2017-01-31	1.03	Dale Rhoda		Generate LEVEL4 output using
*										VCQI_LEVEL4_SET_VARLIST & 
*										VCQI_LEVEL4_SET_LAYOUT
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
* 2018-11-14	1.05	Dale Rhoda		Use VCQI_NUM_DECIMAL_DIGITS
* 2020-12-12	1.06	Dale Rhoda		Allow the user to SHOW_LEVEL_4_ALONE
* 2021-01-06	1.07	Dale Rhoda		Extend stratum string length to 255
*******************************************************************************

program define make_tables_from_DESC_01
	version 14.1
	
	syntax , MEASureid(string) SHEET(string)
				
	local oldvcp $VCP
	global VCP make_tables_from_DESC_01
	
	vcqi_log_comment $VCP 5 Flow "Starting"	
	if "$VCQI_DEBUG" == "1" vcqi_log_comment $VCP 3 Comment "Worksheet = `sheet'"
	
	* This program does several things...
	*
	* 1. It reads in the results generated by GO and tidies them up - for this
	*    measure there is output for two tables - one summarizing HH visited
	*    and one summarizing interviews completed.   
	* 2. It parses out what order the user wants to see stratum-level
	*    results in the spreadsheets.
	* 3. Then it writes (posts) the output to a new dataset in a format
	*    that looks like the tables...in the correct order and with
	*    blank rows, etc.  Nothing is formatted, but at this point it
	*    is staged for export to Excel.
	* 4. Then the program writes the table out to Excel and does some
	*    basic formatting.  
	*   
	*  (This sounds like too many jobs for one program, so consider
	*   coming back and breaking it into smaller pieces.)
	*	
	
	* open the post file with the handle name "to_dataset" (tabulated output)
	*
	* the three fields at the end: block level and substratum
	* are not meant to be written out, but are handy for formatting the 
	* spreadsheet cells
	*
	use "$VCQI_OUTPUT_FOLDER/DESC_01_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_database", clear
	
	* build a list of blank entries for blank rows : blist
	
	* build a list of the post entries using the [`i'] nomenclature but 
	* substitute a pipe (|) for the first macro quote, to keep it from
	* being evaluated until later
	
	local xlist
	local blist	
	foreach v in expected_n visited_n info_from_occupant_n info_from_occupant_pct ///
		eligible_occupant_n eligible_occupant_pct info_from_neighbor_n ///
		info_from_neighbor_pct eligible_neighbor_n eligible_neighbor_pct ///
		no_info_n no_info_pct eligible_n selected_n completed_n ///
		completed_pct male_n male_pct female_n female_pct register_n ///
		register_pct unavailable_n unavailable_pct refused_n refused_pct ///
		other_n other_pct {
		
		local blist `blist' (.)
		if substr("`v'",-3,.) == "pct" replace `v' = `v' * 100
		local xlist `xlist' (`v'[|i'])
	}
	
	capture postclose to_dataset
	
	postfile to_dataset str255 stratum ///
			expected_n visited_n info_from_occupant_n info_from_occupant_pct ///
			eligible_occupant_n eligible_occupant_pct ///
			info_from_neighbor_n info_from_neighbor_pct ///
			eligible_neighbor_n eligible_neighbor_pct ///
			no_info_n no_info_pct ///
			eligible_n selected_n completed_n completed_pct male_n male_pct ///
			female_n female_pct register_n register_pct ///
			unavailable_n unavailable_pct refused_n refused_pct ///
			other_n other_pct block  level substratum ///
			using ///
			"${VCQI_OUTPUT_FOLDER}/DESC_01_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_TO", replace

	vcqi_global DESC_01_TEMP_DATASETS $DESC_01_TEMP_DATASETS DESC_01_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_TO
	
	* Preparatory work and tidying of variables	
		
	* calculate maximum number of characters in the stratum name
	gen stratum_name_length = length(name)
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

	* In many cases the output tables will be easier to read if they
	* have a blank row between blocks and even within blocks between
	* large strata.  If the user asks for blanks between levels, then
	* we set up an empty post command to put out an empty row.
	*
	* Store the command in a local macro so we can call it later by
	* simply saying `postblankrow'.
	
	if $SHOW_BLANKS_BETWEEN_LEVELS == 1 {
		local postblankrow post to_dataset ("") `blist' (.) (.) (.)
	}
	if $SHOW_BLANKS_BETWEEN_LEVELS == 0 {
		local postblankrow local noblankrows
	}
	
	* now wrap the i in macro quotes before using xlist in the posts below
	local xlist = subinstr("`xlist'","|","\`",.)
	
	* Only show results that are aggregated up to the national level (1)
	if $SHOW_LEVEL_1_ALONE == 1 {
		preserve 
		keep if level == 1 & missing(level4id)
		local i 1
		post to_dataset (name[`i']) `xlist' ///
				(1) (1) (0)
		restore
		if $SHOW_BLANKS_BETWEEN_LEVELS == 1 `postblankrow' 
	}
	
	* In this block we only show the sub-national or province level (2) results
	if $SHOW_LEVEL_2_ALONE == 1 {
		preserve
		keep if level == 2 & missing(level4id)
		sort level2order
		forvalues i = 1/`=_N' {
			post to_dataset (name[`i']) `xlist' ///
					(2) (level[`i']) (substratum[`i'])
		}
		restore
		if $SHOW_BLANKS_BETWEEN_LEVELS == 1 `postblankrow' 
	}

		
	* Only show the sub-sub-national level (3) without aggregating upward	
	if $SHOW_LEVEL_3_ALONE == 1 {
		preserve
		keep if level == 3 & missing(level4id)
		sort level3order
		forvalues i = 1/`=_N' {
			post to_dataset (name[`i']) `xlist' ///
					(3) (level[`i']) (substratum[`i'])
		}
		restore
		if $SHOW_BLANKS_BETWEEN_LEVELS == 1 `postblankrow' 
	}
	
		
	* Only show the sub-strata (e.g., urban/rural)	
	* (Note that the value of block here is 9 because this capability 
	*  was added after that for blocks 1-8.)
	if $SHOW_LEVEL_4_ALONE == 1 {
		preserve
		keep if level == 1 & !missing(level4id)
		sort level4order
		forvalues i = 1/`=_N' {
			post to_dataset (name[`i']) `xlist' ///
					(9) (level[`i']) (substratum[`i'])
		}
		restore
		if $SHOW_BLANKS_BETWEEN_LEVELS == 1 `postblankrow' 
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
			if `i' > 1 & level3order[`i'] == 0 `postblankrow'

			post to_dataset (name[`i']) `xlist' ///
					(4) (level[`i']) (substratum[`i'])
		}
		restore
		if $SHOW_BLANKS_BETWEEN_LEVELS == 1 `postblankrow' 
	}

	* Show national results along with the sub-strata (e.g., urban/rural)
	if $SHOW_LEVELS_1_4_TOGETHER == 1 {
		preserve
		keep if inlist(level,1) 
		sort level4order
		forvalues i = 1/`=_N' {
			if `i' > 1 & level4order[`i'] == 0 `postblankrow'

			post to_dataset (name[`i']) `xlist' ///
					(5) (level[`i']) (substratum[`i'])
		}
		restore
		if $SHOW_BLANKS_BETWEEN_LEVELS == 1 `postblankrow' 
	}

	* Show sub-national results along with substrata in each sub-national stratum
	* e.g., each province and then that province's results broken out by 
	* urban/rural
	if $SHOW_LEVELS_2_4_TOGETHER == 1 {
		preserve
		keep if inlist(level,2) 
		sort level2order level4order
		forvalues i = 1/`=_N' {
			if `i' > 1 & level4order[`i'] == 0 `postblankrow'

			post to_dataset (name[`i']) `xlist' ///
					(6) (level[`i']) (substratum[`i'])
		}
		restore
		if $SHOW_BLANKS_BETWEEN_LEVELS == 1 `postblankrow' 
	}
	
	* Show each level 3 stratum and then disaggregate it by the level 4 
	* stratifier (e.g., each district's results and then the district 
	* results broken out by urban/rural
	if $SHOW_LEVELS_3_4_TOGETHER == 1 {
		preserve
		keep if inlist(level,3) 
		sort level3order level4order
		forvalues i = 1/`=_N' {
			if `i' > 1 & level4order[`i'] == 0 `postblankrow'

			post to_dataset (name[`i']) `xlist' ///
					(7) (level[`i']) (substratum[`i'])
		}
		restore
		if $SHOW_BLANKS_BETWEEN_LEVELS == 1 `postblankrow' 
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
			if `i' > 1 & level[`i'] == 2 & level4order[`i'] == 0 `postblankrow'

			post to_dataset (name[`i']) `xlist' ///
					(8) (level[`i']) (substratum[`i'])
		}
		restore
	}

	capture postclose to_dataset
		
	use "${VCQI_OUTPUT_FOLDER}/DESC_01_${DESC_01_DATASET}_${ANALYSIS_COUNTER}_TO", clear
	qui compress
	save, replace
	
	*******************************************************
	*
	* Now export the table to Excel
    *
	*
	
	* calculate number of rows in the table
	qui count
	local nrows = r(N)
	
	* for now we leave two blank rows at the top for title and subtitle
	local startrow 6
	local rows `=`startrow'+1',`=`startrow'+`nrows''
	
	local nextcolumn 1
	local sheetoption sheetreplace

	* how many variables are being exported?
	foreach v in stratum expected_n visited_n info_from_occupant_n info_from_occupant_pct ///
		eligible_occupant_n eligible_occupant_pct info_from_neighbor_n ///
		info_from_neighbor_pct eligible_neighbor_n eligible_neighbor_pct ///
		no_info_n no_info_pct eligible_n selected_n completed_n ///
		completed_pct male_n male_pct female_n female_pct register_n ///
		register_pct unavailable_n unavailable_pct refused_n refused_pct ///
		other_n other_pct {
		
		local variables `variables' `v'
	}
	local nvars = wordcount("`variables'")
		
	* which columns will they be written to?
	local cols `nextcolumn',`=`nextcolumn'+`nvars'-1'
			
	* what is the letter of the first column?
	vcqi_excel_convert_to_letter `nextcolumn'
	
	* what is the cell to put the upper left corner of the new export?
	local cell `r(ConvertToLetter)'`startrow'
				
	* Export the requested variables
	
	export excel `variables' using ///
		"${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx", ///
		sheet("`sheet'") firstrow(variable) cell(`cell') ///
		`sheetoption'

	* Use mata to populate column labels and worksheet titles and footnotes
	mata: b = xl()
	mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx")
	mata: b.set_sheet("`sheet'")
	mata: b.set_mode("open")
	
	*Overwrite the stratum variable name...it is not needed
	mata: b.put_string(`startrow',1,"")

	foreach col in 2 3 4 6 8 10 12 14 15 16 18 20 22 24 26 28 {
		mata: b.put_string(`startrow',`col',"N") 
	}
	
	foreach col in 5 7 9 11 13 17 19 21 23 25 27 29 {
		mata: b.put_string(`startrow',`col',"%") 
	}

	foreach i in 2 3 4 8 12 14 15 16 {
		mata: b.put_string(`=`startrow'-1',`i',"Total")
	}
	mata: b.put_string(`=`startrow'-1', 6,"Eligible")
	mata: b.put_string(`=`startrow'-1',10,"Eligible")
	mata: b.put_string(`=`startrow'-1',18,"Male")
	mata: b.put_string(`=`startrow'-1',20,"Female")
	mata: b.put_string(`=`startrow'-1',22,"Found Register Records")
	mata: b.put_string(`=`startrow'-1',24,"Caretaker Unavailable")
	mata: b.put_string(`=`startrow'-1',26,"Refused")
	mata: b.put_string(`=`startrow'-1',28,"Other")
	
	
	mata: b.put_string(`=`startrow'-2', 2,"Expected")
	mata: b.put_string(`=`startrow'-2', 3,"Observed")
	mata: b.put_string(`=`startrow'-2', 4,"Occupant")
	mata: b.put_string(`=`startrow'-2', 8,"Neighbor")
	mata: b.put_string(`=`startrow'-2',12,"No Info")
	mata: b.put_string(`=`startrow'-2',14,"Eligible")
	mata: b.put_string(`=`startrow'-2',15,"Selected")
	mata: b.put_string(`=`startrow'-2',16,"Completed")
	mata: b.put_string(`=`startrow'-2',24,"Did Not Complete")

	mata: b.put_string(`=`startrow'-4', 2,"HH Visited")
	mata: b.put_string(`=`startrow'-4', 4,"Info From")
	mata: b.put_string(`=`startrow'-4',14,"Info From Occupant")

	* Merge the appropriate column headers
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),( 4,  5))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),( 6,  7))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),( 8,  9))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(10, 11))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(12, 13))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(16, 17))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(18, 19))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(20, 21))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(22, 23))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(24, 25))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(26, 27))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-1', `=`startrow'-1'),(28, 29))

	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-2', `=`startrow'-2'),( 4,  7))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-2', `=`startrow'-2'),( 8, 11))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-2', `=`startrow'-2'),(12, 13))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-2', `=`startrow'-2'),(16, 23))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-2', `=`startrow'-2'),(24, 29))
	
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-4', `=`startrow'-3'),( 2,  3))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-4', `=`startrow'-3'),( 4, 13))
	mata: b.set_sheet_merge("`sheet'",(`=`startrow'-4', `=`startrow'-3'),(14, 29))	
	
	* If this is the first time we are writing to the worksheet
	* include the measure titles and footnotes
	
	if `nextcolumn' == 1 {
		
		mata: b.put_string(1,1,"${`measureid'_TO_TITLE}")
		mata: b.set_font_bold(1,1,"on")
		
		if "${`measureid'_TO_SUBTITLE}" != "" mata: b.put_string(2,1,"${`measureid'_TO_SUBTITLE}")

		local footnoterow = `=`startrow'+`nrows'+2'
		local i 1
		while "${`measureid'_TO_FOOTNOTE_`i'}" != "" {
			mata: b.put_string(`footnoterow',1,"${`measureid'_TO_FOOTNOTE_`i'}")
			local ++footnoterow
			local ++i
		}
	}
	
	* Usually we'll want to format the excel, but it is time consuming
	* so give an option to turn that off during testing of the code
	if "$FORMAT_EXCEL" == "1" {
		
		if $VCQI_NUM_DECIMAL_DIGITS == 0 local dp 
		if $VCQI_NUM_DECIMAL_DIGITS > 0 {
			local dp .
			forvalues i = 1/$VCQI_NUM_DECIMAL_DIGITS {
				local dp `dp'0
			}
		}
		if $VCQI_NUM_DECIMAL_DIGITS < 0 local dp .0

		mata: b.set_border( (`=`startrow'-4',`=`startrow'-1'), (2,29) , "thin", "black" )
		excel_box_border_using_mata `=`startrow'-4' `=`startrow'-1'  1 13 medium black
		excel_box_border_using_mata `=`startrow'-4' `=`startrow'-1' 14 29 medium black
	
		local t2 expected
		local t3 observed
		local t6 eligible
		local t10 eligible
		local t14 eligible
		local t15 selected
		local t22 found register records
		local t24 caretaker unavailable 
		local t26 refused
	
	
		* format individual fields to look good
		forvalues i = 1/`nvars' {
		
			local col = `nextcolumn' - 1 + `i'
			
	
			if word("`variables'",`i') == "stratum"  {
				mata: b.set_column_width(`col',`col', `=`max_stratum_name_length'+3')
				mata: b.set_horizontal_align((`rows'),`col',"left") 
			}
			
			if substr(word("`variables'",`i'),-4,4) == "_pct" {
				mata: b.set_column_width(`col',`col', `=max(5,`=strlen("`t`i''")+2')')
				mata: b.set_number_format((`rows'),`col',"##0`dp';;0`dp';")
			}
			
			if substr(word("`variables'",`i'),-2,2) == "_n" {
				mata: b.set_column_width(`col',`col', `=max(8,`=strlen("`t`i''")+2')')
				mata: b.set_number_format((`rows'),`col',"number_sep")
			}
			

		}
		
		* right align column titles
		mata: b.set_horizontal_align(`startrow',(`cols'),"right")
		* center align the first three rows
		mata: b.set_horizontal_align((`=`startrow'-4',`=`startrow'-1'),(`cols'),"center")
		
		* add bold or shading or indent or italics
		forvalues j = 1/`=_N' {
	
			local i = `j' + `startrow'

			if block[`j'] == 4 & ///
			   level[`j'] == 2 ///
			   mata: b.set_fill_pattern(`i',(`cols'),"solid","lightgray")
			
			if block[`j'] == 8 & ///
			   level[`j'] == 2 & ///
			   substratum[`i'] == 0 ///
			   mata: b.set_fill_pattern(`i',(`cols'),"solid","lightgray")
			
			* Indent level 4 stratum names unless they are headings (LABEL_ONLY) with no estimate
			if `nextcolumn' == 1 & substratum[`j'] == 1 & !missing(expected_n[`j']) ///
				mata: b.set_text_indent(`i',`nextcolumn',3)
			if `nextcolumn' == 1 & substratum[`j'] == 1 ///
				mata: b.set_font_italic(`i',`nextcolumn',"on")
			
			if level[`j'] == 1 & ///
				substratum[`j'] == 0 mata: b.set_font_bold(`i',(`cols'),"on")
		}			
		
	}
	
	mata: b.close_book()
		
	vcqi_log_comment $VCP 3 Comment "Tabular output for DESC_01 to sheet `sheet' in ${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx"	
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
