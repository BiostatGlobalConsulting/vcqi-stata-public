*! - Users Guide TT Control Program version 1.03 - Biostat Global Consulting - 2020-12-12
********************************************************************************
* Vaccination Coverage Quality Indicators (VCQI) control program to analyze
* data from a tetanus survey 
*
*
* Program example and template for the VCQI User's Guide
*
* Written by Biostat Global Consulting
*
* See bottom of program for log of program updates
*
* The user might customize this program by changing items below in the
* code blocks marked TT-B, TT-D, and TT-F below.  Those blocks are
* marked "(User may change)".
*
*
********************************************************************************
* Code Block: TT-A                                               (Do not change)
*-------------------------------------------------------------------------------
*                  Start with clear memory
*-------------------------------------------------------------------------------

set more off

clear all

macro drop _all
	
********************************************************************************
* Code Block: TT-B                                             (User may change)
*-------------------------------------------------------------------------------
*                  Specify input/output folders & analysis name
*-------------------------------------------------------------------------------

* Where have you saved the VCQI Stata source code?

* global S_VCQI_SOURCE_CODE_FOLDER      C:/Users/Dale/Dropbox (Biostat Global)/DAR GitHub Repos/vcqi-stata-bgc

* We recommend that VCQI Users establish the global S_VCQI_SOURCE_CODE_FOLDER
* in the profile.do program that lives in your Stata personal folder.
* (Type the command 'personal' to learn the location of what Stata calls 
*  your personal folder.)
*
* Alternatively, you may uncomment the line of code above and set the 
* global here.  Make its value the path to the folder that holds your 
* current VCQI source folders.

* Note that the S_VCQI_SOURCE_CODE_FOLDER global is used in the six 
* lines of code below

adopath + "${S_VCQI_SOURCE_CODE_FOLDER}/DESC"
adopath + "${S_VCQI_SOURCE_CODE_FOLDER}/DIFF"
adopath + "${S_VCQI_SOURCE_CODE_FOLDER}/LIBRARY"
adopath + "${S_VCQI_SOURCE_CODE_FOLDER}/PLOT"
adopath + "${S_VCQI_SOURCE_CODE_FOLDER}/RI"
adopath + "${S_VCQI_SOURCE_CODE_FOLDER}/SIA"
adopath + "${S_VCQI_SOURCE_CODE_FOLDER}/TT"

vcqi_adopath_check

* Where should the programs look for datasets?
global VCQI_DATA_FOLDER    Q:/- Folders shared outside BGC/BGC Team - WHO Software/Test datasets/2020-10-16

* Where should the programs put output?
global VCQI_OUTPUT_FOLDER  Q:/- Folders shared outside BGC/BGC Team - WHO Software/Working folder - Dale/VCQI test output/TT test

* Establish analysis name (used in log file name and Excel file name)

global VCQI_ANALYSIS_NAME TT_Test

* Set this global to 1 to test all metadata and code that makes
* datasets and calculates derived variables...without running the
* indicators or generating output

global	VCQI_CHECK_INSTEAD_OF_RUN		0

********************************************************************************
* Code Block: TT-C                                               (Do not change)
*-------------------------------------------------------------------------------
*                  Put VCQI in the Stata Path and
*                CD to output folder & open VCQI log
*-------------------------------------------------------------------------------

* CD to the output folder and start the log 
cd "${VCQI_OUTPUT_FOLDER}"

* Start with a clean, empty Excel file for tabulated output (TO)
capture erase "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx"

* Give the current program a name, for logging purposes
global VCP TT_Control_Program

* Open the VCQI log and put a comment in it
vcqi_log_comment $VCP 3 Comment "Run begins...log opened..."
	
* Document the global macros that were defined before the log opened
vcqi_log_global VCQI_DATA_FOLDER
vcqi_log_global VCQI_OUTPUT_FOLDER
vcqi_log_global VCQI_ANALYSIS_NAME

* Write an entry in the log file for each program, noting its version number

vcqi_log_all_program_versions

********************************************************************************
* Code Block: TT-D                                             (User may change)
*-------------------------------------------------------------------------------
*                  Specify dataset names and parameters/metadata
*-------------------------------------------------------------------------------

* Names of datasets that hold TT data
vcqi_global VCQI_TT_DATASET     TT_faux_dataset
vcqi_global VCQI_TTHC_DATASET   TTHC_faux_dataset

* Name of dataset that holds cluster metadata
vcqi_global VCQI_CM_DATASET     CM_faux_dataset

* If you will describe the dataset using DESC_01 then you need to also specify
* the HH and HM datasets

vcqi_global VCQI_HH_DATASET     HH_faux_dataset
vcqi_global VCQI_HM_DATASET     HM_faux_dataset

* --------------------------------------------------------------------------
* Parameters to describe the TT survey
* --------------------------------------------------------------------------

* These following parameters help describe the survey protocol
* with regard to whether they:
* a) skipped going to health centers to find TT records 
*    (TT_RECORDS_NOT_SOUGHT 1)
* b) looked for records for all respondents 
*    (TT_RECORDS_SOUGHT_FOR_ALL 1)
* c) looked for records for women who didn't present vaccination cards
*    during the household interview 
*    (TT_RECORDS_SOUGHT_IF_NO_CARD 1)
*
* These are mutually exclusive, so only one of them should be set to 1.
* (the code checks that condition later)

vcqi_global TT_RECORDS_NOT_SOUGHT        0
vcqi_global TT_RECORDS_SOUGHT_FOR_ALL    0
vcqi_global TT_RECORDS_SOUGHT_IF_NO_CARD 1

* --------------------------------------------------------------------------
* Parameters to describe the analysis being requested
* --------------------------------------------------------------------------

* Name the datasets that give geographic names of the various strata
* and list the order in which strata should appear in tabular output.
* See Annex B of the VCQI User's Guide

vcqi_global LEVEL2_ORDER_DATASET ${VCQI_DATA_FOLDER}/level2order
vcqi_global LEVEL3_ORDER_DATASET ${VCQI_DATA_FOLDER}/level3order

vcqi_global LEVEL1_NAME_DATASET ${VCQI_DATA_FOLDER}/level1name
vcqi_global LEVEL2_NAME_DATASET ${VCQI_DATA_FOLDER}/level2names
vcqi_global LEVEL3_NAME_DATASET ${VCQI_DATA_FOLDER}/level3names

* The user can ask for results to be broken out by levels of 
* a) a single demographic stratifier (like urban/rural), or
* b) a set of several stratifiers (like urban/rural and sex and household wealth)
*
* If the user requests a single stratifier  
* then the stratifier will appear in inchworm and unweighted proportion 
* plots as well as VCQI tables.

* But if the user requests two or more stratifiers  
* then inchworm plots and unweighted proportion plots are not generated for 
* this run.  The stratifiers will appear only in VCQI tables, but not plots.  
* (*UNLESS* the user also asks VCQI to PLOT_OUTCOMES_IN_TABLE_ORDER.)

* List of demographic variables for stratified tables (can be left blank)
vcqi_global VCQI_LEVEL4_SET_VARLIST urban_cluster

* Name of dataset that documents the user's preferred order and 
* row labels for LEVEL4 strata
* (VCQI will generate a layout file if one is not specified; you may
*  copy VCQI's file, edit it, move it to the input dataset folder and
*  then point to it here during later VCQI runs.)

vcqi_global VCQI_LEVEL4_SET_LAYOUT ${VCQI_DATA_FOLDER}/VCQI_LEVEL4_SET_LAYOUT_urban_cluster

* These globals control how the output looks in the tabulated dataset 
* from the 05TO programs; see Annex B in the VCQI User's Guide.

vcqi_global SHOW_LEVEL_1_ALONE         1
vcqi_global SHOW_LEVEL_2_ALONE         0
vcqi_global SHOW_LEVEL_3_ALONE         0
vcqi_global SHOW_LEVEL_4_ALONE         0
vcqi_global SHOW_LEVELS_2_3_TOGETHER   1

vcqi_global SHOW_LEVELS_1_4_TOGETHER   1
vcqi_global SHOW_LEVELS_2_4_TOGETHER   0
vcqi_global SHOW_LEVELS_3_4_TOGETHER   0
vcqi_global SHOW_LEVELS_2_3_4_TOGETHER 0

vcqi_global SHOW_BLANKS_BETWEEN_LEVELS 1

* User specifies the Stata svyset syntax to describe the complex sample
vcqi_global VCQI_SVYSET_SYNTAX svyset clusterid, strata(stratumid) weight(psweight) singleunit(scaled)

* User specifies the method for calculating confidence intervals
* Valid choices are LOGIT, WILSON, JEFFREYS or CLOPPER; our default 
* recommendation is WILSON.

vcqi_global VCQI_CI_METHOD WILSON

* Specify whether the code should export to excel, or not (usually 1)

vcqi_global EXPORT_TO_EXCEL 				1

* Specify if you would like the excel columns to be narrow in Tabulated output
* Set to 1 for yes - The code to do this is a little slow
vcqi_global MAKE_EXCEL_COLUMNS_NARROW 		0

* User specifies the number of digits after the decimal place in coverage
* outcome tables and plots

vcqi_global VCQI_NUM_DECIMAL_DIGITS			1

* Specify whether the code should make plots, or not (usually 1)

* MAKE_PLOTS must be 1 for any plots to be made
vcqi_global MAKE_PLOTS      				1

* Make inchworm plots? Set to 1 for yes.
vcqi_global VCQI_MAKE_IW_PLOTS				1
vcqi_global VCQI_MAKE_LEVEL2_IWPLOTS		0

* IWPLOT_SHOWBARS = 0 means show inchworm distributions
* IWPLOT_SHOWBARS = 1 means show horizontal bars instead of inchworms

vcqi_global IWPLOT_SHOWBARS					0

* Make unweighted sample proportion plots? Set to 1 for yes.
vcqi_global VCQI_MAKE_UW_PLOTS				1
vcqi_global VCQI_MAKE_LEVEL2_UWPLOTS		0

* Make organ pipe plots? Set to 1 for yes.
vcqi_global VCQI_MAKE_OP_PLOTS				1

* Save the data underlying each organ pipe plot?  Set to 1 for yes.
*
* Recall that organ pipe plots are very spare, and do not list the cluster id
* for any of the bars
*
* If this option is turned on, (set to 1) then the organ pipe plot program 
* will save a dataset in the Plots_OP folder for each plot.  The dataset will 
* list the cluster id for each bar in the plot along with its height and 
* width.  This makes it possible to identify precisely which cluster id goes
* with which bar in the plot.

vcqi_global VCQI_SAVE_OP_PLOT_DATA			1

* Specify whether the code should save Stata .gph files when making plots.
* Usually 0.  These files are only made if MAKE_PLOTS is 1.  
* Set to 1 if you want to be able to edit plots in the Stata Graph Editor
* or re-export them in a different size or graphic file format.

vcqi_global SAVE_VCQI_GPH_FILES				1

* Specify whether the code should save VCQI output databases
*
* WARNING!! If this macro is set to 1, VCQI will delete ALL files that
* end in _database.dta in the VCQI_OUTPUT_FOLDER at the end of the run
* If you want to save the databased, change the value to 0.
* (Usually 1)

vcqi_global DELETE_VCQI_DATABASES_AT_END	1

* Specify whether the code should delete intermediate datasets 
* at the end of the analysis (Usually 1)
* If you wish to keep them for additional analysis or debugging,
* set the option to 0.

vcqi_global DELETE_TEMP_VCQI_DATASETS		1

********************************************************************************
* Code Block: TT-E                                               (Do not change)
*-------------------------------------------------------------------------------
*                  Pre-process survey data
*-------------------------------------------------------------------------------

if "$VCQI_CHECK_INSTEAD_OF_RUN" == "1" {
	vcqi_log_comment $VCP 3 Comment "The user has requested a check instead of a run."
	vcqi_global VCQI_PREPROCESS_DATA	0
	vcqi_global VCQI_GENERATE_DVS		0
	vcqi_global VCQI_GENERATE_DATABASES 0
	vcqi_global EXPORT_TO_EXCEL			0
	vcqi_global	MAKE_PLOTS				0
}

check_TT_schedule_metadata
check_TT_survey_metadata
check_TT_analysis_metadata

establish_unique_TT_ids


********************************************************************************
* Code Block: TT-F                                             (User may change)
*-------------------------------------------------------------------------------
*                  Calculate VCQI indicators requested by the user
*-------------------------------------------------------------------------------

* This is a counter that is used to name datasets...the user might change it
* if requesting repeat analyses with differing parameters - see the user's 
* guide

vcqi_global ANALYSIS_COUNTER 1

* Okay...all the preparatory work is complete...now conduct the analysis
* by running the TT_COVG_01 indicator and (optionally) the DESC_XX
* indicators and COVG_DIFF_XX indicators.
*
* The indicators may be run in any order the user wishes.
* 
* We recommend running DESC indicators first, followed by TT_COVG_01
* followed by COVG_DIFF

* Describe the TT dataset
vcqi_global DESC_01_DATASET TT
		
vcqi_global DESC_01_TO_TITLE    TT Survey Sample Summary
vcqi_global DESC_01_TO_SUBTITLE
vcqi_global DESC_01_TO_FOOTNOTE_1  Abbreviations: HH = Households	

DESC_01 

* -------------------------------------------------------------------
* Summarize some responses to multiple-choice questions using DESC_02
* -------------------------------------------------------------------

* Proportion of women who received ante-natal care
vcqi_global DESC_02_DATASET 	TT
vcqi_global DESC_02_VARIABLES 	TT18
vcqi_global DESC_02_WEIGHTED	YES
vcqi_global DESC_02_DENOMINATOR	ALL

vcqi_global DESC_02_TO_TITLE 	 Women Received Ante-Natal Care
* No subtitle
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* Who did they see for care?  (unweighted)
vcqi_global DESC_02_DATASET 	TT
vcqi_global DESC_02_VARIABLES 	TT19
vcqi_global DESC_02_WEIGHTED	NO
vcqi_global DESC_02_DENOMINATOR	RESPONDED

vcqi_global DESC_02_TO_TITLE 	 Who Provided Ante-Natal Care?
*No subtitle or extra footnote
vcqi_global DESC_02_TO_SUBTITLE
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* Where were the babies delivered?
vcqi_global DESC_02_DATASET 	TT
vcqi_global DESC_02_VARIABLES 	TT22
vcqi_global DESC_02_WEIGHTED	YES
vcqi_global DESC_02_DENOMINATOR	ALL

vcqi_global DESC_02_TO_TITLE 	 Place of Delivery
*No subtitle or extra footnote
vcqi_global DESC_02_TO_SUBTITLE
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* Who attended the delivery?
vcqi_global DESC_02_DATASET 	TT
vcqi_global DESC_02_VARIABLES 	TT24
vcqi_global DESC_02_WEIGHTED	YES
vcqi_global DESC_02_DENOMINATOR	ALL

vcqi_global DESC_02_TO_TITLE 	 Who Attended the Birth?
*No subtitle or extra footnote
vcqi_global DESC_02_TO_SUBTITLE
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* Rec'd a vaccination card (weighted)
vcqi_global DESC_02_DATASET 	TT
vcqi_global DESC_02_VARIABLES 	TT26
vcqi_global DESC_02_WEIGHTED	YES
vcqi_global DESC_02_DENOMINATOR	ALL

vcqi_global DESC_02_TO_TITLE 	 Woman Received an Ante-Natal Vaccination Card
*No subtitle or extra footnote
vcqi_global DESC_02_TO_SUBTITLE
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* If only 0 or 1 lifetime doses, why? (unweighted)
vcqi_global DESC_02_DATASET 	TT
vcqi_global DESC_02_VARIABLES 	TT43
vcqi_global DESC_02_WEIGHTED	NO
vcqi_global DESC_02_DENOMINATOR	RESPONDED

vcqi_global DESC_02_TO_TITLE 	 Why Have You Received Fewer Than Two Lifetime TT Doses?
*No subtitle or extra footnote
vcqi_global DESC_02_TO_SUBTITLE
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* -------------------------------------------------------------------
* Estimate % protected at birth (PAB)
* -------------------------------------------------------------------

vcqi_global TT_COVG_01_TO_TITLE    Protected at Birth from Neonatal Tetanus
vcqi_global TT_COVG_01_TO_SUBTITLE
vcqi_global TT_COVG_01_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global TT_COVG_01_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

TT_COVG_01

* -------------------------------------------------------------------
* Test some hypotheses
*
* Note that the COVG_DIFF_01 and _02 indicators specify their own titles
* but the user may specify a sub-title and footnotes.
*
* Note also that ALL of the COVG_DIFF_01 output appears in a single table,
* even if you do many tests, so 
* a) only one subtitle will be displayed for the table, and 
* b) the footnotes should be clear about which
* tests they are describing.  And footnotes should all have consecutive 
* numbers; do not start at _1 again when you conduct a new test.
*-------------------------------------------------------------------
* The first hypothesis to test: 
* Null: PAB Coverage is equal between the northern and southern province
* Alt : PAB coverage differs between them

* Because this is a test BETWEEN two strata, we will use COVG_DIFF_01

* Specify inputs to test this hypothesis: 
* Provinces are level 2 strata
vcqi_global COVG_DIFF_01_STRATUM_LEVEL 2

vcqi_global COVG_DIFF_01_ANALYSIS_COUNTER 1

* We will specify the strata by name (alternative would be ID)
vcqi_global COVG_DIFF_01_ID_OR_NAME NAME

* Names of the two strata to compare
vcqi_global COVG_DIFF_01_STRATUM_NAME1 NORTHERN PROVINCE
vcqi_global COVG_DIFF_01_STRATUM_NAME2 SOUTHERN PROVINCE

* Name of the indicator that calculated the variable to compare
vcqi_global COVG_DIFF_01_INDICATOR TT_COVG_01

* Name of the variable to compare between strata
vcqi_global COVG_DIFF_01_VARIABLE protected_at_birth_to_analyze

vcqi_global COVG_DIFF_01_TO_FOOTNOTE_1 Abbreviations: CI = Confidence Interval

* Now conduct the comparison, posting results in the COVG_DIFF_01
* dataset; the results will be written to the spreadsheet file 
* after all comparisons are finished and we run vcqi_halt_immediately

COVG_DIFF_01

*-------------------------------------------------------------------

* Here is a second hypothesis to test:
* Null: PAB coverage is equal between two level 3 strata: 
* District 01 vs. District 09
* Alt : PAB coverage differs between the two

* Inputs to set up the test
vcqi_global COVG_DIFF_01_STRATUM_LEVEL 3

vcqi_global COVG_DIFF_01_ID_OR_NAME NAME

vcqi_global COVG_DIFF_01_STRATUM_NAME1 District 01
vcqi_global COVG_DIFF_01_STRATUM_NAME2 District 09

vcqi_global COVG_DIFF_01_INDICATOR TT_COVG_01
vcqi_global COVG_DIFF_01_VARIABLE protected_at_birth_to_analyze

COVG_DIFF_01

*-------------------------------------------------------------------

* Here is a third hypothesis:
* Null: PAB coverage is equal between urban and rural clusters within Province 1
* Alt : PAB coverage differs

* Because this is a test WITHIN a stratum, we will use COVG_DIFF_02

vcqi_global COVG_DIFF_02_ID_OR_NAME ID

vcqi_global COVG_DIFF_02_STRATUM_LEVEL 2

vcqi_global COVG_DIFF_02_STRATUM_ID 1

vcqi_global COVG_DIFF_02_INDICATOR TT_COVG_01

vcqi_global COVG_DIFF_02_ANALYSIS_COUNTER 1

vcqi_global COVG_DIFF_02_VARIABLE protected_at_birth_to_analyze

vcqi_global COVG_DIFF_02_SUBPOP_VARIABLE urban_cluster
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL1 0
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL2 1

vcqi_global COVG_DIFF_02_TO_FOOTNOTE_1 Abbreviations: CI = Confidence Interval

COVG_DIFF_02

*-------------------------------------------------------------------

* A fourth hypothesis
* Null: PAB coverage is equal between women who did and did not have 
*       ante-natal care in the Southern Province
* Alt:  PAB coverage differs between those two sub-groups

vcqi_global COVG_DIFF_02_ID_OR_NAME name

vcqi_global COVG_DIFF_02_STRATUM_LEVEL 2

vcqi_global COVG_DIFF_02_STRATUM_NAME Southern Province

vcqi_global COVG_DIFF_02_INDICATOR TT_COVG_01

vcqi_global COVG_DIFF_02_ANALYSIS_COUNTER 1

vcqi_global COVG_DIFF_02_VARIABLE protected_at_birth_to_analyze

* TT18 codes whether they had ANC; 1 = yes and 2 = no
vcqi_global COVG_DIFF_02_SUBPOP_VARIABLE TT18 
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL1 1 
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL2 2

COVG_DIFF_02

********************************************************************************
* Code Block: TT-G                                               (Do not change)
*-------------------------------------------------------------------------------
*                  Exit gracefully
*-------------------------------------------------------------------------------
*
* Close the datasets that hold the results of 
* hypothesis tests, and put them into the output spreadsheet
*
* Close the log file and put it into the output spreadsheet
*
* Clean up extra files
* 
* Send a message to the screen if there are warnings or errors in the log

vcqi_cleanup

********************************************************************************

$VCQI____END_OF_PROGRAM

* Output to the log window is suppressed by the command $VCQI____END_OF_PROGRAM
* (which is an alias for "set output error")

* So this change log in block H will not appear when the user runs VCQI

********************************************************************************
* Code Block: TT-H                                               (Do not change)
*-------------------------------------------------------------------------------
* Change log 
* 				Updated 
*				version 
* Date 			number 	Name			What Changed 
* 2020-01-16	1.00	Dale Rhoda		Version as of 2020-01-16
* 2020-04-09	1.01	Dale Rhoda		Add VCQI____END_OF_PROGRAM to 
*                                       suppress showing this change log
*                                       in the VCQI log window after showing
*                                       the VCQI ASCCI art.
* 2020-12-09	1.02	Dale Rhoda		Allow the user to plot strata in table order
* 2020-12-12	1.03	Dale Rhoda		Allow user to SHOW_LEVEL_4_ONLY
*                                       and update test dataset to 2020-10-16
*                                       which is Harmonia instead of 
*                                       Sassafrippi
******************************************************************************** 

* turn on normal output to the log window again
set output proc
