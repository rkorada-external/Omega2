/*
DESCRIPTION - Spira 82100 Enhacement for -Segment creation - Add "Ultimate Group Cedent" in Criteria drilldown menu
AUTHOR - Sohal SINHA
DATE - 31/01/2020

*/
use BEST
GO

PRINT 'DELETION IF RECORD EXISTS'

DELETE FROM BEST..TSEGCRITERIA where SGTCRI_CF = 'CLI_ULT_GROUP' AND SGTCRISUBCAT_NT = 1 AND  SGTUWCOL_CF= 'ULT_NF' 
	
GO
