*! DESC_03_05TO version 1.04 - Biostat Global Consulting - 2018-02-08
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2017-03-07	1.02	Dale Rhoda		Set two footnotes by default whether 
*										measure is weighted or not
* 2017-08-26	1.03	Mary Prier		Added version 14.1 line
* 2018-02-08	1.04	Dale Rhoda		Clip sheetname to 30 chars at most
*******************************************************************************

program define DESC_03_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP DESC_03_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
		if "`=upper("$DESC_03_WEIGHTED")'" == "YES" {
			vcqi_global DESC_03_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval	
			vcqi_global DESC_03_TO_FOOTNOTE_2  Respondents could select more than one response to this question.
			vcqi_global DESC_03_TO_FOOTNOTE_3  Note: This measure is a population estimate that incorporates survey weights.  The CI is calculated with software that take the complex survey design into account.
		}
		if "`=upper("$DESC_03_WEIGHTED")'" == "NO" {
			vcqi_global DESC_03_TO_FOOTNOTE_1 Note: This measure is an unweighted summary of proportions from the survey sample.
			vcqi_global DESC_03_TO_FOOTNOTE_2  Respondents could select more than one response to this question.
			if "`=upper("$DESC_03_DENOMINATOR")'" == "ALL"       vcqi_global DESC_03_TO_FOOTNOTE_3 Denominator (N) is the total number of respondents.
			if "`=upper("$DESC_03_DENOMINATOR")'" == "RESPONDED" vcqi_global DESC_03_TO_FOOTNOTE_3 Denominator (N) is limited to respondents who answered the question.
		} 
		
		local sheetname DESC_03_${DESC_03_COUNTER}_$DESC_03_SHORT_TITLE $ANALYSIS_COUNTER
		if strlen("`sheetname'") > 30 local sheetname = substr("`sheetname'",1,30)

		make_tables_from_DESC_0203, measureid(DESC_03) sheet(`sheetname')  vid($DESC_03_COUNTER) 
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
