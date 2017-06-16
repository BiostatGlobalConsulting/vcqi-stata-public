*! vcqi_scalar version 1.00 - Biostat Global Consulting - 2015-12-05
*
* If the user says vcqi_scalar scalar_name = value then this program will 
* a) run the command "scalar scalar_name = value" and then
* b) put the current value of scalar_name into the VCQI log
*

program vcqi_scalar

	* Set the scalar macro that the user has asked for
	scalar `0'

	* Write that scalar to the VCQI log
	vcqi_log_scalar `1'

end
