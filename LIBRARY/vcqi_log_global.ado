*! vcqi_log_global version 1.03 - Biostat Global Consulting - 2017-01-29
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-29	1.03	Dale Rhoda		Break long comments into parts
*******************************************************************************


* The user provides the name of a global macro; if it is defined then
* its name and value are written to the vcqi log dataset
*
* If it is not defined, a message saying so is written to the log.
*
* These are considered to be low-level details, so the comment level is set to 3.
*

version 14.0

program vcqi_log_global
 
	if "`1'" == ""  {
		di as error "You must provide the name of a global macro to the program vcqi_log_global"
		vcqi_log_comment $VCP 2 Warning "Program calls vcqi_log_global with no argument."
	}

	if "${`1'}" == ""  {
		vcqi_log_comment $VCP 3 Global "Global macro `1' is not defined at this time."
	}
	else {
	
		* Check to see if the global needs to be broken into substrings
		*
		* If it is > 2045 characters, then put it into the log in several
		* pieces, each of length 2045 or shorter
		
		local glength = length("Global macro `1' is ${`1'}")
		local ncomments = int(`glength' / 2045)
		if `ncomments' != `glength'/2045 local ++ncomments
		
		if `ncomments' == 1 vcqi_log_comment $VCP 3 Global "Global macro `1' is ${`1'}"
		
		if `ncomments' > 1 {
			vcqi_log_comment $VCP 3 Global "The following comment to document global `1' is split into `ncomments' lines in the log."
			forvalues i = 1/`ncomments' {
				local start = 1 + (`i'-1)*2045
				if `i' < `ncomments' local length 2045
				if `i' == `ncomments' local length = mod(`glength',2045)
				di "`glength' `ncomments' `start' `length'"
				vcqi_log_comment $VCP 3 Global "`=substr("Global macro `1' is ${`1'}",`start',`length')'"
			}
		}
	}

end
