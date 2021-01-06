*! get_token_count version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define get_token_count, rclass
	version 14.1
	
	local tcount 0 
	while `"`0'"' != `""' {
		gettoken nextstring 0:0
		local ++tcount
	}

	return scalar N = `tcount'

end
