**************************************************************************
*                      Project: MEPS                          			 *
**************************************************************************
* purpose:   : Master do
* authors	 : Ha Tran (ngocha61084@gmail.com)
* first draft: December 29, 2016
* last update: December 30, 2016
* category   : Data process
* version    : 1229
**************************************************************************

*********************************
* 0. Table of Contents		    *
*********************************

* 1a. Basics
* 1b. Directories
* 2. Master do
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
* 2. Master do					*
*********************************
do "$do/MEPS_00_DataPrep_122816.do"

do "$do/MEPS_00_DataProc_122916.do"

do "$do/MEPS_00_DataAnalysis_123016.do"

********************
* 3. Save and exit *
********************

exit, clear

