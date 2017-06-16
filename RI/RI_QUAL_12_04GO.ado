*! RI_QUAL_12_04GO version 1.01 - Biostat Global Consulting - 2017-02-03
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-02-03	1.01	Dale Rhoda		Switched to _DOSE_PAIR_LIST
*******************************************************************************

program define RI_QUAL_12_04GO

	local oldvcp $VCP
	global VCP RI_QUAL_12_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local j 1
		local i 1
		while `i' <= `=wordcount("$RI_QUAL_12_THRESHOLD_LIST")' {
			local t `=word("$RI_QUAL_12_THRESHOLD_LIST",`i')'
			local d1 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
			local ++j
			local d2 `=word(lower("$RI_QUAL_12_DOSE_PAIR_LIST"),`j')'
			local ++j
			noi di _continue _col(5) "`d1' & `d2' "

			make_unwtd_output_database, measureid(RI_QUAL_12) vid(`d1'_`d2'_`t') var(igt_`d1'_`d2'_`t') estlabel(`=upper("`d1'")'-`=upper("`d2'")' Interval > `t' Days (%))

			local ++i
		}
		noi di ""
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

