*! which_program_version version 1.01 - Biostat Global Consulting - 2016-02-12
******************************************************************************* 
* Change log 
* 				Updated 
*				version 
* Date 			number 	Name			What Changed 
* 2016-02-12	1.02	Dale Rhoda		Set linesize to 250 for capturing long paths
 
capture program drop which_program_version
program define which_program_version, rclass

	local pgmname `1'

	tempfile tfile
	
	local lsize = `c(linesize)'
	
	quietly capture which `pgmname'
	
	if _rc == 0 {
	
		tempname logname
		set linesize 250
	
		* This section needs trace to be off in order to work properly, so 
		* capture the current status of trace, then turn it off.  Then after
		* capturing the program version, return trace to its former state.
		local trace `c(trace)'
		set trace off
	
		log using `tfile', text replace name(`logname')
			which `pgmname'
		quietly log close `logname'
	
		set trace `trace'
		* Trace has been returned to its former state
		
		tempname handle
		
		capture file close `handle'
		file open `handle' using `tfile', read text 
		
			forvalues i = 1/7 {
				file read `handle' line`i'
			}
		
		capture file close `handle'
		
		return local which = "`line6' -- `line7'"

		set linesize `lsize'
	}
	else {
		return local which = "`pgmname' not found."
	}
		
end
