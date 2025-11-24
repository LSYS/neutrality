local SAVEPATH ./figureD2/specest-semantic
use `SAVEPATH', clear

gsort beta
* rank

global covariates time length ind article portfolio rank portfoliorank elec
global outcomes ce_max_quote2speech
global topics topic1 topic2 topic3 topic4 topic5 topic6 topic7 topic8 topic9

global ivar $covariates $outcomes $topics

// duplicates drop $ivar, force
gen porder=_n


* GRAPH SETTINGS
local INDICATOR_SIZE    tiny
local INDICATOR_OFF_COLOR  gs14
local INDICATOR_ON_COLOR   black
local CI95_COLOR        gs14
local CI90_COLOR        gs12
local MSIZE             vsmall
local MAIN_MSIZE        small
local MAINCOLOR            maroon
local MAINSYMBOL        dh
local ILABSIZE          tiny
local INDICATOR_MAIN_SIZE  vsmall
* gen indicators and scatters
   local scoff=" "
   local scon=" "
   local ind=-10
   foreach var in $outcomes {
      cap gen i_`var'=`ind'
      local scoff="`scoff' (scatter i_`var' porder,msize(`INDICATOR_SIZE') mcolor(`INDICATOR_OFF_COLOR'))" 
      local scon="`scon' (scatter i_`var' porder if `var'==1,msize(`INDICATOR_SIZE') mcolor(`INDICATOR_ON_COLOR'))" 
      local ind=`ind'-0.4
   }
   local ind=`ind'-0.6
   foreach var in $covariates {
      cap gen i_`var'=`ind'
      local scoff="`scoff' (scatter i_`var' porder, msize(`INDICATOR_SIZE') mcolor(`INDICATOR_OFF_COLOR'))" 
      local scon="`scon' (scatter i_`var' porder if `var'==1,msize(`INDICATOR_SIZE') mcolor(`INDICATOR_ON_COLOR'))" 
      local ind=`ind'-0.4
   }
   local ind=`ind'-0.6

   foreach var in $topics {
      cap gen i_`var'=`ind'
      local scoff="`scoff' (scatter i_`var' porder,msize(`INDICATOR_SIZE') mcolor(`INDICATOR_OFF_COLOR'))" 
      local scon="`scon' (scatter i_`var' porder if `var'==1,msize(`INDICATOR_SIZE') mcolor(`INDICATOR_ON_COLOR'))" 
      local ind=`ind'-0.4
   }


* plot
#delimit;
tw (rarea u95 l95 porder, fcolor(`CI95_COLOR') lcolor(`CI95_COLOR') lwidth(none)) 
   (rarea u90 l90 porder, fcolor(`CI90_COLOR') lcolor(gs16) lwidth(none))
   (scatter beta porder if main!=1, mcolor(black) msymbol(o) mlwidth(vvvthin) msize(`MSIZE')) 
   (scatter beta porder if main==1, mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL') mlwidth(thin) msize(`MAIN_MSIZE'))    
   `scoff' 
   `scon'  
   /* Manually add in indicators for main spec */
   (scatter i_time porder              if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))     
   (scatter i_length porder            if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))          
   (scatter i_ind porder               if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))          
   (scatter i_article porder           if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))          
   (scatter i_portfolio porder            if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))          
   (scatter i_rank porder              if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))         
   (scatter i_portfoliorank porder        if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))          
   (scatter i_ce_max_quote2speech porder  if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))          
   (scatter i_topic5 porder            if main==1, msize(`INDICATOR_MAIN_SIZE') mcolor(`MAINCOLOR') msymbol(`MAINSYMBOL'))          
  ,legend(order(4 "Main specification"  1 "95% CI" 2 "90% CI") region(lcolor(white)) 
   pos(10) ring(0) rows(1) size(tiny) symysize(small) symxsize(small)
   ) 
   xtitle(" ") ytitle(" ") 
   yscale(noline) xscale(noline) 
   ylab(-8(2)0,noticks nogrid angle(horizontal) labsize(tiny))
   xlab("", noticks)  
   graphregion (fcolor(white) lcolor(white) margin(0 0 0 0) )
   plotregion(fcolor(white) lcolor(white) margin(0 1 0 1) )
;
#delimit cr

gr_edit .yaxis1.add_ticks -9.9 `"{bf:Outcome is semantic accuracy}"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )

gr_edit .yaxis1.add_ticks -10.6 `"{bf:Covariates}"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -11.0 `"Time fixed effects"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -11.4 `"Speech/article length"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -11.8 `"Individual controls"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -12.2 `"Article controls"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -12.6 `"Ministerial portfolio"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -13.0 `"Ministerial rank"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -13.4 `"Ministerial portfolio {it:{bf:x}} rank"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -13.8 `"Electoral controls"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )

gr_edit .yaxis1.add_ticks -14.4 `"{bf:Topic modelling specification}"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -14.8 `"Speech K = 50, Article K = 30"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -15.2 `"Speech K = 50, Article K = 40"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -15.6 `"Speech K = 50, Article K = 50"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -16.0 `"Speech K = 92, Article K = 30"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -16.4 `"Speech K = 92, Article K = 40"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -16.8 `"Speech K = 92, Article K = 50"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -17.2 `"Speech K = 100, Article K = 30"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -17.6 `"Speech K = 100, Article K = 40"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )
gr_edit .yaxis1.add_ticks -18.0 `"Speech K = 100, Article K = 50"', custom tickset(major) editstyle(tickstyle(textstyle(size(`ILABSIZE'))) )

// savefig, path($FIGSAVEDIR/specchart-semantic) format($graphformats) override(width(1200))
