**************************************************************************
*                     Project: MEPS                          			 *
**************************************************************************
* purpose:   : Running the two-part models
* authors	 : Ha Tran (ngocha61084@gmail.com)
* first draft: December 30, 2016
* last update: December 30, 2016
* category   : Data process
* version    : 1230
**************************************************************************

*********************************
* 0. Table of Contents		    *
*********************************

* 1a. Basics
* 1b. Directories
* 2. Run models
* 3. Save and exit


*********************************
* 1a. Basics					*
*********************************

clear all
version 14.1
set more off
set varabbrev off
capture log close
global version = "1230"
set mat 200

*********************************
* 1b. Directories				*
*********************************

local user = 1				// 1 -> Ha (local) | 2 -> XXX

if `user' == 1 {	

	global main		= "C:\Users\hatra\Box Sync\Collaboration Work\MEPS\Data"
	global data_orig= "$main\data_orig"
	global data_proc= "$main\data_proc"
	global log   	= "$main\log"
	global do		= "$main\do"
	global graph	= "$main\graph"
	global table	= "$main\table"
	global temp		= "$main\temp"	
	global output   = "$main\output"
}

else if `user' == 2 {

	global main  	= ""
	global data_orig= ""
	global data_proc= ""
	global data		= ""
	global log   	= ""
	global do		= ""
	global graph	= ""
	global table	= ""
	global temp		= ""	
}		


*********************************
* 2. Run Models					*
*********************************
foreach y in 07 08 12 14 {
	use "$output/H172_final07_14", clear
	keep if YEAR==20`y'
	save "$output/MEPS_final_`y'", replace
}


foreach y in 07 08 12 14 {
log using "$log/MEPS_analysis_`y'_$version.log", replace
use "$output/MEPS_final_`y'", clear
svyset [pweight=PERWTF], strata(VARSTR) psu(VARPSU)

/*	Generate discrete choice dependent variables: yes/no for having any visit, any physician visit, any PC visits, any ER visit	*/

gen visit=1 if visit_total>0
replace visit=0 if visit==. & visit_total==0
label variable visit "Probability of having any visit:1= yes;0=no"
gen visit_phy=1 if visit_total_phy>0
replace visit_phy=0 if visit_total_phy==0
label variable visit_phy "Probability of having any physician visits:1=yes; 0=no"
gen visit_pc=1 if pc_visit_total>0&pc_visit_total!=.
replace visit_pc=0 if visit_pc==.
label variable visit_pc "Prob of having a PC visit: 1=  yes, 0=no"
gen visit_ER=1 if ERTOT>0
replace visit_ER=0 if visit_ER==.
label variable visit_ER "Prob of having any ER visit:1=yes;0=no"

/*	I think it may be better to generate a new variable for age, sex, poverty level, family size, and total number of ER visits	*/
/* so that it's easier for analysis	*/

gen age=AGEX
gen age2=age^2
label variable age2 "Age squared"
gen sex=SEX
gen poverty=POVLEV
gen size=FAMSZEYR
label variable size "Family size-based on FAMSZEYR"
gen visit_total_ER=ERTOT
label variable visit_total_ER "Total # of ER visits"

/*	CCI variable calculated from the Medical conditions file was available only for persons who reported a medical condition. 	*/
/*	For those who did not, the CCI variable will be missing when the Medical conditions file is merged with the Full-year file	*/
/*	Therefore, we need to assign CCI=0 for these missing observations	*/

replace cci=0 if cci==.

/*	Regroup persons into poverty group	*/

gen group=1 if poverty>=0&poverty<=138
replace group=2 if  poverty>138&poverty<=250
replace group=3 if poverty>250&poverty<=400
replace group=4 if group==.
label variable group "Poverty level group:1=<=138%; 2=138-250; 3=250-400; 4=>=400"

/*	Need to convert all price variables into log scale. Because there are visits where cost=0 (because they belong to a flat fee group), we add	*/
/*	1 in the parenthese to give these visits a price of 0 instead of missing when genering ln	*/

gen p_total_ln=ln( p_total+1) 
gen p_self_ln=ln( p_self+1) 
gen p_total_phy_ln=ln( p_total_phy+1) 
gen p_self_phy_ln =ln( p_self_phy +1) 
gen p_total_pc_ln =ln( p_total_pc +1) 
gen p_self_pc_ln =ln( p_self_pc +1) 
gen p_total_ER_ln =ln( p_total_ER +1) 
gen p_self_ER_ln =ln( p_self_ER +1) 

/* Finally, we will run the 2-part demand model	*/
/*	For the abstract purpose, we will care only about price per visit based on total payment (not self-pay	*/

/* 	First, the demand for medical visits (all types of visits-both physician and non-physician)	*/

xi: svy: logit visit age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION
predict visit_pr
xi: svy: nbreg visit_total age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION p_total_ln 
predict visit_total_pr
replace visit_total_pr=0 if visit_total_pr==.
gen demand_total= visit_total_pr*visit_pr
label variable demand_total "Demand for total visits"
svy: mean demand_total, over (group)

/* 	Second, the demand for physician visits (only visits to medical doctor)	*/

xi: svy: logit visit_phy age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION
predict visit_phy_pr
xi: svy: nbreg visit_total_phy age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION p_total_phy_ln 
predict visit_total_phy_pr
replace visit_total_phy_pr=0 if visit_total_phy_pr==.
label variable visit_total_phy_pr "Predicted number of physician visits"
gen demand_phy= visit_phy_pr* visit_total_phy_pr
svy: mean demand_phy, over(group)
label variable demand_phy "Demand for physician visits"

/*	Third, the demand for PC visits (primary care visits only)	*/

xi: svy: logit visit_pc age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION
predict visit_pc_pr
xi: svy: nbreg pc_visit_total age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION  p_total_pc_ln 
predict pc_visit_total_pr
replace pc_visit_total_pr=0 if pc_visit_total_pr==.
label variable pc_visit_total_pr "Predicted number of PC visits"
gen demand_pc= pc_visit_total_pr* visit_pc_pr
label variable demand_pc "Demand for primary care visits"

/*	Fourth, the demand for ER visits only	*/
xi: svy: logit visit_ER age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION
predict visit_ER_pr
xi: svy: nbreg visit_total_ER age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION p_total_ER_ln

/*	However, when I run the nbreg command for visit_total_ER, the standard error, t-value, and p-value, 95% CI were missing with 	*/
/*	the error: "Note: Missing standard errors because of strata with single sampling unit". I read about this error, and found	*/
/*	It was because missing data in other variables have led to strata with only one sampling unit in the estimatation sample (I don't know why 	*/
/*	it does not happen to other dependent variables). However, one suggestion to deal with this issue is to drop variables that belong to these 	*/
/*	single sampling unit. In order to do so, we need to identify these strata	*/

svydes if e(sample), single

/*	After you know which stratum has a single sampling unit, instead of dropping these observations (because I want to estimate the mean of demand	*/
/*	for the whole population), please replace visit_total_ER into missing data	*/

replace visit_total_ER=. if visit_total_ER!=.&(VARSTR==1048|VARSTR==1049|VARSTR==1052|VARSTR==1067|VARSTR==1070|VARSTR==1085|VARSTR==1108)

/*	After that, run the nbreg command as usual	*/
xi: svy: nbreg visit_total_ER age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION p_total_ER_ln

/*	For 2014 data (which I think the problem might be the same for other years), nbreg command did not return a p-value for the test of alpha=0	*/
/*	which suggest we that we might not need nbreg. I tried poisson instead. All value estimates were similar as when running by nbreg before	*/

xi: svy: poisson visit_total_ER age age2 i.sex i.race i.marry income i.edu i.usborn i.health i.limit i.checkup i.bmi i.usual i.unable_delay i.employment i.insurance IPDIS cci size i.REGION p_total_ER_ln
predict visit_total_ER_pr
replace visit_total_ER_pr=0 if visit_total_ER_pr==.
gen demand_ER= visit_total_ER_pr* visit_ER_pr
label variable demand_ER "Demand for ER visits"

/*	Finally, report the mean demand	for the whole population, and by poverty level subgroups*/
svy: mean demand_total demand_phy demand_pc demand_ER
svy: mean demand_total demand_phy demand_pc demand_ER , over(group)

/*	NOTE: THE PROBLEM OF MISSING STANDARD ERROR DESCRIBED ABOVE COULD HAPPEN TO ANY OF DEPENDENT VARIABLES. IF YOU ENCOUNTER THE PROBLEM	*/
/*	FOR OTHER DEPENDENT VARIABLES WITH EARLIER YEAR DATA, PLEASE TREAT IT THE SAME WAY	*/
log close
}

********************
* 3. Save and exit *
********************


exit, clear
