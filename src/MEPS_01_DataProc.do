**************************************************************************
*                      Project: MEPS                           	    	 *
**************************************************************************
* purpose:   : Process data
* authors	 : Ha Tran (ngocha61084@gmail.com)
* first draft: December 29, 2016
* last update: December 29, 2016
* category   : Data process
* version    : 1229
**************************************************************************

*********************************
* 0. Table of Contents		    *
*********************************

* 1a. Basics
* 1b. Directories
* 2. Create CCI
* 3. Create Office-based medical provider visits
* 4. Create Outpatient department visits
* 5. Merge CCI, Office-based Medical Provider Visits and Outpatient Department 
*    with Full Year Consolidated Data
* 6. Recode remaining variables, generate final data
* 7. Check all final variables before running model
* 8. Save and exit


*********************************
* 1a. Basics					*
*********************************

clear all
version 14.1
set more off
set varabbrev off
capture log close
global version = "1229"

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
* 2. Create CCI					*
*********************************
use "$data_proc/mcd07_14", clear
*Check data
preserve
ren icd9codx i
log using "$log/MEPS_05_DataPrep_$version.log", replace
la var i "icd9codx"
keep if i=="410"|i=="411"|i=="398"|i=="402"|i=="428"|i>="440"&i<="447"|i=="290"| ///
        i=="291"|i=="294"|i>="430"&i<="433"|i=="435"|i>="491"&i<="493"|i=="710"| ///
		i=="714"|i=="725"|i>="531"&i<="534"|i=="571"|i=="573"|i=="342"|i=="434"| ///
		i=="436"|i=="437"|i=="403"|i=="404"|i>="580"&i<="586"|i=="250"|i>="140"& ///
		i<="195"|i>="204"&i<="208"|i=="200"|i=="202"|i=="203"|i=="070"|i=="570"| ///
		i=="572"|i>="196"&i<="199"
tab year i, row
log close
restore
//data ok

log using "$log/MEPS_01_DataProc_$version.log", replace
*CREATE CCI
//keep if year==2007|year==2008|year==2012
ds
foreach v in `r(varlist)' {
ren `v' `=upper("`v'")'
}
/* 	This do file is used to calculate the Charlson comorbidity index for observations	*/
/*	in the "2014 Medical Conditions file"	*/	

gen myo=1 if ICD9CODX=="410"| ICD9CODX=="411"
replace myo=0 if myo==.
gen cong=1 if ICD9CODX=="398"| ICD9CODX=="402"|ICD9CODX=="428"				
replace cong=0 if cong==.
gen peri =1 if ICD9CODX>="440"&ICD9CODX<="447"
replace peri=0 if peri==.
gen deme=1 if  ICD9CODX=="290"| ICD9CODX=="291"|ICD9CODX=="294"
replace deme=0 if deme==.
gen cere =1 if ICD9CODX>="430"&ICD9CODX<="433"|ICD9CODX=="435"
replace cere=0 if cere==.
gen chro=1 if ICD9CODX>="491"&ICD9CODX<="493"
replace chro=0 if chro==.
gen conn=1 if ICD9CODX=="710"| ICD9CODX=="714"|ICD9CODX=="725"
replace conn=0 if conn==.
gen ulce=1 if ICD9CODX>="531"&ICD9CODX<="534"
replace ulce=0 if ulce==.
gen mild=1 if ICD9CODX=="571"|ICD9CODX=="573"
replace mild=0 if mild==.

gen hemi=1 if ICD9CODX=="342"|ICD9CODX=="434"|ICD9CODX=="436"|ICD9CODX=="437"
replace hemi=0 if hemi==.
gen mode=1 if ICD9CODX=="403"|ICD9CODX=="404"|ICD9CODX>="580"&ICD9CODX<="586"
replace mode=0 if mode==.
gen diab=1 if ICD9CODX=="250"
replace diab=0 if diab==.
gen tumo=1 if ICD9CODX>="140"&ICD9CODX<="195"
replace tumo=0 if tumo==.
gen leuk=1 if ICD9CODX>="204"&ICD9CODX<="208"
replace leuk=0 if leuk==.
gen lymp=1 if ICD9CODX=="200"|ICD9CODX=="202"|ICD9CODX=="203"
replace lymp=0 if lymp==.

gen live =1 if ICD9CODX=="070"|ICD9CODX=="570"|ICD9CODX=="572"
replace live=0 if live==.

gen meta=1 if ICD9CODX>="196"&ICD9CODX<="199"
replace meta=0 if meta==.

bys DUPERSID: egen myo_m=max( myo)
bys DUPERSID: egen cong_m=max( cong )
bys DUPERSID: egen peri_m=max( peri )
bys DUPERSID: egen deme_m=max( deme )
bys DUPERSID: egen cere_m=max( cere )
bys DUPERSID: egen chro_m=max( chro )
bys DUPERSID: egen conn_m=max( conn )
bys DUPERSID: egen ulce_m=max( ulce )
bys DUPERSID: egen mild_m=max( mild )
bys DUPERSID: egen hemi_m=max( hemi )
bys DUPERSID: egen mode_m=max( mode )
bys DUPERSID: egen diab_m=max( diab )
bys DUPERSID: egen tumo_m=max( tumo )
bys DUPERSID: egen leuk_m=max( leuk )
bys DUPERSID: egen lymp_m=max( lymp )
bys DUPERSID: egen live_m=max( live )
bys DUPERSID: egen meta_m=max( meta )

gen cci=1*( myo_m+ cong_m+ peri_m+ deme_m+ cere_m+ chro_m+ conn_m+ ulce_m+ mild_m)+2*( hemi_m+ mode_m+ diab_m+ tumo_m+ leuk_m+ lymp_m)+3* live_m+6* meta_m
label variable cci "Charlson comorbidity index"
save "$data_proc\H170_working file.dta", replace

/*	After calculating CCI, i only kept dupersid and cci for merging with the Full-year consolidated data file later.	*/
/*	After dropping all other variables, I saved it as a separate file and keep the original Medical conditions file	*/
/*	with all of the newly constructed variables for CCI calculation	*/

sort DUPERSID
quietly by DUPERSID: gen dup = cond(_N==1,0,_n)
drop if dup>1
keep DUPERSID cci YEAR

save "$output\H170_final.dta", replace
	preserve
		foreach y in 07 08 09 10 11 12 13 14 {
		use "$output\H170_final.dta"
		keep if YEAR==20`y'
		save "$output\H170_final_`y'.dta", replace
		}
	restore
	

/*	The final file for merging should be name H170-final.dta	*/
log close

******************************************************************
* 3. Create Office-based medical provider visits		   		 *
******************************************************************
use "$data_proc/obmpvd07_14", clear
log using "$log/MEPS_06_DataPrep_$version.log", replace
*Check data: there are variables needed to check including seetlkpv, drsplty, seedoc, obsfx, obxpx
foreach v in seetlkpv drsplty seedoc {
tabulate year `v',row m
}

foreach v in obsfx obxpx {
mean `v',over(year)
}
codebook seetlkpv drsplty seedoc obsfx obxpx
//-> variables ok across years
log close

log using "$log/MEPS_02_DataProc_$version.log", replace
*CREATE OFFICE-BASED MEDICAL PROVIDER VISITS
//keep if year==2007|year==2008|year==2012
ds
foreach v in `r(varlist)' {
ren `v' `=upper("`v'")'
}

/*	This file contains the command to identify primary care visits from all other 	*/
/*	specialty visits and non-physician visits in the Office-based Medical Provider Visists file	*/

/*	First, only keep actual visits, not those over the phone	*/

keep if SEETLKPV==1

/*	Second, count # of pc visits and # of specialist (sp) visits	*/

gen pc_visit =1 if DRSPLTY==6|DRSPLTY==8|DRSPLTY==10|DRSPLTY==14|DRSPLTY==24
replace pc_visit=0 if pc_visit==.
gen sp_visit=1 if pc_visit==0&SEEDOC==1
replace sp_visit=0 if sp_visit==.
bys DUPERSID: egen pc_visit_total=total(pc_visit)
bys DUPERSID: egen sp_visit_total=total(sp_visit)

/*	Third, reset all cost variables to missing values if they are <0 (for inapplicable cases)	*/

replace OBSFX =. if OBSFX<0
replace OBXPX = . if OBXPX<0

/* Fourth, estimate costs associated with pc and sp visits	*/

bys DUPERSID: egen pc_OBSFX=sum(OBSFX) if pc_visit==1
bys DUPERSID: egen pc_OBXPX=sum(OBXPX) if pc_visit==1
bys DUPERSID: egen pc_OBSF=max( pc_OBSFX)
bys DUPERSID: egen pc_OBXP=max( pc_OBXPX)

bys DUPERSID: egen sp_OBSFX=sum(OBSFX) if sp_visit==1
bys DUPERSID: egen sp_OBXPX=sum(OBXPX) if sp_visit==1
bys DUPERSID: egen sp_OBSF=max( sp_OBSFX )
bys DUPERSID: egen sp_OBXP =max( sp_OBXPX )

rename pc_visit_total pc_visit_total_OB
rename sp_visit_total sp_visit_total_OB
label variable pc_visit_total_OB "Total # of primary care visits in Office based"
label variable sp_visit_total_OB "Total # of specialist visits in Office based"
label variable pc_OBSF "OOP payment-All PC visits-Office based"
label variable pc_OBXP "Total payment-All PC visits-Office based"
label variable sp_OBSF "OOP payment-All SP visits-Office based"
label variable sp_OBXP "Total payment-All SP visits-Office based"

save "$data_proc\H168G_working file.dta", replace


/*	After generating all necessary variables in the working file, I saved as into a new file called	*/
/*	H168G-final.dta. This will be the file use for final analysis	*/

save "$output\H168G_final.dta", replace
sort DUPERSID
quietly by DUPERSID: gen dup = cond(_N==1,0,_n)
drop if dup>1
keep DUPERSID pc_visit_total_OB sp_visit_total_OB pc_OBSF pc_OBXP sp_OBSF sp_OBXP YEAR
save "$output\H168G_final.dta", replace

	preserve
		foreach y in 07 08 09 10 11 12 13 14 {
		use "$output\H168G_final.dta"
		keep if YEAR==20`y'
		save "$output/H168G_final_`y'", replace
		}
	restore
log close


******************************************************************
* 4. Create Outpatient department visits				   		 *
******************************************************************
use "$data_proc/ovd07_14", clear
log using "$log/MEPS_07_DataPrep_$version.log", replace
* Check data: seetlkpv, drsplty, seedoc, opxpx, opxpx, opfsfx, opfxpx, opdsfx, opdxpx
codebook seetlkpv drsplty seedoc opxpx opxpx opfsfx opfxpx opdsfx opdxpx
*Check data: there are variables needed to check including seetlkpv, drsplty, seedoc, obsfx, obxpx
foreach v in seetlkpv drsplty seedoc {
tabulate year `v',row m
}

foreach v in opxpx opxpx opfsfx opfxpx opdsfx opdxpx {
mean `v',over(year)
}
//-> variables ok across years
log close


log using "$log/MEPS_03_DataProc_$version.log", replace
*CREATE OFFICE-BASED MEDICAL PROVIDER VISITS
//keep if year==2007|year==2008|year==2012
ds
foreach v in `r(varlist)' {
ren `v' `=upper("`v'")'
}

/*	This file contains the command to identify primary care visits from all other 	*/
/*	specialty visits and non-physician visits in the Outpatient Department Visists file	*/

/*	First, only keep actual visits, not those over the phone	*/

keep if SEETLKPV==1

/*	Second, count # of pc visits and # of specialist (sp) visits	*/

gen pc_visit =1 if DRSPLTY==6|DRSPLTY==8|DRSPLTY==10|DRSPLTY==14|DRSPLTY==24
replace pc_visit=0 if pc_visit==.
gen sp_visit=1 if pc_visit==0&SEEDOC==1
replace sp_visit=0 if sp_visit==.
bys DUPERSID: egen pc_visit_total=total(pc_visit)
bys DUPERSID: egen sp_visit_total=total(sp_visit)

/*	Third, reset all cost variables to missing values if they are <0 (for inapplicable cases)	*/

replace OPXPX=. if OPXPX<0
replace OPFSFX=. if OPFSFX<0
replace OPFXPX=. if OPFXPX<0
replace OPDSFX=. if OPDSFX<0
replace OPDXPX=. if OPDXPX<0

/*	Fourth, estimate costs associated with pc and sp visits	*/

bys DUPERSID: egen pc_OPXPX =sum( OPXPX ) if pc_visit==1
bys DUPERSID: egen pc_OPFSFX =sum( OPFSFX ) if pc_visit==1
bys DUPERSID: egen pc_OPFXPX =sum( OPFXPX ) if pc_visit==1
bys DUPERSID: egen pc_OPDSFX =sum( OPDSFX ) if pc_visit==1
bys DUPERSID: egen pc_OPDXPX =sum( OPDXPX ) if pc_visit==1
bys DUPERSID: egen pc_OPSF= max(pc_OPFSFX+ pc_OPDSFX)
bys DUPERSID: egen pc_OPXP= max( pc_OPXPX )

bys DUPERSID: egen sp_OPXPX =sum( OPXPX ) if sp_visit==1
bys DUPERSID: egen sp_OPFSFX =sum( OPFSFX ) if sp_visit==1
bys DUPERSID: egen sp_OPFXPX =sum( OPFXPX ) if sp_visit==1
bys DUPERSID: egen sp_OPDSFX =sum( OPDSFX ) if sp_visit==1
bys DUPERSID: egen sp_OPDXPX =sum( OPDXPX ) if sp_visit==1
bys DUPERSID: egen sp_OPSF= max(sp_OPFSFX+ sp_OPDSFX)
bys DUPERSID: egen sp_OPXP= max( sp_OPXPX )

rename pc_visit_total pc_visit_total_OPT
label variable pc_visit_total_OPT "Total # of PC visit in OPT"
rename sp_visit_total sp_visit_total_OPT
label variable sp_visit_total_OPT "Total # of SP visits in OPT"
label variable pc_OPSF "OOP payment-All PC visits to OPT"
label variable pc_OPXP "Total payment-All PC visits to OPT"
label variable sp_OPSF "OOP payment-All SP visits to OPT"
label variable sp_OPXP "Total payment-All SP visits to OPT"

save "$data_proc\H168F_working file.dta", replace

/* Before generating the final data for merging, I saved as into a new data file called	*/
/* H168F-final.dta	*/

save "$output\H168F_final.dta", replace
sort DUPERSID
quietly by DUPERSID: gen dup = cond(_N==1,0,_n)
drop if dup>1
keep DUPERSID pc_visit_total_OPT sp_visit_total_OPT pc_OPXP pc_OPSF sp_OPSF sp_OPXP YEAR
save "$output\H168F_final.dta", replace

	preserve
		foreach y in 07 08 09 10 11 12 13 14 {
		use "$output/H168F_final.dta", clear
		keep if YEAR==20`y'
		save "$output/H168F_final_`y'", replace
		}
	restore
log close


******************************************************************
* 5. Merge 3 separate data files with the consolidated data		 *
******************************************************************
*A. Process the consolidated data for merging
log using "$log/MEPS_04_DataProc_$version.log", replace
use "$data_proc/fycd07_14", clear
keep duid pid dupersid panel famidyr fams1231 famszeyr region begrfm31 begrfy31   ///
     endrfm31 endrfy31 endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42      ///
	 begrfm53 begrfy53 endrfm53 endrfy53 endrfm endrfy inscop31 inscop42          ///
	 inscop53 inscop pstats31 pstats42 pstats53 agex sex racethx marryx edrecode  ///
	 faminc povlev rthlth53 mnhlth53 anylmt bmindx53 check53 saqelig pcs42 mcs42  ///
	 k6sum42 phq242 haveus42 tmtkus42 locatn42 mdunab42 mddlay42 empst53h          ///
	 hour53h slfcm53h hrwg53h inscov obtotv obdrv obothv optotv opdrv opothv      ///
	 ertot ipzero ipdis ipngtd rxtot perwtf famwtf saqwtf diabwf varstr varpsu    ///
	 obvexp obvslf obdexp obdslf optexp optslf opfexp opfslf opdexp opdslf opvexp ///
	 opvslf opsexp opsslf opoexp oposlf opoexp oposlf oppexp oppslf ertexp        ///
	 ertslf erfexp erfslf erdexp erdslf bornusa year hispanx racex raceax educyr
//ren selfcm53 slfcmh
//ren hrwgim53 hrwg53h
//ren empst53 empst53h
//ren hour53 hour53h

ds
foreach v in `r(varlist)' {
ren `v' `=upper("`v'")'
}
save "$output/fycd_final", replace

preserve
	foreach y in 07 08 09 10 11 12 13 14{
	use "$output/fycd_final", clear
	keep if YEAR==20`y'
	save "$output/fycd_final_`y'", replace
	}
restore

 
*B. Merge with the three separate data files
*2007
use "$output/fycd_final_07", clear
gen fullyr=1 if INSCOP31==1&INSCOP42==1&INSCOP==1&PANEL==12
replace fullyr=1 if fullyr==.&(((INSCOP31==1|INSCOP31==3)&BEGRFY31<2007)&INSCOP42==1&INSCOP53==1&PANEL==11)
replace fullyr=0 if fullyr==.

/*	Second, merge the full year file with the CCI file	*/
merge 1:1 DUPERSID using "$output\H170_final_07.dta"
rename _merge merge_cci
label variable merge_cci "1=h171 only; 2= cci only; 3=both"
save "$output\H171_Final_07.dta", replace

/*	Third, merge the full-year/CCI file with the Office-based medical provider visits file	*/
merge 1:1 DUPERSID using "$output\H168G_final_07.dta"
rename _merge merge_cci_OB
label variable merge_cci_OB "1=h171/cci only; 2=OB only; 3= both"
save "$output\H171_Final_07.dta", replace

/* Fourth, merge the full-year/CCI/Office-based file with the Outpatient deparment visits file	*/
merge 1:1 DUPERSID using "$output\H168F_final_07.dta"
rename _merge merge_cci_OB_OP
label variable merge_cci_OB_OP "1=h171/cci/OB only; 2=OP only; 3=both"
save "$output\H171_Final_07.dta", replace

/*	Remove patients who are not inscope full year (fullyr=0) and who are either <18 or >64 years and PERWTF<0	*/
/* The total # of observation in the original full-year consolidated file was 30,964	*/
drop if fullyr==0|PERWTF<=0
/*	2,418  observations deleted)	*/
drop if AGEX<18|AGEX>64
/*	11,425  observations deleted	*/
/* Total is 17,121  observations	*/

/*	Fifth, generate new variables to capture total visits to primary care/specilist and associated costs	*/
egen pc_visit_total= rowtotal(pc_visit_total_OB pc_visit_total_OPT), missing
egen pc_cost_total=rowtotal( pc_OBXP pc_OPXP), missing
egen pc_cost_self= rowtotal( pc_OBSF pc_OPSF ), miss
replace pc_cost_total=0 if pc_visit_total==0
replace pc_cost_self=0 if pc_visit_total==0

egen sp_visit_total= rowtotal( sp_visit_total_OB sp_visit_total_OPT), missing
egen sp_cost_self= rowtotal( sp_OBSF sp_OPSF ), missing
egen sp_cost_total= rowtotal( sp_OBXP sp_OPXP ), missing
replace sp_cost_total=0 if sp_visit_total==0
replace sp_cost_self=0 if sp_visit_total==0

label variable pc_visit_total "Total # of visits to primary care"
label variable sp_visit_total "Total # of visits to specialist"
label variable pc_cost_total "Total payment of all PC visits"
label variable pc_cost_self "Total OOP payment of all visits"
label variable sp_cost_self "Total OOP payment of all SP visits"
label variable sp_cost_total "Total payment of all SP visits"
save "$output\H171_final_2_07.dta", replace

*2008
use "$output/fycd_final_08", clear
gen fullyr=1 if INSCOP31==1&INSCOP42==1&INSCOP==1&PANEL==13
replace fullyr=1 if fullyr==.&(((INSCOP31==1|INSCOP31==3)&BEGRFY31<2008)&INSCOP42==1&INSCOP53==1&PANEL==12)
replace fullyr=0 if fullyr==.

/*	Second, merge the full year file with the CCI file	*/
merge 1:1 DUPERSID using "$output\H170_final_08.dta"
rename _merge merge_cci
label variable merge_cci "1=h171 only; 2= cci only; 3=both"
save "$output\H171_Final_08.dta", replace

/*	Third, merge the full-year/CCI file with the Office-based medical provider visits file	*/
merge 1:1 DUPERSID using "$output\H168G_final_08.dta"
rename _merge merge_cci_OB
label variable merge_cci_OB "1=h171/cci only; 2=OB only; 3= both"
save "$output\H171_Final_08.dta", replace

/* Fourth, merge the full-year/CCI/Office-based file with the Outpatient deparment visits file	*/
merge 1:1 DUPERSID using "$output\H168F_final_08.dta"
rename _merge merge_cci_OB_OP
label variable merge_cci_OB_OP "1=h171/cci/OB only; 2=OP only; 3=both"
save "$output\H171_Final_08.dta", replace

/*	Remove patients who are not inscope full year (fullyr=0) and who are either <18 or >64 years and PERWTF<0	*/
/* The total # of observation in the original full-year consolidated file was 33,066	*/
drop if fullyr==0|PERWTF<=0
/*	2,739  observations deleted)	*/
drop if AGEX<18|AGEX>64
/*	11,846  observations deleted	*/
/* Total is 18,481  observations	*/

/*	Fifth, generate new variables to capture total visits to primary care/specilist and associated costs	*/
egen pc_visit_total= rowtotal(pc_visit_total_OB pc_visit_total_OPT), missing
egen pc_cost_total=rowtotal( pc_OBXP pc_OPXP), missing
egen pc_cost_self= rowtotal( pc_OBSF pc_OPSF ), miss
replace pc_cost_total=0 if pc_visit_total==0
replace pc_cost_self=0 if pc_visit_total==0

egen sp_visit_total= rowtotal( sp_visit_total_OB sp_visit_total_OPT), missing
egen sp_cost_self= rowtotal( sp_OBSF sp_OPSF ), missing
egen sp_cost_total= rowtotal( sp_OBXP sp_OPXP ), missing
replace sp_cost_total=0 if sp_visit_total==0
replace sp_cost_self=0 if sp_visit_total==0

label variable pc_visit_total "Total # of visits to primary care"
label variable sp_visit_total "Total # of visits to specialist"
label variable pc_cost_total "Total payment of all PC visits"
label variable pc_cost_self "Total OOP payment of all visits"
label variable sp_cost_self "Total OOP payment of all SP visits"
label variable sp_cost_total "Total payment of all SP visits"
save "$output\H171_final_2_08.dta", replace


*2009
use "$output/fycd_final_09", clear
gen fullyr=1 if INSCOP31==1&INSCOP42==1&INSCOP==1&PANEL==14
replace fullyr=1 if fullyr==.&(((INSCOP31==1|INSCOP31==3)&BEGRFY31<2009)&INSCOP42==1&INSCOP53==1&PANEL==13)
replace fullyr=0 if fullyr==.

/*	Second, merge the full year file with the CCI file	*/
merge 1:1 DUPERSID using "$output\H170_final_09.dta"
rename _merge merge_cci
label variable merge_cci "1=h171 only; 2= cci only; 3=both"
save "$output\H171_Final_09.dta", replace

/*	Third, merge the full-year/CCI file with the Office-based medical provider visits file	*/
merge 1:1 DUPERSID using "$output\H168G_final_09.dta"
rename _merge merge_cci_OB
label variable merge_cci_OB "1=h171/cci only; 2=OB only; 3= both"
save "$output\H171_Final_09.dta", replace

/* Fourth, merge the full-year/CCI/Office-based file with the Outpatient deparment visits file	*/
merge 1:1 DUPERSID using "$output\H168F_final_09.dta"
rename _merge merge_cci_OB_OP
label variable merge_cci_OB_OP "1=h171/cci/OB only; 2=OP only; 3=both"
save "$output\H171_Final_09.dta", replace

/*	Remove patients who are not inscope full year (fullyr=0) and who are either <18 or >64 years and PERWTF<0	*/
/* The total # of observation in the original full-year consolidated file was 36,855	*/
drop if fullyr==0|PERWTF<=0
/*	2,868  observations deleted)	*/
drop if AGEX<18|AGEX>64
/*	13,234  observations deleted	*/
/* Total is 20,753  observations	*/

/*	Fifth, generate new variables to capture total visits to primary care/specilist and associated costs	*/
egen pc_visit_total= rowtotal(pc_visit_total_OB pc_visit_total_OPT), missing
egen pc_cost_total=rowtotal( pc_OBXP pc_OPXP), missing
egen pc_cost_self= rowtotal( pc_OBSF pc_OPSF ), miss
replace pc_cost_total=0 if pc_visit_total==0
replace pc_cost_self=0 if pc_visit_total==0

egen sp_visit_total= rowtotal( sp_visit_total_OB sp_visit_total_OPT), missing
egen sp_cost_self= rowtotal( sp_OBSF sp_OPSF ), missing
egen sp_cost_total= rowtotal( sp_OBXP sp_OPXP ), missing
replace sp_cost_total=0 if sp_visit_total==0
replace sp_cost_self=0 if sp_visit_total==0

label variable pc_visit_total "Total # of visits to primary care"
label variable sp_visit_total "Total # of visits to specialist"
label variable pc_cost_total "Total payment of all PC visits"
label variable pc_cost_self "Total OOP payment of all visits"
label variable sp_cost_self "Total OOP payment of all SP visits"
label variable sp_cost_total "Total payment of all SP visits"
save "$output\H171_final_2_09.dta", replace

*2010
use "$output/fycd_final_10", clear
gen fullyr=1 if INSCOP31==1&INSCOP42==1&INSCOP==1&PANEL==15
replace fullyr=1 if fullyr==.&(((INSCOP31==1|INSCOP31==3)&BEGRFY31<2010)&INSCOP42==1&INSCOP53==1&PANEL==14)
replace fullyr=0 if fullyr==.

/*	Second, merge the full year file with the CCI file	*/
merge 1:1 DUPERSID using "$output\H170_final_10.dta"
rename _merge merge_cci
label variable merge_cci "1=h171 only; 2= cci only; 3=both"
save "$output\H171_Final_10.dta", replace

/*	Third, merge the full-year/CCI file with the Office-based medical provider visits file	*/
merge 1:1 DUPERSID using "$output\H168G_final_10.dta"
rename _merge merge_cci_OB
label variable merge_cci_OB "1=h171/cci only; 2=OB only; 3= both"
save "$output\H171_Final_10.dta", replace

/* Fourth, merge the full-year/CCI/Office-based file with the Outpatient deparment visits file	*/
merge 1:1 DUPERSID using "$output\H168F_final_10.dta"
rename _merge merge_cci_OB_OP
label variable merge_cci_OB_OP "1=h171/cci/OB only; 2=OP only; 3=both"
save "$output\H171_Final_10.dta", replace

/*	Remove patients who are not inscope full year (fullyr=0) and who are either <18 or >64 years and PERWTF<0	*/
/* The total # of observation in the original full-year consolidated file was 32,846	*/
drop if fullyr==0|PERWTF<=0
/*	2,475  observations deleted)	*/
drop if AGEX<18|AGEX>64
/*	11,805  observations deleted	*/
/* Total is 18,566  observations	*/

/*	Fifth, generate new variables to capture total visits to primary care/specilist and associated costs	*/
egen pc_visit_total= rowtotal(pc_visit_total_OB pc_visit_total_OPT), missing
egen pc_cost_total=rowtotal( pc_OBXP pc_OPXP), missing
egen pc_cost_self= rowtotal( pc_OBSF pc_OPSF ), miss
replace pc_cost_total=0 if pc_visit_total==0
replace pc_cost_self=0 if pc_visit_total==0

egen sp_visit_total= rowtotal( sp_visit_total_OB sp_visit_total_OPT), missing
egen sp_cost_self= rowtotal( sp_OBSF sp_OPSF ), missing
egen sp_cost_total= rowtotal( sp_OBXP sp_OPXP ), missing
replace sp_cost_total=0 if sp_visit_total==0
replace sp_cost_self=0 if sp_visit_total==0

label variable pc_visit_total "Total # of visits to primary care"
label variable sp_visit_total "Total # of visits to specialist"
label variable pc_cost_total "Total payment of all PC visits"
label variable pc_cost_self "Total OOP payment of all visits"
label variable sp_cost_self "Total OOP payment of all SP visits"
label variable sp_cost_total "Total payment of all SP visits"
save "$output\H171_final_2_10.dta", replace

*2011
use "$output/fycd_final_11", clear
gen fullyr=1 if INSCOP31==1&INSCOP42==1&INSCOP==1&PANEL==16
replace fullyr=1 if fullyr==.&(((INSCOP31==1|INSCOP31==3)&BEGRFY31<2011)&INSCOP42==1&INSCOP53==1&PANEL==15)
replace fullyr=0 if fullyr==.

/*	Second, merge the full year file with the CCI file	*/
merge 1:1 DUPERSID using "$output\H170_final_11.dta"
rename _merge merge_cci
label variable merge_cci "1=h171 only; 2= cci only; 3=both"
save "$output\H171_Final_11.dta", replace

/*	Third, merge the full-year/CCI file with the Office-based medical provider visits file	*/
merge 1:1 DUPERSID using "$output\H168G_final_11.dta"
rename _merge merge_cci_OB
label variable merge_cci_OB "1=h171/cci only; 2=OB only; 3= both"
save "$output\H171_Final_11.dta", replace

/* Fourth, merge the full-year/CCI/Office-based file with the Outpatient deparment visits file	*/
merge 1:1 DUPERSID using "$output\H168F_final_11.dta"
rename _merge merge_cci_OB_OP
label variable merge_cci_OB_OP "1=h171/cci/OB only; 2=OP only; 3=both"
save "$output\H171_Final_11.dta", replace

/*	Remove patients who are not inscope full year (fullyr=0) and who are either <18 or >64 years and PERWTF<0	*/
/* The total # of observation in the original full-year consolidated file was 35,313	*/
drop if fullyr==0|PERWTF<=0
/*	2,543  observations deleted)	*/
drop if AGEX<18|AGEX>64
/*	12,805  observations deleted	*/
/* Total is 19,965  observations	*/

/*	Fifth, generate new variables to capture total visits to primary care/specilist and associated costs	*/
egen pc_visit_total= rowtotal(pc_visit_total_OB pc_visit_total_OPT), missing
egen pc_cost_total=rowtotal( pc_OBXP pc_OPXP), missing
egen pc_cost_self= rowtotal( pc_OBSF pc_OPSF ), miss
replace pc_cost_total=0 if pc_visit_total==0
replace pc_cost_self=0 if pc_visit_total==0

egen sp_visit_total= rowtotal( sp_visit_total_OB sp_visit_total_OPT), missing
egen sp_cost_self= rowtotal( sp_OBSF sp_OPSF ), missing
egen sp_cost_total= rowtotal( sp_OBXP sp_OPXP ), missing
replace sp_cost_total=0 if sp_visit_total==0
replace sp_cost_self=0 if sp_visit_total==0

label variable pc_visit_total "Total # of visits to primary care"
label variable sp_visit_total "Total # of visits to specialist"
label variable pc_cost_total "Total payment of all PC visits"
label variable pc_cost_self "Total OOP payment of all visits"
label variable sp_cost_self "Total OOP payment of all SP visits"
label variable sp_cost_total "Total payment of all SP visits"
save "$output\H171_final_2_11.dta", replace

*2012
use "$output/fycd_final_12", clear
gen fullyr=1 if INSCOP31==1&INSCOP42==1&INSCOP==1&PANEL==17
replace fullyr=1 if fullyr==.&(((INSCOP31==1|INSCOP31==3)&BEGRFY31<2012)&INSCOP42==1&INSCOP53==1&PANEL==16)
replace fullyr=0 if fullyr==.

/*	Second, merge the full year file with the CCI file	*/
merge 1:1 DUPERSID using "$output\H170_final_12.dta"
rename _merge merge_cci
label variable merge_cci "1=h171 only; 2= cci only; 3=both"
save "$output\H171_Final_12.dta", replace

/*	Third, merge the full-year/CCI file with the Office-based medical provider visits file	*/
merge 1:1 DUPERSID using "$output\H168G_final_12.dta"
rename _merge merge_cci_OB
label variable merge_cci_OB "1=h171/cci only; 2=OB only; 3= both"
save "$output\H171_Final_12.dta", replace

/* Fourth, merge the full-year/CCI/Office-based file with the Outpatient deparment visits file	*/
merge 1:1 DUPERSID using "$output\H168F_final_12.dta"
rename _merge merge_cci_OB_OP
label variable merge_cci_OB_OP "1=h171/cci/OB only; 2=OP only; 3=both"
save "$output\H171_Final_12.dta", replace

/*	Remove patients who are not inscope full year (fullyr=0) and who are either <18 or >64 years and PERWTF<0	*/
/* The total # of observation in the original full-year consolidated file was 38,974	*/
drop if fullyr==0|PERWTF<=0
/*	2,767  observations deleted)	*/
drop if AGEX<18|AGEX>64
/*	14,023  observations deleted	*/
/* Total is 22,184  observations	*/

/*	Fifth, generate new variables to capture total visits to primary care/specilist and associated costs	*/
egen pc_visit_total= rowtotal(pc_visit_total_OB pc_visit_total_OPT), missing
egen pc_cost_total=rowtotal( pc_OBXP pc_OPXP), missing
egen pc_cost_self= rowtotal( pc_OBSF pc_OPSF ), miss
replace pc_cost_total=0 if pc_visit_total==0
replace pc_cost_self=0 if pc_visit_total==0

egen sp_visit_total= rowtotal( sp_visit_total_OB sp_visit_total_OPT), missing
egen sp_cost_self= rowtotal( sp_OBSF sp_OPSF ), missing
egen sp_cost_total= rowtotal( sp_OBXP sp_OPXP ), missing
replace sp_cost_total=0 if sp_visit_total==0
replace sp_cost_self=0 if sp_visit_total==0

label variable pc_visit_total "Total # of visits to primary care"
label variable sp_visit_total "Total # of visits to specialist"
label variable pc_cost_total "Total payment of all PC visits"
label variable pc_cost_self "Total OOP payment of all visits"
label variable sp_cost_self "Total OOP payment of all SP visits"
label variable sp_cost_total "Total payment of all SP visits"
save "$output\H171_final_2_12.dta", replace

*2013
use "$output/fycd_final_13", clear
gen fullyr=1 if INSCOP31==1&INSCOP42==1&INSCOP==1&PANEL==18
replace fullyr=1 if fullyr==.&(((INSCOP31==1|INSCOP31==3)&BEGRFY31<2013)&INSCOP42==1&INSCOP53==1&PANEL==17)
replace fullyr=0 if fullyr==.

/*	Second, merge the full year file with the CCI file	*/
merge 1:1 DUPERSID using "$output\H170_final_13.dta"
rename _merge merge_cci
label variable merge_cci "1=h171 only; 2= cci only; 3=both"
save "$output\H171_Final_13.dta", replace

/*	Third, merge the full-year/CCI file with the Office-based medical provider visits file	*/
merge 1:1 DUPERSID using "$output\H168G_final_13.dta"
rename _merge merge_cci_OB
label variable merge_cci_OB "1=h171/cci only; 2=OB only; 3= both"
save "$output\H171_Final_13.dta", replace

/* Fourth, merge the full-year/CCI/Office-based file with the Outpatient deparment visits file	*/
merge 1:1 DUPERSID using "$output\H168F_final_13.dta"
rename _merge merge_cci_OB_OP
label variable merge_cci_OB_OP "1=h171/cci/OB only; 2=OP only; 3=both"
save "$output\H171_Final_13.dta", replace

/*	Remove patients who are not inscope full year (fullyr=0) and who are either <18 or >64 years and PERWTF<0	*/
/* The total # of observation in the original full-year consolidated file was 36,940	*/
drop if fullyr==0|PERWTF<=0
/*	2,715  observations deleted)	*/
drop if AGEX<18|AGEX>64
/*	13,267  observations deleted	*/
/* Total is 20,958  observations	*/

/*	Fifth, generate new variables to capture total visits to primary care/specilist and associated costs	*/
egen pc_visit_total= rowtotal(pc_visit_total_OB pc_visit_total_OPT), missing
egen pc_cost_total=rowtotal( pc_OBXP pc_OPXP), missing
egen pc_cost_self= rowtotal( pc_OBSF pc_OPSF ), miss
replace pc_cost_total=0 if pc_visit_total==0
replace pc_cost_self=0 if pc_visit_total==0

egen sp_visit_total= rowtotal( sp_visit_total_OB sp_visit_total_OPT), missing
egen sp_cost_self= rowtotal( sp_OBSF sp_OPSF ), missing
egen sp_cost_total= rowtotal( sp_OBXP sp_OPXP ), missing
replace sp_cost_total=0 if sp_visit_total==0
replace sp_cost_self=0 if sp_visit_total==0

label variable pc_visit_total "Total # of visits to primary care"
label variable sp_visit_total "Total # of visits to specialist"
label variable pc_cost_total "Total payment of all PC visits"
label variable pc_cost_self "Total OOP payment of all visits"
label variable sp_cost_self "Total OOP payment of all SP visits"
label variable sp_cost_total "Total payment of all SP visits"
save "$output\H171_final_2_13.dta", replace


*2014
use "$output/fycd_final_14", clear
gen fullyr=1 if INSCOP31==1&INSCOP42==1&INSCOP==1&PANEL==19
replace fullyr=1 if fullyr==.&(((INSCOP31==1|INSCOP31==3)&BEGRFY31<2014)&INSCOP42==1&INSCOP53==1&PANEL==18)
replace fullyr=0 if fullyr==.

/*	Second, merge the full year file with the CCI file	*/
merge 1:1 DUPERSID using "$output\H170_final_14.dta"
rename _merge merge_cci
label variable merge_cci "1=h171 only; 2= cci only; 3=both"
save "$output\H171_Final_14.dta", replace

/*	Third, merge the full-year/CCI file with the Office-based medical provider visits file	*/
merge 1:1 DUPERSID using "$output\H168G_final_14.dta"
rename _merge merge_cci_OB
label variable merge_cci_OB "1=h171/cci only; 2=OB only; 3= both"
save "$output\H171_Final_14.dta", replace

/* Fourth, merge the full-year/CCI/Office-based file with the Outpatient deparment visits file	*/
merge 1:1 DUPERSID using "$output\H168F_final_14.dta"
rename _merge merge_cci_OB_OP
label variable merge_cci_OB_OP "1=h171/cci/OB only; 2=OP only; 3=both"
save "$output\H171_Final_14.dta", replace

/*	Remove patients who are not inscope full year (fullyr=0) and who are either <18 or >64 years and PERWTF<0	*/
/* The total # of observation in the original full-year consolidated file was 36,940	*/
drop if fullyr==0|PERWTF<=0
/*	2,533  observations deleted)	*/
drop if AGEX<18|AGEX>64
/*	12,672  observations deleted	*/
/* Total is 19,670  observations	*/

/*	Fifth, generate new variables to capture total visits to primary care/specilist and associated costs	*/
egen pc_visit_total= rowtotal(pc_visit_total_OB pc_visit_total_OPT), missing
egen pc_cost_total=rowtotal( pc_OBXP pc_OPXP), missing
egen pc_cost_self= rowtotal( pc_OBSF pc_OPSF ), miss
replace pc_cost_total=0 if pc_visit_total==0
replace pc_cost_self=0 if pc_visit_total==0

egen sp_visit_total= rowtotal( sp_visit_total_OB sp_visit_total_OPT), missing
egen sp_cost_self= rowtotal( sp_OBSF sp_OPSF ), missing
egen sp_cost_total= rowtotal( sp_OBXP sp_OPXP ), missing
replace sp_cost_total=0 if sp_visit_total==0
replace sp_cost_self=0 if sp_visit_total==0

label variable pc_visit_total "Total # of visits to primary care"
label variable sp_visit_total "Total # of visits to specialist"
label variable pc_cost_total "Total payment of all PC visits"
label variable pc_cost_self "Total OOP payment of all visits"
label variable sp_cost_self "Total OOP payment of all SP visits"
label variable sp_cost_total "Total payment of all SP visits"
save "$output\H171_final_2_14.dta", replace


******************************************************************
* 6. Recode remaining variables, generate final data			 *
******************************************************************
*A. Append data of all year together
use "$output\H171_final_2_07.dta", clear
	append using "$output\H171_final_2_08.dta"
		append using "$output\H171_final_2_09.dta"
			append using "$output\H171_final_2_10.dta"
				append using "$output\H171_final_2_11.dta"
					append using "$output\H171_final_2_12.dta"
						append using "$output\H171_final_2_13.dta"
							append using "$output\H171_final_2_14.dta"
/*	The following commands are used to work with the 2014 Full-year consolidated data file after	*/
/* it was merged with all three files: CCI, Outpatient, and Office-based	*/

/* Keep original SEX, AGE14X	*/
/* Regenerate variable for race because in year earlier than 2012, an equivalent race variable is not available*/



/*	For year earlier than 2012, use the following code to generate race:	*/
	gen race=1 if HISPANX==1	
	replace race=2 if RACEX==1& HISPANX==2	
	replace race=3 if RACEX==2& HISPANX==2	
	replace race=4 if RACEAX==1& HISPANX==2	
	replace race=5 if race==.	
	replace race=RACETHX if YEAR>=2012

	/* Recode marrital status	*/

gen marry=1 if MARRYX==1
replace marry =2 if (MARRYX==2|MARRYX==3|MARRYX==4)&marry==.
replace marry =3 if marry==.

/* Recode Education attainment in 2014 file	

gen edu=1 if EDRECODE==1
replace edu=2 if edu==.&(EDRECODE==2|EDRECODE==13)
replace edu=3 if edu==.&(EDRECODE==14|EDRECODE==15)
replace edu=4 if edu==.&EDRECODE==16
label variable edu "Education attainment:1=<highsch; 2=highsch; 3=college; 4=grad"
*/

/* 	For year before 2013, var EDRECODE is not available. Therefore, we need to generate edu based on var EDUCYR	*/
 	gen edu=1 if EDUCYR>=0&EDUCYR<=8	
	replace edu=2 if edu==.&(EDUCYR>=9&EDUCYR<=12)	
	replace edu=3 if edu==.&(EDUCYR>=13&EDUCYR<=16)	
	replace edu=4 if edu==.&EDUCYR==17	
/* 	All negative values of EDUCYR will become missing in edu. Leave them as is	*/
/*  EDUCYR wasn't available in 2013. But I won't work with 2013 data -> leave them as missing */
* Recode Education attainment in 2014 file	
replace edu=1 if EDRECODE==1 &edu==.
replace edu=2 if edu==.&(EDRECODE==2|EDRECODE==13)
replace edu=3 if edu==.&(EDRECODE==14|EDRECODE==15)
replace edu=4 if edu==.&EDRECODE==16
label variable edu "Education attainment:1=<highsch; 2=highsch; 3=college; 4=grad"


/*	Recode Born in the USA	*/
gen usborn=BORNUSA
replace usborn =. if BORNUSA<0
label variable usborn "Born in the USA:1=yes; 2=no"

/* Keep original  POVLEV	*/

/* Income	*/

gen income=FAMINC
replace income=. if income<0
label variable income "Family income in $"

/* Recode RTHLTH53, MNHLTH53	*/

gen health=RTHLTH53
replace health=. if RTHLTH53<0
label variable health "Perceived health status"
gen mental=MNHLTH53
replace mental=. if MNHLTH53<0
label variable mental "Perceived mental health status"

/*	Recode Any limitation. Before 2014, the variable is named ANYLIM*	*/

gen limit=ANYLMT
replace limit=. if ANYLMT<0
label variable limit "Any limitation: 1= yes; 2=no"

/*	Recode checkup within 1 year from interview	*/

gen checkup=1 if CHECK53==1
replace checkup=0 if checkup==.&CHECK53>0
label variable checkup "Check up within 1 years:1=yes, 2=no"

/* Generate new bmi value	*/

gen bmi=2 if BMINDX53>0&BMINDX53<18.5
replace bmi=1 if bmi==.&(BMINDX53>=18.5&BMINDX53<=24.9)
replace bmi=3 if bmi==.&(BMINDX53>=25&BMINDX53<=29.9)
replace bmi=4 if bmi==.&BMINDX53>=30
label variable bmi "1=normal;2=under;3=over;4=obese"

/* Recode usual source of care	*/

gen usual=HAVEUS42
replace usual=. if usual<0
label variable usual "Have usual source of care:1=yes; 2= no"

/*	Recode Time travel to usual source of care	*/

gen time=TMTKUS42
replace time=. if TMTKUS42<0

/*	Recode location of usual source of care	*/

gen location=1 if LOCATN42==1
replace location =2 if LOCATN42==2|LOCATN42==3
label variable location "Location of usual source: 1= office; 2= hospital"

/* Recode Unable to receive medical treatment and Delay in receiving treatment into a single variable	*/

gen unable_delay=1 if MDUNAB42==1|MDDLAY42==1
replace unable_delay=0 if MDUNAB42==2&MDDLAY42==2
label variable unable_delay "Unable or delayed to receive medical treatment: 1=yes; 2=no"

/*	Generate new employment variable	*/

gen employment=1 if EMPST53H==34
replace employment=2 if  HOUR53H>=40&EMPST53H==1
replace employment=3 if employment==.
label variable employment "Employment status:1=unemployed;2=full-time;3=part-time"

/*	Recode hourly wage	*/

gen wage=HRWG53H
replace wage=. if HRWG53H<0
label variable wage "Hourly wage for those employed, not self-employed"

/*	Recode insurance status	*/

gen insurance=1 if INSCOV==3
replace insurance=2 if INSCOV==2
replace insurance=3 if insurance==.
label variable insurance "Insurance status:1=uninsured;2=public; 3=private"

/*	Generate dependent variables	*/

gen visit_total=OBTOTV+OPTOTV
label variable visit_total "Total # of visits to all physicians and non-physician"
gen visit_total_phy=OBDRV+OPDRV
label variable visit_total_phy "Total # of visits to physician only"
gen p_total=(OBVEXP+OPTEXP)/visit_total
label variable p_total "Price-total payment-all visits"
gen p_self=(OBVSLF+OPTSLF)/visit_total
label variable p_self "Price-self pay-all visits"

gen p_total_phy=(OBDEXP+OPVEXP+OPSEXP)/ visit_total_phy
label variable p_total_phy "Price-total payment-visits to physicians only"
gen p_self_phy=(OBDSLF+OPVSLF+OPSSLF)/ visit_total_phy
label variable p_self_phy "Price-self pay-visits to physicians only"
gen p_total_pc= pc_cost_total/ pc_visit_total
label variable p_total_pc "Price-total payment-visits to PC physicians only"
gen p_self_pc= pc_cost_self / pc_visit_total
label variable p_self_pc "Price-self pay-visits to PC physicians only"

gen p_total_ER=ERTEXP/ERTOT
label variable p_total_ER "Price-total payment-ER visits only"
gen p_self_ER=ERTSLF/ERTOT
label variable p_self_ER "Price-self pay-ER visits only"

save "$output/H172_final07_14.dta", replace
log close

**********************
* 7. Check variables *
**********************
use "$output/H172_final07_14", clear
log using "$log/MEPS_08_DataPrep_$version.log", replace
ds FAMINC POVLEV BMINDX53 PCS42 MCS42 HOUR53H HRWG53H O* ER* IP* RXTOT *WTF DIABWF  ///
VARPSU pc_visit_total_OB sp_visit_total_OB pc_OBSF pc_OBXP sp_OBSF sp_OBXP VARSTR   ///
pc_OPSF pc_OPXP sp_OPSF sp_OPXP pc_visit_total pc_cost_total pc_cost_self FAMIDYR   ///
sp_visit_total sp_cost_self sp_cost_total income wage visit_total visit_total_phy   ///
p_total p_self p_total_phy p_self_phy p_total_pc p_self_pc p_total_ER p_self_ER     ///
DUID PID DUPERSID PANEL, not
foreach v in `r(varlist)' {
	tabulate YEAR `v' [aw=PERWTF], row
}
ds FAMINC POVLEV BMINDX53 PCS42 MCS42 HOUR53H HRWG53H O* ER* IP* RXTOT  	        ///
pc_visit_total_OB sp_visit_total_OB pc_OBSF pc_OBXP sp_OBSF sp_OBXP                 ///
pc_OPSF pc_OPXP sp_OPSF sp_OPXP pc_visit_total pc_cost_total pc_cost_self           ///
sp_visit_total sp_cost_self sp_cost_total income wage visit_total visit_total_phy   ///
p_total p_self p_total_phy p_self_phy p_total_pc p_self_pc p_total_ER p_self_ER 
foreach v in `r(varlist)' {
	mean `v' [aw=PERWTF], over(YEAR)
}
log close
	

********************
* 8. Save and exit *
********************

compress
save "$output/H172_final07_14", replace

exit, clear

