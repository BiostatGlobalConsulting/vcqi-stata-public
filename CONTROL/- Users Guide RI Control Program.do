*! - Users Guide RI Control Program version 1.05 - Biostat Global Consulting - 2021-01-05
********************************************************************************
* Vaccination Coverage Quality Indicators (VCQI) control program to analyze
* data from a routine immunization survey 
*
*
* Program example and template for the VCQI User's Guide
*
* Written by Biostat Global Consulting
*
* See bottom of program for log of program updates
*
* The user might customize this program by changing items below in the
* code blocks marked RI-B, RI-D, and RI-F below.  Those blocks are
* marked "(User may change)".
* 
********************************************************************************
* Code Block: RI-A                                               (Do not change)
*-------------------------------------------------------------------------------
*                  Start with clear memory
*-------------------------------------------------------------------------------

set more off

clear all

macro drop _all

********************************************************************************
* Code Block: RI-B                                            (User may change)
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
global VCQI_DATA_FOLDER    	Q:/- Folders shared outside BGC/BGC Team - WHO Software/Test datasets/2020-10-16

* Where should the programs put output?
global VCQI_OUTPUT_FOLDER   Q:/- Folders shared outside BGC/BGC Team - WHO Software/Working folder - Dale/VCQI test output/RI test

* Establish analysis name (used in log file name and Excel file name)

global VCQI_ANALYSIS_NAME RI_Test

* Set this global to 1 to test all metadata and code that makes
* datasets and calculates derived variables...without running the
* indicators or generating output

global	VCQI_CHECK_INSTEAD_OF_RUN		0

********************************************************************************
* Code Block: RI-C                                               (Do not change)
*-------------------------------------------------------------------------------
*                  Put VCQI in the Stata Path and
*                CD to output folder & open VCQI log
*-------------------------------------------------------------------------------

* CD to the output folder and start the log 
cd "${VCQI_OUTPUT_FOLDER}"

* Start with a clean, empty Excel file for tabulated output (TO)
capture erase "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx"

* Give the current program a name, for logging purposes
global VCP RI_Control_Program

* Open the VCQI log and put a comment in it
vcqi_log_comment $VCP 3 Comment "Run begins...log opened..."
	
* Document the global macros that were defined before the log opened
vcqi_log_global VCQI_DATA_FOLDER
vcqi_log_global VCQI_OUTPUT_FOLDER
vcqi_log_global VCQI_ANALYSIS_NAME

* Write an entry in the log file for each program, noting its version number

vcqi_log_all_program_versions

********************************************************************************
* Code Block: RI-D                                             (User may change)
*-------------------------------------------------------------------------------
*                  Specify dataset names and important metadata
*-------------------------------------------------------------------------------

* Name of datasets that hold RI data
vcqi_global VCQI_RI_DATASET     RI_mdy
vcqi_global VCQI_RIHC_DATASET 	RIHC_mdy

* Name of dataset that holds cluster metadata
vcqi_global VCQI_CM_DATASET     CM_faux_dataset

* If you will describe the dataset using DESC_01 then you need to also specify
* the HH and HM datasets

vcqi_global VCQI_HH_DATASET     HH_faux_dataset
vcqi_global VCQI_HM_DATASET     HM_faux_dataset

* --------------------------------------------------------------------------
* Parameters to describe RI schedule 
* --------------------------------------------------------------------------
* These parameters may change from survey to survey

* See:
* http://www.who.int/immunization/policy/Immunization_routine_table2.pdf?ua=1 
* http://apps.who.int/immunization_monitoring/globalsummary/schedules

* Single-dose antigens will use a parameter named <dose>_min_age_days (required)
* Single-dose antigens may  use a parameter named <dose>_max_age_days (optional)
* Note: If a dose is not considered valid *AFTER* a certain age, then specify
*       that maximum valid age using the _max_age_days parameter.
*       If the dose is considered late, but still valid, then do not specify
*       a maximum age.


scalar bcg_min_age_days 		= 0  // birth dose
scalar hepb_min_age_days 		= 0  // birth dose
scalar opv0_min_age_days 		= 0  // birth dose

* Note: In this country, opv0 and hepb0 are only considered valid 
*       if given in the first two weeks of life
scalar opv0_max_age_days 		= 14  // birth dose
scalar hepb_max_age_days 		= 14  // birth dose

scalar penta1_min_age_days 		= 42  // 6 weeks
scalar pcv1_min_age_days 		= 42  // 6 weeks
scalar opv1_min_age_days 		= 42  // 6 weeks
scalar rota1_min_age_days 		= 42  // 6 weeks

scalar penta2_min_age_days 		= 70  // 10 weeks
scalar penta2_min_interval_days = 28  // 4 weeks
scalar pcv2_min_age_days 		= 70  // 10 weeks
scalar pcv2_min_interval_days 	= 28  // 4 weeks
scalar opv2_min_age_days 		= 70  // 10 weeks
scalar opv2_min_interval_days 	= 28  // 4 weeks
scalar rota2_min_age_days 		= 70  // 10 weeks
scalar rota2_min_interval_days 	= 28  // 4 weeks

scalar penta3_min_age_days 		= 98  // 14 weeks
scalar penta3_min_interval_days = 28  // 4 weeks
scalar pcv3_min_age_days 		= 98  // 14 weeks
scalar pcv3_min_interval_days 	= 28  // 4 weeks
scalar opv3_min_age_days 		= 98  // 14 weeks
scalar opv3_min_interval_days 	= 28  // 4 weeks
scalar rota3_min_age_days 		= 98  // 14 weeks
scalar rota3_min_interval_days 	= 28  // 4 weeks

scalar ipv_min_age_days 		= 98  // 14 weeks; may be co-administered w/ OPV

scalar mcv1_min_age_days 		= 270  // 9 months
scalar yf_min_age_days 			= 270  // 9 months

* --------------------------------------------------------------------------
* Parameters to describe survey
* --------------------------------------------------------------------------
* Specify the earliest and latest possible vaccination date for this survey.
*
* The software assumes this survey includes birth doses, so the earliest date
* is the first possible birthdate for RI survey respondents and the latest
* date is the last possible vaccination date for this dataset - the latest
* date might be the date that the survey ended.
 
vcqi_global EARLIEST_SVY_VACC_DATE_M  	1
vcqi_global EARLIEST_SVY_VACC_DATE_D  	1
vcqi_global EARLIEST_SVY_VACC_DATE_Y  	2013
 
vcqi_global LATEST_SVY_VACC_DATE_M  	1
vcqi_global LATEST_SVY_VACC_DATE_D  	1
vcqi_global LATEST_SVY_VACC_DATE_Y  	2015

* These parameters indicate the eligible age range for survey respondents
* (age expressed in days)

vcqi_global VCQI_RI_MIN_AGE_OF_ELIGIBILITY 365
vcqi_global VCQI_RI_MAX_AGE_OF_ELIGIBILITY 729

* These following parameters help describe the survey protocol
* with regard to whether they:
* a) skipped going to health centers to find RI records (RI_RECORDS_NOT_SOUGHT 1)
* b) looked for records for all respondents (RI_RECORDS_SOUGHT_FOR_ALL 1)
* c) looked for records for women who didn't present vaccination cards
*    during the household interview (RI_RECORDS_SOUGHT_IF_NO_CARD 1)
*
* These are mutually exclusive, so only one of them should be set to 1.
* 
vcqi_global RI_RECORDS_NOT_SOUGHT        0
vcqi_global RI_RECORDS_SOUGHT_FOR_ALL    0
vcqi_global RI_RECORDS_SOUGHT_IF_NO_CARD 1

* --------------------------------------------------------------------------
* Which doses should be included in the analysis?
* --------------------------------------------------------------------------

* Note that these abbreviations must correspond to those used in the
* names of the dose date and dose tick variables *AND* the names used 
* above in the schedule scalars (<dose>_min_age_days and 
* <dose>_min_interval_days and <dose>_max_days.  The variables are 
* named using lower-case acronyms.  The globals here may be upper or
* mixed case...they will be converted to lower case in the software.
*
vcqi_global RI_SINGLE_DOSE_LIST  BCG HEPB OPV0 IPV MCV1 YF
vcqi_global RI_MULTI_2_DOSE_LIST 
vcqi_global RI_MULTI_3_DOSE_LIST PENTA PCV OPV ROTA

* --------------------------------------------------------------------------
* Do you want to shift doses?
* --------------------------------------------------------------------------

* Populate the below globals to indicate if you would like to dose shift. 
* This can be done with multi-dose vaccines and/or boosters.
* This will need to be completed for each dose shift.
vcqi_global NUM_DOSE_SHIFTS 0	// Number of times you would like to run the date shifting program.
								// Program must run separately for each dose group
								// Wipe out or set to 0 if you do not wish to complete any date shifts
								
vcqi_global SHIFTTO_1 		penta1 penta2 penta3	//Provide dose list that will have SHIFTFROM doses pushed forward if missing
vcqi_global SHIFTFROM_1 	penta4 penta5			//Provide dose name of doses to shift forward into SHIFTTO list

vcqi_global SHIFTTO_2 		polio1 polio2 polio3	//Provide dose list that will have SHIFTFROM doses pushed forward if missing
vcqi_global SHIFTFROM_2 	polio4 polio5			//Provide dose name of doses to shift forward into SHIFTTO list

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
vcqi_global MAKE_EXCEL_COLUMNS_NARROW 		1

* User specifies the number of digits after the decimal place in coverage
* outcomes

vcqi_global VCQI_NUM_DECIMAL_DIGITS			1

* Specify whether the code should make plots, or not (usually 1)

* MAKE_PLOTS must be 1 for any plots to be made
vcqi_global MAKE_PLOTS      				1

* Set PLOT_OUTCOMES_IN_TABLE_ORDER to 1 if you want inchworm and 
* unweighted plots to list strata in the same order as the tables;
* otherwise the strata will be sorted by the outcome and shown in
* bottom-to-top order of increasing indicator performance
vcqi_global PLOT_OUTCOMES_IN_TABLE_ORDER 	1

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
* If you want to save the databases, change the value to 0.
* (Usually 1)

vcqi_global DELETE_VCQI_DATABASES_AT_END	1

* Specify whether the code should delete intermediate datasets 
* at the end of the analysis (Usually 1)
* If you wish to keep them for additional analysis or debugging,
* set the option to 0.

vcqi_global DELETE_TEMP_VCQI_DATASETS		1

* For RI analysis, there is an optional report on data quality
* Set this global to 1 to generate that report
* It appears in its own separate Excel file

vcqi_global VCQI_REPORT_DATA_QUALITY		0

* Set this global to 1 if you would like to create an augmented dataset
* that merges survey dataset with derived variables calculated by VCQI.
* Default value is 0 (no)

vcqi_global VCQI_MAKE_AUGMENTED_DATASET		0

********************************************************************************
* Code Block: RI-E                                               (Do not change)
*-------------------------------------------------------------------------------
*                  Format the VCQI dose list and pre-process survey data
*-------------------------------------------------------------------------------

* Construct the global RI_DOSE_LIST from what the user specified above
* VCQI currently handles single-dose and three-dose vaccines. 

* First, list single dose vaccines 
global RI_DOSE_LIST `=lower("$RI_SINGLE_DOSE_LIST")'

* Then list each dose for two-dose vaccines 
foreach i in $RI_MULTI_2_DOSE_LIST {
	global RI_DOSE_LIST "$RI_DOSE_LIST `=lower("`i'")'1 `=lower("`i'")'2"
}

* Finally, list each dose for three-dose vaccines 
foreach i in $RI_MULTI_3_DOSE_LIST {
	global RI_DOSE_LIST "$RI_DOSE_LIST `=lower("`i'")'1 `=lower("`i'")'2 `=lower("`i'")'3"
}

* Put a copy of the dose list in the log
vcqi_log_global RI_DOSE_LIST

* --------------------------------------------------------------------------
* Check the user's metadata for completeness and correctness
* --------------------------------------------------------------------------

check_RI_schedule_metadata
check_RI_survey_metadata
check_RI_analysis_metadata

* Run the program to look at date of birth (from history, card, and register)
* and look at dates of vaccination from cards and register.  This program 
* evaluates each date and checks to see that it occurred in the period
* allowed for respondents eligible for this survey.  It also checks to see 
* that doses in a sequence were given in order.  If any vaccination date 
* seems to be outside the right range or recorded out of sequence, the date
* is stripped off and replaced with a simple yes/no tick mark.  This step
* means less date-checking is necessary in subsequent programs.

cleanup_RI_dates_and_ticks

* The name of the datasets coming out of these cleanup steps are:
* "${VCQI_OUTPUT_FOLDER}/${VCQI_DATASET}_clean" &
* "${VCQI_OUTPUT_FOLDER}/${VCQI_RIHC_DATASET}_clean"

* --------------------------------------------------------------------------
* Establish unique IDs
* --------------------------------------------------------------------------

* The name of the dataset coming out of the ID step is RI_with_ids
establish_unique_RI_ids

* If the user requests a check instead of a run, then turn off
* flags that result in databases, excel output, and plots

if "$VCQI_CHECK_INSTEAD_OF_RUN" == "1" {
	vcqi_log_comment $VCP 3 Comment "The user has requested a check instead of a run."
	vcqi_global VCQI_PREPROCESS_DATA	0
	vcqi_global VCQI_GENERATE_DVS		0
	vcqi_global VCQI_GENERATE_DATABASES 0
	vcqi_global EXPORT_TO_EXCEL			0
	vcqi_global	MAKE_PLOTS				0
}

********************************************************************************
* Code Block: RI-F                                             (User may change)
*-------------------------------------------------------------------------------
*                  Calculate VCQI indicators requested by the user
*-------------------------------------------------------------------------------

* This is a counter that is used to name datasets...it is usually set to 1 but
* the user might change it if requesting repeat analyses with differing 
* parameters - see the User's Guide

vcqi_global ANALYSIS_COUNTER 1

* Most indicators may be run in any order the user wishes, although there are 
* are some restrictions...see the table in the section of Chapter 6 entitled 
* Analysis Counter.
* 
* We recommend running DESC indicators first, 

vcqi_global DESC_01_DATASET 	RI
vcqi_global DESC_01_TO_TITLE    RI Survey Sample Summary
vcqi_global DESC_01_TO_SUBTITLE
vcqi_global DESC_01_TO_FOOTNOTE_1  Abbreviations: HH = Households	

DESC_01 

* --------------------------------------------------------------------------
* Summarize responses to some multiple-choice questions using DESC_02
* --------------------------------------------------------------------------
		
* Is the card an original or replacement?  (simple unweighted sample proportion)

vcqi_global DESC_02_DATASET 	RI
vcqi_global DESC_02_VARIABLES 	RI30
vcqi_global DESC_02_WEIGHTED	NO
vcqi_global DESC_02_DENOMINATOR	RESPONDED

vcqi_global DESC_02_TO_TITLE Is the card an original or replacement?
* No subtitle.
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* Did you have to pay for replacement?
vcqi_global DESC_02_DATASET 	RI
vcqi_global DESC_02_VARIABLES	RI31
vcqi_global DESC_02_WEIGHTED	NO
vcqi_global DESC_02_DENOMINATOR	RESPONDED

vcqi_global DESC_02_TO_TITLE Did you have to pay for replacement?
* No subtitle or additional footnotes
vcqi_global DESC_02_TO_SUBTITLE
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* Where does your child usually receive vaccinations?
vcqi_global DESC_02_DATASET 	RI
vcqi_global DESC_02_VARIABLES 	RI103
vcqi_global DESC_02_WEIGHTED	YES
vcqi_global DESC_02_DENOMINATOR	ALL
* Make subtotals for local and for 'outside'
vcqi_global DESC_02_N_SUBTOTALS	2
vcqi_global DESC_02_SUBTOTAL_LEVELS_1 1 2 3
vcqi_global DESC_02_SUBTOTAL_LABEL_1 Local
vcqi_global DESC_02_SUBTOTAL_LEVELS_2 4 5 6
vcqi_global DESC_02_SUBTOTAL_LABEL_2 Outside (Not local)
* No subtitle or additional footnotes
vcqi_global DESC_02_TO_TITLE Where does your child usually receive vaccinations?
vcqi_global DESC_02_TO_SUBTITLE
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* Who was the child who had an abscess?
vcqi_global DESC_02_DATASET 	RI
vcqi_global DESC_02_VARIABLES 	RI119
vcqi_global DESC_02_WEIGHTED	NO
vcqi_global DESC_02_DENOMINATOR	RESPONDED
* The label on outcome #6 is "Other, Please Specify"
* Use the relabel options to re-label it simply "Other"
vcqi_global DESC_02_N_RELABEL_LEVELS 2
vcqi_global DESC_02_RELABEL_LEVEL_1 6
vcqi_global DESC_02_RELABEL_LABEL_1 Other
vcqi_global DESC_02_RELABEL_LEVEL_2 .
vcqi_global DESC_02_RELABEL_LABEL_2 Missing
vcqi_global DESC_02_TO_TITLE Who was the child who had an abscess?
* No subtitle or additional footnotes
vcqi_global DESC_02_TO_SUBTITLE
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02, cleanup

* --------------------------------------------------------------------------
* Now demonstrate using DESC_03 on a multiple-choice question
* where the respondent can select all answers that apply
* --------------------------------------------------------------------------

vcqi_global DESC_03_DATASET			RI
vcqi_global DESC_03_SHORT_TITLE		Vx_Msgs
vcqi_global DESC_03_VARIABLES 		RI127 RI128 RI129 RI130 RI131 RI132 RI133 
vcqi_global DESC_03_WEIGHTED		YES
vcqi_global DESC_03_DENOMINATOR		ALL
vcqi_global DESC_03_SELECTED_VALUE	1
* The label on RI133 is "Other, please specify"; use the so-called
* MISSING options to re-label it simply "Other"
vcqi_global DESC_03_TO_TITLE		What messages have you heard about vaccination?
vcqi_global DESC_03_TO_SUBTITLE

vcqi_global DESC_03_N_RELABEL_LEVELS 1
vcqi_global DESC_03_RELABEL_LEVEL_1 RI133
vcqi_global DESC_03_RELABEL_LABEL_1 7. Other

DESC_03, cleanup

* --------------------------------------------------------------------------
* Summarize vaccination coverage
* --------------------------------------------------------------------------
		
* Estimate crude dose coverage for all the doses in the RI_DOSE_LIST
vcqi_global RI_COVG_01_TO_TITLE    	  Crude Coverage
vcqi_global RI_COVG_01_TO_SUBTITLE
vcqi_global RI_COVG_01_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_COVG_01_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_COVG_01

* Estimate valid dose coverage 
	
vcqi_global RI_COVG_02_TO_TITLE       Valid Coverage
vcqi_global RI_COVG_02_TO_SUBTITLE
vcqi_global RI_COVG_02_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_COVG_02_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_COVG_02

* Estimate proportion of respondents fully vaccinated
vcqi_global RI_DOSES_TO_BE_FULLY_VACCINATED BCG MCV1 YF PENTA1 PENTA2 PENTA3 OPV1 OPV2 OPV3

vcqi_global RI_COVG_03_TO_TITLE       Fully Vaccinated
vcqi_global RI_COVG_03_TO_SUBTITLE
vcqi_global RI_COVG_03_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_COVG_03_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.		
vcqi_global RI_COVG_03_TO_FOOTNOTE_3  Note: To be fully vaccinated, the child must have received: $RI_DOSES_TO_BE_FULLY_VACCINATED
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_COVG_03

* Estimate proportion of respondents not vaccinated
* (This measure also uses the global macro RI_DOSES_TO_BE_FULLY_VACCINATED)
	
vcqi_global RI_COVG_04_TO_TITLE       Not Vaccinated
vcqi_global RI_COVG_04_TO_SUBTITLE
vcqi_global RI_COVG_04_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_COVG_04_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.
vcqi_global RI_COVG_04_TO_FOOTNOTE_3  Note: To be counted as not vaccinated, the child must not have received any of these doses: $RI_DOSES_TO_BE_FULLY_VACCINATED
vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_COVG_04

* --------------------------------------------------------------------------
* Identify clusters with alarmingly low coverage of BCG MCV1 OPV1 or PENTA1

vcqi_global RI_COVG_05_DOSE_LIST BCG MCV1 OPV1 PENTA1

* Specify whether to make one table listing only the clusters with low 
* coverage (ONLY_LOW_CLUSTERS)
* or to make one table per stratum, listing all clusters and highlighting
* those with low coverage (ALL_CLUSTERS)
vcqi_global RI_COVG_05_TABLES ONLY_LOW_CLUSTERS

* Specify whether alarmingly low coverage is defined by an absolute
* number of respondents vaccinated (COUNT) or by percent of respondents
* in the cluster (PERCENT)
vcqi_global RI_COVG_05_THRESHOLD_TYPE COUNT

* Specify the threshold that defines alarmingly low 
* A count, like 0, 1, 2 if the THRESHOLD_TYPE is COUNT
* A percent 0 up to 100 if the THRESHOLD_TYPE is PERCENT

* Clusters whose coverage is <= the threshold will be flagged 
* as having alarmingly low coverage.
vcqi_global RI_COVG_05_THRESHOLD 2

* Establish FOOTNOTE_1 and _2, depending on the values of the global macros 
* RI_COVG_05_TABLES and THRESHOLD_TYPE
*
* Note that we use these two globals here without checking for valid values.
* If their values are not valid, the program RI_COVG_05 below will stop with
* an error *before* these footnotes are used in any tables.

if "`=upper("$RI_COVG_05_TABLES")'" == "ALL_CLUSTERS" ///
	vcqi_global RI_COVG_05_TO_FOOTNOTE_1 Note: Shaded rows have alarmingly low coverage for at least one dose.

if "`=upper("$RI_COVG_05_TABLES")'" == "ONLY_LOW_CLUSTERS" ///
	vcqi_global RI_COVG_05_TO_FOOTNOTE_1 Note: Each row has alarmingly low coverage for at least one dose.

if "`=upper("$RI_COVG_05_THRESHOLD_TYPE")'" == "COUNT" ///
	local criterion_string N who received at least one dose in the list <= ${RI_COVG_05_THRESHOLD}

if "`=upper("$RI_COVG_05_THRESHOLD_TYPE")'" == "PERCENT" ///
	local criterion_string the weighted % who received at least one dose in the list <= ${RI_COVG_05_THRESHOLD}%

vcqi_global RI_COVG_05_TO_FOOTNOTE_2 In this table, alarmingly low means: `criterion_string'.


* Note that the worksheet title is built by the indicator and not specified 
* by the user.
* Note also the indicator builds footnotes 1 and 2, so the first 
* user-specified footnote would be #3. 
vcqi_global RI_COVG_05_TO_FOOTNOTE_3

RI_COVG_05

* --------------------------------------------------------------------------
* Characterize access to services using the crude coverage of PENTA1
* --------------------------------------------------------------------------
vcqi_global RI_ACC_01_DOSE_NAME PENTA1
	
vcqi_global RI_ACC_01_TO_TITLE       Received `=upper("$RI_ACC_01_DOSE_NAME")' - Crude
vcqi_global RI_ACC_01_TO_SUBTITLE
vcqi_global RI_ACC_01_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_ACC_01_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_ACC_01

* --------------------------------------------------------------------------
* Calculate issues with continuity (dropout) for three dose pairs:
* 1. Dropout from Penta1 to Penta3
* 2. Dropout from OPV1 to OPV3
* 3. Dropout from Penta3 to MCV1
* --------------------------------------------------------------------------
vcqi_global RI_CONT_01_DROPOUT_LIST PENTA1 PENTA3 OPV1 OPV3 PENTA3 MCV1

vcqi_global RI_CONT_01_TO_TITLE       Dropout
vcqi_global RI_CONT_01_TO_SUBTITLE	
vcqi_global RI_CONT_01_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_CONT_01

* --------------------------------------------------------------------------
* Indicators characterizing the quality of the vaccination program
* --------------------------------------------------------------------------

* Estimate proportion who have a card with vaccination dates on it
	
vcqi_global RI_QUAL_01_TO_TITLE       RI Card Availability
vcqi_global RI_QUAL_01_TO_SUBTITLE
vcqi_global RI_QUAL_01_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_QUAL_01_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_01

* Estimate proportion who ever had a vaccination card

vcqi_global RI_QUAL_02_TO_TITLE       Ever Received RI Card
vcqi_global RI_QUAL_02_TO_SUBTITLE
vcqi_global RI_QUAL_02_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_QUAL_02_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_02

* Estimate proportion of PENTA1 doses administered that were invalid
vcqi_global RI_QUAL_03_DOSE_NAME PENTA1

vcqi_global RI_QUAL_03_TO_TITLE       Received Invalid `=upper("$RI_QUAL_03_DOSE_NAME")'
vcqi_global RI_QUAL_03_TO_SUBTITLE
vcqi_global RI_QUAL_03_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_03

* Estimate proportion of MCV1 doses administered before 39 weeks of age
vcqi_global RI_QUAL_04_DOSE_NAME MCV1
vcqi_global RI_QUAL_04_AGE_THRESHOLD `=(39*7)'

vcqi_global RI_QUAL_04_TO_TITLE       `=upper("$RI_QUAL_04_DOSE_NAME")' Received Before Age $RI_QUAL_04_AGE_THRESHOLD Days
vcqi_global RI_QUAL_04_TO_SUBTITLE
vcqi_global RI_QUAL_04_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_04

* Estimate proportion of PENTA intra-dose intervals that were 
* shorter than 28 days

vcqi_global RI_QUAL_05_DOSE_NAME PENTA
vcqi_global RI_QUAL_05_INTERVAL_THRESHOLD 28

vcqi_global RI_QUAL_05_TO_TITLE       `=upper("$RI_QUAL_05_DOSE_NAME")' Interval < $RI_QUAL_05_INTERVAL_THRESHOLD Days
vcqi_global RI_QUAL_05_TO_SUBTITLE
vcqi_global RI_QUAL_05_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global RI_QUAL_05_TO_FOOTNOTE_2  For this indicator, N is the number of Dose 1 to Dose 2 intervals plus the number of Dose 2 to Dose 3 intervals for which respondents had vaccination dates. Some respondents will have contributed data for no intervals, some for one interval, and some for two intervals.
vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_05

* Estimate proportion of MCV1 doses that were administered before age 1
vcqi_global RI_QUAL_06_DOSE_NAME MCV1
* (The threshold for RI_QUAL_06 is always age 1.)

vcqi_global RI_QUAL_06_TO_TITLE       Percent of Valid `=upper("$RI_QUAL_06_DOSE_NAME")' Given by Age 1
vcqi_global RI_QUAL_06_TO_SUBTITLE
vcqi_global RI_QUAL_06_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global RI_QUAL_06_TO_FOOTNOTE_2  Denominator is the number of respondents with valid dose of `=upper("$RI_QUAL_06_DOSE_NAME")'.
vcqi_global RI_QUAL_06_TO_FOOTNOTE_3  Numerator is the number of residents who had a valid dose of `=upper("$RI_QUAL_06_DOSE_NAME")' by age 1.	
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_06

* The next three indicators are concerned with Missed Opportunities for Simultaneous Vaccination (MOV)

* Usually the user will want to see MOV output for all the doses in the RI_DOSE_LIST
* but sometimes they may want to omit some doses.  Either specify the list of doses
* clearly here, or simply copy the RI_DOSE_LIST into the global MOV_OUTPUT_DOSE_LIST
*
* e.g., to generate MOV output for only the basic eight EPI doses, we might say:
* vcqi_global MOV_OUTPUT_DOSE_LIST bcg opv1 opv2 opv3 dpt1 dpt2 dpt3 mcv

vcqi_global MOV_OUTPUT_DOSE_LIST $RI_DOSE_LIST

*
* Run the program to establish which dates the child was vaccinated on and
* whether they received every dose for which they were age-eligible (or 
* interval-eligible).  Put the results in a dataset that is ready to be 
* merged in later for MOV indicators 
*

calculate_MOV_flags

* Estimate what valid coverage would have been if there had been no MOVs

vcqi_global RI_QUAL_07B_TO_TITLE       Coverage if no MOVs
vcqi_global RI_QUAL_07B_TO_SUBTITLE
vcqi_global RI_QUAL_07B_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval
vcqi_global RI_QUAL_07B_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CIs are calculated with software that take the complex survey design into account.
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_07B

* Estimate the proportion of visits that had MOVs
vcqi_global RI_QUAL_08_VALID_OR_CRUDE CRUDE

vcqi_global RI_QUAL_08_TO_TITLE       Percent of Visits with MOVs
vcqi_global RI_QUAL_08_TO_SUBTITLE
vcqi_global RI_QUAL_08_TO_FOOTNOTE_1  Percent of visits where children were eligible for the dose and did not receive it.
if "`=upper("$RI_QUAL_08_VALID_OR_CRUDE")'" == "VALID" vcqi_global RI_QUAL_08_TO_FOOTNOTE_2 Note: Early doses are ignored in this analysis; the respondent is considered to have not received them.
if "`=upper("$RI_QUAL_08_VALID_OR_CRUDE")'" == "CRUDE" vcqi_global RI_QUAL_08_TO_FOOTNOTE_2 Note: Early doses are accepted in this analysis; all doses are considered valid doses.
vcqi_global RI_QUAL_08_TO_FOOTNOTE_3 Note: The final measure on this sheet, MOVs per Visit, is not a percent.  It is a ratio.  
vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_08

* Estimate the proportion of children who experienced 1+ MOVs
vcqi_global RI_QUAL_09_VALID_OR_CRUDE CRUDE

vcqi_global RI_QUAL_09_TO_TITLE       Percent of Respondents with MOVs
vcqi_global RI_QUAL_09_TO_SUBTITLE
vcqi_global RI_QUAL_09_TO_FOOTNOTE_1  Percent of respondents who had date of birth and visit date data who failed to receive a vaccination for which they were eligible on an occasion when they received another vaccination.
vcqi_global RI_QUAL_09_TO_FOOTNOTE_2  An uncorrected MOV means that the respondent had still not received a valid dose at the time of the survey.
vcqi_global RI_QUAL_09_TO_FOOTNOTE_3  A corrected MOV means that the respondent had received a valid dose by the time of the survey.
vcqi_global RI_QUAL_09_TO_FOOTNOTE_4  The denominator for Had MOV (%) is the number of respondents who had visits eligible.
vcqi_global RI_QUAL_09_TO_FOOTNOTE_5  The denominator for MOV uncorrected and corrected (%) is the number of MOVs.  
vcqi_global RI_QUAL_09_TO_FOOTNOTE_6  Note that for individual doses, the % MOV uncorrected + % MOV corrected adds up to 100%.
if "`=upper("$RI_QUAL_09_VALID_OR_CRUDE")'" == "VALID" vcqi_global RI_QUAL_09_TO_FOOTNOTE_7 Note: Early doses are ignored in this analysis; the respondent is considered to have not received them.
if "`=upper("$RI_QUAL_09_VALID_OR_CRUDE")'" == "CRUDE" vcqi_global RI_QUAL_09_TO_FOOTNOTE_7 Note: Early doses are accepted in this analysis; all doses are considered valid doses.
* This indicator makes plots (1) if any MOV and (2) if corrected. These are sorted in opposite directions, so global SORT_PLOT_LOW_TO_HIGH is set in RI_QUAL_09_06PO.ado

RI_QUAL_09

* Estimate the proportion of intervals that are longer
* than the specified thresholds
* 1. Penta1 to Penta2 longer than 56 days
* 2. Penta2 to Penta3 longer than 56 days
* 3. BCG to MCV1 longer than 273 days

vcqi_global RI_QUAL_12_DOSE_PAIR_LIST PENTA1 PENTA2 PENTA2 PENTA3 BCG MCV1
vcqi_global RI_QUAL_12_THRESHOLD_LIST 56 56 273

vcqi_global RI_QUAL_12_TO_TITLE       Dose Intervals Exceed Thresholds
vcqi_global RI_QUAL_12_TO_SUBTITLE
vcqi_global RI_QUAL_12_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global SORT_PLOT_LOW_TO_HIGH 0 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_12

* Estimate proportion of Penta3 doses that were given before 26 weeks
vcqi_global RI_QUAL_13_DOSE_NAME PENTA3
vcqi_global RI_QUAL_13_AGE_THRESHOLD `=(26*7)+1'

vcqi_global RI_QUAL_13_TO_TITLE       `=upper("$RI_QUAL_13_DOSE_NAME")' Received Before Age $RI_QUAL_13_AGE_THRESHOLD Days
vcqi_global RI_QUAL_13_TO_SUBTITLE
vcqi_global RI_QUAL_13_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global SORT_PLOT_LOW_TO_HIGH 1 // 1=sort proportions on plot low at bottom to high at top; 0 is the opposite

RI_QUAL_13

* ------------------------------------------------------------------------------
* Indicators that plot cumulative coverage curves and cumulative interval curves
* ------------------------------------------------------------------------------

*
* RI_CCC_01 and RI_CIC_01 make UNWEIGHTED plots
*

* Make Unweighted Cumulative Coverage Curve (CCC) Plots
vcqi_global RI_CCC_01_PLOT_TITLE "<Plot Title Here>"
vcqi_global RI_CCC_01_PLOT_LEVELS 1 2 3 // List which level(s) you want CCC (1=nation, 2=zone, 3=stratum)
vcqi_global RI_CCC_01_XMAX_INTERVAL 50  // units is age in days...round up to the nearest xmax_interval (default is 50)
vcqi_global RI_CCC_01_GRAPHREGION_COLOR white
vcqi_global RI_CCC_01_NUM_LEGEND_ROWS 2

* If want to over-ride automated x-labels on plot, fill in global here, otherwise leave the global empty
vcqi_global RI_CCC_01_XLABELS 

* If want to change the font size of the xlabels (usually make them smaller so they don't overlap)
* e.g., vsmall, small, or medsmall
vcqi_global RI_CCC_01_XLABEL_SIZE medsmall

* Alternate labels on x-axis? (0=No; 1=Yes)
vcqi_global RI_CCC_01_XLABEL_ALTERNATE	0 

* Cumulative coverage curve details 
* The vectors of colors/patterns/widths must be *at least* as long as the number of antigens
vcqi_global RI_CCC_01_COLOR    gs3 red blue gold gs8 purple green magenta sand cyan
vcqi_global RI_CCC_01_PATTERN  solid dash longdash solid solid dash solid dash solid dash
vcqi_global RI_CCC_01_WIDTH    medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin

* Vertical lines denoting vaccination schedule
vcqi_global RI_CCC_01_VLINE_COLOR    gs10
vcqi_global RI_CCC_01_VLINE_PATTERN  longdash
vcqi_global RI_CCC_01_VLINE_WIDTH    medthin

* CCC are made for dates according to card. If register dates were sought, then
*  CCC are also made for dates according to register. If user wants to over-ride 
*  this default, then type the data source (either card or register) user wants
*  CCC plots, otherwise, leave blank. (e.g., if both card and register dates
*  available but user only wants card CCC, then type card here; or if dataset only
*  has register dates, then type register here)
vcqi_global RI_CCC_01_CARD_REGISTER

* Note that the y-axis goes from 0% to 100% and the denominator for these curves
* is the number of respondents with a card with a birthdate and at least one
* vaccination date. (For register plots, the denominator is the number of 
* respondents with register records with a birthdate and at least one vx date.)

RI_CCC_01

* Make Unweighted Cumulative Interval Curves (CIC)
*
* These locals are very similar to those described above under the CCC curves.

* Note that the y-axis goes from 0% to 100% and the denominator for these curves
* is the number of respondents with a date for dose1 and a date for dose2.
*
* The code automatically makes interval plots for every antigen with doses 
* named with numbers 1+ at the end, e.g., opv1 opv2, etc.  This code IGNORES
* doses with a zero at the end of the name.  That is to say that it does NOT
* generate a plot for the interval between opv0 and opv1, but does generate
* plots for intervals between opv1 and opv2, opv2 and opv3, etc.

vcqi_global RI_CIC_01_XMAX_INTERVAL 10
vcqi_global RI_CIC_01_PLOT_LEVELS 1 2 3
vcqi_global RI_CIC_01_CARD_REGISTER
vcqi_global RI_CIC_01_XLABELS
vcqi_global RI_CIC_01_PLOT_TITLE "<Title goes here>"

vcqi_global RI_CIC_01_COLOR    navy
vcqi_global RI_CIC_01_PATTERN  solid
vcqi_global RI_CIC_01_WIDTH    medium

vcqi_global RI_CIC_01_VLINE_COLOR   gs10 gs10
vcqi_global RI_CIC_01_VLINE_PATTERN longdash solid
vcqi_global RI_CIC_01_VLINE_WIDTH   medthin medthin
vcqi_global RI_CIC_01_GRAPHREGION_COLOR white
vcqi_global RI_CIC_01_XLABEL_SIZE	medsmall

* Alternate labels on x-axis? (0=No; 1=Yes)
vcqi_global RI_CIC_01_XLABEL_ALTERNATE	0 

RI_CIC_01

*
* RI_CCC_02 and RI_CIC_02 make WEIGHTED plots
*

* Make Weighted Cumulative Coverage Curve (CCC) Plots
vcqi_global RI_CCC_02_PLOT_TITLE "<Title goes here>"
vcqi_global RI_CCC_02_PLOT_LEVELS 1  // List which level(s) you want CCC (1=nation, 2=zone, 3=stratum)
vcqi_global RI_CCC_02_XMAX_INTERVAL 50  // units is age in days...round up to the nearest xmax_interval (default is 50)
vcqi_global RI_CCC_02_GRAPHREGION_COLOR white
vcqi_global RI_CCC_02_NUM_LEGEND_ROWS 2

* If want to over-ride automated x-labels on plot, fill in global here, otherwise leave the global empty
vcqi_global RI_CCC_02_XLABELS 

* If want to change the font size of the xlabels (usually make them smaller so they don't overlap)
* e.g., vsmall, small, or medsmall
vcqi_global RI_CCC_02_XLABEL_SIZE medsmall

* Alternate labels on x-axis? (0=No; 1=Yes)
vcqi_global RI_CCC_02_XLABEL_ALTERNATE	1

* Cumulative coverage curve details 
* The vectors of colors/patterns/widths must be *at least* as long as the number of antigens
vcqi_global RI_CCC_02_COLOR    gs3 red blue gold gs8 purple green magenta sand cyan
vcqi_global RI_CCC_02_PATTERN  solid dash longdash solid solid dash solid dash solid dash
vcqi_global RI_CCC_02_WIDTH    medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin

* Vertical lines denoting vaccination schedule
vcqi_global RI_CCC_02_VLINE_COLOR    gs10
vcqi_global RI_CCC_02_VLINE_PATTERN  longdash
vcqi_global RI_CCC_02_VLINE_WIDTH    medthin

* CCC are made for dates according to card. If register dates were sought, then
*  CCC are also made for dates according to register. If user wants to over-ride 
*  this default, then type the data source (either card or register) user wants
*  CCC plots, otherwise, leave blank. (e.g., if both card and register dates
*  available but user only wants card CCC, then type card here; or if dataset only
*  has register dates, then type register here)
vcqi_global RI_CCC_02_CARD_REGISTER card

* Note that the y-axis goes from 0% to 100% and the denominator for these curves
* is the number of respondents with a card with a birthdate and at least one
* vaccination date. (For register plots, the denominator is the number of 
* respondents with register records with a birthdate and at least one vx date.)
vcqi_global RI_CCC_02_XLABEL_INCLUDE 180 365		

* If card availability or coverage are low, you might not want the y-axis to
* go all the way up to 100.  If you set this ZOOM parameter to 1, the plots
* will go from 0 up to 20%, 40%, 60%, 80%, or 100% - whichever is required
* to show all your data.

vcqi_global RI_CCC_02_ZOOM_Y_AXIS 1	

vcqi_global CCC_XMAX = 550

RI_CCC_02

* Make Weighted Cumulative Interval Curves (CIC)
*
* These locals are very similar to those described above under the CCC curves.

* Note that the y-axis goes from 0% to 100% and the denominator for these curves
* is the number of respondents with a date for dose1 and a date for dose2.
*
* The code automatically makes interval plots for every antigen with doses 
* named with numbers 1+ at the end, e.g., opv1 opv2, etc.  This code IGNORES
* doses with a zero at the end of the name.  That is to say that it does NOT
* generate a plot for the interval between opv0 and opv1, but does generate
* plots for intervals between opv1 and opv2, opv2 and opv3, etc.

vcqi_global RI_CIC_02_XMAX_INTERVAL 10
vcqi_global RI_CIC_02_PLOT_LEVELS 1 
vcqi_global RI_CIC_02_CARD_REGISTER
vcqi_global RI_CIC_02_XLABELS
vcqi_global RI_CIC_02_PLOT_TITLE "<Title goes here>"

vcqi_global RI_CIC_02_COLOR    navy
vcqi_global RI_CIC_02_PATTERN  solid
vcqi_global RI_CIC_02_WIDTH    medium

vcqi_global RI_CIC_02_VLINE_COLOR   gs10 gs10
vcqi_global RI_CIC_02_VLINE_PATTERN longdash solid
vcqi_global RI_CIC_02_VLINE_WIDTH   medthin medthin
vcqi_global RI_CIC_02_GRAPHREGION_COLOR white
vcqi_global RI_CIC_02_XLABEL_SIZE	medsmall

* Alternate labels on x-axis? (0=No; 1=Yes)
vcqi_global RI_CIC_02_XLABEL_ALTERNATE	0 

vcqi_global RI_CIC_02_CARD_REGISTER card

vcqi_global RI_CIC_02_ZOOM_Y_AXIS 0

RI_CIC_02

********************************************************************************
* Make Coverage and Timeliness Charts

* Specify 1 or 2 or 3 here to make charts for every level 1, 2 or 3 stratum.
* You may also specify a combination like 1 3
global RI_VCTC_01_LEVELS 1 

* Specify which doses to show in the chart and the order, from bottom to top
global TIMELY_DOSE_ORDER bcg hepb opv0 opv1 opv2 opv3 penta1 penta2 penta3 pcv1 pcv2 pcv3 rota1 rota2 rota3 ipv mcv1 yf

* Specify the y-coordinates for the bars.  If you want them to be spaced evenly, you may omit this global (leave it empty)
global TIMELY_Y_COORDS    10  20  30   43 50 57   73 80 87   103 110 117   133 140 147   160  170  180

* Specify the y-coordinates for a set of light reference horizonatal lines between dose groups
* These are just for the purpose of aiding the viewer's eye in grouping doses visually.
* The lines are sometimes skipped if you have already used the TIMELY_Y_COORDS to group the doses.
* To omit these lines altogether, leave this global empty or omit it.
global TIMELY_YLINE_LIST  

* Run the .do file that defines the default parameters.
* Note that you need to copy the file from the VCQI source folder named RI
* and paste it into your VCQI_OUTPUT_FOLDER.  You may customize the 
* entries in the .do file itself or you may re-specify them in code 
* below the include statement.
include "$VCQI_OUTPUT_FOLDER/globals_for_timeliness_plots.do"

* Because we are spacing the bars about every y=10 units instead of the 
* default Y=1, specify a bar width that is 10X the default.
global TIMELY_BARWIDTH 6.7

* Similarly, specify a buffer between the TEXTBAR label and top row that
* is on the order of 9 or 10 y-axis units instead of ~1.
global TIMELY_TEXTBAR_LABEL_Y_SPACE 9

* Do the calculations and make the charts
RI_VCTC_01

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

* Does crude (RI_COVG_01) penta3 by card differ between 
* the Northern vs Southern province?

vcqi_global COVG_DIFF_01_STRATUM_LEVEL 2
vcqi_global COVG_DIFF_01_ANALYSIS_COUNTER $ANALYSIS_COUNTER

vcqi_global COVG_DIFF_01_ID_OR_NAME NAME

vcqi_global COVG_DIFF_01_STRATUM_NAME1 NORTHERN PROVINCE
vcqi_global COVG_DIFF_01_STRATUM_NAME2 SOUTHERN PROVINCE

vcqi_global COVG_DIFF_01_INDICATOR RI_COVG_01
vcqi_global COVG_DIFF_01_VARIABLE got_crude_penta3_by_card

vcqi_global COVG_DIFF_01_TO_FOOTNOTE_1 Abbreviations: CI = Confidence Interval

COVG_DIFF_01

* --------------------------------------------------------------------------
* Does crude Penta 1, 2, and 3 differ between urban and rural clusters
* in province 1?

vcqi_global COVG_DIFF_02_INDICATOR RI_COVG_01
vcqi_global COVG_DIFF_02_ANALYSIS_COUNTER  $ANALYSIS_COUNTER

vcqi_global COVG_DIFF_02_SUBPOP_VARIABLE urban_cluster
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL1 0
vcqi_global COVG_DIFF_02_SUBPOP_LEVEL2 1

vcqi_global COVG_DIFF_02_ID_OR_NAME ID
vcqi_global COVG_DIFF_02_STRATUM_LEVEL 2

vcqi_global COVG_DIFF_02_STRATUM_ID 1

vcqi_global COVG_DIFF_02_VARIABLE got_crude_penta1_by_card

vcqi_global COVG_DIFF_02_TO_FOOTNOTE_1 Abbreviations: CI = Confidence Interval

COVG_DIFF_02

vcqi_global COVG_DIFF_02_VARIABLE got_crude_penta2_by_card
COVG_DIFF_02

vcqi_global COVG_DIFF_02_VARIABLE got_crude_penta3_by_card
COVG_DIFF_02

* --------------------------------------------------------------------------
* Now test urban vs. rural crude Penta 1, 2, and 3
* in province 2 (which is named Northern Province).
* 

vcqi_global COVG_DIFF_02_ID_OR_NAME NAME
vcqi_global COVG_DIFF_02_STRATUM_NAME Northern Province

vcqi_global COVG_DIFF_02_VARIABLE got_crude_penta1_by_card
COVG_DIFF_02

vcqi_global COVG_DIFF_02_VARIABLE got_crude_penta2_by_card
COVG_DIFF_02

vcqi_global COVG_DIFF_02_VARIABLE got_crude_penta3_by_card
COVG_DIFF_02

********************************************************************************
* Code Block: RI-G                                               (Do not change)
*-------------------------------------------------------------------------------
*                  Exit gracefully
*-------------------------------------------------------------------------------
*
* Make RI augmented dataset for additional analysis purposes if user requests it.

if "$VCQI_MAKE_AUGMENTED_DATASET"=="1" & "$VCQI_CHECK_INSTEAD_OF_RUN" != "1" make_RI_augmented_dataset, noidenticaldupes

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
* Code Block: RI-H                                               (Do not change)
*-------------------------------------------------------------------------------
* Change log 
* 				Updated 
*				version 
* Date 			number 	Name			What Changed 
* 2020-01-16	1.00	Dale Rhoda		Version as of 2020-01-16
* 2020-03-27	1.01	Mary Prier		Added RI_QUAL_07B and commented out 
*										call to RI_QUAL_07
* 2020-04-09	1.02	Dale Rhoda		Add VCQI____END_OF_PROGRAM to 
*                                       suppress showing this change log
*                                       in the VCQI log window after showing
*                                       the VCQI ASCCI art.
* 2020-12-09	1.03	Dale Rhoda		Allow the user to plot strata in table order
* 2020-12-12	1.04	Dale Rhoda		Allow user to SHOW_LEVEL_4_ONLY
*                                       and update test dataset to 2020-10-16
*                                       which is Harmonia instead of 
*                                       Sassafrippi
* 2021-01-05	1.05	Dale Rhoda		Added calls for RI_CCC_02 and RI_CIC_02
*                                       and RI_VCTC_01
******************************************************************************** 

* turn on normal output to the log window again
set output proc
