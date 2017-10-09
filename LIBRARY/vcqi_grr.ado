*! vcqi_grr version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define vcqi_grr
	version 14.1

	*-------------------------------------------------------------------------------
	*                  Exit gracefully
	*-------------------------------------------------------------------------------
	*
	* If the user was doing a check run, then unset this flag now so 
	* VCQI will exit gracefully

	vcqi_global VCQI_CHECK_INSTEAD_OF_RUN 0
	*
	* Close the datasets that hold the results of 
	* hypothesis tests, and put them into the output spreadsheet
	*
	* Close the log file and put it into the output spreadsheet
	*
	* Clean up extra files
	* 
	* Send a message to the screen if there are warnings or errors in the log

	vcqi_halt_immediately

end
