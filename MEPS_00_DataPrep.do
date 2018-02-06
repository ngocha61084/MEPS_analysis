**************************************************************************
*                       Project: MEPS                                	 *
**************************************************************************
* purpose:   : Data Preparation
* authors	 : Ha Tran (ngocha61084@gmail.com)
* first draft: December 28, 2016
* last update: December 28, 2016
* category   : Data preparation
* version    : 1228
**************************************************************************

*********************************
* 0. Table of Contents		    *
*********************************

* 1a. Basics
* 1b. Directories
* 2. Create data of selected variables
* 3. Variables' distribution
* 4. Save and exit

*********************************
* 1a. Basics					*
*********************************

clear all
version 14.1
set more off
set varabbrev off
capture log close
global version = "1228"

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

log using "$log\MEPS_00_Dataprep_$version.log", replace

********************************************************
* 2. Create data of selected variables 				   *
********************************************************
*A. Transform data to .dta 
* Full year consolidated data
foreach y in 07 08 09 10 11 12 13 14 {
	import sasxport "$data_orig/Full Year Consolidated Data/20`y'/fycd_`y'.ssp"
	save "$data_orig/Stata Data/fycd_`y'", replace
}

*Medical Condition Data
foreach y in 07 08 09 10 11 12 13 14 {
	import sasxport "$data_orig/Medical Condition Data/20`y'/mcd_`y'.ssp"
	save "$data_orig/Stata Data/mcd_`y'", replace
}

*Office Based Medical Provider Visits Data
foreach y in 07 08 09 10 11 12 13 14 {
	import sasxport "$data_orig/Office Based Medical Provider Visits Data/20`y'/obmpvd_`y'.ssp"
	save "$data_orig/Stata Data/obmpvd_`y'", replace
}

*Outpatient Visits Data
foreach y in 07 08 09 10 11 12 13 14 {
	import sasxport "$data_orig/Outpatient Visits Data/20`y'/ovd_`y'.ssp"
	save "$data_orig/Stata Data/ovd_`y'", replace
}


* Employment Data
import sasxport "$data_orig/Employment Data/h131.ssp"
keep if year>=2007 & year<=2013
save "$data_orig/Stata Data/ed07_13", replace
 
foreach y in 07 08 09 10 11 12 13 {
use "$data_orig/Stata Data/ed07_13", replace
keep if year==20`y'
save "$data_orig/Stata Data/ed_`y'", replace
}



*B. Keep only selected variables (based on Phuc' excel list)

*Full year consolidated data
*2017:
use "$data_orig/Stata Data/fycd_07", clear
	merge 1:1 dupersid using "$data_orig/Stata Data/ed_07"
	drop _merge
	
ren racethnx racethx
ren heardi42 dfhear42
ren seedif42 dfsee42 
ren anylim07 anylmt07
ren whenst53 bstst53 
ren whnbwl53 clntst53  
ren phyact53 phyexe53
drop health42 hideg

keep duid pid dupersid panel famidyr fams1231 famszeyr region07 begrfm31 begrfy31 ///
endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42 begrfm53 begrfy53 endrfm53  ///
endrfy53 endrfm07 endrfy07 inscop31 inscop42 inscop53 inscop07 pstats31 pstats42  ///
pstats53 /*demographic variables:*/ age07x sex racethx marry07x ed* langhm42      ///
/*income variables*/ ttlp07x faminc07 povcat07 povlev07 wagep07x /*personal:*/    ///
rthlth31 rthlth42 rthlth53 mnhlth31 mnhlth42 mnhlth53 /*health status:*/ iadlhp31 ///
iadlhp53 adlhlp31 adlhlp53 aidhlp31 aidhlp53 wlklim31 wlklim53 actlim31 actlim53  ///
soclim31 soclim53 coglim31 coglim53 dfhear42 dfsee42 /*dfcog42*/ wlkdif*          ///
anylmt07 dentck53 bpchek53 cholck53 check53 nofat53 exrcis53 flusht53 /*dfcog42*/ ///
asprin53 noaspr53 stomch53 lsteth53 psa53 hyster53 papsmr53 brstex53 mamogr53     ///
/*bst*/ bstst53 /*bstsre53*/ /*clntst53 clntre53*/ visslf07 othexp07 clntst53     ///
/*phyexe53*/ phyexe53 bmindx53 seatbe53 othslf07 usborn42 hispanx racex raceax    ///
saqelig pcs42 mcs42 k6sum42 phq242 /*Disability days*/ ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 /*access to care*/ haveus42 ynousc42 noreas42 seldsi42 ///
neware42 dkwhru42 uscnot42 persla42 diffpl42 insrpl42 myself42 careco42 /*nohi*/  ///
/*othrea42*/ othins42 jobrsn42 newdoc42 docels42 nolike42 /*health42*/ knowdr42   ///
onjob42 nogodr42 trans42 clinic42 provty42 plctyp42 tmtkus42 typepe42 locatn42    ///
hsplap42 whitpr42 blckpr42 asianp42 natamp42 pacisp42 othrcp42 gendrp42 minorp42  ///
preven42 reffrl42 ongong42 phnreg42 offhou42 phnreg42 afthou42 treatm42 respct42  ///
decide42 explop42 langpr42 mdunab42 mdunrs42 mddlay42 mddlrs42 dnunab42 dnunrs42  ///
dndlay42 dndlrs42 pmunab42 pmunrs42 pmdlay42 pmdlrs42 /*employment variable:*/    ///
empst31h empst42h empst53h slfcm31h slfcm42h slfcm53h hour31h hour42h hour53h     ///
hrwg31h hrwg42h hrwg53h /*summary health insurance*/ prvev07 triev07 mcrev07 	  ///
mcdev07 opaev07 opbev07 unins07 inscov07 /*insurc07*/ /*personal level util*/     ///
obtotv07 obdrv07 obothv07 obchir07 obnurs07 obopto07 obasst07 obther07 optotv07   ///
opdrv07 opothv07 amchir07 amnurs07 amopto07 amasst07 amther07 ertot07 ipzero07    ///
ipdis07 ipngtd07 dvtot07 dvgen07 dvorth07 hhtotd07 hhagd07 hhindd07 hhinfd07      ///
rxtot07 /*weight*/ perwt07f famwt07f saqwt07f diabw07f varstr varpsu visexp07     ///
obvexp07 obvslf07 obdexp07 obdslf07 oboexp07 oboslf07 optexp07 optslf07 opfexp07  ///
opfslf07 opdexp07 opdslf07 opvexp07 opvslf07 opsexp07 opsslf07 opoexp07 oposlf07  ///
oppexp07 oppslf07 ertexp07 ertslf07 erfexp07 erfslf07 erdexp07 erdslf07 iptexp07  ///
iptslf07 ipfexp07 ipfslf07 ipdexp07 ipdslf07 zifexp07 zifslf07 zidexp07 zidslf07  ///
rxexp07 rxslf07 dvtexp07 dvtslf07 hhaexp07 hhaslf07 hhnexp07 hhnslf07     

ren *07 *
ren *07* **
ren usborn42 bornusa
gen year=2007
save "$data_proc/fycd_07", replace



*2008:
use "$data_orig/Stata Data/fycd_08", clear
	merge 1:1 dupersid using "$data_orig/Stata Data/ed_08"
	drop _merge
	
ren *08 *07
drop dsft0753 dsey0753 dsch0753 dsfl0753
ren *08* *07*
ren racethnx racethx
ren heardi42 dfhear42
ren seedif42 dfsee42 
ren anylim07 anylmt07
ren whenst53 bstst53 
ren whnbwl53 clntst53  
ren phyact53 phyexe53
drop health42 hideg

keep duid pid dupersid panel famidyr fams1231 famszeyr region07 begrfm31 begrfy31 ///
endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42 begrfm53 begrfy53 endrfm53  ///
endrfy53 endrfm07 endrfy07 inscop31 inscop42 inscop53 inscop07 pstats31 pstats42  ///
pstats53 /*demographic variables:*/ age07x sex racethx marry07x ed* langhm42      ///
/*income variables*/ ttlp07x faminc07 povcat07 povlev07 wagep07x /*personal lev*/ ///
rthlth31 rthlth42 rthlth53 mnhlth31 mnhlth42 mnhlth53 /*health status:*/ iadlhp31 ///
iadlhp53 adlhlp31 adlhlp53 aidhlp31 aidhlp53 wlklim31 wlklim53 actlim31 actlim53  ///
soclim31 soclim53 coglim31 coglim53 dfhear42 dfsee42 /*dfcog42*/ wlkdif* /*dfd*/  ///
/*dfer*/ anylmt07 dentck53 bpchek53 cholck53 check53 nofat53 exrcis53 flusht53    ///
asprin53 noaspr53 stomch53 lsteth53 psa53 hyster53 papsmr53 brstex53 mamogr53     ///
/*bst*/ bstst53 /*bstsre53*/ /*clntst53 clntre53*/ /*sgmtst53 whnbwl53*/ clntst53 ///
/*phyexe53*/ phyexe53 bmindx53 seatbe53 usborn42 hispanx racex raceax othslf07    ///
saqelig pcs42 mcs42 k6sum42 phq242 /*Disability days*/ ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 /*access to care*/ haveus42 ynousc42 noreas42 seldsi42 ///
neware42 dkwhru42 uscnot42 persla42 diffpl42 insrpl42 myself42 careco42 /*noh*/   ///
/*othrea42*/ othins42 jobrsn42 newdoc42 docels42 nolike42 /*health42*/ knowdr42   ///
onjob42 nogodr42 trans42 clinic42 provty42 plctyp42 tmtkus42 typepe42 locatn42    ///
hsplap42 whitpr42 blckpr42 asianp42 natamp42 pacisp42 othrcp42 gendrp42 minorp42  ///
preven42 reffrl42 ongong42 phnreg42 offhou42 phnreg42 afthou42 treatm42 respct42  ///
decide42 explop42 langpr42 mdunab42 mdunrs42 mddlay42 mddlrs42 dnunab42 dnunrs42  ///
dndlay42 dndlrs42 pmunab42 pmunrs42 pmdlay42 pmdlrs42 /*employment variable*/     ///
empst31h empst42h empst53h slfcm31h slfcm42h slfcm53h hour31h hour42h hour53h     ///
hrwg31h hrwg42h hrwg53h /*summary health insurance*/ prvev07 triev07 mcrev07 	  ///
mcdev07 opaev07 opbev07 unins07 inscov07 /*in07*/ /*personal level utilization*/  ///
obtotv07 obdrv07 obothv07 obchir07 obnurs07 obopto07 obasst07 obther07 optotv07   ///
opdrv07 opothv07 amchir07 amnurs07 amopto07 amasst07 amther07 ertot07 ipzero07    ///
ipdis07 ipngtd07 dvtot07 dvgen07 dvorth07 hhtotd07 hhagd07 hhindd07 hhinfd07      ///
rxtot07 /*weight*/ perwt07f famwt07f saqwt07f diabw07f varstr varpsu /*expend*/   ///
obvexp07 obvslf07 obdexp07 obdslf07 oboexp07 oboslf07 optexp07 optslf07 opfexp07  ///
opfslf07 opdexp07 opdslf07 opvexp07 opvslf07 opsexp07 opsslf07 opoexp07 oposlf07  ///
oppexp07 oppslf07 ertexp07 ertslf07 erfexp07 erfslf07 erdexp07 erdslf07 iptexp07  ///
iptslf07 ipfexp07 ipfslf07 ipdexp07 ipdslf07 zifexp07 zifslf07 zidexp07 zidslf07  ///
rxexp07 rxslf07 dvtexp07 dvtslf07 hhaexp07 hhaslf07 hhnexp07 hhnslf07 visexp07    ///
visslf07 othexp07 

ren *07 *08
ren *07* *08*
ren *08 *
ren *08* **
ren usborn42 bornusa
gen year=2008
save "$data_proc/fycd_08", replace



*2009
use "$data_orig/Stata Data/fycd_09", clear
	merge 1:1 dupersid using "$data_orig/Stata Data/ed_09"
	drop _merge
	
ren *09 *07
ren *09* *07*
ren racethnx racethx
ren heardi42 dfhear42
ren seedif42 dfsee42 
ren anylim07 anylmt07  
ren phyact53 phyexe53
drop hideg

keep duid pid dupersid panel famidyr fams1231 famszeyr region07 begrfm31 begrfy31 ///
endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42 begrfm53 begrfy53 endrfm53  ///
endrfy53 endrfm07 endrfy07 inscop31 inscop42 inscop53 inscop07 pstats31 pstats42  ///
pstats53 /*demographic variables:*/ age07x sex racethx marry07x ed* langhm42      ///
/*income variables*/ ttlp07x faminc07 povcat07 povlev07 wagep07x /*personal lev*/ ///
rthlth31 rthlth42 rthlth53 mnhlth31 mnhlth42 mnhlth53 /*health status:*/ iadlhp31 ///
iadlhp53 adlhlp31 adlhlp53 aidhlp31 aidhlp53 wlklim31 wlklim53 actlim31 actlim53  ///
soclim31 soclim53 coglim31 coglim53 dfhear42 dfsee42 /*dfcog42*/ wlkdif* /*dfd*/  ///
/*dfer*/ anylmt07 dentck53 bpchek53 cholck53 check53 nofat53 exrcis53 flusht53    ///
asprin53 noaspr53 stomch53 lsteth53 psa53 hyster53 papsmr53 brstex53 mamogr53     ///
/*bst*/ bstst53 /*bstsre53*/ /*clntst53 clntre53*/ /*sgmtst53 whnbwl53*/ clntst53 ///
/*phyexe53*/ phyexe53 bmindx53 seatbe53 othslf07 usborn42 hispanx racex raceax    ///
saqelig pcs42 mcs42 k6sum42 phq242 /*Disability days*/ ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 /*access to care*/ haveus42 ynousc42 noreas42 seldsi42 ///
neware42 dkwhru42 uscnot42 persla42 diffpl42 insrpl42 myself42 careco42 /*nohi*/  ///
/*othrea42*/ othins42 jobrsn42 newdoc42 docels42 nolike42 /*health42*/ knowdr42   ///
onjob42 nogodr42 trans42 clinic42 provty42 plctyp42 tmtkus42 typepe42 locatn42    ///
hsplap42 whitpr42 blckpr42 asianp42 natamp42 pacisp42 othrcp42 gendrp42 minorp42  ///
preven42 reffrl42 ongong42 phnreg42 offhou42 phnreg42 afthou42 treatm42 respct42  ///
decide42 explop42 langpr42 mdunab42 mdunrs42 mddlay42 mddlrs42 dnunab42 dnunrs42  ///
dndlay42 dndlrs42 pmunab42 pmunrs42 pmdlay42 pmdlrs42 /*employment variable*/     ///
empst31h empst42h empst53h slfcm31h slfcm42h slfcm53h hour31h hour42h hour53h     ///
hrwg31h hrwg42h hrwg53h /*summary health insurance*/ prvev07 triev07 mcrev07 	  ///
mcdev07 opaev07 opbev07 unins07 inscov07 /*irc07*/ /*personal level utilization*/ ///
obtotv07 obdrv07 obothv07 obchir07 obnurs07 obopto07 obasst07 obther07 optotv07   ///
opdrv07 opothv07 amchir07 amnurs07 amopto07 amasst07 amther07 ertot07 ipzero07    ///
ipdis07 ipngtd07 dvtot07 dvgen07 dvorth07 hhtotd07 hhagd07 hhindd07 hhinfd07      ///
rxtot07 /*wght*/ perwt07f famwt07f saqwt07f diabw07f varstr varpsu /*expend:*/    ///
obvexp07 obvslf07 obdexp07 obdslf07 oboexp07 oboslf07 optexp07 optslf07 opfexp07  ///
opfslf07 opdexp07 opdslf07 opvexp07 opvslf07 opsexp07 opsslf07 opoexp07 oposlf07  ///
oppexp07 oppslf07 ertexp07 ertslf07 erfexp07 erfslf07 erdexp07 erdslf07 iptexp07  ///
iptslf07 ipfexp07 ipfslf07 ipdexp07 ipdslf07 zifexp07 zifslf07 zidexp07 zidslf07  ///
rxexp07 rxslf07 dvtexp07 dvtslf07 hhaexp07 hhaslf07 hhnexp07 hhnslf07 visexp07    ///
visslf07 othexp07 

ren *07 *09
ren *07* *09*
ren *09 *
ren *09* **
ren usborn42 bornusa
gen year=2009
save "$data_proc/fycd_09", replace



*2010
use "$data_orig/Stata Data/fycd_10", clear
	merge 1:1 dupersid using "$data_orig/Stata Data/ed_10"
	drop _merge
	
ren *10 *07
ren *10* *07*
ren racethnx racethx
ren heardi42 dfhear42
ren seedif42 dfsee42 
ren anylim07 anylmt07  
ren phyact53 phyexe53
drop hideg

keep duid pid dupersid panel famidyr fams1231 famszeyr region07 begrfm31 begrfy31 ///
endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42 begrfm53 begrfy53 endrfm53  ///
endrfy53 endrfm07 endrfy07 inscop31 inscop42 inscop53 inscop07 pstats31 pstats42  ///
pstats53 /*demographic variables:*/ age07x sex racethx marry07x ed* langhm42      ///
/*income variables*/ ttlp07x faminc07 povcat07 povlev07 wagep07x /*personal le:*/ ///
rthlth31 rthlth42 rthlth53 mnhlth31 mnhlth42 mnhlth53 /*health status:*/ iadlhp31 ///
iadlhp53 adlhlp31 adlhlp53 aidhlp31 aidhlp53 wlklim31 wlklim53 actlim31 actlim53  ///
soclim31 soclim53 coglim31 coglim53 dfhear42 dfsee42 /*dfcog42*/ wlkdif* /*df42*/ ///
/*dfe42*/ anylmt07 dentck53 bpchek53 cholck53 check53 nofat53 exrcis53 flusht53   ///
asprin53 noaspr53 stomch53 lsteth53 psa53 hyster53 papsmr53 brstex53 mamogr53     ///
/*bst*/ bstst53 /*bstsre53*/ /*clntst53 clntre53*/ /*sgmtst53 whnbwl53*/ clntst53 ///
/*phyexe53*/ phyexe53 bmindx53 seatbe53 othslf07 usborn42 hispanx racex raceax    ///
saqelig pcs42 mcs42 k6sum42 phq242 /*Disability days*/ ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 /*access to care*/ haveus42 ynousc42 noreas42 seldsi42 ///
neware42 dkwhru42 uscnot42 persla42 diffpl42 insrpl42 myself42 careco42 /*nohi2*/ ///
/*othrea42*/ othins42 jobrsn42 newdoc42 docels42 nolike42 /*health42*/ knowdr42   ///
onjob42 nogodr42 trans42 clinic42 provty42 plctyp42 tmtkus42 typepe42 locatn42    ///
hsplap42 whitpr42 blckpr42 asianp42 natamp42 pacisp42 othrcp42 gendrp42 minorp42  ///
preven42 reffrl42 ongong42 phnreg42 offhou42 phnreg42 afthou42 treatm42 respct42  ///
decide42 explop42 langpr42 mdunab42 mdunrs42 mddlay42 mddlrs42 dnunab42 dnunrs42  ///
dndlay42 dndlrs42 pmunab42 pmunrs42 pmdlay42 pmdlrs42 /*employment variable*/     ///
empst31h empst42h empst53h slfcm31h slfcm42h slfcm53h hour31h hour42h hour53h     ///
hrwg31h hrwg42h hrwg53h /*summary health insurance*/ prvev07 triev07 mcrev07 	  ///
mcdev07 opaev07 opbev07 unins07 inscov07 /*ins*/ /*personal level utilization*/   ///
obtotv07 obdrv07 obothv07 obchir07 obnurs07 obopto07 obasst07 obther07 optotv07   ///
opdrv07 opothv07 amchir07 amnurs07 amopto07 amasst07 amther07 ertot07 ipzero07    ///
ipdis07 ipngtd07 dvtot07 dvgen07 dvorth07 hhtotd07 hhagd07 hhindd07 hhinfd07      ///
rxtot07 /*weight*/ perwt07f famwt07f saqwt07f diabw07f varstr varpsu /*expend*/   ///
obvexp07 obvslf07 obdexp07 obdslf07 oboexp07 oboslf07 optexp07 optslf07 opfexp07  ///
opfslf07 opdexp07 opdslf07 opvexp07 opvslf07 opsexp07 opsslf07 opoexp07 oposlf07  ///
oppexp07 oppslf07 ertexp07 ertslf07 erfexp07 erfslf07 erdexp07 erdslf07 iptexp07  ///
iptslf07 ipfexp07 ipfslf07 ipdexp07 ipdslf07 zifexp07 zifslf07 zidexp07 zidslf07  ///
rxexp07 rxslf07 dvtexp07 dvtslf07 hhaexp07 hhaslf07 hhnexp07 hhnslf07 visexp07    ///
visslf07 othexp07 

ren *07 *10
ren *07* *10*
ren *10 *
ren *10* **
ren usborn42 bornusa
gen year=2010
save "$data_proc/fycd_10", replace



*2011: 
use "$data_orig/Stata Data/fycd_11", clear
	merge 1:1 dupersid using "$data_orig/Stata Data/ed_11"
	drop _merge
ren *11 *07
ren *11* *07*
ren racethnx racethx
ren heardi42 dfhear42
ren seedif42 dfsee42 
ren anylim07 anylmt07 
drop hideg 
ren eduyrdeg eduyrdg
keep duid pid dupersid panel famidyr fams1231 famszeyr region07 begrfm31 begrfy31 ///
endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42 begrfm53 begrfy53 endrfm53  ///
endrfy53 endrfm07 endrfy07 inscop31 inscop42 inscop53 inscop07 pstats31 pstats42  ///
pstats53 /*demographic variables:*/ age07x sex racethx marry07x ed* langhm42      ///
/*income variables*/ ttlp07x faminc07 povcat07 povlev07 wagep07x /*personal lev*/ ///
rthlth31 rthlth42 rthlth53 mnhlth31 mnhlth42 mnhlth53 /*health status:*/ iadlhp31 ///
iadlhp53 adlhlp31 adlhlp53 aidhlp31 aidhlp53 wlklim31 wlklim53 actlim31 actlim53  ///
soclim31 soclim53 coglim31 coglim53 dfhear42 dfsee42 /*dfcog42*/ wlkdif* /*dfdr*/ ///
/*dfern*/ anylmt07 dentck53 bpchek53 cholck53 check53 nofat53 exrcis53 flusht53   ///
asprin53 noaspr53 stomch53 lsteth53 psa53 hyster53 papsmr53 brstex53 mamogr53     ///
/*bst*/ bstst53 /*bstsre53*/ /*clntst53 clntre53*/ /*sgmtst53 whnbwl53*/ clntst53 ///
/*phyexe53*/ phyexe53 bmindx53 seatbe53 othslf07 usborn42 hispanx racex raceax    ///
saqelig pcs42 mcs42 k6sum42 phq242 /*Disability days*/ ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 /*access to care*/ haveus42 ynousc42 noreas42 seldsi42 ///
neware42 dkwhru42 uscnot42 persla42 diffpl42 insrpl42 myself42 careco42 /*nohi*/  ///
/*othrea42*/ othins42 jobrsn42 newdoc42 docels42 nolike42 /*health42*/ knowdr42   ///
onjob42 nogodr42 trans42 clinic42 provty42 plctyp42 tmtkus42 typepe42 locatn42    ///
hsplap42 whitpr42 blckpr42 asianp42 natamp42 pacisp42 othrcp42 gendrp42 minorp42  ///
preven42 reffrl42 ongong42 phnreg42 offhou42 phnreg42 afthou42 treatm42 respct42  ///
decide42 explop42 langpr42 mdunab42 mdunrs42 mddlay42 mddlrs42 dnunab42 dnunrs42  ///
dndlay42 dndlrs42 pmunab42 pmunrs42 pmdlay42 pmdlrs42 /*employment variable*/     ///
empst31h empst42h empst53h slfcm31h slfcm42h slfcm53h hour31h hour42h hour53h     ///
hrwg31h hrwg42h hrwg53h /*summary health insurance*/ prvev07 triev07 mcrev07 	  ///
mcdev07 opaev07 opbev07 unins07 inscov07 /*insu*/ /*personal level utilization*/  ///
obtotv07 obdrv07 obothv07 obchir07 obnurs07 obopto07 obasst07 obther07 optotv07   ///
opdrv07 opothv07 amchir07 amnurs07 amopto07 amasst07 amther07 ertot07 ipzero07    ///
ipdis07 ipngtd07 dvtot07 dvgen07 dvorth07 hhtotd07 hhagd07 hhindd07 hhinfd07      ///
rxtot07 /*weight*/ perwt07f famwt07f saqwt07f diabw07f varstr varpsu /*expend*/   ///
obvexp07 obvslf07 obdexp07 obdslf07 oboexp07 oboslf07 optexp07 optslf07 opfexp07  ///
opfslf07 opdexp07 opdslf07 opvexp07 opvslf07 opsexp07 opsslf07 opoexp07 oposlf07  ///
oppexp07 oppslf07 ertexp07 ertslf07 erfexp07 erfslf07 erdexp07 erdslf07 iptexp07  ///
iptslf07 ipfexp07 ipfslf07 ipdexp07 ipdslf07 zifexp07 zifslf07 zidexp07 zidslf07  ///
rxexp07 rxslf07 dvtexp07 dvtslf07 hhaexp07 hhaslf07 hhnexp07 hhnslf07 visexp07    ///
visslf07 othexp07 othslf07 usborn42 hispanx racex raceax

ren *07 *11
ren *07* *11*
ren *11 *
ren *11* **
ren usborn42 bornusa
gen year=2011
save "$data_proc/fycd_11", replace



*2012: 
use "$data_orig/Stata Data/fycd_12", clear
merge 1:1 dupersid using "$data_orig/Stata Data/ed_12"
drop _merge
drop hideg
ren eduyrdeg eduyrdg
ren anylim12 anylmt12
ren heardi42 dfhear42
ren seedif42 dfsee42
keep duid pid dupersid panel famidyr fams1231 famszeyr region12 begrfm31 begrfy31 ///
endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42 begrfm53 begrfy53 endrfm53  ///
endrfy53 endrfm12 endrfy12 inscop31 inscop42 inscop53 inscop12 pstats31 pstats42  ///
pstats53 /*demographic variables:*/ age12x sex racethx marry12x ed* langhm42      ///
/*income variables*/ ttlp12x faminc12 povcat12 povlev12 wagep12x /*personal lev*/ ///
rthlth31 rthlth42 rthlth53 mnhlth31 mnhlth42 mnhlth53 /*health status:*/ iadlhp31 ///
iadlhp53 adlhlp31 adlhlp53 aidhlp31 aidhlp53 wlklim31 wlklim53 actlim31 actlim53  ///
soclim31 soclim53 coglim31 coglim53 dfhear42 dfsee42 /*dfcog42*/ wlkdif* /*dfd*/  ///
/*dfe42*/ anylmt12 dentck53 bpchek53 cholck53 check53 nofat53 exrcis53 flusht53   ///
asprin53 noaspr53 stomch53 lsteth53 psa53 hyster53 papsmr53 brstex53 mamogr53     ///
/*bst*/ bstst53 /*bstsre53*/ /*clntst53 clntre53*/ /*sgmtst53 whnbwl53*/ clntst53 ///
/*phyexe53*/ phyexe53 bmindx53 seatbe53 othslf12 usborn42 hispanx raceax othexp12 ///
saqelig pcs42 mcs42 k6sum42 phq242 /*Disability days*/ ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 /*access to care*/ haveus42 ynousc42 noreas42 seldsi42 ///
neware42 dkwhru42 uscnot42 persla42 diffpl42 insrpl42 myself42 careco42 /*nohi*/  ///
/*othrea42*/ othins42 jobrsn42 newdoc42 docels42 nolike42 /*health42*/ knowdr42   ///
onjob42 nogodr42 trans42 clinic42 provty42 plctyp42 tmtkus42 typepe42 locatn42    ///
hsplap42 whitpr42 blckpr42 asianp42 natamp42 pacisp42 othrcp42 gendrp42 minorp42  ///
preven42 reffrl42 ongong42 phnreg42 offhou42 phnreg42 afthou42 treatm42 respct42  ///
decide42 explop42 langpr42 mdunab42 mdunrs42 mddlay42 mddlrs42 dnunab42 dnunrs42  ///
dndlay42 dndlrs42 pmunab42 pmunrs42 pmdlay42 pmdlrs42 /*employment variable*/     ///
empst31h empst42h empst53h slfcm31h slfcm42h slfcm53h hour31h hour42h hour53h     ///
hrwg31h hrwg42h hrwg53h /*summary health insurance*/ prvev12 triev12 mcrev12 	  ///
mcdev12 opaev12 opbev12 unins12 inscov12 /*insurc12*/ /*personal level util*/     ///
obtotv12 obdrv12 obothv12 obchir12 obnurs12 obopto12 obasst12 obther12 optotv12   ///
opdrv12 opothv12 amchir12 amnurs12 amopto12 amasst12 amther12 ertot12 ipzero12    ///
ipdis12 ipngtd12 dvtot12 dvgen12 dvorth12 hhtotd12 hhagd12 hhindd12 hhinfd12      ///
rxtot12 /*weight*/ perwt12f famwt12f saqwt12f diabw12f varstr varpsu /*expend*/   ///
obvexp12 obvslf12 obdexp12 obdslf12 oboexp12 oboslf12 optexp12 optslf12 opfexp12  ///
opfslf12 opdexp12 opdslf12 opvexp12 opvslf12 opsexp12 opsslf12 opoexp12 oposlf12  ///
oppexp12 oppslf12 ertexp12 ertslf12 erfexp12 erfslf12 erdexp12 erdslf12 iptexp12  ///
iptslf12 ipfexp12 ipfslf12 ipdexp12 ipdslf12 zifexp12 zifslf12 zidexp12 zidslf12  ///
rxexp12 rxslf12 dvtexp12 dvtslf12 hhaexp12 hhaslf12 hhnexp12 hhnslf12 visexp12    ///
visslf12 

gen racex=.
ren *12 *
ren *12* **
gen year=2012
ren fams31 fams1231
ren usborn42 bornusa
save "$data_proc/fycd_12", replace



*2013:
use "$data_orig/Stata Data/fycd_13", clear
	merge 1:1 dupersid using "$data_orig/Stata Data/ed_13"
	drop _merge
	
keep duid pid dupersid panel famidyr fams1231 famszeyr region13 begrfm31 begrfy31 ///
endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42 begrfm53 begrfy53 endrfm53  ///
endrfy53 endrfm13 endrfy13 inscop31 inscop42 inscop53 inscop13 pstats31 pstats42  ///
pstats53 /*demographic variables:*/ age13x sex racethx marry13x ed*  langhm42     ///
/*income variables*/ ttlp13x faminc13 povcat13 povlev13 wagep13x /*personal lev*/ ///
rthlth31 rthlth42 rthlth53 mnhlth31 mnhlth42 mnhlth53 /*health status:*/ iadlhp31 ///
iadlhp53 adlhlp31 adlhlp53 aidhlp31 aidhlp53 wlklim31 wlklim53 actlim31 actlim53  ///
soclim31 soclim53 coglim31 coglim53 dfhear42 dfsee42 /*dfcog42*/ wlkdif* /*dfd*/  ///
/*dfer*/ anylmt13 dentck53 bpchek53 cholck53 check53 nofat53 exrcis53 flusht53    ///
asprin53 noaspr53 stomch53 lsteth53 psa53 hyster53 papsmr53 brstex53 mamogr53     ///
/*bst*/ bstst53 /*bstsre53*/ /*clntst53 clntre53*/ /*sgmtst53 whnbwl53*/ clntst53 ///
/*phyexe53*/ phyexe53 bmindx53 seatbe53 othslf13 bornusa hispanx raceax othexp13  ///
saqelig pcs42 mcs42 k6sum42 phq242 /*Disability days*/ ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 /*access to care*/ haveus42 ynousc42 noreas42 seldsi42 ///
neware42 dkwhru42 uscnot42 persla42 diffpl42 insrpl42 myself42 careco42 /*nohi*/  ///
/*othrea42*/ othins42 jobrsn42 newdoc42 docels42 nolike42 /*health42*/ knowdr42   ///
onjob42 nogodr42 trans42 clinic42 provty42 plctyp42 tmtkus42 typepe42 locatn42    ///
hsplap42 whitpr42 blckpr42 asianp42 natamp42 pacisp42 othrcp42 gendrp42 minorp42  ///
preven42 reffrl42 ongong42 phnreg42 offhou42 phnreg42 afthou42 treatm42 respct42  ///
decide42 explop42 langpr42 mdunab42 mdunrs42 mddlay42 mddlrs42 dnunab42 dnunrs42  ///
dndlay42 dndlrs42 pmunab42 pmunrs42 pmdlay42 pmdlrs42 /*employment variable*/     ///
empst31h empst42h empst53h slfcm31h slfcm42h slfcm53h hour31h hour42h hour53h     ///
hrwg31h hrwg42h hrwg53h /*summary health insurance*/ prvev13 triev13 mcrev13 	  ///
mcdev13 opaev13 opbev13 unins13 inscov13 /*insurc13*/ /*personal level util*/     ///
obtotv13 obdrv13 obothv13 obchir13 obnurs13 obopto13 obasst13 obther13 optotv13   ///
opdrv13 opothv13 amchir13 amnurs13 amopto13 amasst13 amther13 ertot13 ipzero13    ///
ipdis13 ipngtd13 dvtot13 dvgen13 dvorth13 hhtotd13 hhagd13 hhindd13 hhinfd13      ///
rxtot13 /*weight*/ perwt13f famwt13f saqwt13f diabw13f varstr varpsu /*expend*/   ///
obvexp13 obvslf13 obdexp13 obdslf13 oboexp13 oboslf13 optexp13 optslf13 opfexp13  ///
opfslf13 opdexp13 opdslf13 opvexp13 opvslf13 opsexp13 opsslf13 opoexp13 oposlf13  ///
oppexp13 oppslf13 ertexp13 ertslf13 erfexp13 erfslf13 erdexp13 erdslf13 iptexp13  ///
iptslf13 ipfexp13 ipfslf13 ipdexp13 ipdslf13 zifexp13 zifslf13 zidexp13 zidslf13  ///
rxexp13 rxslf13 dvtexp13 dvtslf13 hhaexp13 hhaslf13 hhnexp13 hhnslf13 visexp13    ///
visslf13 othexp13 

gen racex=.
ren *13 *
ren *13* **
gen year=2013
save "$data_proc/fycd_13", replace



*2014:
use "$data_orig/Stata Data/fycd_14", clear
ren langspk langhm42
gen langpr42=.
keep duid pid dupersid panel famidyr fams1231 famszeyr region14 begrfm31 begrfy31 ///
endrfm31 endrfy31 begrfm42 begrfy42 endrfm42 endrfy42 begrfm53 begrfy53 endrfm53  ///
endrfy53 endrfm14 endrfy14 inscop31 inscop42 inscop53 inscop14 pstats31 pstats42  ///
pstats53 /*demographic variables:*/ age14x sex racethx marry14x ed* langhm42      ///
/*income variables*/ ttlp14x faminc14 povcat14 povlev14 wagep14x /*personal lev*/ ///
rthlth31 rthlth42 rthlth53 mnhlth31 mnhlth42 mnhlth53 /*health status:*/ iadlhp31 ///
iadlhp53 adlhlp31 adlhlp53 aidhlp31 aidhlp53 wlklim31 wlklim53 actlim31 actlim53  ///
soclim31 soclim53 coglim31 coglim53 dfhear42 dfsee42 /*dfcog42*/ wlkdif* /*dfd*/  ///
/*dfer*/ anylmt14 dentck53 bpchek53 cholck53 check53 nofat53 exrcis53 flusht53    ///
asprin53 noaspr53 stomch53 lsteth53 psa53 hyster53 papsmr53 brstex53 mamogr53     ///
/*bst*/ bstst53 /*bstsre53*/ /*clntst53 clntre53*/ /*sgmtst53 whnbwl53*/ clntst53 ///
/*phyexe53*/ phyexe53 bmindx53 seatbe53   ///
saqelig pcs42 mcs42 k6sum42 phq242 /*Disability days*/ ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 /*access to care*/ haveus42 ynousc42 noreas42 seldsi42 ///
neware42 dkwhru42 uscnot42 persla42 diffpl42 insrpl42 myself42 careco42 /*nohi*/  ///
/*othrea42*/ othins42 jobrsn42 newdoc42 docels42 nolike42 /*health42*/ knowdr42   ///
onjob42 nogodr42 trans42 clinic42 provty42 plctyp42 tmtkus42 typepe42 locatn42    ///
hsplap42 whitpr42 blckpr42 asianp42 natamp42 pacisp42 othrcp42 gendrp42 minorp42  ///
preven42 reffrl42 ongong42 phnreg42 offhou42 phnreg42 afthou42 treatm42 respct42  ///
decide42 explop42 langpr42 mdunab42 mdunrs42 mddlay42 mddlrs42 dnunab42 dnunrs42  ///
dndlay42 dndlrs42 pmunab42 pmunrs42 pmdlay42 pmdlrs42 /*employment variable*/     ///
empst31h empst42h empst53h slfcm31h slfcm42h slfcm53h hour31h hour42h hour53h     ///
hrwg31h hrwg42h hrwg53h /*summary health insurance*/ prvev14 triev14 mcrev14 	  ///
mcdev14 opaev14 opbev14 unins14 inscov14 /*insurc14*/ /*personal level util*/     ///
obtotv14 obdrv14 obothv14 obchir14 obnurs14 obopto14 obasst14 obther14 optotv14   ///
opdrv14 opothv14 amchir14 amnurs14 amopto14 amasst14 amther14 ertot14 ipzero14    ///
ipdis14 ipngtd14 dvtot14 dvgen14 dvorth14 hhtotd14 hhagd14 hhindd14 hhinfd14      ///
rxtot14 /*weight*/ perwt14f famwt14f saqwt14f diabw14f varstr varpsu /*expend*/   ///
obvexp14 obvslf14 obdexp14 obdslf14 oboexp14 oboslf14 optexp14 optslf14 opfexp14  ///
opfslf14 opdexp14 opdslf14 opvexp14 opvslf14 opsexp14 opsslf14 opoexp14 oposlf14  ///
oppexp14 oppslf14 ertexp14 ertslf14 erfexp14 erfslf14 erdexp14 erdslf14 iptexp14  ///
iptslf14 ipfexp14 ipfslf14 ipdexp14 ipdslf14 zifexp14 zifslf14 zidexp14 zidslf14  ///
rxexp14 rxslf14 dvtexp14 dvtslf14 hhaexp14 hhaslf14 hhnexp14 hhnslf14 visexp14    ///
visslf14 othexp14 

gen racex=.
ren *14 *
ren *14* **
gen year=2014
save "$data_proc/fycd_14", replace


* Append the data:
use "$data_proc/fycd_07"
	append using "$data_proc/fycd_08"
		append using "$data_proc/fycd_09"
			append using "$data_proc/fycd_10"
				append using "$data_proc/fycd_11"
					append using "$data_proc/fycd_12"
						append using "$data_proc/fycd_13"
							append using "$data_proc/fycd_14"
save "$data_proc/fycd07_14",replace
						
						
* Medical Condition Data
foreach y in 07 08 09 10 11 12 13 14 {
	use "$data_orig/Stata Data/mcd_`y'", clear
	keep dupersid condn condidx panel condrn icd9codx icd9prox cccodex perwt`y'f varstr varpsu
	ren perwt`y'f perwtf
	gen year=20`y'
	save "$data_proc/mcd_`y'", replace
}

use "$data_proc/mcd_07"
	append using "$data_proc/mcd_08"
		append using "$data_proc/mcd_09"
			append using "$data_proc/mcd_10"
				append using "$data_proc/mcd_11"
					append using "$data_proc/mcd_12"
						append using "$data_proc/mcd_13"
							append using "$data_proc/mcd_14"
save "$data_proc/mcd07_14",replace


* Office-based medical provider visits file
	use "$data_orig/Stata Data/obmpvd_07", clear
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffobtype ffbef07 fftot08 obsf07x obxp07x perwt07f varstr varpsu
	ren fftot08 fftot
	la var fftot "Total % of visits in FF after the survey year"
	ren *07 *
	ren *07* **
	gen year=2007
	save "$data_proc/obmpvd_07", replace

	use "$data_orig/Stata Data/obmpvd_08", clear
	ren *08 *07
	ren *08* *07*
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffobtype ffbef07 fftot09 obsf07x obxp07x perwt07f varstr varpsu
	ren fftot09 fftot
	la var fftot "Total % of visits in FF after the survey year"
	ren *07 *
	ren *07* **
	gen year=2008
	save "$data_proc/obmpvd_08", replace
	
	
	use "$data_orig/Stata Data/obmpvd_09", clear
	ren *09 *07
	ren *09* *07*
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffobtype ffbef07 fftot10 obsf07x obxp07x perwt07f varstr varpsu
	ren fftot10 fftot
	la var fftot "Total % of visits in FF after the survey year"
	ren *07 *
	ren *07* **
	gen year=2009
	save "$data_proc/obmpvd_09", replace
	
	
	use "$data_orig/Stata Data/obmpvd_10", clear
	ren *10 *07
	ren *10* *07*
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffobtype ffbef07 fftot11 obsf07x obxp07x perwt07f varstr varpsu
	ren fftot11 fftot
	la var fftot "Total % of visits in FF after the survey year"
	ren *07 *
	ren *07* **
	gen year=2010
	save "$data_proc/obmpvd_10", replace
	
	
	use "$data_orig/Stata Data/obmpvd_11", clear
	ren *11 *07
	ren *11* *07*
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffobtype ffbef07 fftot12 obsf07x obxp07x perwt07f varstr varpsu
	ren fftot12 fftot
	la var fftot "Total % of visits in FF after the survey year"
	ren *07 *
	ren *07* **
	gen year=2011
	save "$data_proc/obmpvd_11", replace
	
	
	use "$data_orig/Stata Data/obmpvd_12", clear
	ren *12 *07
	ren *12* *07*
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffobtype ffbef07 fftot13 obsf07x obxp07x perwt07f varstr varpsu
	ren fftot13 fftot
	la var fftot "Total % of visits in FF after the survey year"
	ren *07 *
	ren *07* **
	gen year=2012
	save "$data_proc/obmpvd_12", replace
	
	
	use "$data_orig/Stata Data/obmpvd_13", clear
	ren *13 *07
	ren *13* *07*
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffobtype ffbef07 fftot14 obsf07x obxp07x perwt07f varstr varpsu
	ren fftot14 fftot
	la var fftot "Total % of visits in FF after the survey year"
	ren *07 *
	ren *07* **
	gen year=2013
	save "$data_proc/obmpvd_13", replace
	
	
	use "$data_orig/Stata Data/obmpvd_14", clear
	ren *14 *07
	ren *14* *07*
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffobtype ffbef07 fftot15 obsf07x obxp07x perwt07f varstr varpsu
	ren fftot15 fftot
	la var fftot "Total % of visits in FF after the survey year"
	ren *07 *
	ren *07* **
	gen year=2014
	save "$data_proc/obmpvd_14", replace

	
use "$data_proc/obmpvd_07"
	append using "$data_proc/obmpvd_08"
		append using "$data_proc/obmpvd_09"
			append using "$data_proc/obmpvd_10"
				append using "$data_proc/obmpvd_11"
					append using "$data_proc/obmpvd_12"
						append using "$data_proc/obmpvd_13"
							append using "$data_proc/obmpvd_14"
save "$data_proc/obmpvd07_14",replace


* Outpatient Visit Data
foreach y in 07 08 09 10 11 12 13 14 {
	use "$data_orig/Stata Data/ovd_`y'", clear
	capture gen ffbef`y'=.
	capture ren fftot* fftot
	capture gen fftot=.
	keep dupersid evntidx eventrn panel ffeeidx seetlkpv seedoc drsplty medptype ///
	ffoptype ffbef`y' fftot opxp`y'x opfsf`y'x opfxp`y'x opdsf`y'x opdxp`y'x     ///
	perwt`y'f varstr varpsu
	ren *`y' *
	ren *`y'* **
	gen year=20`y'
	save "$data_proc/ovd_`y'", replace
}

use "$data_proc/ovd_07"
	append using "$data_proc/ovd_08"
		append using "$data_proc/ovd_09"
			append using "$data_proc/ovd_10"
				append using "$data_proc/ovd_11"
					append using "$data_proc/ovd_12"
						append using "$data_proc/ovd_13"
							append using "$data_proc/ovd_14"
save "$data_proc/ovd07_14",replace
log close

********************************************************
* 3. Variables' distribution		 				   *
********************************************************
* Full Year Consolidated Data
use "$data_proc/fycd07_14",replace
log using "$log\MEPS_01_Dataprep_$version.log", replace
ds duid pid dupersid panel famidyr perwtf famwtf saqwtf diabwf varstr varpsu age* ///
ttlpx faminc povlev wagepx bmindx53  pcs42 mcs42 ddnwrk31 ddnwrk42 ddnwrk53       ///
ddnscl31 ddnscl42 ddnscl53 hour* hrw* ob* op* am* ert* erf* erd*                  ///
ipzero zif* zid*  ipd* ipt* ipf* ipn* dvt* dvg* dvo* hht* hha*                    ///
ipdexp ipdslf ipngtd dvtot dvtexp dvtslf dvgen dvorth hhtotd hhagd hhaexp hhaslf  ///
hhi* hhn* visexp visslf othexp othslf rxtot rxexp rxslf eduyrdg, not
foreach x in `r(varlist)' {
tabulate year `x' [aw=perwtf],row
}
ds age* ttlpx faminc povlev wagepx bmindx53  pcs42 mcs42 ddnwrk31 ddnwrk42 ddnwrk53 ///
ddnscl31 ddnscl42 ddnscl53 hour* hrw* ob* op* am* ert* erf* erd* ipzero zif* zid*   ///
ipt* ipf* ipn* dvt* dvg* dvo* hht* hha* ipdexp ipdslf ipngtd dvtot dvtexp dvtslf    ///
dvgen dvorth hhtotd hhagd hhaexp hhaslf hhi* hhn* visexp visslf othexp othslf rxtot ///
rxexp rxslf eduyrdg ipd*  ///
foreach x in `r(varlist)' {
mean `x' [aw=perwtf],over(year)
}
log close


* Medical Condition Data
use "$data_proc/mcd07_14",clear
log using "$log\MEPS_02_Dataprep_$version.log", replace
* MEDICAL CONDITION DATA
tabulate year condrn [aw=perwtf], row
log close

* Office-based medical provider visits file
use "$data_proc/obmpvd07_14",clear
log using "$log\MEPS_03_Dataprep_$version.log", replace
*OFFICE-BASED MEDICAL PROVIDER VISITS DATA
foreach v in seetlkpv seedoc drsplty medptype ffobtype {
tabulate year `v' [aw=perwtf], row
}
foreach v in ffbef fftot obsfx obxpx {
mean `v' [aw=perwtf], over(year)
}
log close

* Outpatient Visit Data
use "$data_proc/ovd07_14", clear
log using "$log\MEPS_04_Dataprep_$version.log", replace
* OUTPATIENT VISITS DATA
foreach x in seetlkpv seedoc drsplty medptype ffoptype {
tabulate year `x' [aw=perwtf], row
}
foreach x in fftot opxpx opfsfx opfxpx opdsfx opdxpx perwtf varstr varpsu ffbef {
mean `x' [aw=perwtf], over(year)
}
log close

********************
* 4. Save and exit *
********************

exit, clear
