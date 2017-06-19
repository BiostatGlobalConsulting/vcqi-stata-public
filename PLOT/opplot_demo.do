********************************************************************************
*
* Program to illustrate making organ pipe plots in two different strata
*
* Dale Rhoda 2016-07-22
* Dale.Rhoda@biostatglobal.com
*
********************************************************************************

clear
set more off
cd "C:\Users\Dale\Desktop\- temporary\opplot demo" // <--- Edit this line

* If necessary, add the folder that holds the opplot program to your adopath
* (Not necessary if you put the program in a folder that is already in the
*  adopath, like maybe c:/ado/personal or c:/ado/plus/o)

adopath + "C:\Users\Dale\Dropbox (Biostat Global)\DAR GitHub Repos\vcqi-stata-bgc\PLOT"  // <--- Edit this line

* Make fake data with 2 strata with 10 clusters each with 10 respondents each

set seed 8675309
set obs 200
gen clusterid = mod(_n-1,10)+1
bysort clusterid: gen stratumid = _n <= 10

* The yes/no outcome variable here is y.  It can take values of 0, 1, or missing(.).
* If it takes any other values, opplot will complain and abort.

gen y = runiform() > clusterid/10
* Boost coverage in stratum 1
replace y = 1 if runiform() > .5 & stratumid == 1

* Basic demo...two plots...one for each stratum
opplot y , clustvar(clusterid) stratvar(stratumid) stratum(0) title(Stratum 0) name(Demo0,replace)
opplot y , clustvar(clusterid) stratvar(stratumid) stratum(1) title(Stratum 1) name(Demo1,replace)

* Change bar colors
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		stratum(1) title(Stratum 1) name(Demo2,replace) ///
		barcolor1(red) barcolor2(gs8)
		
* Demo different bar widths if weights differ
gen weight = 1
replace weight = 2 if clusterid == 1
		
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		weightvar(weight) ///
		stratum(1) title(Stratum 1) name(Demo3,replace) ///
		barcolor1(red) barcolor2(gs8)	

* Change line colors		
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		weightvar(weight) ///
		stratum(1) title(Stratum 1) name(Demo4,replace) ///
		barcolor1(red) barcolor2(gs8)	///
		linecolor1(white) linecolor2(green)
		
* Change ylabel;
* Demo ylabel xtitle ytitle subtitle footnote
* Demo export
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		weightvar(weight) ///
		stratum(1) title(Stratum 1) name(Demo5,replace) ///
		ylabel(0(25)100,angle(0)) ///
		xtitle(XTitle) ytitle(YTitle) ///
		subtitle(Subtitle) footnote(Footnote) ///
		export(Stratum_1.png)

* The exportstratumname option saves you the trouble of coming
* up with the export filename		
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		stratum(0) title(Stratum 0) name(Demo0,replace) ///
		exportstratumname
		
* The exportwidth options lets you specify that a larger file is saved
* with better resolution for some purposes
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		stratum(0) title(Stratum 0) name(Demo0,replace) ///
		exportstratumname exportwidth(2000)

* Demo changing the aspect ratio of the figure using xsize and ysize		
opplot y , clustvar(clusterid) stratvar(stratumid) ///
		stratum(0) title(Stratum 0) name(Demo6,replace) ///
		xsize(20) ysize(6) export(Stratum_0_wide.png)

* Here is the 'syntax' statement from opplot.  I have demoed the useful
* features in this program.  The 'savedata' option is currently commented
* out, but you can uncomment and use it.
	
/*		
	syntax varlist(max=1) [if] [in], CLUSTVAR(varname fv) ///
	[STRATVAR(varname fv) STRATUM(string) WEIGHTvar(varname) ///
	 TITLE(string) SUBtitle(string) FOOTnote(string) ///
	 BARCOLOR1(string) LINECOLOR1(string) ///
	 BARCOLOR2(string) LINECOLOR2(string) ///
	 XTITLE(string) YTITLE(string) XLABEL(string) YLABEL(string) ///
	 EXPORTSTRAtumname EXPORT(string) EXPORTWidth(integer 2000) ///
	 SAVING(string asis) NAME(string) SAVEDATA(string asis) ///
	 XSIZE(real -9) YSIZE(real -9) ]
	 
*/

* Let me know if you have questions!		
