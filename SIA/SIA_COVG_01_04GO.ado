*! SIA_COVG_01_04GO version 1.00 - Biostat Global Consulting - 2015-09-28

program define SIA_COVG_01_04GO

	local oldvcp $VCP
	global VCP SIA_COVG_01_04GO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
		make_svyp_output_database, measureid(SIA_COVG_01) vid(c) var(got_sia_dose_by_card)       estlabel(Vaccinated during SIA, by card)
		make_svyp_output_database, measureid(SIA_COVG_01) vid(h) var(got_sia_dose_by_history)    estlabel(Vaccinated during SIA, by history)
		if "$SIA_FINGERMARKS_SOUGHT" == "1" ///
		make_svyp_output_database, measureid(SIA_COVG_01) vid(f) var(got_sia_dose_by_fingermark) estlabel(Vaccinated during SIA, by fingermark)
		make_svyp_output_database, measureid(SIA_COVG_01) vid(a) var(got_sia_dose)               estlabel(Vaccinated during SIA)
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end

