*! RI_COVG_01_05TO version 1.05 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Move titles & footnotes to control pgm
* 2016-06-06	1.03	Dale Rhoda		Added card or register
* 2016-09-15	1.04	Dale Rhoda		Added BCG scar
* 2017-08-26	1.05	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_01_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
	
		foreach d in $RI_DOSE_LIST {
			noi di _continue _col(5) "`d' "
			local du `=upper("`d'")'
			* by card
			make_tables_from_svyp_output, measureid(RI_COVG_01) var(estimate ci )     sheet(RI_COVG_01 ${ANALYSIS_COUNTER}) vid(`d'_c) estlabel(`du' crude coverage, by card (%))
			* by history
			make_tables_from_svyp_output, measureid(RI_COVG_01) var(estimate ci )     sheet(RI_COVG_01 ${ANALYSIS_COUNTER}) vid(`d'_h) estlabel(`du' crude coverage, by history (%))

			* by scar (for BCG only)
			if lower("`d'") == "bcg" make_tables_from_svyp_output, measureid(RI_COVG_01) var(estimate ci ) sheet(RI_COVG_01 ${ANALYSIS_COUNTER}) vid(bcg_s) estlabel(`du' crude coverage, by scar (%))
			
			* Add the words 'or scar' to the ch and chr labels if the dose is BCG
			if lower("`d'") == "bcg" {
				local ch_label by card or history or scar (%)
				local chr_label by card or history or register or scar (%)
			}
			else {
				local ch_label by card or history (%)
				local chr_label by card or history or register (%)
			}
		
			* by card or history (or scar if BCG)
			make_tables_from_svyp_output, measureid(RI_COVG_01) var(estimate ci )     sheet(RI_COVG_01 ${ANALYSIS_COUNTER}) vid(`d'_ch) estlabel(`du' crude coverage, `ch_label' (%))

			if $RI_RECORDS_SOUGHT_FOR_ALL | $RI_RECORDS_SOUGHT_IF_NO_CARD {
				* by register
				make_tables_from_svyp_output, measureid(RI_COVG_01) var(estimate ci ) sheet(RI_COVG_01 ${ANALYSIS_COUNTER}) vid(`d'_r) estlabel(`du' crude coverage, by register (%))
				* by card or register
				make_tables_from_svyp_output, measureid(RI_COVG_01) var(estimate ci ) sheet(RI_COVG_01 ${ANALYSIS_COUNTER}) vid(`d'_cr) estlabel(`du' crude coverage, by card or register (%))
				* by card or history or register (or scar if BCG)
				make_tables_from_svyp_output, measureid(RI_COVG_01) var(estimate ci ) sheet(RI_COVG_01 ${ANALYSIS_COUNTER}) vid(`d'_chr) estlabel(`du' crude coverage, `chr_label' (%))
			}
			* to analyze
			make_tables_from_svyp_output, measureid(RI_COVG_01) var(estimate ci stderr lcb ucb deff icc n nwtd) sheet(RI_COVG_01 ${ANALYSIS_COUNTER})  vid(`d'_a) estlabel(`du' crude coverage (%))
		}	
		noi di ""
	}
		
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
