*! uwplot_vcqi version 1.06 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
*-------------------------------------------------------------------------------
* 2016-02-12	1.1		Dale Rhoda		There's no cleanwork option needed here
*										Removed it from comments
*
* 2016-02-24	1.02	Dale Rhoda		Only set VCP and call vcqi_log_comment
*          								if VCQI is running; allows the possibility
*										to call the program from outside VCQI
* 2016-03-12	1.03	Dale Rhoda		set obs 2 if there's only one row in
*                                       the dataset; to allow room for x and y
*                                       for the white area at right
* 2017-05-18	1.04	Dale Rhoda		Remove color from level4 shape...outline 
*										filled with white triangle
* 2017-05-19	1.05	Dale Rhoda		Tweak shadebehind width and white 
*										rectangle dimensions
* 2017-08-26	1.06	Mary Prier		Added version 14.1 line
*********************************************************************************
* All datasets which are called into this program should be stored in 
* the working directory; the plot will also be saved in the working directory
*********************************************************************************
*
* Required option: 
*
* INPUTDATA the name of input dataset 
* (variables:
*     param1 -- sample size
*     param2 -- p (1-100)
*	  param3 -- y (= row number, starting at bottom of figure)
*	  param4 -- symbol
* 	  param5 -- size
* 	  param6 -- color
*     rowname -- row labels which will be displayed left of the y-axis
*     shadebehind 
*
* Optional:
*
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
*            See Nicholas J. G. Winte (2005) "Stata tip 23: Regaining control over axis ranges"
*
* VERLINESDATA dataset to describe vertical lines 
*             (variables: xcoord, ystart, ystop, color, thickness, style)
*             if ystart and ystop are missing then a vertical line across whole chart is drawn
*             it is possible to specify as many as needed vertical lines
*
* HORLINESDATA dataset to describe horizontal lines 
*              (variables: ycoord, xstart, xstop, color, thickness, style)
*              if xstart and xstop are missing then a horizontal line across whole chart is drawn
*              it is possible to specify as many as needed horizontal lines
*
* SAVING name of gph file to be save in working directory, this image can be edited 
*           later at any time in graph editor  or using addplot command   
*
* EXPORT name and suffix of the plot to be saved in working directory. If this option left blank
*             then plot will be saved as only a gph image 
*             (ex. graph1.png or graphBA_12.pdf)
*             possible suffixes: ps (PostScript), eps(Encapsulated PostScript),
*             wmf (Windows Metafile), emf (Windows Enhanced Metafile), pdf (PDF)
*             png (Portable Network Graphics), tif (TIFF)
********************************************************************************

program define uwplot_vcqi
	version 14.1
	
	syntax, 					///
		INPUTdata(string) [		///
		XTITLE(string) 			///
		YTITLE(string) 			///
		TITLE(string asis) 		///
		SUBtitle(string asis)	///
		NOTE(string asis) 		///
		XAXISRANGE(numlist) 	///
		XSIZE(real 10)			///
		YSIZE(real 10)			///
		VERlinesdata(string)	///
		HORlinesdata(string) 	///
		RIGHTtext(real 0) 		///
		SAVING(string asis) 	///
		NAME(string asis) 		///
		EXPORT(string) ]
		
	if "$VCQI_LOGOPEN" == "1" {
		local oldvcp $VCP
	global VCP uwplot_vcqi		
		vcqi_log_comment $VCP 5 Flow "Starting"
	}		
	
	* read in input data with distribution parameters	
	use `inputdata', clear
		
	**** 
	replace param4 = "S" 		if missing(param4)
	replace param5 = "large" 	if missing(param5)
	replace param6 = "black" 	if missing(param6)
	
	local bign = _N

	forvalues i = 1/`bign' {

		local n`i'	= param1[`i']
		local p`i'	= param2[`i']
		local y`i'  = param3[`i']
		local sym`i' = param4[`i']
		local size`i' = param5[`i']
		local color`i' = param6[`i']
		local outline`i' = outline[`i']
		
	}
		
		
	* If the user has specified the names of horizontal or vertical reference
	* line datasets, then put their properties into local macros

	if "`verlinesdata'"!="" {	
		use `verlinesdata', clear
		local bigxl				=_N
		forvalues i = 1/`bigxl' {
			local xcoord`i'		= xcoord[`i']
			local ystart`i'		= ystart[`i']
			local ystop`i'		= ystop[`i']
			local colorxl`i'	= color[`i']
			local thicknessxl`i'= thickness[`i']
			local stylexl`i'	= style[`i']
		}
	}

	if "`horlinesdata'"!="" {	
		use `horlinesdata', clear
		local bigyl				=_N
		forvalues i = 1/`bigyl' {
			local ycoord`i'		= ycoord[`i']
			local xstart`i'		= xstart[`i']
			local xstop`i'		= xstop[`i']
			local coloryl`i'	= color[`i']
			local thicknessyl`i'= thickness[`i']
			local styleyl`i'	= style[`i']
		}
	}


	* Now set up macros and variables needed to construct the plot itself
	
	use `inputdata', clear

	* macro variable for shading
	*********************************************************************
	gen yrange_all = 0.6+`bign'+0.4
	gen yshadenum  = dn // center the shading vertically on the reference line
	gen yshadepct  = 0.8 / yrange_all*100 /* define the thickness of the line in other words what portion of the plot it will cover*/
	replace yshadepct  = 0.7 / yrange_all*100	if `bign' < 20
	forvalues i = 1/`bign' {
		local yshadepct`i'=yshadepct[`i']
		local yshadenum`i'=yshadenum[`i']
	}

	* Make string variable containing est & N
	* to plot on the right hand side of the plot
	*******************************************************************


	*   rtstring1 contains % and N
	
	gen pstring = strtrim(string(param2, "%4.1f"))
	replace pstring = "100" if pstring == "100.0"
	
	gen nstring = strofreal(param1, "%10.0fc")
	forvalues i = 1/10 {
		replace nstring = " " + nstring if length(nstring) < 10
	}

	gen rtstring1 = pstring + " " + nstring

	local lenrttext0 = 0
	local lenrttext1 = length(rtstring1)


	* use xsize and ysize to control height and width of the plot 
	*************************************************************************************
	* ysize(#) and xsize(#) specify relative height and width of the available area.
	* Each takes values from 0 to 20.  
	* if user wants to plot fewer than 10 distributions then plot will be 
	* square
	* if user wants to plot fewer than 10 distributions then plot will be square
	* if user wants to plot more than 10 distributions then plot will be vertical rectangular 
	* The user can change the aspect ratio after the plot is saved, using the
	* graph display, xsize() ysize() command
	local ysize 20
	if `bign' <= 10 local xsize 20
	if `bign' > 10  local xsize `= min(20, (20+ (20*(10/`bign')))/2)'

	* Range of X axis
	***********************************************************************
	* If user didn't specify x axis range, create macro variable for range to feed into plot

	* If xaxisrange was left blank then it will be created here based on x minimum and maximum values
	if "`xaxisrange'" == "" {
		local xrangemin 0
		local xrangemax = ceil(105 + `lenrttext`righttext''*1.6)
		local xaxisrange  `xrangemin' `xrangemax'
	}

	* Create coordinate variables to position CI text on the right 
	*********************************************************************** 
	* For VCQI, CI text will always start at x=105 
	gen text_x = 105

	* center text agaist text_y
	gen text_y = dn
	
	* establish two x,y pairs for plotting a large white rectangle strip
	* from the top to the bottom of the plot, at right...this will cover
	* the right edge of any YLINE options and keep them from interfering
	* with the citext that starts at x=105
	
	gen shadeclipx = .
	gen shadeclipy = `bign' + 0.75 if _n < 3
	replace shadeclipx = 103 in 1
	set obs `=max(_N,2)'
	replace shadeclipx = `xrangemax' in 2
	
	* Tilt of x axis labels
	************************nk m***********************************************************
	* if x axis extands to 140% then tilt labels at 45 degrees angle
	local xlabangle 0
	if `xrangemax' > 140 local xlabangle 45

	* Assign user-specified rownames to a value label and apply it to dn
	***********************************************************************
	local def 
	forvalues i = 1/`bign' {
		local def `def'  `i' "`=trim("`=rowname[`i']'")'"
	}

	label define ynames `def' , replace
	label values dn ynames

	******************************************************************

	* syntax to shade behind selected distributions
	local shadelines 
	forvalues i = 1/`bign' {
		if shadebehind[`i'] != ""{
			local shadelines `shadelines' yline(`yshadenum`i'', lw(`yshadepct`i'') lc(`=shadebehind[`i']') lstyle(foreground) noextend) 
		}
	}	
						   
	* add vertical reference lines that the user requested
	*
	* If the user specified y-coordinats for the lines to start and stop then
	* plot them using scatteri; if the lines are to extend all the way up
	* through the plot, then plot them using the xline option
	local verlinesthrough
	local verlinespartial
	if "`verlinesdata'"!="" {
		forvalues i = 1/`bigxl' {
			if mi(`ystart`i'') & mi(`ystop`i'') {
				local verlinesthrough `verlinesthrough' xline(`xcoord`i'', lc(`colorxl`i'') lw(`thicknessxl`i'') lstyle(`stylexl`i'')) 
			}
			if !mi(`ystart`i'') & !mi(`ystop`i'') {
				local verlinespartial `verlinespartial' (scatteri `ystart`i'' `xcoord`i'' `ystop`i''  `xcoord`i'', c(direct) m(i) lc(`colorxl`i'') lw(`thicknessxl`i'') lstyle(`stylexl`i'') )
			}
		}
	}

	* add horizontal reference lines that the user requested
	*
	* If the user specified x-coordinats for the lines to start and stop then
	* plot them using scatteri; if the lines are to extend all the way across
	* through the plot, then plot them using the yline option
	local horlinesthrough
	local horlinespartial
	if "`horlinesdata'"!=""{
		forvalues i = 1/`bigyl' {
			if mi(`xstart`i'') & mi(`xstop`i'') {
				local horlinesthrough `horlinesthrough' yline(`ycoord`i'', lc(`coloryl`i'') lw(`thicknessyl`i'') lstyle(`styleyl`i'')) 
			}
			if !mi(`xstart`i'') & !mi(`xstop`i'') {
				local horlinespartial `horlinespartial' (scatteri `ycoord`i'' `xstart`i'' `ycoord`i'' `xstop`i''  , c(direct) m(i) lc(`coloryl`i'') lw(`thicknessyl`i'') lstyle(`styleyl`i'') )
			}
		}
	}
						 
	* Begin to pack the local macro named "plotit" with all the commands
	* to portray the distributions and reference lines
	
	* Plot row names
	local plotit  (scatter dn param2 , m(i) c(none)) 

	* Syntax to plot each of the distributions and tick marks
	forvalues i = 1/`bign' {
		if "`n`i''" != "" & "`p`i''" != "" & "`y`i''" != "" & "`outline`i''" == "1" {
			local plotit `plotit' (scatteri `y`i'' `p`i'' if dn==`i', ms(`sym`i'') mc(`color`i'') msize(`size`i'') )
			local plotit `plotit' (scatteri `y`i'' `p`i'' if dn==`i', ms(`sym`i'') mc(white) msize(`=`size`i''*0.75') )
		}
		if "`n`i''" != "" & "`p`i''" != "" & "`y`i''" != "" & "`outline`i''" != "1" local plotit `plotit' (scatteri `y`i'' `p`i'' if dn==`i', ms(`sym`i'') mc(`color`i'') msize(`size`i'') )
	}

	* Add rttext to the right edge of the plot
	* first lay down a white rectangle at the right of the plot to provide
	* a clean background for the citext (cover the right edge of any YLINEs)
	* Note: mlabg(*-1) means it starts right at x=105, no gap
	******************************************************************
	if `righttext'!=0 {
		local plotit `plotit' (area shadeclipy shadeclipx, color(white) fcolor(white))
		local plotit `plotit' (scatter text_y text_x, mlabel(rtstring`righttext') m(i) mlabg(*-1) mlabsize(*0.65) mlabcolor(black) ) 
	}

	local  plotit `plotit' `horlinespartial' `verlinespartial'
	
	di `"`shadelines'"'
	
	graph twoway `plotit' , 	///
		`horlinesthrough' 		///
		`verlinesthrough' 		///
		`shadelines'			///
		legend(off) 			///
		ysize(`ysize') 			///
		xsize(`xsize') 			///
		ylabel(1(1)`bign', ang(hor) nogrid valuelabel labsize(small))	///
		graphregion(color(white)) 	 				///
		xscale(range(`xaxisrange') titlegap(*10)) 	///
		xlabel(0(25)100,angle(`xlabangle')) 		///
		yscale(range(0.4 `=`bign'+0.5') titlegap(1)) 	///
		xtitle(`xtitle')  		///
		ytitle(`ytitle') 		///
		title(`title')			///
		subtitle(`subtitle')	///
		note(`note')			///
		name(`name')	 		///
		saving(`saving') 

	* export graph in chosen format
	if "`export'" != "" {
		graph export "`export'", width(2000) replace
		noi di "Exported unweighted plot: `export'"
	}

	if "$VCQI_LOGOPEN" == "1" {
		vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'
	}

end

