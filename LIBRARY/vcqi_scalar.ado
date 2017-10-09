*! vcqi_scalar version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************
*
* If the user says vcqi_scalar scalar_name = value then this program will 
* a) run the command "scalar scalar_name = value" and then
* b) put the current value of scalar_name into the VCQI log

program define vcqi_scalar
	version 14.1

	* Set the scalar macro that the user has asked for
	scalar `0'

	* Write that scalar to the VCQI log
	vcqi_log_scalar `1'

end
