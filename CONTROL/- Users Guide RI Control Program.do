********************************************************************************
* Vaccination Coverage Quality Indicators (VCQI) control program to analyze
* data from a routine immunization survey 
*
*
* Program example and template for the VCQI User's Guide
*
* Written by Biostat Global Consulting
*
* Updated 2017-07-19
*
* The user might customize this program by changing items below in the
* code blocks marked RI-B, RI-D, and RI-F below.  Those blocks are
* marked "(User may change)".
* 
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

* Where should the programs look for datasets?
global VCQI_DATA_FOLDER    	Q:/- Folders shared outside BGC/BGC Team - WHO Software/Test datasets/2016-02-24

* Where should the programs put output?
global VCQI_OUTPUT_FOLDER   Q:/- Folders shared outside BGC/BGC Team - WHO Software/Working folder - Dale/VCQI test output/RI cleanup test

* Establish analysis name (used in log file name and Excel file name)

global VCQI_ANALYSIS_NAME RI_Test

* Set this global to 1 to test all metadata and code that makes
* datasets and calculates derived variables...without running the
* indicators or generating output

global	VCQI_CHECK_INSTEAD_OF_RUN		0

********************************************************************************
* Code Block: RI-C                                               (Do not change)
*-------------------------------------------------------------------------------
*                  CD to output folder & open VCQI log
*-------------------------------------------------------------------------------

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

* http://www.who.int/immunization/policy/Immunization_routine_table2.pdf?ua=1 
* Note: Not including maximums (e.g., ms & yf are to be given b/t 9-12 months; 
* series are to be given b/t 4-8 weeks of previous dose)

scalar bcg_min_age_days 		= 0  // birth dose
scalar hepb_min_age_days 		= 0  // birth dose
scalar opv0_min_age_days 		= 0  // birth dose

* opv0 only given in the first two weeks of life
scalar opv0_max_age_days 		= 14  // birth dose

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

scalar mcv_min_age_days 		= 270  // 9 months
scalar mcv1_min_age_days 		= 270  // 9 months
scalar yf_min_age_days 			= 270  // 9 months

* --------------------------------------------------------------------------
* Parameters to describe survey
* --------------------------------------------------------------------------
* Specify the earliest and latest possible vaccination date for this survey.
*
* (The software assumes this survey includes birth doses, so the earliest date
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
* Which doses should be included in the analysis
* --------------------------------------------------------------------------

* Note that these abbreviations must correspond to those used in the
* names of the dose date and dose tick variables.  The variables are 
* named using lower-case acronyms.  The globals here may be upper or
* mixed case...they will be converted to lower case in the software.
*
vcqi_global RI_SINGLE_DOSE_LIST  BCG HEPB OPV0 IPV MCV1 YF
vcqi_global RI_MULTI_2_DOSE_LIST 
vcqi_global RI_MULTI_3_DOSE_LIST PENTA PCV OPV ROTA

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

* For RI analysis, there is an optional report on data quality
* Set this global to 1 to generate that report
* It appears in its own separate Excel spreadsheet

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
* Clear out the SUBTITLE in case it was previously used.
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02

* Did you have to pay for replacement?
vcqi_global DESC_02_VARIABLES	RI31

vcqi_global DESC_02_TO_TITLE Did you have to pay for replacement?
* Clear out the SUBTITLE in case it was previously used.
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 

DESC_02

* Where does your child usually receive vaccinations?
vcqi_global DESC_02_VARIABLES 	RI103
vcqi_global DESC_02_WEIGHTED	YES
vcqi_global DESC_02_DENOMINATOR	ALL
* Make subtotals for local and for 'outside'
vcqi_global DESC_02_N_SUBTOTALS	2
vcqi_global DESC_02_SUBTOTAL_LEVELS_1 1 2 3
vcqi_global DESC_02_SUBTOTAL_LABEL_1 Local
vcqi_global DESC_02_SUBTOTAL_LEVELS_2 4 5 6
vcqi_global DESC_02_SUBTOTAL_LABEL_2 Outside (Not local)
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
vcqi_global DESC_02_SUBTOTAL_LEVELS_2 
vcqi_global DESC_02_SUBTOTAL_LABEL_2 

* Who was the child who had an abscess?
vcqi_global DESC_02_VARIABLES 	RI119
vcqi_global DESC_02_WEIGHTED	NO
vcqi_global DESC_02_DENOMINATOR	RESPONDED
* The label on outcome #6 is "Other, Please Specify"
* Use the so-called missing options to re-label it 
* simply "Other"
vcqi_global DESC_02_N_MISSING_LEVELS 2
vcqi_global DESC_02_MISSING_LEVEL_1 6
vcqi_global DESC_02_MISSING_LABEL_1 Other
vcqi_global DESC_02_MISSING_LEVEL_2 .
vcqi_global DESC_02_MISSING_LABEL_2 Missing
vcqi_global DESC_02_TITLE Who was the child who had an abscess?
* Clear out the SUBTITLE in case it was previously used.
vcqi_global DESC_02_TO_SUBTITLE
* Remember that DESC_02 automatically assigns two footnotes, so if you
* want to include another, start with the number 3.
* We are not using it here, but clear it out in case it was used earlier.
vcqi_global DESC_02_TO_FOOTNOTE_3 
DESC_02
* Clear out the MISSING globals right away
vcqi_global DESC_02_N_MISSING_LEVELS 
vcqi_global DESC_02_MISSING_LEVEL_1 
vcqi_global DESC_02_MISSING_LABEL_1 
vcqi_global DESC_02_MISSING_LEVEL_2 
vcqi_global DESC_02_MISSING_LABEL_2 

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
vcqi_global DESC_03_N_MISSING_LEVELS 1
vcqi_global DESC_03_MISSING_LEVEL_1 RI133
vcqi_global DESC_03_MISSING_LABEL_1 7. Other
* Clear out the SUBTITLE in case it was previously used.
vcqi_global DESC_03_TO_SUBTITLE
* We are not using any footnotes here; clear out the first one so none are printed.
vcqi_global DESC_03_TO_FOOTNOTE_1
DESC_03
* Clear out the MISSING globals right away
vcqi_global DESC_03_N_MISSING_LEVELS 
vcqi_global DESC_03_MISSING_LEVEL_1 
vcqi_global DESC_03_MISSING_LABEL_1 
		
* --------------------------------------------------------------------------
* Summarize vaccination coverage
* --------------------------------------------------------------------------
		
* Estimate crude dose coverage for all the doses in the RI_DOSE_LIST
vcqi_global RI_COVG_01_TO_TITLE    	  Crude Coverage
vcqi_global RI_COVG_01_TO_SUBTITLE
vcqi_global RI_COVG_01_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_COVG_01_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.

RI_COVG_01

* Estimate valid dose coverage 
	
vcqi_global RI_COVG_02_TO_TITLE       Valid Coverage
vcqi_global RI_COVG_02_TO_SUBTITLE
vcqi_global RI_COVG_02_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_COVG_02_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.

RI_COVG_02

* Estimate proportion of respondents fully vaccinated
vcqi_global RI_DOSES_TO_BE_FULLY_VACCINATED BCG MCV1 YF PENTA1 PENTA2 PENTA3 OPV1 OPV2 OPV3

vcqi_global RI_COVG_03_TO_TITLE       Fully Vaccinated
vcqi_global RI_COVG_03_TO_SUBTITLE
vcqi_global RI_COVG_03_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_COVG_03_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.		
vcqi_global RI_COVG_03_TO_FOOTNOTE_3  Note: To be fully vaccinated, the child must have received: $RI_DOSES_TO_BE_FULLY_VACCINATED

RI_COVG_03

* Estimate proportion of respondents not vaccinated
* (This measure also uses the global macro RI_DOSES_TO_BE_FULLY_VACCINATED)
	
vcqi_global RI_COVG_04_TO_TITLE       Not Vaccinated
vcqi_global RI_COVG_04_TO_SUBTITLE
vcqi_global RI_COVG_04_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_COVG_04_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.
vcqi_global RI_COVG_04_TO_FOOTNOTE_3  Note: To be counted as not vaccinated, the child must not have received any of these doses: $RI_DOSES_TO_BE_FULLY_VACCINATED

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

RI_CONT_01

* --------------------------------------------------------------------------
* Indicators characterizing the quality of the vaccination program
* --------------------------------------------------------------------------

* Estimate proportion who have a card with vaccination dates on it
	
vcqi_global RI_QUAL_01_TO_TITLE       RI Card Availability
vcqi_global RI_QUAL_01_TO_SUBTITLE
vcqi_global RI_QUAL_01_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_QUAL_01_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.

RI_QUAL_01

* Estimate proportion who ever had a vaccination card

vcqi_global RI_QUAL_02_TO_TITLE       Ever Received RI Card
vcqi_global RI_QUAL_02_TO_SUBTITLE
vcqi_global RI_QUAL_02_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval; LCB=Lower Confidence Bound; UCB=Upper Confidence Bound; DEFF=Design Effect; ICC=Intracluster Correlation Coefficient
vcqi_global RI_QUAL_02_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI, LCB and UCB are calculated with software that take the complex survey design into account.

RI_QUAL_02

* Estimate proportion of PENTA1 doses administered that were invalid
vcqi_global RI_QUAL_03_DOSE_NAME PENTA1

vcqi_global RI_QUAL_03_TO_TITLE       Received Invalid `=upper("$RI_QUAL_03_DOSE_NAME")'
vcqi_global RI_QUAL_03_TO_SUBTITLE
vcqi_global RI_QUAL_03_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.

RI_QUAL_03

* Estimate proportion of MCV1 doses administered before 39 weeks of age
vcqi_global RI_QUAL_04_DOSE_NAME MCV1
vcqi_global RI_QUAL_04_AGE_THRESHOLD `=(39*7)'

vcqi_global RI_QUAL_04_TO_TITLE       `=upper("$RI_QUAL_04_DOSE_NAME")' Received Before Age $RI_QUAL_04_AGE_THRESHOLD Days
vcqi_global RI_QUAL_04_TO_SUBTITLE
vcqi_global RI_QUAL_04_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.

RI_QUAL_04

* Estimate proportion of PENTA intra-dose intervals that were 
* shorter than 28 days

vcqi_global RI_QUAL_05_DOSE_NAME PENTA
vcqi_global RI_QUAL_05_INTERVAL_THRESHOLD 28

vcqi_global RI_QUAL_05_TO_TITLE       `=upper("$RI_QUAL_05_DOSE_NAME")' Interval < $RI_QUAL_05_INTERVAL_THRESHOLD Days
vcqi_global RI_QUAL_05_TO_SUBTITLE
vcqi_global RI_QUAL_05_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global RI_QUAL_05_TO_FOOTNOTE_2  For this indicator, N is the number of Dose 1 to Dose 2 intervals plus the number of Dose 2 to Dose 3 intervals for which respondents had vaccination dates. Some respondents will have contributed data for no intervals, some for one interval, and some for two intervals.

RI_QUAL_05

* Estimate proportion of MCV1 doses that were administered before age 1
vcqi_global RI_QUAL_06_DOSE_NAME MCV1
* (The threshold for RI_QUAL_06 is always age 1.)

vcqi_global RI_QUAL_06_TO_TITLE       Percent of Valid `=upper("$RI_QUAL_06_DOSE_NAME")' Given by Age 1
vcqi_global RI_QUAL_06_TO_SUBTITLE
vcqi_global RI_QUAL_06_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.
vcqi_global RI_QUAL_06_TO_FOOTNOTE_2  Denominator is the number of respondents with valid dose of `=upper("$RI_QUAL_06_DOSE_NAME")'.
vcqi_global RI_QUAL_06_TO_FOOTNOTE_3  Numerator is the number of residents who had a valid dose of `=upper("$RI_QUAL_06_DOSE_NAME")' by age 1.	

RI_QUAL_06

* Estimate what valid coverage would have been if there had been no MOVs

* Code to calculate flags describing Missed Opportunities for Simultaneous
* Vaccination (MOV)

* Run the program to establish which dates the child was vaccinated on and
* whether they received every dose for which they were age-eligible (or 
* interval-eligible).  Put the results in a dataset that is ready to be 
* merged in later for MOV indicators 
*
calculate_MOV_flags

vcqi_global RI_QUAL_07_VALID_OR_CRUDE VALID

vcqi_global RI_QUAL_07_TO_TITLE       Valid Coverage if no MOVs
vcqi_global RI_QUAL_07_TO_SUBTITLE
vcqi_global RI_QUAL_07_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval
vcqi_global RI_QUAL_07_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CIs are calculated with software that take the complex survey design into account.
if "`=upper("$RI_QUAL_07_VALID_OR_CRUDE")'" == "VALID" vcqi_global RI_QUAL_07_TO_FOOTNOTE_3 Note: Early doses are ignored in this analysis; the respondent is considered to have not received them.
if "`=upper("$RI_QUAL_07_VALID_OR_CRUDE")'" == "CRUDE" vcqi_global RI_QUAL_07_TO_FOOTNOTE_3 Note: Early doses are accepted in this analysis; all doses are considered valid doses.

RI_QUAL_07

* Estimate the proportion of visits that had MOVs
vcqi_global RI_QUAL_08_VALID_OR_CRUDE VALID

vcqi_global RI_QUAL_08_TO_TITLE       Percent of Visits with MOVs
vcqi_global RI_QUAL_08_TO_SUBTITLE
vcqi_global RI_QUAL_08_TO_FOOTNOTE_1  Percent of visits where children were eligible for the dose and did not receive it.
if "`=upper("$RI_QUAL_08_VALID_OR_CRUDE")'" == "VALID" vcqi_global RI_QUAL_08_TO_FOOTNOTE_2 Note: Early doses are ignored in this analysis; the respondent is considered to have not received them.
if "`=upper("$RI_QUAL_08_VALID_OR_CRUDE")'" == "CRUDE" vcqi_global RI_QUAL_08_TO_FOOTNOTE_2 Note: Early doses are accepted in this analysis; all doses are considered valid doses.
vcqi_global RI_QUAL_08_TO_FOOTNOTE_3 Note: The final measure on this sheet, MOVs per Visit, is not a percent.  It is a ratio.  

RI_QUAL_08

* Estimate the proportion of children who experienced 1+ MOVs
vcqi_global RI_QUAL_09_VALID_OR_CRUDE VALID

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
		
RI_QUAL_09

* Estimate the proportion of intervals that are longer
* than the specified thresholds
* 1. Penta1 to Penta2 longer than 56 days
* 2. Penta2 to Penta3 longer than 56 days
* 3. BGC to MCV1 longer than 273 days

vcqi_global RI_QUAL_12_DOSE_PAIR_LIST PENTA1 PENTA2 PENTA2 PENTA3 BCG MCV1
vcqi_global RI_QUAL_12_THRESHOLD_LIST 56 56 273

vcqi_global RI_QUAL_12_TO_TITLE       Dose Intervals Exceed Thresholds
vcqi_global RI_QUAL_12_TO_SUBTITLE
vcqi_global RI_QUAL_12_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.

RI_QUAL_12

* Estimate proportion of Penta3 doses that were given before 26 weeks
vcqi_global RI_QUAL_13_DOSE_NAME PENTA3
vcqi_global RI_QUAL_13_AGE_THRESHOLD `=(26*7)+1'

vcqi_global RI_QUAL_13_TO_TITLE       `=upper("$RI_QUAL_13_DOSE_NAME")' Received Before Age $RI_QUAL_13_AGE_THRESHOLD Days
vcqi_global RI_QUAL_13_TO_SUBTITLE
vcqi_global RI_QUAL_13_TO_FOOTNOTE_1  Note: This measure is an unweighted summary of a proportion from the survey sample.

RI_QUAL_13

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
* the Upper vs Lower province?

vcqi_global COVG_DIFF_01_STRATUM_LEVEL 2
vcqi_global COVG_DIFF_01_ANALYSIS_COUNTER $ANALYSIS_COUNTER

vcqi_global COVG_DIFF_01_ID_OR_NAME NAME

vcqi_global COVG_DIFF_01_STRATUM_NAME1 UPPER PROVINCE
vcqi_global COVG_DIFF_01_STRATUM_NAME2 LOWER PROVINCE

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
* in province 2 (which is named Upper Province).
* 

vcqi_global COVG_DIFF_02_ID_OR_NAME NAME
vcqi_global COVG_DIFF_02_STRATUM_NAME Upper Province

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
* Make RI augmented dataset for additional anaylsis purposes if user requests it.

if "$VCQI_MAKE_AUGMENTED_DATASET"=="1" make_RI_augmented_dataset, noidenticaldupes

* Close the datasets that hold the results of 
* hypothesis tests, and put them into the output spreadsheet
*
* Close the log file and put it into the output spreadsheet
*
* Clean up extra files
* 
* Send a message to the screen if there are warnings or errors in the log

vcqi_cleanup
