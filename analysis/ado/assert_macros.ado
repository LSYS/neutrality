capture program drop assert_macros
program define assert_macros
    args macros
	///////////////////////////////////////////////////////////////////////////////
	// Description:
	// ------------
	//		Asserts that global macro(s) are defined (not empty).
	//
	// Syntax: 
	// -------
	// 		assert_macros "macro1 macro2 ..."
	// MWE:
	// ----
	// 		sysuse auto
	//		global m1 price make
	// 		corr_pval
	//		assert_macros "m1 m2"
	//////////////////////////////////////////////////////////////////////////////		
	if "`macros'"!="" {
		foreach global_macro in `macros' {
			dis "Checking `global_macro':"
			capture assert "$`global_macro'" != ""
        	if _rc == 0 {
            	display "`global_macro' contains: $`global_macro'"
        	}
        	else if _rc != 0 {
            	display in red "`global_macro' is empty (not defined)."
        	}
		}
	}
	else {
		noisily dis "No macros stated..."
	}
end
