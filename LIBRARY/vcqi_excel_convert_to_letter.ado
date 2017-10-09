*! vcqi_excel_convert_to_letter Version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

* I have coded up the algorithm from
* http://stackoverflow.com/questions/22708/how-do-i-find-the-excel-column-name-that-corresponds-to-a-given-integer
* and it seems to work well.
*
* I use the same inputs and outputs as Mary's earlier program.

program define vcqi_excel_convert_to_letter, rclass  
	version 14.1
	
	* Input:
	*  1 Excel column number reference  
	
	args n
	
	local result
	while (`n'>0) {
		local --n  
		local name `=char(`=65+mod(`n',26)')'`name'
		local n = int(`n'/26)
	}
	return local ConvertToLetter `name'

end

