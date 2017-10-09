*! RI_COVG_05_05TO version 1.04 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-01-18	1.01	Dale Rhoda		Changed to vcqi_global
* 2016-03-08	1.02	Dale Rhoda		Added subtitles and enabled 
*                                       user-specified footnotes (starting @ 3)
* 2016-03-11	1.03	Dale Rhoda		Moved footnotes 1 & 2 to control pgm
* 2017-08-26	1.04	Mary Prier		Added version 14.1 line
*******************************************************************************

program define RI_COVG_05_05TO
	version 14.1
	
	local oldvcp $VCP
	global VCP RI_COVG_05_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {
  	
		use "${VCQI_OUTPUT_FOLDER}/RI_COVG_05_${ANALYSIS_COUNTER}", clear
		
		* mark which clusters have alarmingly low coverage 
		* (as defined by user analysis parameters)
		
		gen alc = 0
		if "`=upper("$RI_COVG_05_THRESHOLD_TYPE")'" == "COUNT" {
			foreach d in `=lower("$RI_COVG_05_DOSE_LIST")' {
				replace alc = 1 if got_`d'_count <= $RI_COVG_05_THRESHOLD 
			}
			local criterion_string N who received at least one dose in the list <= ${RI_COVG_05_THRESHOLD}
		}
		if "`=upper("$RI_COVG_05_THRESHOLD_TYPE")'" == "PERCENT" {
			foreach d in `=lower("$RI_COVG_05_DOSE_LIST")' {
				replace alc = 1 if got_`d'_pct <= $RI_COVG_05_THRESHOLD
			}
			local criterion_string the weighted % who received at least one dose in the list <= ${RI_COVG_05_THRESHOLD}%
		}
		
		tab alc, m
			
		if "`=upper("$RI_COVG_05_TABLES")'" == "ALL_CLUSTERS" {
		
			* The user is asking to have a list of cluster-level coverage
			* for all clusters in all strata...so make one worksheet per
			* stratum, and shade the rows for clusters where one or more
			* of the doses listed here meets the criteria for alarmingly low
			* coverage.

			* make a list of variables to export and for later formatting purposes,
			* note which of them is a count and which of them is a percent
			local vlist clusterid cluster_name cluster_n
			local clabel1 Cluster ID
			local clabel2 Cluster Name
			local clabel3 N
			local type3 n
			local i 4
			foreach d in `=lower("$RI_COVG_05_DOSE_LIST")' {
				local du `=upper("`d'")'
				local vlist `vlist' got_`d'_count got_`d'_pct
				local clabel`i' Received `du' (N)
				local type`i' n
				local ++i
				
				local clabel`i' Received `du' (%)
				local type`i' pct
				local ++i
			}
			local ncols `=`i'-1'
			local cols 1,`ncols'
		
			local startrow 3
			local cell A4
		
			levelsof stratumid, local(slist)
			
			foreach s in `slist' {
			
				preserve
				keep if stratumid == `s'
				
				local nrows = _N
				local rows 4,`=4+`nrows''
				
				export excel `vlist' using ///
					"${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx",  ///
					sheet("RI_COVG_05 ${ANALYSIS_COUNTER} - `s'") cell(`cell') sheetreplace
					
				* Use mata to populate column labels and worksheet titles and footnotes
				mata: b = xl()
				mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx")
				mata: b.set_sheet("RI_COVG_05 ${ANALYSIS_COUNTER} - `s'")
				
				mata: b.put_string(1,1,"Cluster Level Coverage for Stratum `s' - `=stratum_name[1]'")
				
				if "$RI_COVG_05_TO_SUBTITLE" != "" mata: b.put_string(2,1,"$RI_COVG_05_TO_SUBTITLE")
				
				forvalues i = 1/`ncols' {
					mata: b.put_string(`startrow',`i',"`clabel`i''")
					if $FORMAT_EXCEL {
						mata: b.set_column_width(`i',`i', `=max(4,strlen("`clabel`i''"))')
						if "`type`i''" == "n"   mata: b.set_number_format((`rows'),`i',"number_sep")
						if "`type`i''" == "pct" mata: b.set_number_format((`rows'),`i',"##0.0;;0.0;")
					}
				}
				mata: b.set_horizontal_align((`startrow'),(1,`ncols'),"right") 
				
				forvalues i = 1/`=_N' {
					if alc[`i'] == 1 mata: b.set_fill_pattern(`=`startrow'+`i'',(`cols'),"solid","lightgray")
				}
				
				* 
				vcqi_global RI_COVG_05_TO_FOOTNOTE_1 Note: Shaded rows have alarmingly low coverage for at least one dose.
				vcqi_global RI_COVG_05_TO_FOOTNOTE_2 In this table, alarmingly low means: `criterion_string'.
				* Note that the user might specify footnotes 3 and later in the control program.
				
				local footnoterow = `nrows'+5
				local i 1
				while "${RI_COVG_05_TO_FOOTNOTE_`i'}" != "" {
					mata: b.put_string(`footnoterow',1,"${RI_COVG_05_TO_FOOTNOTE_`i'}")
					local ++footnoterow
					local ++i
				}
				mata: b.close_book()

				vcqi_log_comment $VCP 3 Comment "Wrote cluster coverage table for stratum `s' to ${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx"	
				
				restore
			}
		}
		
		if "`=upper("$RI_COVG_05_TABLES")'" == "ONLY_LOW_CLUSTERS" {

			local vlist stratumid stratum_name clusterid cluster_name cluster_n
			local clabel1 Stratum ID
			local clabel2 Stratum Name
			local clabel3 Cluster ID
			local clabel4 Cluster Name
			local clabel5 N
			local type3 n
			local i 6
			foreach d in `=lower("$RI_COVG_05_DOSE_LIST")' {
				local du `=upper("`d'")'
				local vlist `vlist' got_`d'_count got_`d'_pct
				local clabel`i' Received `du' (N)
				local type`i' n
				local ++i
				
				local clabel`i' Received `du' (%)
				local type`i' pct
				local ++i
			}
			local ncols `i'
			local cols 1,`ncols'
		
			keep if alc == 1 
					
			local startrow 3
			local cell A3
			local nrows = max(1,_N)
			local rows 4,`=4+`nrows''

			* If zero clusters have alarmingly low coverage, export a worksheet
			* with a short message saying that there are no clusters that meet 
			* the criteria
			
			if _N == 0 {
				local need_column_labels 0
				clear
				set obs 1
				gen text = "There are no clusters that meet the criteria for alarmingly low coverage."
				label variable text " "
				local vlist text
			}
			else local need_column_labels 1

			export excel `vlist' using ///
				"${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx",  ///
				sheet("RI_COVG_05 ${ANALYSIS_COUNTER}") cell(`cell') ///
				firstrow(varlabel) sheetreplace

			
			* Use mata to populate column labels and worksheet titles and footnotes
			mata: b = xl()
			mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx")
			mata: b.set_mode("open")
			mata: b.set_sheet("RI_COVG_05 ${ANALYSIS_COUNTER}")
			
			mata: b.put_string(1,1,"Clusters with Alarmingly Low Coverage")

			if "$RI_COVG_05_TO_SUBTITLE" != "" mata: b.put_string(2,1,"$RI_COVG_05_TO_SUBTITLE")

			* Export column labels and format them if there are any clusters in the table
			if `need_column_labels' == 1 {
				forvalues i = 1/`ncols' {
					mata: b.put_string(`startrow',`i',"`clabel`i''")
					if $FORMAT_EXCEL {
						mata: b.set_column_width(`i',`i', `=max(4,strlen("`clabel`i''"))')
						if "`type`i''" == "n"   mata: b.set_number_format((`rows'),`i',"number_sep")
						if "`type`i''" == "pct" mata: b.set_number_format((`rows'),`i',"##0.0;;0.0;")
					}
				}
				mata: b.set_horizontal_align((`startrow'),(1,`ncols'),"right") 
			}
			* 
			vcqi_global RI_COVG_05_TO_FOOTNOTE_1 Note: Each row has alarmingly low coverage for at least one dose.
			vcqi_global RI_COVG_05_TO_FOOTNOTE_2 In this table, alarmingly low means: `criterion_string'.
			* Note that the user might specify footnotes 3 and later in the control program.
			
			local footnoterow = `nrows'+5
			local i 1
			while "${RI_COVG_05_TO_FOOTNOTE_`i'}" != "" {
				mata: b.put_string(`footnoterow',1,"${RI_COVG_05_TO_FOOTNOTE_`i'}")
				local ++footnoterow
				local ++i
			}

			mata: b.close_book()

			vcqi_log_comment $VCP 3 Comment "Wrote alarmingly low coverage table RI_COVG_05 to ${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx"	
				
		}
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
