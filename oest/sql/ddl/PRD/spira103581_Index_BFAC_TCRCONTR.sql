USE BFAC
go

/*****************************************************************************
Description : script Creation INDEX TABLE  BFAC..TCRCONTR
Author      : ART
Date        : 04/04/2022
Spira       : 103581  

---------------------------------------------------------------------------
Modification :

*****************************************************************************/


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TCRCONTR') AND name='i_test')
BEGIN
    DROP INDEX TCRCONTR.i_test
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TCRCONTR') AND name='i_test')
        PRINT '<<< FAILED DROPPING INDEX dbo.TCRCONTR.i_test >>>'
    ELSE
        PRINT '<<< DROPPED INDEX dbo.TCRCONTR.i_test >>>'
END
go

IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TCRCONTR') AND name='ICRCONTR_00')
BEGIN
    DROP INDEX TCRCONTR.ICRCONTR_00
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TCRCONTR') AND name='ICRCONTR_00')
        PRINT '<<< FAILED DROPPING INDEX dbo.TCRCONTR.ICRCONTR_00 >>>'
    ELSE
        PRINT '<<< DROPPED INDEX dbo.TCRCONTR.ICRCONTR_00 >>>'
END
go


CREATE INDEX ICRCONTR_00
    ON dbo.TCRCONTR (CR_NF, CRUWY_NF, CRUW_NT)
go
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TCRCONTR') AND name='ICRCONTR_00')
    PRINT '<<< CREATED INDEX dbo.TCRCONTR.ICRCONTR_00 >>>'
ELSE
    PRINT '<<< FAILED CREATING INDEX dbo.TCRCONTR.ICRCONTR_00 >>>'
go



  
