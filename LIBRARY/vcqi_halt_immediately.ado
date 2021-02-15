*! vcqi_halt_immediately version 1.26 - Biostat Global Consulting - 2021-01-06
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Sent error message to VCQI log
*
* 2016-01-18	1.02	Dale Rhoda		Use vcqi_global in some places
*
* 2016-02-12	1.03	Dale Rhoda		Delete databases if user requests it
* 										and delete the logfile .dta if user
* 										requests that temp datasets be deleted
*
* 2016-02-12							Moved the message about exiting
*                                       prematurely to a spot higher in the 
*										code ... before the log is closed and
* 										exported.
*
* 2016-02-14	1.04	Dale Rhoda		Added exit to the bottom, so it will
* 										quit either with code 99 if VCQI_ERROR
*										is set, or cleanly otherwise
*
* 2016-02-16	1.05	Dale Rhoda		Remove all the temporary datasets if
* 										the user requests it
*
* 2016-02-24	1.06	Dale Rhoda		Change CVG to COVG for consistency
*
* 2016-02-27	1.07	Mary Prier		Displays message to screen if there are 
*                                       any errors or warnings in log dataset.
*                                       Sorts errors and warnings to be at the 
*                                       top of the dataset; exports to excel & 
*                                       uses <putexcel> to change font color &
*                                       shading for errors to be red and for 
*                                       warnings to be yellow. (Issue #21)
*  								  	    
* 2016-08-25	1.08	Dale Rhoda		Skip this program if the user has 
*										asked to VCQI_CHECK_INSTEAD_OF_RUN
*
* 2016-09-11	1.09	Dale Rhoda		Run quietly; add VCQI banner to screen
*                                       output
*
* 2016-09-20	1.10	Dale Rhoda		Call them error  'messages' instead of
*										errors
* 2017-07-05	1.11	MK Trimner		Added code to check to see if "$VCQI_OUTPUT_FOLDER/`surveytype'_with_ids" 
*										exists prior to running add_HH_vars_to_opplot_datasets program
*
* 2017-08-26	1.12	Mary Prier		Added version 14.1 line
*
* 2018-04-26	1.13	Dale Rhoda		Removed check from v 1.11
*
* 2018-05-30	1.14	Dale Rhoda		Wrapped all global checks in ""
*
* 2018-06-26	1.15	MK Trimner		Added changes to include set_TO_xlsx_column_width
*										and moved VCQI tattoo to bottom 
*
* 2019-09-13	1.16 	Mary Prier		Added RI_CCC_01 RI_CIC_01 to list of indictors
*										to loop over in the DELETE_TEMP_VCQI_DATASETS section
*
* 2019-10-07	1.17	Dale Rhoda		Added RI_SIA_04 and 05 to list of indicators
*										to loop over in the DELETE_TEMP_VCQI_DATASETS section
* 2020-02-04	1.18	MK Trimner		Added aggregate_vcqi_databases program if user specifies to 
*										keep VCQI_DATABASES through global $DELETE_VCQI_DATABASES_AT_END == 0
* 										Then always delete the individual databases
* 2020-04-09	1.19	Dale Rhoda		Set MISS_VCQI____END_OF_PROGRAM global so we can
*										*store* the control program change log at the bottom
*                                       of the program but suppress it from being shown in the
*                                       log window when MISS VCQI concludes.
* 2020-04-30	1.20	Dale Rhoda		Clean up END_OF_PROGRAM
*
* 2020-09-25	1.21	Dale Rhoda		Add RI_VCTC_01 to cleanup temp files list
*
* 2020-11-07    1.22	Dale Rhoda		Closing message should report n_errors - 1 
*                                       if one of the errors was simply to say that
*                                       VCQI is exiting prematurely due to an error
*
* 2020-11-15	1.23	Dale Rhoda		Explicitly di as text to manage font color
*
* 2020-12-08	1.24	Dale Rhoda		New exit billboard
*
* 2020-12-09    1.25    Dale Rhoda      Introduce $MISC_TEMP_DATASETS
*
* 2021-01-06	1.26	Dale Rhoda		Add RI_QUAL_07B, RI_CCC_02 and RI_CIC_02
*                                       to the list for deleting temporary datasets;
*                                       also close any open graphs
*
*******************************************************************************

program define vcqi_halt_immediately
	version 14.1

	global VCP vcqi_halt_immediately
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		if "$VCQI_CHECK_INSTEAD_OF_RUN" != "1" {
		
			****************************************************************************
			* Close any graphs that remain open
			graph drop _all
			
			****************************************************************************
			* If the user made organ pipe plots and saved accompanying datasets,
			* augment those datasets with the cluster names
			if "$MAKE_PLOTS" == "1" & "$VCQI_MAKE_OP_PLOTS" == "1" & ///
				"$VCQI_SAVE_OP_PLOT_DATA" == "1" noi add_HH_vars_to_opplot_datasets
			
			****************************************************************************
			* If the user executed some COVG_DIFF_01 hypothesis tests, close
			* that postfile, export it to excel, and format it

			if "$COVG_DIFF_01_POSTOPEN" == "1" {
				vcqi_log_comment $VCP 3 Comment "Closing the COVG_DIFF_01 postfile..."

				capture postclose cdiff01
				use "$COVG_DIFF_01_FILENAME", clear
				compress
				save, replace
				save "${COVG_DIFF_01_FILENAME}_database", replace

				global VCQI_DATABASES $VCQI_DATABASES COVG_DIFF_01_${ANALYSIS_COUNTER}_database

				vcqi_global COVG_DIFF_POSTOPEN 0

				if "$EXPORT_TO_EXCEL" == "1" {
				
					vcqi_log_comment $VCP 3 Comment "Exporting COVG_DIFF_01 output to Excel"
					COVG_DIFF_01_05TO

				}
			}

			****************************************************************************
			* If the user executed some COVG_DIFF_02 hypothesis tests, close
			* that postfile, export it to excel, and format it

			if "$COVG_DIFF_02_POSTOPEN" == "1" {
				vcqi_log_comment $VCP 3 Comment "Closing the COVG_DIFF_02 postfile..."

				capture postclose cdiff02
				use "$COVG_DIFF_02_FILENAME", clear
				compress
				save, replace
				save "${COVG_DIFF_02_FILENAME}_database", replace
				
				global VCQI_DATABASES $VCQI_DATABASES COVG_DIFF_02_${ANALYSIS_COUNTER}_database

				vcqi_global COVG_DIFF_02_POSTOPEN 0

				if "$EXPORT_TO_EXCEL" == "1" {
					vcqi_log_comment $VCP 3 Comment "Exporting COVG_DIFF_01 output to Excel"
					COVG_DIFF_02_05TO

				}
			}
			
			****************************************************************************
			* If the user has specified to keep the temp databases, run program to 
			* append all databases into one database 
			if "$DELETE_VCQI_DATABASES_AT_END" == "0"  & "$AGGREGATE_VCQI_DATABASES" == "1" aggregate_vcqi_databases
			
			* If user specified to delete databases put comment to log
			if "$DELETE_VCQI_DATABASES_AT_END" == "1" vcqi_log_comment $VCP 3 Comment "User has specified that VCQI databases should all be deleted."
			
			if  "$DELETE_VCQI_DATABASES_AT_END" == "1" | ///
			   ("$DELETE_VCQI_DATABASES_AT_END" == "0"  & "$AGGREGATE_VCQI_DATABASES" == "1") {
				
				* Note: This will erase all files that end in _database.dta in
				* the output folder ... even if those files were generated by an
				* earlier VCQI run.  This makes it important to direct the output
				* of each run to its own output folder.
				foreach f in $VCQI_DATABASES {
					vcqi_log_comment $VCP 3 Comment "Erasing `f'.dta"
					capture erase "${VCQI_OUTPUT_FOLDER}/`f'.dta"
				}
			}
			   

			****************************************************************************
			* Delete VCQI temp datasets if the user requests it
			* Most of the measures clean up after themselves, but there are some 
			* temporary datasets that persist across measures; clean those up here
			
			if "$DELETE_TEMP_VCQI_DATASETS" == "1" {
				foreach d in $TT_TEMP_DATASETS $RI_TEMP_DATASETS $SIA_TEMP_DATASETS $MISC_TEMP_DATASETS {
					vcqi_log_comment $VCP 3 Cleanup "Erasing temp dataset `d'"
					capture erase "${VCQI_OUTPUT_FOLDER}/`d'.dta"
				}

				foreach p in TT_COVG_01 SIA_COVG_01 SIA_COVG_02 SIA_COVG_03 SIA_COVG_04 SIA_COVG_05 SIA_QUAL_01 ///
							   RI_ACC_01 RI_CONT_01 DESC_01 DESC_02 DESC_03  ///
							   RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04 RI_COVG_05 ///
							   RI_QUAL_01 RI_QUAL_02 RI_QUAL_03 RI_QUAL_04 RI_QUAL_05 ///
							   RI_QUAL_06 RI_QUAL_07 RI_QUAL_07B RI_QUAL_08 RI_QUAL_09 RI_QUAL_12 ///
							   RI_QUAL_13 RI_CCC_01 RI_CCC_02 RI_CIC_01 RI_CIC_02 ///
							   COVG_DIFF_01 COVG_DIFF_02 RI_VCTC_01 {					   
					foreach d in ${`p'_TEMP_DATASETS} {
						vcqi_log_comment $VCP 3 Cleanup "Erasing temp dataset `d'"
						capture erase "${VCQI_OUTPUT_FOLDER}/`d'.dta"
					}
				}
			}	
			****************************************************************************
			
			* Let the user know (by screen and by logfile) if VCQI is exiting prematurely
			
			if "$VCQI_ERROR" == "1" {
				noisily di as error "VCQI is exiting prematurely because of an error."
				vcqi_log_comment $VCP 1 Error "VCQI is exiting prematurely because of an error"
			}
			
			****************************************************************************
			* Clean up and close the logfile

			vcqi_log_comment $VCP 3 Comment "Closing and exporting the log..."

			capture postclose logfile
			global VCQI_LOGOPEN 0

			* Look at the log
			use "${VCQI_OUTPUT_FOLDER}/${VCQI_LOGFILE_NAME}", clear
			
			qui count
			local n_logrows = r(N)
			
			* Count the number of errors (i.e., level==1) 
			qui count if level=="1"
			local n_errors = r(N)

			* Count the number of warnings (i.e., level==2) 
			qui count if level=="2" & entry_type == "Warning"
			local n_warnings = r(N)

			* Sort log dataset by levels (errors at top)
			gen sequence = _n
			order sequence, first
			sort level sequence
			
			* Establish variable labels for export to the first row
			label variable sequence 	"Log Sequence"
			label variable date 		"Date"
			label variable time 		"Time"
			label variable program	 	"Program"
			label variable level 		"Level"
			label variable entry_type 	"Log Entry Type"
			label variable entry 		"Log Entry"

			* Export the log
			destring _all, replace
			
			export excel using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx", ///
				sheet(Log) sheetreplace firstrow(varlabel) 
				
			* Color text so errors are red & warnings are yellow
			putexcel set "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx", ///
				modify sheet("Log")
			
			* Set columns to be highlighted
			local col1 A
			qui describe
			local nvars = r(k) // number of variables in dataset
			vcqi_excel_convert_to_letter `nvars'
			local col2 r(ConvertToLetter)
			
			* Highlight rows with errors red
			if(`n_errors'>0) {
				local row1e = 2
				local row2e = 1 + `n_errors'
				putexcel `col1'`row1e':`=`col2''`row2e', font("Calibri",11,"156 0 6") 
				putexcel `col1'`row1e':`=`col2''`row2e', fpattern("solid","255 199 206")
			}

			* Highlight rows with warnings yellow
			if(`n_warnings'>0) {
				local row1w = `n_errors' + 2
				local row2w = `n_errors' + 1 + `n_warnings'	
				putexcel `col1'`row1w':`=`col2''`row2w', font("Calibri",11,"156 101 0") 
				putexcel `col1'`row1w':`=`col2''`row2w', fpattern("solid","255 235 156")
			}

			putexcel clear
			
			* Set the widths of the log columns to hold the text
			* expand the column width to hold the text (max allowable width via mata = 255)
			mata: b = xl()
			mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx")
			mata: b.set_mode("open")
			mata: b.set_sheet("Log")
			mata: b.set_column_width(1,1, 12)
			mata: b.set_column_width(2,2, 12)
			mata: b.set_column_width(3,3,  9)
			mata: b.set_column_width(4,4, 30)
			mata: b.set_column_width(5,5,  6)
			mata: b.set_column_width(6,6, 15)
			mata: b.set_column_width(7,7,255)
			mata: b.set_fill_pattern(1,(1,7),"solid","lightgray")
			mata: b.set_horizontal_align((1,`=`n_logrows'+1'),(1,1),"center")
			mata: b.set_horizontal_align((1,`=`n_logrows'+1'),(5,5),"center")
			mata: b.close_book()

			* Now that the logfile has been exported to Excel...delete the logfile
			* dataset if the user has asked us to tidy up.
			if "$DELETE_TEMP_VCQI_DATASETS" == "1" ///
				capture erase "${VCQI_OUTPUT_FOLDER}/${VCQI_LOGFILE_NAME}.dta"
			
			* Adjust column width for all sheets except log
			if "$MAKE_EXCEL_COLUMNS_NARROW"=="" global MAKE_EXCEL_COLUMNS_NARROW 0
			if $MAKE_EXCEL_COLUMNS_NARROW == 1 ///
			noisily set_TO_xlsx_column_width, excel(${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO)		
			
			noisily di as text ""
			noisily di as text ""

			/*
			* This was VCQI's classic exit billboard from 2015 thru 2020
			noisily di as text "========================================="
			noisily di as text " VACCINATION COVERAGE QUALITY INDICATORS "
			noisily di as text "========================================="
			noisily di as text "                                         "
			noisily di as text "  VVV   VVV    CCCCC    QQQ    IIIIIII   "
			noisily di as text "   VV   VV    CC       QQ QQ     III     "
			noisily di as text "    VV VV    CC       QQ   QQ    III     "
			noisily di as text "     VVV      CC       QQ QQ     III     "
			noisily di as text "      V        CCCCC    QQQ Q  IIIIIII   "
			noisily di as text "                                         " 
			noisily di as text "=========================================" 
			noisily di as text "     (C) WORLD HEALTH ORGANIZATION       " 
			noisily di as text "========================================="
			*/

			* This billboard was adopted in January 2021
			noisily di as text "====================================================================               "
			noisily di as text "                 VACCINATION COVERAGE QUALITY INDICATORS                           "
			noisily di as text "  ====================================================================             "
			noisily di as text "   __/\\\________/\\\________/\\\\\\\\\________/\\\________/\\\\\\\\\\\_           "
			noisily di as text "    _\/\\\_______\/\\\_____/\\\////////______/\\\\/\\\\____\/////\\\///__          "
			noisily di as text "     _\//\\\______/\\\____/\\\/_____________/\\\//\////\\\______\/\\\_____         "
			noisily di as text "      __\//\\\____/\\\____/\\\______________/\\\______\//\\\_____\/\\\_____        "
			noisily di as text "       ___\//\\\__/\\\____\/\\\_____________\//\\\______/\\\______\/\\\_____       "
			noisily di as text "        ____\//\\\/\\\_____\//\\\_____________\///\\\\/\\\\/_______\/\\\_____      "
			noisily di as text "         _____\//\\\\\_______\///\\\_____________\////\\\//_________\/\\\_____     "
			noisily di as text "          ______\//\\\__________\////\\\\\\\\\_______\///\\\\\\___/\\\\\\\\\\\_    "
			noisily di as text "           _______\///______________\/////////__________\//////___\///////////__   "
			noisily di as text "            =====================================================================  " 
			noisily di as text "                                (C) WORLD HEALTH ORGANIZATION                      " 
			noisily di as text "              ====================================================================="
			
			noisily di as text ""
			noisily di as text ""	
			
			* Report n-1 if one of the errors is 'VCQI is exiting prematurely' because that's not a separate error
			if "$VCQI_ERROR" == "1" noisily di as text "VCQI ran with `=`n_errors'-1' error messages and `n_warnings' warnings."
			else                    noisily di as text "VCQI ran with `n_errors' error messages and `n_warnings' warnings."

			if (`n_errors' + `n_warnings' > 0) ///
				noisily di as text "See the Log worksheet in ${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx for more information."


			****************************************************************************
			* Exit with error code, if appropriate
			
			if "$VCQI_ERROR" == "1" {
				exit 99	
			}
			
			* Establish a global for the control program to use that
			* is the same as the 'quietly{' command.  This will suppress
			* writing the change log to the screen and instead leave a 
			* last line in the log window that says:
			* VCQI____END_OF_PROGRAM
			
			global VCQI____END_OF_PROGRAM  set output error 
			
		}
	}
end
