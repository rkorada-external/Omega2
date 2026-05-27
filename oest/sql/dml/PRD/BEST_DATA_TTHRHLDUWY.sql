use BEST
go

truncate table TTHRHLDUWY
go 
create table #TLOBH (
        LOB_CF      ULOB_CF NOT NULL,
        LOB_GL      UL64    NULL,
        LOB_GS      UL16    NOT NULL,
        SSD_CF USSD_CF NOT NULL,
        LOB_HL UL64    NULL,
        LOB_HS UL16    NOT NULL
)
insert into #TLOBH
    SELECT T.LOB_CF,
       	T.LOB_GL,
       	T.LOB_GS,
       	TH.SSD_CF,
        TH.LOB_HL,
       	TH.LOB_HS
	FROM   BREF..TLOB T, BREF..TLOBH TH
    WHERE T.LOB_CF = TH.LOB_CF
 
  create table #TNAT (
        NAT_CF char(10)
  )  
  insert into #TNAT VALUES ("P") -- PROP  
  insert into #TNAT VALUES ("N")  --NON PROP   

insert into TTHRHLDUWY
SELECT ES.SSD_CF, ES.ESB_CF, L.LOB_CF, NAT_CF, 2003, getdate(), 'dbo', getdate(), 'dbo'
FROM BREF..TESB ES, #TLOBH L , #TNAT
WHERE ES.SSD_CF = L.SSD_CF
AND (L.LOB_CF <> "30" and L.LOB_CF <> "31")
AND LIFE_CF = 2
ORDER BY ssd_cf, esb_cf,lob_cf
go
