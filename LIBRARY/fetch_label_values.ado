*! fetch_label_values version 1.00 - Biostat Global Consulting - 2018-01-02
******************************************************************************* 
* Change log 
* 				Updated 
*				version 
* Date 			number 	Name			What Changed 
* 2018-01-02	1.00	Dale Rhoda		Original version
*******************************************************************************

* This program returns a macro named r(vlist) that lists every numeric 
* value that is included in a value label.
 
program define fetch_label_values, rclass
	version 15.1
	
	local labname `1'

	tempfile tfile
	
	local lsize = `c(linesize)'
	
	quietly capture label list `labname'
	
	if _rc == 0 {
			
		quietly label save `labname' using `tfile', replace 
				
		tempname handle
		
		capture file close `handle'
		file open `handle' using `tfile', read text 
		
		* This line holds the first value label
		file read `handle' line
		
		* Put the list of values into the local macro named vlist
		while r(eof)==0 {
			tokenize `"`line'"'
			local vlist `vlist' `4'
			file read `handle' line
		}
		
		capture file close `handle'
		
		return local vlist = "`vlist'"

	}
		
end
