
# Project: MEPS Analysis - Collaborate with the researchers at Cleveland Clinic, Cleveland, OH


![Alt text](image/obamacare.png?raw=true "Title")

Introduction: Previous studies found that the Affordable Care Act Medicaid Expansions increased insurance coverage, access to care and utilization in low-income persons. Little is known about the demand for primary care on a national scale which is useful for health policy decision making. We aimed to estimate the current demand for primary care and examine trends over time.rapidly changing US healthcare environment. We aimed to estimate the demand for total visits, primary care visits, ED visits and examine the trend over time.


Analysis:

- MEPS_00_DataPrep.do: Data Prepation
	* Create data with selected variables
	* Variables' distributions
- MEPS_01_DataProc.do: Data Processing
	* Create CCI
	* Create Office-based medical provider visits
	* Create Outpatient department visits
	* Merge CCI, Office-based Medical Provider Visits and Outpatient Department with Full Year Consolidated Data
	* Recode remaining variables, generate final data
	* Check all final variables before running model

- MEPS_02_DataAnalysis: Data analysis
	* Run two-part models

- MEPS_03_Master: Master dofiles
	* Run all dofiles. 

- MEPS_04_DataAppend: Append data
	* Append data for trend tests.

Authors: Ha Tran (ngocha61084@gmail.com)



HAVE A LOVELY DAY!
