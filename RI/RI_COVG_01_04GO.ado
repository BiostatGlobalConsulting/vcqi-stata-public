*! RI_COVG_01_04GO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-06-06	1.01	Dale Rhoda		Added card or register
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_01_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	foreach d in $RI_DOSE_LIST {
	
		noi di _continue _col(5) "`d' "
		make_svyp_output_database, measureid(RI_COVG_01) vid(`d'_c)  var(got_crude_`d'_by_card)     estlabel(Crude `d', by card)
		make_svyp_output_database, measureid(RI_COVG_01) vid(`d'_h)  var(got_crude_`d'_by_history)  estlabel(Crude `d', by history)
		
		if lower("`d'") == "bcg" make_svyp_output_database, measureid(RI_COVG_01) vid(bcg_s)  var(got_crude_bcg_by_scar)     estlabel(Crude bcg, by scar)
		
		if lower("`d'") == "bcg" local scar or scar
		if lower("`d'") != "bcg" local scar 
		
		make_svyp_output_database, measureid(RI_COVG_01) vid(`d'_ch) var(got_crude_`d'_c_or_h)      estlabel(Crude `d', by card or history `scar')
		
		if $RI_RECORDS_SOUGHT_FOR_ALL | $RI_RECORDS_SOUGHT_IF_NO_CARD {
			make_svyp_output_database, measureid(RI_COVG_01) vid(`d'_r)   var(got_crude_`d'_by_register) estlabel(Crude `d', by register)
			make_svyp_output_database, measureid(RI_COVG_01) vid(`d'_cr)  var(got_crude_`d'_c_or_r)      estlabel(Crude `d', by card or register)
			make_svyp_output_database, measureid(RI_COVG_01) vid(`d'_chr) var(got_crude_`d'_c_or_h_or_r) estlabel(Crude `d', by card or history or register `scar')
		}
		make_svyp_output_database, measureid(RI_COVG_01) vid(`d'_a)   var(got_crude_`d'_to_analyze)  estlabel(Crude `d', to analyze)
	}
	noi di as text ""
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

