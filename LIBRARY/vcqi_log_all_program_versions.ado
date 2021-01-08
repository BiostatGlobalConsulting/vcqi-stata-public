*! vcqi_log_all_program_versions 1.13 - Biostat Global Consulting - 2021-01-05
******************************************************************************* 
* Change log 
* 				Updated 
*				version 
* Date 			number 	Name			What Changed 
* 2016-02-12	1.01	Dale Rhoda		Changed CVG to COVG in the DIFF ados 
* 2016-09-20	1.02	Dale Rhoda		Run quietly
* 2016-12-01	1.03	Dale Rhoda		Updated for svyp upgrade
* 2016-12-19	1.04	Dale Rhoda		Fixed a typo
* 2017-02-15	1.05	Dale Rhoda		Updated with new programs
* 2017-08-26	1.06	Mary Prier		Added version 14.1 line
* 2018-06-26	1.07	MK Trimner		Added shift_RI_dates, set_TO_xlsx_column_width
*										compare_two_ri_ads and fetch_label_values
* 2018-07-05	1.08	Dale Rhoda		Added svyp_null_result
* 2019-09-16	1.09	Mary Prier		Added RI_CCC & RI_CIC programs
* 2020-01-10	1.10	Mary Prier		Added several .ado files to log (commented with date) &
* 										alphabetized filenames within each category/folder
* 2020-01-16	1.11	Mary Prier		Added .style files to list of programs to check
* 2020-03-04	1.12	Mary Prier		Added gen_EVIM_variables.ado &
*										  parse_EVIM_variables.ado in the RI list 
* 2021-01-05	1.13	Dale Rhoda		Added programs recently added & 
*                                         changed EVIM to CVDIMS
******************************************************************************* 

program define vcqi_log_all_program_versions 
	version 14.1
 
	local oldvcp $VCP
	global VCP vcqi_log_all_program_versions 
	vcqi_log_comment $VCP 5 Flow "Starting" 
	
	noisily di as text "Logging the version numbers of all VCQI .ado programs..."
	
	noisily {
 
		* DESC
		vcqi_log_program_version DESC_01.ado 
		vcqi_log_program_version DESC_01_00GC.ado 
		vcqi_log_program_version DESC_01_01PP.ado 
		vcqi_log_program_version DESC_01_04GO.ado 
		vcqi_log_program_version DESC_01_05TO.ado 
		vcqi_log_program_version DESC_02.ado 
		vcqi_log_program_version DESC_02_00GC.ado 
		vcqi_log_program_version DESC_02_01PP.ado 
		vcqi_log_program_version DESC_02_03DV.ado 
		vcqi_log_program_version DESC_02_04GO.ado 
		vcqi_log_program_version DESC_02_05TO.ado 
		vcqi_log_program_version DESC_03.ado 
		vcqi_log_program_version DESC_03_00GC.ado 
		vcqi_log_program_version DESC_03_01PP.ado 
		vcqi_log_program_version DESC_03_03DV.ado 
		vcqi_log_program_version DESC_03_04GO.ado 
		vcqi_log_program_version DESC_03_05TO.ado 
		
		* DIFF
		vcqi_log_program_version COVG_DIFF_01.ado 
		vcqi_log_program_version COVG_DIFF_01_00GC.ado 
		vcqi_log_program_version COVG_DIFF_01_01PP.ado 
		vcqi_log_program_version COVG_DIFF_01_04GO.ado 
		vcqi_log_program_version COVG_DIFF_01_05TO.ado 
		vcqi_log_program_version COVG_DIFF_02.ado 
		vcqi_log_program_version COVG_DIFF_02_00GC.ado 
		vcqi_log_program_version COVG_DIFF_02_01PP.ado 
		vcqi_log_program_version COVG_DIFF_02_04GO.ado 
		vcqi_log_program_version COVG_DIFF_02_05TO.ado 
		
		* Library
		vcqi_log_program_version aggregate_vcqi_databases.ado
		vcqi_log_program_version calcicc.ado
		vcqi_log_program_version check_analysis_metadata.ado
		vcqi_log_program_version check_VCQI_CM_metadata.ado
		vcqi_log_program_version compare_two_ri_ads.ado
		vcqi_log_program_version excel_box_border_using_mata.ado 
		vcqi_log_program_version fetch_label_values.ado
		vcqi_log_program_version get_token_count.ado 
		vcqi_log_program_version make_count_output_database.ado 
		vcqi_log_program_version make_DESC_0203_output_database.ado 
		vcqi_log_program_version make_svyp_output_database.ado 
		vcqi_log_program_version make_table_order_database.ado
		vcqi_log_program_version make_table_order_dataset.ado
		vcqi_log_program_version make_tables_from_DESC_01.ado 
		vcqi_log_program_version make_tables_from_DESC_0203.ado 
		vcqi_log_program_version make_tables_from_RI_QUAL_09.ado 
		vcqi_log_program_version make_tables_from_svyp_output.ado 
		vcqi_log_program_version make_tables_from_unwtd_output.ado 
		vcqi_log_program_version make_unwtd_output_database.ado 
		vcqi_log_program_version manage_source_paths.ado  // added 1/10/2020
		vcqi_log_program_version set_TO_xlsx_column_width.ado
		vcqi_log_program_version svyp_ci_calc.ado
		vcqi_log_program_version svyp_null_result.ado
		vcqi_log_program_version svypd.ado 
		vcqi_log_program_version vcqi_adopath_check.ado
		vcqi_log_program_version vcqi_cleanup.ado
		vcqi_log_program_version vcqi_excel_convert_to_letter.ado 
		vcqi_log_program_version vcqi_global.ado 
		vcqi_log_program_version vcqi_grr.ado
		vcqi_log_program_version vcqi_halt_immediately.ado 
		vcqi_log_program_version vcqi_log_all_program_versions.ado 
		vcqi_log_program_version vcqi_log_comment.ado 
		vcqi_log_program_version vcqi_log_global.ado 
		vcqi_log_program_version vcqi_log_program_version.ado 
		vcqi_log_program_version vcqi_log_scalar.ado
		vcqi_log_program_version vcqi_open_log.ado 
		vcqi_log_program_version vcqi_scalar.ado
		vcqi_log_program_version which_program_version.ado 
		
		* Plot
		vcqi_log_program_version add_HH_vars_to_opplot_datasets.ado
		vcqi_log_program_version color-vcqi_level1.style   // added 1/16/2020
		vcqi_log_program_version color-vcqi_level2.style   // added 1/16/2020
		vcqi_log_program_version color-vcqi_level3.style   // added 1/16/2020
		vcqi_log_program_version color-vcqi_level4.style   // added 1/16/2020
		vcqi_log_program_version color-vcqi_outline.style  // added 1/16/2020
		vcqi_log_program_version excel_wrapper_for_iwplot_svyp.ado
		vcqi_log_program_version iwplot_svyp.ado 
		vcqi_log_program_version opplot.ado 
		vcqi_log_program_version uwplot_vcqi.ado 
		vcqi_log_program_version vcqi_to_double_iwplot.ado
		vcqi_log_program_version vcqi_to_iwplot.ado 
		vcqi_log_program_version vcqi_to_uwplot.ado
		
		* RI
		vcqi_log_program_version calculate_MOV_flags.ado 
		vcqi_log_program_version check_RI_analysis_metadata.ado 
		vcqi_log_program_version check_RI_COVG_01_03DV.ado 
		vcqi_log_program_version check_RI_COVG_02_03DV.ado 
		vcqi_log_program_version check_RI_COVG_03_03DV.ado 
		vcqi_log_program_version check_RI_QUAL_01_03DV.ado 
		vcqi_log_program_version check_RI_schedule_metadata.ado 
		vcqi_log_program_version check_RI_survey_metadata.ado 
		vcqi_log_program_version cleanup_RI_dates_and_ticks.ado 
		vcqi_log_program_version date_tick_chk_01_dob_present.ado
		vcqi_log_program_version date_tick_chk_02_dob_concordant.ado
		vcqi_log_program_version date_tick_chk_03_sensible_dob.ado
		vcqi_log_program_version date_tick_chk_04_dose_concordant.ado
		vcqi_log_program_version date_tick_chk_05_excel_report.ado
		vcqi_log_program_version establish_unique_RI_ids.ado 
		vcqi_log_program_version gen_CVDIMS_variables.ado 	
		vcqi_log_program_version make_RI_augmented_dataset.ado
		vcqi_log_program_version parse_CVDIMS_variables.ado 	// added 3/4/2020
		vcqi_log_program_version RI_ACC_01.ado 
		vcqi_log_program_version RI_ACC_01_00GC.ado 
		vcqi_log_program_version RI_ACC_01_01PP.ado 
		vcqi_log_program_version RI_ACC_01_04GO.ado 
		vcqi_log_program_version RI_ACC_01_05TO.ado 
		vcqi_log_program_version RI_CCC_01.ado 
		vcqi_log_program_version RI_CCC_01_00GC.ado 
		vcqi_log_program_version RI_CCC_01_01PP.ado 
		vcqi_log_program_version RI_CCC_01_03DV.ado 
		vcqi_log_program_version RI_CCC_01_06PO.ado 
		vcqi_log_program_version RI_CCC_02.ado 
		vcqi_log_program_version RI_CCC_02_00GC.ado 
		vcqi_log_program_version RI_CCC_02_01PP.ado 
		vcqi_log_program_version RI_CCC_02_03DV.ado 
		vcqi_log_program_version RI_CCC_02_06PO.ado 
		vcqi_log_program_version RI_CIC_01.ado 
		vcqi_log_program_version RI_CIC_01_00GC.ado 
		vcqi_log_program_version RI_CIC_01_01PP.ado 
		vcqi_log_program_version RI_CIC_01_03DV.ado 
		vcqi_log_program_version RI_CIC_01_06PO.ado 
		vcqi_log_program_version RI_CIC_02.ado 
		vcqi_log_program_version RI_CIC_02_00GC.ado 
		vcqi_log_program_version RI_CIC_02_01PP.ado 
		vcqi_log_program_version RI_CIC_02_03DV.ado 
		vcqi_log_program_version RI_CIC_02_06PO.ado 
		vcqi_log_program_version RI_CONT_01.ado 
		vcqi_log_program_version RI_CONT_01_00GC.ado 
		vcqi_log_program_version RI_CONT_01_01PP.ado 
		vcqi_log_program_version RI_CONT_01_03DV.ado 
		vcqi_log_program_version RI_CONT_01_04GO.ado 
		vcqi_log_program_version RI_CONT_01_05TO.ado 
		vcqi_log_program_version RI_CONT_01_06PO.ado 
		vcqi_log_program_version RI_COVG_01.ado 
		vcqi_log_program_version RI_COVG_01_01PP.ado 
		vcqi_log_program_version RI_COVG_01_02DQ.ado 
		vcqi_log_program_version RI_COVG_01_03DV.ado 
		vcqi_log_program_version RI_COVG_01_04GO.ado 
		vcqi_log_program_version RI_COVG_01_05TO.ado 
		vcqi_log_program_version RI_COVG_01_06PO.ado 
		vcqi_log_program_version RI_COVG_02.ado 
		vcqi_log_program_version RI_COVG_02_01PP.ado 
		vcqi_log_program_version RI_COVG_02_03DV.ado 
		vcqi_log_program_version RI_COVG_02_04GO.ado 
		vcqi_log_program_version RI_COVG_02_05TO.ado 
		vcqi_log_program_version RI_COVG_02_06PO.ado 
		vcqi_log_program_version RI_COVG_03.ado 
		vcqi_log_program_version RI_COVG_03_00GC.ado  // added 1/10/2020
		vcqi_log_program_version RI_COVG_03_01PP.ado 
		vcqi_log_program_version RI_COVG_03_02DQ.ado 
		vcqi_log_program_version RI_COVG_03_03DV.ado 
		vcqi_log_program_version RI_COVG_03_04GO.ado 
		vcqi_log_program_version RI_COVG_03_05TO.ado 
		vcqi_log_program_version RI_COVG_03_06PO.ado 
		vcqi_log_program_version RI_COVG_04.ado 
		vcqi_log_program_version RI_COVG_04_01PP.ado 
		vcqi_log_program_version RI_COVG_04_03DV.ado 
		vcqi_log_program_version RI_COVG_04_04GO.ado 
		vcqi_log_program_version RI_COVG_04_05TO.ado 
		vcqi_log_program_version RI_COVG_04_06PO.ado 
		vcqi_log_program_version RI_COVG_05.ado 
		vcqi_log_program_version RI_COVG_05_00GC.ado 
		vcqi_log_program_version RI_COVG_05_01PP.ado 
		vcqi_log_program_version RI_COVG_05_03DV.ado 
		vcqi_log_program_version RI_COVG_05_05TO.ado 
		vcqi_log_program_version RI_dose_intervals.ado 
		vcqi_log_program_version RI_QUAL_01.ado 
		vcqi_log_program_version RI_QUAL_01_01PP.ado 
		vcqi_log_program_version RI_QUAL_01_02DQ.ado 
		vcqi_log_program_version RI_QUAL_01_03DV.ado 
		vcqi_log_program_version RI_QUAL_01_04GO.ado 
		vcqi_log_program_version RI_QUAL_01_05TO.ado 
		vcqi_log_program_version RI_QUAL_01_06PO.ado 
		vcqi_log_program_version RI_QUAL_02.ado 
		vcqi_log_program_version RI_QUAL_02_01PP.ado 
		vcqi_log_program_version RI_QUAL_02_02DQ.ado 
		vcqi_log_program_version RI_QUAL_02_03DV.ado 
		vcqi_log_program_version RI_QUAL_02_04GO.ado 
		vcqi_log_program_version RI_QUAL_02_05TO.ado 
		vcqi_log_program_version RI_QUAL_02_06PO.ado 
		vcqi_log_program_version RI_QUAL_03.ado 
		vcqi_log_program_version RI_QUAL_03_00GC.ado 
		vcqi_log_program_version RI_QUAL_03_01PP.ado 
		vcqi_log_program_version RI_QUAL_03_03DV.ado 
		vcqi_log_program_version RI_QUAL_03_04GO.ado 
		vcqi_log_program_version RI_QUAL_03_05TO.ado 
		vcqi_log_program_version RI_QUAL_03_06PO.ado 
		vcqi_log_program_version RI_QUAL_04.ado 
		vcqi_log_program_version RI_QUAL_04_00GC.ado 
		vcqi_log_program_version RI_QUAL_04_01PP.ado 
		vcqi_log_program_version RI_QUAL_04_03DV.ado 
		vcqi_log_program_version RI_QUAL_04_04GO.ado 
		vcqi_log_program_version RI_QUAL_04_05TO.ado 
		vcqi_log_program_version RI_QUAL_04_06PO.ado 
		vcqi_log_program_version RI_QUAL_05.ado 
		vcqi_log_program_version RI_QUAL_05_00GC.ado 
		vcqi_log_program_version RI_QUAL_05_01PP.ado 
		vcqi_log_program_version RI_QUAL_05_03DV.ado 
		vcqi_log_program_version RI_QUAL_05_04GO.ado 
		vcqi_log_program_version RI_QUAL_05_05TO.ado 
		vcqi_log_program_version RI_QUAL_05_06PO.ado 
		vcqi_log_program_version RI_QUAL_06.ado 
		vcqi_log_program_version RI_QUAL_06_00GC.ado 
		vcqi_log_program_version RI_QUAL_06_01PP.ado 
		vcqi_log_program_version RI_QUAL_06_03DV.ado 
		vcqi_log_program_version RI_QUAL_06_04GO.ado 
		vcqi_log_program_version RI_QUAL_06_05TO.ado 
		vcqi_log_program_version RI_QUAL_06_06PO.ado 
		vcqi_log_program_version RI_QUAL_07B.ado 
		vcqi_log_program_version RI_QUAL_07B_01PP.ado 
		vcqi_log_program_version RI_QUAL_07B_03DV.ado 
		vcqi_log_program_version RI_QUAL_07B_04GO.ado 
		vcqi_log_program_version RI_QUAL_07B_05TO.ado 
		vcqi_log_program_version RI_QUAL_07B_06PO.ado 
		vcqi_log_program_version RI_QUAL_08.ado 
		vcqi_log_program_version RI_QUAL_08_00GC.ado 
		vcqi_log_program_version RI_QUAL_08_01PP.ado 
		vcqi_log_program_version RI_QUAL_08_04GO.ado 
		vcqi_log_program_version RI_QUAL_08_05TO.ado 
		vcqi_log_program_version RI_QUAL_08_06PO.ado 
		vcqi_log_program_version RI_QUAL_09.ado 
		vcqi_log_program_version RI_QUAL_09_00GC.ado 
		vcqi_log_program_version RI_QUAL_09_01PP.ado 
		vcqi_log_program_version RI_QUAL_09_03DV.ado 
		vcqi_log_program_version RI_QUAL_09_04GO.ado 
		vcqi_log_program_version RI_QUAL_09_05TO.ado 
		vcqi_log_program_version RI_QUAL_09_06PO.ado 
		vcqi_log_program_version RI_QUAL_12.ado 
		vcqi_log_program_version RI_QUAL_12_00GC.ado 
		vcqi_log_program_version RI_QUAL_12_01PP.ado 
		vcqi_log_program_version RI_QUAL_12_03DV.ado 
		vcqi_log_program_version RI_QUAL_12_04GO.ado 
		vcqi_log_program_version RI_QUAL_12_05TO.ado 
		vcqi_log_program_version RI_QUAL_12_06PO.ado 
		vcqi_log_program_version RI_QUAL_13.ado 
		vcqi_log_program_version RI_QUAL_13_00GC.ado 
		vcqi_log_program_version RI_QUAL_13_01PP.ado 
		vcqi_log_program_version RI_QUAL_13_03DV.ado 
		vcqi_log_program_version RI_QUAL_13_04GO.ado 
		vcqi_log_program_version RI_QUAL_13_05TO.ado 
		vcqi_log_program_version RI_QUAL_13_06PO.ado 
		vcqi_log_program_version RI_VCTC_01.ado
		vcqi_log_program_version RI_VCTC_01_00GC.ado
		vcqi_log_program_version RI_VCTC_01_01PP.ado
		vcqi_log_program_version RI_VCTC_01_03DV.ado
		vcqi_log_program_version RI_VCTC_01_05TO.ado
		vcqi_log_program_version RI_VCTC_01_06PO.ado
		vcqi_log_program_version shift_RI_dates.ado
		vcqi_log_program_version vcqi_RI_dose_assertlist.ado
		
		* SIA
		vcqi_log_program_version check_SIA_analysis_metadata.ado 
		vcqi_log_program_version check_SIA_COVG_01_03DV.ado  // added 1/10/2020
		vcqi_log_program_version check_SIA_schedule_metadata.ado 
		vcqi_log_program_version check_SIA_survey_metadata.ado 
		vcqi_log_program_version establish_unique_SIA_ids.ado 
		vcqi_log_program_version make_SIA_augmented_dataset.ado
		vcqi_log_program_version SIA_COVG_01.ado 
		vcqi_log_program_version SIA_COVG_01_01PP.ado 
		vcqi_log_program_version SIA_COVG_01_02DQ.ado 
		vcqi_log_program_version SIA_COVG_01_03DV.ado 
		vcqi_log_program_version SIA_COVG_01_04GO.ado 
		vcqi_log_program_version SIA_COVG_01_05TO.ado 
		vcqi_log_program_version SIA_COVG_01_06PO.ado 
		vcqi_log_program_version SIA_COVG_02.ado 
		vcqi_log_program_version SIA_COVG_02_01PP.ado 
		vcqi_log_program_version SIA_COVG_02_02DQ.ado 
		vcqi_log_program_version SIA_COVG_02_03DV.ado 
		vcqi_log_program_version SIA_COVG_02_04GO.ado 
		vcqi_log_program_version SIA_COVG_02_05TO.ado 
		vcqi_log_program_version SIA_COVG_02_06PO.ado 
		vcqi_log_program_version SIA_COVG_03.ado 
		vcqi_log_program_version SIA_COVG_03_00GC.ado 
		vcqi_log_program_version SIA_COVG_03_01PP.ado 
		vcqi_log_program_version SIA_COVG_03_02DQ.ado 
		vcqi_log_program_version SIA_COVG_03_03DV.ado 
		vcqi_log_program_version SIA_COVG_03_04GO.ado 
		vcqi_log_program_version SIA_COVG_03_05TO.ado 
		vcqi_log_program_version SIA_COVG_04.ado        // added 1/10/2020
		vcqi_log_program_version SIA_COVG_04_00GC.ado   // added 1/10/2020
		vcqi_log_program_version SIA_COVG_04_01PP.ado   // added 1/10/2020 
		vcqi_log_program_version SIA_COVG_04_02DQ.ado   // added 1/10/2020 
		vcqi_log_program_version SIA_COVG_04_03DV.ado   // added 1/10/2020 
		vcqi_log_program_version SIA_COVG_04_04GO.ado   // added 1/10/2020 
		vcqi_log_program_version SIA_COVG_04_05TO.ado   // added 1/10/2020
		vcqi_log_program_version SIA_COVG_04_06PO.ado   // added 1/10/2020
		vcqi_log_program_version SIA_COVG_05.ado        // added 1/10/2020
		vcqi_log_program_version SIA_COVG_05_00GC.ado   // added 1/10/2020
		vcqi_log_program_version SIA_COVG_05_01PP.ado   // added 1/10/2020
		vcqi_log_program_version SIA_COVG_05_03DV.ado   // added 1/10/2020
		vcqi_log_program_version SIA_COVG_05_05TO.ado   // added 1/10/2020
		vcqi_log_program_version SIA_QUAL_01.ado 
		vcqi_log_program_version SIA_QUAL_01_01PP.ado 
		vcqi_log_program_version SIA_QUAL_01_02DQ.ado 
		vcqi_log_program_version SIA_QUAL_01_03DV.ado 
		vcqi_log_program_version SIA_QUAL_01_04GO.ado 
		vcqi_log_program_version SIA_QUAL_01_05TO.ado 
		vcqi_log_program_version SIA_QUAL_01_06PO.ado 
		
		* TT
		vcqi_log_program_version check_TT_analysis_metadata.ado 
		vcqi_log_program_version check_TT_schedule_metadata.ado 
		vcqi_log_program_version check_TT_survey_metadata.ado 
		vcqi_log_program_version cleanup_TT_dates_and_ticks.ado  // added 1/10/2020
		vcqi_log_program_version establish_unique_TT_ids.ado 
		vcqi_log_program_version make_TT_augmented_dataset.ado  // added 1/10/2020
		vcqi_log_program_version TT_COVG_01.ado 
		vcqi_log_program_version TT_COVG_01_01PP.ado 
		vcqi_log_program_version TT_COVG_01_02DQ.ado 
		vcqi_log_program_version TT_COVG_01_03DV.ado 
		vcqi_log_program_version TT_COVG_01_04GO.ado 
		vcqi_log_program_version TT_COVG_01_05TO.ado 
		vcqi_log_program_version TT_COVG_01_06PO.ado 

	}	
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp' 
 
end 
