use best
go

if exists (select 1 from syscolumns where id = object_id("TI17CTRSML") and name = "SIIFIRCLO_D")
begin
        PRINT '<<< COLUMN SIIFIRCLO_D ALREADY EXISTS >>>'
end
else
begin
        exec ("ALTER TABLE TI17CTRSML ADD SIIFIRCLO_D  Datetime  NULL")
        PRINT '<<< COLUMN SIIFIRCLO_D ADDED ON BEST..TI17CTRSML >>>'
end
go

if exists (select 1 from syscolumns where id = object_id("TI17CTRSML") and name = "SIIINISTS_CT")
begin
        PRINT '<<< COLUMN SIIINISTS_CT ALREADY EXISTS >>>'
end
else
begin
        exec ("ALTER TABLE TI17CTRSML ADD SIIINISTS_CT  tinyint  NULL")
        PRINT '<<< COLUMN SIIINISTS_CT ADDED ON BEST..TI17CTRSML >>>'
end
go


use BTRAV
go

if exists (select 1 from syscolumns where id = object_id("ESFD8000_TRETIFRS") and name = "SIIFSTCLO_D")
begin
        PRINT '<<< COLUMN SIIFSTCLO_D ALREADY EXISTS >>>'
end
else
begin
        exec ("ALTER TABLE ESFD8000_TRETIFRS ADD SIIFSTCLO_D  DAtetime  NULL")
        PRINT '<<< COLUMN SIIFSTCLO_D ADDED ON BTRAV..ESFD8000_TRETIFRS >>>'
end
go

if exists (select 1 from syscolumns where id = object_id("ESFD8000_TRETIFRS") and name = "SIIINISTS_CT")
begin
        PRINT '<<< COLUMN SIIINISTS_CT ALREADY EXISTS >>>'
end
else
begin
        exec ("ALTER TABLE ESFD8000_TRETIFRS ADD SIIINISTS_CT  tinyint  NULL")
        PRINT '<<< COLUMN SIIINISTS_CT ADDED ON BTRAV..ESFD8000_TRETIFRS >>>'
end
go

use BTRAV
go

if exists (select 1 from syscolumns where id = object_id("ESFD8000_TSECIFRS") and name = "SIIFIRCLO_D")
begin
        PRINT '<<< COLUMN SIIFIRCLO_D ALREADY EXISTS >>>'
end
else
begin
        exec ("ALTER TABLE ESFD8000_TSECIFRS ADD SIIFIRCLO_D  DAtetime  NULL")
        PRINT '<<< COLUMN SIIFIRCLO_D ADDED ON BTRAV..ESFD8000_TRETIFRS >>>'
end
go

if exists (select 1 from syscolumns where id = object_id("ESFD8000_TSECIFRS") and name = "SIIINISTS_CT")
begin
        PRINT '<<< COLUMN SIIINISTS_CT ALREADY EXISTS >>>'
end
else
begin
        exec ("ALTER TABLE ESFD8000_TSECIFRS ADD SIIINISTS_CT  tinyint  NULL")
        PRINT '<<< COLUMN SIIINISTS_CT ADDED ON BTRAV..ESFD8000_TSECIFRS >>>'
end
go



