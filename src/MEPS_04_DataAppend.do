**************************************************************************
*                      Project: MEPS                                 	 *
**************************************************************************
* purpose:   : Append data for ttest and trend test
* authors	 : Ha Tran (ngocha61084@gmail.com)
* first draft: January 2, 2017
* last update: January 2, 2017
* category   : Data preparation
* version    : 0102
**************************************************************************

*********************************
* 0. Table of Contents		    *
*********************************

* 1a. Basics
* 1b. Directories
* 2. Append Data
* 3. Exit

*********************************
* 1a. Basics					*
*********************************

clear all
version 14.1
set more off
set varabbrev off
capture log close
global version = "0102"

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

log using "$log\MEPS_00_2007 data_$version.log", replace


*********************************
* 2. Append Data				*
*********************************
use "$temp/MEPS_MeanDemand_2007", clear
	append using "$temp/MEPS_MeanDemand_2008"
		append using "$temp/MEPS_MeanDemand_2010"
			append using "$temp/MEPS_MeanDemand_2011"
				append using "$temp/MEPS_MeanDemand_2012"
					append using "$temp/MEPS_MeanDemand_2013"
						append using "$temp/MEPS_MeanDemand_2014"

save "$output/MEPS_MeanDemand07_14", replace

*********************************
* 3. Exit				*
*********************************
exit, clear




