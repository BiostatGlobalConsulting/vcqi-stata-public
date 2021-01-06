*! set_TO_xlsx_column_width version 1.02 - Biostat Global Consulting - 2018-11-24
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-06-26	1.00	MK Trimner		Original Version copied from MISS-VCQI
* 2018-10-04	1.01	Dale Rhoda		Pull some code out of the inner loop
* 										and switch from putexcel to mata for
*										wordwrap
* 2018-11-24	1.02	Dale Rhoda		If there is no content to the right of
*										column A, or below cell B1 then skip 
*										over this VCQI output sheet; it does
*										NOT need its columns adjusted
*
*******************************************************************************
capture program drop set_TO_xlsx_column_width
program define set_TO_xlsx_column_width

	syntax  , EXCEL(string asis) [ NAME(string asis) values]
	
	qui {
		* If the user specified a .xls or .xlsx extension in EXCEL or NAME
		* strip it off here
		foreach v in excel name {
			if lower(substr("``v''",-4,.)) == ".xls"  ///
				local `v' `=substr("``v''",1,length("``v''")-4)'
			if lower(substr("``v''",-5,.)) == ".xlsx" ///
				local `v' `=substr("``v''",1,length("``v''")-5)'
		}
		
		* Make sure file provided exists
		capture confirm file "`excel'.xlsx"
		if _rc!=0 {
			* If file not found, display error and exit program
			noi di as error "Spreadsheet provided in macro EXCEL does not exist." ///
					" Current value provided was: `excel'"
					
			noi di as error "Exiting program..."
			exit 99
					
		}
		else {
			
			* Describe excel file to determine how many sheets are present
			capture import excel using "`excel'.xlsx", describe
			local f `=r(N_worksheet)'
				
			* If user requests a new file name, create copy and save as NAME
			if "`name'"!="" {
				copy "`excel'.xlsx" "`name'.xlsx", replace
				
				* Set excel local to new file name
				local excel `name'
			}
		
			* Go through each of the sheets
			forvalues b = 1/`f' {
				
				* Bring in the sheet
				capture import excel using "`excel'.xlsx", describe
							
				* Capture the sheet name			
				local sheet `=r(worksheet_`b')'
				
				* Be sure the lower right corner is to the right of and/or below cell B1
				local lower_right_cell `=substr("`=r(range_`b')'",4,.)'
				local right_column     `lower_right_cell'
				
				* strip out all the numbers from the column
				forvalues i = 0/9 {
					local right_column = subinstr("`right_column'","`i'","",.)
				}
				
				* skip this sheet if the lower right corner is in row A or is cell B1
				if "`right_column'" == "A" | "`lower_right_cell'" == "B1" continue				
				
				if "`=upper("`sheet'")'" != "LOG" {
				
					* Capture the last column
					* change starting position to B2
					local range B2:`lower_right_cell'
			
					* Import file
					import excel "`excel'.xlsx", sheet("`sheet'") firstrow clear allstring cellrange(`range')
					
					* Drop any lines that are not relevant
					* Need to check all cells, not just the first
					gen avl = 0
					foreach v of varlist * {
						if "`v'"!="avl" {
							forvalues i = 1/`=_N' {
								replace avl = avl + strlen(`v') in `i'
							}
						}
					}
					drop if avl==0
					drop avl
					
					qui {
						describe
						return list
					}
					
					* If values is not specified turn off option
					if "`values'"=="" local values off
									
					* Format the tabs
					noi di as text "Formatting tab `=`b'-1' out of `=`f'-1'..."
					
					assertlist_cleanup_format, excel(`excel') sheet(`sheet') values(`values')

				}
			}
		}
	}
end

********************************************************************************
********************************************************************************
******							Format Excel Tabs						   *****
********************************************************************************
********************************************************************************

capture program drop assertlist_cleanup_format
program define assertlist_cleanup_format

syntax  , EXCEL(string asis) SHEET(string asis) VALUES(string asis)

	qui {	
	
		mata: b = xl()
		mata: b.load_book("`excel'.xlsx")
		mata: b.set_mode("open")
		mata: b.set_sheet("`sheet'")	
	
		local col 1
		foreach v of varlist * {
			local ++col
			
			* Grab the table column name
			local label `=`v'[1]'
			
			* Grab the label length
			local ll = strlen("`label'")
			
			local width	0
			* Determine if the entire column name is greater than 11 characters
			if `ll'  <= 11 {
				local width `=max(`=`ll' + 2',6)'
			}
			else {
				local wc `: word count `label''
				local max 0
				* Grab the length of the longest word
				forvalues i = 1/`wc' {
					local thiswordlength = strlen("`: word `i' of `label''")
					if `thiswordlength' > `max' local max `thiswordlength'
				}
				
				local width `=max(`=`max' + 2',13)'
				
			}
			
			* if the value option is specified, look at the variable values to
			* determine the column width

			if "`values'"!="off" {
				* Check the longest value length
				* To do this create a temp string variable of current variable
				tempvar vl
				gen `vl'=length(`v')
				
				* Wipe out the first observation as this is the column header
				replace `vl'=. in 1
				summarize `vl'
				
				* Reset the width local to take the max of the previous value or
				* the longest value plus 2
				local width `=max(`=`r(max)' + 2',`width')'
				
				drop `vl'
			}
			
			* Put the new variable name into excel file
			putexcel set "`excel'.xlsx", modify sheet("`sheet'") 
						
			* Wrap the text
			*putexcel `=word("`exlist'",`col')'3, txtwrap
			mata: b.set_text_wrap(3,`col',"on")
				
			* Set the column width
			mata: b.set_column_width(`col',`col',`width')
		}
				
		mata b.close_book()	

	}
end
