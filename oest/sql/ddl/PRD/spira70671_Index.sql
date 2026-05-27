USE BRET
go

/*****************************************************************************
Description : script Creation INDEX TABLES  BRET..TRTOSTA et BRET..TPLCATRN
Author      : MZM
Date        : 28/06/2019
Spira       :70671  : req 10.7 / 10.8

---------------------------------------------------------------------------
Modification :

*****************************************************************************/


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TRTOSTA') AND name='ITRTOSTA_01')
BEGIN
    DROP INDEX TRTOSTA.ITRTOSTA_01
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TRTOSTA') AND name='ITRTOSTA_01')
        PRINT '<<< FAILED DROPPING INDEX dbo.TRTOSTA.ITRTOSTA_01 >>>'
    ELSE
        PRINT '<<< DROPPED INDEX dbo.TRTOSTA.ITRTOSTA_01 >>>'
END
go
CREATE NONCLUSTERED INDEX ITRTOSTA_01
    ON dbo.TRTOSTA (RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RETACCSEN_NT)
go
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TRTOSTA') AND name='ITRTOSTA_01')
    PRINT '<<< CREATED INDEX dbo.TRTOSTA.ITRTOSTA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING INDEX dbo.TRTOSTA.ITRTOSTA_01 >>>'
go

/*==============================================================*/
/* Index: TPLCATRN                                              */
/*==============================================================*/

IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TPLCATRN') AND name='IPLCATRN_03')
BEGIN
    DROP INDEX TPLCATRN.IPLCATRN_03
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TPLCATRN') AND name='IPLCATRN_03')
        PRINT '<<< FAILED DROPPING INDEX dbo.TPLCATRN.IPLCATRN_03 >>>'
    ELSE
        PRINT '<<< DROPPED INDEX dbo.TPLCATRN.IPLCATRN_03 >>>'
END
go
CREATE NONCLUSTERED INDEX IPLCATRN_03
    ON dbo.TPLCATRN (RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RETACCSEN_NT)
go
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TPLCATRN') AND name='IPLCATRN_03')
    PRINT '<<< CREATED INDEX dbo.TPLCATRN.IPLCATRN_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING INDEX dbo.TPLCATRN.IPLCATRN_03 >>>'
go

  
