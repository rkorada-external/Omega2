Use BEST
Go

if NOT exists(select 1 from syscolumns where Id = Object_ID('dbo.TPATTERNSII') and Name = 'RATEINDEX_CT')
begin
	ALTER TABLE BEST..TPATTERNSII
	ADD RATEINDEX_CT  varchar(32) NULL
	

	PRINT '<<< RATEINDEX_CT Column added successfully >>>'
end 
else
begin
	PRINT '<<< RATEINDEX_CT Column already exists >>>'
end

go

if NOT exists(select 1 from syscolumns where Id = Object_ID('dbo.TPATTERNSII') and Name = 'ESB_CF')
begin
	ALTER TABLE BEST..TPATTERNSII
	ADD ESB_CF       UESB_CF    NULL
	

	PRINT '<<< ESB_CF Column added successfully >>>'
end 
else
begin
	PRINT '<<< ESB_CF Column already exists >>>'
end

go



IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TPATTERNSII') AND name='IPATTERNSII_00') 
		AND exists(select 1 from syscolumns where Id = Object_ID('dbo.TPATTERNSII') and Name = 'ESB_CF')
		AND exists(select 1 from syscolumns where Id = Object_ID('dbo.TPATTERNSII') and Name = 'RATEINDEX_CT')

BEGIN
    DROP INDEX TPATTERNSII.IPATTERNSII_00
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TPATTERNSII') AND name='IPATTERNSII_00')
        PRINT '<<< FAILED DROPPING INDEX TPATTERNSII.IPATTERNSII_00 >>>'
    ELSE
        PRINT '<<< DROPPED INDEX TPATTERNSII.IPATTERNSII_00 >>>'
	
	
	
	CREATE UNIQUE CLUSTERED INDEX IPATTERNSII_00
    ON dbo.TPATTERNSII(PATCAT_CT,PATTYP_CT,PATTERN_ID,SSD_CF,SEG_NF,UWY_NF,CUR_CF,LOB_CF,RATING_CF,NORME_CF,SEGNAT_CT,BALSHEY_NF, RATEINDEX_CT, ESB_CF)
	LOCAL INDEX IPATTERNSII_00_293573053
	
	IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TPATTERNSII') AND name='IPATTERNSII_00')
		PRINT '<<< CREATED INDEX dbo.TPATTERNSII.IPATTERNSII_00 >>>'
	ELSE
		PRINT '<<< FAILED CREATING INDEX dbo.TPATTERNSII.IPATTERNSII_00 >>>'	
        
        
END


go

