# sf133

### Data Definitions
[OMB circular A-11, Appendix F](https://obamawhitehouse.archives.gov/sites/default/files/omb/assets/a11_current_year/app_f.pdf) contains data definitions for SF133.

### Formats
In FY2018, OMB began providing a quarterly report, along with separate monthly (.xlsx)
In FY2013, OMB began consistenly posting Excel files on monthly basis. (.xlsx)
In FY2012, OMB reported Nov, Jul, and Aug periods in Excel. (.xls)
In previous years (FY1998-FY2011), only pdfs are available. (.pdf)


### Shape
From FY2013-FY2017: 36 Variables

In FY2018, 4 new colnames introduced
* "AMT1"            
* "AMT2"            
* "AMT3"            
* "AMT4"            
* "LINE_DESC_SHORT"

In FY2017, AMT_OCT (not included in previous years) introduced

### Data Inconsistencies
TRAG (treasury agency code) wrongly identifies:
* 12 (dept. of agriculture) and 
* 69 (Dept.Transportation)

OMB_ACCOUNT cuts off long titles (as "Medicare-Eligible REtiree Health Fund Contribution, National Gua")

When FY1 is NA, one year money is implied (FY1 should be same as FY2)

## Questions
* No-Year Money: How can an account have no begin year, and "X" end year? How to track no year money with no begin year?



