*! vcqi_log_scalar version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

* The user provides the name of a scalar; if it is defined then
* its name and value are written to the vcqi log 
*
* If it is not defined, a message saying so is written to the log.
*
* These are considered to be low-level details, so the comment level is set to 3.

program define vcqi_log_scalar
	version 14.1
 
	if "`1'" == ""  {
		di as error "You must provide the name of a scalar macro to the program vcqi_log_scalar"
		vcqi_log_comment $VCP 2 Warning "Program calls vcqi_log_scalar with no argument."
	}

	if "`=scalar(`1')'" == ""  {
		vcqi_log_comment $VCP 3 Scalar "Scalar `1' is not defined at this time."
	}
	else {
		vcqi_log_comment $VCP 3 Scalar "Scalar `1' is `=scalar(`1')'"
	}

end
