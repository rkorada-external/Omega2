use BEST
go
if object_id('dbo.PsFetchCTRI17PRD_RETBR') is not null
begin
  drop PROC dbo.PsFetchCTRI17PRD_RETBR
  print '<<< DROPPED PROC dbo.PsFetchCTRI17PRD_RETBR >>>'
end
go

create procedure dbo.PsFetchCTRI17PRD_RETBR
(
   @p_norm_cf	 varchar(5)
)
with execute as caller as 


/**************************************************************************************************
Programme                : PsFetchCTRI17PRD_RETBR
Fichier script associé   : BEST_PsFetchCTRI17PRD_RETBR.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : JYP - PERSEE 
Date de creation         : 19/07/2021
Description du programme : Extraction FCTRI17PRD from TRETIFRS table, for BR = retro Booked and Run-off
                      
_____________________________________________________
[001] 19/07/2021 JYP  :SPIRA 94896 : création
[002] 23/07/2021 JYP  :SPIRA 94896 : add run-off without product code, exclude empty keys
[003] 26/07/2021 JYP  :SPIRA 94896 : force UW_NT = 1
[004] 27/07/2021 JYP  :SPIRA 94896 : remove tretctr
[005] 28/10/2021 JYP  :SPIRA 99947 : bugfix null fields
[006] 07/01/2022 MZM  :SPIRA 99947 : bugfix duplicate fields UA2
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
AND
(   exists --- check prod code
    (   
    select 1 from best..TI17PRODUCT p 
    where ( @p_norm_cf = 'I17G' and isnull(p.GRPIFRSSEG_CT,'null') = isnull(t.GRPIFRSSEG_CT,'null') and isnull(p.GRPINIPRO_CF,'null') = isnull(t.GRPINIPRO_CF,'null') and isnull(p.GRPIFRSTRA_CT,'null') = isnull(t.GRPIFRSTRA_CT,'null') and t.GRPINISTS_CT = 2 and t.GRPFSTCLO_D is not null )
       or ( @p_norm_cf = 'I17P' and isnull(p.PARIFRSSEG_CT,'null') = isnull(t.PARIFRSSEG_CT,'null') and isnull(p.PARINIPRO_CF,'null') = isnull(t.PARINIPRO_CF,'null') and isnull(p.PARIFRSTRA_CT,'null') = isnull(t.PARIFRSTRA_CT,'null') and t.PARINISTS_CT = 2 and t.PARFSTCLO_D is not null )
       or ( @p_norm_cf = 'I17L' and isnull(p.LOCIFRSSEG_CT,'null') = isnull(t.LOCIFRSSEG_CT,'null') and isnull(p.LOCINIPRO_CF,'null') = isnull(t.LOCINIPRO_CF,'null') and isnull(p.LOCIFRSTRA_CT,'null') = isnull(t.LOCIFRSTRA_CT,'null') and t.LOCINISTS_CT = 2 and t.LCLFSTCLO_D is not null )
    )
	--- run-off
    or ( @p_norm_cf = 'I17G' and GRPINISTS_CT = 9 )
    or ( @p_norm_cf = 'I17P' and PARINISTS_CT = 9 )
    or ( @p_norm_cf = 'I17L' and LOCINISTS_CT = 9 )	
)
--- exclude empty keys 
AND not 
(
       ( @p_norm_cf = 'I17G' and t.GRPIFRSSEG_CT is null and t.GRPINIPRO_CF is null and t.GRPIFRSTRA_CT is null )
    or ( @p_norm_cf = 'I17P' and t.PARIFRSSEG_CT is null and t.PARINIPRO_CF is null and t.PARIFRSTRA_CT is null )
    or ( @p_norm_cf = 'I17L' and t.LOCIFRSSEG_CT is null and t.LOCINIPRO_CF is null and t.LOCIFRSTRA_CT is null )	
)
-- [006]
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
GO

if object_id('dbo.PsFetchCTRI17PRD_RETBR') is not null
  print '<<< CREATED PROC dbo.PsFetchCTRI17PRD_RETBR >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFetchCTRI17PRD_RETBR >>>'
go
grant execute on dbo.PsFetchCTRI17PRD_RETBR TO GOMEGA
go
grant execute on dbo.PsFetchCTRI17PRD_RETBR TO GDBBATCH
go


	 