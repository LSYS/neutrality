capture program drop count_unique
program count_unique, rclass
    syntax varlist(min=1 max=1) [if] [in], [print(string)]
    marksample i_use, strok
    ///////////////////////////////////////////////////////////////////////////////
    // Description:
    // ------------
    //      Counts unique values in a variable (including strings).
    //
    // Syntax: 
    // -------
    //      count_unique var [if] [in], [print(string)]
    // MWE:
    // ----
    //      sysuse auto
    //      count_unique make
    //      return list
    ////////////////////////////////////////////////////////////////////////////// 
    preserve
    tempvar i_first
    
    keep if `i_use'
    bysort `varlist': gen byte `i_first' = (_n==1) & ~missing(`varlist')
    
    if "`print'"!="" {
        count if `i_first'
    }
    else {
        qui count if `i_first'
    }
    restore
    return scalar uval = r(N)
    display as result r(N)
end
