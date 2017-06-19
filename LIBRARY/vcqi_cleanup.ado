*! vcqi_cleanup version 1.00 - Biostat Global Consulting - 2016-09-19
*
program vcqi_cleanup

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
