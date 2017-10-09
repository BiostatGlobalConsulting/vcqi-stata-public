*! vcqi_open_log version 1.03 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-10-30    1.00	Dale Rhoda		<first draft>
* 2016-02-27	1.01	Mary Prier		Export placeholder text for "Log" worksheet & posted characteristics of computer running VCQI to log file
* 2017-01-29	1.02	Dale Rhoda		Increase log comment length limit to 32,767
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
*******************************************************************************

program define vcqi_open_log
	version 14.1

	* If the user has not established the required global variables then exit.
	* We do not call the program to exit gracefully here, because that, too
	* requires these global macros to be in place...this is a hard stop
	* very early in the process of the run if these basics are not in place.	
	
	if "$VCQI_LOGOPEN" == "1" {

		display as error "You are attempting to open a vcqi log file, but the vcqi_LOGOPEN global macro indicates that one is already open."
		exit 99
	}

	if "$VCQI_OUTPUT_FOLDER" == "" {

		display as error "Define the VCQI_OUTPUT_FOLDER before attempting to open a log file."
		exit 99
	}

	if "$VCQI_ANALYSIS_NAME" == "" {

		display as error "Define the VCQI_ANALYSIS_NAME before attempting to open a log file."
		exit 99
	}		 
		
	global VCQI_LOGFILE_NAME VCQI_${VCQI_ANALYSIS_NAME}_LOG

	* Export placeholder text for "Log" worksheet so it is the left-most tab in the tabulated output (TO) Excel file
	capture preserve
	clear
	set obs 8
	
	gen text =      "This text is a placeholder." 
	replace text =  "If VCQI exits in a clean manner then this text will disappear." in 2
	replace text =  "If VCQI has halted and this text is in the worksheet, you might find an informative log in the Stata log dataset." in 3
	replace text =  "If that happens, go to the Stata command line and type the following line:" in 4
	replace text =  "    vcqi_cleanup" in 5
	replace text =  " " in 6
	replace text =  "Now the VCQI log will be the Stata dataset and you can scroll to the bottom to discover clues as to what went wrong." in 7
	replace text =  "Contact Dale.Rhoda@biostatglobal.com if you have questions.  If possible, attach your logfile dataset (or spreadsheet) to the e-mail." in 8
	
	label variable text "Placeholder Log Text"
	
	* calculate maximum text length for Excel column width
	gen tl = strlen(text)
	sum tl
	scalar textlength = r(max)
	drop tl
	
	export excel using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx", ///
		sheet(Log) sheetreplace firstrow(varlabel) 
	
	* expand the column width to hold the text (max allowable width via mata = 255)
	mata: b = xl()
	mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx")
	mata: b.set_mode("open")
	mata: b.set_sheet("Log")
	
	mata: b.set_column_width(1,1, `=min(255,textlength+3)')
	mata: b.set_fill_pattern((1,10),1,"solid","yellow")
	
	restore
	
	* Open Log file 
	* Note that a Stata string is limited to 2,000,000,000 characters
	* and an Excel cell is limited to 32,767 characters
	* but post is limited to 2045 characters
	
	capture postclose logfile

	postfile logfile str12 date str8 time str50 program ///
			         str50 level str50 entry_type str2045 entry using ///
			         "${VCQI_OUTPUT_FOLDER}/${VCQI_LOGFILE_NAME}", ///
					 replace
			 
	* Post characteristics of the computer that is running VCQI to logfile
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("The following comments document characteristics of the computer that is running VCQI.")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(stata_version) returns `c(stata_version)'")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(version) returns `c(version)'")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(userversion) returns `c(userversion)'")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(SE) returns `c(SE)'.  A returned value of 1 means SE or better.")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(MP) returns `c(MP)'.  A returned value of 1 means computer is running Stata/MP.")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(processors) returns `c(processors)'")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(os) returns `c(os)'")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(machine_type) returns `c(machine_type)'")
	post logfile ("$S_DATE") ("$S_TIME") ("VCQI_LOG_OPEN") ("3") ("c(return)") ("c(bit) returns `c(bit)'")
	
					 
	global VCQI_LOGOPEN 1
	
end
			 

			
