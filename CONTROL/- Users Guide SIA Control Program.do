********************************************************************************
* Vaccination Coverage Quality Indicators (VCQI) control program to analyze
* data from a supplemental immunization activity (SIA) survey 
*
*
* Program example and template for the VCQI User's Guide
*
* Written by Biostat Global Consulting
*
* Updated 2017-02-15
*
* The user might customize this program by changing items below in the
* code blocks marked SIA-B, SIA-D, and SIA-F below.  Those blocks are
* marked "(User may change)".
*
*
********************************************************************************
* Code Block: SIA-A                                              (Do not change)
*-------------------------------------------------------------------------------
*                  Start with clear memory
*-------------------------------------------------------------------------------

set more off

clear all

macro drop _all
	
********************************************************************************
* Code Block: SIA-B                                            (User may change)
*-------------------------------------------------------------------------------
*                  Specify input/output folders & analysis name
*-------------------------------------------------------------------------------

* Where should the programs look for datasets?
global VCQI_DATA_FOLDER    Q:/- Folders shared outside BGC/BGC Team - WHO Software/Test datasets/2016-02-24

* Where should the programs put output?
global VCQI_OUTPUT_FOLDER     Q:/- Folders shared outside BGC/BGC Team - WHO Software/Working folder - Dale/VCQI test output

* Establish analysis name (used in log file name and Excel file name)

global VCQI_ANALYSIS_NAME SIA_Test

********************************************************************************
* Code Block: SIA-C                                              (Do not change)
*-------------------------------------------------------------------------------
*                  CD to output folder & open VCQI log
*-------------------------------------------------------------------------------

cd "${VCQI_OUTPUT_FOLDER}"

* Start with a clean, empty Excel file for tabulated output (TO)
capture erase "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx"

* Give the current program a name, for logging purposes
global VCP SIA_Control_Program

* Open the VCQI log and put a comment in it
vcqi_log_comment $VCP 3 Comment "Run begins...log opened..."
	
* Document the global macros that were defined before the log opened
vcqi_log_global VCQI_DATA_FOLDER
vcqi_log_global VCQI_OUTPUT_FOLDER
vcqi_log_global VCQI_ANALYSIS_NAME

* Write an entry in the log file for each program, noting its version number

vcqi_log_all_program_versions

********************************************************************************
* Code Block: SIA-D                                            (User may change)
*-------------------------------------------------------------------------------
*                  Specify dataset names and important metadata
*-------------------------------------------------------------------------------

* Names of datasets that hold SIA data
vcqi_global VCQI_CM_DATASET     CM_SIA_faux_dataset
vcqi_global VCQI_SIA_DATASET    SIA_faux_dataset

* If you will describe the dataset using DESC_01 then you will also need
* to specify the names of the HH & HM datasets

vcqi_global VCQI_HH_DATASET     HH_faux_dataset
vcqi_global VCQI_HM_DATASET     HM_faux_dataset

* ---------------------------------------------------
* Parameters to describe survey
* This survey coded a variable for whether the fingermark was
* seen and so we can report results by fingermark as well as 
* card and history

vcqi_global SIA_FINGERMARKS_SOUGHT 1

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

vcqi_global SHOW_LEVEL_1_ALONE         0
vcqi_global SHOW_LEVEL_2_ALONE         0
vcqi_global SHOW_LEVEL_3_ALONE         0 
vcqi_global SHOW_LEVELS_2_3_TOGETHER   0

vcqi_global SHOW_LEVELS_1_4_TOGETHER   1
vcqi_global SHOW_LEVELS_2_4_TOGETHER   0
vcqi_global SHOW_LEVELS_3_4_TOGETHER   0
vcqi_global SHOW_LEVELS_2_3_4_TOGETHER 1

vcqi_global SHOW_BLANKS_BETWEEN_LEVELS 1

* User specifies the method for calculating confidence intervals
* Valid choices are LOGIT, WILSON, JEFFREYS or CLOPPER; our default 
* recommendation is WILSON.

vcqi_global VCQI_CI_METHOD WILSON

* Specify whether the code should export to excel, or not (usually 1)

vcqi_global EXPORT_TO_EXCEL 				1

* The code to format excel is a little slow, so give an option to turn it off
* when debugging (usually 1)

vcqi_global FORMAT_EXCEL    				1

* Specify whether the code should make plots, or not (usually 1)

* MAKE_PLOTS must be 1 for any plots to be made
vcqi_global MAKE_PLOTS      				1

* Make inchworm plots? Set to 1 for yes.
vcqi_global VCQI_MAKE_IW_PLOTS				1
vcqi_global VCQI_MAKE_LEVEL2_IWPLOTS		0

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

* Set this globlal to 1 to test all metadata and code that makes
* datasets and calculates derived variables...without running the
* indicators or generating output

vcqi_global	VCQI_CHECK_INSTEAD_OF_RUN		0

********************************************************************************
* Code Block: SIA-E                                              (Do not change)
*-------------------------------------------------------------------------------
*                  Pre-process survey data
*-------------------------------------------------------------------------------

* Prepare to do SIA analysis

check_SIA_schedule_metadata
check_SIA_survey_metadata
check_SIA_analysis_metadata
establish_unique_SIA_ids

if "$VCQI_CHECK_INSTEAD_OF_RUN" == "1" {
	vcqi_log_comment $VCP 3 Comment "The user has requested a check instead of a run."
	vcqi_global VCQI_PREPROCESS_DATA	0
	vcqi_global VCQI_GENERATE_DVS		0
	vcqi_global VCQI_GENERATE_DATABASES 0
	vcqi_global EXPORT_TO_EXCEL			0
	vcqi_global	MAKE_PLOTS				0
}

********************************************************************************
* Code Block: SIA-F                                            (User may change)
*-------------------------------------------------------------------------------
*                  Calculate VCQI indicators requested by the user
*-------------------------------------------------------------------------------

* This is a counter that is used to name datasets...the user might change it
* if requesting repeat analyses with differing parameters - see the user's 
* guide

vcqi_global ANALYSIS_COUNTER 1

* Okay...all the preparatory work is complete...now conduct the analysis
* by running the SIA indicators and (optionally) the DESC_XX
* indicators and COVG_DIFF_XX indicators.
*
* The indicators may be run in any order the user wishes.
* 
* We recommend running DESC indicators first, followed by SIA indicators,
* followed by COVG_DIFF

* Describe the SIA dataset

vcqi_global DESC_01_DATASET 	SIA
vcqi_global DESC_01_TO_TITLE    SIA Survey Sample Summary
vcqi_global DESC_01_TO_SUBTITLE
vcqi_global DESC_01_FOOTNOTE_1  Abbreviations: HH = Households	

DESC_01 

* ----------------------------------------------------------------------
* Summarize responses to some multiple-choice questions using DESC_02
* ----------------------------------------------------------------------
		
* What proportion of the respondents sampled were away
* when the campaign happened?  (simple unweighted sample proportion)

vcqi_global DESC_02_DATASET 	SIA
vcqi_global DESC_02_VARIABLES 	SIA17
vcqi_global DESC_02_WEIGHTED	NO
vcqi_global DESC_02_DENOMINATOR	ALL

vcqi_global DESC_02_TO_TITLE 	 Child was here when campaign happened
* Clear out the SUBTITLE in case it was previously used.
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 
	
DESC_02

* How did people hear about the campaign?
vcqi_global DESC_02_VARIABLES	SIA18

vcqi_global DESC_02_TO_TITLE 	 Sources of information about the campaign
* Clear out the SUBTITLE in case it was previously used.
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 

DESC_02

* If the child did not receive the vaccine, why?
vcqi_global DESC_02_VARIABLES	SIA25

vcqi_global DESC_02_TO_TITLE 	 Reasons for non-vaccination in the campaign
* Clear out the SUBTITLE in case it was previously used.
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 

DESC_02

* Had they already received a dose before the campaign?

* Do a weighted estimate, and generate a subtotal variable
* to summarize the two 'yes' answers.
vcqi_global DESC_02_VARIABLES			SIA27
vcqi_global DESC_02_WEIGHTED			YES
vcqi_global DESC_02_N_SUBTOTALS			1
vcqi_global	DESC_02_SUBTOTAL_LEVELS_1	1 2
vcqi_global DESC_02_SUBTOTAL_LABEL_1	Yes

vcqi_global DESC_02_TO_TITLE 	 Received the vaccine before the campaign
* Clear out the SUBTITLE in case it was previously used.
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 

DESC_02
* Reset the SUBTOTALS globals
vcqi_global DESC_02_N_SUBTOTALS	
vcqi_global DESC_02_SUBTOTAL_LEVELS_1 
vcqi_global DESC_02_SUBTOTAL_LABEL_1 

* Run the four SIA analyses

vcqi_global SIA_COVG_01_TO_TITLE       Vaccinated During SIA
vcqi_global SIA_COVG_01_TO_SUBTITLE
	
vcqi_global SIA_COVG_01_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global SIA_COVG_01_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.

SIA_COVG_01

vcqi_global SIA_COVG_02_TO_TITLE       SIA Provided Child's First Measles Dose
vcqi_global SIA_COVG_02_TO_SUBTITLE
	
vcqi_global SIA_COVG_02_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global SIA_COVG_02_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.

SIA_COVG_02

* Minimum and maximum age to participate 
* in the SIA - expressed in days (9m to 15 years)
* These parameters define the first and last birth cohort for SIA_COVG_03

vcqi_global SIA_MIN_AGE `=9*30'
vcqi_global SIA_MAX_AGE `=int(15*365.25)'

vcqi_global SIA_COVG_03_TO_TITLE       Lifetime MCV Doses, by birth cohort
vcqi_global SIA_COVG_03_TO_SUBTITLE
	
vcqi_global SIA_COVG_03_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global SIA_COVG_03_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights. 

SIA_COVG_03
	
vcqi_global SIA_QUAL_01_TO_TITLE    Vaccinated Respondent Received SIA Card
vcqi_global SIA_QUAL_01_TO_SUBTITLE
	
vcqi_global SIA_QUAL_01_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.

SIA_QUAL_01

* --------------------------------------------------------------------------
* Now do hypothesis tests
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
* --------------------------------------------------------------------------

* SIA Coverage is equal between provinces

vcqi_global COVG_DIFF_01_STRATUM_LEVEL 2
vcqi_global COVG_DIFF_01_ANALYSIS_COUNTER 1

vcqi_global COVG_DIFF_01_ID_OR_NAME NAME

vcqi_global COVG_DIFF_01_STRATUM_NAME1 UPPER PROVINCE
vcqi_global COVG_DIFF_01_STRATUM_NAME2 LOWER PROVINCE

vcqi_global COVG_DIFF_01_INDICATOR SIA_COVG_01
vcqi_global COVG_DIFF_01_VARIABLE got_sia_dose

vcqi_global COVG_DIFF_01_TO_FOOTNOTE_1 Abbreviations: CI = Confidence Interval

COVG_DIFF_01

***********************
* SIA is first dose coverage is equal between two districts:
* Rosebud and Dongolocking

vcqi_global COVG_DIFF_01_STRATUM_LEVEL 3
vcqi_global COVG_DIFF_01_STRATUM_NAME1 Rosebud
vcqi_global COVG_DIFF_01_STRATUM_NAME2  Dongolocking

vcqi_global COVG_DIFF_01_ID_OR_NAME NAME

vcqi_global COVG_DIFF_01_INDICATOR SIA_COVG_02
vcqi_global COVG_DIFF_01_VARIABLE sia_is_first_measles_dose

COVG_DIFF_01

* ---------------------------------------------------
* campaign card coverage is equal between urban and rural within Province 1

vcqi_global COVG_DIFF_02_ID_OR_NAME ID
vcqi_global COVG_DIFF_02_STRATUM_LEVEL 2

vcqi_global COVG_DIFF_02_STRATUM_ID 1

vcqi_global COVG_DIFF_02_INDICATOR SIA_QUAL_01
vcqi_global COVG_DIFF_02_ANALYSIS_COUNTER 1

vcqi_global COVG_DIFF_02_VARIABLE got_campaign_card

vcqi_global COVG_DIFF_02_SUBPOP_VARIABLE urban_cluster
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL1 0
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL2 1

vcqi_global COVG_DIFF_02_TO_FOOTNOTE_1 Abbreviations: CI = Confidence Interval

COVG_DIFF_02

* ---------------------------------------------------
* campaign card coverage is equal between urban and rural in the Lower Province

vcqi_global COVG_DIFF_02_ID_OR_NAME name
vcqi_global COVG_DIFF_02_STRATUM_LEVEL 2

vcqi_global COVG_DIFF_02_STRATUM_NAME lower province

vcqi_global COVG_DIFF_02_INDICATOR SIA_QUAL_01
vcqi_global COVG_DIFF_02_ANALYSIS_COUNTER 1

vcqi_global COVG_DIFF_02_VARIABLE got_campaign_card

vcqi_global COVG_DIFF_02_SUBPOP_VARIABLE urban_cluster
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL1 0
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL2 1

COVG_DIFF_02

********************************************************************************
* Code Block: SIA-G                                              (Do not change)
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

