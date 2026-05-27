use BEST
go
PRINT '<<< Update Table BEST..TULAERAT >>>'

DROP INDEX TULAERAT.IULAERAT_00
if exists (SELECT * FROM sysindexes WHERE id=OBJECT_ID('TULAERAT') AND name='IULAERAT_00')
    PRINT '<<< FAILED DROPPING INDEX TULAERAT.IULAERAT_00 >>>'
else
    PRINT '<<< DROPPED INDEX TULAERAT.IULAERAT_00 >>>'
go


ALTER TABLE BEST..TULAERAT ADD CTRNAT_CT char(1) DEFAULT 'A' NOT NULL
if exists (select 1 from syscolumns where id = object_id("TULAERAT") and name = "CTRNAT_CT")
    PRINT '<<< CTRNAT_CT Column added successfully >>>'
go

ALTER TABLE BEST..TULAERAT ADD UWY_NF UUWY_NF DEFAULT 8888 NOT NULL
if exists (select 1 from syscolumns where id = object_id("TULAERAT") and name = "UWY_NF")
    PRINT '<<< UWY_NF Column added successfully >>>'
go

ALTER TABLE BEST..TULAERAT ADD LOBN2_NF int DEFAULT 9999 NOT NULL
if exists (select 1 from syscolumns where id = object_id("TULAERAT") and name = "LOBN2_NF")
    PRINT '<<< LOBN2_NF Column added successfully >>>'
go

CREATE UNIQUE INDEX IULAERAT_00 ON BEST..TULAERAT (SSD_CF, ESB_CF, PER_CF, CLOSING_D, CTRNAT_CT, UWY_NF, LOBN2_NF)

if exists (SELECT * FROM sysindexes WHERE id=OBJECT_ID('TULAERAT') AND name='IULAERAT_00')
    PRINT '<<< CREATED INDEX TULAERAT.IULAERAT_00 >>>'
else
    PRINT '<<< FAILED CREATING INDEX TULAERAT.IULAERAT_00 >>>'

go



use BTRAV
go
PRINT '<<< Update Table BTRAV..EST_ESID0851_ULAERAT >>>'

ALTER TABLE BTRAV..EST_ESID0851_ULAERAT ADD CTRNAT_CT char(1) DEFAULT 'A' NOT NULL
if exists (select 1 from syscolumns where id = object_id("EST_ESID0851_ULAERAT") and name = "CTRNAT_CT")
    PRINT '<<< CTRNAT_CT Column added successfully >>>'
go

ALTER TABLE BTRAV..EST_ESID0851_ULAERAT ADD UWY_NF UUWY_NF DEFAULT 8888 NOT NULL
if exists (select 1 from syscolumns where id = object_id("EST_ESID0851_ULAERAT") and name = "UWY_NF")
    PRINT '<<< UWY_NF Column added successfully >>>'
go

ALTER TABLE BTRAV..EST_ESID0851_ULAERAT ADD LOBN2_NF int DEFAULT 9999 NOT NULL
if exists (select 1 from syscolumns where id = object_id("EST_ESID0851_ULAERAT") and name = "LOBN2_NF")
    PRINT '<<< LOBN2_NF Column added successfully >>>'
go
