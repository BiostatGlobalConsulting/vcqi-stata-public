*! RI_QUAL_08_04GO version 1.02 - Biostat Global Consulting - 2019-11-09
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
* 2019-11-09	1.02 	Dale Rhoda		Introduced MOV_OUTPUT_DOSE_LIST
*******************************************************************************

program define RI_QUAL_08_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_QUAL_08_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		local vc  `=lower("$RI_QUAL_08_VALID_OR_CRUDE")'
		local pvc `=proper("`vc'")'
			
		foreach d in $MOV_OUTPUT_DOSE_LIST {
			noi di _continue _col(5) "`d' "
			make_count_output_database, measureid(RI_QUAL_08) vid(`d') num(total_mov_`d'_`vc') den(total_elig_`d'_`vc') estlabel(Visits with MOV for `=upper("`d'")' (`pvc')(%))
		}
		noi di _continue _col(5) "Totals..."
		make_count_output_database, measureid(RI_QUAL_08) vid(any) num(total_mov_visits_`vc') den(total_elig_visits_`vc') estlabel(Visits with MOV for any dose (`pvc')(%))
		make_count_output_database, measureid(RI_QUAL_08) vid(rate) num(total_movs_`vc')      den(total_elig_visits_`vc') estlabel(Rate of MOVs per eligible visit (`pvc')(%))
		
		noi di as text ""
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

