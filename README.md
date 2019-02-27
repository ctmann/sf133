# SF133
The SF133 is published by OMB's MAX budget execution database and represents an authoritative source for tracking budget execution at the account level. 

Difficult to use, the online reports (.xlsx) include a "Raw Data" tab that necessarily mingle subtotals and detailed line item changes, requiring great care to accurately disentangle. Pivot tables are also included in each online workbook. Cross-checking results with these tables and other related reports (see 1022, below) highly recommended. In sum...a dangerous dataset.

### Purpose of this Repository
This repository compiles the **Department of Defense-Military** Monthly Report collection for years **FY2013-FY2018.** (Earlier years vary too much in both format and shape.) By combining reports from past years, it should be possible to track cumulative changes in a single appropriation (or appn category) from year to year. 

Such an analysis could reveal spending patterns that lie outside the norm, for example, by identifying historical unobligated balances in Operation and Maintence Army accounts.

### How to Use this Repository
* Updating Data: See section "How to Update..." in R script.
* Complete dataset: Size limitations prevent complete compiled dataset from being posted as .csv on Github. Users will consquently need to download and compile data using repository script. Currently, I have not "gathered" the amounts by reporting month, as I believed this might be too confusing for such a complicated dataset. 

### Reporting Timeframe
There are effectively two annual SF133 versions. The **Excel** report (with pivot tables), and the **XML** report. 

The Excel report includes only some months (see below). The XML report *seems* to contain every month, but I'm still evaluating.

The two versions do not share identical column names.

#### Reference: End of fiscal quarters, by month

Here's a reminder on the fiscal months of the year:

Quarter | Begin Month | End Month
--- | --- | ---
1 | October | December
2 | January | March
3 | April | June
4 | July | September

### Favorite Lines
OMB Circular A-11 Appendix F explains line numbers, which may change from year to year.

LINENO | LINE_DESC  | My notes
--- | --- | ---
1100 | BA: Disc: Appropriation | Seems to show original appn only in first year, and even this may be altered. Not certain about this line...
2490 | Unob Bal: end of year (total) | Unobligated funds. A sum of both expired (2413) and unexpired (2412).
2412 | Unexpired Unobligated Balance: end of year | equivalent to 2490 with STAT U (Unexpired)
2413 | Expired Unobligated Balance: end of year | equivalent to 2490 with STAT E (Expired)
1029 | Unob Bal: Other balances returned to the Treasury | Cancelled amounts. Somtimes cited by DOD as "Amounts Returned to Treasury from Canceling Accounts." Preferred field.
1089 | Exp Unob Bal: Other Balances withdrawn to Treasury | Cancelled unobligated. Not sure what this is.

The dataset contained in the "processed" folder contains the compiled SF133 filtered by my favorite lines (due to space limitations, the entire dataset could not be uploaded to Github). These are shown in the R code as:

    "1100",                         # APPN
    "2490", "2412", "2413",         # Unobligated, expired and unexpired
    "1029",                         # cancelled (DOD report)
    "1910", "2190", "3050", "4020"  # 1002 lines

## Limitations of the **Excel** SF133 report

Until FY2018, public SF133 reports skipped the first qtr reporting and left a gap at the end-of-year (missing SEP,OCT).

MONTH | FY Qtr | Notes
--- |---|---
NOV | |
... | | DEC added in FY2018
JAN | first month of 2nd qtr|
FEB ||
...| | MAR added in FY2018
APR | first month of 3rd qrtr|
MAY ||
...|| JUN added in FY2018
JUL | first month of 4th qtr|
AUG ||
...| | SEP added in FY2018
...| first month of 1st qtr| OCT added in FY2018


### Data Definitions
[OMB circular A-11, Appendix F](https://obamawhitehouse.archives.gov/sites/default/files/omb/assets/a11_current_year/app_f.pdf) contains data definitions for SF133.

### Formats
* In FY2018, OMB began providing a quarterly report, along with separate monthly (.xlsx)
* In FY2013, OMB began consistenly updating amounts in JAN, FEB, <no MAR>, APR, <no JUN>, JUL, AUG, <no SEP>, 
* In FY2012, OMB reported Nov, Jul, and Aug periods in Excel. (.xls)
* In previous years (FY1998-FY2011), only pdfs are available. (.pdf)

### Shape of Data
From FY2013-FY2017, there have been between 36-41 Variables, a satisfactory level of consistency. Data gets less reliable in earlier periods.

*  In FY2018, four quarterly variables were introduced ("AMT1", "AMT2", "AMT3", "AMT4"), and an abreviated line description (LINE_DESC_SHORT)
*  In FY2017, AMT_OCT (not included in previous years) introduced

### Data Inconsistencies
* TRAG (treasury agency code) wrongly identifies:
  -  12 (dept. of agriculture) and 
  -  69 (Dept.Transportation)
* OMB_ACCOUNT cuts off long titles (as "Medicare-Eligible REtiree Health Fund Contribution, National Gua")
* When FY1 is NA, one year money is implied (FY1 should be same as FY2)

### Selected Data Definitions

VARIABLE | NOTES
--- | ---|
AGENCY | For complete list, see OMB Circular A-11, Appendix C
BUREAU | ibid
OMB_ACCT | OMB Circular A-11, Section 79D
TRAG | Treasury Agency Code
STAT | Status- Expired or Unexpired
CRED_INT | Credit Accounts, Financing Accounts, Non-Financing Accounts
LINENO | For complete list, see OMB Circular A-11, Appendix F (also explains how lines are added together)
SECTION | 4 Sections (Budgetary Resources/ Status of Budgetary Resources / Change in Obligated Balance/ Budget Authority and Outlays, Net)
LINE_TYPE | D: Detail line, S: Summary or total line
AGEUP | 3-digit agency code. See OMB Circular A-1, Appendix C for complete list.
AMT...| Quarterly AMT where Month not indicated. Added in FY2018. (Dec, March, June, Sept)
Life.Begin/Life.End | added - Formatted YYYY (instead of YY).
Life.of.Money | added - indicates 1-year, 2-year, 3-year money, etc. 
Lifespan.of.Money | added - begin and end FY money, as 2017/2017, 2017/2018, 2017/2019, etc.
FY.cancelled | added - calculated by adding five years to end of period-of-availability


### Cross-Checking

#### Cross Check SF133 with 1022

Take care that 1022 corresponds with SF133 reporting date. (December = AMT1, for example)

1022 Column | 1022 Column Title |SF133 LINENO | SF 133 LINE_DESC
--- | ---| ---| ---
Col C | Approved Program | 1910 | Total budgetary resources (disc. and mand.)
Col E | Obligation Transactions in Current Fiscal Year | 2190 | New obligations and upward adjustments (total)
Col G | Gross Disbursements in Current Fiscal Year | 4020 |Disc: Outlays, gross (total)
Col H | Gross Unpaid Obligations End of Period (Col E+F+G) | 3050 |Ob Bal: EOY: Unpaid obligations
Col I | Total Unobligated Balance, (Col D-E) | 2490 |Unob Bal: end of year (total)


## Questions
* No-Year Money: No year money seems to have no begin (FY1) year. Is it implied? Not sure... 
* Report Dates: In previous years, the SF133 did not seem to include "end of year".
* What's up with the many conflicting treasury agency codes?



