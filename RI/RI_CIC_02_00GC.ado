*! RI_CIC_02_00GC version 1.02 - Biostat Global Consulting - 2020-09-27
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2019-01-10	1.00	Mary Prier		Original version
* 2020-04-11	1.01	Dale Rhoda		Check RI_CIC_02_CARD_SHADED_WIDTH_PCT
* 2020-09-27	1.02	Dale Rhoda		Use capture confirm integer number
*******************************************************************************

program define RI_CIC_02_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CIC_02_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	 
	vcqi_log_global RI_CIC_02_DOSE_NAME
	vcqi_log_global RI_DOSE_LIST
	
	local exitflag 0
	
	* Check if <dose>_min_interval_days scalars are defined 
	* First, build local of doses to loop over...
	local loop_over 
	foreach d in `=lower("$RI_MULTI_2_DOSE_LIST")' {
		local loop_over `loop_over' `d'2
	}
	foreach d in `=lower("$RI_MULTI_3_DOSE_LIST")' {
		local loop_over `loop_over' `d'2 `d'3
	}
	* Now check if scalars are defined
	foreach d in `loop_over' {
		capture confirm scalar `d'_min_interval_days
		if _rc!=0 {
			di as error "Scalar `d'_min_interval_days is not defined. Please define this scalar in the schedule part of the control program."
			vcqi_log_comment $VCP 1 Error "Scalar `d'_min_interval_days is not defined. Please define this scalar in the schedule part of the control program."
			local exitflag 1
		}
	}			

	* Check if plot title was specified
	if "$RI_CIC_02_PLOT_TITLE"=="" {
		noi di as text "Global variable for CIC plot title was not defined."
		vcqi_global RI_CIC_02_PLOT_TITLE
		vcqi_log_comment $VCP 2 CIC "Global variable for CIC plot title (RI_CIC_02_PLOT_TITLE) was not defined."
	}
	
	* Check if global RI_CIC_02_PLOT_LEVELS was specified; if not set to 3 (i.e., plots will be made for all 3 levels: 1=nation, 2=zone, 3=stratum)
	if "$RI_CIC_02_PLOT_LEVELS"=="" {
		vcqi_global RI_CIC_02_PLOT_LEVELS 1 2 3
		vcqi_log_comment $VCP 3 CIC "Global variable RI_CIC_02_PLOT_LEVELS was not defined. Default is to make CIC plots for nation/zone/stratum."
	}
	* Else, check that levels specified were in the set {1,2,3}
	else {
		foreach i in $RI_CIC_02_PLOT_LEVELS {
			local plot_levels_check = inlist(`i',1,2,3)
			if(`plot_levels_check'==0) {
				noi di as text "`i' is not a valid level. Valid levels include {1,2,3}. Please update global RI_CIC_02_PLOT_LEVELS."
				vcqi_log_comment $VCP 1 CIC "`i' is not a valid level. Valid levels include {1,2,3}. Please update global RI_CIC_02_PLOT_LEVELS."
				local exitflag 1
			}			
		}	
	}
	
	* Check if RI_CIC_02_XMAX_INTERVAL was specified; if not set to 10
	if "$RI_CIC_02_XMAX_INTERVAL"=="" {
		noi di as text "Global variable for RI_CIC_02_XMAX_INTERVAL was not defined. Setting this global to 10."
		vcqi_global RI_CIC_02_XMAX_INTERVAL 10
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_XMAX_INTERVAL was not defined. Setting this global to 10."
	}
	* Else, check that it's an integer
	else {
		capture confirm integer number $RI_CIC_02_XMAX_INTERVAL
		if(_rc!=0) {
			noi di as text "$RI_CIC_02_XMAX_INTERVAL is not an integer. Please update global RI_CIC_02_XMAX_INTERVAL to be an integer."
			vcqi_log_comment $VCP 1 CIC "$RI_CIC_02_XMAX_INTERVAL is not an integer. Please update global RI_CIC_02_XMAX_INTERVAL to be an integer."
			local exitflag 1
		}	
	}
	
	* Check if RI_CIC_02_GRAPHREGION_COLOR was specified; if not set to white
	if "$RI_CIC_02_GRAPHREGION_COLOR"=="" {
		noi di as text "Global variable for RI_CIC_02_GRAPHREGION_COLOR was not defined. Setting this global to white."
		vcqi_global RI_CIC_02_GRAPHREGION_COLOR white
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_GRAPHREGION_COLOR was not defined. Setting this global to white."
	}
	
	* Check if RI_CIC_02_XLABEL_SIZE was specified; if not set to medsmall
	if "$RI_CIC_02_XLABEL_SIZE"=="" {
		noi di as text "Global variable for RI_CIC_02_XLABEL_SIZE was not defined. Setting this global to medsmall."
		vcqi_global RI_CIC_02_XLABEL_SIZE medsmall
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_XLABEL_SIZE was not defined. Setting this global to medsmall."
	}
	
	* Check if RI_CIC_02_XLABEL_ALTERNATE was specified; if not set to 0 (0=No)
	if "$RI_CIC_02_XLABEL_ALTERNATE"=="" {
		noi di as text "Global variable for RI_CIC_02_XLABEL_ALTERNATE was not defined. Setting this global to 0 (0 means do not alternate x-labels."
		vcqi_global RI_CIC_02_XLABEL_ALTERNATE 0
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_XLABEL_ALTERNATE was not defined. Setting this global to 0 (0 means do not alternate x-labels."
	}
	* Else, check that it's either 0 or 1
	else {
		if("$RI_CIC_02_XLABEL_ALTERNATE"!="0" & "$RI_CIC_02_XLABEL_ALTERNATE"!="1") {
			noi di as text "global RI_CIC_02_XLABEL_ALTERNATE is set to $RI_CIC_02_XLABEL_ALTERNATE, an invalid assignment. Please update global RI_CIC_02_XLABEL_ALTERNATE to be either 0 or 1."
			vcqi_log_comment $VCP 1 CIC "global RI_CIC_02_XLABEL_ALTERNATE is set to $RI_CIC_02_XLABEL_ALTERNATE, an invalid assignment. Please update global RI_CIC_02_XLABEL_ALTERNATE to be either 0 or 1."
			local exitflag 1
		}	
	}
	
	* Check if RI_CIC_02_COLOR was specified; if not set to gs3 red blue gold gs8 purple green magenta sand cyan
	if "$RI_CIC_02_COLOR"=="" {
		noi di as text "Global variable for RI_CIC_02_COLOR was not defined. Setting this global to gs3 red blue gold gs8 purple green magenta sand cyan."
		vcqi_global RI_CIC_02_COLOR navy
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_COLOR was not defined. Setting this global to gs3 red blue gold gs8 purple green magenta sand cyan."
	}
	
	* Check if RI_CIC_02_PATTERN was specified; if not set to solid dash longdash solid solid dash solid dash solid dash
	if "$RI_CIC_02_PATTERN"=="" {
		noi di as text "Global variable for RI_CIC_02_PATTERN was not defined. Setting this global to solid dash longdash solid solid dash solid dash solid dash."
		vcqi_global RI_CIC_02_PATTERN solid
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_PATTERN was not defined. Setting this global to solid dash longdash solid solid dash solid dash solid dash."
	}
	
	* Check if RI_CIC_02_WIDTH was specified; if not set to medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin
	if "$RI_CIC_02_WIDTH"=="" {
		noi di as text "Global variable for RI_CIC_02_WIDTH was not defined. Setting this global to medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin."
		vcqi_global RI_CIC_02_WIDTH medthin
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_WIDTH was not defined. Setting this global to medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin."
	}
	
	* Check if RI_CIC_02_VLINE_COLOR was specified; if not set to gs10
	if "$RI_CIC_02_VLINE_COLOR"=="" {
		noi di as text "Global variable for RI_CIC_02_VLINE_COLOR was not defined. Setting this global to gs10."
		vcqi_global RI_CIC_02_VLINE_COLOR gs10
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_VLINE_COLOR was not defined. Setting this global to gs10."
	}
	
	* Check if RI_CIC_02_VLINE_PATTERN was specified; if not set to longdash
	if "$RI_CIC_02_VLINE_PATTERN"=="" {
		noi di as text "Global variable for RI_CIC_02_VLINE_PATTERN was not defined. Setting this global to longdash."
		vcqi_global RI_CIC_02_VLINE_PATTERN longdash
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_VLINE_PATTERN was not defined. Setting this global to longdash."
	}
	
	* Check if RI_CIC_02_VLINE_WIDTH was specified; if not set to medthin
	if "$RI_CIC_02_VLINE_WIDTH"=="" {
		noi di as text "Global variable for RI_CIC_02_VLINE_WIDTH was not defined. Setting this global to medthin."
		vcqi_global RI_CIC_02_VLINE_WIDTH medthin
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_VLINE_WIDTH was not defined. Setting this global to medthin."
	}
	
	* Vertical lines denoting smallest valid dose interval...
	* If <dose>_min_interval_days != <dose#+1>_min_age_days-<dose#>_min_age_days, then 2 vertical lines will appear on CIC plot
	*  (i.e., if AFRO schedule or PAHO schedule...will there be 1 or 2 vertical lines when child was eligible for dose)
	*  Regardless if there will be 2 vertical lines plotted or not, make sure there are 2 defined in the globals (in case 2 are needed)
	* Check if RI_CIC_02_VLINE_COLOR/PATTERN/WIDTH has two components (e.g., RI_CIC_02_VLINE_COLOR blue green)
	* Note: We know these globals have at least one defined (from 3 previous checks)
	* RI_CIC_02_VLINE_COLOR
	local color_size : list sizeof global(RI_CIC_02_VLINE_COLOR)
	if(`color_size'<2) {
		noi di as text "Global variable for RI_CIC_02_VLINE_COLOR needs two entries. Setting this global to $RI_CIC_02_VLINE_COLOR gs10."
		vcqi_global RI_CIC_02_VLINE_COLOR $RI_CIC_02_VLINE_COLOR gs10
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_VLINE_COLOR needs two entries. Setting this global to $RI_CIC_02_VLINE_COLOR gs10."
	}
	* RI_CIC_02_VLINE_PATTERN
	local pattern_size : list sizeof global(RI_CIC_02_VLINE_PATTERN)
	if(`pattern_size'<2) {
		noi di as text "Global variable for RI_CIC_02_VLINE_PATTERN needs two entries. Setting this global to $RI_CIC_02_VLINE_PATTERN solid."
		vcqi_global RI_CIC_02_VLINE_COLOR $RI_CIC_02_VLINE_PATTERN solid
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_VLINE_PATTERN needs two entries. Setting this global to $RI_CIC_02_VLINE_PATTERN solid."
	}
	* RI_CIC_02_VLINE_WIDTH
	local width_size : list sizeof global(RI_CIC_02_VLINE_WIDTH)
	if(`width_size'<2) {
		noi di as text "Global variable for RI_CIC_02_VLINE_WIDTH needs two entries. Setting this global to $RI_CIC_02_VLINE_WIDTH medthin."
		vcqi_global RI_CIC_02_VLINE_COLOR $RI_CIC_02_VLINE_WIDTH medthin
		vcqi_log_comment $VCP 3 CIC "Global variable for RI_CIC_02_VLINE_WIDTH needs two entries. Setting this global to $RI_CIC_02_VLINE_WIDTH medthin."
	}
		
	* Check that if RI_CIC_02_CARD_REGISTER is defined, that it only is set to card and/or register
	if ("$RI_CIC_02_CARD_REGISTER" != "") {
		local card_register_size : list sizeof global(RI_CIC_02_CARD_REGISTER)
		if(`card_register_size'>2) {
			noi di as text "global RI_CIC_02_CARD_REGISTER is set to $RI_CIC_02_CARD_REGISTER, an invalid assignment. Valid entries are card and/or register. Please update global RI_CIC_02_CARD_REGISTER, or set it to missing."
			vcqi_log_comment $VCP 1 CIC "global RI_CIC_02_CARD_REGISTER is set to $RI_CIC_02_CARD_REGISTER, an invalid assignment. Valid entries are card and/or register. Please update global RI_CIC_02_CARD_REGISTER, or set it to missing."
			local exitflag 1
		}
		
		foreach i in $RI_CIC_02_CARD_REGISTER {
			if(!inlist("`i'","card","register")) {
				noi di as text "global RI_CIC_02_CARD_REGISTER contains `i', an invalid entry. Valid entries are card and/or register. Please update global RI_CIC_02_CARD_REGISTER, or set it to missing."
				vcqi_log_comment $VCP 1 CIC "global RI_CIC_02_CARD_REGISTER contains `i', an invalid entry. Valid entries are card and/or register. Please update global RI_CIC_02_CARD_REGISTER, or set it to missing."
				local exitflag 1
			}
		}
	}
	
	* Check that if RI_CIC_02_XLABELS is defined, that it only contains integers
	if ("$RI_CIC_02_XLABELS" != "") {
		foreach i in $RI_CIC_02_XLABELS {
			capture confirm integer number `i'
			if(_rc!=0) {
				noi di as text "global RI_CIC_02_XLABELS contains `i'. Please update global RI_CIC_02_XLABELS to only contain integer(s)."
				vcqi_log_comment $VCP 1 CIC "global RI_CIC_02_XLABELS contains `i'. Please update global RI_CIC_02_XLABELS to only contain integer(s)."
				local exitflag 1
			}	
		}	
	}	
		
	* Set the width of the shaded portion of the plot to be 5% of the width of the non-shaded, if the user has not specified the parameter.
	if "$RI_CIC_02_CARD_SHADED_WIDTH_PCT" == "" vcqi_global RI_CIC_02_CARD_SHADED_WIDTH_PCT 5
	
	* Require the parameter to fall between 1 and 100% inclusive.
	if $RI_CIC_02_CARD_SHADED_WIDTH_PCT < 1 | $RI_CIC_02_CARD_SHADED_WIDTH_PCT > 100 {
		di as error "The parameter RI_CIC_02_CARD_SHADED_WIDTH_PCT should fall between 1 and 100.  You specified $RI_CIC_02_CARD_SHADED_WIDTH_PCT.  Please make a correction."
		vcqi_log_comment $VCP 1 Error "The parameter RI_CIC_02_CARD_SHADED_WIDTH_PCT should fall between 1 and 100.  You specified $RI_CIC_02_CARD_SHADED_WIDTH_PCT.  Please make a correction."
		local exitflag 1
	}
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		di `exitflag'
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end


