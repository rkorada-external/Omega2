/*==============================================================*/
/* Table: ESFD8000_TSECIFRS                                     */
/*==============================================================*/

USE BTRAV
go
if exists (select 1 from syscolumns where id = object_id("ESFD8000_TSECIFRS") and name = "SIIFIRCLO_D")
	begin
			exec ("ALTER TABLE ESFD8000_TSECIFRS drop SIIFIRCLO_D")
	end
go
 
if exists (select 1 from syscolumns where id = object_id("ESFD8000_TSECIFRS") and name = "SIIINISTS_CT")
	begin
			exec ("ALTER TABLE ESFD8000_TSECIFRS drop SIIINISTS_CT")
	end
go
 
alter table BTRAV..ESFD8000_TSECIFRS
	-- Add
	add SIIFIRCLO_D Datetime null, 
		SIIINISTS_CT  tinyint  null
go
 
if exists (select 1 from syscolumns where id = object_id("BTRAV..ESFD8000_TSECIFRS") and name = "SIIFIRCLO_D")
	begin
			PRINT '<<< COLUMN SIIFIRCLO_D ADDED ON BTRAV..ESFD8000_TSECIFRS >>>'
	end
go
 
if exists (select 1 from syscolumns where id = object_id("ESFD8000_TSECIFRS") and name = "SIIINISTS_CT")
	begin
			PRINT '<<< COLUMN SIIINISTS_CT ADDED ON BTRAV..ESFD8000_TSECIFRS >>>'
	end
go


/*==============================================================*/
/* Table: ESFD8000_TRETIFRS                                     */
/*==============================================================*/


USE BTRAV
go
if exists (select 1 from syscolumns where id = object_id("ESFD8000_TRETIFRS") and name = "SIIFSTCLO_D")
	begin
			exec ("ALTER TABLE ESFD8000_TRETIFRS drop SIIFSTCLO_D")
	end
go
 
if exists (select 1 from syscolumns where id = object_id("ESFD8000_TRETIFRS") and name = "SIIINISTS_CT")
	begin
			exec ("ALTER TABLE ESFD8000_TRETIFRS drop SIIINISTS_CT")
	end
go
 
alter table BTRAV..ESFD8000_TRETIFRS
	-- Add
	add SIIFSTCLO_D Datetime null, 
		SIIINISTS_CT  tinyint  null
go
 
if exists (select 1 from syscolumns where id = object_id("BTRAV..ESFD8000_TRETIFRS") and name = "SIIFSTCLO_D")
	begin
			PRINT '<<< COLUMN SIIFSTCLO_D ADDED ON BTRAV..ESFD8000_TRETIFRS >>>'
	end
go
 
if exists (select 1 from syscolumns where id = object_id("ESFD8000_TRETIFRS") and name = "SIIINISTS_CT")
	begin
			PRINT '<<< COLUMN SIIINISTS_CT ADDED ON BTRAV..ESFD8000_TRETIFRS >>>'
	end
go