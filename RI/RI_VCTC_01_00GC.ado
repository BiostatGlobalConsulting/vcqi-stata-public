*! RI_VCTC_01_00GC version 1.03 - Biostat Global Consulting - 2020-11-16
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2020-09-24	1.00	Dale Rhoda		Original version
* 2020-11-03	1.01	MK Trimner		Wrote the program based on DAR requests
* 2020-11-06	1.02	Dale Rhoda		Updated error messages to list the
*                                        current (errant) value of globals.
*                                       Also calculate max legend order value.
* 2020-11-16    1.03    Dale Rhoda      Use IF instead of capture assert.
*                                        Also add a few more defaults.
*******************************************************************************

program define RI_VCTC_01_00GC
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_VCTC_01_00GC
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	* Lets start by making a few globals all upper case
	* Make timely dose order upper case
	global TIMELY_DOSE_ORDER = upper("$TIMELY_DOSE_ORDER")
	local timely_dose_order $TIMELY_DOSE_ORDER

	* Make CD list upper case
	global TIMELY_CD_LIST = upper("$TIMELY_CD_LIST")
	local timely_cd_list $TIMELY_CD_LIST
	
	* Create local that will put extra spaces after messages
	
	* We want to create a local that contains all the order values to do a check after we loop through 1/N at the end of program
	local legend_orders
	
	* Create a local that will be set to show there was an error and we need to exit the program
	local exitflag 0

	* First global to check: TIMELY_DOSE_ORDER must be defined
	if "$TIMELY_DOSE_ORDER" == ""  {
		local exitflag 1
		di as error "You must define global variable TIMELY_DOSE_ORDER to make these plots." _n 
		vcqi_log_comment $VCP 1 Error "You must define global variable TIMELY_DOSE_ORDER to make these plots."	
	}
	* We need to make a local with this list sorted
	else local doseorderlist : list sort timely_dose_order

	* All doses in TIMELY_DOSE_ORDER should be in the RI_DOSE_LIST
	foreach t in $TIMELY_DOSE_ORDER {
		if !( `=strpos("`=upper("$RI_DOSE_LIST")'","`t'")' > 0 ) {  
			local exitflag 1
			di as error "Dose `t' provided in global variable TIMELY_DOSE_ORDER must also be part of global variable RI_DOSE_LIST. "
			di as error "(Add `t' to the appropriate global variable RI_SINGLE_DOSE_LIST, RI_MULTI_2_DOSE_LIST or RI_MULTI_3_DOSE_LIST)" _n
			vcqi_log_comment $VCP 1 Error ///
			"Dose `t' provided in global variable TIMELY_DOSE_ORDER must also be part of global variable RI_DOSE_LIST. (Add `t' to the appropriate global variable RI_SINGLE_DOSE_LIST, RI_MULTI_2_DOSE_LIST or RI_MULTI_3_DOSE_LIST)"
		}
	}
	
	* User may set the y coordinates of the bars using the global TIMELY_Y_COORDS   
	if "$TIMELY_Y_COORDS" != "" {
		* SHould hold the same number of elements as TIMELY_DOSE_ORDER
		if wordcount("$TIMELY_DOSE_ORDER") != wordcount("$TIMELY_Y_COORDS") {
			local exitflag 1
			di as error "Global variable TIMELY_Y_COORDS has `=wordcount("$TIMELY_Y_COORDS")' elements in its list, but global TIMELY_DOSE_ORDER has `=wordcount("$TIMELY_DOSE_ORDER").  They should be equal." _n
			vcqi_log_comment $VCP 1 Error ///
			             "Global variable TIMELY_Y_COORDS has `=wordcount("$TIMELY_Y_COORDS")' elements in its list, but global TIMELY_DOSE_ORDER has `=wordcount("$TIMELY_DOSE_ORDER").  They should be equal."
		}
				
		* All elements should be numeric
		tokenize "$TIMELY_Y_COORDS"
		forvalues i = 1/`=wordcount("$TIMELY_Y_COORDS")' {
			local y`i' = ``i''
		}
		
		forvalues i = 1/`=wordcount("$TIMELY_Y_COORDS")' {
			capture confirm integer number `y`i''
			local rc`i' = _rc
			if `rc`i'' != 0 {
				local exitflag 1
				di as error "Global variable TIMELY_Y_COORDS contains the item `y`i'' which is not numeric.  All of its entries should be integers." _n
				vcqi_log_comment $VCP 1 Error ///
							"Global variable TIMELY_Y_COORDS contains the item `y`i'' which is not numeric.  All of its entries should be integers."
			}			
			if `i' > 1 {
				* YCOORD values should be in strictly increasing numeric order
				*
				* If y[i] and y[i-1] are both numeric, then check the order
				if `rc`i'' == 0 & `rc`=`i'-1'' == 0 {
					if `y`i'' <= `y`=`i'-1'' {
						local exitflag 1
						di as error "Global variable TIMELY_Y_COORDS should be in numeric order, but `y`i'' appears after `y`=`i'-1''." _n
						vcqi_log_comment $VCP 1 Error ///
									"Global variable TIMELY_Y_COORDS should be in numeric order, but `y`i'' appears after `y`=`i'-1''."
					}
				}
			}
		}
	}

	* If global variable TIMELY_CD_LIST is defined we need to do some checks and make a sorted list of the the values
	if "$TIMELY_CD_LIST" != "" {
		* Create local with sorted value 
		local cdlist : list sort timely_cd_list
		
		* Second if TIMELY_CD_LIST is defined, it should hold a subset of doses from TIMELY_DOSE_ORDER
		foreach t in $TIMELY_CD_LIST {
			if !( `=strpos("$TIMELY_DOSE_ORDER","`t'")' > 0 ) {
				local exitflag 1
				di as error "Dose `t' provided in global variable TIMELY_CD_LIST must be one of the doses provided in global variable TIMELY_DOSE_ORDER" _n
				vcqi_log_comment $VCP 1 Error ///
				"Dose `t' provided in global variable TIMELY_CD_LIST must be one of the doses provided in global variable TIMELY_DOSE_ORDER"
			}
		}
	}
	
	* For each dose in the TIMELY_CD_LIST, check the following globals are also populated:
	foreach t in $TIMELY_CD_LIST {
		if "${TIMELY_CD_`t'_NTILES}" == "" {
			local exitflag 1
			di as error "Global variable TIMELY_CD_`t'_NTILES must be populated." _n
			vcqi_log_comment $VCP 1 Error "Global variable TIMELY_CD_`t'_NTILES must be populated."
		}
		else {
			* TIMELY_CD_<dose in caps>_NTILES will be a positive integer
			positive_integer_check TIMELY_CD_`t'_NTILES
			if `positive_integer' == 0 {

				* For each value of 1/TIMELY_CD_<dose in caps>_NTILES, the following
				forvalues i = 1/${TIMELY_CD_`t'_NTILES} {
					if `i' != ${TIMELY_CD_`t'_NTILES} {
						* Confirm global  ${TIMELY_CD_`t'_UB_`i'} is set
					if "${TIMELY_CD_`t'_UB_`i'}" == "" {
							local exitflag 1
							di as error "Global variable TIMELY_CD_`t'_UB_`i' must be defined." _n
							vcqi_log_comment $VCP 1 Error "Global variable TIMELY_CD_`t'_UB_`i' must be defined."
						}
						*	TIMELY_CD_<dose in caps>_UB_`i' should be a number greater than TIMELY_CD_<dose in caps>_UB_`=`i'-1'
						else {
							if `i' > 1 {
								if !( ${TIMELY_CD_`t'_UB_`i'} > ${TIMELY_CD_`t'_UB_`=`i'-1'} ) {
									local exitflag 1
									di as error "Global variable TIMELY_CD_`t'_UB_`i' should be greater than TIMELY_CD_`t'_UB_`=`i'-1'" _n
									vcqi_log_comment $VCP 1 Error "Global variable TIMELY_CD_`t'_UB_`i' should be greater than TIMELY_CD_`t'_UB_`=`i'-1'"
								}
							}
						}
						*   TIMELY_CD_<dose in caps>_LABEL_`i' should be defined; if it is not set to default
						if "${TIMELY_CD_`t'_LABEL_`i'}" == "" {
							global TIMELY_CD_`t'_LABEL_`i' Within ${TIMELY_CD_`t'_UB_`i'} days 
							di as text "Global variable TIMELY_CD_`t'_LABEL_`i' was not set."
							di as text `"Default value will be used: "Within ${TIMELY_CD_`t'_UB_`i'} days""' _n							
							vcqi_log_comment $VCP 3 Comment "Global variable TIMELY_CD_`t'_LABEL_`i' was not set. Default value will be used: Within ${TIMELY_CD_`t'_UB_`i'} days"
						}
					}
					if `i' == ${TIMELY_CD_`t'_NTILES} {
						if "${TIMELY_CD_`t'_UB_`i'}" != "" {
							local exitflag 1
							di as error "Global variable TIMELY_CD_`t'_UB_`i' should not be set as this is for the children whose vaccination timing is unknown." _n
							vcqi_log_comment $VCP 1 Error "Global variable TIMELY_CD_`t'_UB_`i' should not be set as this is for the children whose vaccination timing is unknown."
						}
						
						if "${TIMELY_CD_`t'_LABEL_`i'}" == "" {
							global  TIMELY_CD_`t'_LABEL_`i' Timing unknown
							di as text "Global variable TIMELY_CD_`t'_LABEL_`i' was not set."
							di as text `"Default value will be used: "Timing unknown""' _n							
							vcqi_log_comment $VCP 3 Comment "Global variable TIMELY_CD_`t'_LABEL_`i' was not set. Default value will be used: Timing unknown"
						}

					}
			
					*   TIMELY_CD_<dose in caps>_COLOR_`i' should be defined (and a valid color)
					colorstyle TIMELY_CD_`t'_COLOR_`i'

					* TIMELY_CD_<dose in caps>_LCOLOR_`i' should be defined (and a valid color)
					colorstyle TIMELY_CD_`t'_LCOLOR_`i'

					*   TIMELY_CD_<dose in caps>_LWIDTH_`i' should be defined (and a valid linewidth)
					lwidthstyle TIMELY_CD_`t'_LWIDTH_`i'
					
					*   TIMELY_CD_<dose in caps>_LEGEND_ORDER_`i' should either be missing or be positive integer 
					*	(and should not appear in the list of legend orders that are defined by other values of TIMELY_CD_<dose in caps>_LEGEND_ORDER)
					if "${TIMELY_CD_`t'_LEGEND_ORDER_`i'}" != "" {
						positive_integer_check TIMELY_CD_`t'_LEGEND_ORDER_`i'
						if `positive_integer' == 0 local legend_orders `legend_orders' ${TIMELY_CD_`t'_LEGEND_ORDER_`i'}
					
						*   TIMELY_CD_<dose in caps>_LEGEND_LABEL_`i' should be defined if LEGEND_ORDER_`i' is defined; otherwise it may be defined or not; we don't care
						if "${TIMELY_CD_`t'_LEGEND_LABEL_`i'}" == "" {
							local exitflag 1
							di as error "Global variable TIMELY_CD_`t'_LEGEND_LABEL_`i' should be defined since global variable TIMELY_CD_`t'_LEGEND_ORDER_`i' is populated" _n
							vcqi_log_comment $VCP 1 Error "Global variable TIMELY_CD_`t'_LEGEND_LABEL_`i' should be defined since global variable TIMELY_CD_`t'_LEGEND_ORDER_`i' is populated"
						}
					}
				}
			}	
		}
	}
		
	*
	
	* Check to see if the list of doses in TIMELY_CD_LIST is the same as
	* TIMELY_DOSE_ORDER; if yes, that means the user defined a custom definition
	* for EVERY dose in the list, and we do not need the default definitions, so 
	* skip the TIMELY_DT checks.  But if the lists do not hold exactly the same 
	* doses, then we need the default definition, so:
	if !( "`cdlist'" == "`doseorderlist'" & "`doseorderlist'" != "" ) {
		if "$TIMELY_N_DTS" == "" {
			* If TIMELY_N_DTS is missing suggest user include a line calling globals_for_timeliness_plots do file
			di as text "Global variable TIMELY_N_DTS is not populated. User may want to include the following code in the control program:"
			di as text `""include <path>/globals_for_timeliness_plots.do" BEFORE calling RI_VCTC_01."' _n
			vcqi_log_comment $VCP 2 Warning "Global variable TIMELY_N_DTS is not populated. User may want to include the following code in the control program: include <path>/globals_for_timeliness_plots.do BEFORE calling RI_VCTC_01."
		}
		else {
			* If defined, TIMELY_N_DTS should be a positive integer
			positive_integer_check TIMELY_N_DTS
			if `positive_integer' == 0 {
				* Loop from 1 up to TIMELY_N_DTS  (number of default tiles)
				forvalues i = 1/$TIMELY_N_DTS {

					if `i' != $TIMELY_N_DTS {
						
					*	TIMELY_DT_UB_`i' should be a number that is greater than TIMELY_DT_UB_`=`i'-1'
						capture confirm number ${TIMELY_DT_UB_`i'}
						if _rc != 0 {
							local exitflag 1
							di as error "Global variable TIMELY_DT_UB_`i' is ${TIMELY_DT_UB_`i'}; it should be 0 or a positive number."
							vcqi_log_comment $VCP 1 Error "Global variable TIMELY_DT_UB_`i' is ${TIMELY_DT_UB_`i'}; it should be 0 or a positive number."
						}
						else {
							if ${TIMELY_DT_UB_`i'} < 0 {
								local exitflag 1
								di as error "Global variable TIMELY_DT_UB_`i' is ${TIMELY_DT_UB_`i'}; it should be 0 or a positive number."
								vcqi_log_comment $VCP 1 Error "Global variable TIMELY_DT_UB_`i' is ${TIMELY_DT_UB_`i'}; it should be 0 or a positive number."
							}
						}
						if `i' != 1 {
							capture {
								confirm number ${TIMELY_DT_UB_`i'}
								confirm number ${TIMELY_DT_UB_`=`i'-1'}
							}
							if _rc == 0 {
								if !( ${TIMELY_DT_UB_`i'} > ${TIMELY_DT_UB_`=`i'-1'} ) {
									local exitflag 1
									di as error "Global variable TIMELY_DT_UB_`i' should be greater than global variable TIMELY_DT_UB_`=`i'-1'" _n
									vcqi_log_comment $VCP 1 Error "Global variable TIMELY_DT_UB_`i' should be greater than global variable TIMELY_DT_UB_`=`i'-1'"
								}
							}
							
							*   TIMELY_DT_LABEL_`i' should be defined; if it is not, make it "Received within ${TIMELY_DT_UB_`i'} days of scheduled age"
							if "${TIMELY_DT_LABEL_`i'}" == "" {
								global TIMELY_DT_LABEL_`i' Received within ${TIMELY_DT_UB_`i'} days of scheduled age
								di as text "Global variable TIMELY_DT_LABEL_`i' was not set."
								di as text `"Default value will be used: "Received within ${TIMELY_DT_UB_`i'} days of scheduled age""' _n								
								vcqi_log_comment $VCP 2 Warning "Global variable TIMELY_DT_LABEL_`i' was not set. Default value will be used: Received within ${TIMELY_DT_UB_`i'} days of scheduled age"
							} 
						}
					}
					if `i' == $TIMELY_N_DTS {
						if "${TIMELY_DT_UB_`i'}" != "" {
							local exitflag 1
							di as error "Global variable TIMELY_DT_UB_`i' should not be set as this is for the children whose timing is unknown." _n
							vcqi_log_comment $VCP 1 Error "Global variable TIMELY_DT_UB_`i' should not be set as this is for the children whose timing is unknown."
						}
						
						*   TIMELY_DT_LABEL_`i' should be defined; if it is not, make it "Received within ${TIMELY_DT_UB_`i'} days of scheduled age"
						if "${TIMELY_DT_LABEL_`i'}" == "" {
							global TIMELY_DT_LABEL_`i' Age received is unknown
							di as text "Global variable TIMELY_DT_LABEL_`i' was not set."
							di as text `"Default value will be used: "Age received is unknown""' _n							
							vcqi_log_comment $VCP 2 Warning "Global variable TIMELY_DT_LABEL_`i' was not set. Default value will be used: Age received is unknown"
						} 
					}
					
					*   TIMELY_DT_COLOR_`i' should be defined and a valid color
					colorstyle TIMELY_DT_COLOR_`i'
					
					*   TIMELY_DT_LCOLOR_`i' should be defined and a valid color
					colorstyle TIMELY_DT_LCOLOR_`i'
					
					*   TIMELY_DT_LWIDTH_`i' should be defined and a valid linewidth
					lwidthstyle TIMELY_DT_LWIDTH_`i'
					
					if "${TIMELY_DT_LEGEND_ORDER_`i'}" != "" {
						* Confirm a positive integer if populated
						positive_integer_check TIMELY_DT_LEGEND_ORDER_`i'
						*   [continue to add to your list of legend order values]
						if `positive_integer' == 0 local legend_orders `legend_orders' ${TIMELY_DT_LEGEND_ORDER_`i'}
						
						*   TIMELY_CD_<dose in caps>_LEGEND_LABEL_`i' should be defined if LEGEND_ORDER_`i' is defined; otherwise it may be defined or not; we don't care
						if "${TIMELY_DT_LEGEND_LABEL_`i'}" == "" {
							local exitflag 1
							di as error "Global variable TIMELY_DT_LEGEND_LABEL_`i' should be defined since global variable LEGEND_ORDER_`i' is populated" _n
							vcqi_log_comment $VCP 1 Error "Global variable TIMELY_DT_LEGEND_LABEL_`i' should be defined since global variable LEGEND_ORDER_`i' is populated"
						}
					}
					if "${TIMELY_DT_LEGEND_ORDER_`i'}" == "" {
						local exitflag 1
						di as error "Global variable TIMELY_DT_LEGEND_ORDER_`i' should be defined" _n
						vcqi_log_comment $VCP 1 Error "Global variable TIMELY_DT_LEGEND_ORDER_`i' should be defined"
					}					
				}
			}
		}
	}	
			
	* Next we will look at globals to specify the 'Showed HBR' line.  
	* If TIMELY_HBR_LINE_PLOT is not 1, the user didn't request adding that line, so we do not need to do the following checks
	if "$TIMELY_HBR_LINE_PLOT" == "1" {
		* global TIMELY_HBR_LINE_VARIABLE  should be one of the several variables produced by RI_QUAL_01; make it had_card if it is missing but TIMELY_HBR_LINE_PLOT is 1
		* We need to look at both the card and register values if register was seen
		local checkvars inlist("$TIMELY_HBR_LINE_VARIABLE","had_card", "had_card_with_dates", "had_card_with_dates_or_ticks", "had_card_with_flawless_dates")
		
		if $RI_RECORDS_SOUGHT_FOR_ALL == 1 | $RI_RECORDS_SOUGHT_IF_NO_CARD == 1 ///
		local checkvars `checkvars' | inlist("$TIMELY_HBR_LINE_VARIABLE", "had_register","had_register_with_dates", "had_register_with_dates_or_ticks", "had_register_with_flawless_dates", "had_card_or_register")

		if !(  `checkvars' ) {
			if "$TIMELY_HBR_LINE_VARIABLE" == "" {
				global TIMELY_HBR_LINE_VARIABLE had_card
				di as text `"Global variable TIMELY_HBR_LINE_VARIABLE was not defined. Default value of "had_card" will be used"' _n
				vcqi_log_comment $VCP 2 Warning  `"Global variable TIMELY_HBR_LINE_VARIABLE was not defined. Default value of "had_card" will be used"'
			}
			else {
				local exitflag 1
				di as error "Global variable TIMELY_HBR_LINE_VARIABLE takes the value ${TIMELY_HBR_LINE_VARIABLE}; it should contain the name of one of the variables produced by RI_QUAL_01" _n
				vcqi_log_comment $VCP 1 Error "Global variable TIMELY_HBR_LINE_VARIABLE takes the value ${TIMELY_HBR_LINE_VARIABLE}; it should contain the name of one of the variables produced by RI_QUAL_01"
			}
		}

		*   global TIMELY_HBR_LINE_WIDTH make it medium if not defined
		lwidthstyle  TIMELY_HBR_LINE_WIDTH medium
		
		*   global TIMELY_HBR_LINE_COLOR make it gs8 if not defined
		colorstyle TIMELY_HBR_LINE_COLOR  gs8
		
		*   global TIMELY_HBR_LINE_PATTERN make it 'shortdash' if not defined
		patternstyle TIMELY_HBR_LINE_PATTERN shortdash
		
		* global TIMELY_HBR_LINE_LABEL must be defined
		
		if "$TIMELY_HBR_LINE_LABEL" == "" {
			local exitflag 1
			di as error "Global variable TIMELY_HBR_LINE_LABEL needs to be populated since global variable TIMELY_HBR_LINE_PLOT is 1" _n
			vcqi_log_comment $VCP 1 Error "Global variable TIMELY_HBR_LINE_LABEL needs to be populated since global variable TIMELY_HBR_LINE_PLOT is 1"
		}	
	}	
	
	* Now you've looked at everything that could contribute to legend order:
	* (default tiles, custom doses and the hbr line).  Evaluate the list of order values you have been buliding.  
	*  Confirm the list of orders go from 1 up to the max, with no duplicates and without
	*    skipping a value; if there are duplicates or skips, we'll want to issue an error message.
	local duplicate_ordernumbers : list dups legend_orders
	if "`duplicate_ordernumbers'" != "" {
		local exitflag 1
		di as error "The the LEGEND ORDER global variables contain these duplicates: `duplicate_ordernumbers'; there should be no duplicate values." _n
		vcqi_log_comment $VCP 1 Error "The the LEGEND ORDER global variables contain these duplicates: `duplicate_ordernumbers'; there should be no duplicate values."
	} 
	
	* Find the maximum legend order value
	local olist : subinstr local legend_orders " " ",", all
	local max_order = max(`olist')
	local ordernumberscheck
	forvalues i = 1/`max_order'{
		local ordernumberscheck `ordernumberscheck' `i'
	}
	
	local sorted_ordernumbers : list sort legend_orders
	if  "`sorted_ordernumbers'" != "`ordernumberscheck'" {
		local exitflag 1
		di as error "The LEGEND ORDER global variables currently take values `sorted_ordernumbers', but should contain all values from 1-`max_order'" _n
		vcqi_log_comment $VCP 1 Error "The LEGEND ORDER global variables currently take values `sorted_ordernumbers', but should contain all values from 1-`max_order'."
	} 
	
	* Okay...now you've checked the definitions of the custom and default 
	* timeliness categories and bar characteristics; we'll check some other
	* globals
	
	* Check for TIMELY_YLINE_LIST  It is not required, but if specified it should hold a list of numbers.
	if "$TIMELY_YLINE_LIST" != "" {
		local allnumeric 0
		foreach i in $TIMELY_YLINE_LIST {
			capture confirm number `i'
			if _rc != 0 local allnumeric 1
		}
		if `allnumeric' == 1 {
			local exitflag 1
			di as error "Global variable TIMELY_YLINE_LIST takes value ${TIMELY_YLINE_LIST}; it should hold a list of numbers." _n
			vcqi_log_comment $VCP 1 Error "Global variable TIMELY_YLINE_LIST takes value ${TIMELY_YLINE_LIST}; it should hold a list of numbers."
		}
		else {
			* Check to see if the next two globals are set, if not set to defaults
			colorstyle TIMELY_YLINE_LCOLOR gs14 
			lwidthstyle TIMELY_YLINE_LWIDTH thin
		}
	}
	
	*********************************************

	*Check each of these Global variables.
	* If not defined, use these defaults.
	
	sizestyle TIMELY_XLABEL_SIZE 5pt
	sizestyle TIMELY_YLABEL_SIZE 5pt
	
	colorstyle TIMELY_XLABEL_COLOR black
	colorstyle TIMELY_YLABEL_COLOR black
	colorstyle TIMELY_CI_LCOLOR gs8
	sizestyle  TIMELY_CI_MSIZE small
	
	lwidthstyle TIMELY_CI_LWIDTH thin
	lwidthstyle TIMELY_BARWIDTH 0.5
	
	if "$TIMELY_XSCALE_MAX" == "" {
		global TIMELY_XSCALE_MAX 150
		di as text "Global variable TIMELY_XSCALE_MAX was not defined; VCQI will use the default value: 150" _n
		vcqi_log_comment $VCP 2 Warning "Global variable TIMELY_XSCALE_MAX was not defined; VCQI will use the default value: 150"
	}

	*********************************************
	*
	* Text bar options

	* ORDER is from the top down
	* Check TIMELY_TEXTBAR_ORDER and associated globals if populated
	if "$TIMELY_TEXTBAR_ORDER" != "" {
		* First we want to replace any , with spaces " "
		global TIMELY_TEXTBAR_ORDER = subinstr("$TIMELY_TEXTBAR_ORDER",","," ",.)
		
		local textbar_error 0
		local textbar_valid_list
		* Check to make sure the global only contains valid strings
		foreach t in `=upper("$TIMELY_TEXTBAR_ORDER")' {
			if inlist("`t'","COVG","N","NHBR","NEFF","DEFF","ICC") local textbar_valid_list `textbar_valid_list' `t'
			else local textbar_error 1
		}
		if `textbar_error' ==  1 {
			local exitflag 1
			di as error "Global variable TIMELY_TEXTBAR_ORDER takes value ${TIMELY_TEXTBAR_ORDER}; it should only contain string values from list: COVG N NHBR NEFF DEFF ICC" _n
			vcqi_log_comment $VCP 1 Error "Global variable TIMELY_TEXTBAR_ORDER takes value ${TIMELY_TEXTBAR_ORDER}; it should only contain string values from list: COVG N NHBR NEFF DEFF ICC"
		}
		
		local covg 0
		local icc 0
		local textbar_order
		foreach t in `textbar_valid_list' {
			capture confirm number ${TIMELY_TEXTBAR_X_`t'}
			if _rc != 0 {
				local exitflag 1
				di as error "Global variable TIMELY_TEXTBAR_X_`t' should be a number" _n
				vcqi_log_comment $VCP 1 Error "Global variable TIMELY_TEXTBAR_X_`t' should be a number"
			}
			else {
				local textbar_order `textbar_order' ${TIMELY_TEXTBAR_X_`t'}
				if "${TIMELY_TEXTBAR_LABEL_`t'}" == "" {
					local exitflag 1
					di as error "Global variable TIMELY_TEXTBAR_LABEL_`t' should be populated with a short string " _n
					vcqi_log_comment $VCP 1 Error "Global variable TIMELY_TEXTBAR_LABEL_`t' should be populated with a short string"
				}
			}
			sizestyle TIMELY_TEXTBAR_SIZE_`t' 5pt
			colorstyle TIMELY_TEXTBAR_COLOR_`t' black
			
			if "`t'"== "COVG" local covg 1 
			if "`t'" == "ICC" local icc 1

		}
		
		* If the COVG or ICC TIMELY_TEXTBAR_*_DEC_DIGITS globals are not set, set to default values
		if `covg' == 1 	& "$TIMELY_TEXTBAR_COVG_DEC_DIGITS" == "" 	global TIMELY_TEXTBAR_COVG_DEC_DIGITS 	1
		if `icc' == 1 	& "$TIMELY_TEXTBAR_ICC_DEC_DIGITS" 	== "" 	global TIMELY_TEXTBAR_ICC_DEC_DIGITS 	3
		
		* If the TIMELY_YSCALE_MAX global is not set, set to the max value plus 5
		local textbar_list = subinstr("`textbar_order'"," ",",",.)
		if "$TIMELY_YSCALE_MAX" == "" global TIMELY_YSCALE_MAX = max(`textbar_list') + 5
	}
	
	* Set it to the default value
	else if "$TIMELY_YSCALE_MAX" == "" global TIMELY_YSCALE_MAX 100		
		
	* RI_VCTC_01_LEVELS should include only integers from the set 1 2 3, with no duplicates.
	* If missing, set to 1 3
	local level_error 0
	if "$RI_VCTC_01_LEVELS" == "" global RI_VCTC_01_LEVELS 3
	local level_list $RI_VCTC_01_LEVELS
	local duplicate_levels : list dups level_list
	local note
	if "`duplicate_levels'" != "" {
		local level_error 1
		local note " with no duplicate values."
	}
	foreach g in $RI_VCTC_01_LEVELS {
		capture confirm integer number `g'
		if _rc == 0 {
			if !inlist(`g',1,2,3) local level_error 1
		}
		else local level_error 1
		if `level_error' == 1 {
			local exitflag 1
			di as error "Global variable RI_VCTC_01_LEVELS takes value ${RI_VCTC_01_LEVELS}; should only contain integer values of 1 2 and 3`note'" _n
			vcqi_log_comment $VCP 1 Error "Global variable RI_VCTC_01_LEVELS takes value ${RI_VCTC_01_LEVELS}; it should only contain integers values of 1 2 and 3`note'"
		}
	}
	
	* Now add a few more globals to be used later on in program

	* Number of doses in timeliness plot
	global TIMELY_N_DOSES = wordcount("$TIMELY_DOSE_ORDER")

	global TIMELY_N_CUSTOMIZED_DOSES = wordcount("$TIMELY_N_CUSTOMIZED_DOSES")
	
	if `exitflag' == 1 {
		vcqi_global VCQI_ERROR 1
		vcqi_halt_immediately
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

********************************************************************************
********************************************************************************
********************************************************************************
capture prog drop colorstyle
prog def colorstyle

	args name default

	local global `name'
	local name `=lower("${`global'}")'
	local color_count =wordcount("`name'") 
	local color_error 0

	if "`name'" == "" {
		if "`default'" != "" {
			global `global' `default'
			di as text "Global variable `global' was not defined so default value of `default' will be used." _n
			vcqi_log_comment $VCP 2 Warning "Global variable `global' was not defined so default value of `default' will be used."
		}
		else {
			c_local exitflag 1
			di as error "Global variable `global' should be defined and a valid color option" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' should be defined and a valid color option"
		}
	}
	else {

		* Remove the color intesity
		local end .
		if `=strpos("`name'","*")' > 0 {
			local end = strpos("`name'","*") - 1
			local number = substr("`name'",`=`end'+2',.)
			capture confirm number `number'
			if _rc != 0 local color_error 1
			
			local name = substr("`name'",1,`end')
		}

		if !inlist(`color_count',1,3,4) local color_error 1

		if `color_count' == 3 {
			foreach i in `name' {
				capture confirm integer number `i'
					if _rc == 0 {
						if  !( `i' >= 0 & `i' <= 255) local color_error 1
					}
					else if !( `i' >= 0 & `i' <= 1 )  local color_error 1
			}
		}

		if `color_count' == 4 {
			tokenize `name'
			capture assert "`1'" == "hsv"
			if _rc != 0 local color_error 1
			
			capture confirm integer number `2'
			if _rc == 0 capture assert `2' >= 0 & `2' <= 360 
			if _rc != 0 local color_error 1
			
			forvalues i = 3/4 {
				capture confirm number `i'
				if _rc == 0 capture assert `i' >= 0 & `i' <= 1
				if _rc != 0 local color_error 1
			}
		} 

		if `color_count' == 1 {
			capture findfile color-`name'.style
			if _rc == 601 local color_error 1
		}

		if `color_error'== 1 {
			c_local exitflag 1
			di as error "Global variable `global' currently takes value ${`global'}; it should be a valid color option" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' currently takes value ${`global'}; it should be a valid color option"
		}
	}
end

********************************************************************************
********************************************************************************
********************************************************************************

capt prog drop sizestyle
prog def sizestyle

	args name default

	local global `name'
	local name ${`global'}
	local size_error 0

	if "`name'" == "" {
		if "`default'" != "" {
			global `global' `default'
			di as text "Global variable `global' was not defined so default value of `default' will be used." _n
			vcqi_log_comment $VCP 2 Warning "Global variable `global' was not defined so default value of `default' will be used."
		}
		else {
			c_local exitflag 1
			di as error "Global variable `global' should be defined and a valid size style option" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' should be defined and a valid size style option"
		}
	}
	else {

		* Remove the multiply factor
		if `=strpos("`name'","*")' == 1 local name = substr("`name'",2,.)

		capture confirm number `name'
		if _rc == 0 {
			if `name' < 0  local size_error 1
		}
		else {
			capture findfile gsize-`name'.style
			if _rc == 601 size `name'
		}

		if `size_error' == 1  {
			c_local exitflag 1
			di as error "Global variable `global' currently takes value ${`global'}; it should be a valid size style option" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' currently takes value ${`global'}; it should be a valid size style option"
		}
	}

end

********************************************************************************
********************************************************************************
********************************************************************************

capt prog drop lwidthstyle
prog def lwidthstyle

	args name default

	local global `name'
	local name ${`global'}
	local lwidth_error 0
	local size_error 0
	if "`name'" == "" {
		if "`default'" != "" {
			global `global' `default'
			di as text "Global variable `global' was not defined so default value of `default' will be used." _n
			vcqi_log_comment $VCP 2 Warning "Global variable `global' was not defined so default value of `default' will be used."
		}
		else {
			c_local exitflag 1
			di as error "Global variable `global' should be defined and a valid linewidth style option" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' should be defined and a valid linewidth style option"
		}
	}
	else {

		* Remove the multiply factor
		if `=strpos("`name'","*")' == 1 local name = substr("`name'",2,.)
		
		capture confirm number `name'
		if _rc == 0 {
			if `name' < 0 local lwidth_error  1
		}
		else {
			capture findfile linewidth-`name'.style
			if _rc == 601 size `name'
			if `size_error' == 1 local lwidth_error 1
		}

		if `lwidth_error' == 1  {
			c_local exitflag 1
			di as error "Global variable `global' currently takes value ${`global'}; it should be a valid linewidth style option" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' currently takes value ${`global'}; it should be a valid linewidth style option"
		}
	}
end

********************************************************************************
********************************************************************************
********************************************************************************

capt prog drop anglestyle
prog def anglestyle

	args name default

	local global `name'
	local name ${`global'}
	local angle_error 0
	if "`name'" == "" {
		if "`default'" != "" {
			global `global' `default'
			di as text "Global variable `global' was not defined so default value of `default' will be used." _n
			vcqi_log_comment $VCP 2 Warning "Global variable `global' was not defined so default value of `default' will be used."
		}
		else {
			c_local exitflag 1
			di as error "Global variable `global' should be defined and a valid angle style option" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' should be defined and a valid angle style option"
		}
	}
	else {

		* Angle can have any number value... positive or negative
		capture confirm number `name'
		if _rc != 0 {
			capture findfile anglestyle-`name'.style
			if _rc == 601 local angle_error 1
		}

		if `angle_error' == 1  {
			c_local exitflag 1
			di as error "Global variable `global' currently takes value ${`global'}; it should be a valid angle style" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' currently takes value ${`global'}; it should be a valid angle style"
		}

	}
end

********************************************************************************
********************************************************************************
********************************************************************************

capt prog drop patternstyle
prog def patternstyle

	args name default

	local global `name'
	local name ${`global'}
	if "`name'" == "" {
		if "`default'" != "" {
			global `global' `default'
			di as text "Global variable `global' was not defined so default value of `default' will be used." _n
			vcqi_log_comment $VCP 2 Warning "Global variable `global' was not defined so default value of `default' will be used."
		}
		else {
			c_local exitflag 1
			di as error "Global variable `global' currently takes value ${`global'}; it should be defined and a valid line pattern style option" _n
			vcqi_log_comment $VCP 1 Error "Global variable `global' currently takes value ${`global'}; it should be defined and a valid line pattern style option"
		}
	}
	else {

		* Pattern can have a specific string value or formula of characters
		capture findfile linepattern-`name'.style
		if _rc == 601 {
			* We want to check to see if they added a "formula"
			* We must check for the values of "l _  -  .  and #"
			local formula `name'
			foreach p in l _ - . # {
				local formula = subinstr("`formula'","`p'","",.)
			}
			if "`formula'" != "" {
				c_local exitflag 1
				di as error "Global variable `global' currently takes value ${`global'}; it should be a valid line pattern style option" _n
				vcqi_log_comment $VCP 1 Error "Global variable `global' currently takes value ${`global'}; it should be a valid line pattern style option"
			}
		}
	}
end

********************************************************************************
********************************************************************************
********************************************************************************
capt prog drop size
prog def size

	args size

	local in inches
	local pt points
	local cm cms
	local rs relative
	local len = strlen("`size'")
	local len_end1 = `len' - 2
	local len_start2 = `len_end1' + 1

	local 1 = substr("`size'",1, `len_end1')
	local 2 = substr("`size'",`len_start2',.)

	capture confirm number `1'
	if _rc != 0 c_local size_error 1

	capture findfile sizetype-``2''.style
	if _rc != 0 c_local size_error 1

end

********************************************************************************
********************************************************************************
********************************************************************************
capt prog drop positive_integer_check
prog def positive_integer_check

	args name 

	local global `name'
	local value ${`global'}

	c_local positive_integer 0

	capture confirm integer number `value'
	if _rc != 0 | `value' < 0 {
		local exitflag 1
		c_local positive_integer 1
		di as error "Global variable `global' currently takes value ${`global'}; it should be missing or a positive integer" _n
		vcqi_log_comment $VCP 1 Error "Global variable `global' currently takes value ${`global'}; it should be missing or a positive integer"
	}

end
