*! RI_CCC_02_00GC version 1.02 - Biostat Global Consulting - 2020-09-27
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-12-06	1.00	Mary Prier		Original version	
* 2020-04-11	1.01	Dale Rhoda		Check RI_CCC_02_CARD_SHADED_WIDTH_PCT
* 2020-09-27	1.02	Dale Rhoda		Use capture confirm integer number
*******************************************************************************

program define RI_CCC_02_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_CCC_02_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	 
	vcqi_log_global RI_CCC_02_DOSE_NAME
	vcqi_log_global RI_DOSE_LIST
	
	local exitflag 0
	
	* Check if plot title was specified
	if "$RI_CCC_02_PLOT_TITLE"=="" {
		noi di as text "Global variable for CCC plot title was not defined."
		vcqi_global RI_CCC_02_PLOT_TITLE
		vcqi_log_comment $VCP 2 CCC "Global variable for CCC plot title (RI_CCC_02_PLOT_TITLE) was not defined."
	}
	
	* Check if global RI_CCC_02_PLOT_LEVELS was specified; if not set to 1 2 3 (i.e., plots will be made for all 3 levels: 1=nation, 2=zone, 3=stratum)
	if "$RI_CCC_02_PLOT_LEVELS"=="" {
		noi di as text "Global variable RI_CCC_02_PLOT_LEVELS was not defined. Default is to make CCC plots for nation/zone/stratum."
		vcqi_global RI_CCC_02_PLOT_LEVELS 1 2 3
		vcqi_log_comment $VCP 3 CCC "Global variable RI_CCC_02_PLOT_LEVELS was not defined. Default is to make CCC plots for nation/zone/stratum."
	}
	* Else, check that levels specified were in the set {1,2,3}
	else {
		foreach i in $RI_CCC_02_PLOT_LEVELS {
			local plot_levels_check = inlist(`i',1,2,3)
			if(`plot_levels_check'==0) {
				noi di as text "`i' is not a valid level. Valid levels include {1,2,3}. Please update global RI_CCC_02_PLOT_LEVELS."
				vcqi_log_comment $VCP 1 CCC "`i' is not a valid level. Valid levels include {1,2,3}. Please update global RI_CCC_02_PLOT_LEVELS."
				local exitflag 1
			}			
		}	
	}
	
	* Check if RI_CCC_02_XMAX_INTERVAL was specified; if not set to 50
	if "$RI_CCC_02_XMAX_INTERVAL"=="" {
		noi di as text "Global variable for RI_CCC_02_XMAX_INTERVAL was not defined. Setting this global to 50."
		vcqi_global RI_CCC_02_XMAX_INTERVAL 50
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_XMAX_INTERVAL was not defined. Setting this global to 50."
	}
	* Else, check that it's an integer
	else {
		capture confirm integer number $RI_CCC_02_XMAX_INTERVAL
		if(_rc!=0) {
			noi di as text "$RI_CCC_02_XMAX_INTERVAL is not an integer. Please update global RI_CCC_02_XMAX_INTERVAL to be an integer."
			vcqi_log_comment $VCP 1 CCC "$RI_CCC_02_XMAX_INTERVAL is not an integer. Please update global RI_CCC_02_XMAX_INTERVAL to be an integer."
			local exitflag 1
		}	
	}
	
	* Check if RI_CCC_02_GRAPHREGION_COLOR was specified; if not set to white
	if "$RI_CCC_02_GRAPHREGION_COLOR"=="" {
		noi di as text "Global variable for RI_CCC_02_GRAPHREGION_COLOR was not defined. Setting this global to white."
		vcqi_global RI_CCC_02_GRAPHREGION_COLOR white
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_GRAPHREGION_COLOR was not defined. Setting this global to white."
	}
	
	* Check if RI_CCC_02_NUM_LEGEND_ROWS was specified; if not set to 2
	if "$RI_CCC_02_NUM_LEGEND_ROWS"=="" {
		noi di as text "Global variable for RI_CCC_02_NUM_LEGEND_ROWS was not defined. Setting this global to 2."
		vcqi_global RI_CCC_02_NUM_LEGEND_ROWS 2
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_NUM_LEGEND_ROWS was not defined. Setting this global to 2."
	}
	* Else, check that it's an integer
	else {
		capture confirm integer number $RI_CCC_02_NUM_LEGEND_ROWS
		if(_rc!=0) {
			noi di as text "$RI_CCC_02_NUM_LEGEND_ROWS is not an integer. Please update global RI_CCC_02_NUM_LEGEND_ROWS to be an integer."
			vcqi_log_comment $VCP 1 CCC "$RI_CCC_02_NUM_LEGEND_ROWS is not an integer. Please update global RI_CCC_02_NUM_LEGEND_ROWS to be an integer."
			local exitflag 1
		}	
	}

	* Check if RI_CCC_02_COLOR was specified; if not set to gs3 red blue gold gs8 purple green magenta sand cyan
	if "$RI_CCC_02_COLOR"=="" {
		noi di as text "Global variable for RI_CCC_02_COLOR was not defined. Setting this global to gs3 red blue gold gs8 purple green magenta sand cyan."
		vcqi_global RI_CCC_02_COLOR gs3 red blue gold gs8 purple green magenta sand cyan
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_COLOR was not defined. Setting this global to gs3 red blue gold gs8 purple green magenta sand cyan."
	}
	
	* Check if RI_CCC_02_PATTERN was specified; if not set to solid dash longdash solid solid dash solid dash solid dash
	if "$RI_CCC_02_PATTERN"=="" {
		noi di as text "Global variable for RI_CCC_02_PATTERN was not defined. Setting this global to solid dash longdash solid solid dash solid dash solid dash."
		vcqi_global RI_CCC_02_PATTERN solid dash longdash solid solid dash solid dash solid dash
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_PATTERN was not defined. Setting this global to solid dash longdash solid solid dash solid dash solid dash."
	}
	
	* Check if RI_CCC_02_WIDTH was specified; if not set to medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin
	if "$RI_CCC_02_WIDTH"=="" {
		noi di as text "Global variable for RI_CCC_02_WIDTH was not defined. Setting this global to medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin."
		vcqi_global RI_CCC_02_WIDTH medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_WIDTH was not defined. Setting this global to medthin medthin medthin medthin medthin medthin medthin medthin medthin medthin."
	}
	
	* Check if RI_CCC_02_VLINE_COLOR was specified; if not set to gs10
	if "$RI_CCC_02_VLINE_COLOR"=="" {
		noi di as text "Global variable for RI_CCC_02_VLINE_COLOR was not defined. Setting this global to gs10."
		vcqi_global RI_CCC_02_VLINE_COLOR gs10
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_VLINE_COLOR was not defined. Setting this global to gs10."
	}
	
	* Check if RI_CCC_02_VLINE_PATTERN was specified; if not set to longdash
	if "$RI_CCC_02_VLINE_PATTERN"=="" {
		noi di as text "Global variable for RI_CCC_02_VLINE_PATTERN was not defined. Setting this global to longdash."
		vcqi_global RI_CCC_02_VLINE_PATTERN longdash
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_VLINE_PATTERN was not defined. Setting this global to longdash."
	}
	
	* Check if RI_CCC_02_VLINE_WIDTH was specified; if not set to medthin
	if "$RI_CCC_02_VLINE_WIDTH"=="" {
		noi di as text "Global variable for RI_CCC_02_VLINE_WIDTH was not defined. Setting this global to medthin."
		vcqi_global RI_CCC_02_VLINE_WIDTH medthin
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_VLINE_WIDTH was not defined. Setting this global to medthin."
	}
	
	* Check if RI_CCC_02_XLABEL_SIZE was specified; if not set to medsmall
	if "$RI_CCC_02_XLABEL_SIZE"=="" {
		noi di as text "Global variable for RI_CCC_02_XLABEL_SIZE was not defined. Setting this global to medsmall."
		vcqi_global RI_CCC_02_XLABEL_SIZE medsmall
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_XLABEL_SIZE was not defined. Setting this global to medsmall."
	}
	
	* Check if RI_CCC_02_XLABEL_ALTERNATE was specified; if not set to 0 (0=No)
	if "$RI_CCC_02_XLABEL_ALTERNATE"=="" {
		noi di as text "Global variable for RI_CCC_02_XLABEL_ALTERNATE was not defined. Setting this global to 0 (0 means do not alternate x-labels."
		vcqi_global RI_CCC_02_XLABEL_ALTERNATE 0
		vcqi_log_comment $VCP 3 CCC "Global variable for RI_CCC_02_XLABEL_ALTERNATE was not defined. Setting this global to 0 (0 means do not alternate x-labels."
	}
	* Else, check that it's either 0 or 1
	else {
		if("$RI_CCC_02_XLABEL_ALTERNATE"!="0" & "$RI_CCC_02_XLABEL_ALTERNATE"!="1") {
			noi di as text "global RI_CCC_02_XLABEL_ALTERNATE is set to $RI_CCC_02_XLABEL_ALTERNATE, an invalid assignment. Please update global RI_CCC_02_XLABEL_ALTERNATE to be either 0 or 1."
			vcqi_log_comment $VCP 1 CCC "global RI_CCC_02_XLABEL_ALTERNATE is set to $RI_CCC_02_XLABEL_ALTERNATE, an invalid assignment. Please update global RI_CCC_02_XLABEL_ALTERNATE to be either 0 or 1."
			local exitflag 1
		}	
	}
	
	* Check that if RI_CCC_02_CARD_REGISTER is defined, that it only is set to card and/or register
	if ("$RI_CCC_02_CARD_REGISTER" != "") {
		local card_register_size : list sizeof global(RI_CCC_02_CARD_REGISTER)
		if(`card_register_size'>2) {
			noi di as text "global RI_CCC_02_CARD_REGISTER is set to $RI_CCC_02_CARD_REGISTER, an invalid assignment. Valid entries are card and/or register. Please update global RI_CCC_02_CARD_REGISTER, or set it to missing."
			vcqi_log_comment $VCP 1 CCC "global RI_CCC_02_CARD_REGISTER is set to $RI_CCC_02_CARD_REGISTER, an invalid assignment. Valid entries are card and/or register. Please update global RI_CCC_02_CARD_REGISTER, or set it to missing."
			local exitflag 1
		}
		
		foreach i in $RI_CCC_02_CARD_REGISTER {
			if(!inlist("`i'","card","register")) {
				noi di as text "global RI_CCC_02_CARD_REGISTER contains `i', an invalid entry. Valid entries are card and/or register. Please update global RI_CCC_02_CARD_REGISTER, or set it to missing."
				vcqi_log_comment $VCP 1 CCC "global RI_CCC_02_CARD_REGISTER contains `i', an invalid entry. Valid entries are card and/or register. Please update global RI_CCC_02_CARD_REGISTER, or set it to missing."
				local exitflag 1
			}
		}
	}
	
	* Check that if RI_CCC_02_XLABELS is defined, that it only contains integers
	if ("$RI_CCC_02_XLABELS" != "") {
		foreach i in $RI_CCC_02_XLABELS {
			capture confirm integer number `i'
			if(_rc!=0) {
				noi di as text "global RI_CCC_02_XLABELS contains `i'. Please update global RI_CCC_02_XLABELS to only contain integer(s)."
				vcqi_log_comment $VCP 1 CCC "global RI_CCC_02_XLABELS contains `i'. Please update global RI_CCC_02_XLABELS to only contain integer(s)."
				local exitflag 1
			}	
		}	
	}
	
	*** Figure out how many antigen families have been defined ***
	qui {
		* Make list of antigens (will be replicates in this list)
		local antigen_list
		foreach d in `=lower("$RI_DOSE_LIST")' {
			local lastchar = substr("`d'",strlen("`d'"),1)
			local allbutlastchar = substr("`d'",1,`=strlen("`d'")-1')
			if (real("`lastchar'") == .) {
				local antigen_list `antigen_list' `d'
			} 
			else {
				local antigen_list `antigen_list' `allbutlastchar'
			}
		}

		* Now make a list of antigens that only contains unique values
		local antigen_family : list uniq antigen_list
		local num_antigen_family : list sizeof local(antigen_family)
	}  // end quietly 
	
	* If RI_CCC_02_COLOR has been defined, make sure the list length is as least as long as the number of antigen families
	if "$RI_CCC_02_COLOR"!="" {
		local color_temp : list sizeof global(RI_CCC_02_COLOR)
		if (`color_temp'<`num_antigen_family') {
			di as error "The number of elements in global variable RI_CCC_02_COLOR must be at least as big as the number of antigens defined in the control program. $RI_CCC_02_COLOR contains `color_temp' elements whereas there are `num_antigen_family' antigens specified. Specify more colors in RI_CCC_02_COLOR list."
			vcqi_log_comment $VCP 1 Error "The number of elements in global variable RI_CCC_02_COLOR must be at least as big as the number of antigens defined in the control program. $RI_CCC_02_COLOR contains `color_temp' elements whereas there are `num_antigen_family' antigens specified. Specify more colors in RI_CCC_02_COLOR list."
			local exitflag 1
		}
	}
	
	* If RI_CCC_02_PATTERN has been defined, make sure the list length is as least as long as the number of antigen families
	if "$RI_CCC_02_PATTERN"!="" {
		local pattern_temp : list sizeof global(RI_CCC_02_PATTERN)
		if (`pattern_temp'<`num_antigen_family') {
			di as error "The number of elements in global variable RI_CCC_02_PATTERN must be at least as big as the number of antigens defined in the control program. $RI_CCC_02_PATTERN contains `pattern_temp' elements whereas there are `num_antigen_family' antigens specified. Specify more patterns in RI_CCC_02_PATTERN list. (Note: Can repeat patterns in list.)"
			vcqi_log_comment $VCP 1 Error "The number of elements in global variable RI_CCC_02_PATTERN must be at least as big as the number of antigens defined in the control program. $RI_CCC_02_PATTERN contains `pattern_temp' elements whereas there are `num_antigen_family' antigens specified. Specify more patterns in RI_CCC_02_PATTERN list. (Note: Can repeat patterns in list.)"
			local exitflag 1
		}
	}
	
	* If RI_CCC_02_WIDTH has been defined, make sure the list length is as least as long as the number of antigen families
	if "$RI_CCC_02_WIDTH"!="" {
		local width_temp : list sizeof global(RI_CCC_02_WIDTH)
		if (`width_temp'<`num_antigen_family') {
			di as error "The number of elements in global variable RI_CCC_02_WIDTH must be at least as big as the number of antigens defined in the control program. $RI_CCC_02_WIDTH contains `width_temp' elements whereas there are `num_antigen_family' antigens specified. Specify more widths in RI_CCC_02_WIDTH list. (Note: Can repeat widths in list.)"
			vcqi_log_comment $VCP 1 Error "The number of elements in global variable RI_CCC_02_WIDTH must be at least as big as the number of antigens defined in the control program. $RI_CCC_02_WIDTH contains `width_temp' elements whereas there are `num_antigen_family' antigens specified. Specify more widths in RI_CCC_02_WIDTH list. (Note: Can repeat widths in list.)"
			local exitflag 1
		}
	}
	
	* Set the width of the shaded portion of the plot to be 15% of the width of the non-shaded, if the user has not specified the parameter.
	if "$RI_CCC_02_CARD_SHADED_WIDTH_PCT" == "" vcqi_global RI_CCC_02_CARD_SHADED_WIDTH_PCT 15
	
	* Require the parameter to fall between 1 and 100% inclusive.
	if $RI_CCC_02_CARD_SHADED_WIDTH_PCT < 1 | $RI_CCC_02_CARD_SHADED_WIDTH_PCT > 100 {
		di as error "The parameter RI_CCC_02_CARD_SHADED_WIDTH_PCT should fall between 1 and 100.  You specified $RI_CCC_02_CARD_SHADED_WIDTH_PCT.  Please make a correction."
		vcqi_log_comment $VCP 1 Error "The parameter RI_CCC_02_CARD_SHADED_WIDTH_PCT should fall between 1 and 100.  You specified $RI_CCC_02_CARD_SHADED_WIDTH_PCT.  Please make a correction."
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


