*--------------------------------------------------
* Analysis file
* When female leaders believe that men make better leaders: Empowerment in community-based water management in rural Namibia
* 03_analysis-gender.do
* 2020-01-17, final
* Ivo Steimanis, Philipps University Marburg
*--------------------------------------------------


*--------------------------------------------------
* Program Setup
*--------------------------------------------------
version 16              // Set Version number for backward compatibility
set more off            
clear all               
set linesize 80         
macro drop _all        
set scheme lean2 // grayscale scheme, change to preferred graph scheme
* -------------------------------------------------

*--------------------------------------------------
* Directory
*--------------------------------------------------
*set working directions
global workpath ""
global datapath ""
global output ""
* --------------------------------------------------

*--------------------------------------------------
* Description
*--------------------------------------------------

/*
1) Who gets elected into office?
	- Table 1. Socio-demographics
	- Figure A1. Villager perception of the last WPL election
	
2) Adapting democratic principles and values to local customs
	- Table 2. How did WPLs get into office and for how long?
	- Figure 3. What makes a good leader?
	- Figure 4. Democratic principles and leader behavior
	- Table A2. Differences in values between leaders and villagers
	
3) Norm enforcement of leaders in the experiment
	- Figure 5. Rule enforcement in the Experiment
	- Figure A4. Social preferences and personality traits 
	- Table A5. Tobit model
	
4) Villager satisfaction as a function of leaders’ gender, values and behaviour
	- Figure 6. Villager satisfaction with the WPL
	- Table 3. Determinants of villager satisfaction with the performance of WPLs
	- Table A6. Determinants of satisfaction with the WPLs - FULL MODEL
	
*/
*--------------------------------------------------

// Start log-file
capture log close    
log using "$output\troubled_waters.txt", text replace

// Open data file created by cleaning.do
use "$datapath\female_leaders.dta", replace




*--------------------------------------------------
* 1) Who gets elected into office?
*--------------------------------------------------

* Table 1: Socio-demographics
global demo age education rootedness tl_relative d2 better_off 

iebaltab $demo if TL!=1, grpvar(identifier2) rowvarlabels format(%9.2f) ///
	  stdev ftest fmissok  tblnonote save("$output\01_main-manuscript\table1_socio-demographics.xlsx") replace
	  
global binary  tl_relative better_off
global cont age education rootedness d2
foreach var of varlist $binary {
prtest `var', by(fem_WPC) /* within WPC male vs. female */
prtest `var' if id3 > 2, by(id3) /* between villagers */
prtest `var' if id3==1 | id3==3, by(id3) /* male wpcs and male villagers */
prtest `var' if id3==2 | id3==4, by(id3) /* female wpcs and female villagers */
}

foreach var of varlist $cont {
ranksum `var', by(fem_WPC) /* within WPC male vs. female */
ranksum `var' if id3 > 2, by(id3) /* between villagers */
ranksum `var' if id3==1 | id3==3, by(id3) /* male wpcs and male villagers */
ranksum `var' if id3==2 | id3==4, by(id3) /* female wpcs and female villagers */
}
ranksum age, by(fem_WPC) /* within WPC male vs. female */
ranksum education, by(fem_WPC) /* within WPC male vs. female */
ranksum d2 if id3==1 | id3==3, by(id3) /* male wpcs and male villagers */
ranksum d2 if id3==2 | id3==4, by(id3) /* male wpcs and male villagers */

*Figure A1. Villager perception of the last WPL election
preserve
rename d_b7a le1
rename d_b7c le2
rename d_b7d le3
rename d_b7e le4
rename d_b7f le5

reshape long le ,i(id) j(le_id)
label define le1 1 "(1) Trustworthy" 2 "(2) Intimidation" 3 " (3) Promises" 4 " (4) Paid voters" 5 "(5) Pressure"
label values le_id le1

cibar le if b5a==1, over1(f_wpc) over2(le_id) bargap(10) barlabel(on) blpos(11) graphopts(legend(pos(12) ring(0) rows(1) size(medium))  yla(0(0.2)1) title("", size(medium)) ytitle("Percent", size(medium))) ciopts(lpattern(dash) lcolor(black))
graph save "$output\figure-A1_last-election.gph", replace
graph export "$output\02_appendix\figure-A1_last-election.tif", replace width(7100)

restore




*--------------------------------------------------
* 2) Adapting democratic principles and values to local customs
*--------------------------------------------------

*Table 2: How did they get into office?
global LE_wpc dcompetitor elected secretelec term experience turnout  f2c f11 new_term

iebaltab $LE_wpc if id < 65, grpvar(fem_WPC) total rowvarlabels format(%9.2f) stdev ftest fmissok  tblnonote save("$output\01_main-manuscript\table2_office-attainment.xlsx") replace
	   
pwcorr term experience, sig
foreach var of varlist $LE_wpc {
	ranksum `var', by(fem_WPC)
	 tab `var' fem_WPC,  chi2 V
	}
	
* Office attainment by relation to traditional leader
iebaltab $LE_wpc if TL==0, grpvar(tl_relative) rowvarlabels format(%9.2f) stdev ftest fmissok  tblnonote save("$output\office-attaiment-related-TL.xlsx") replace
*relatives of chief are less likely to state that they want to run for another term
* 100% for non-relatives and only 79% of relatives


*Figure 3. What makes a good leader?
preserve
rename new_c2 who1
rename new_c7 who2
rename new_c11 who3
rename new_c12 who4

reshape long who ,i(id) j(who_id)
label define who1 1 "(1) Most people" 2 "(2) Men" 3 "(3) Education" 4 "(4) Elderly"
label values who_id who1

cibar who, over1(id4) over2(who_id) bargap(0) gap(80) barlabel(on) blpos(11) blgap(0.01) blsize(7pt) blfmt(%9.1f) graphopts(legend(pos(12) ring(0) rows(1) size(7pt)) xsize(3.4) ysize(2) yla(1(1)5) title("", size(8pt)) ytitle("Mean", size(6pt))) ciopts(lpattern(dash) lcolor(black))
graph save "$output\figure3_what-makes-a-good-leader.gph", replace
graph export "$output\01_main-manuscript\figure3_what-makes-a-good-leader.tif", replace width(3400)
restore

*non-parametric tests for differences
ranksum new_c2 if id4>1, by(id4)
ranksum new_c2 if id4<3, by(id4)
ranksum new_c7 if id4>1, by(id4)
ranksum new_c7 if id4<3, by(id4)
ranksum new_c11 if id4>1, by(id4)
ranksum new_c11 if id4<3, by(id4)
ranksum new_c12 if id4>1, by(id4)
ranksum new_c12 if id4<3, by(id4)

*joint orthogonality F-test
global who new_c2 new_c7 new_c11 new_c12
reg id4 $who if id4 > 1, vce(robust)
test $who
reg id4 $who if id4 < 3, vce(robust)
test $who


* Table A2. Differences in values between leaders and villagers
global leadership d_c2 d_c7 d_c11 d_c12 d_c1 d_c3 d_c8 d_c9  d_c5
	
iebaltab $leadership, grpvar(id3) rowvarlabels onerow format(%9.2f) ///
	  stdev ftest fmissok tblnonote save("$output\02_appendix\table-A2_differences-democratic-values.xlsx") replace

foreach var of varlist $leadership {
	prtest `var', by(fem_WPC) /* within WPC male vs. female */
	prtest `var', by(TL) /* between leader types */
	prtest `var' if id3 > 2, by(id3) /* between villagers */
	prtest `var' if id3==1 | id3==3, by(id3) /* male wpcs and male villagers */
	prtest `var' if id3==2 | id3==4, by(id3) /* female wpcs and female villagers */
	}

prtest d_c7 if id3 > 2, by(id3)
* Female villagers are 12 pp less likely to agree that “men make better political leaders” 
* compared to male villagers (Proportion test, z=2.55, p < 0.05, n=384). 


*Figure 4. Democratic principles and leader behavior
preserve
rename new_c1 principle1
rename new_c3 principle2
rename new_c8 principle3
rename new_c9 principle4

reshape long principle ,i(id) j(pr_id)
label define pr1 1 "(1) Group voting" 2 "(2) Accountability" 3 "(3) No nepotism" 4 "(4) Bribes"
label values pr_id pr1

cibar principle, over1(id4) over2(pr_id) bargap(0) gap(80) barlabel(on) blpos(11) blgap(0.01) blsize(7pt) blfmt(%9.1f) graphopts(legend(pos(12) ring(1) rows(1) size(7pt)) xsize(3.4) ysize(2) yla(1(1)5) title("", size(8pt)) ytitle("Mean", size(6pt))) ciopts(lpattern(dash) lcolor(black))

graph save "$output\figure4_democratic-principles.gph", replace
graph export "$output\01_main-manuscript\figure4_democratic-principles.tif", replace width(3400)
restore

*non-parametric tests for differences
ranksum new_c1 if id4>1, by(id4)
ranksum new_c1 if id4<3, by(id4)
ranksum new_c3 if id4>1, by(id4)
ranksum new_c3 if id4<3, by(id4)
ranksum new_c8 if id4>1, by(id4)
ranksum new_c8 if id4<3, by(id4)
ranksum new_c9 if id4>1, by(id4)
ranksum new_c9 if id4<3, by(id4)

*joint orthogonality F-test
global principle new_c1 new_c3 new_c8 new_c9
reg id4 $principle if id4 > 1, vce(robust)
test $principle
reg id4 $principle if id4 < 3, vce(robust)
test $principle




*--------------------------------------------------
* (3) Norm enforcement of leaders in the experiment
*--------------------------------------------------

*Figure 5. Rule enforcement in the Experiment
preserve
rename PSP_NN intens_1
rename ASP_NN intens_2

reshape long intens_ ,i(id) j(intens_id)
label define p_lab1 1 "PSP" 2 "ASP" 
label values intens_id p_lab1


cibar intens_, over1(fem_WPC) over2(intens_id) bargap(0) gap(80) barlabel(on) blpos(11) blgap(0.01) blsize(7pt) blfmt(%9.1f) graphopts(legend(pos(12) rows(1) ring(0) size(6pt))  yla(0(1)6) xsize(1.7) ysize(2) title("{bf:a:} Intensity", size(8pt))  ytitle("mean", size(6pt))) ciopts(lpattern(dash) lcolor(black))
graph save "$output\figure5_panelA-punishment-intensity.gph", replace
restore

preserve
rename p_freq_nn freq_1
rename asp_freq_nn freq_2
reshape long freq_ ,i(id) j(freq_id)
label define p_freq1 1 "PSP" 2 "ASP" 
label values freq_id p_freq1

cibar freq_, over1(fem_WPC) over2(freq_id) bargap(0) gap(80) barlabel(on) blpos(11) blgap(0.01) blsize(7pt) blfmt(%9.1f) graphopts(legend(pos(12) rows(1) ring(0) size(6pt))  yla(0(0.2)1) xsize(1.7) ysize(2) title("{bf:b:} Frequency", size(8pt))  ytitle("mean", size(6pt))) ciopts(lpattern(dash) lcolor(black))
graph save "$output\figure5_panelB-punishment-intensity.gph", replace
restore

grc1leg "$output\figure5_panelA-punishment-intensity.gph" "$output\figure5_panelB-punishment-intensity.gph" , legendfrom("$output\figure5_panelA-punishment-intensity.gph") position(6) ring(1)  col(2) saving("$output\figure5_rule-enforcement-TG.gph", replace)
gr save "$output\figure5_rule-enforcement-TG.gph", replace
gr export "$output\01_main-manuscript\figure5_rule-enforcement-TG.tif", replace width(3400)

*significance tests
ranksum PSP_NN, by(fem_WPC)
ttest PSP_NN, by(fem_WPC)
* Mann Whitney-U p=0.13; ttest p=0.049
ranksum ASP_NN, by(fem_WPC)
* p=0.38
prtest p_freq_nn, by(fem_WPC)
*p=0.27
prtest asp_freq_nn, by(fem_WPC)
* p=0.28


*Figure A4. Social preferences and personality traits
preserve
replace decision1=decision1-1
replace decision2=decision2-1
replace decision3=decision3-1
lab def a_b 0 "A" 1 "B"
foreach var of varlist decision1-decision3 {
	lab val `var' a_b
	}
reshape long decision ,i(id) j(dec_id)
label define l_dec1 1 "Pro-social Game" 2 "Sharing Game" 3 "Envy Game"
label values dec_id l_dec1


cibar decision, over1(identifier2) over2(dec_id) bargap(20) gap(110) barlabel(on) blpos(11) graphopts(legend(pos(12) ring(0) rows(1) size(medium)) xsize(7.1)yla(0(0.2)1)  title("{bf:a:} Pro-social preferences", size(medium)) ytitle("Share B", size(medium))) ciopts(lpattern(dash) lcolor(black))
graph save "$output\figureA4_panelA-prosocial-preferences.gph", replace
restore

preserve
rename extraversion_normal bigfive1
rename agreeableness_normal bigfive2
rename conscientiousness_normal bigfive3
rename neuroticism_normal bigfive4
rename openness_normal bigfive5

reshape long bigfive, i(id) j(big5_id)
label define big5 1 "extraversion" 2 "agreeableness" 3 "conscientiousness" 4 "neuroticism" 5 "openness"
label values big5_id big5

cibar bigfive, over1(fem_WPC) over2(big5_id) bargap(20) gap(110) barlabel(on) blpos(11) graphopts(legend(pos(12) ring(0) rows(1) size(medium)) xsize(7.1)yla(0(0.2)1)  title("{bf:b:} Personality traits", size(large)) ytitle("mean", size(medium))) ciopts(lpattern(dash) lcolor(black))
graph save "$output\figureA4_panelB-personality-traits.gph", replace
restore

gr combine "$output\figureA4_panelA-prosocial-preferences.gph" "$output\figureA4_panelB-personality-tratits.gph" , rows(2) xsize(7.1) ysize(6)
gr export "$output\02_appendix\figure-A4-prosocial-preferences-big5.tif", replace width(7100)


*Table A5. Tobit model
tobit PSP_NN fem_WPC, ll(0) ul(40)
outreg2 using "$output\02_appendix\tableA5_tobit-intensity-PSP", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  replace
tobit PSP_NN fem_WPC age education hhsize married better_off, ll(0) ul(40)
outreg2 using "$output\02_appendix\tableA5_tobit-intensity-PSP", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  append




*---------------------------------------------------------------------------------
* (4) Villager satisfaction as a function of leaders’ gender, values and behaviour
*---------------------------------------------------------------------------------

*Figure 6. Villager satisfaction with the WPL
global vil_sat d_swpc d_b8a d_b8b d_b8c d_b8d

catplot new_b10b f_wpc if know_wpc==1, percent(f_wpc) recast(bar) blabel(bar, size(7pt) format(%9.1f) pos(12)) title("") yla(0(25)100) xsize(3.4) ysize(2)
gr export "$output\01_main-manuscript\figure6_villager-satisfaction.tif", replace width(3400)
ranksum new_b10b if know_wpc==1, by(f_wpc)


*Table 3. Determinants of Villager satisfaction with the performance of WPL
*GETS model
*preperation for regression analysis


global socio_vil male age education wpc_relative better_off pca_wealth
global l_socio f_wpc high_l_age l_related l_edu 
global l_lab l_psp l_asp l_dec2 l_dec3 /*no variation (only 3 leaders choose b) in dec1 wrt to satisfaction */
global l_principle l_new_c1 l_new_c3 l_new_c8 l_new_c9
global l_who l_new_c2 l_new_c7 l_new_c11 l_new_c12

genspec d_swpc d_b8a d_b8b d_b8c d_b8d $socio_vil $l_socio $l_lab $l_who $l_priciple if know_wpc==1 , vce(robust)
outreg2 using "$output\01_main-manuscript\table3_determinants-villager-satisfaction-GETS", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  replace


*Table A6. Determinants of satisfaction with the WPLs - FULL MODEL
probit d_swpc d_b8a d_b8b d_b8c d_b8d if know_wpc==1, vce(robust)
mfx2, replace
test d_b8a d_b8b d_b8c d_b8d /* jointly significant chi2(4)=12.48 p=0.014 */
outreg2 using "$output\02_appendix\table-A6_probit-determinants-villager-satisfaction", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  replace
probit d_swpc d_b8a d_b8b d_b8c d_b8d $socio_vil if know_wpc==1, vce(robust)
mfx2, replace
test $socio_vil /* jointly insignificant p>0.3173 */
outreg2 using "$output\02_appendix\table-A6_probit-determinants-villager-satisfaction", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  append
probit d_swpc d_b8a d_b8b d_b8c d_b8d $socio_vil $l_socio if know_wpc==1, vce(robust)
mfx2, replace
test $l_socio  /* jointly significant Chi2(4)=7.85 p=0.0973 */
outreg2 using "$output\02_appendix\table-A6_probit-determinants-villager-satisfaction", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  append
probit d_swpc d_b8a d_b8b d_b8c d_b8d $socio_vil $l_lab  if know_wpc==1, vce(robust)
mfx2, replace
test $l_lab /* jointly insignificant F=3.44 p=0.49 */
outreg2 using "$output\02_appendix\table-A6_probit-determinants-villager-satisfaction", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  append
probit d_swpc d_b8a d_b8b d_b8c d_b8d $socio_vil $l_who if know_wpc==1, vce(robust)
mfx2, replace
test $l_who /*jointly insignificant p=0.17, most people can learn to be leaders is significant */
outreg2 using "$output\02_appendix\table-A6_probit-determinants-villager-satisfaction", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  append
probit d_swpc d_b8a d_b8b d_b8c d_b8d $socio_vil $l_principle if know_wpc==1, vce(robust)
mfx2, replace
test $l_principle /*jointly insignificant p=0.29 */
outreg2 using "$output\02_appendix\table-A6_probit-determinants-villager-satisfaction", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  append
probit d_swpc d_b8a d_b8b d_b8c d_b8d $socio_vil $l_socio $l_lab $l_who $l_priciple  if know_wpc==1, vce(robust)
mfx2, replace
outreg2 using "$output\02_appendix\table-A6_probit-determinants-villager-satisfaction", addstat(Pseudo R-squared, e(r2_p)) adec(2) dec(2) word  append
