*! excel_box_border_using_mata version 1.01 - Biostat Global Consulting - 2017-08-26
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2017-08-26	1.01	Mary Prier		Added version 14.1 line
*******************************************************************************

program define excel_box_border_using_mata
	version 14.1
	
	/*
		Inputs:
		1   top row number
		2   bottom row number
		3   left column number
		4   right column number
		5   line style
		6   line color
	*/

	local trow  `1'
	local brow  `2'
	local lcol  `3'
	local rcol  `4'
	local style `5'
	local color `6'
	if "`style'" == "" local style medium
	if "`color'" == "" local color black
	
	mata: b.set_left_border  ( ( `trow', `brow'), (`lcol', `lcol'), "`style'", "`color'" )
	mata: b.set_right_border ( ( `trow', `brow'), (`rcol', `rcol'), "`style'", "`color'" )
	mata: b.set_top_border   ( ( `trow', `trow'), (`lcol', `rcol'), "`style'", "`color'" )
	mata: b.set_bottom_border( ( `brow', `brow'), (`lcol', `rcol'), "`style'", "`color'" )

end 
