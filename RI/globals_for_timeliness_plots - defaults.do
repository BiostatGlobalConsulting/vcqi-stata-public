*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-09-24	1.00	Dale Rhoda		Original version
* 2021-01-05	1.01	Dale Rhoda		Added comments and tweaked slightly
*******************************************************************************

*
* DT means 'default tiles'
*
* CD means 'customized doses'
*

* Establish parameters for default tiles

global TIMELY_N_DTS 5  // 5 tiles per dose

global TIMELY_DT_UB_1 0     // given before the target age - so given early
global TIMELY_DT_UB_2 28    // given < the target age plus 28 days - so timely (within 28 days)
global TIMELY_DT_UB_3 56    // given < the target age plus 56 days - so < 2 months late
global TIMELY_DT_UB_4 1000  // given >=  the target age plus 56 days - so 2+ months late
                            // note that the fifth tile does not have an upper bound; it represents children whose timing is unknown

global TIMELY_DT_COLOR_1 magenta*2
global TIMELY_DT_COLOR_2 green
global TIMELY_DT_COLOR_3 magenta*.5
global TIMELY_DT_COLOR_4 magenta*.8
global TIMELY_DT_COLOR_5 magenta*.10        

global TIMELY_DT_LCOLOR_1 gs2
global TIMELY_DT_LCOLOR_2 gs2
global TIMELY_DT_LCOLOR_3 gs2
global TIMELY_DT_LCOLOR_4 gs2
global TIMELY_DT_LCOLOR_5 gs2

global TIMELY_DT_LWIDTH_1 *.2
global TIMELY_DT_LWIDTH_2 *.2
global TIMELY_DT_LWIDTH_3 *.2
global TIMELY_DT_LWIDTH_4 *.2
global TIMELY_DT_LWIDTH_5 *.2

global TIMELY_DT_LABEL_1 Too Early
global TIMELY_DT_LABEL_2 Timely (28 days)
global TIMELY_DT_LABEL_3 < 2 Months Late
global TIMELY_DT_LABEL_4 2+ Months Late
global TIMELY_DT_LABEL_5 Timing Unknown

global TIMELY_DT_LEGEND_LABEL_1 Too Early
global TIMELY_DT_LEGEND_LABEL_2 Timely (28 Days)
global TIMELY_DT_LEGEND_LABEL_3 < 2 Months Late
global TIMELY_DT_LEGEND_LABEL_4 2+ Months Late
global TIMELY_DT_LEGEND_LABEL_5 Timing Unknown

* Legend order is left-to-right on the plot
* If the user chooses to customize the tiles for some doses then
* these settings are often adjusted in the control program or
* later in this .do file.

global TIMELY_DT_LEGEND_ORDER_1 1 
global TIMELY_DT_LEGEND_ORDER_2 2 
global TIMELY_DT_LEGEND_ORDER_3 3
global TIMELY_DT_LEGEND_ORDER_4 4
global TIMELY_DT_LEGEND_ORDER_5 5

*********************************************
*
* Specify parameters for customized doses
* Note that some of these parameters over-ride the defaults set above
*
*
* Specify customized tile and legend definitions, but wrap them in a 
* comment block so they will not be used by default.  
*
* These serve as examples.  Users may update the custom definitions either
* in this .do file or in their control program.

/*

	global TIMELY_CD_LIST bcg hepb  // customized definitions for BCG & HEPB

	global TIMELY_CD_BCG_NTILES 5   // BCG still has 5 tiles

	global TIMELY_CD_BCG_UB_1 5     // First tile is for given <= target age (0 days) plus 5 days
	global TIMELY_CD_BCG_UB_2 56    // Second is for given < 2 months late
	global TIMELY_CD_BCG_UB_3 365   // Third is for given 2+ months late but within a year
	global TIMELY_CD_BCG_UB_4 1000  // Fourth is for doses given after age 1 year
	global TIMELY_CD_BCG_UB_5 
	global TIMELY_CD_BCG_UB_6 

	global TIMELY_CD_BCG_COLOR_1 green*2    //use a dark green for this special BCG timely category
	global TIMELY_CD_BCG_COLOR_2 magenta*.5 // standard color
	global TIMELY_CD_BCG_COLOR_3 magenta*.8 // standard color
	global TIMELY_CD_BCG_COLOR_4 black      // very late BCG shows in a BLACK bar
	global TIMELY_CD_BCG_COLOR_5 magenta*.1 // standard color
	global TIMELY_CD_BCG_COLOR_6 

	global TIMELY_CD_BCG_LCOLOR_1 gs2
	global TIMELY_CD_BCG_LCOLOR_2 gs2
	global TIMELY_CD_BCG_LCOLOR_3 gs2
	global TIMELY_CD_BCG_LCOLOR_4 gs2
	global TIMELY_CD_BCG_LCOLOR_5 gs2
	global TIMELY_CD_BCG_LCOLOR_6 gs2

	global TIMELY_CD_BCG_LWIDTH_1 *.2
	global TIMELY_CD_BCG_LWIDTH_2 *.2
	global TIMELY_CD_BCG_LWIDTH_3 *.2
	global TIMELY_CD_BCG_LWIDTH_4 *.2
	global TIMELY_CD_BCG_LWIDTH_5 *.2
	global TIMELY_CD_BCG_LWIDTH_6 *.2

	global TIMELY_CD_BCG_LABEL_1 BCG by day 5 
	global TIMELY_CD_BCG_LABEL_2 < 2 Months Late
	global TIMELY_CD_BCG_LABEL_3 2+ Months Late
	global TIMELY_CD_BCG_LABEL_4 After 1 Year (BCG only)
	global TIMELY_CD_BCG_LABEL_5 Timing Unknown
	global TIMELY_CD_BCG_LABEL_6                                 

	global TIMELY_CD_BCG_LEGEND_LABEL_1 BCG by Day 5
	global TIMELY_CD_BCG_LEGEND_LABEL_2 < 2 Months Late
	global TIMELY_CD_BCG_LEGEND_LABEL_3 2+ Months Late
	global TIMELY_CD_BCG_LEGEND_LABEL_4 BGC After 1 Year
	global TIMELY_CD_BCG_LEGEND_LABEL_5 Timing Unknown
	global TIMELY_CD_BCG_LEGEND_LABEL_6     

	* Only two of these are new categories...so only two need to go on the legend
	* Because we are specifying spot 1 here, we will need to reset the DT_LEGEND_ORDERs

	global TIMELY_CD_BCG_LEGEND_ORDER_1 1
	global TIMELY_CD_BCG_LEGEND_ORDER_2 
	global TIMELY_CD_BCG_LEGEND_ORDER_3 
	global TIMELY_CD_BCG_LEGEND_ORDER_4 8
	global TIMELY_CD_BCG_LEGEND_ORDER_5 
	global TIMELY_CD_BCG_LEGEND_ORDER_6
	 
	*********************************************

	global TIMELY_CD_HEPB_NTILES 4

	global TIMELY_CD_HEPB_UB_1 2      // HEPB is timely if given on day 0 or 1
	global TIMELY_CD_HEPB_UB_2 56     // < 2 months late
	global TIMELY_CD_HEPB_UB_3 1000   // 2+  months late

	global TIMELY_CD_HEPB_COLOR_1 green*.33   // use yet another green for HEPB timely
	global TIMELY_CD_HEPB_COLOR_2 magenta*.5
	global TIMELY_CD_HEPB_COLOR_3 magenta*.8
	global TIMELY_CD_HEPB_COLOR_4 magenta*.1

	global TIMELY_CD_HEPB_LCOLOR_1 gs2
	global TIMELY_CD_HEPB_LCOLOR_2 gs2
	global TIMELY_CD_HEPB_LCOLOR_3 gs2
	global TIMELY_CD_HEPB_LCOLOR_4 gs2

	global TIMELY_CD_HEPB_LWIDTH_1 *.2
	global TIMELY_CD_HEPB_LWIDTH_2 *.2
	global TIMELY_CD_HEPB_LWIDTH_3 *.2
	global TIMELY_CD_HEPB_LWIDTH_4 *.2

	global TIMELY_CD_HEPB_LABEL_1 Timely (within 1 day)
	global TIMELY_CD_HEPB_LABEL_2 < 2 Months Late
	global TIMELY_CD_HEPB_LABEL_3 2+ Months Late
	global TIMELY_CD_HEPB_LABEL_4 Timing Unknown  

	global TIMELY_CD_HEPB_LEGEND_LABEL_1 HEPB by Day 1
	global TIMELY_CD_HEPB_LEGEND_LABEL_2 < 2 Months Late
	global TIMELY_CD_HEPB_LEGEND_LABEL_3 2+ Months Late
	global TIMELY_CD_HEPB_LEGEND_LABEL_4 Timing Unknown  

	global TIMELY_CD_HEPB_LEGEND_ORDER_1 2 // only this category needs a new legend entry
	global TIMELY_CD_HEPB_LEGEND_ORDER_2 
	global TIMELY_CD_HEPB_LEGEND_ORDER_3 
	global TIMELY_CD_HEPB_LEGEND_ORDER_4 

	* Now because we introduced new tiles in the #1 and #2 slots 
	* (BCG timely and HEPB timely, respectively)
	* we need to move the default tile legend entries
	* from slots 1-5 to 3-7.

	global TIMELY_DT_LEGEND_ORDER_1 3 
	global TIMELY_DT_LEGEND_ORDER_2 4 
	global TIMELY_DT_LEGEND_ORDER_3 5
	global TIMELY_DT_LEGEND_ORDER_4 6
	global TIMELY_DT_LEGEND_ORDER_5 7

	* End of customized tile & legend definitions
*/
*********************************************

global TIMELY_XLABEL_SIZE 5pt
global TIMELY_XLABEL_COLOR black

global TIMELY_YLABEL_SIZE 5pt
global TIMELY_YLABEL_COLOR black

global TIMELY_BARWIDTH 0.67

global TIMELY_CI_LCOLOR gs8
global TIMELY_CI_LWIDTH vthin
global TIMELY_CI_MSIZE  small

* User can specify additional legend options here - and may over-ride these defaults by resetting this global later
global TIMELY_LEGEND_OPTIONS row(1) symxsize(*.3) symysize(*1) size(*.5) keygap(0.5) region(lcolor(white)) span // could consider using row(2) 

*********************************************
*
* Text bar options

* ORDER is from left to right
* If you do not wish to annotate the plot with a text bar,
* simply make the TIMELY_TEXTBAR_ORDER empty.

global TIMELY_TEXTBAR_ORDER COVG N NEFF DEFF ICC

global TIMELY_TEXTBAR_X_COVG 104
global TIMELY_TEXTBAR_X_N    117
global TIMELY_TEXTBAR_X_NEFF 127
global TIMELY_TEXTBAR_X_DEFF 137
global TIMELY_TEXTBAR_X_ICC  147

* TIMELY_TEXTBAR_LABEL_Y_SPACE is a buffer between the top row of TEXTBAR and
* its column labels.  We usually set this to be 1 to 1.5 times the barwidth
global TIMELY_TEXTBAR_LABEL_Y_SPACE 0.67

global TIMELY_TEXTBAR_LABEL_COVG Coverage(%)
global TIMELY_TEXTBAR_LABEL_N    N
global TIMELY_TEXTBAR_LABEL_NHBR NHBR
global TIMELY_TEXTBAR_LABEL_NEFF NEFF
global TIMELY_TEXTBAR_LABEL_DEFF DEFF
global TIMELY_TEXTBAR_LABEL_ICC  ICC

global TIMELY_XSCALE_MAX     155

global TIMELY_TEXTBAR_SIZE_COVG 5pt
global TIMELY_TEXTBAR_SIZE_N    5pt
global TIMELY_TEXTBAR_SIZE_NHBR 5pt
global TIMELY_TEXTBAR_SIZE_NEFF 5pt
global TIMELY_TEXTBAR_SIZE_DEFF 5pt
global TIMELY_TEXTBAR_SIZE_ICC  5pt

global TIMELY_TEXTBAR_COLOR_COVG black
global TIMELY_TEXTBAR_COLOR_N    black
global TIMELY_TEXTBAR_COLOR_NHBR black
global TIMELY_TEXTBAR_COLOR_NEFF black
global TIMELY_TEXTBAR_COLOR_DEFF black
global TIMELY_TEXTBAR_COLOR_ICC  black

* Number of digits after the decimal in coverage 
global TIMELY_TEXTBAR_COVG_DEC_DIGITS 1

* Number of digits after the decimal in ICC
global TIMELY_TEXTBAR_ICC_DEC_DIGITS  3

*********************************************

* Specify whether to indicate the % who showed a HBR (or register)
* If yes, set this to 1, otherwise 0
global TIMELY_HBR_LINE_PLOT 1

* If yes, then which variable from RI_QUAL_01 do you want to use?
* The default is had_card.  There are several other options, especially
* if the survey visited health centers to look at register records.
global TIMELY_HBR_LINE_VARIABLE had_card

*  HBR line properties
global TIMELY_HBR_LINE_WIDTH medium
global TIMELY_HBR_LINE_COLOR gs8
global TIMELY_HBR_LINE_PATTERN shortdash
global TIMELY_HBR_LINE_LABEL <-- Showed HBR

*********************************************

* If the user specifies they want to see some ylines, specify line properties here
global TIMELY_YLINE_LCOLOR gs14
global TIMELY_YLINE_LWIDTH thin

*********************************************

* User can pass thru any Stata twoway options here (and may over-ride this default by redefining the global)
global TIMELY_TWOWAY_OPTIONS note("   Abbreviations: HBR: Home-based record  NEFF: Effective sample size  DEFF: Design effect  ICC: Intracluster correlation coefficient", size(5pt) place(w) span)


