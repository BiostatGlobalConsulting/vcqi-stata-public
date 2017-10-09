*! COVG_DIFF_01_05TO version 1.02 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-02-26	1.01	Dale Rhoda		Switch FOOTNOTE code to while loop
* 2017-08-26	1.02	Mary Prier		Added version 14.1 line
*******************************************************************************
program define COVG_DIFF_01_05TO
	version 14.1

	local oldvcp $VCP
	global VCP COVG_DIFF_01_05TO
	vcqi_log_comment $VCP 5 Flow "Starting"
	
	quietly {

		use "$COVG_DIFF_01_FILENAME", clear

		* Calculate maximum string lengths

		gen variable_name_length = length(variable)
		qui summarize variable_name_length
		local max_variable_name_length = r(max)
		drop variable_name_length
		
		gen stratum_name_length = length(stratum_name1)
		qui summarize stratum_name_length
		local max_stratum_name1_length = r(max)
		drop stratum_name_length
		
		gen stratum_name_length = length(stratum_name2)
		qui summarize stratum_name_length
		local max_stratum_name2_length = r(max)
		drop stratum_name_length
		
		* generate the stratum1 confidence interval string
		gen ci1 = "(" + strofreal(lb951,"%03.1f") + ", " + strofreal(ub951,"%04.1f") + ")"
		replace ci1 = subinstr(ci1,"100.0","100",1)
		replace ci1 = subinstr(ci1,", 00.",", 0.",1)
		
		order ci1, after(ub951)
		drop lb951 ub951

		gen ci2 = "(" + strofreal(lb952,"%03.1f") + ", " + strofreal(ub952,"%04.1f") + ")"
		replace ci2 = subinstr(ci2,"100.0","100",1)
		replace ci2 = subinstr(ci2,", 00.",", 0.",1)

		order ci2, after(ub952) 
		drop lb952 ub952
		
		gen ci3 = "(" + strofreal(difflb95,"%03.1f") + ", " + strofreal(diffub95,"%04.1f") + ")"
		replace ci3 = subinstr(ci3,"100.0","100",1)
		replace ci3 = subinstr(ci3,", 00.",", 0.",1)

		order ci3, after(diffub95)
		drop difflb95 diffub95

		gen pvaluestring = strofreal(pvalue,"%6.4f")
		replace pvaluestring = "< 0.0001" if pvalue < 0.0001
		
		order pvaluestring, after(pvalue)
		drop pvalue
		
		* calculate number of rows in the table
		qui count
		local nrows = r(N)
		
		* for now we leave two blank rows at the top for title and subtitle
		local startrow 3
		local rows 4,`=`startrow'+`nrows''

		export excel using "${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx", ///
			sheet("COVG_DIFF_01 $ANALYSIS_COUNTER") cell(A3) sheetreplace firstrow(variable) 

		* Use mata to populate column labels and worksheet titles and footnotes
		mata: b = xl()
		mata: b.load_book("${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx")
		mata: b.set_sheet("COVG_DIFF_01 $ANALYSIS_COUNTER")
		
		mata: b.put_string(`startrow', 1,"Stratum Level")
		mata: b.put_string(`startrow', 2,"Indicator")
		mata: b.put_string(`startrow', 3,"Variable")
		mata: b.put_string(`startrow', 4,"Analysis Counter")
		mata: b.put_string(`startrow', 5,"Stratum ID1")
		mata: b.put_string(`startrow', 6,"Stratum Name1")
		mata: b.put_string(`startrow', 7,"N1")
		mata: b.put_string(`startrow', 8,"N1 (wtd)")	
		mata: b.put_string(`startrow', 9,"Coverage 1 (%)")
		mata: b.put_string(`startrow',10,"95% CI")
		mata: b.put_string(`startrow',11,"Stratum ID2")
		mata: b.put_string(`startrow',12,"Stratum Name2")
		mata: b.put_string(`startrow',13,"N1")
		mata: b.put_string(`startrow',14,"N1 (wtd)")	
		mata: b.put_string(`startrow',15,"Coverage 2 (%)")
		mata: b.put_string(`startrow',16,"95% CI")
		mata: b.put_string(`startrow',17,"Degrees of Freedom")
		mata: b.put_string(`startrow',18,"Proportion Difference (%)")
		mata: b.put_string(`startrow',19,"95% CI")
		mata: b.put_string(`startrow',20,"P-value")

		* If this is the first time we are writing to the worksheet
		* include the measure titles and footnotes
				
		mata: b.put_string(1,1,"Coverage Difference Between Strata")
		mata: b.set_font_bold(1,1,"on")
			
		*if "${`measureid'_TO_SUBTITLE}" != "" mata: b.put_string(2,1,"${`measureid'_TO_SUBTITLE}")

		local footnoterow = `=`startrow'+`nrows'+2'
		local i 1
		while "${`measureid'_TO_FOOTNOTE_`i'}" != "" {
			mata: b.put_string(`footnoterow',1,"${`measureid'_TO_FOOTNOTE_`i'}")
			local ++footnoterow
			local ++i
		}
		
		* Usually we'll want to format the excel, but it is time consuming
		* so give an option to turn that off during testing of the code
		if "$FORMAT_EXCEL" == "1" {
		
			mata: b.set_column_width( 1, 1, 14)
			mata: b.set_column_width( 2, 2, 16)
			mata: b.set_column_width( 3, 3, `=max(10,`max_variable_name_length')') 
			mata: b.set_column_width( 4, 4, 17)
			mata: b.set_column_width( 5, 5, 12)
			mata: b.set_column_width( 6, 6, `=max(10,`max_stratum_name1_length')') 
			mata: b.set_column_width( 7, 7,  6)
			mata: b.set_column_width( 8, 8, 11)
			mata: b.set_column_width( 9, 9, 15)
			mata: b.set_column_width(10,10,12)
			mata: b.set_column_width(11,11,12)
			mata: b.set_column_width(12,12, `=max(10,`max_stratum_name2_length')') 
			mata: b.set_column_width(13,13,  6)
			mata: b.set_column_width(14,14, 11)
			mata: b.set_column_width(15,15, 15)
			mata: b.set_column_width(16,16, 12)
			mata: b.set_column_width(17,17, 19)
			mata: b.set_column_width(18,18, 26)
			mata: b.set_column_width(19,19, 12)
			mata: b.set_column_width(20,20, 8)

			mata: b.set_number_format((`rows'), 9,"##0.0;-##0.0;0.0;")
			mata: b.set_number_format((`rows'),15,"##0.0;-##0.0;0.0;")
			mata: b.set_number_format((`rows'),18,"##0.0;-##0.0;0.0;")

			mata: b.set_number_format((`rows'), 7,"number_sep")
			mata: b.set_number_format((`rows'), 8,"number_sep")
			mata: b.set_number_format((`rows'),13,"number_sep")
			mata: b.set_number_format((`rows'),14,"number_sep")

			mata: b.set_horizontal_align((`rows'), 2,"right")
			mata: b.set_horizontal_align((`rows'), 3,"right")
			
			mata: b.set_horizontal_align((`rows'),10,"right")
			mata: b.set_horizontal_align((`rows'),16,"right")
			mata: b.set_horizontal_align((`rows'),19,"right")
			mata: b.set_horizontal_align((`rows'),20,"right")

			mata: b.set_horizontal_align((`startrow'),(1,20),"right")

		}
		
		mata: b.close_book()
			
		vcqi_log_comment $VCP 3 Comment "Tabular output: COVG_DIFF_01 in ${VCQI_OUTPUT_FOLDER}/${VCQI_ANALYSIS_NAME}_TO.xlsx"	
	}
	
	vcqi_log_comment $VCP 5 Flow "Exiting"
	global VCP `oldvcp'

end
