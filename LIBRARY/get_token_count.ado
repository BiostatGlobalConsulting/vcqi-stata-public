*! get_token_count Version 1.0 Biostat Global Consulting 2015-11-23

program define get_token_count, rclass

	local tcount 0 
	while `"`0'"' != `""' {
		gettoken nextstring 0:0
		local ++tcount
	}

	return scalar N = `tcount'

end
