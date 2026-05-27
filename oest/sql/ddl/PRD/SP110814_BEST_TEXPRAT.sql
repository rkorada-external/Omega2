use BEST
go
PRINT '<<< Update Table BEST..TEXPRAT >>>'

DROP INDEX TEXPRAT.TEXPRAT
if exists (SELECT * FROM sysindexes WHERE id=OBJECT_ID('TEXPRAT') AND name='TEXPRAT')
    PRINT '<<< FAILED DROPPING INDEX TEXPRAT.TEXPRAT >>>'
else
    PRINT '<<< DROPPED INDEX TEXPRAT.TEXPRAT >>>'
go


ALTER TABLE BEST..TEXPRAT ADD MAINTRATINI_R USHA_R DEFAULT 0 NOT NULL
if exists (select 1 from syscolumns where id = object_id("TEXPRAT") and name = "MAINTRATINI_R")
    PRINT '<<< MAINTRATINI_R Column added successfully >>>'
go

ALTER TABLE BEST..TEXPRAT ADD UWY_NF UUWY_NF DEFAULT 8888 NOT NULL
if exists (select 1 from syscolumns where id = object_id("TEXPRAT") and name = "UWY_NF")
    PRINT '<<< UWY_NF Column added successfully >>>'
go


CREATE UNIQUE INDEX TEXPRAT_00 ON BEST..TEXPRAT (SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, CLODAT_D, PER_CF, UWY_NF)

if exists (SELECT * FROM sysindexes WHERE id=OBJECT_ID('TEXPRAT') AND name='TEXPRAT_00')
    PRINT '<<< CREATED INDEX TEXPRAT.TEXPRAT_00 >>>'
else
    PRINT '<<< FAILED CREATING INDEX TEXPRAT.TEXPRAT_00 >>>'
go


use BTRAV
go
PRINT '<<< Update Table BTRAV..TEXPRAT >>>'

ALTER TABLE BTRAV..TEXPRAT ADD MAINTRATINI_R USHA_R DEFAULT 0 NOT NULL
if exists (select 1 from syscolumns where id = object_id("TEXPRAT") and name = "MAINTRATINI_R")
    PRINT '<<< MAINTRATINI_R Column added successfully >>>'
go

ALTER TABLE BTRAV..TEXPRAT ADD UWY_NF UUWY_NF DEFAULT 8888 NOT NULL
if exists (select 1 from syscolumns where id = object_id("TEXPRAT") and name = "UWY_NF")
    PRINT '<<< UWY_NF Column added successfully >>>'
go
