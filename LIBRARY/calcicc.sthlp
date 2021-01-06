{smcl}
{* *! version 1.1 04 Dec 2020}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Description" "iccloop##description"}{...}
{viewerjumpto "Required Input" "iccloop##inputdata"}{...}
{viewerjumpto "Optional Input" "iccloop##optional"}{...}
{viewerjumpto "Examples" "iccloop##examples"}{...}
{viewerjumpto "Author" "iccloop##author"}{...}
{title:Title}

{phang}
{bf:iccloop} {hline 2} Calculate intracluster correlation coefficient from clustered data - allows negative ICCs

{marker syntax}{...}
{title:Syntax}

{cmdab:calcicc} outcome_var clusterid_var

{p 8 17 2}

{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd} {cmd:calcicc} is a program used to calculate intracluster correlation 
   coefficient (ICC) using the ANOVA method of estimation that Stata employs in
   its {cmd:loneway} command.  {cmd:calcicc} is a modification of loneway in
   that it does NOT truncate the value of ICC at zero.  If the estimated value
   is smaller than zero, calcicc returns the negative number.  By contrast, if 
   the estimated ICC is negative, loneway returns a value of zero.{p_end}
   
{pstd}  {cmd:calcicc} is used inside VCQI and in the program {cmd: iccloop} 
   which is being distributed to collaborators to extract survey planning 
   parameters from vaccination coverage cluster survey datasets to be included 
   in a 2021 manuscript being coordinated by Dale Rhoda at Biostat Global 
   Consulting. {p_end}

{pstd}  {cmd:iccloop} uses a bootstrap approach to calculate a 95% confidence
   interval for ICC, so {cmd:calcicc} does not return any values except the ICC. 
   {p_end}   
   
{pstd}The ANOVA method of estimating ICC is documented in the PDF help for 
   {cmd:loneway} and is cited in numerous papers that list ICC values for 
   planning group-randomized trials (sometimes called cluster-randomized 
   trials). One notable place where the method is described and employed is: 
   Ridout, M.S., Demetrio, C.G. and Firth, D., 1999. 
   Estimating intraclass correlation for binary data. 
   {it:Biometrics}, 55(1), pp.137{c -}148.{p_end} 


{hline}

{marker author}{...}
{title:Authors}
{p}

Dale Rhoda, Biostat Global Consulting

Email {browse "mailto:Dale.Rhoda@biostatglobal.com":Dale.Rhoda@biostatglobal.com}

{hline}
		
