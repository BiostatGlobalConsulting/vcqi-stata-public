{smcl}
{* *! version 1.1 04 Dec 2020}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Description" "vcqi_ri_dose_assertlist##description"}{...}
{viewerjumpto "Required Input" "vcqi_ri_dose_assertlist##inputdata"}{...}
{viewerjumpto "Optional Input" "vcqi_ri_dose_assertlist##optional"}{...}
{viewerjumpto "Examples" "vcqi_ri_dose_assertlist##examples"}{...}
{viewerjumpto "Author" "vcqi_ri_dose_assertlist##author"}{...}
{title:Title}

{phang}
{bf:vcqi_ri_dose_assertlist} {hline 2} Check routine immunization dose data for logical inconsistencies

{marker syntax}{...}
{title:Syntax}

{cmdab:vcqi_ri_dose_assertlist} 

{p 8 17 2}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd} {cmd:vcqi_ri_dose_assertlist} is a program used for logical inconsistencies
   in routine immunization (RI) survey data that has been formated to be consistent
   with the World Health Organization's Vaccination Coverage Quality Indicators
   {browse "www.biostatglobal.com/VCQI_RESOURCES.html":VCQI}.
   It uses the companion program named {cmd:assertlist} and 
   makes a list of individuals whose vaccination evidence data exhibit one
   or more problems.{p_end}
   
{pstd}The program performs these checks:{p_end}
{pmore}1.	Date of birth should be sensical if populated{p_end}
{pmore}2.	Interview date should be sensical if populated{p_end}
{pmore}3.	Date of birth should be before interview date {p_end}
{pmore}4.	Dose date should be sensical if populated{p_end}
{pmore}5.	Dose date should be ≥ date of birth {p_end}
{pmore}6.	Dose date should be ≤ interview date{p_end}
{pmore}7.	Doses in a series should not use the same date{p_end}
{pmore}8.	Doses in a series should appear in order{p_end}
			
{pstd}Observations that fail these checks will be documented in an Excel 
      spreadsheet named vcqi_ri_dose_date_assertions.xlsx.{p_end}
	  
{pstd} Important!  {cmd:vcqi_ri_dose_assertlist} requires that you have 
   downloaded the program assertlist and put it in your Stata adopath.  Type 
   the command 'which assertlist'.  If it does not find the command, download
   it from the {browse "https://github.com/BiostatGlobalConsulting/assertlist":Biostat Global Consulting assertlist Github site}.{p_end}
   
{pstd} Important! In order to run this command your Stata session should have 
   already defined some scalars and globals that are typically found in a
   VCQI RI control program.  These include:{p_end}
{pstd}- RI_SINGLE_DOSE_LIST, RI_MULTI_2_DOSE_LIST, and RI_MULTI_3_DOSE_LIST {p_end}
{pstd}- The vaccination schedule min_age scalars for all doses defined in those DOSE_LISTS. {p_end}
{pstd}- e.g., bcg_min_age_days, penta1_min_age_days, penta2_min_age_days, etc. {p_end}
{pstd}- VCQI_DATA_FOLDER {p_end}
{pstd}- VCQI_OUTPUT_FOLDER {p_end}
{pstd}- VCQI_RI_DATASET {p_end}
{pstd}- VCQI_RIHC_DATASET (optional) {p_end}
{pstd}- EARLIEST_SVY_VACC_DATE_M, _D, and _Y {p_end}
{pstd}- LATEST_SVY_VACC_DATE_M,   _D, and _Y {p_end}
{pstd}- RI_RECORDS_SOUGHT_FOR_ALL, RI_RECORDS_SOUGHT_IF_NO_CARD, RI_RECORDS_NOT_SOUGHT {p_end}
{pstd} {p_end}
{pstd}For examples of how to populate these parameters, see the template RI 
   control program in your VCQI Stata source distribution and see the VCQI User's Guide.
   Both are available in the vcqi-stata-public Github repository at the 
   {browse "https://github.com/BiostatGlobalConsulting/vcqi-stata-public":Biostat Global Consulting VCQI Github site}.{p_end}
   
{hline}

{marker author}{...}
{title:Authors}
{p}

Mary Kay Trimner & Dale Rhoda, Biostat Global Consulting

Email {browse "mailto:Dale.Rhoda@biostatglobal.com":Dale.Rhoda@biostatglobal.com}

{hline}
		
{title:See Also}
{help assertlist}
