*! TT_COVG_01_04GO version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define TT_COVG_01_04GO
	version 14.1
	
	local oldvcp $VCP
	global VCP TT_COVG_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
		make_svyp_output_database, measureid(TT_COVG_01) vid(c) var(protected_at_birth_by_card)     estlabel(Protected at birth, by card)
		make_svyp_output_database, measureid(TT_COVG_01) vid(h) var(protected_at_birth_by_history)  estlabel(Protected at birth, by history)
		make_svyp_output_database, measureid(TT_COVG_01) vid(ch) var(protected_at_birth_c_or_h)      estlabel(Protected at birth, by card or history)
		if $TT_RECORDS_SOUGHT_FOR_ALL == 1 | $TT_RECORDS_SOUGHT_IF_NO_CARD == 1 {
			make_svyp_output_database, measureid(TT_COVG_01) vid(r) var(protected_at_birth_by_register) estlabel(Protected at birth, by register)
			make_svyp_output_database, measureid(TT_COVG_01) vid(chr) var(protected_at_birth_c_or_h_or_r) estlabel(Protected at birth, by card or history or register)
		}
		make_svyp_output_database, measureid(TT_COVG_01) vid(a) var(protected_at_birth_to_analyze)  estlabel(Protected at birth)
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

