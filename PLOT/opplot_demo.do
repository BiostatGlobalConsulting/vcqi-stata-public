*! opplot_demo version 1.02 - Biostat Global Consulting - 2020-10-29
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-07-22	1.00	Dale Rhoda		Original version (date may be wrong)
* 2018-07-03	1.01	Dale Rhoda		Added plotn option (date may be wrong)
* 2020-10-29	1.02	Caitlin Clary	Vary respondents per cluster in faux
*										data; reload faux data after Demo 7;
*										demo plotting all strata; demo saving
* 										.tif; add comments throughout
*******************************************************************************

********************************************************************************
*
* Program to illustrate making organ pipe plots in two different strata
*
* Dale Rhoda
* Dale.Rhoda@biostatglobal.com
*
********************************************************************************

clear
set more off
capture mkdir "C:\Users\Dale\Desktop\- temporary\opplot demo" // <--- Edit this line
cd "C:\Users\Dale\Desktop\- temporary\opplot demo"            // <--- Edit this line

* If necessary, add the folder that holds the opplot program to your adopath
* (Not necessary if you put the program in a folder that is already in the
*  adopath, like maybe c:/ado/personal or c:/ado/plus/o)

adopath + "C:\Users\Dale\Dropbox (Biostat Global)\DAR GitHub Repos\vcqi-stata-bgc\PLOT"  // <--- Edit this line

* Make fake data with 2 strata with 10 clusters each with varying respondents per cluster

clear

set seed 8675309

set obs 200
gen clusterid = round(runiform(1, 20))
gen stratumid = 0
replace stratumid = 1 if clusterid > 10

* Generate an ID for clusters within strata (used when generating outcome below)
gen csindex = clusterid
replace csindex = clusterid-10 if clusterid > 10

* The yes/no outcome variable here is y.  It can take values of 0, 1, or missing(.).
* If it takes any other values, opplot will complain and abort.
gen y = 0
replace y = 1 if runiform() > csindex/10
drop csindex

* Boost coverage in stratum 1
replace y = 1 if runiform() > .5 & stratumid == 1

* Basic demo: two plots, one for each stratum
opplot y , clustvar(clusterid) stratvar(stratumid) stratum(0) title(Stratum 0) name(Demo0, replace)
opplot y , clustvar(clusterid) stratvar(stratumid) stratum(1) title(Stratum 1) name(Demo1, replace)

* Without the stratvar and stratum arguments, all strata are plotted 
opplot y , clustvar(clusterid) title(All Strata) name(Demo2, replace) 

* Change bar colors (barcolor1, barcolor2)
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		stratum(1) title(Stratum 1) name(Demo3, replace) ///
		barcolor1(ebblue) barcolor2(gs12)
		
* Demo different bar widths if weights differ (weightvar)
* Give additional weight to cluster 11 in stratum 1
gen weight = 1
replace weight = 2 if clusterid == 11
save fauxdata, replace
		
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		weightvar(weight) ///
		stratum(1) title(Stratum 1) name(Demo4, replace) ///
		barcolor1(ebblue) barcolor2(gs12)	

* Change line colors (linecolor1, linecolor2)	
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		weightvar(weight) ///
		stratum(1) title(Stratum 1) name(Demo5, replace) ///
		barcolor1(ebblue) barcolor2(gs12)	///
		linecolor1(white) linecolor2(pink)
		
* Demo Y axis breaks (ylabel) and text options (xtitle ytitle subtitle footnote)
* Demo export to save as a PNG 
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		weightvar(weight) ///
		stratum(1) title(Stratum 1) name(Demo6, replace) ///
		barcolor1(lavender) barcolor2(white) ///
		ylabel(0(25)100, angle(0)) ///
		xtitle(XTitle) ytitle(YTitle) ///
		subtitle(Subtitle) footnote(Footnote) ///
		export(Stratum_1.png)

* The exportstratumname option saves you the trouble of coming
* up with the export filename. Saves as <stratum name>.png
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		stratum(0) title(Stratum 0) name(Demo0, replace) ///
		exportstratumname
		
* The exportwidth options lets you specify that a larger file is saved
* with better resolution for some purposes
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		stratum(0) title(Stratum 0) name(Demo0, replace) ///
		export(0_higherres.png) exportwidth(3000)
			
* Demo saving as .tif file  
opplot y , clustvar(clusterid) stratvar(stratumid) ///
           stratum(0) title(Stratum 0) name(Demo0, replace) ///
           export(Stratum_0.tif)
		   
* Demo changing the aspect ratio of the figure using xsize and ysize		
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		stratum(0) title(Stratum 0) name(Demo7, replace) ///
		barcolor1(dkorange) barcolor2(eggshell)	///
		xsize(20) ysize(6) export(Stratum_0_wide.png)
		
* Demo saving the accompanying dataset (savedata) and having a look at it         
opplot y , clustvar(clusterid) stratvar(stratumid) ///
        stratum(0) title(Stratum 0) name(Demo7,replace) ///
		barcolor1(dkorange) barcolor2(eggshell)	///
        xsize(20) ysize(6) savedata(Demo7)
use Demo7, clear 
browse 

* Load faux data again
use fauxdata, clear

* Demo plotting the number of respondents (plotn)  
opplot y , clustvar(clusterid) stratvar(stratumid) ///
           stratum(0) title(Stratum 0) name(Demo8, replace) ///
           xsize(20) ysize(6) plotn
		   
* Demo plotting the number of respondents using all related options   
* plotn nlinecolor nlinewidth nlinepattern ytitle2 yround2     
opplot y , clustvar(clusterid) stratvar(stratumid) ///
           stratum(0) title(Stratum 0) name(Demo9, replace) ///
           xsize(20) ysize(6) plotn nlinecolor(red) nlinewidth(*2) ///
           nlinepattern(dash) ytitle2(Number of Respondents (N)) ///
           yround2(2)
		  
* Here is the 'syntax' statement from opplot.  We have demoed the useful
* features in this program.  
	
/*		
	syntax varlist(max=1) [if] [in], CLUSTVAR(varname fv) ///
	[STRATVAR(varname fv) STRATUM(string) WEIGHTvar(varname) ///
	 TITLE(string) SUBtitle(string) FOOTnote(string) NOTE(string) ///
	 BARCOLOR1(string) LINECOLOR1(string) ///
	 BARCOLOR2(string) LINECOLOR2(string) EQUALWIDTH ///
	 XTITLE(string) YTITLE(string) XLABEL(string) YLABEL(string) ///
	 EXPORTSTRAtumname EXPORT(string) EXPORTWidth(integer 2000) ///
	 SAVING(string asis) NAME(string) SAVEDATA(string asis) ///
	 XSIZE(real -9) YSIZE(real -9) TWOWAY(string asis) PLOTN ///
	 NLINEColor(string asis) NLINEWidth(string) NLINEPattern(string) ///
	 YTITLE2(string asis) YROUND2(integer 5) ]
*/

* Questions ???
* Email: Dale.Rhoda@biostatglobal.com
