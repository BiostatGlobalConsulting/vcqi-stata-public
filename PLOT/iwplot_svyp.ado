*! iwplot_svyp version 1.26 - Biostat Global Consulting - 2021-01-13
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*-------------------------------------------------------------------------------
* 2015			0.9		Dale Rhoda		Draft version

* 2015			1.0		Yulia Fungard	Polished version with new options

* 2015-12-21	1.01	MK Trimner		added starting comment and VCP globals
*                                       global VCP iwplot_svyp
*                                       
*                                       vcqi_log_comment $VCP 5 Flow "Starting"
*
* 2016-01-12	1.10	D. Rhoda		Reworked the calculation of heights
*										of distribution rectangles & introduced
*         								option to base equal area calculation
*										on either the stairstep polygons or
* 										smooth bounding polygons 
*										(user options equalarea and polygon)
*										see accompanying documentation for 
*										details; the defaults are probably fine
*
*										Introduced option for user to specify
*										a variable named 'rownumber' in the
*										input data...this allows the user to
*										put multiple distributions on the same
*										horizontal row of the plot; be sure
*										to specify only a single value (or the
* 										same value) for rowname and shadebehind
* 										for every distribution on the same row
*
*										Also expanded options for control of
* 										distribution outline and area - the 
* 										inputdata can now include not only
*										outlinecolor and areacolor but also
*										outlinewidth, outlinepattern, 
*										outlinestyle, and areaintensity
*
*										It is fine to leave any of those blank;
* 										by default distributions use no fill
*										and only a thin black outline
*
*										Incorporated Yulia's recent code to 
*										clarify comments, add markvaluecolor
*
*										Introduced code to check variables in
* 										the dataset; re-type them if necessary
*										and establish defaults (for most)
*
*										For consistency, removed showlcb and 
*                                       showucb; if lcb has a numeric value, the
* 										tickmark will appear; otherwise not;
*										same for ucb; same for clip; same for
*										shadebehind...the user doesn't need to
*										specify yes/no variables for these 
*										plotting options...just specify 
*										the variable and its values, and the 
*										code will show them in the plot
*										
*	2016-01-13	1.11	D. Rhoda		Changed the inappropriate word 
*										'convex' to 'smooth'		
*	2016-02-12	1.12	D. Rhoda		Edited block of code that decides
*										whether to save or drop temporary
*										datasets							
*
* 	2016-02-24	1.13	Dale Rhoda		Only set VCP and call vcqi_log_comment
*										or vcqi_halt_immediately
*          								if VCQI is running; allows the user
*										to call the program from outside VCQI
*
*   2016-03-10	1.14	Dale Rhoda		Removed most di statements
*
*	2016-03-12	1.15	Dale Rhoda		set obs 2 if there's only one shape to 
*										plot; this parallels a bug fix in 
*										uwplot
*
*	2016-04-06	1.16	Y. Fungard		Added option to put text boxes on a plot							
*                                       Added option to customize text at right
*                                       Added option for custom arrows 
*
*	2016-04-25	1.17	Dale Rhoda		Added round() function when using ESS
*  										to calculate boundary coordinates
*
* 	2016-06-06	1.18	Dale Rhoda		Substantial improvements to 
*										set defaults for variables that are
*										not required inputs in the lines, text,
* 										and arrows datasets.
*
*										Facilitated passing in xaxisrange and 
*										having rightsidetext plot at max+5
*
*										Made 'polygon' a characteristic of the
*										distribution, not the plot, so we can
*										specify different values within a single
*										plot
*
*	2016-09-15	1.19	Dale Rhoda		Added caption option
*
* 	2016-10-26	1.20	Dale Rhoda		Call new svyp routines for faster 
*										results and to allow non-integer 
*										values of ESS
*
*  	2017-06-14	1.21	Dale Rhoda		Introduced macro named
*										multiple_shapes_on_some_rows to more
*										easily track when the user has
*										requested that and to take appropriate
*										measures with citext and with row
*										label and text at right
*
*	2017-08-21	1.22	Dale Rhoda		Put the shaded rows BEHIND vertical 
*										and horizontal lines and stripped
*										.0 from 100.0 in cistring
*										
* 2017-08-26	1.23	Mary Prier		Added version 14.1 line
*
* 2019-10-10  	1.24  	Dale Rhoda  	Allow flexible number of decimal places and
*                               		allow the user to request bars instead of
*										inchworm distributions via the 
*                               		$IWPLOT_SHOWBARS global macro (0 for 
*										inchworms and 1 for bars)
*
* 2019-10-17	1.25	Dale Rhoda		Set default decimal digits to 1
*
* 2021-01-13	1.26	Dale Rhoda		Rearrange interval orders in cistring5

*********************************************************************************
* All datasets which are called into this program should be stored in 
* the working directory; the plot will also be saved in the working directory
*********************************************************************************
*
* Required option: 
*
* INPUTDATA -- name of input dataset 
*
* Variables:
*	source (string)        -- either ESS or DATASET; this may vary by row
*   param1 (numerical)     -- If source is ESS, this holds the effective sample size (ESS)
*							  (Note that ESS does NOT need to be an integer.)
*   param2 (numerical)     -- If source is ESS, this holds the estimated survey proportion p (1-100)
*   param3 (string)        -- For either ESS or DATASET, this parameter holds the name of
*                           the method to use for estimating confidence intervals;
*                           Any value accepted by the svyp program is allowable here.
*                           Options currently include Clopper, Wilson, Logit or Jeffreys.
*
*							Note that if the sample proportion is 0% or 100% then
*							the Logit and the Wilson options default to using a
*							Clopper-Pearson interval.
*
*	param4 (string)        -- If source is DATASET, this param holds the path and name
*                            of the survey dataset to be used to estimate the proportion
*	param5 (string)        -- If source is DATASET, this holds the name of the variable
*                            whose proportion is being estimated
*	param6 (string)        -- If source is DATASET, this holds the svyset command to be 
*                            issued before estimating the proportion
*	param7 (string)        -- If source is DATASET, this holds the Stata 'if' syntax to
*                            restrict the estimation to the subpopulation of interest
*   rowname (string)       -- row labels which will be displayed on left side of the plot
*								Be sure not to list conflicting rownames if you
*                               put more than one distribution on a row; the
*                               program sorts the dataset by rownumber and only
*								pays attention to the last rowname defined for
*          						each rownumber
*	rownumber (numerical)	-- row number (y-coordinate) the distribution is centered on 
*                              (_n by default...note that row 1 is the bottom row)

*   outlinecolor (string) 	-- valid Stata color (black by default)
*	outlinewidth (string)	-- valid Stata line width (vvthin by default)
*	outlinepattern (string)	-- valid Stata line pattern (solid by default)
*   outlinestyle (string)	-- valid Stata line style (foreground by default)
*   areacolor (string)		-- valid Stata color (none, by default)
*	areaintensity (numerical)	-- valid Stata intensity (0-100) (100 by default)
*								   intensity can also be controled using
*                                  a multiplier in areacolor (e.g.,
*                                  areacolor = red*.5 would yield the same
*                                  results as areacolor = red and intensity = 50
*   markvalue (numerical)  -- percentile at which to show a vertical tick for reference
*                             It should be left blank if no vertical tick is needed
*   markvaluecolor(string) -- valid Stata color
*   clip(numerical)        -- width of the CI at which to clip the graphic distribution 
*                             This value has to be either missing or betwen 0.01 and 99.9 (usually 95)
*   lcb(numerical)   	   -- what % of confidence should fall above the LCB? (usually 95)
*                             This value should either be either missing or in range 51 - 99.9.
*							  If it is missing, the lcb tick will not appear.
*   lcbcolor (string)      -- valid Stata color
*   ucb(numerical)   	   -- what % of confidence should fall below the UCB? (usually 95)
*                             This value should either be either missing or in range 51 - 99.9
*							  If it is missing, the ucb tick will not appear.
*   ucbcolor (string)      -- valid Stata color
*   rightsidetext (string) -- custom text to put on the right hand side instead if CI text
*   shadebehind (string)   -- if this is not missing it should be a valid Stata color;
*                             if not missing, there will be a shaded line behind the
*                             row, to draw the eye to this row...often used to hightlight
*                             the national level results;
*                             if it is missing, the plot will not have a shaded line 
*                             behind the distribution
*							  Note that caution is needed if you put more than one 
*                             distribution on a row; if any of the distributions
*                             specify a shadebehind color, then the row will 
*                             be shaded; the program sorts the dataset by 
*                             rownumber and uses the last shadebehind color
*                             listed per row;
*   polygon(numerical) 	   -- 1 means the plots will show only the stair-step polygons -
*              				    this is mostly a debug option
*            				  2 means the plots will show smooth bounding polygons (default)
*            				  3 means the plots will show BOTH the stairstep and smooth 
*              					bounding polygons (when the user specifies 3 *and* an
*								areacolor, the color will only appear inside
*								the stairsteps...not between the steps and
* 								bounding polygon
*
* Optional:
*
* NL number of points at which to calculate the shape of the top of each distribution
*
* XTITLE title for X axis
* YTITLE title for Y axis
* TITLE title at the top of the plot
* SUBTITLE subtitle at the top of the plot
* NOTE note at the bottom of the plot
*
* XAXISRANGE numerical range (min max) for X axis if left blank then program will create a range based on 
*            minimum and maximum values of X
* XAXISLABEL numerical labels for X axis
*            Both xaxisrange and XAXISLABEL control the length of X axis. 
*            See Nicholas J. G. Winter (2005) "Stata tip 23: Regaining control over axis ranges"
*
* VERLINESDATA dataset to describe vertical lines 
*             (required variables: xcoord, ystart, ystop, color, width, style)
*             if ystart and ystop are missing then a vertical line across whole chart is drawn
*             it is possible to specify as many as needed vertical lines
*
* HORLINESDATA dataset to describe horizontal lines 
*              (required variables: ycoord, xstart, xstop, color, width, style)
*              if xstart and xstop are missing then a horizontal line across whole chart is drawn
*              it is possible to specify as many as needed horizontal lines
*
* TEXTONPLOTDATA dataset to describe text on plot 
*                (required variables: textonplot, xcoordtext, ycoordtext, colortext, fontsizetext)
*                it is possible to specify as many as needed text boxes;
*           	 we could add additional textbox attributes in the future
*
* ARROWSDATA    dataset to describe arrows on plot 
*                (required variables: xcoordend, ycoordend, xcoordtip, ycoordtip, arrowcolor, arrowwidth)
*                it is possible to specify as many arrows as needed ;
*                we could add additional arrow attributes in the future
*
* CITEXT takes values 1, 2, 3, 4 or 5
*             1) one-sided 95% LCB, p, one-sided 95% UCB
*             2) p (95%CI)
*             3) p (95%CI) (0, 1-sided 95% UCB]
*             4) p (95%CI) [1-sided 95% LCB, 100)
*             5) p (95%CI) [1-sided 95% LCB, 100) (0, 1-sided 95% UCB]
*
*			  NOTE.  IF the user puts more than one distribution on any row of
*             the plot (two distributions have the same rownum) then CITEXT 
*             will be turned off, no matter what the user asks for; if you
*             show more than one distribution per row, this program doesn't
* 			  know which one to summarize, so it doesn't summarize any at all
*             
*             NOTE. If the user specifies rightsidetext variable in the input dataset
*             then for that particular row citext will be overwritten with the user's text
*             from rightsidetext field
*
* EQUALAREA  1 means distributions will not be re-scaled; their coordinates
*              will be set up so they are equal-area under the so-called
*              stair-step polygon, which does not take triangles into
*              account, and is not constrained to be a strictly-increasing polygon
*            2 means distributions will be scaled to be equal-area under the
*              so-called smooth bounding polygons (the ones that include 
*              triangles and are constrained to not decrease in h)  
* 			   2 is the default
*
* NAME		 gives the Stata graph a name in the window title bar
*
* SAVING name of gph file to be save in working directory, this image can be edited 
*           later at any time in graph editor or using the addplot command   
*
* EXPORT name and suffix of the plot to be saved in working directory. If this option left blank
*             then plot will be saved as only a gph image 
*             (ex. graph1.png or graphBA_12.pdf)
*             possible suffixes: ps (PostScript), eps(Encapsulated PostScript),
*             wmf (Windows Metafile), emf (Windows Enhanced Metafile), pdf (PDF)
*             png (Portable Network Graphics), tif (TIFF)
* CLEANWORK  blank - default, all datasets created by the program will be saved in working directory
*            yes - all datasets created by the program will be deleted from working directory, it should 
*                  keep working directory clean, recommended option
********************************************************************************

program define iwplot_svyp
	version 14.1
	
	syntax, 					///
		INPUTdata(string) [		///
		NL(integer 50) 			///
		XTITLE(string) 			///
		YTITLE(string) 			///
		TITLE(string asis)		///
		SUBtitle(string asis) 	///
		NOTE(string asis) 		///
		CAPTION(string asis)	///
		XAXISDESIGN(integer 1)	///
		XAXISRANGE(numlist) 	///
		XSIZE(numlist >0 <=20 min=1 max=1) 	///
		YSIZE(numlist >0 <=20 min=1 max=1)  ///
		VERlinesdata(string)	///
		HORlinesdata(string) 	///
		TEXTONPLOTdata(string) 	///
		ARROWSdata(string) 	    ///
		CItext(integer 0) 		///
		CITEXTLEFTMARGIN(numlist >=0 min=1 max=1) ///
		EQUALarea(integer 2)	///
		SAVING(string asis) 	///
		NAME(string asis) 		///
		EXPORT(string asis)  	///
		CLEANwork(string)		///
		TWOway(string asis) ]
	
	* write an entry in the log file if we are running VCQI
	if "$VCQI_LOGOPEN" == "1" {
		local oldvcp $VCP
		global VCP iwplot_svyp
		vcqi_log_comment $VCP 5 Flow "Starting"
	}
	
	local q quietly
	if "$VCQI_DEBUG" == "1" local q noisily
	
	`q' {
	
		if "$VCQI_NUM_DECIMAL_DIGITS" == "" global VCQI_NUM_DECIMAL_DIGITS 1
	
		* read in input data with distribution parameters	
		use `inputdata', clear
		
		capture confirm variable source
		if _rc != 0 {
			di as error "iwplot_svyp input dataset `inputdata' should contain"
			di as error "a variable named source"
			if "$VCQI_LOGOPEN" == "1" vcqi_halt_immediately
			else exit 99
		}
		
		replace source = upper(source)
		capture assert inlist(source,"ESS","DATASET")
		if _rc != 0 {
			di as error "iwplot_svyp input dataset `inputdata' variable source"
			di as error "has an invalid value; should be only ESS or DATASET"
			if "$VCQI_LOGOPEN" == "1" vcqi_halt_immediately
			else exit 99
		}
		
		* If any rows have source set to ESS, then param1-param2 are required
		count if source == "ESS"
		if r(N) > 0 {
			capture confirm variable param1
			local rc1 = _rc
			if _rc != 0 di as error "iwplot_svyp input source is sometimes set to ESS but param1 does not exist"
			capture confirm variable param2
			local rc2 = _rc
			if _rc != 0 di as error "iwplot_svyp input source is sometimes set to ESS but param2 does not exist"
			if `rc1' != 0 | `rc2' != 0 {
				if "$VCQI_LOGOPEN" == "1" vcqi_halt_immediately
				else exit 99
			}
		}
		
		* If any rows have source set to DATASET, then param4-param7 are required
		count if source == "DATASET"
		if r(N) > 0 {
			forvalues i = 4/7 {
				capture confirm variable param`i'
				local rc`i' = _rc
				if _rc != 0 di as error "iwplot_svyp input source is sometimes set to ESS but param`i' does not exist"
			}
			if `rc4' != 0 | `rc5' != 0 | `rc6' != 0 | `rc7' != 0 {
				if "$VCQI_LOGOPEN" == "1" vcqi_halt_immediately
				else exit 99
			}
		}
		
		* gen param3 if it is missing; default to LOGIT
		capture gen param3 = "LOGIT"
		
		if !inlist(`equalarea',1,2) {
			di as error "iwplot_svyp requires the input option equalarea to be 1 or 2"
			if "$VCQI_LOGOPEN" == "1" vcqi_halt_immediately
			else exit 99
		}
		
		* polygon must be 1 or 2 or 3
		* Its default is 2; generate if necessary
		* and fill in the default if any values are missing
		
		capture gen polygon = 2
		destring polygon, replace 
		replace polygon     = 2 if missing(polygon)
		
		if !inlist(polygon,1,2,3) {
			di as error "iwplot_svyp requires the input option polygon to be 1 or 2 or 3"
			if "$VCQI_LOGOPEN" == "1" vcqi_halt_immediately
			else exit 99
		}
		
		* xaxisdesign must be 1 or 2 or 3
		
		if !inlist(`xaxisdesign',1,2,3) {
			di as error 'iwplot_svyp requires the xaxisdesign option to be 1 or 2 or 3; you specified `xaxisdesign'."
			if "$VCQI_LOGOPEN" == "1" vcqi_halt_immediately
			else exit 99
		}	
		
		* if user requests control over x-axis but does not specify range, 
		* then revert to option 2 where x-axis is determined by data limits
		
		if `xaxisdesign' == 3 & "`xaxisrange'" == "" local xaxisdesign 2
		
		* default row for distributions
		* if not specified, defaults to _n
		* if the variable is provided but the value is missing, drop the row
		
		capture gen rownumber = _n
		drop if missing(rownumber)
		
		* default outline for distributions
		
		capture gen outlinecolor = "black"
		replace outlinecolor="black" if missing(outlinecolor)
		
		capture gen outlinewidth = "vvthin"
		replace outlinewidth = "vvthin" if missing(outlinewidth)
		
		capture gen outlinepattern = "solid"
		replace outlinepattern = "solid" if missing(outlinepattern)
		
		capture gen outlinestyle = "foreground"
		replace outlinestyle = "foreground" if missing(outlinestyle)
		
		* default fill for distributions
		
		capture gen areacolor = "none"
		replace areacolor = "none" if missing(areacolor)
		
		capture gen areaintensity = 100
		replace areaintensity = 100 if missing(areaintensity)
		
		* default lcb
		capture gen lcb = .
		destring lcb, replace force
		
		capture gen lcbcolor = "none"
		tostring lcbcolor, replace force
		replace lcbcolor = "gs8" if missing(lcbcolor)

		* default ucb
		capture gen ucb = .
		destring ucb, replace force
		
		capture gen ucbcolor = "none"
		tostring ucbcolor, replace force
		replace ucbcolor = "gs8" if missing(ucbcolor)

		* default clip
		capture gen clip = .
		destring clip, replace force
		
		* default markvalue
		capture gen markvalue = .
		destring markvalue, replace force
		
		capture gen markvaluecolor = "none"
		tostring markvaluecolor, replace force
		replace markvaluecolor = "none" if missing(markvaluecolor)
		
		* default rowname
		capture gen rowname = _n
		tostring rowname, replace force
		
		* default rightsidetext
		capture gen rightsidetext = ""
		tostring rightsidetext, replace force
		
		* default shadebehind
		capture gen shadebehind = ""
		tostring shadebehind, replace force
		
		local bign = _N
		
		* If there is more than one distribution on at least one row
		* then only keep the last value specified per row for 
		* shadebehind and rightsidetext
		
		summarize rownumber
		local nplotrows = r(max)
		
		gen sortorder = _n
		local multiple_shapes_on_some_rows 0
		bysort rownumber: gen nperrow = _N
		summarize nperrow
		if r(max) > 1 local multiple_shapes_on_some_rows 1
		sort sortorder
		drop nperrow sortorder
		
		if `multiple_shapes_on_some_rows' {
		
			forvalues i = 1/`nplotrows' {
				local lastsb
				local lasttr	
			
				forvalues j = 1/`bign' {	
					if rownumber[`j'] == `i' {
						if !missing(shadebehind[`j'])   local lastsb = shadebehind[`j']
						if !missing(rightsidetext[`j']) local lasttr = rightsidetext[`j']
						if !missing(rowname[`j'])       local lastrn = rowname[`j']
					}
				}
				
				replace shadebehind   = "`lastsb'" if rownumber == `i'
				replace rightsidetext = "`lasttr'" if rownumber == `i'
				replace rowname       = "`lastrn'" if rownumber == `i'
			}
		}		
		
		forvalues i = 1/`bign' {
			
			local source`i' = upper(source[`i'])
			if "`source`i''" == "ESS" {
				local effss`i'       = param1[`i']
				local p`i'           = param2[`i']
				local method`i'      = lower(param3[`i'])
			}
			if "`source`i''" == "DATASET" {
				local method`i' 	= param3[`i']
				local dataset`i' 	= param4[`i']
				local variable`i' 	= param5[`i']
				local svyset`i'	 	= param6[`i']
				local if`i' 		= param7[`i']
			}
			
			local rownumber`i'      = rownumber[`i']
			local areacolor`i'      = lower(areacolor[`i'])
			if wordcount("`areacolor`i''") == 3 local areacolor`i' = "`areacolor`i''"
			local areaintensity`i'  = int(areaintensity[`i'])
			
			local outlinecolor`i'   = lower(outlinecolor[`i'])
			local outlinewidth`i'   = lower(outlinewidth[`i'])
			local outlinepattern`i' = lower(outlinepattern[`i'])
			local outlinestyle`i'   = lower(outlinestyle[`i'])
			
			if shadebehind[`i'] != "" & shadebehind[`i'] != "." local shadebehind`rownumber`i''    = lower(shadebehind[`i'])
			
			local rightsidetext`i'  = rightsidetext[`i']
			
			local polygon`i' 		= polygon[`i']
			
			* plot one-sided lower confidence bound
			* change to alpha/2 to plot  
			
			local lcb`i'		 = 2*lcb[`i']-100
			local lcbcolor`i'    = lower(lcbcolor[`i'])
			if lcb[`i'] < 50 local lcb`i' = 50
			
			* plot one-sided upper confidence bound
			* change to alpha/2 to plot 	   
			
			local ucb`i'         = 2*ucb[`i']-100
			local ucbcolor`i'    = lower(ucbcolor[`i'])
			if ucb[`i'] < 50 local ucb`i' = 50
			
			local clip`i'        = clip[`i']
			
			* plot a vertical line at specific percentile
			* of the confidence distribution
			local markvalue`i'   = markvalue[`i']
			local markvaluecolor`i' = markvaluecolor[`i']
										 
			* label each row in the plot               
			local rowname`rownumber`i''  = rowname[`i']

		}
						
		* If the user has specified the names of horizontal or vertical reference
		* line datasets or arrows or textonplot, then put their properties 
		* into local macros

		if "`verlinesdata'"!="" {	
			use `verlinesdata', clear
			
			capture confirm variable xcoord
			if _rc != 0 local verlinesdata
			else {
				
				* these 6 variables are not required; 
				* gen them if not specified 
				* populate with defaults
				* fill in missing values
				
				capture gen ystart = .
				destring ystart, replace force
				
				capture gen ystop = .
				destring ystop, replace force
				
				capture gen color = "black"
				tostring color, replace force
				replace color = "black" if missing(color)
				
				capture gen width = "medium"
				tostring width, replace force
				capture confirm variable thickness
				if _rc == 0 replace width = thickness if !missing(thickness)
				replace width = "medium" if missing(width)
				
				capture gen style = "foreground"
				tostring style, replace force
				replace style     = "foreground" if missing(style)
				
				capture gen pattern = "solid"
				tostring pattern, replace force
				replace pattern = "solid" if missing(pattern)
				
				local bigxl				=_N
				
				forvalues i = 1/`bigxl' {
					local xcoord`i'		= xcoord[`i']
					local ystart`i'		= ystart[`i']
					local ystop`i'		= ystop[`i']
					local colorxl`i'	= color[`i']
					local widthxl`i'	= width[`i']
					local stylexl`i'	= style[`i']
					local patternxl`i'	= pattern[`i']
				}
			}
		}

		if "`horlinesdata'"!="" {	
			use `horlinesdata', clear
			
			capture confirm variable ycoord
			if _rc != 0 local horlinesdata
			else {
					
				* these 6 variables are not required; 
				* gen them if not specified 
				* populate with defaults
				* fill in missing values
				
				capture gen xstart = .
				destring xstart, replace force
				
				capture gen xstop = .
				destring xstop, replace force
				
				capture gen color = "black"
				tostring color, replace force
				replace color = "black" if missing(color)
				
				capture gen width = "medium"
				tostring width, replace force
				capture confirm variable thickness
				if _rc == 0 replace width = thickness if !missing(thickness)
				replace width = "medium" if missing(width)
				
				capture gen style = "foreground"
				tostring style, replace force
				replace style     = "foreground" if missing(style)
				
				capture gen pattern = "solid"
				tostring pattern, replace force
				replace pattern = "solid" if missing(pattern)
						
				local bigyl				=_N

				forvalues i = 1/`bigyl' {
					local ycoord`i'		= ycoord[`i']
					local xstart`i'		= xstart[`i']
					local xstop`i'		= xstop[`i']
					local coloryl`i'	= color[`i']
					local widthyl`i'	= width[`i']
					local styleyl`i'	= style[`i']
					local patternyl`i'	= pattern[`i']
				}
			}
		}

		if "`textonplotdata'"!="" {	
			use `textonplotdata', clear
			
			* Check 3 required variables
			capture confirm variable textonplot
			local rc1 = _rc
			capture confirm variable xcoordtext
			local rc2 = _rc
			capture confirm variable ycoordtext
			local rc3 = _rc
			
			* Ignore the dataset if any required variables are missing
			if `rc1' != 0 | `rc2' != 0 | `rc3' != 0 local textonplotdata
			else {	
			

				* These three variables are not required; 
				* generate them if necessary; make sure they 
				* are strings if the user specified them, and
				* fill in default values if any are missing
				capture gen colortext    = "black"
				tostring colortext, replace force
				replace colortext        = "black" if missing(colortext)
				
				capture gen fontsizetext = "*1"
				tostring fontsizetext, replace force
				replace fontsizetext     = "*1" if missing(fontsizetext)
				
				capture gen orientation   = "horizontal"
				tostring orientation, replace force
				replace orientation       = "horizontal" if missing(orientation)
				
				local textonplotlines       = _N

				forvalues i = 1/`textonplotlines' {
				
					local textonplot`i'		= textonplot[`i']
					local xcoordtext`i'		= xcoordtext[`i']
					local ycoordtext`i'		= ycoordtext[`i']
					local colortext`i'	    = colortext[`i']
					local fontsizetext`i'	= fontsizetext[`i']
					local textorient`i'		= orientation[`i']
				}
			}
		}
			  
		if "`arrowsdata'"!="" {	
			use `arrowsdata', clear
			
			capture confirm variable ycoordtip
			local rc1 = _rc
			capture confirm variable xcoordtip
			local rc2 = _rc
			capture confirm variable ycoordend
			local rc3 = _rc
			capture confirm variable xcoordend
			local rc4 = _rc
			
			* Ignore the dataset if any required variables are missing
			if `rc1' != 0 | `rc2' != 0 | `rc3' != 0 | `rc4' != 0 local arrowsdata
			else {	
			
				* These two variables are not required
				* Generate them if necessary
				* Fill in default values if necessary
				
				capture gen arrowcolor = "black"
				tostring arrowcolor, force replace
				replace arrowcolor = "black" if missing(arrowcolor)
				
				capture gen arrowwidth = "*1"
				tostring arrowwidth, force replace
				replace  arrowwidth = "*1" if missing(arrowwidth)
			
				local arrowsl			=_N

				forvalues i = 1/`arrowsl' {
					local ycoordtip`i'		= ycoordtip[`i']
					local xcoordtip`i'		= xcoordtip[`i']
					local ycoordend`i'		= ycoordend[`i']
					local xcoordend`i'		= xcoordend[`i']
					local arrowcolor`i'	    = arrowcolor[`i']
					local arrowwidth`i' 	= arrowwidth[`i']
				}
			}
		}

		**** clear all matrices 
		set matsize 800 
		clear matrix 

		* Set up matrices to hold info regarding the distributions
		* The matrix named 'table' will hold some high-level summary information
		* about the distribution: estimated prevalence, effective sample size,
		* lb and ub of 95% CI, lb and ub of 90% CI, the lower and upper 
		* bounds to be shown with tick marks, the point that the user wishes
		* to mark, and and the lb and ub where the distribution will be clipped

		local tcols p effss lb_95pct ub_95pct lb_90pct ub_90pct lcbpct ucbpct mvpct cliplb clipub
		local ntcols: word count `tcols'

		capture matrix drop table
		matrix table = J(`bign',`ntcols',.)
		matrix colnames table = `tcols'

		* Set up matrices to hold info about the polygons that outline
		* the confidence distributions: 
		*  l and u hold the lower and upper bounds of several (nl) CIs
		*  a holds the area or level of the CIs
		*  h holds the height coordinate for each rectangle 

		foreach l in a l u h {
			forvalues i = 1/`nl' {
				local `l'cols ``l'cols' `l'`i'
			}
		}
		
		foreach l in a l u h {
			capture matrix drop `l'vals
			matrix `l'vals = J(`bign',`nl',.)
			matrix colnames `l'vals = ``l'cols'
		}

		* set up matrices to hold x and y bounds of 
		* stairstep (ss) and smooth bounding (sb)
		* polygons

		forvalues i = 1/`=4*`nl'' {
			local ssxcols `ssxcols' ssx`i' 
			local ssycols `ssycols' ssy`i'
		}
		
		forvalues i = 1/`=2*(`nl'+1)' {
			local sbxcols `sbxcols' sbx`i'
			local sbycols `sbycols' sby`i'
		}
				
		foreach l in x y {
			capture matrix drop `l'vals
			matrix ss`l'vals = J(`bign',`=4*`nl'',.)
			matrix colnames ss`l'vals = `ss`l'cols'
			
			matrix sb`l'vals = J(`bign',`=2*(`nl'+1)',.)
			matrix colnames sb`l'vals = `sb`l'cols'
		}					

		* The coordinates of the outlines of the distributions are calculated by
		* calling svyp over and over, starting with a very narrow confidence level
		* and growing and growing all the way out to a 99.99 % CI.  The number of
		* CIs used to outline the distribution is nl.  And the precise confidence
		* limits for each call to svyp are spaced evenly from a 0.01% CI out to
		* a 99.99% CI.  Calculate those levels here and store them in local
		* macros.
		

		if "${CILEVELLIST_`nl'}" == "" {
			local llist 
			forvalues i = 1/`nl' {
				local lvl`i' = 0.01 + (`=(`i'-1)*((99.99-0.01)/(`=`nl'-1'))')
				local llist `llist' `=substr("`lvl`i''",1,5)'
			}
			global CILEVELLIST_`nl' = "`llist'"
			local llist
		}

		forvalues i = 1/`bign' {
		
			noisily di as text "Calculating outline for distribution # `i': `rowname`rownumber`i'''"
			***************************************************************	
			
			* Data for this distribution will be simulated using 
			* an effective sample size and estimated coverage

			if "`source`i''" == "ESS" {
				local call_svyp qui svyp_ci_calc, p(`=`p`i''/100') stderr(`=sqrt(((`p`i''/100)*(1-(`p`i''/100)))/`effss`i'')') n(`effss`i'') method(`method`i'') 
				* Note that we do not 'adjust' when source is ESS because we do not typically know the dof...and those are needed for the function of ESS by level
			}

			
			* Data for this distribution come from a dataset
			if "`source`i''" == "DATASET" {
				use "`dataset`i''", clear
				local y `variable`i''
				quietly `svyset`i''
				local ifi `if`i''
				
				qui count `ifi'
				if r(N) == 0 continue
				local call_svyp qui svypd `y' `ifi', method(`method`i'') adjust truncate 
				
			}
			
			`call_svyp' level(95)
			
			matrix table[`i', 1] = r(svyp)*100  
			matrix table[`i', 2] = r(N)   
			matrix table[`i', 3] = r(lb_alpha)*100
			matrix table[`i', 4] = r(ub_alpha)*100
			matrix table[`i', 5] = r(lb_2alpha)*100
			matrix table[`i', 6] = r(ub_2alpha)*100
			
			if "`lcb`i''" != "" & "`lcb`i''" != "." {
				if `lcb`i'' >= 50 {
					`call_svyp' level(`lcb`i'') 
					matrix table[`i', 7] = r(lb_alpha)*100
				}
			}
				
			if "`ucb`i''" != "" & "`ucb`i''" != "." {
				if `ucb`i'' >= 50 {
					`call_svyp' level(`ucb`i'')  
					matrix table[`i', 8] = r(ub_alpha)*100
				}
			}
			
			* The markvalue is a percentile; values between 0.01 and 99.99 
			* are acceptable...the x-coordinate is calculated here and stored
			* in the table matrix for later display
			
			if `markvalue`i''!=. {
			
				local mv = `markvalue`i''
				
				* if the user has requested the 50th percentile it is the survey estimate
				if `mv' == 50 {
					matrix table[`i', 9] = table[`i', 1]
				}
				
				* if user has requested one below 50, 
				* it is the lower limit of a 2*(100-mv)-100% confidence interval
				if `mv' >= 0.01 & `mv' < 50 {
					local mvlvl = 2*(100-`mv')-100
					`call_svyp' level(`=int(`mvlvl')')
					matrix table[`i', 9] = r(lb_alpha)*100
				}
				
				* if user has requested one above 50, 
				* it is the upper limit of a 2*mv-100% confidence interval
				if `mv' > 50 & `mv' < 99.9 {
					local mvlvl = 2*`mv'-100
					`call_svyp' level(`=int(`mvlvl')')   
					matrix table[`i', 9] = r(ub_alpha)*100
				}
			}
			
			* Clipping happens at the upper and lower limits of a clip% CI
			
			if `clip`i''!=. {	
				`call_svyp' level(`clip`i'')
				matrix table[`i', 10] = r(lb_alpha)*100  
				matrix table[`i', 11] = r(ub_alpha)*100
			}

			* Now calculate the x and y coordinates of NL pairs of points to  
			* define the outline of the top portion of the distribution
			
			* Begin by calculating the x coordinates...these are the upper 
			* and lower bounds of nl CIs ... one at lvl1, lvl2, etc.
			
			`call_svyp' cilevellist(${CILEVELLIST_`nl'}) 
			
			matrix ci_list = r(ci_list)
			
			forvalues j = 1/`nl' {
							
				* calculate the appropriate height (h) value for this interval
				* so the area under the rectangles defined by ui and li will
				* sum up to about 99.99 - 0.01 = 99.98 %
				
				scalar ai = ci_list[`j',1]
				scalar li = ci_list[`j',2]*100
				scalar ui = ci_list[`j',3]*100
				
				matrix avals[`i',`j'] = ai
				matrix lvals[`i',`j'] = li
				matrix uvals[`i',`j'] = ui
				
				scalar uimli = ui - li
				
				if `j' == 1 {
					scalar uimli = ui - li
					scalar hi = ai / uimli
					matrix hvals[`i',`j'] = hi
					scalar lastuimli = uimli
				}
				
				if `j' > 1 {
					scalar uimli = ui -li
					scalar hi = (ai - real(word("${CILEVELLIST_`nl'}",`=`j'-1'))) / (uimli - lastuimli)
					matrix hvals[`i',`j'] = hi			
					scalar lastuimli = uimli
				}
			}

			* In the hi calculations, the hi are NOT constrained to be 
			* strictly decreasing as level increases from 0.01 to 99.99.
			*
			* In most circumstances we would like them to follow that 
			* pattern, (the height of rectangle that portrays the ZZ% CI 
			* should be higher than the height of the rectangle portraying
			* the QQ% CI if ZZ% < QQ%) but it seems to not be the case
			* for the clopper pearson intervals - in order to meet the area
			* constraints, sometimes h1 is lower than h2.
			
			* So lets think of two possible polygons for portraying the 
			* distribution.  The first we call the 'stairstep' distribution
			* and it consists of the set of li, ui, and hi such that the
			* sum of the areas under the rectangles = 99.99 - 0.01, even
			* if the hi do not decrease monotonically as ai increases
			*
			* this stairstep polygon will have 4*nl points to define
			* all the vertices of the nl CI rectangles; it is a concave
			* polygon because it shows each of the stairsteps and it may
			* be concave if h1 < h2
			*
			* the second polygon is a smooth bounding polygon formed by 
			* the outermost points of the stairstep polygon; it consists
			* of 2*(nl+1) points 
			*
			* when the sets of li, ui, and hi are originally calculated,
			* the areas of the smooth boundary (sb) polygons may differ 
			* somewhat; we calculate their area in the code below and 
			* note that the area calculation also includes the triangles
			* at the top of the CI rectangles (although not at the top of
			* the topmost rectangle)
			*
			* So the user may wish to portray the stairstep polygon, and 
			* show those with equal area for different strata; this is 
			* accomplished by setting the user option 'equalarea' to 1 and
			* by setting the option 'polygon' to either 1 or 3.  Polygon
			* equals 1 will result in only the stairstep polygons showing; 
			* and equals 3 will show stairsteps colored in with smooth
			* bounding polygons shown with a line around the stairstep.
			*
			* If the user wants to portray only the smooth polygons, 
			* then set the polygon option to 2.  And if the user wants those
			* smooth polygons for each stratum to have equal area, 
			* set the equalarea option to 2.
			*
			* Note that the equalarea option will result in polygon vertices
			* such that the polygons have equal area, but when they are 
			* portrayed graphically, sometimes the area varies somewhat from
			* distribution to distribution, depending on the scale of the 
			* figure, the number of distributions, and the width of any
			* lines around the polygons
			
			* Populate the x and y matrices to hold the coordinates of the
			* stairstep (ss) and the smooth bounding (sb) polygons
			
			* calculate boundaries for stairstep polygons
			* first point is at bottom left of polygon and last point 
			* is at bottom right; the points go clockwise around the 
			* top of the distribution
			
			local sslc = 2*`nl' 
			local ssuc = `sslc' + 1
			
			forvalues j = 1/`nl' {
							
				matrix ssxvals[`i',`=`sslc'-1'] = lvals[`i',`j']
				matrix ssxvals[`i',`sslc']      = lvals[`i',`j']
				
				matrix ssxvals[`i',`ssuc']      = uvals[`i',`j']
				matrix ssxvals[`i',`=`ssuc'+1'] = uvals[`i',`j']
				
				matrix ssyvals[`i',`sslc']      = hvals[`i',`j']
				matrix ssyvals[`i',`=`sslc'+1'] = hvals[`i',`j']
				
				matrix ssyvals[`i',`ssuc']      = hvals[`i',`j']
				matrix ssyvals[`i',`=`ssuc'-1'] = hvals[`i',`j']
				
				local sslc = `sslc' - 2
				local ssuc = `ssuc' + 2
	
			}
			
			matrix ssyvals[`i',1]        = 0
			matrix ssyvals[`i',`=4*`nl''] = 0
				
			* calculate boundaries for smooth bounding polygons
			* first point is at bottom left of polygon and last point 
			* is at bottom right; the points go clockwise around the 
			* top of the distribution
			
			local sblc = `nl'   + 1
			local sbuc = `sblc' + 1
			
			forvalues j = 1/`nl' {
							
				matrix sbxvals[`i',`sblc']      = lvals[`i',`j']
				matrix sbxvals[`i',`sbuc']      = uvals[`i',`j']
				
				matrix sbyvals[`i',`sblc']      = hvals[`i',`j']
				matrix sbyvals[`i',`sbuc']      = hvals[`i',`j']
				
				local --sblc 
				local ++sbuc 
	
			}
			
			matrix sbyvals[`i',1]             = 0
			matrix sbyvals[`i',`=2*(`nl'+1)'] = 0
			
			matrix sbxvals[`i',1]             = lvals[`i',`nl']
			matrix sbxvals[`i',`=2*(`nl'+1)'] = uvals[`i',`nl']
			
			* loop up the left side and up the right side of each 
			* distribution and do not let the y-values decrease
			
			forvalues j = 2/`=`nl'+1' {
				matrix sbyvals[`i',`j'] = max(sbyvals[`i',`j'], sbyvals[`i',`=`j'-1'])
			}
			forvalues j = `=2*(`nl'+1)-1'(-1)`=`nl'+2' {
				matrix sbyvals[`i',`j'] = max(sbyvals[`i',`j'], sbyvals[`i',`=`j'+1'])
			}
		}
		
		* Having stored the coordinates in those matrices, bring them into 
		* a dataset in memory and wrangle them into the shape we need for 
		* plotting
		
		clear
		svmat table, names(col) 
		svmat ssxvals, names(col) 
		svmat ssyvals, names(col) 
		svmat sbxvals, names(col) 
		svmat sbyvals, names(col) 
		
		tempfile tempfile1 
		save `tempfile1', replace
		
		* distribution number (dn)
		gen dn = _n
		
		* put the row number in the dataset
		gen rownumber = .
		forvalues i = 1/`=_N' {
			replace rownumber = `rownumber`i'' in `i'
		}			

		* go from wide dataset to long
		drop if    p == .
		drop if ssx1 == .
		
		reshape long ssx ssy sbx sby, i(dn) j(j)
		
		* calculate scaling factor to give  equal area
				
		* total area of sb boxes and triangles
		gen areabt = (sbx - sbx[_n-1]) * min(sby,sby[_n-1]) + ///
		             0.5 * (sbx - sbx[_n-1]) * abs(sby - sby[_n-1]) if j > 2
		by dn: egen areasbt = total(areabt)
		
		* the original set of y-coordinates will usually result in sb polygons
		* that differ in area; generate a second set of 
		* y-coordinates for them so they will have equal area 
		* (this gives flexibility to plot whichever the user requests:
		*  equal-area for the stairstep polygons or equal-area for the 
		*  smooth bounding polygons)
		
		egen minareasbt = min(areasbt)
		gen sbt_scale_factor = minareasbt / areasbt
		gen sby2 = sby * sbt_scale_factor
		
		* calculate the area of polygons that use sby2 coordinates
		
		gen areabt2 = (sbx - sbx[_n-1]) * min(sby2,sby2[_n-1]) + ///
		              0.5 * (sbx - sbx[_n-1]) * abs(sby2 - sby2[_n-1]) if j > 2
		by dn: egen areasbt2 = total(areabt2)
		
		* calculate the area under the stairstep polygon rectangles using
		* the original y-coordinates; these should be equal and should be
		* equal to 99.98
		
		gen jodd  = mod(j,2) == 1 & j > 1
		gen areas =  (ssx - ssx[_n-1]) * ssy if jodd == 1
		by dn: egen areass = total(areas)
		
		* now calculate a scaled set of y-coordinates for stairstep
		* polygons to go with the new smooth bounding coordinates
		
		gen ssy2 = ssy * sbt_scale_factor

		* calcualate the area under the scaled ss rectangles
		
		gen areas2 =  (ssx - ssx[_n-1]) * ssy2 if jodd == 1
		by dn: egen areass2 = total(areas2)
		
		* These coordinates all have a base at y=0 and no enforced
		* upper bound on y, but for plotting purposes we are going to fit 
		* each polygon into a coordinate system such that the tallest 
		* polygon is 0.8 units high
		
		* generate four new sets of scaled coordinates for plotting
		
		egen m1 = max(ssy)
		egen m2 = max(ssy2)
		
		gen ssyy1 = (ssy/m1)
		gen sbyy1 = (sby/m1)
		gen ssyy2 = (ssy2/m2)
		gen sbyy2 = (sby2/m2)
		
		* Now set the y-coordinates for plotting based on the user inputs
		* (user input equalarea must be 1 or 2)
		
		if `equalarea' == 1 {
			gen ssyy = ssyy1*0.8+(rownumber-0.4)
			gen sbyy = sbyy1*0.8+(rownumber-0.4)
		}
		else if `equalarea' == 2 {
			gen ssyy = ssyy2*0.8+(rownumber-0.4)
			gen sbyy = sbyy2*0.8+(rownumber-0.4)
		}
		
		* clip upper and lower bounds of the distributions at specific CI 
		forvalues i = 1/`bign' {
			if `clip`i'' !=. {
				replace sbx = max(sbx,cliplb) if dn == `i'
				replace sbx = min(sbx,clipub) if dn == `i'
				
				replace ssx = max(ssx,cliplb) if dn == `i'
				replace ssx = min(ssx,clipub) if dn == `i'
			}
		}

		* set up some x and y variables for plotting
		
		gen yminall = 0.6
		egen ymaxall = max(ssyy)

		egen xminall = min(ssx)
		egen xmaxall = max(ssx)

		gen ymin = rownumber - 0.4
		by dn: egen ymax = max(ssyy)

		by dn: egen xmin = min(ssx)
		by dn: egen xmax = max(ssx)

		* add an empty row between distributions - to make the dataset easy
		* to examine by eye and to make the area plots distinct for each 
		* distribution
		set obs `=_N+`bign'-1'
		replace j = `=4*`nl'+1' if ssx==.
		gsort - j
		replace dn = _n if _n < `bign'
		sort dn j
		replace dn = . if missing(ssx)
		replace j = . if missing(ssx)

		tempfile tempfile2
		save `tempfile2', replace

		* Now set up macros and variables needed to construct the plot itself
		
		* create macro variables to plot tick marks 
		********************************************
		keep if j==1     

		forvalues i = 1/`bign' {

			* macro vars for min and max values to use in plotting
			local ymax`i'=ymax[`i']
			local ymin`i'=ymin[`i']
			local xmax`i'=xmax[`i']
			local xmin`i'=xmin[`i']
			local ymaxall=ymaxall[1]
			local yminall=yminall[1]
			local xminall=xminall[1]
			local xmaxall=xmaxall[1]

			* macro variables to plot tick marks of CIs
			local lcbpct`i' = lcbpct[`i']
			local ucbpct`i' = ucbpct[`i']
			local lb95`i' =  lb_95pct[`i']
			local ub95`i' =  ub_95pct[`i']			
		}


		* Make five types of string variable containing est & 3 useful 95% CIs
		* to plot on the right hand side of the plot
		*******************************************************************
		use `tempfile2', clear
		
		* lower limit of traditional 95% CI
		gen     lb_str1 = string(lb_95pct, "%4.${VCQI_NUM_DECIMAL_DIGITS}f")
		replace lb_str1 = "100" if lb_str1=="100.0"
		* upper limit of traditional 95% CI
		gen     ub_str1 = string(ub_95pct, "%4.${VCQI_NUM_DECIMAL_DIGITS}f")
		replace ub_str1 = "100" if ub_str1=="100.0"

		gen     lb_str2 = "0"
		* 95% upper confidence bound (UCB)
		gen     ub_str2 = string(ucbpct, "%4.${VCQI_NUM_DECIMAL_DIGITS}f")
		replace ub_str2 = "100" if ub_str2=="100.0"
		
		* 95% lower confidence bound (LCB)
		gen     lb_str3 = string(lcbpct, "%4.${VCQI_NUM_DECIMAL_DIGITS}f")
		replace lb_str3 = "100" if lb_str3=="100.0"
		gen ub_str3 = "100"
		
		gen cistring0 = ""
		
		gen pstring = strtrim(string(p, "%4.${VCQI_NUM_DECIMAL_DIGITS}f"))
		replace pstring = "100" if pstring == "100.0"
		replace pstring = pstring + "%"

		*   cistring1 contains lower 95% confidence bound (LCB), p, and 95% upper confidence bound
		gen cistring1 =  strtrim(lb_str3) + " | " + pstring + " | " + ub_str2 

		*   cistring2 contains p, (95%CI)
		gen cistring2 =  pstring + " (" + lb_str1 + "," + ub_str1 + ")"

		*   cistring3 contains p, (0, 95% UCB]
		gen cistring3 = strtrim(cistring2) + " (" + lb_str2 + "," + ub_str2 + "]" 

		*   cisrting4 contains p, (95% LCB, 100]
		gen cistring4 = strtrim(cistring2) + " [" + lb_str3 + "," + ub_str3 + ")" 

		*   cistring5 contains p, 95% CI, (95% LCB, 100] [0, 95% UCB)
		gen cistring5 = strtrim(cistring2) + " (" + lb_str2 + "," + ub_str2 + "]" + " [" + lb_str3 + "," + ub_str3 + ")"
		
		*   cistring6 contains 2sided-95%-lower-limit - p - 2sided-95%-upper-limit  N=N
		*   (where N is ESS for ESS and N for DATASET)
		* 	(and the estimates do not have info after decimal place, per Nigeria 2016 MICS/NICS report protocol)
		
		gen cistring6 = string(lb_95pct, "%02.0f") + " - " + string(p, "%02.0f") + " - " + string(ub_95pct, "%02.0f") + "  N= " + string(effss, "%5.0fc")
		replace cistring6 = " " + cistring6 if lb_95pct < 9.5
		replace cistring6 = subinstr(cistring6,"N=","N= " ,1) if effss < 1000 & effss > 99
		replace cistring6 = subinstr(cistring6,"N=","N=  ",1) if effss < 99
		replace cistring6 = cistring6 + " (*)" if effss < 50 & effss > 25
		replace cistring6 = cistring6 + " (!)" if effss < 25

		* Clear out the auto-generated cistrings if the user is plotting more 
		* than one distribution per row - we can't know which distribution to 
		* summarize when there is more than one per row, so don't summarize any
		
		if `multiple_shapes_on_some_rows' replace cistring`citext' = ""	
		
		* But allow user-specified text at right...the user can manage this
		* via the inputs and will have a fix if they get more text than 
		* they wanted.
		*
		* Overwrite the cistring with the user specified text from the input data
		local showtextatright 0
		forvalues i = 1/`bign' {
		    replace cistring`citext' = "`rightsidetext`i''" if "`rightsidetext`i''" != "." & "`rightsidetext`i''" != "" & dn==`i' 
			if "`rightsidetext`i''" != "." & "`rightsidetext`i''" != "" local showtextatright 1
		}
				
		* Determine the length of ci text on the right
		
		egen lencitext`citext' = max(strlen(cistring`citext'))
				
		local lencitext=lencitext`citext'[1]
		
		drop lencitext`citext'		
		
		* We don't need the string to be repeated many times
		forvalues i = 0/5 {
			replace cistring`i' = "" if j > 1
		}

		* use xsize and ysize to control height and width of the plot 
		* (if the user did not pass in values for these parameters)
		*************************************************************************************
		* ysize(#) and xsize(#) specify relative height and width of the available area.
		* Each takes values from 0 to 20.  
		* if user wants to plot more than 10 distributions then plot will be vertical rectangular 
		* The user can change the aspect ratio after the plot is saved, using the
		* graph display, xsize() ysize() command
		if "`xsize'" == "" & "`ysize'" == "" &  `nplotrows' > 10 {
			local ysize 20
			local xsize `= min(20, (20+ (20*(10/`nplotrows')))/2)'
		}

		* Range of X axis
		***********************************************************************
		* If user didn't specify x axis range, create macro variable for range to feed into plot

		* If xaxisrange was left blank then it will be created here based on x minimum and maximum values
				
		if `xaxisdesign' == 1 {  // Always plot from 0 to 100 with text beyond 100
			local xrangemin 0
			local xlabelmax 100
			if "`citextleftmargin'" != "" local xtextstart = `xmaxall' + `citextleftmargin'
			else local xtextstart = 103
			local xtextscale = 1.1
			local xrangemax = max(100,ceil(`=`xtextstart' + `lencitext'*`xtextscale'')) 
			local xaxisrange  `xrangemin' `xrangemax'
		}
		else if `xaxisdesign' == 2 {  // Round down and up from xlimits of data
			local round5min = round(`xminall',5)
			if `round5min' >= `xminall' local round5min = `round5min' - 5
			local xrangemin = max(0,`round5min')
			local round5max = round(`xmaxall',5)
			if `round5max' <= `xmaxall' local round5max = `round5max' + 5
			local xlabelmax = min(`round5max',100)
			if "`citextleftmargin'" != "" local xtextstart = `xmaxall' + `citextleftmargin'
			else local xtextstart = `xlabelmax' + 1
			local xtextscale = max(0.3,`=1.1*(`xtextstart' - `xrangemin')/100')
			local xrangemax = ceil(`=`xtextstart' + `lencitext'*`xtextscale'')

			local xaxisrange  `xrangemin' `xrangemax'
		}
		else if `xaxisdesign' == 3 {  // user specified max and min
			local xrangemin = word("`xaxisrange'",1)
			local xrangemax = word("`xaxisrange'",2)	
			if `xrangemin' > `xminall' {
				local round5min = round(`xminall',5)
				if `round5min' >= `xminall' local round5min = `round5min' - 5
				local xrangemin = max(0,`round5min')
			}
			local round5max = round(`xmaxall',5)
			if `round5max' <= `xmaxall' local round5max = `round5max' + 5
			local xlabelmax = min(`round5max',100)
			if "`citextleftmargin'" != "" local xtextstart = `xmaxall' + `citextleftmargin'
			else local xtextstart = `xlabelmax' + 1
			local xaxisrange  `xrangemin' `xrangemax'
		}
		
		if index("`twoway'","xlabel") > 0 local user_specified_xlabel 1
		
		local xrangelen = `xlabelmax' - `xrangemin'
		
		if inrange(`xrangelen',2,13)   local step  2
		if inrange(`xrangelen',13,32)  local step  5
		if inrange(`xrangelen',32,59)  local step 10
		if inrange(`xrangelen',59,80)  local step 20
		if inrange(`xrangelen',80,200) local step 25
		
		* Tilt of x axis labels
		************************nk m***********************************************************
		* if x axis extends to 150% then tilt labels at 45 degrees angle
		local xlabangle 0
		if `xrangemax' > 150 local xlabangle 45
		
		if index("`twoway'","xlabel") == 0 local xlabel xlabel(`xrangemin'(`step')`xlabelmax',angle(`xlabangle')) 
		
		* Create coordinate variables to position CI text on the right 
		*********************************************************************** 
		* For VCQI, CI text will always start at x=105 
		
		gen text_x = `xtextstart'

		* center text vertically on the integer y-values
		gen text_y = rownumber
		
		* If the user has requested xlines (by specifying 1+ horizontal lines
		* with no start and top x-coordinates) then we want to paint a white box 
		* at the right side to cover the ylines so they do not interfere
		* with citext or rightsidetext		
		
		* establish two x,y pairs for plotting a large white rectangle strip
		* from the top to the bottom of the plot
		
		gen shadeclipx = .
		gen shadeclipy = `nplotrows' + 0.5 if _n < 3
		* Suggested improvement from Stas
		replace shadeclipx = `xtextstart'-1 in 1
		set obs `=max(_N,2)'
		replace shadeclipx = `xrangemax' in 2

		save `tempfile2', replace


		* Assign user-specified rownames to a value label and apply it to dn
		***********************************************************************
		local def ""
		forvalues i = 1/`nplotrows' {
			local def `def'  `i' "`=trim("`rowname`i''")'"
		}

		label define ynames `def',replace
		label values rownumber ynames

		******************************************************************
		* Plot row names
		local plotit `plotit' (scatter rownumber p , m(i) c(none)) 

		* syntax to shade behind selected distributions
		
		gen yshade = .
		gen xshade = .
		forvalues i = 1/`nplotrows' {
			if "`shadebehind`i''" != "" {
				replace yshade = `i'+0.45 	if rownumber == `i' & inlist(j,1,2)
				replace xshade = `xrangemin' 		if rownumber == `i' & j == 1
				replace xshade = `=min(`xlabelmax',100)'	if rownumber == `i' & j == 2
				local plotit `plotit' ( area yshade xshade if rownumber == `i', color(`shadebehind`i'') fcolor(`shadebehind`i'') base(`=`i'-0.45') )
			}
		}	
				
		* syntax to add bars to the plot

		if !inlist("$IWPLOT_SHOWBARS","", "0") {
			gen ybar = .
			gen xbar = .
			forvalues i = 1/`nplotrows' {
				replace ybar = `i'+0.20 			if rownumber == `i' & inlist(j,1,2)
				replace xbar = `xrangemin' 			if rownumber == `i' & j == 1
				replace xbar = `=min(`=table[`i', 1]',100)'	if rownumber == `i' & j == 2
				local plotit `plotit' ( area ybar xbar if rownumber == `i', color(`outlinecolor`i'') lwidth(vthin) fcolor(`areacolor`i'')  fi(`areaintensity`i'') base(`=`i'-0.20') )
			}	
		}
		
		* Build macros to plot vertical reference lines that the user requested
		*
		* If the user specified y-coordinates for the lines to start and stop then
		* plot them using scatteri; if the lines are to extend all the way up
		* through the plot, then plot them using the xline option
		local verlinesthrough
		local verlinespartial
		if "`verlinesdata'"!="" {
			forvalues i = 1/`bigxl' {
				if missing(`ystart`i'') & missing(`ystop`i'') {
					local verlinesthrough `verlinesthrough' xline(`xcoord`i'', lc(`colorxl`i'') lw(`widthxl`i'') lstyle(`stylexl`i'') lpattern(`patternxl`i'') ) 
				}
				if !missing(`ystart`i'') & !missing(`ystop`i'') {
					local verlinespartial `verlinespartial' (scatteri `ystart`i'' `xcoord`i'' `ystop`i''  `xcoord`i'', c(direct) m(i) lc(`colorxl`i'') lw(`widthxl`i'') lstyle(`stylexl`i'') lpattern(`patternxl`i'') )
				}
			}
		}

		* Build macros to plot horizontal reference lines that the user requested
		*
		* If the user specified x-coordinates for the lines to start and stop then
		* plot them using scatteri; if the lines are to extend all the way across
		* through the plot, then plot them using the yline option
		local horlinesthrough
		local horlinespartial
		if "`horlinesdata'" != "" {
			forvalues i = 1/`bigyl' {
				if missing(`xstart`i'') & missing(`xstop`i'') {
					local horlinesthrough `horlinesthrough' yline(`ycoord`i'', lc(`coloryl`i'') lw(`widthyl`i'') lstyle(`styleyl`i'') lpattern(`patternyl`i'')) 
				}
				if !missing(`xstart`i'') & !missing(`xstop`i'') {
					local horlinespartial `horlinespartial' (scatteri `ycoord`i'' `xstart`i'' `ycoord`i'' `xstop`i''  , c(direct) m(i) lc(`coloryl`i'') lw(`widthyl`i'') lstyle(`styleyl`i'') lpattern(`patternyl`i'') )
				}
			}
		}		
			
   		
   		* Add custom text that user has requested
		
		local textonplotit
		if "`textonplotdata'" != "" {
			set obs `=max(_N,`textonplotlines')'
			forvalues i = 1/`textonplotlines' {
				if "`textorient`i''" == "horizontal" 	local p 3 	// go right from coords
				if "`textorient`i''" == "vertical"   	local p 12	// go up from coords
				if "`textorient`i''" == "rhorizontal" 	local p 9	// go left from coords
				if "`textorient`i''" == "rvertical" 	local p 6	// go down from coords
				
				local textonplotit `textonplotit' (scatteri 0 `xrangemin', msymbol(none) text( `ycoordtext`i'' `xcoordtext`i'' "`textonplot`i''" , placement(`p') size(`fontsizetext`i'') color(`colortext`i'') orientation(`textorient`i'') ) )
			
			}
		}
		* Add custom arrows that user has requested
        
		local arrowsplotit	  
		if "`arrowsdata'"!="" {	
			forvalues i = 1/`arrowsl'{
			local arrowsplotit `arrowsplotit'  (pcarrowi `ycoordend`i'' `xcoordend`i'' `ycoordtip`i'' `xcoordtip`i'' , lc(`arrowcolor`i'') lw(`arrowwidth`i'') mlc(`arrowcolor`i'') )
			}
        }
		
		* Begin to pack the local macro named "plotit" with all the commands
		* to portray the distributions and reference lines

		* Syntax to plot each of the distributions and tick marks
		
		* User input polygon determines whether we plot the stairstep polygons
		* or smooth polygons, or both; smooth is the default
		
		forvalues i = 1/`bign' {
		
			if inlist(`polygon`i'',1,3) local plotit `plotit' (area ssyy ssx if dn==`i', fc(`areacolor`i'') fi(`areaintensity`i'') ///
			                                                lc(`outlinecolor`i'') lw(`outlinewidth`i'') lp(`outlinepattern`i'') ///
															ls(`outlinestyle`i'') nodropbase) 
			
			if `polygon`i'' == 3 local plotit `plotit' (line sbyy sbx if dn==`i', connect(direct) lc(`outlinecolor`i'') ///
			                                         lw(`outlinewidth`i'') lp(`outlinepattern`i'') ls(`outlinestyle`i'') ) 
						
			* Plot inchworm shape if the user has not asked for bars 
			if inlist("$IWPLOT_SHOWBARS","", "0") & `polygon`i'' == 2 local plotit `plotit' (area sbyy sbx if dn==`i', fc(`areacolor`i'') fi(`areaintensity`i'') ///
			                                                lc(`outlinecolor`i'') lw(`outlinewidth`i'') lp(`outlinepattern`i'') ///
															ls(`outlinestyle`i'') nodropbase)  
															
			* Plot the 2-sided CI instead of inchworm shape if user specifies they want to see bars
			
			if !inlist("$IWPLOT_SHOWBARS","", "0") & `polygon`i'' == 2 local plotit `plotit' (scatteri `rownumber`i'' `lb95`i'' `rownumber`i'' `ub95`i'', c(direct) m(i) lw(*0.95) lc(black))

			* Plot reference line inside the distribution at the point estimate (but not if the user requested bars instead of distributions)
			
			if inlist("$IWPLOT_SHOWBARS","", "0") local plotit `plotit' (rspike ymin ymax p if dn==`i' & j==1,  lc(`outlinecolor`i'') lw(thin)) 
			
			* The user can ask to see a vertical reference line at a point that they specify
			if `markvalue`i'' != . {
				local plotit `plotit'  (rspike ymin ymax mvpct if dn==`i' & j==1,  lc(`markvaluecolor`i'') lw(thin))
			}
				   
			* add tick marks at specified one-sided LOWER confidence bound
			if "`lcb`i''" != "" {
				* vertical small line
				local plotit `plotit' (scatteri `=`rownumber`i''-0.08' `lcbpct`i'' `=`rownumber`i''+0.08'  `lcbpct`i'' if dn == `i', c(direct) m(i) lw(*0.5) lc(`lcbcolor`i'') )
				* horizontal small line
				local plotit `plotit' (scatteri `rownumber`i'' `lcbpct`i'' `rownumber`i'' `=`lcbpct`i''+0.35' if dn == `i', c(direct) m(i) lw(*0.5) lc(`lcbcolor`i'') )
			}

			* add tick marks at specified one-sided UPPER confidence bound
			if "`ucb`i''" != "" {
				* veritical tick marks
				local plotit `plotit' (scatteri `=`rownumber`i''-0.08' `ucbpct`i'' `=`rownumber`i''+0.08'  `ucbpct`i'' if dn == `i', c(direct) m(i) lw(*0.5) lc(`ucbcolor`i'') )
				* horizontal tick marks
				local plotit `plotit' (scatteri `rownumber`i'' `=`ucbpct`i''-0.35' `rownumber`i''  `ucbpct`i'' if dn == `i' & j==1, c(direct) m(i) lw(*0.5) lc(`ucbcolor`i'') )
			}					   
		}

		* Add citext to the right edge of the plot
		* If user has specified YLINES (horizontal lines with no start/stop x-coords) 
		* then first lay down a white rectangle at the right of the plot to provide
		* a clean background for the citext (cover the right edge of any YLINEs)
		* Note: mlabg(*-1) means it starts right at text_x, with no gap
		******************************************************************
		if (`citext'!=0 & `multiple_shapes_on_some_rows' == 0) | `showtextatright' == 1 {
			if "`horlinesthrough'" != "" local plotit `plotit' (area shadeclipy shadeclipx, color(white) fcolor(white))
			local plotit `plotit' (scatter text_y text_x, mlabel(cistring`citext') m(i) mlabg(*-1) mlabsize(*0.65) mlabcolor(black) ) 
		}
		
		if `xrangemin' == 0 & `xrangemax' >= 100 local step 25
		else local step 10

		local  plotit `plotit' `horlinespartial' `verlinespartial' `textonplotit' `arrowsplotit'
		
		graph twoway `plotit' , 	///
			`horlinesthrough' 		///
			`verlinesthrough' 		///
			legend(off) 			///
			ylabel(1(1)`nplotrows', ang(hor) nogrid valuelabel labsize(small))	///
			graphregion(color(white)) 	 				///
			xscale(range(`xaxisrange') titlegap(*10)) `xlabel'	///
			yscale(titlegap(1)) 	///
			ysize(`ysize') 			///
			xsize(`xsize') 			///
			xtitle(`xtitle')  		///
			ytitle(`ytitle') 		///
			title(`title')			///
			subtitle(`subtitle')	///
			note(`note')			///
			caption(`caption')		///
			name(`name')	 		///
			saving(`saving') `twoway' 
			


			
		* export graph in chosen format
		if `"`export'"'. != "" {
			graph export `export'
			noi di as text "Exported inchworm plot:"
			noi di `"`export'"'
		}

		* clear working directory
		if upper("`cleanwork'") != "YES" {
			use `tempfile1', clear
			save iwplot_data_wide, replace
			use `tempfile2', clear
			save iwplot_data_long, replace
		}
	}

	if "$VCQI_LOGOPEN" == "1" {
		vcqi_log_comment $VCP 5 Flow "Exiting"
		global VCP `oldvcp'
	}

end

