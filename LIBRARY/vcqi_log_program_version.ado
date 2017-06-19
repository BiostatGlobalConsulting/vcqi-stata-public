*! vcqi_log_program_version version 1.01 - Biostat Global Consulting - 2015-10-03
*
* The user provides a user-written stata command name and this 
* program looks up its location and version number, if that
* is the first *! line at the top of the program
*
* This program puts the info out to the vcqi log dataset
*
* These are low-level details, so their level is set to 3 in the logfile
********************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		changed 3 to 2 in follwing statment: vcqi_log_comment $VCP 3 Warning "This program calls vcqi_log_program_version with no argument."
*										changed	"if strpos("`r(which)'","not found") > 0 {" statement to be an "if" and "else" statment 
*											if strpos("`r(which)'","not found") > 0 {
*												vcqi_log_comment $VCP 2 Warning "`r(which)'"
*											}	
*											else {
*												vcqi_log_comment $VCP 3 Program "`r(which)'"
*											}									
*******************************************************************************

version 14.0

program vcqi_log_program_version

	if "`1'" == ""  {
		di as error "You must provide vcqi_log_program_version with the name of a user-written Stata command"
		vcqi_log_comment $VCP 2 Warning "This program calls vcqi_log_program_version with no argument."
	}

	which_program_version `1'

	if strpos("`r(which)'","not found") > 0 {
		vcqi_log_comment $VCP 2 Warning "`r(which)'"
	}	
	else {
		vcqi_log_comment $VCP 3 Program "`r(which)'"
	}

end
