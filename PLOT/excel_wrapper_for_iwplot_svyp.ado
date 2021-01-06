*! excel_wrapper_for_iwplot_svyp version 1.03 - Biostat Global Consulting - 2019-10-17
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2019-02-14	1.02	MK Trimner		Added line to run iwplot if commandlines empty
*										This will run with default values and will not save
* 2019-10-17	1.03 	Dale Rhoda		Set IWPLOT_SHOWBARS to 0 by default
*******************************************************************************

program define excel_wrapper_for_iwplot_svyp
	version 14.1
	
	* Set the local for xlsname for importing data
	local xlsname `1'
	
	capture program drop iwplot_svyp
	
	set more off
	
	if "$IWPLOT_SHOWBARS" == "" global IWPLOT_SHOWBARS 0
	
	* read the main worksheet with info about distributions, markvalues,
	* clipping, lcb ticks, ucb ticks, shading behind distributions
	* and customized text for the right margin
	import excel using "`xlsname'", sheet("distribution_info") firstrow allstring clear
	capture quietly destring rownumber , replace
	capture quietly destring param1, replace
	capture quietly destring param2, replace
	capture quietly destring areaintensity, replace
	capture quietly destring markvalue, replace
	capture quietly destring clip, replace
	capture quietly destring lcb , replace
	capture quietly destring ucb , replace
	tempfile distribution
	save `distribution', replace

	* read & save info about any desired vertical lines
	import excel using "`xlsname'", sheet("vertical_lines") firstrow allstring clear
	if `=_N' > 0 {
		capture quietly destring xcoord  , replace
		capture quietly destring ystart  , replace
		capture quietly destring ystop   , replace
		tempfile vl
		save `vl', replace
		local verplot verlinesdata(`vl')
	}

	* read & save info about any desired horizontal lines
	import excel using "`xlsname'", sheet("horizontal_lines") firstrow allstring clear
	if `=_N' > 0 {
		capture quietly destring ycoord , replace
		capture quietly destring xstart , replace
		capture quietly destring xstop  , replace
		tempfile hl
		save `hl', replace
		local horplot horlinesdata("`hl'")	
	}
	
	* read & save info about any desired text to put on top of the plot
	* (Note that CI text at right is handled with the citext option
	*  and graph and axis titles should be specified using the iwplot_vcqi
	*  options...this textbox business is for additional text on top 
	*  of the plot to call attention to something special.)
	import excel using "`xlsname'", sheet("textbox") firstrow allstring clear
	if `=_N' > 0 {
		capture quietly destring xcoordtext , replace
		capture quietly destring ycoordtext , replace
		tempfile tx
		save `tx', replace
		local textplot textonplotdata("`tx'")	
	}

	* read & save info about any desired arrows
	import excel using "`xlsname'", sheet("arrows") firstrow allstring clear
	if `=_N' > 0 {
		capture quietly destring xcoordend, replace
		capture quietly destring ycoordend, replace
		capture quietly destring xcoordtip, replace
		capture quietly destring ycoordtip, replace
		tempfile ar
		save `ar', replace
		local arrowplot arrowsdata("`ar'")	
	}

	* Call the program that makes and saves and exports the plot;
	* note that additional options are available; look at the comments
	* at the top of the program to learn more
	
	* The example below specifies 
	* nl(20)
	* which is to say that every distribution will be made of 20 x,y
	* pairs to define the shape of the top half of the distribution;
	* this will run faster if you specify nl(5) until the plot looks the
	* way you want it, and then switch to nl(20) (or higher) to make
	* your final plots for presentation
	
	* The example below specifies 
	* citext(3)
	* but you can also specify 1, 2, 4, or 5
	* or leave the option off altogether
	*
	
	* Pull in command_lines tab from spreadsheet to create local variables for iwplot_vcqi program
	* save info about command_lines


	import excel using "`xlsname'", sheet("command_lines") firstrow allstring clear
	capture quietly destring nl  				, replace
	capture quietly destring xaxisdesign		, replace
	capture quietly destring xsize  			, replace
	capture quietly destring ysize  			, replace
	capture quietly destring equalarea 			, replace
	capture quietly destring polygon 			, replace
	capture quietly destring citext         	, replace
	capture quietly destring citextleftmargin	, replace
	
	if `=_N' > 0 {
		* Create the command_line locals based on the values from the spreadsheet
		forvalues i = 1/`=_N' {
			foreach v in nl xtitle ytitle title subtitle note xaxisdesign xaxisrange xsize ysize citext citextleftmargin equalarea saving name export cleanwork twoway {
				capture gen `v' = .
				local `v' 
				if !missing(`v'[`i'])	local `v' `v'(`=`v'[`i']')
			}
			
			preserve
	
			iwplot_svyp, 						///
				inputdata("`distribution'") 		///
				`nl'								///
				`xtitle' `ytitle' `title' ///
				`subtitle' `note' `xaxisdesign' `xaxisrange' `xsize' `ysize' ///
				`verplot' `horplot'  `textplot' `arrowplot' ///
				`citext' `citextleftmargin' `equalarea' ///
				`saving' `name' `export' `cleanwork' `twoway'

			restore
		}
	}
	else iwplot_svyp, 						///
				inputdata("`distribution'") 	///
				`verplot' `horplot' `textplot' `arrowplot'

	capture erase arrows.dta
	capture erase textbox.dta
	capture erase test1.dta
	capture erase vertical_lines.dta
	capture erase horizontal_lines.dta
	capture erase distribution_info.dta
*	capture erase distribution_info_l.dta
*	capture erase distribution_info_w.dta
end

