use BEST
go
if object_id('dbo.PsFetchCTRI17PRD_RETI') is not null
begin
  drop PROC dbo.PsFetchCTRI17PRD_RETI
  print '<<< DROPPED PROC dbo.PsFetchCTRI17PRD_RETI >>>'
end
go

create procedure dbo.PsFetchCTRI17PRD_RETI
(
   @p_norm_cf	 varchar(5)
)
with execute as caller as 


/**************************************************************************************************
Programme                : PsFetchCTRI17PRD_RETI
Fichier script associé   : BEST_PsFetchCTRI17PRD_RETI.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : JYP - PERSEE 
Date de creation         : 19/07/2021
Description du programme : Extraction FCTRI17PRD from TRETIFRS table, for retro INI
                      
_____________________________________________________
[001] 21/07/2021 JYP  :SPIRA 94896 : création
[002] 23/07/2021 JYP  :SPIRA 94896 : exclude empty keys
[003] 26/07/2021 JYP  :SPIRA 94896 : force UW_NT = 1
[004] 27/07/2021 JYP  :SPIRA 94896 : remove tretctr
[005] 22/11/2021 JYP  :SPIRA 98979 : add retro with status 0
************************************************************************************************/

SELECT  t.RETCTR_NF , 0 AS END_NT , C.RETSEC_NF  , t.RTY_NF, 1 AS UW_NT , 
 case when @p_norm_cf = 'I17G' then t.GRPIFRSSEG_CT
      when @p_norm_cf = 'I17P' then t.PARIFRSSEG_CT 
      when @p_norm_cf = 'I17L' then t.LOCIFRSSEG_CT 
      else null   
 end,
 case when @p_norm_cf = 'I17G' then t.GRPINIPRO_CF
      when @p_norm_cf = 'I17P' then t.PARINIPRO_CF 
      when @p_norm_cf = 'I17L' then t.LOCINIPRO_CF 
      else null   
 end,
 case when @p_norm_cf = 'I17G' then t.GRPIFRSTRA_CT
      when @p_norm_cf = 'I17P' then t.PARIFRSTRA_CT 
      when @p_norm_cf = 'I17L' then t.LOCIFRSTRA_CT 
      else null   
 end
FROM bret..TRETIFRS t ,  BREF..TBATCHSSD b , BRET..TRETSEC C 
WHERE b.BATCHUSER_CF = suser_name() 
AND b.SSD_CF =  C.SSD_CF 
AND t.RETCTR_NF = C.RETCTR_NF  AND   t.RTY_NF = C.RTY_NF
AND (
       ( @p_norm_cf = 'I17G' and (GRPINISTS_CT in ( 1,0 ) or GRPINISTS_CT is null) )
    or ( @p_norm_cf = 'I17P' and (PARINISTS_CT in ( 1,0 ) or PARINISTS_CT is null) )
    or ( @p_norm_cf = 'I17L' and (LOCINISTS_CT in ( 1,0 ) or LOCINISTS_CT is null) )
	)
--- exclude assumed csuoe
AND  not exists 
(
SELECT 1 
from  btrt..TSECIFRS s
where (s.GRPINISTS_CT in ( 1,2,9) or s.GRPINISTS_CT is null ) 
AND t.RETCTR_NF = s.CTR_NF and t.RTY_NF = s.UWY_NF
)
AND  not exists 
(
select 1
from  bfac..TSECIFRS s
where (s.GRPINISTS_CT in (1,2,9) or s.GRPINISTS_CT is null ) 
AND t.RETCTR_NF = s.CTR_NF and t.RTY_NF = s.UWY_NF
)	
--- exclude empty keys 
AND not 
(
       ( @p_norm_cf = 'I17G' and t.GRPIFRSSEG_CT is null and t.GRPINIPRO_CF is null and t.GRPIFRSTRA_CT is null )
    or ( @p_norm_cf = 'I17P' and t.PARIFRSSEG_CT is null and t.PARINIPRO_CF is null and t.PARIFRSTRA_CT is null )
    or ( @p_norm_cf = 'I17L' and t.LOCIFRSSEG_CT is null and t.LOCINIPRO_CF is null and t.LOCIFRSTRA_CT is null )	
)	
GO

if object_id('dbo.PsFetchCTRI17PRD_RETI') is not null
  print '<<< CREATED PROC dbo.PsFetchCTRI17PRD_RETI >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFetchCTRI17PRD_RETI >>>'
go
grant execute on dbo.PsFetchCTRI17PRD_RETI TO GOMEGA
go
grant execute on dbo.PsFetchCTRI17PRD_RETI TO GDBBATCH
go


	 