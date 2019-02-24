# sf133

### Data Definitions
[OMB circular A-11, Appendix F](https://obamawhitehouse.archives.gov/sites/default/files/omb/assets/a11_current_year/app_f.pdf) contains data definitions for SF133.

### Formats
In FY2018, OMB began providing a quarterly report, along with separate monthly (.xlsx)
In FY2013, OMB began consistenly posting Excel files on monthly basis. (.xlsx)
In FY2012, OMB reported Nov, Jul, and Aug periods in Excel. (.xls)
In previous years (FY1998-FY2011), only pdfs are available. (.pdf)

### Shape of Data
*  From FY2013-FY2017, 36-41 Variables
*  In FY2018, four quarterly amount variables introduced ("AMT1", "AMT2", "AMT3", "AMT4"), and an abreviated line description (LINE_DESC_SHORT)
*  In FY2017, AMT_OCT (not included in previous years) introduced

### Data Inconsistencies
* TRAG (treasury agency code) wrongly identifies:
  -  12 (dept. of agriculture) and 
  -  69 (Dept.Transportation)

OMB_ACCOUNT cuts off long titles (as "Medicare-Eligible REtiree Health Fund Contribution, National Gua")

When FY1 is NA, one year money is implied (FY1 should be same as FY2)

## Questions
* No-Year Money: How can an account have no begin year, and "X" end year? How to track no year money with no begin year?

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





### Best Lines
OMB Circular A-11 Appendix F explains line numbers, which may change from year to year.

LINENO | LINE_DESC  | My notes
--- | --- | ---
1100 | BA: Disc: Appropriation | Seems to show original appn only in first year, and even this may be altered slightly
2490 | Unob Bal: end of year (total) | Unobligated funds. Not sure how this applies to mid-year reporting.
2413 | Expired Unobligated Balance: end of year | Expired Funds. (Not sure this is identical with STAT variable)
1089 | Exp Unob Bal: Other Balances withdrawn to Treasury | Cancelled funds




