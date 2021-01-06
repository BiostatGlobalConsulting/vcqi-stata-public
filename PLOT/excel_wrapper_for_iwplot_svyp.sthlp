{smcl}
{...}
{...}
{* *! excel_wrapper_for_iwplot_svyp.sthlp version 1.00 - Biostat Global Consulting - 2016-02-18}{...}
{* Change log: }{...}
{* 				Updated}{...}
{*				version}{...}
{* Date 		number 	Name			What Changed}{...}
{* 2016-02-18	1.00	Dale Rhoda		Original version}{...}
{* xxxx-xx-xx	1.0x	<name>			<comment>}{...}
{...}
{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install iwplot_svyp" "ssc install iwplot_svyp"}{...}
{vieweralsosee "Help iwplot_svyp (if installed)" "iwplot_svyp"}{...}
{vieweralsosee "Help twoway (if installed)" "twoway"}{...}
{vieweralsosee "Help graph export (if installed)" "graph export"}{...}
{viewerjumpto "Description" "excel_wrapper_for_iwplot_svyp##description"}{...}
{viewerjumpto "Required Input" "excel_wrapper_for_iwplot_svyp##inputdata"}{...}
{viewerjumpto "Optional Input" "excel_wrapper_for_iwplot_svyp##optional"}{...}
{viewerjumpto "Examples" "excel_wrapper_for_iwplot_svyp##examples"}{...}
{viewerjumpto "Author" "excel_wrapper_for_iwplot_svyp##author"}{...}
{viewerjumpto "Related Commands" "excel_wrapper_for_iwplot_svyp##related"}{...}
{title:Title}

{phang}
{bf:excel_wrapper_for_iwplot_svyp} {hline 2} Program used to create datasets from an excel template that are necessary to run the {helpb iwplot_svyp} program. {p_end}

{pmore2} {helpb iwplot_svyp} -Creates inchworm plots for survey-estimated proportions. {p_end}

{marker syntax}{...}
{title:Syntax}

{cmdab:excel_wrapper_for_iwplot_svyp} "{help excel_wrapper_for_iwplot_svyp##inputdata:INPUTDATA}"(string) 

{pmore2} {bf: Example: {cmd:excel_wrapper_for_iwplot_svyp} {it:"excel_wrapper_data.xlsx"}}

{p 8 17 2}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Helpfile Sections}
{pmore}{help excel_wrapper_for_iwplot_svyp##description:Description} {p_end}
{pmore}{help excel_wrapper_for_iwplot_svyp##inputdata:Required Input}{p_end}
{pmore}{help excel_wrapper_for_iwplot_svyp##optional:Optional Input}{p_end}
{pmore}{help excel_wrapper_for_iwplot_svyp##examples:Examples}{p_end}
{pmore}{help excel_wrapper_for_iwplot_svyp##author:Author}{p_end}
{pmore}{help excel_wrapper_for_iwplot_svyp##related:Related Commands}{p_end}

{marker description}{...}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{title:Description}

{pstd} {cmd:excel_wrapper_for_iwplot_svyp} is a program that can be used with {helpb iwplot_svyp} to make inchworm plots for survey-estimated proportions. In order to run this program, you will need to install the iwplot_svyp package.{p_end}

{pstd} You may acquire the files from the Stata SSC Archive.  Visit the {browse "http://biostatglobal.com":Biostat Global Consulting website} to find a link to a GitHub repository. {p_end}

{pstd} The standardized template for {cmd: excel_wrapper_for_iwplot_svyp} is also available on the {browse "http://biostatglobal.com":Biostat Global Consulting website} GitHub repository page, titled {bf:iwplot_svyp_template}.{p_end}
{pstd} The template contains the 6 tabs {it:required} for this wrapper to work with {helpb iwplot_svyp}. {p_end}

{pmore} {bf: NOTE It is {ul:important} for all 6 tabs to remain on the template even if the data is blank. If any tabs are {ul:missing} it will cause the program to error.} 

{pstd} The six tabs that make up {bf:iwplot_svyp_template} correspond to the required and optional datasets/options for the {helpb iwplot_svyp} program. They are as follows: distribution_info, command_lines, textbox, arrows, horizontal_lines and vertical_lines.{p_end}

{title:How the wrapper works}

{pstd} Just like in {helpb iwplot_svyp}, {cmd:excel_wrapper_for_iwplot_svyp} allows for the flexibility of using the options from the {help twoway} and {help graph} commands. {p_end}
{pstd} However, rather than the options being specified through multiple datasets or noted in the syntax, they are populated on the appropriate tab in the {bf:iwplot_svyp_template}. {p_end} 
{pstd} {cmd:excel_wrapper_for_iwplot_svyp} takes the data within the spreadsheet provided and creates the datasets necessary to run {helpb iwplot_svyp}. {p_end}

{pstd} After {cmd: excel_wrapper_for_iwplot_svyp} has created the datasets, it then runs {cmd:iwplot_svyp} to create the inchworm plot(s) according to your specifications. {p_end}

{pstd} {help iwplot_svyp##distribution_info:Distribution_info} is the {bf:only} tab that must be populated to run this program. The other tabs add additional features to the plot and only need to be populated if you wish to utilize that specific function. {p_end}

	
{hline}
{marker inputdata}
{title:Required Input} 

{pstd} {bf:INPUTDATA} - Name of the dataset that contains all 6 tabs from {bf:iwplot_svyp_template} and are populated with all the data need to run {cmd:iwplot_svyp}. {p_end}
{pmore} {bf:Example: inputdata({it:"iwplot_svyp_data1"}).} {p_end}

{pmore} {bf: NOTE Double quotes need to be around the name of the dataset.} {p_end}
{marker distribution_info}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:distribution_info} 

{pstd} The distribution_info tab is the {bf:only} tab that must contain some data to run both the {cmd: excel_wrapper_for_iwplot_svyp} and {helpb iwplot_svyp} program. {p_end}
{pstd} However, not all of the variables in the spreadsheet are {red:required}. {p_end}

{pmore} {bf:Please reference {help iwplot_svyp##distribution_info:distribution_info} for the specific requirements regarding this tab.} 

{hline}
{marker optional}
{title:Optional Input}

{pstd} The options under this section allow you to have more control over how the plot looks and is saved. Each of these tabs are {it:optional} and not required.  {p_end}

{pmore} {bf:NOTE Even though the tabs are optional, certain variables are {it:required} if you wish to utilize that specific function. The required variables will be noted in each section below.} {p_end}
{marker command_lines}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:command_lines} 

{pstd} The {bf:command_lines} tab creates the dataset that passes through values to specify the non dataset options in {helpb iwplot_svyp}.{p_end}

{pmore} Rather than having to list them out in the {helpb iwplot_svyp} sytnax, the {cmd:excel_wrapper_for_iwplot_svyp} program takes the values from the excel sheet and populates the {helpb iwplot_svyp} syntax appropriately. {p_end}

{pmore}{bf:NOTE This tab can be populated with as many rows as desired. Each row will create a new graph with the row specific features using the data found on the {help excel_wrapper_for_iwplot_svyp##distribution_info:distribution_info},} 
{bf:{help excel_wrapper_for_iwplot_svyp##textbox:textbox}, {help excel_wrapper_for_iwplot_svyp##arrows:arrows}, {help excel_wrapper_for_iwplot_svyp##horizontal_lines:horizontal_lines} and}
{bf:{help excel_wrapper_for_iwplot_svyp##vertical_lines:vertical_lines} tabs.} {p_end}

{pmore} {bf:Please reference {help iwplot_svyp##command_lines1:command_lines} for specific requirements regarding this tab.}{p_end}
{marker textbox}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:textbox}

{pstd} The {bf:textbox} tab creates the dataset used by {helpb iwplot_svyp} to add text on the plot.{p_end}

{pmore} {bf:Please reference {help iwplot_svyp##TEXTONPLOTdata:TEXTONPLOTdata} for specific requirements regarding this tab.} {p_end}
{marker arrows}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:arrows}

{pstd} The {bf:arrows} tab creates the dataset used by {helpb iwplot_svyp} to add arrows on the plot.{p_end}

{pmore} {bf:Please reference {help iwplot_svyp##ARROWSdata:ARROWSdata} for specific requirements regarding this tab.} {p_end}
{marker horizontal_lines}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:horizontal_lines} 

{pstd} The {bf:horizontal_lines} tab creates the dataset used by {helpb iwplot_svyp} to horizontal lines on the plot.{p_end}

{pmore} {bf:Please reference {help iwplot_svyp##HORlinesdata:HORlinesdata} for specific requirements regarding this tab.} {p_end}
{marker vertical_lines} 
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{dlgtab:vertical_lines} 

{pstd} The {bf:vertical_lines} tab creates the dataset used by {helpb iwplot_svyp} to vertical lines on the plot.{p_end}

{pmore} {bf:Please reference {help iwplot_svyp##VERlinesdata:VERlinesdata} for specific requirements regarding this tab.} {p_end}

{hline}

{marker examples}{...}
{title:Examples}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{marker author}
{title:Author}
{p}

Mary Kay Trimner, Biostat Global Consulting

Email {browse "mailto:MaryKay.Trimner@biostatglobal.com":MaryKay.Trimner@biostatglobal.com}

Website {browse "http://biostatglobal.com": Biostat Global Consulting website} 

{hline}

{marker related}
{p 150 0 0}({it:{back:back to previous section}})  {p_end}
{title:Related commands}

{help iwplot_svyp}
{help twoway} 	
{help graph export} 

{title:Other Helpful Commands}
{help macro}			{help colorstyle}			
{help linewidthstyle}		{help linepatternstyle}	
{help linestyle}		{help intensitystyle}
{help axis_scale_options}	{help numlist}						
{help title_options}		
