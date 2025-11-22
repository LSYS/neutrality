version 13.1
/* This program takes a test-stat its corresponding p-value and manually append
	stars as an indication of significance level. The local macro string output is
	made with LaTeX output from esttab in mind */


capture program drop TestStatSig
program TestStatSig, rclass
	/* 1st value is test-stat, 2nd value is p-value */
	if `2' < 0.001 { /* sig. at 1 percent */
		return local StatStars = string(round(`1', 0.01)) + "^{***}"
	}
	else if 0.001 <= `2' < 0.05 { /* sig. at 5 percent */
		return local StatStars = string(round(`1', 0.01)) + "^{**}"
	}
	
	else if 0.05 <= `2' < 0.1 { /* sig. at 10 percent */
		return local StatStars = string(round(`1', 0.01)) + "^{*}"
	}
	
	else if 0.1 <= `2' {
		return local StatStars = string(round(`1', 0.01))
	}
end
