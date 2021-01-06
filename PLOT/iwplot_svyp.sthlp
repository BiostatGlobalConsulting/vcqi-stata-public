{smcl}
{...}
{...}
{* *! iwplot_svyp.sthlp version 1.00 - Biostat Global Consulting - 2016-02-18}{...}
{* Change log: }{...}
{* 				Updated}{...}
{*				version}{...}
{* Date 		number 	Name			What Changed}{...}
{* 2016-02-18	1.00	Dale Rhoda		Original version}{...}
{* xxxx-xx-xx	1.0x	<name>			<comment>}{...}
{...}
{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install excel_wrapper_for_iwplot_svyp" "ssc install excel_wrapper_for_iwplot_svyp"}{...}
{vieweralsosee "Help excel_wrapper_for_iwplot_svyp (if installed)" "excel_wrapper_for_iwplot_svyp"}{...}
{vieweralsosee "Help twoway" "twoway"}{...}
{vieweralsosee "Help graph export" "graph export"}{...}
{viewerjumpto "Description" "iwplot_svyp##description"}{...}
{viewerjumpto "Required Input" "iwplot_svyp##inputdata"}{...}
{viewerjumpto "Optional Input" "iwplot_svyp##optional"}{...}
{viewerjumpto "Examples" "iwplot_svyp##examples"}{...}
{viewerjumpto "Author" "iwplot_svyp##author"}{...}
{viewerjumpto "Related Commands" "iwplot_svyp##related"}{...}
{title:Title}

{phang}
{bf:iwplot_svyp} {hline 2} Inchworm plots for survey-estimated proportions 

{marker syntax}{...}
{title:Syntax}

{cmdab:iwplot_svyp} {help iwplot_svyp##inputdata:INPUTdata}(string) 
{pmore} [{it:{help iwplot_svyp##command_lines1:NL}(real 50)} {help iwplot_svyp##command_lines1:XTITLE}(string)} {help iwplot_svyp##command_lines1:YTITLE}(string)} {p_end}
{pmore} {it:{help iwplot_svyp##command_lines1:TITLE}(string asis) {help iwplot_svyp##command_lines1:SUBtitle}(string asis) {help iwplot_svyp##command_lines1:NOTE}(string asis)} {p_end}
{pmore} {it:{help iwplot_svyp##command_lines2:XAXISRANGE}(numlist) {help iwplot_svyp##command_lines2:XSIZE}(real 10) {help iwplot_svyp##command_lines2:YSIZE}(real 10)} {p_end}
{pmore} {it:{help iwplot_svyp##VERlinesdata:VERlinesdata}(string) {help iwplot_svyp##HORlinesdata:HORlinesdata}(string) {help iwplot_svyp##TEXTONPLOTdata:TEXTONPLOTdata}(string)} {p_end}
{pmore} {it:{help iwplot_svyp##ARROWSdata:ARROWSdata}(string) {help iwplot_svyp##command_lines3:CItext}(real 0)} {p_end}
{pmore} {it:{help iwplot_svyp##command_lines3:EQUALarea}(real 2) {help iwplot_svyp##command_lines3:POLYgon}(real 2)} {p_end}
{pmore} {it:{help iwplot_svyp##command_lines4:SAVING}(string asis) {help iwplot_svyp##command_lines4:NAME}(string asis)} {p_end}
{pmore} {it:{help iwplot_svyp##command_lines5:EXPORT}(string asis) {help iwplot_svyp##command_lines5:CLEANwork}(string) {help iwplot_svyp##command_lines5:TWOway}(string asis)}]  {p_end}	
{p 8 17 2}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Helpfile Sections}
{pmore}{help iwplot_svyp##description:Description} {p_end}
{pmore}{help iwplot_svyp##inputdata:Required Input}{p_end}
{pmore}{help iwplot_svyp##optional:Optional Input}{p_end}
{pmore}{help iwplot_svyp##examples:Examples}{p_end}
{pmore}{help iwplot_svyp##author:Author}{p_end}
{pmore}{help iwplot_svyp##related:Related Commands}{p_end}

{marker description}{...}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{title:Description}

{pstd} {cmd:iwplot_svyp} is a program used to make inchworm plots for survey-estimated proportions. In order to run this program, you will need to install the iwplot_svyp package. {p_end}

{pstd} You may acquire the files from the Stata SSC Archive.  Type ssc install {cmd:iwplot_svyp} from the Stata command line or visit the {browse "http://biostatglobal.com":Biostat Global Consulting website} to find a link to a GitHub repository. {p_end}

{pstd} The {cmd:iwplot_svyp} program creates the inchworm plot and allows for the flexibility of using the options from the {help twoway} and {help graph} commands. Different options are specified through multiple datasets or noted in the syntax. {p_end}

{pstd} Only one dataset, known as the {help iwplot_svyp##inputdata:inputdata}, is required to run the {cmd:iwplot_svyp} program. The {help iwplot_svyp##inputdata:inputdata} set must contain all the required variables noted below. {p_end}

{pstd} You may generate the {help iwplot_svyp##inputdata:inputdata} dataset using Stata or specify the values in an Excel file and call the {helpb excel_wrapper_for_iwplot_svyp}. {p_end}

	
{hline}
{marker inputdata}
{title:Required Input} 

{pstd} {bf:INPUTDATA} - Name of the dataset that summarizes {help iwplot_svyp##distribution_info:distribution_info}. {p_end}
{pmore} {bf:Example: inputdata({it:"dataset name"}).} {p_end}

{pmore} {bf: NOTE Double quotes need to used if the dataset path or name include spaces.} {p_end}
{marker distribution_info}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:distribution_info} 

{pstd} This section contains the {bf:only} data {it:{red:required}} to run the {cmd:iwplot_svyp} program. The dataset includes one row or observation for each distribution that will appear in the plot.  Note below that some variables in this section are required and some are optional.  {p_end}

{pmore} {bf: NOTE This dataset should be listed as the filename for your inputdata syntax.} {p_end}
{pmore} {bf: Example: If your dataset containing this information is named {it:distribution_info}, then specify:} {p_end}

{pmore3} {it: iwplot_svyp, inputdata("distribution_info")}


{pstd} {opt source} ({it:string}) {red:Required}- Can take on the value of either {bf:ESS} or {bf:DATASET}; this may vary by row {p_end}
{pmore} Indicates how the program will get the data to create the plot. {p_end}

{pmore2}	{bf:1. ESS - Effective sample size is provided in param1.} {p_end}
{pmore2}	{bf:2. DATASET - Path and name of survey dataset is provided in param4 and used to estimate the proportion.} {p_end}


{pstd} {opt param1} ({it:integer}) {red:Required if source is ESS} - Effective sample size (ESS) 

{pstd} {opt param2} ({it:numerical}) {red:Required if source is ESS} - Estimated survey proportion, expressed as a percent: takes values from 0 to 100

{pstd} {opt param3} ({it:string}) - Name of the method to use for estimating confidence intervals;  Any value accepted by the svyp program is allowable here. {bf:(Wilson by default)} {p_end}
{pmore} {bf:NOTE Options currently include Clopper, Wilson, or Logit.} {p_end}

{pstd} {opt param4} ({it:string}) {red:Required if source is DATASET} - Path and name of the survey dataset to be used to estimate the proportion {p_end}

{pstd} {opt param5} ({it:string}) {red:Required if source is DATASET} - Name of the variable whose proportion is being estimated {p_end}

{pstd} {opt param6} ({it:string}) {red:Required if source is DATASET} - Svyset command to be issued before estimating the proportion {p_end}

{pstd} {opt param7} ({it:string}) {red:Required if source is DATASET} - Stata 'if' syntax to restrict the estimation to the domain (subpopulation) of interest {p_end}

{pmore} {bf:Example: if stratum == 1 (for Stratum 1)} {p_end}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{pstd} {opt rightsidetext} ({it:string}) - Custom text to put on the right hand side instead if CI text. {p_end}
{pmore} {bf:NOTE If the user specifies {it:CITEXT}, the rightsidetext option trumps the CITEXT value.  Only one rightsidetext value can be specified for each rownumber.} {p_end}
{pmore} {bf:If there is more than one distribution on any row of the plot (two distributions have the same rownumber) and the rightsidetext differs for each distribution,} {p_end}
{pmore} {bf:the value specified last (in the later row or observation of the inputdata dataset) because the program does not know which value to use. The same rule applies to {it:CITEXT}}. {p_end}
{pmore} {bf:However, if the {it:CITEXT} is turned off due to value conflict and the rightsidetext is used correctly, one value per rownumber, the rightsidetext function will work.} {p_end}

{pstd} {opt rowname} ({it:string}) - Row labels which will be displayed on left side of the plot. {bf:(_n by default)}{p_end}
{pmore} {bf: NOTE Be sure not to list conflicting rownames if you put more than one distribution on a row; the program sorts the dataset by rownumber and only pays attention to the last rowname defined foreach rownumber.} {p_end}

{pstd} {opt rownumber} ({it:numerical}) - Row number (y-coordinate) the distribution is centered on.. {bf:(_n by default)} {p_end}
{pmore} {bf:NOTE Row 1 is the bottom row.} {p_end}

{pstd} {opt outlinecolor} ({it:string}) - {bf:lcolor} valid Stata color for outline {bf:(black by default)} (See {help colorstyle}) {p_end}

{pstd} {opt outlinewidth} ({it:string}) - {bf:lwidth} valid Stata line width {bf:(vvthin by default)} (See {help linewidthstyle}) {p_end}

{pstd} {opt outlinepattern} ({it:string}) - {bf:lpattern} valid Stata line pattern {bf:(solid by default)} (See {help linepatternstyle}) {p_end}

{pstd} {opt outlinestyle} ({it:string}) - {bf:lstyle} valid Stata line style {bf:(foreground by default)} (See {help linestyle}) {p_end}

{pstd} {opt areacolor} ({it:string}) - {bf:color} valid Stata color for area {bf:(none by default)} (See {help colorstyle}) {p_end}

{pstd} {opt areaintensity} ({it:numerical}) - valid Stata intensity for area (0-100) {bf:(100 by default)} {p_end}
{pmore} Use this option if you would like the color to be darker or lighter than the stata color. (See {help intensitystyle}) {p_end}

{pstd} {opt markvalue} ({it:numerical}) - Percentile at which to show a vertical tick for reference (0-100). {p_end}
{pmore} {bf:NOTE It should be left blank if no vertical tick is needed.} {p_end}    
{pstd} {opt markvaluecolor} ({it:string}) - valid Stata color for vertical tick {bf:(none by default)}  (See {help colorstyle}) {p_end}

{pstd} {opt clip} ({it:numerical}) - Width of the CI at which to clip the graphic distribution {it:(usually 95)}. {p_end}
{pmore} {bf:NOTE This value has to be missing or between 0.01 and 99.9.} {p_end}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{pstd} {opt lcb} ({it:numerical}) - Percent of confidence that should fall above the LCB ({it:usually 95}). {p_end}
{pmore} {bf:NOTE This value should be missing or between 51 - 99.9. If it is missing, the lcb tick will not appear.} {p_end}

{pstd} {opt lcbcolor} ({it:string}) - valid Stata color for lcb tick {bf:(none by default)} (See {help colorstyle}) {p_end}

{pstd} {opt ucb} ({it:numerical}) - Percent of confidence should fall below the UCB ({it:usually 95}). {p_end}
{pmore} {bf:NOTE This value should be missing or between 51 - 99.9. If it is missing, the ucb tick will not appear.} {p_end}

{pstd} {opt ucbcolor} ({it:string}) - valid Stata color for ucb tick {bf:(none by default)} (See {help colorstyle}){p_end}

{pstd} {opt shadebehind} ({it:string}) - valid Stata color for shaded line behind row {bf:(none by default)} (See {help colorstyle}) {p_end}
{pmore} {bf:NOTE If not missing, there will be a shaded line behind the row specified. This is used to draw the eye to this row. ({it:Often used to hightlight the aggregate level results})} {p_end}
{pmore} {bf:If it is missing, the plot will not have a shaded line behind the distribution.} {p_end}

{pmore} {bf:NOTE Caution is needed if you put more than one distribution on a row. If any of the distributions specify a shadebehind color, then the row will be shaded.}{p_end}
{pmore} {bf:The program sorts the dataset by rownumber and uses the last shadebehind color listed per rownumber.} {p_end}

{hline}
{marker optional}
{title:Optional Input}

{pstd} The options under this section allow you to have more control over how the plot looks and is saved. Each is {it:optional}.  {p_end}

{pstd} {bf:NOTE Certain options specify the names of datasets.  If you choose to use that option, then certain variables are {it:required}. The required variables are noted in each section below.} {p_end}
{marker command_lines1}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:command line options} 

{pstd} The command line options specify how the plot should be created and saved. Appropriate syntax for each option is provided below. {p_end}

{pstd} Please reference {help twoway} to see valid values for each option listed below. {p_end}

{pstd} {opt nl} ({it:numerical}) - Number of points at which to calculate the shape of the top of each distribution. {bf:(50 is the default)} {p_end}
{pmore} Typical values are any number between 5 and 50.  Smaller values run faster but result in coarse distributions.  Use a value like 50 for a finished product. {p_end}

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:nl(50)}} 

{pstd} {opt xtitle} ({it:string}) - {bf:title} for X axis (See {help title_options})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:xtitle("Example-X")}} 

{pstd} {opt ytitle} ({it:string}) - {bf:title} for Y axis (See {help title_options})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:ytitle("Example-Y")}} 

{pstd} {opt title} ({it:string}) - {bf:title} at the top of the plot (See {help title_options})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:title("TitleExample")}} 

{pstd} {opt subtitle} ({it:string}) - {bf:subtitle} at the top of the plot (See {help title_options})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:subtitle("SubTitleExample")}}

{pstd} {opt note} ({it:string}) - {bf:note} at the bottom of the plot, also known as {it:footnote} (See {help title_options})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:note("Plot Note Example")}} {p_end}
{marker command_lines2}
{pstd} {opt xaxisrange} ({it:numerical}) - {bf:range} from minimum to maximum for X axis) (See {help axis_scale_options}) {p_end}
{pmore} {bf:NOTE If xaxisrange is left blank then program will create a range based on minimum and maximum values of X}	{p_end}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:xaxisrange(0 100)}}

{pstd} {opt xsize} ({it:numerical}) - {bf:xscale} (how x axis looks) {bf:(10 is the default)} (See {help axis_scale_options}) {p_end}

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:xsize(15)}}

{pstd} {opt ysize} ({it:numerical}) - {bf:yscale} (how y axis looks) {bf:(10 is the default)} (See {help axis_scale_options}) {p_end}

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:ysize(15)}} {p_end}
{marker command_lines3}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{pstd} {opt citext} ({it:numerical}) Can take on a value of 0, 1, 2, 3, 4 or 5 {bf:(0 is the default)} {p_end} 
{pmore} Indicates which standard text will appear on the plot. The below list shows which text corresponds with each value. {p_end} 
{pmore2} 		{bf:0) CITEXT is blank} {p_end}
{pmore2} 		{bf:1) one-sided 95% LCB, p, one-sided 95% UCB} {p_end}
{pmore2}		{bf:2) p (95%CI)} {p_end}
{pmore2}		{bf:3) p (95%CI) (0, 1-sided 95% UCB)} {p_end}
{pmore2}        	{bf:4) p (95%CI) (1-sided 95% LCB, 100)} {p_end}
{pmore2}        	{bf:5) p (95%CI) (1-sided 95% LCB, 100) (0, 1-sided 95% UCB)} {p_end}

{pmore} {bf:NOTE If you put more than one distribution on any row of the plot (two distributions have the same rownumber) then CITEXT will be turned {it:off}} {p_end}
{pmore} {bf:regardless of what you have asked for in either row. If you show more than one distribution per row, the {it:{cmd:iwplot_svyp}} program doesn't which one to summarize, so it doesn't summarize any at all.} {p_end}

{pmore} {bf:NOTE If you specify the {it:rightsidetext} variable, then the CITEXT value is overwritten with the text from {it:rightsidetext} for that particular row.} {p_end}   

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:CITEXT(5)}} {p_end}

{pstd} {opt equalarea} ({it:numerical}) Can take on a value of 1 or 2 {bf:(2 is the default)} {p_end}
{pmore} Determines the distribution of the plot. The descriptions for each value are below: {p_end}

{pmore2}		{bf:1) Distributions will not be re-scaled; their coordinates will be set up so they are equal-area under the so-called stair-step polygon,}{p_end}
{pmore3}			{bf:	which does not take triangles into account and is not constrained to be a strictly-increasing polygon.} {p_end}
{pmore2}		{bf:2) Distributions will be scaled to be equal-area under the so-called smooth bounding polygons that include triangles and are constrained to not decrease in height as the distribution approaches the point estimate.} {p_end}

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:equalarea(1)}} {p_end}

{pstd} {opt polygon} ({it:numerical}) Can take on a value of 1, 2, or 3 ({bf:2 is the default}) {p_end}
{pmore} Determines how the polygons will be shown in the plot. {p_end}

{pmore2}		{bf:1) The plots will only show the stair-step polygons ({it:this is mostly a debug option})} {p_end}
{pmore2}		{bf:2) The plots will show smooth bounding ploygons.} {p_end}
{pmore2} 		{bf:3) The plots will show BOTH the stair-step and smooth bounding polygons.} {p_end}

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:polygon(3)}} {p_end}

{marker command_lines4}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{pstd} {opt saving} ({it:string}) - Name of gph file to be saved in working directory (See {help saving_option}) {p_end}
{pmore} This image can be edited later at any time in graph editor or using {help addplot_option} command.{p_end}
{pmore} {bf: Example: file123, replace}

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:saving("Example graph Saving",replace)}} {p_end}

{pstd} {opt name} ({it:string}) - Name of the graph in Stata memory (See {help name}) {p_end}
{pmore} If you are creating multiple graphs, this will enable you to identify which graph is which on the Stata screen. {p_end}

{pmore} {bf:NOTE You must specify the {it:replace} option with both SAVING and NAME if you would like to replace graphs that already exist with this filename in the working directory.} {p_end}

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:name("Example graph name",replace)}} {p_end}

{marker command_lines5}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{pstd} {opt export} ({it:string}) - Name and suffix of the plot to be saved in working directory (See {help graph export}) {p_end} 
{pmore} {bf:NOTE If this option is left blank then plot will only be saved as a gph image (ex. graph1.png or graphBA_12.pdf)}. {p_end}
{pmore} {bf:You must specify the {it:replace} option if you would like to replace graphs that already exist with this filename in the working directory.} {p_end}
{pmore} {bf:Look at each file type options to see if there are other export options you would like to specify. {it:Example: You may be able to set width and height.}} {p_end}

{pmore} {bf:Possible suffixes:} {p_end}
{pmore2}		{bf:1. ps (PostScript)} (See {help ps_options}) {p_end}
{pmore2}		{bf:2. eps(Encapsulated PostScript)} (See {help eps_options}) {p_end}
{pmore2}		{bf:3. wmf (Windows Metafile)} {p_end}
{pmore2}		{bf:4. emf (Windows Enhanced Metafile)} {p_end}
{pmore2}		{bf:5. pdf (PDF)} {p_end}
{pmore2}		{bf:6. png (Portable Network Graphics)} (See {help png_options}) {p_end}
{pmore2}		{bf:7. tif (TIFF)} (See {help tif_options}) {p_end}

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:export("Example graph Export.png", width(2000) replace)}} {p_end}

{pstd} {opt twoway} ({it:string}) - Allows the user to add any additional options found under {help twoway} graphs that are not included in the dataset. {p_end}
{pmore} Add the appropriate syntax as the value for the twoway variable for the desired option(s). {p_end}


{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:twoway(list {help twoway} options here)}} {p_end}

{pstd} {opt cleanwork} ({it:string}) - Can take a value of blank or YES ({bf:blank is the default}) {p_end}
{pmore} Used to specify if all datasets created by the program will be saved in working directory or deleted.

{pmore2}		{bf:1. YES - all datasets created by the program will be {it:deleted} from working directory, it should keep working directory clean, {it:recommended option}.} {p_end}
{pmore2}		{bf:2. blank- All datasets created by the program will be {it:kept} in the working directory.} {p_end}


{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:cleanwork(YES)}} {p_end}

{marker TEXTONPLOTdata}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:TEXTONPLOTdata} 

{pstd} The {bf:TEXTONPLOTdata} dataset is used to overlay text on plot.{p_end}
{pstd} Please reference {help added_text_options} or {help textbox_options} under {help twoway} to see the different options. {p_end}


{pstd}{opt textonplot} ({it:string}) {red:Required} - {bf:text} that will appear on the plot in the textbox (See {help added_text_options})

{pstd}{opt xcoordtext} ({it:numerical})	{red:Required} - {bf:xaxis} coordinate where the textbox will start on the graph (See {help added_text_options})

{pstd}{opt ycoordtext} ({it:numerical})	{red:Required} - {bf:yaxis} coordinate where the textbox will start on the graph (See {help added_text_options})

{pstd}{opt colortext} ({it:string}) 	 - {bf:fcolor} of text {bf:(black is the default)} (See {help colorstyle}) 

{pstd}{opt fontsizetext}({it:numerical}) - {bf:size} of text {bf:(1 is the default)} (See {help textsizestyle})

{pstd}{opt orientation} ({it:string})	 - {bf:orientation} of textbox {bf:(horizontal is the default)} (See {help orientationstyle})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:textonplot("dataset_holding_textonplot_variables")}} {p_end}

{pmore} {bf:NOTE It is possible to add as many text annotations as desired. A separate row will need to be added to the dataset for each textbox.} {p_end}
	
{marker ARROWSdata}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:ARROWSdata} 

{pstd} The {bf:ARROWSdata} dataset is used to add arrows to the plot.{p_end}
{pstd} Please reference {help twoway pcarrow} under {help twoway} to see the different options.{p_end}


{pstd} {opt xcoordend} ({it:numerical}) {red:Required} - {bf:x} coordinate where the arrow will end on the graph (See {help twoway pcarrow})

{pstd} {opt ycoordend} ({it:numerical}) {red:Required} - {bf:y} coordinate where the arrow will end on the graph (See {help twoway pcarrow})

{pstd} {opt xcoordtip} ({it:numerical}) {red:Required} - {bf:x} coordinate where the arrow will start on the graph (See {help twoway pcarrow})

{pstd} {opt ycoordtip} ({it:numerical}) {red:Required} - {bf:y} coordinate where the arrow will start on the graph (See {help twoway pcarrow})

{pstd} {opt arrowcolor} ({it:string})	 - {bf:mcolor} for arrow {bf:(black is the default)} (See {help colorstyle})   

{pstd} {opt arrowwidth} ({it:string}) 	 - {bf:lstyle} for arrow {bf:(vvthin is the default)} (See {help linewidthstyle})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:arrowdata("arrowdata")}} {p_end}

{pmore} {bf:NOTE It is possible to add as many arrows as desired. A separate row will need to be added to the dataset for each arrow.} {p_end}
{marker HORlinesdata}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:HORlinesdata} 

{pstd} The {bf:HORlinesdata} dataset is used to overlay horizontal lines on the plot.{p_end}
{pstd} Please reference {help added_line_options} under {help twoway} to see the different options. {p_end}


{pstd} {opt ycoord} ({it:numerical}) {red:Required} - {bf:yline} coordinate where the line will show on the graph (See {help added_line_options})

{pstd} {opt xstart} ({it:numerical}) {red:Required} - {bf:xline} coordinate where the line will start (See {help added_line_options})

{pstd} {opt xstop} ({it:numerical}) {red:Required} - {bf:xline} coordinate where the line will stop (See {help added_line_options})

{pmore} {bf:NOTE If xstart and xstop are missing then the horizontal line is drawn across whole chart}

{pstd} {opt color} ({it:string}) - {bf:lcolor} of the line {bf:(black is the default)} (See {help colorstyle}) 

{pstd} {opt width} ({it:string}) - {bf:lwidth} of the line {bf:(vvthin is the default)} (See {help linewidthstyle}) 

{pstd} {opt style} ({it:string}) - {bf:lstyle} of the line {bf:(solid is the default)} (See {help linestyle})

{pstd} {opt pattern} ({it:string}) - {bf:lpattern} of the line (See {help linepatternstyle})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:horlinesdata("horizontal_line_data")}} {p_end}

{pmore} {bf:NOTE It is possible to add as many horizontal lines as desired. A separate row will need to be added to the dataset for each horizontal line.} {p_end}

{marker VERlinesdata}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:VERlinesdata} 

{pstd} The {bf:VERlinesdata} dataset is used to overlay veritcal lines on the plot.{p_end}
{pstd} Please reference {help added_line_options} under {help twoway} to see the different options.{p_end}


{pstd} {opt xcoord} ({it:numerical}) {red:Required} - {bf:xline} coordinate where the line will show on the graph (See {help added_line_options})

{pstd} {opt ystart} ({it:numerical}) {red:Required} - {bf:yline} coordinate where the line will start (See {help added_line_options})

{pstd} {opt ystop} ({it:numerical}) {red:Required} - {bf:yline} coordinate where the line will stop (See {help added_line_options})

{pmore} {bf:NOTE If ystart and ystop are missing then the veritcal line is drawn across whole chart}

{pstd} {opt color} ({it:string}) - {bf:lcolor} of the line {bf:(black is the default)} (See {help colorstyle}) 

{pstd} {opt width} ({it:string}) - {bf:lwidth} of the line {bf:(vvthin is the default)} (See {help linewidthstyle}) 

{pstd} {opt style} ({it:string}) - {bf:lstyle} of the line {bf:(solid is the default)} (See {help linestyle})

{pstd} {opt pattern} ({it:string}) - {bf:lpattern} of the line (See {help linepatternstyle})

{pmore3} {bf: Syntax:} {it:iwplot_vcqi, inputdata("distribution_info")} {bf:{red:verlinesdata("vertical_line_data")}} {p_end}

{pmore} {bf:NOTE It is possible to add as many veritcal lines as needed. A separate row will need to be added to the dataset for each vertical line.} {p_end}



{hline}

{marker examples}{...}
{title:Examples}

{marker author}{...}
{title:Authors}
{p}

Dale Rhoda & Yulia Fungard, Biostat Global Consulting

Email {browse "mailto:Dale.Rhoda@biostatglobal.com":Dale.Rhoda@biostatglobal.com}

Website {browse "http://biostatglobal.com": http://biostatglobal.com} 

{hline}
{marker related}
{title:Related commands}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{help excel_wrapper_for_iwplot_svyp}
{help twoway} 	
{help graph export} 

{title:Other Helpful Commands}
{help macro}			{help colorstyle}			
{help linewidthstyle}		{help linepatternstyle}	
{help linestyle}		{help intensitystyle}
{help axis_scale_options}	{help numlist}						
{help title_options}		
