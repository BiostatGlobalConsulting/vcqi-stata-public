*! shift_RI_dates version 1.01 - Biostat Global Consulting - 2018-11-12
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-06-19	1.00	MK Trimner		Original version
* 2018-11-12	1.01	MK Trimner		?
*******************************************************************************

* This program can be used to shift doses between each other
* For example: If boosters were received or a campaign completed
* This program will move any doses received from the secondary source (booster or campaign) and replace the primary dose if missing.

********************************************************************************
* Program Syntax
* Required Option:
*
* SHIFTTO -- 	format: 		string
*				description:	list of dose(s) that you would like to populate with SHIFTFROM list if missing
*				note:			dose name provided must match the same dose name used in the VCQI ready dataset
*				note2:			list may be 1 or more dose names
*				note3:			list doses in chronological order as they should have been received
* 				example: 		dpt1 dpt2 dpt3
*
* SHIFTFROM --	format:			string
*				description:	list of dose(s) that will populate the doses provided in the SHIFTTO list when missing
*				note1:			dose name provided must match the same dose name used in the VCQI ready dataset
*				note2: 			if specified list may contain 1 or more dose names
*				note3:			list doses in chronological order as they should have been recieved
*				example:		dpt4 dpt5
*
********************************************************************************
* Examples
*	example1:	SHIFTTO(dpt1 dpt2 dpt3) SHIFTFROM(dpt4 dpt5)
*
*	Raw data:						Shifted date:			
*		dpt1 - 2/7/2015					dpt1 - 2/7/2015
*		dpt2 - Missing					dpt2 - 6/7/2015
*		dpt3 - Missing					dpt3 - 7/15/2015
*		dpt4 - 6/7/2015					dpt4 - Missing
*		dpt5 - 7/15/2015				dpt5 - Missing
*
*	example2:	SHIFTTO(dpt1 dpt2 dpt3) SHIFTFROM(dpt4 dpt5)
*
*	Raw data:						Shifted date:			
*		dpt1 - 2/7/2015					dpt1 - 2/7/2015
*		dpt2 - Missing					dpt2 - Tick set --> Since dpt3 is populated this will be set as a tick and not date shifted
*		dpt3 - 5/21/2015				dpt3 - 5/21/2015
*		dpt4 - 6/7/2015					dpt4 - 6/7/2015
*		dpt5 - 7/15/2015				dpt5 - 7/15/2015
*								
*	example3:	SHIFTTO(dpt1 dpt2 dpt3) SHIFTFROM(dpt4 dpt5)
*
*	Raw data:						Shifted date:			
*		dpt1 - 2/7/2015					dpt1 - 2/7/2015
*		dpt2 - 5/21/2015				dpt2 - 5/21/2015 
*		dpt3 - Missing					dpt3 - 7/15/2015
*		dpt4 - Missing					dpt4 - Missing
*		dpt5 - 7/15/2015				dpt5 - Missing
********************************************************************************
* General Notes:
* Program uses 3 other sub programs. 
*		1. dose_shift_program	
*		2. make_RI_dates_shifted_preprocess
*		3. make_RI_dates_shifted_from
*
* Program uses the function ROWSORT. If this is not already installed please do so before running...
*
* Program requires that the below globals be populated in the control program
* global NUM_DOSE_SHIFTS -- format:			integer
*							description:	Number of dose shifts that need to be completed. 
*							note1:			default is 0 - no dose shifts
*							note2:			if you would like to complete a shift for
*											opv and dpt NUM_DOSE_SHIFTS should be set to 2
*
* For each desired shift the below globals need to be populated with the corresponding
* shift number in place of the #. So # will be 1/NUM_DOSE_SHIFTS value. 
* Each of these globals are described in detail above.
*
* global SHIFTTO_#		dose list
* global SHIFTFROM_#	dose list
*
********************************************************************************/
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2018-06-26	1.00	MK Trimner		original copied from MISS-VCQI
* 2018-11-12	1.01	MK Trimner		- Added document type to created var so 
*										this program can run for card and register
*										- Cleaned up some comments/code that reflected
*										previous versions
*******************************************************************************
capture program drop shift_RI_dates
program define shift_RI_dates

	forvalues i = 1/$NUM_DOSE_SHIFTS {
		dose_shift_program, shiftto(${SHIFTTO_`i'}) shiftfrom(${SHIFTFROM_`i'})
	}
	
end

********************************************************************************
********************************************************************************
****						dose_shift_program								****
********************************************************************************
********************************************************************************
capture program drop dose_shift_program
program define dose_shift_program

	syntax ,  SHIFTTO(string asis) SHIFTFROM(string asis)
	
	no di as text "This program requires the rowsort function to be installed"
	no di as text "Begin shifting dose dates and ticks..."
	
	quietly {
	
		* Determine if the shift needs to occur on card and register datasets
		if "$RI_RECORDS_NOT_SOUGHT" == "1" 	local source card
		
		if "$RI_RECORDS_SOUGHT_FOR_ALL" == "1" | ///
		"$RI_RECORDS_SOUGHT_IF_NO_CARD" == "1" local source card register
	
		* Reset SHIFTTO and SHIFTFROM to be lowercase
		foreach v in shiftto shiftfrom {
			if "``v''"!="" {
				local `v' `=lower("``v''")'
			}
		}
		
		* Complete for each data source
		foreach s in `source' {
				
			* First step is to clean up the data
			noi preprocess_cleanup, shiftto(`shiftto') shiftfrom(`shiftfrom') s(`s')
			
			* Shift dates from SHIFTFROM to SHIFTTO list
			shiftfrom, shiftto(`shiftto') shiftfrom(`shiftfrom') s(`s') vlist(`vlist') 
			
			* Only keep the original variables and newly created 
			* variables that show any shifts 
			keep `vlist'
					
			save, replace
		}
	}
end

********************************************************************************
********************************************************************************
****						preprocess_cleanup								****
********************************************************************************
********************************************************************************
capture program drop preprocess_cleanup
program define preprocess_cleanup

syntax ,  SHIFTTO(string asis) s(string asis) SHIFTFROM(string asis)

qui {

	* Clean up ticks
	no di as text "Remove any ticks if a date is present..."
	foreach v in `shiftto' `shiftfrom' {
		replace `v'_`s'_tick=. if !missing(`v'_`s'_date)
	}
	
	* Wipe out SHIFTFROM date if it is the same as any SHIFTTO dates
	* Do not set the tick mark for SHIFTFROM dose
	foreach b in `shiftfrom' {
		foreach v in `shiftto' {
			gen `b'_date_same_`v'_`s'= `b'_`s'_date == `v'_`s'_date 
			replace `b'_date_same_`v'_`s' = 0 if missing(`b'_`s'_date) & missing(`v'_`s'_date)
					
			label var `b'_date_same_`v'_`s' "`=proper("`s'")' - `b' has the same date as `v', `b' is wiped out"
	
			replace `b'_`s'_date=. if `b'_date_same_`v'_`s'==1
		
			* Only keep the variable if applies to doses in dataset 
			summarize `b'_date_same_`v'_`s' 
			if `=r(max)'==0 drop `b'_date_same_`v'_`s' 	
		}
	}
	
	* Create a local to pass through with all variables that need to be kept
	unab vlist : _all
	c_local vlist `vlist'
}

end

********************************************************************************
********************************************************************************
****							shiftfrom									****
********************************************************************************
********************************************************************************
capture program drop shiftfrom
program define shiftfrom

syntax ,  SHIFTTO(string asis) s(string asis) SHIFTFROM(string asis) VLIST(varlist)

qui {
	
	* If a later dose is received but previous dose missing in shiftto list
	* Keep previous missing doses blank
	* Create variable that will show this option 
	gen still_fill=1
		
	local a 
	foreach v in `shiftto' {
		local a `v' `a'
	}
		
	* Create new variable that shows list of doses that are still missing
	* This list will only include doses after the last received dose
	* Any previous missing doses are not included
	gen empty_list=""
	
	foreach v in `a' {
		replace still_fill=0 if !missing(`v'_`s'_date) | `v'_`s'_tick==1
		replace empty_list="`v'" + "_" + empty_list if still_fill==1
	}
	

	no di as text "Make replacements from `shiftfrom' to `shiftto'"	
	
	* Create local to show card or register
	local c card
	if "`s'"=="register" local c reg
	
	forvalues i = 1/`=wordcount("`shiftto'")' {
		local dosei `=word("`shiftto'",`i')'
		gen include_`dosei'= strpos(empty_list,"`=word("`shiftto'",`i')'")>0 
		
		* Only complete the below steps if dose appears in empty_list
		forvalues j = 1/`=wordcount("`shiftfrom'")' {
			local dosej `=word("`shiftfrom'",`j')'
								
			gen shift_from_`dosej'_to_`dosei'_`c' = (missing(`dosei'_`s'_date) & `dosei'_`s'_tick!=1) & ///
											(!missing(`dosej'_`s'_date) | `dosej'_`s'_tick==1) & include_`dosei'==1
											
			label variable shift_from_`dosej'_to_`dosei'_`c' "`=proper("`s'")' - `dosej' date and tick moved to `dosei' from SHIFTFROM list" 
											
			replace `dosei'_`s'_date = `dosej'_`s'_date if shift_from_`dosej'_to_`dosei'_`c' == 1
			
			replace `dosei'_`s'_tick=`dosej'_`s'_tick if shift_from_`dosej'_to_`dosei'_`c' == 1
			
			replace `dosej'_`s'_date = . if shift_from_`dosej'_to_`dosei'_`c' == 1
			
			replace `dosej'_`s'_tick=. if shift_from_`dosej'_to_`dosei'_`c' == 1
			
			* Drop generated variable if no one is in the group
			summarize shift_from_`dosej'_to_`dosei'_`c'
			if `=r(max)'==0  drop shift_from_`dosej'_to_`dosei'_`c'
						
			* Add to var list if someone is in the group
			else local vlist `vlist' shift_from_`dosej'_to_`dosei'_`c'
		
			
		}
	}

	* pass through the local vlist
	c_local vlist `vlist'
}
end
