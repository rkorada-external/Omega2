use BEST
go
if object_id('dbo.PsFetchTRETIFRS_GRN') is not null
begin
  drop PROC dbo.PsFetchTRETIFRS_GRN
  print '<<< DROPPED PROC dbo.PsFetchTRETIFRS_GRN >>>'
end
go

create procedure dbo.PsFetchTRETIFRS_GRN
(
@p_user_site varchar(5)
)
with execute as caller as 


/**************************************************************************************************
Programme                : PsFetchTRETIFRS_GRN
Fichier script associé   : BEST_PsFetchTRETIFRS_GRN.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : JYP - PERSEE 
Date de creation         : 24/01/2022
Description du programme : Extraction from TRETIFRS table for Granularity process
                      
_____________________________________________________
[001] 24/01/2022 JYP  :SPIRA 101782 : création
[002] 08/06/2022 JYP  :SPIRA 104771 : IFRS17 Product defaulting
************************************************************************************************/


SELECT  t.RETCTR_NF , 0 AS END_NT , C.RETSEC_NF  , t.RTY_NF, 1 AS UW_NT , 
		t.GRPIFRSSEG_CT,
		t.GRPINIPRO_CF ,
		t.GRPIFRSTRA_CT,
		t.PARIFRSSEG_CT, 
		t.PARINIPRO_CF , 
		t.PARIFRSTRA_CT, 
		t.LOCIFRSSEG_CT, 
		t.LOCINIPRO_CF , 
		t.LOCIFRSTRA_CT, 
		GRPINISTS_CT ,
		PARINISTS_CT ,
		LOCINISTS_CT,
		@p_user_site,
		'R' ,
		f.LIFE_CF,e.PARM1,e.PARM2
FROM bret..TRETIFRS t ,  BREF..TBATCHSSD b , BRET..TRETSEC C , BRET..TRETCTR d ,BEST..TI17CLOPER e, BREF..TESB f
WHERE b.BATCHUSER_CF = @p_user_site
AND b.SSD_CF =  C.SSD_CF 
AND t.RETCTR_NF = C.RETCTR_NF  AND   t.RTY_NF = C.RTY_NF
AND t.RETCTR_NF = d.RETCTR_NF AND t.RTY_NF = d.RTY_NF AND C.SSD_CF = d.SSD_CF
AND d.SSD_CF *= e.SSD_CF AND d.ESB_CF *= e.ESB_CF
AND d.SSD_CF *= f.SSD_CF AND d.ESB_CF *= f.ESB_CF
AND  not exists 
(
SELECT 1 
from  btrt..TSECIFRS s
where t.RETCTR_NF = s.CTR_NF and t.RTY_NF = s.UWY_NF
)
AND  not exists 
(
select 1
from  bfac..TSECIFRS s
where t.RETCTR_NF = s.CTR_NF and t.RTY_NF = s.UWY_NF
)	    
GO

if object_id('dbo.PsFetchTRETIFRS_GRN') is not null
  print '<<< CREATED PROC dbo.PsFetchTRETIFRS_GRN >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFetchTRETIFRS_GRN >>>'
go
grant execute on dbo.PsFetchTRETIFRS_GRN TO GOMEGA
go
grant execute on dbo.PsFetchTRETIFRS_GRN TO GDBBATCH
go


	 