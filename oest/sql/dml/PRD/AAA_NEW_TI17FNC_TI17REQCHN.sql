
USE BEST
go

IF (OBJECT_ID('FK_REQST_REQST_FNC') IS NOT NULL)
    ALTER TABLE dbo.TI17REQFNC
        DROP CONSTRAINT FK_REQST_REQST_FNC
go

IF (OBJECT_ID('PK_TI17REQFNC') IS NOT NULL)
	ALTER TABLE dbo.TI17REQFNC
		DROP CONSTRAINT PK_TI17REQFNC
IF (OBJECT_ID('FK_FNCT_REQST_FNC') IS NOT NULL)
	ALTER TABLE dbo.TI17REQFNC
		DROP CONSTRAINT FK_FNCT_REQST_FNC
go
IF OBJECT_ID('dbo.TI17REQFNC') IS NOT NULL
BEGIN
    DROP TABLE dbo.TI17REQFNC
    IF OBJECT_ID('dbo.TI17REQFNC') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.TI17REQFNC >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.TI17REQFNC >>>'
END
go
CREATE TABLE dbo.TI17REQFNC
(
    REQCOD_CT      varchar(32) NOT NULL,
    IDF_CT         varchar(30) NOT NULL,
    REQST_CHAIN_LL char(10)    NULL,
    CONSTRAINT PK_TI17REQFNC
    PRIMARY KEY NONCLUSTERED (REQCOD_CT,IDF_CT)
)
LOCK DATAROWS
go
IF OBJECT_ID('dbo.TI17REQFNC') IS NOT NULL
    PRINT '<<< CREATED TABLE dbo.TI17REQFNC >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dbo.TI17REQFNC >>>'
go


ALTER TABLE dbo.TI17REQFNC
    ADD CONSTRAINT FK_FNCT_REQST_FNC
    FOREIGN KEY (IDF_CT)
    REFERENCES dbo.TI17FNC (IDF_CT)
go

ALTER TABLE dbo.TI17REQFNC
    ADD CONSTRAINT FK_REQST_REQST_FNC
    FOREIGN KEY (REQCOD_CT)
    REFERENCES dbo.TI17REQ (REQCOD_CT)
go

GRANT REFERENCES ON dbo.TI17REQFNC TO GOMEGA
go
GRANT REFERENCES ON dbo.TI17REQFNC TO GDBBATCH
go
GRANT SELECT ON dbo.TI17REQFNC TO GCONSULT
go
GRANT SELECT ON dbo.TI17REQFNC TO GOMEGA
go
GRANT SELECT ON dbo.TI17REQFNC TO GDBBATCH
go
GRANT INSERT ON dbo.TI17REQFNC TO GOMEGA
go
GRANT INSERT ON dbo.TI17REQFNC TO GDBBATCH
go
GRANT DELETE ON dbo.TI17REQFNC TO GOMEGA
go
GRANT DELETE ON dbo.TI17REQFNC TO GDBBATCH
go
GRANT UPDATE ON dbo.TI17REQFNC TO GOMEGA
go
GRANT UPDATE ON dbo.TI17REQFNC TO GDBBATCH
go





------------------------  TI17FNC -----------------

IF EXISTS (select o.name as TableName, c.name as ColumnName 
                from sysobjects o, syscolumns c 
                where o.id=c.id and o.type='U' 
                and o.name = "TI17FNC"
                and c.name = "CHAIN_CT")
        begin
            execute ("ALTER TABLE TI17FNC     DROP CHAIN_CT     ")
        end
go

IF EXISTS (select o.name as TableName, c.name as ColumnName 
                    from sysobjects o, syscolumns c 
                    where o.id=c.id and o.type='U' 
                    and o.name = "TI17FNC"
                    and c.name = "SEVERITY_CT")
        execute ("ALTER TABLE TI17FNC     DROP SEVERITY_CT ")
go
 
    
ALTER TABLE TI17FNC
    ADD CHAIN_CT             varchar(30)    default '' not null        
go   

ALTER TABLE TI17FNC
    ADD SEVERITY_CT             tinyint   default 0 not null        
go


------------------------  TI17TRAPERMFIL -----------------
alter table TI17TRAPERMFIL
modify PATHPATTRN_LL varchar(512) null


