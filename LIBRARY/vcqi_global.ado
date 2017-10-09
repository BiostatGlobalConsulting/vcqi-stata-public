*! vcqi_global version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

* If the user says vcqi_global GLOBAL_NAME value then this program will 
* a) run the command "global GLOBAL_NAME value" and then
* b) put the current value of GLOBAL_NAME into the VCQI log
*

program define vcqi_global
	version 14.1

	* Set the global macro that the user has asked for
	global `0'

	* Write that global to the VCQI log
	vcqi_log_global `1'

end
