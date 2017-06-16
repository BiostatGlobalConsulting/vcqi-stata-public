*! vcqi_log_comment version 1.04 - Biostat Global Consulting - 2017-01-29
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2015-12-21	1.01	MK Trimner		Removed the space between (" 3) in  di as error" 3) a keyword like comment, warning or error, and 4) a comment."
* 2016-02-21    1.02    Mary Prier      In the error message displayed to the screen when checking the fourth argument, the word "third" was changed to "fourth" and the number 1000 was changed to 2000.
* 2016-03-23	1.03	Dale Rhoda		Add diagnostic output when args have a problem
* 2017-01-29	1.04	Dale Rhoda		Extend log comment limit to 2045 chars
*******************************************************************************

* The user provides four inputs, all of which are written as a new row 
* in a dataset, along with a date and timestamp.
* 
* Typically 
*   1. The first argument will be the name of the program posting the
*      comment
*   2. The second argument will be a number indicating the level of detail
*      or verbosity...this can be used later in Excel to filter out the
*      nitty gritty comments.  1 is high-level...2 is second-order detail, 
*      and 3 is a deep detail that may be useful for debugging.
*   2. The third argument will be a keyword like 'Comment' or 'Warning' 
*      or 'Error' (for later filtering)
*   3. And the last argument will be the comment itself.  
*
*   Initial length limits are 50, 50, 50, and 2000 characters.

version 14.0

program define vcqi_log_comment

	* Be sure there are four arguments
	* Add a syntax statement here for more error checking later

	if "`1'" == "" | "`2'" == "" | "`3'" == "" | "`4'" == "" {
		di as error "Problem calling vcqi_log_comment from $VCP"
		di as error "You must provide 1) the name of the calling program, "
		di as error "2) a number indicating level of detail e.g., 1, 2, 3"
		di as error "3) a keyword like comment, warning or error, and 4) a comment."
		di as error "The calling arguments were "
		di as error "1: `1'"
		di as error "2: `2'"
		di as error "3: `3'"
		di as error "4: `4'"
		
		exit 99
	}

	if length("`1'") > 50 {
		di as error "Problem calling vcqi_log_comment from $VCP"
		di as error "The first argument to vcqi_log_comment should be 50 or fewer characters."
		di as error "1: `1'"
		di as error "2: `2'"
		di as error "3: `3'"
		di as error "4: `4'"
		exit 99
	}


	if length("`2'") > 50 {
		di as error "Problem calling vcqi_log_comment from $VCP"
		di as error "The second argument to vcqi_log_comment should be 50 or fewer characters."
		di as error "1: `1'"
		di as error "2: `2'"
		di as error "3: `3'"
		di as error "4: `4'"
		exit 99
	}


	if length("`3'") > 50 {
		di as error "Problem calling vcqi_log_comment from $VCP"
		di as error "The third argument to vcqi_log_comment should be 50 or fewer characters."
		di as error "1: `1'"
		di as error "2: `2'"
		di as error "3: `3'"
		di as error "4: `4'"
		exit 99
	}


	if length("`4'") > 2045 {
		di as error "Problem calling vcqi_log_comment from $VCP"
		di as error "The fourth argument to vcqi_log_comment should be 2045 or fewer characters."
		di as error "1: `1'"
		di as error "2: `2'"
		di as error "3: `3'"
		di as error "4: `4'"
		exit 99
	}

	* If there isn't an open log file, open one now

	if "$VCQI_LOGOPEN" != "1" vcqi_open_log

	post logfile ("$S_DATE") ("$S_TIME") ("`1'") ("`2'") ("`3'") ("`4'")

end
