*! compare_two_ri_ads version 1.03 - Biostat Global Consulting - 2017-02-28
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-01-10	1.00	MK Trimner		Original version
* 2017-01-30	1.01	Dale Rhoda		Make outputpath optional; add note
* 2017-02-21	1.02	MK Trimner		Remove ACC_01 as it will show as 0 since dpt1_crude_to_analyze is associated with RI_COVG_01
* 2017-02-21	1.02	MK Trimner		Add RI_QUAL_12 as dataset has been changed to be 1 row per person
* 2017-02-21	1.02	MK Trimner		Adjusted code to only shade if value is greater than 0
* 2017-02-21	1.02	MK Trimner		Formatted column width in tables	
* 2017-02-21	1.02	MK Trimner		Corrected code for RI_QUAL_08
* 2017-02-28	1.03	MK Trimner		Added lines in tables to divide table headings and data
*										Reversed column and row in RI_QUAL_08 shading code
*										Made table text be aligned to the right side
* 										Added footnotes and note about disconcordance after each table
*										Hard coded Indicator name in cell A1
* 2017-04-25	1.04	MK Trimner		Added comments about syntax to align with User's guide
*										
*******************************************************************************
*
* This program allows the user to compare the results of two augmented datasets created by the make_RI_augmented_dataset program.
* Results will be saved as an excel file as both a summary tab and Individual tab for each Indicator. 
* The results can illustrate the impact of changes in data. 
* Example: Typos in dates of birth and dose dates.
*
********************************************************************************
* Program Syntax
*
* Required Option:
*
* FILE1NAME -- 	format: 		string
*				description:	name of first augmented dataset used for comparison.
*				note1:			if folder path is different than Current Directory, the entire path must be specified with file name.
*				note2:			this program requires that the augmented datasets be cleaned up
*								meaning any conflicting variable results must be resolved and
*								all variables starting with "ADS_DUP" must be deleted prior to running the program.

* FILE2NAME --	format: 		string
*				description:	name of second augmented dataset used for comparison.
*				note1:			if folder path is different than Current Directory, the entire path must be specified with file name.
*				note2:			this program requires that the augmented datasets be cleaned up
*								meaning any conflicting variable results must be resolved and
*								all variables starting with "ADS_DUP" must be deleted prior to running the program.
*				
*
****************************************************************************************************************************************************************
* Optional Options:
*
* OUTPUTPATH 	-- format: 		string
*				description:	Path where the results will be saved as an excel spreadsheet titled: ADS_COMPARISON_REPORT
*				default value:	Current Directory
*
********************************************************************************
* General Notes:
*
* The program will only complete the comparison for and Indicator if both augmented datasets contain the variable. 
*
* Be sure that each Indicator you would like to compare has been ran for both datasets prior to running this program.
*
* The results exclude Indicators RI_COVG_05, RI_QUAL_05 and RI_QUAL_12.
*
********************************************************************************

capture program drop compare_two_ri_ads
program define compare_two_ri_ads

	syntax , FILE1name(string) FILE2name(string) [OUTPUTpath(string)]
	
	set more off
	
	quietly {

		nois di "cd to Output location..."
		* CD to location for output
		if "`outputpath'" != "" cd  `"`outputpath'"'

		* Open the first dataset
		use "`file1name'", clear

		* Set RI Indicator list
		* Indicator RI_ACC_01 is not included as it is captured in RI_COVG_01
		global RILIST 	RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04 ///
						RI_CONT_01 RI_QUAL_01 RI_QUAL_02 RI_QUAL_03 ///
						RI_QUAL_04 RI_QUAL_06 RI_QUAL_07 RI_QUAL_08 ///
						RI_QUAL_09 RI_QUAL_13 
					
		* Create list without the mov indicators
		global RILIST2 	RI_COVG_01 RI_COVG_02 RI_COVG_03 RI_COVG_04 ///
						RI_CONT_01 RI_QUAL_01 RI_QUAL_02 RI_QUAL_03 ///
						RI_QUAL_04 RI_QUAL_06 RI_QUAL_07 /// //RI_QUAL_12 ///
						RI_QUAL_13

		* Pull all the dose names to create a dose name list
		local vlist
		foreach v of varlist * {
			if strpos("`v'","card_tick")>=1 {
				local vlist `vlist' `=subinstr("`v'","_card_tick","",.)'
			}
		}

		*********************************************************************************
		nois di "Determine which doses exist in both Augmented datasets..."

		* Create 4 lists of all variables that will be used in the program
		* First list are dose specific and contain a values of 1,0,.
		
		local dlist1 
		foreach v in `vlist' {
			foreach n in got_crude_*_by_* got_crude_*_to_analyze got_valid_*_by_* got_valid_*_to_analyze  ///
						valid_*_age1_* valid_*_age1_to_analyze ///
						got_invalid_*_by* got_invalid_*  valid_*_before_age1 ///
						valid_*_if_no_movs child_had_mov_* child_had_uncor_mov_* child_had_cor_mov_* { 
						
				* Variable will only be added if it exists in the dataset		
				capture confirm variable `=subinstr("`n'","*","`v'",1)' 
				if !_rc {
					local dlist1 `dlist1' `=subinstr("`n'","*","`v'",1)'
				}
			}
		}

		*********************************************************************************

		* Second list includes the all non dose specific variables with values 1,0,.
		local dlist2
		foreach n in fully_vaccinated_crude fully_vaccinated_valid ///
						fully_vaccinated_by_age1 not_vaccinated_crude not_vaccinated_valid not_vaccinated_by_age1  ///
						showed_card_with_dates ever_had_an_ri_card ///
						child_had_mov child_had_only_uncor_mov  ///
						child_had_only_cor_mov child_had_cor_and_uncor_mov {

				* Variable will only be added if it exists in the dataset		
				capture confirm variable `n' 
				if !_rc {
					local dlist2 `dlist2' `n'
				}
		}
				
		* Add RI_CONT and RI_QUAL_09 and RI_QUAL_13 variables
		 foreach v of varlist * {
			foreach n in dropout early { 
				if strpos("`v'","`n'")>=1 {
					local dlist2 `dlist2' `v'
				}
			}
		}

		*********************************************************************************
		* Create a third list for variables that do not have a 1,0,. value...
		local dlist3a
		local dlist3b
		local dlist3
		foreach v in `vlist' {
			foreach n in total_mov_*_valid  { //QUAL_08
				* Variable will only be added if it exists in the dataset		
				capture confirm variable `=subinstr("`n'","*","`v'",1)' 
				if !_rc {
					local dlist3a `dlist3a' `=subinstr("`n'","*","`v'",1)'
				}
			}
			foreach n in total_elig_*_valid {
			* Variable will only be added if it exists in the dataset		
				capture confirm variable `=subinstr("`n'","*","`v'",1)' 
				if !_rc {
					local dlist3b `dlist3b' `=subinstr("`n'","*","`v'",1)'
				}
			}
		}
		
		local dlist3 `dlist3a' `dlist3b'
		*********************************************************************************
		
		* Create fourth list by grabbing the non dose specific variables that do not have a value of 1,0,.
		local dlist4
		foreach n in total_elig_visits_valid /// //RI_QUAL_08
					card_date_count /// //RI_QUAL_01
					doses_with_mov doses_with_uncor_mov doses_with_cor_mov /// //RI_QUAL_09  
					total_mov_visits_valid total_movs_valid { //RI_QUAL_08
		
			capture confirm variable `n' 
			if !_rc {
				local dlist4 `dlist4' `n'
			}
		}
				
		*********************************************************************************
		
		* Open second dataset
		use "`file2name'", clear

		* Create new variable list to show which of the above variables exist in both datasets... all others are dropped
		local dlistf
		foreach v of varlist * {
			if strpos("`dlist1' `dlist2' `dlist3' `dlist4'","`v'")>=1 {
				local dlistf `dlistf' `v'
			}
		}

		* Only keep variables that are relevant
		keep RI01 RI03 RI11 RI12 `dlistf'
		
		* Rename to indicate second file
		foreach v of varlist * {
			if !inlist("`v'","RI01", "RI03", "RI11", "RI12") {
				rename `v' `v'_2
			}
		}

		save "ADS_COMPDS_2", replace 
		
		* Bring in first dataset... 
		use "`file1name'", clear
		 
		* Only keep the relevant variables
		keep RI01 RI03 RI11 RI12 `dlistf' 
		 
		save "ADS_COMPDS_1", replace

		* Merge in second dataset to have one large dataset...
		merge 1:1 RI01 RI03 RI11 RI12 using "ADS_COMPDS_2"
		save "ADS_COMPDS_1_and_2_COMBINED", replace

		* Export to excel and comment on any lines where there was not a match from the merge
		count if _merge==1
		scalar merge1=r(N)

		count if _merge==2
		scalar merge2=r(N)

		count if _merge==3
		scalar merge3=r(N)

		scalar totmerge1_2=merge1 + merge2

		* Drop any lines that do not have _merge==3
		drop if _merge!=3
		drop _merge

		save, replace
		
	********************************************************************************
		nois di "Create matrixes for each variable to show concordance between both datasets..."

		* Create summary page for non 1, 0, . valued variables
		 use "ADS_COMPDS_1_and_2_COMBINED", clear	
		
		* use the below to create the matrix and determine the values for variables with 0,1,. values
		* Those in `dlist1' and `dlist2'
		forvalues i = 1/2 {
			foreach v in `dlist`i'' { 
				matrix `v' = J(3,3,.) 
				matrix rownames `v'= 0 1 Missing
				matrix colnames `v'= 0 1 Missing
				
				foreach i in 0 1 . {
					if inlist(`i',0,1) {
						local r `i'
					}
					else {
						local r 2
					}
					foreach j in 0 1 . {
						if inlist(`j',0,1) {
							local c `j'
						}
						else {
							local c 2
						}

						
						count if `v'==`i' & `v'_2==`j'
						matrix `v'[`=`r'+1', `=`c'+1']=r(N)
						
					}
				}
						
				matrix list `v', nohalf
				* Grab the diagonal total
				scalar `v'_d= trace(`v')
				* Grab the row and column numbers in matrix
				scalar `v'_r=rowsof(`v')
				scalar `v'_c=colsof(`v')
			
				. mata : st_matrix("`v'2", sum(st_matrix("`v'")))
				matrix list `v'2
				* Grab the total of the entire matrix
				scalar `v'_t=`v'2[1,1]
			}
		}

		
		* Determine the max for each variable that do not have a 1,0,. values
		forvalues i = 3/4 {
			foreach v in  `dlist`i'' {
				summarize `v'
				local `v'1=r(max)
				summarize `v'_2
				local `v'2=r(max)
				local max_`v' `=max(``v'1', ``v'2')'
				
				* Create locals iwth row and column names
				local `v'_rcn
				forvalues n = 0/`max_`v'' {
					local `v'_rcn ``v'_rcn' `n'
				}
			}
		}
		
	********************************************************************************	
		
		* Create matrixes for 0, 1, . value variables 
		forvalues i = 3/4 {
			foreach v in `dlist`i'' { 
				matrix `v' = J(`=`max_`v''+1',`=`max_`v''+1',.) 
				matrix rownames `v' = ``v'_rcn'
				matrix colnames `v' = ``v'_rcn'
				
				forvalues i = 0/`max_`v'' {
					forvalues j = 0/`max_`v'' {
						qui	count if `v'==`i' & `v'_2==`j'
						matrix `v'[`=`i'+1', `=`j'+1']=r(N)
						
					}
				}
				
				matrix list `v', nohalf
				* Grab the diagonal total
				scalar `v'_d= trace(`v')

				* Grab the row and column numbers in matrix
				scalar `v'_r=rowsof(`v')
				scalar `v'_c=colsof(`v')

				
				. mata : st_matrix("`v'2", sum(st_matrix("`v'")))
				matrix list `v'2
				* Grab the total of the entire matrix
				scalar `v'_t=`v'2[1,1]
			}
		}
	
******************************************************************************
		* Set up excel spreadsheet
		putexcel set ADS_COMPARISON_REPORT.xlsx, replace sheet("Summary")
			
		if totmerge1_2>0 {
			local note1 "Notes: `=totmerge1_2' lines were dropped from the dataset as they did not exist in both files."
		}
		else if totmerge1_2==0 {
			local note1 "Notes: All `=merge3' lines from both datasets are included in this summary." 
		}
		
		putexcel A1="`note1'", bold
		

		foreach i in $RILIST {
			scalar `i'_d=0
			scalar `i'_t=0
			scalar `i'_n=0
		}

		* Create the summary tab to show discordance and concordance
		foreach i in $RILIST {
			foreach v in `dlistf' {
				if "``v'[Indicator]'"=="`i'"  {
					* Grab the sum of each discordance for summary tab
					scalar `i'_d= `v'_d + `i'_d 
					scalar `i'_t= `v'_t + `i'_t				
				}
			}
			scalar `i'_n = `i'_t - `i'_d
		}

			
		
		local r 3 
		putexcel set ADS_COMPARISON_REPORT.xlsx, modify sheet("Summary")
		nois di "Creating Summary page to show Concordance, Disconcordance and Total for each Indicator..."

			
		* Add indicator, discordance total, concordance total and total to summary page
		putexcel B2 = "Indicator", hcenter bold
		putexcel C2 = "Discordance", hcenter bold
		putexcel D2 = "Concordance", hcenter bold
		putexcel E2 = "Total", hcenter bold

		foreach i in $RILIST {
			if `i'_t!=0 {
				putexcel B`r' = "`i'", hcenter
				putexcel C`r' = `i'_n, hcenter 
				if `i'_n>0 putexcel C`r', fpattern("solid", "pink")
				putexcel D`r' = `i'_d, hcenter
				putexcel E`r' = `i'_t, hcenter
				local r `=`r'+1'
			}
		}
		putexcel B3:E3, border(top thick)
		putexcel B`r':E`r', border(top thick)
		putexcel B3:B`=`r'-1', border(left thick)
		putexcel E3:E`=`r'-1', border(right thick)
		
	********************************************************************************		
		
		
		* Export each matrix	
		foreach i in $RILIST2 {
			if `i'_t!=0 {
				local r 1
				foreach v in `dlist1' `dlist2' {
					if "``v'[Indicator]'"=="`i'" {

						nois di "Creating table for `v' in `i'..."

						* Add Message explaning what sheet entails
						putexcel set ADS_COMPARISON_REPORT.xlsx, modify sheet("`i'")
						putexcel A1= "Variables derived during Indicator `i'", bold 
						
						* Add matrix to spreadsheet
						putexcel A`=`r'+ 2' = "`v'", vcenter bold italic
						putexcel B`=`r'+ 3' = matrix(`v'), right names

						putexcel A`=`r'+ 3':A`=`r'+ 6' = "File 2", merge right bold	
						putexcel A`=`r'+ 3':A`=`r'+ 6', border (right "vvthick")
						putexcel B`=`r'+ 4':B`=`r'+ 6', border (right "vvthick")
						
						putexcel B`=`r'+2':E`=`r'+2' = "File 1", merge hcenter bold
						putexcel B`=`r'+2':E`=`r'+2', border (bottom "vvthick")
						putexcel C`=`r'+3':E`=`r'+3', border (bottom "vvthick")

						
						* Add pink shading
						if matrix(`v'[2,1])>0 putexcel C`=`r'+5', fpattern("solid", "pink") 
						if matrix(`v'[3,1])>0 putexcel C`=`r'+6', fpattern("solid", "pink") 
						
						if matrix(`v'[1,2])>0 putexcel D`=`r'+4', fpattern("solid", "pink") 
						if matrix(`v'[3,2])>0 putexcel D`=`r'+6', fpattern("solid", "pink") 
						
						if matrix(`v'[1,3])>0 putexcel E`=`r'+4', fpattern("solid", "pink")
						if matrix(`v'[2,3])>0 putexcel E`=`r'+5', fpattern("solid", "pink") 
						
						* Add note about discordance
						putexcel A`=`r' + 7'= "Note: Any cells highlighted in pink indicate discordance between file 1 and file 2", bold			
										
						local r `=`r' + `v'_r + 4'
						
						local r`i' `=`r'+3'
					
					}	
				}
				
				* Add footnote with filenames
				putexcel set ADS_COMPARISON_REPORT.xlsx, modify sheet("`i'")
				putexcel A`r`i''= "Footnote1: File 1 is `file1name'", bold
				putexcel A`=`r`i''+1'= "Footnote2: File 2 is `file2name'", bold
			}	
		}
********************************************************************************
	

		* Do the same process for the MOV indicators.. but set them up so the summary variables are first
		local i 1
		foreach g in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z {
			local c`i' `g'
			
			local i `=`i'+1'
		}
			
		foreach g in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z {
			foreach n in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z {
		
				local c`i' `g'`n'
				
				local i `=`i'+1'
			}
		}
	
	
	
********************************************************************************
	* Complete for RI_QUAL_08 per dose
		foreach i in RI_QUAL_08 {
			if `i'_t!=0 {
				local r 1
				* Put the summary variables in first
				foreach v in total_elig_visits_valid total_mov_visits_valid total_movs_valid `dlist3a' {
					local n 1
					if "``v'[Indicator]'"=="`i'" {
						nois di "Creating table for `v' in RI_QUAL_08..."

						* Add Message explaning what sheet entails
						putexcel set ADS_COMPARISON_REPORT.xlsx, modify sheet("`i'")
						putexcel A1 = "Variables derived during Indicator `i'", bold 

						* Add matrix to spreadsheet
						putexcel A`=`r'+ 2' = "`v'", vcenter bold italic
						putexcel B`=`r'+ 3' = matrix(`v'), right names		
						
						* Add file titles to page
						putexcel A`=`r'+ 3':A`=`r' + 4 + `max_`v''' = "File 2", merge right bold	
						putexcel A`=`r'+ 3':A`=`r' + 4 + `max_`v''', border (right "vvthick")
						putexcel B`=`r'+ 4':B`=`r' + 4 + `max_`v''', border (right "vvthick")

					
						local n `=`n' + 2 + `max_`v'''
						
						putexcel B`=`r'+2':`c`n''`=`r'+ 2' = "File 1", merge hcenter bold
						putexcel B`=`r'+2':`c`n''`=`r'+ 2', border (bottom "vvthick")
						putexcel C`=`r'+3':`c`n''`=`r'+ 3', border (bottom "vvthick")
						
						* Add note about discordance
						putexcel A`=`r' + 5 + `max_`v'''= "Note: Any cells highlighted in pink indicate discordance between file 1 and file 2", bold			
						
						* Add pink shading
						
						local n 2
						local r `=`r'+3'
						forvalues s = 0/`max_`v'' {
							forvalues t = 0/`max_`v'' {
								if `s'!=`t' {
									if matrix(`v'[`=`s'+1',`=`t'+1']) > 0 putexcel `c`=`n' + 1 + `t'''`=`r' + 1 + `s'', fpattern("solid", "pink")
								}
							}
						}
						
					}
					
					if "`v'"=="total_elig_visits_valid" | "`v'"== "total_mov_visits_valid" | "`v'"== "total_movs_valid"  {
						local r `=`r' + `v'_r + 1'
					}
					
					else {
						* Determine the max row number for the mov and elig table
						* If the two tables do not have the same number of rows, you want to use the max
						local f `=max(`v'_r, `=subinstr("`v'","mov","elig",.)'_r)'
									
						local r `=`r' + `f' + 1'
					}
				}
			
				* Set local r so that it will be equal with the first dose specific table	
				local r `=total_elig_visits_valid_r + total_mov_visits_valid_r + total_movs_valid_r + 13'
				
				* Determine the max number of columns for each table and make that local n
				local p
				foreach v in `dlist3a' `dlist3b' {
					local p `p' `v'_r
				}
				
				local p `=subinstr("`p'"," ",",",.)'
				di "`p'"
				
				local k `=max(`p')'
				di "`k'"
				
				
				foreach v in `dlist3b' {
					local n  `=`k' + 4'
				
					if "``v'[Indicator]'"=="`i'" {
						putexcel set ADS_COMPARISON_REPORT.xlsx, modify sheet("`i'")
						
						nois di "Creating table for `v' in RI_QUAL_08..."
				
						* Add matrix to spreadsheet
						putexcel `c`n''`=`r'+ 2' = "`v'", vcenter bold italic
						putexcel `c`=`n' + 1''`=`r'+ 3' = matrix(`v'), right names

						putexcel `c`n''`=`r'+ 3':`c`n''`=`r'+ 4 + `max_`v''' = "File 2", merge right bold	
						putexcel `c`n''`=`r'+ 3':`c`n''`=`r'+ 4 + `max_`v''', border (right "vvthick")
						putexcel `c`=`n'+1''`=`r'+ 4':`c`=`n'+1''`=`r'+ 4 + `max_`v''', border (right "vvthick")
						
						putexcel `c`=`n' + 1''`=`r'+2':`c`=`n' + 2 + `max_`v''''`=`r'+2' = "File 1", merge hcenter bold
						putexcel `c`=`n' + 1''`=`r'+2':`c`=`n' + 2 + `max_`v''''`=`r'+2', border (bottom "vvthick")
						putexcel `c`=`n' + 2''`=`r'+3':`c`=`n' + 2 + `max_`v''''`=`r'+3', border (bottom "vvthick")
						
						* Add note about discordance
						putexcel `c`n''`=`r' + 5 + `max_`v''' ="Note: Any cells highlighted in pink indicate discordance between file 1 and file 2", bold			

						
						* Add pink shading
						local n `=`k' + 5'
						local r `=`r'+3'
						forvalues s = 0/`max_`v'' {
							forvalues t = 0/`max_`v'' {
								if `s'!=`t' {
									if matrix(`v'[`=`s'+1',`=`t'+1']) > 0 putexcel `c`=`n' + 1 + `t'''`=`r' + 1 + `s'', fpattern("solid", "pink")
								}
							}
						}
						
						* Determine the max row number for the mov and elig table
						* If the two tables do not have the same number of rows, you want to use the max
						local f `=max(`v'_r, `=subinstr("`v'","elig","mov",.)'_r)'
									
						local r `=`r' + `f' + 1'
						
						local r`i' `=`r' + 3'
					
					}
				}	 
				
			
			* Add footnote with filenames
			putexcel set ADS_COMPARISON_REPORT.xlsx, modify sheet("`i'")
			putexcel A`r`i''= "Footnote1: File 1 is `file1name'", bold
			putexcel A`=`r`i''+1'= "Footnote2: File 2 is `file2name'", bold
			
			}
		}
********************************************************************************
	
		foreach i in RI_QUAL_09 {
			if `i'_t!=0 {
				local r 1
				foreach v in child_had_mov child_had_only_uncor_mov {
					if "``v'[Indicator]'"=="`i'" {

						nois di "Creating table for `v' in RI_QUAL_09..."

						* Add Message explaning what sheet entails
						putexcel set ADS_COMPARISON_REPORT.xlsx, modify sheet("`i'")
						putexcel A1= "Variables derived during Indicator `i'", bold 
						
						* Add matrix to spreadsheet
						putexcel A`=`r'+ 2' = "`v'", vcenter bold italic
						putexcel B`=`r'+ 3' = matrix(`v'), right names

						putexcel A`=`r'+ 3':A`=`r'+ 6' = "File 2", merge right bold	
						putexcel A`=`r'+ 3':A`=`r'+ 6', border (right "vvthick")
						putexcel B`=`r'+ 4':B`=`r'+ 6', border (right "vvthick")
									
						putexcel B`=`r'+2':E`=`r'+2' = "File 1", merge hcenter bold
						putexcel B`=`r'+2':E`=`r'+2', border (bottom "vvthick")
						putexcel C`=`r'+3':E`=`r'+3', border (bottom "vvthick")
						
						
						* Add pink shading
						if matrix(`v'[2,1])>0 putexcel C`=`r'+5', fpattern("solid", "pink")  
						if matrix(`v'[3,1])>0 putexcel C`=`r'+6', fpattern("solid", "pink")
					
						if matrix(`v'[1,2])>0 putexcel D`=`r'+4', fpattern("solid", "pink")
						if matrix(`v'[3,2])>0 putexcel D`=`r'+6', fpattern("solid", "pink")
					
						if matrix(`v'[1,3])>0 putexcel E`=`r'+4', fpattern("solid", "pink")
						if matrix(`v'[2,3])>0 putexcel E`=`r'+5', fpattern("solid", "pink")
						
						* Add note about discordance
						putexcel A`=`r' + 7' = "Note: Any cells highlighted in pink indicate discordance between file 1 and file 2", bold			
							
						local r `=`r' + `v'_r + 4'
					
					}	
				}
				
				local r 1
				foreach v in child_had_cor_and_uncor_mov child_had_only_cor_mov {
					if "``v'[Indicator]'"=="`i'" {

						nois di "Creating table for `v' in RI_QUAL_09..."

						* Add matrix to spreadsheet
						putexcel G`=`r'+ 2' = "`v'", vcenter bold italic
						putexcel H`=`r'+ 3' = matrix(`v'), right names

						putexcel G`=`r'+ 3':G`=`r'+ 6' = "File 2", merge right bold	
						putexcel G`=`r'+ 3':G`=`r'+ 6', border (right "vvthick")
						putexcel H`=`r'+ 4':H`=`r'+ 6', border (right "vvthick")				
						
						putexcel H`=`r'+2':K`=`r'+2' = "File 1", merge hcenter bold
						putexcel H`=`r'+2':K`=`r'+2', border (bottom "vvthick")
						putexcel I`=`r'+3':K`=`r'+3', border (bottom "vvthick")					
						
						* Add pink shading
						if matrix(`v'[2,1])>0 putexcel I`=`r'+5', fpattern("solid", "pink")
						if matrix(`v'[3,1])>0 putexcel I`=`r'+6', fpattern("solid", "pink")
					
						if matrix(`v'[1,2])>0 putexcel J`=`r'+4', fpattern("solid", "pink")
						if matrix(`v'[3,2])>0 putexcel J`=`r'+6', fpattern("solid", "pink")
					
						if matrix(`v'[1,3])>0 putexcel K`=`r'+4', fpattern("solid", "pink")
						if matrix(`v'[2,3])>0 putexcel K`=`r'+5', fpattern("solid", "pink")
						
						* Add note about discordance
						putexcel G`=`r' + 7'= "Note: Any cells highlighted in pink indicate discordance between file 1 and file 2", bold			
										
						local r `=`r' + `v'_r + 4'
						
						local r`i' `=`r' + 3'
					}	
				}
				
				* Add footnote with filenames
				putexcel set ADS_COMPARISON_REPORT.xlsx, modify sheet("`i'")
				putexcel A`r`i''="Footnote1: File 1 is `file1name'", bold
				putexcel A`=`r`i''+1'="Footnote2: File 2 is `file2name'", bold
		
			}
		}
	}
	****************************************************************************
	* Format each tab
	noisily di "Formatting worksheets..."
	
	quietly {
		*Use mata to populate table formatting
		mata: b = xl()
		mata: b.load_book("ADS_COMPARISON_REPORT.xlsx")
		mata: b.set_mode("open")
		
		mata: b.set_sheet("Summary")
		
		* Format column width
		forvalues i = 2/5 {
			mata: b.set_column_width(`i',`i',12)
		}
		
		* Format columns for Indicator tabs
		foreach d in $RILIST2 {
			if `d'_t!=0 { 
				mata: b.set_sheet("`d'")
			
				* Set column width
				mata: b.set_column_width(1,1,27)
			
				forvalues i = 2/5 {
					mata: b.set_column_width(`i',`i',10)
				}
			}
		}
		
		* Format the columns in RI_QUAL_09 tab
		
		if RI_QUAL_09_t!=0 {
			mata: b.set_sheet("RI_QUAL_09")

			* Set column width
			foreach i in 1 7 {
				mata: b.set_column_width(`i',`i',27)
				forvalues n=1/4 {
					mata: b.set_column_width(`=`i'+`n'',`=`i'+`n'',10)
				}
			}
		}
		
		* Format columns in RI_QUAL_08
		if RI_QUAL_08_t != 0 {
			mata: b.set_sheet("RI_QUAL_08")
			
			mata: b.set_column_width(1,1,27)
			
			forvalues i = 2/`=max(total_elig_visits_valid_r, total_mov_visits_valid_r, total_movs_valid_r)' {
				mata: b.set_column_width(`i',`i',10)
			}
			
			foreach v in `dlist3b' {
				mata: b.set_column_width(`=`k'+ 4',`=`k' + 4',22)
			}
		}

		mata b.close_book()
	}
	nois di "Comparison of Augmented datasets complete"
	
			
end

