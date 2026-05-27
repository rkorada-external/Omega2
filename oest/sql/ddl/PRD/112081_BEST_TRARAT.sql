use BEST
go
PRINT '<<< Update Table BEST..TRARAT >>>'

-- RA prudence LIC ratio
ALTER TABLE BEST..TRARAT ADD RALIC_R USHA_R NULL
if exists (select 1 from syscolumns where id = object_id("TRARAT") and name = "RALIC_R")
    PRINT '<<< RALIC_R Column added successfully >>>'
go

-- RA prudence LRC ratio
ALTER TABLE BEST..TRARAT ADD RALRC_R USHA_R NULL
if exists (select 1 from syscolumns where id = object_id("TRARAT") and name = "RALRC_R")
    PRINT '<<< RALRC_R Column added successfully >>>'
go