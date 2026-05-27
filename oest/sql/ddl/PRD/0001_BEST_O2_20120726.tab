USE BEST
go

/*
 * Migration script for BEST..TCTRFIC: add ESB_CF in the primary key
 */

-- Add ESB_CF column (nullable for the moment)
ALTER TABLE dbo.TCTRFIC ADD ESB_CF UESB_CF NULL
if @@error!=0 select syb_quit()
go


-- Migration here

/* First step: complete contract numbers */
UPDATE BEST..TCTRFIC
   SET t1.CTR_NF = t2.CTR_NF
  FROM BEST..TCTRFIC t1,
       BTRT..TCONTR t2
 WHERE substring (convert(char(3), 100 + t1.SSD_CF), 2, 2) + t1.CTR_NF = t2.CTR_NF

 /* Second step: fill ledger code */
UPDATE BEST..TCTRFIC
   SET t1.ESB_CF = t2.ACCESB_CF
  FROM BEST..TCTRFIC t1,
       BTRT..TCONTR t2
 WHERE t1.CTR_NF = t2.CTR_NF
   AND t1.SSD_CF = t2.SSD_CF
   AND t2.LSTUWY_B = 1
go


-- ESB_CF becomes mandatory
ALTER TABLE dbo.TCTRFIC MODIFY ESB_CF NOT NULL
if @@error!=0 select syb_quit()
go


-- Drop primary key index
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TCTRFIC') AND name='ICTRFIC_00')
BEGIN
	DROP INDEX TCTRFIC.ICTRFIC_00
	if @@error!=0 select syb_quit()
	IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TCTRFIC') AND name='ICTRFIC_00')
		PRINT '<<< FAILED DROPPING INDEX dbo.TCTRFIC.ICTRFIC_00 >>>'
END
go


-- Recreate primary key index
CREATE UNIQUE CLUSTERED INDEX ICTRFIC_00
    ON dbo.TCTRFIC(SSD_CF,UWGRP_CF,PCPRSKTRY_CF,LIFTRTTYP_CF,CED_NF,ESB_CF)
go
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.TCTRFIC') AND name='ICTRFIC_00')
    PRINT '<<< CREATED INDEX dbo.ICTRFIC_00 >>>'
ELSE
    PRINT '<<< FAILED CREATING INDEX dbo.ICTRFIC_00 >>>'
go
