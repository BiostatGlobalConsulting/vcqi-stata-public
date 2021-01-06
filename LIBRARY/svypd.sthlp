{smcl}
{...}
{...}
{* *! svypd.sthlp version 1.03 - Biostat Global Consulting - 2020-09-23}{...}
{* Change log: }{...}
{* 				Updated}{...}
{*				version}{...}
{* Date 		number 	Name			What Changed}{...}
{* 2016-02-18	1.00	Dale Rhoda		Original version}{...}
{* 2018-04-11	1.01	Dale Rhoda		Updated info on what program returns}{...}
{* 2020-04-22   1.02    Dale Rhoda      Allow Exact as synonym for Clopper}
{* 2020-04-22                           Also always call CLopper if stderr is 0}
{* 2020-09-23   1.03    Dale Rhoda      Clean up to send to StataCorp}
{...}
{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help svy" "help svy"}{...}
{vieweralsosee "Help proportion" "help proportion"}{...}
{vieweralsosee "Help cii" "help cii"}{...}
{viewerjumpto "Syntax" "svyp##syntax"}{...}
{viewerjumpto "Description" "svyp##description"}{...}
{viewerjumpto "Options" "svyp##options"}{...}
{viewerjumpto "Stored Results" "svyp##results"}{...}
{viewerjumpto "Examples" "svyp##examples"}{...}
{viewerjumpto "Author" "svyp##author"}{...}
{viewerjumpto "References" "svyp##references"}{...}
{viewerjumpto "Related Commands" "svyp##related"}{...}
{title:Title}

{p}
{bf:svypd} {hline 2} This command is a wrapper for Stata's {helpb svy proportion}
 command.{p_end}
 
{pstd} It handles the special case where a variable encodes a binary outcome using 
 the values 0, 1, or missing.{p_end}
 
{pstd} It estimates the proportion of the population represented by respondents coded 1.{p_end}

{pstd} Its features include options to calculate not only the logit 
confidence interval (CI), but also modified Agresti-Coull, Clopper-Pearson, Fleiss (Wilson with continuity correction), Jeffreys, Wald and Wilson
CIs.{p_end}

{pstd} For CI calculation, the user can specify whether or not to adjust for design degrees-of-freedom.{p_end}

{pstd} The user can also specify that the design effect (DEFF) should be no smaller than 1.{p_end}

{pstd} If the standard error is 0, meaning that all clusters have the same observed coverage, 
       and the user has requested Wald or Logit intervals, the program ignores the complex sampling design and 
	   returns a Clopper-Pearson interval calculated using the full sample size (assumes 
	   the design effect is 1 and degrees of freedom = N-1).{p_end}
 
{marker syntax}{...}
{title:Syntax}

{cmdab:svypd} {help varname} [{help if}] [, {help svypd##level:level}(real 95) {help svypd##cilevellist:cilevellist}(numlist) {help svypd##method:method}(string) {help svypd##adjust:ADJust} {help svypd##truncate:TRUNcate} ]

{pstd}varname is a variable that takes only the values 0 or 1 or missing.{p_end}
{p 8 17 2}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Helpfile Sections}
{pmore}{help svypd##description:Description} {p_end}
{pmore}{help svypd##options:Options}{p_end}
{pmore}{help svypd##results:Stored Results}{p_end}
{pmore}{help svypd##examples:Examples}{p_end}
{pmore}{help svypd##author:Author}{p_end}
{pmore}{help svypd##references:References}{p_end}
{pmore}{help svypd##related:Related Commands}{p_end}

{marker description}{...}
{title:Description}

{pstd}We commonly estimate the proportion of 1s in a svyset dataset variable 
and want to capture the weighted proportion as well as a 2-sided 
CI or an upper or lower 1-sided confidence limit.{p_end}

{pstd}This command is meant to address some of the limitations of Stata's svy: proportion command.{p_end}

{pstd}For several choices of citype(), the svy: proportion command does not report a meaningful CI when the sample proportion is 0 or 1 or when the standard error is 0; this command does.{p_end}

{pstd}The svy: proportion command doesn't allow values of the level() option to fall between 0 and 10; this command does.{p_end}

{pstd}The svy: proportion command calculates a CI for a single level() at a time; this command returns CIs for a vector of levels if requested (using the option cilevellist()).{p_end}

{pstd}This command allows the user to calculate several types of CI, as suggested in {help svypd##references:Korn and Graubard} and {help svypd##references:Dean and Pagano}.{p_end}
	
{hline}
{marker options}{...}
{title:Options} 
{p 150 0 0}({it:{back:back to previous section}}) {p_end}

{marker level}
{dlgtab:level} 
{pstd} {bf:level} - confidence interval (CI) level is a single numeric value between 00.01 and 99.99.  
       The program will calculate 2-sided limits for that level of confidence and, if level is > 50, 
	   it will also calculate 1-sided limits for that level of confidence.  All confidence limits are 
	   returned in a matrix named r(ci_list).{p_end}

{pmore}{bf: NOTE} The default value is 95 which will return the limits of the 2-sided 95% CI and the 
       1-sided upper- and lower-95% confidence bounds.  (Recall that the 1-sided 95% lower confidence bound 
       is the lower limit of a 2-sided 90% CI and the 1-sided 95% upper confidence bound is the upper limit 
       of the 2-sided 90% CI.){p_end}

{marker cilevellist}
{dlgtab:cilevellist} 
{pstd} {bf:cilevellist} - confidence interval (CI) level list is a list of numeric values between 00.01 and 99.99.  
       The program will calculate 2-sided limits for as many levels as you specify in the list and will return them 
       in a matrix named r(ci_list).{p_end}

{pmore}{bf: NOTE} The user may specify the level option or the cilevellist option, but not both.  
       The default is level(95) which is the same as cilevellist(95 90).{p_end}

{marker method}
{dlgtab:method} 
{pstd} {bf:method} - indicates the method by which the confidence interval(s) will be calculated. Valid options include: {p_end}

{pmore3} - Logit (default){p_end}
{pmore3} - Agresti-Coull (may be abbreviated to Agresti) {p_end}
{pmore3} - Clopper-Pearson (may be abbreviated to Clopper or to Exact){p_end}
{pmore3} - Fleiss (may be abbreviated to Wilsoncc which stands for Wilson with continuity correction){p_end}
{pmore3} - Jeffreys {p_end}
{pmore3} - Wald {p_end}
{pmore3} - Wilson {p_end}

{pmore} {bf:NOTE} The formulae for calculating most of these limits are described 
in {help svypd##references:Dean and Pagano}.  The formula for the Fleiss 
interval comes from {help svypd##references:Fleiss et al}, pages 28-29.

{marker adjust}
{dlgtab:adjust} 
{pstd} {bf:adjust} - If the user specifies the adjust option then the effective sample size for CI calculations will be 
        adjusted (diminished) to account for the design degrees of freedom in the manner discussed in 
		D&P ({help svypd##references:references}) K&G ({help svypd##references:references}).{p_end}

{marker truncate}
{dlgtab:truncate} 
{pstd} {bf:truncate} - If the user specifies the truncate option then the design effect is not allowed to go 
       below 1.0 and the effective sample size is not allowed to be larger than the actual sample size.{p_end}

{pmore}{bf: NOTE} The default is to allow the design effect to take on values below 1.0.{p_end}

{hline}
{marker results}{...}
{title:Stored Results} 
{p 150 0 0}({it:{back:back to previous section}}) {p_end}

{pstd}The program returns the following scalar values: {p_end}
{p2colset 16 35 75 2}
{p2col:r(svyp)}the estimated population proportion of 1s {p_end}
{p2col:r(stderr)}the standard error of the estimated proportion {p_end}
{p2col:r(lb_alpha)}level% (default=95%) 2-sided CI lower bound {p_end}
{p2col:r(ub_alpha)}level% (default=95%) 2-sided CI upper bound {p_end}
{p2col:r(lb_2alpha)}level% (default=95%) 1-sided lower confidence bound {p_end}
{p2col:r(ub_2alpha)}level% (default=95%) 1-sided upper confidence bound {p_end}

{p2colset 16 35 75 2}	
{p2col:r(df)}Degrees of freedom {p_end}
{p2col:r(deff)}Design Effect {p_end}
{p2col:r(neff)}Effective sample size {p_end}
{p2col:r(N)}Number of 0s & 1s in the sample proportion calculation {p_end}
{p2col:r(Nwtd)}Sum of weights for observations used in the calculation {p_end}
{p2col:r(clusters)}Number of clusters {p_end}

{pstd} The program returns two macros:{p_end}
{p2colset 16 35 75 2}
{p2col:r(cilevellist)}List of 'level' values for which CI bounds were calculated {p_end}
{p2col:r(method)}Method used to calculate the CI bounds {p_end}

{pstd} {bf:NOTE} If the user does not specify level, it is set to 95 and r(cilevellist)= "95 90"{p_end}

{pstd} {bf:NOTE} If the sample proportion is 0% or 100% or if the standard error is 0, 
        and if the user has requested a CI type that is not defined under those conditions, 
		svypd will calculate a Clopper-Pearson interval and return a value of 
		r(method) that says "Clopper-Pearson" instead of the method that the user asked for.{p_end}

{pstd} The program returns one matrix:{p_end}
{p2colset 16 35 75 2}
{p2col:r(cilist)}List of the values in r(cilevellist) and the lower and upper {p_end}
{p2col: }confidence bounds for 2-sided intervals for those values of 'level' {p_end}

{hline}
{marker author}
{title:Author}
{p}

Dale Rhoda, Biostat Global Consulting

Email: {browse "mailto:Dale.Rhoda@biostatglobal.com":Dale.Rhoda@biostatglobal.com}

Website: {browse "http://biostatglobal.com": http://biostatglobal.com} 

{hline}

{marker references}{...}
{title:References}
{p 150 0 0}({it:{back:back to previous section}}) {p_end}
{pmore}Korn, E. L. and Graubard, B. I. (1998), "Confidence Intervals for Proportions With Small Expected Number of Positive Counts Estimated From Survey Data," Survey Methodology, 24, 193-201.

{pmore}Curtin, L. R., Kruszon-Moran, D., Carroll, M., and Li, X. (2006), "Estimation and Analytic Issues for Rare Events in NHANES," Proceedings of the Survey Research Methods Section, ASA, 2893-2903.  

{pmore}http://support.sas.com/documentation/cdl/en/statug/63962/HTML/default/viewer.htm#statug_surveyfreq_a0000000252.htm

{pmore}Dean, Natalie, and Marcello Pagano. (2015), "Evaluating confidence interval methods for binomial proportions in clustered surveys." Journal of Survey Statistics and Methodology 3, no. 4 : 484-503.

{pmore}Fleiss, Joseph L., Bruce Levin, and Myunghee Cho Paik. Statistical Mehods for Rates and Proportions. John Wiley & Sons, 2013.

{marker related}{...}
{title:Related commands}
{p 150 0 0}({it:{back:back to previous section}}) {p_end}
{help svy} 
{help proportion} 


