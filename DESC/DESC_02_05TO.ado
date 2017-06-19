*! DESC_02_05TO version 1.02 - Biostat Global Consulting 2016-03-07
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2017-03-07	1.02	Dale Rhoda		Generate two footnotes automatially
*										whether the measure is weighted or not
*******************************************************************************

program define DESC_02_05TO

	local oldvcp $VCP
	global VCP DESC_02_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
		
	quietly {
		*global DESC_02_TO_TITLE    Responses to Multiple Choice Question
		
		* For many measures we specify the measure label using a global like
		* DESC_02_TO_TITLE, but for this measure, 
		* the title that will be inserted in the table is whatever is passed in
		* thru the required option named label().
		
		*global DESC_02_TO_SUBTITLE
		if "`=upper("$DESC_02_WEIGHTED")'" == "YES" {
			vcqi_global DESC_02_TO_FOOTNOTE_1  Abbreviations: CI=Confidence Interval	
			vcqi_global DESC_02_TO_FOOTNOTE_2  Note: This measure is a population estimate that incorporates survey weights.  The CI is calculated with software that take the complex survey design into account.
		}
		if "`=upper("$DESC_02_WEIGHTED")'" == "NO" {
			vcqi_global DESC_02_TO_FOOTNOTE_1 Note: This measure is an unweighted summary of proportions from the survey sample.
			if "`=upper("$DESC_02_DENOMINATOR")'" == "ALL"       vcqi_global DESC_02_TO_FOOTNOTE_2 Denominator (N) is the total number of respondents.
			if "`=upper("$DESC_02_DENOMINATOR")'" == "RESPONDED" vcqi_global DESC_02_TO_FOOTNOTE_2 Denominator (N) is limited to respondents who answered the question.
		} 
		
		local vid 1
		foreach d in $DESC_02_VARIABLES {
			make_tables_from_DESC_0203, measureid(DESC_02) sheet(DESC_02_${DESC_02_COUNTER}_`d' $ANALYSIS_COUNTER)  vid(`vid') 
			local ++vid
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
