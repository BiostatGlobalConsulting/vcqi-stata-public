*! vcqi_global version 1.00 - Biostat Global Consulting - 2015-12-05
*
* If the user says vcqi_global GLOBAL_NAME value then this program will 
* a) run the command "global GLOBAL_NAME value" and then
* b) put the current value of GLOBAL_NAME into the VCQI log
*

program vcqi_global

	* Set the global macro that the user has asked for
	global `0'

	* Write that global to the VCQI log
	vcqi_log_global `1'

end
