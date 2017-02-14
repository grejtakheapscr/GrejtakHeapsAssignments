// ==========================================================================
// largeDams
// ==========================================================================
// define project name
local projName "largeDams"
// ==========================================================================
// standard opening options
log close _all
graph drop _all
clear all
set more off
set linesize 80
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// construct directory structure for tabular data
capture mkdir "CodeArchive"
capture mkdir "DataClean"
capture mkdir "DataRaw"
capture mkdir "LogFile"
capture mkdir "Output"
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// create permanent text-based log file
log using "LogFile/`projName'.txt", replace text name(permLog)
// create temporary smcl log file for MarkDoc
quietly log using "LogFile/`projName'.smcl", replace smcl name(tempLog)
// ==========================================================================
// ==========================================================================
// ==========================================================================
/***
# largeDams
#### SOC 4650/5650: Intro to GIS
#### Corey Grejtak-Heaps
#### 02/10/2017
### Description
This is the do file for Problem Set 1
### Dependencies
This do-file was written and executed using Stata 14.2.
It also uses the latest [MarkDoc](https://github.com/haghish/markdoc/wiki)
package via GitHub as well as the latest versions of its dependencies:
***/
version 14
which markdoc
which weave
which statax
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/***
### Import/Open Data
***/
local rawData "MO_HYDRO_Dams.csv"

import delimited "MO_HYDRO_Dams.csv", varname (1)

/***
**2a.** This command imports the raw data into Stata.
***/

summarize

/***
**2b.** This command gives us a table summarizing the dataset that we're using. There are 15 variables in the dataset.
***/

drop maxstor resarea wtrshed

/***
**2c.** This command removed the variables maxstor, resarea, and wtrshed from our dataset.
***/

list objectid nid_id offname in 1/10

/***
**2d.** It appears that nid_id and objectid may be uniquely identify observations due to the numbers being consistent and in order. The dam facility names may also be uniquely identifying, but it's less likely due to the nature of names.
***/

isid objectid

/***
**2e.** An error was not generated after executing this command because objectid does indeed uniquely identifies observations. The variables nid_id and offname do not uniquely idemtify observations.
***/

duplicates report

/***
**2f.** There were no duplicate observations reported. The reason the offname didn't uniquely identify anything could be because with 5,271 observations it is likely that at least two dams share the same name.
***/

rename offname dam_name

/***
**2g.** I renamed offname to dam_name because it is a clearer description of what the variable represents.
***/

tabulate owntype , missing

/***
**2h.** The catergory P (Private) has the most dams, this means that private dams are the most common in this dataset.
***/

replace owntype = "Federal" if owntype == "F"
replace owntype = "Local Government" if owntype == "L"
replace owntype = "Private" if owntype == "P"
replace owntype = "State" if owntype == "S"
replace owntype = "Public Utility" if owntype == "U"

/***
**2i.** The replace command allowed me to change all of these names for a more clear dataset. To confirm all changes worked I tabulated another owntype frequency table, not seen here.
***/

tabulate yrcmplt , missing

/***
**2j.** The zero likely denotes that the the year the dam was completed is unknown, not documented properly, or there was an entry error.
***/

summarize damht

/***
**2k.** The average height of the dams in the dataset are 28.9 feet.
***/

drop if damht<28.88105

/***
**2l.** There are 2,042 observations greater than the mean of all the dams' height.
***/

tabulate damtype , missing

/***
**2m.** The most common type of dam construction is Earth, making up 93.78% of all dams in the subset we created in 2l.
***/

/***
**3a.** Yes, every variable in the dataset is in a unique column and measures only one concept.

**3b.** There are no duplicate in any observation's row. Having variables that do not uniquely identify observations isn't an issue because the variables that do uniquely identify observations allow us to avoid dropping duplicates that are not actually duplicates.

**3c.** There are now 2,042 observations in the cleaned dataset.

**3d.** The observational unit in this dataset, after being cleaned, is all Missouri dams in the US Army Corps of Engineers' National Inventory of Dams that are higher than average.

**3e.** This dataset is now tidy because there are no duplicate variables, objects with confusing names have been renamed, each column only represents one variable and there are no duplicate observations.

**3f.** The variable purpose would benefit by using descriptive words rather than acronyms or abbreviations.

***/

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/***
### Save and Export Clean Data
***/
save "DataClean/`projName'.dta", replace
export delimited "DataClean/`projName'.csv", replace
// ==========================================================================
// ==========================================================================
// ==========================================================================
// end MarkDoc log
/*
quietly log close tempLog
*/
// convert MarkDoc log to Markdown
markdoc "LogFile/`projName'", replace export(md)
copy "LogFile/`projName'.md" "Output/`projName'.md", replace
shell rm -R "LogFile/`projName'.md"
shell rm -R "LogFile/`projName'.smcl"
// ==========================================================================
// archive code and raw data
copy "`projName'.do" "CodeArchive/`projName'.do", replace
copy "`rawData'" "DataRaw/`rawData'", replace
// ==========================================================================
// standard closing options
log close _all
graph drop _all
set more on
// ==========================================================================
exit
