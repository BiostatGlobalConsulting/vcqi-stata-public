
*
* DT means 'default tiles'
*
* CD means 'customized doses'
*


global TIMELY_N_DTS 5

global TIMELY_DT_UB_1 0
global TIMELY_DT_UB_2 28
global TIMELY_DT_UB_3 56
global TIMELY_DT_UB_4 1000

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
global TIMELY_DT_LABEL_2 Timely (within 28 days)
global TIMELY_DT_LABEL_3 < 2 Months Late
global TIMELY_DT_LABEL_4 2+ Months Late
global TIMELY_DT_LABEL_5 Timing Unknown

global TIMELY_DT_LEGEND_LABEL_1 Too Early
global TIMELY_DT_LEGEND_LABEL_2 Timely (within 28 days)
global TIMELY_DT_LEGEND_LABEL_3 < 2 Months Late
global TIMELY_DT_LEGEND_LABEL_4 2+ Months Late
global TIMELY_DT_LEGEND_LABEL_5 Timing Unknown

global TIMELY_DT_LEGEND_ORDER_1 1 
global TIMELY_DT_LEGEND_ORDER_2 2 
global TIMELY_DT_LEGEND_ORDER_3 3
global TIMELY_DT_LEGEND_ORDER_4 4
global TIMELY_DT_LEGEND_ORDER_5 5

*********************************************


*********************************************

global TIMELY_XLABEL_SIZE 5pt
global TIMELY_XLABEL_COLOR black

global TIMELY_YLABEL_SIZE 5pt
global TIMELY_YLABEL_COLOR black

global TIMELY_BARWIDTH 0.67

global TIMELY_CI_LCOLOR gs8
global TIMELY_CI_LWIDTH vthin
global TIMELY_CI_MSIZE  small

global TIMELY_LEGEND_OPTIONS symxsize(*.3) symysize(*1) size(*.5) keygap(0.5) region(lcolor(white)) span

*********************************************
*
* Text bar options

* ORDER is from left to right

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

global TIMELY_TEXTBAR_COVG_DEC_DIGITS 1
global TIMELY_TEXTBAR_ICC_DEC_DIGITS  3

*********************************************

global TIMELY_HBR_LINE_PLOT 1
global TIMELY_HBR_LINE_VARIABLE had_card
global TIMELY_HBR_LINE_WIDTH medium
global TIMELY_HBR_LINE_COLOR gs8
global TIMELY_HBR_LINE_PATTERN shortdash
global TIMELY_HBR_LINE_LABEL <-- Showed HBR

*********************************************

global TIMELY_YLINE_LCOLOR gs14
global TIMELY_YLINE_LWIDTH thin

*********************************************

global TIMELY_TWOWAY_OPTIONS note("   Abbreviations: HBR: Home-based record  NEFF: Effective sample size  DEFF: Design effect  ICC: Intracluster correlation coefficient", size(5pt) place(w) span)


