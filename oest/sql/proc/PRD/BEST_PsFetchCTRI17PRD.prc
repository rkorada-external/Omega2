use BEST
go
if object_id('dbo.PsFetchCTRI17PRD') is not null
begin
  drop PROC dbo.PsFetchCTRI17PRD
  print '<<< DROPPED PROC dbo.PsFetchCTRI17PRD >>>'
end
go

create procedure dbo.PsFetchCTRI17PRD
(
   @p_norm_cf	 varchar(5)
)
with execute as caller as 


/**************************************************************************************************
Programme                : PsFetchCTRI17PRD
Fichier script associé   : BEST_PsFetchCTRI17PRD.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : JYP - PERSEE 
Date de creation         : 02/09/2020
Description du programme : Extraction FCTRI17PRD from TSECIFRS table
                      
_____________________________________________________
[001] 02/09/2020 JYP  :SPIRA 83614: création
[002] 04/09/2020 JYP  :SPIRA 83614: add filter on closing date
[003] 08/02/2021 JYP  :SPIRA 91991: add filter for Local/Parent
[004] 08/02/2021 JYP  :SPIRA 97042: add status 9 run off
[005] 22/06/2021 JYP  :SPIRA 97118: add transition field IFRSTRA_CT
[006] 23/07/2021 JYP  :SPIRA 97118: exclude empty keys
************************************************************************************************/



SELECT  
 t.ctr_nf , t.end_nt, t.sec_nf  , t.uwy_nf, t.uw_nt , 
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
FROM btrt..TSECIFRS t
WHERE
(      ( @p_norm_cf = 'I17G' and GRPINISTS_CT in (2,9) and GRPFIRCLO_D is not null)
    or ( @p_norm_cf = 'I17P' and PARINISTS_CT in (2,9) and PARFIRCLO_D is not null)
    or ( @p_norm_cf = 'I17L' and LOCINISTS_CT in (2,9) and LOCFIRCLO_D is not null)
)	
--- exclude empty keys 
AND not 
(
       ( @p_norm_cf = 'I17G' and t.GRPIFRSSEG_CT is null and t.GRPINIPRO_CF is null and t.GRPIFRSTRA_CT is null )
    or ( @p_norm_cf = 'I17P' and t.PARIFRSSEG_CT is null and t.PARINIPRO_CF is null and t.PARIFRSTRA_CT is null )
    or ( @p_norm_cf = 'I17L' and t.LOCIFRSSEG_CT is null and t.LOCINIPRO_CF is null and t.LOCIFRSTRA_CT is null )	
)	
UNION
SELECT  
 f.ctr_nf , f.end_nt, f.sec_nf  , f.uwy_nf, f.uw_nt , 
 case when @p_norm_cf = 'I17G' then f.GRPIFRSSEG_CT
      when @p_norm_cf = 'I17P' then f.PARIFRSSEG_CT 
      when @p_norm_cf = 'I17L' then f.LOCIFRSSEG_CT 
      else null   
 end,
 case when @p_norm_cf = 'I17G' then f.GRPINIPRO_CF
      when @p_norm_cf = 'I17P' then f.PARINIPRO_CF 
      when @p_norm_cf = 'I17L' then f.LOCINIPRO_CF 
      else null   
 end,
 case when @p_norm_cf = 'I17G' then f.GRPIFRSTRA_CT
      when @p_norm_cf = 'I17P' then f.PARIFRSTRA_CT 
      when @p_norm_cf = 'I17L' then f.LOCIFRSTRA_CT 
      else null   
 end 
FROM bfac..TSECIFRS f
WHERE
(      ( @p_norm_cf = 'I17G' and GRPINISTS_CT in (2,9) and GRPFIRCLO_D is not null)
    or ( @p_norm_cf = 'I17P' and PARINISTS_CT in (2,9) and PARFIRCLO_D is not null)
    or ( @p_norm_cf = 'I17L' and LOCINISTS_CT in (2,9) and LOCFIRCLO_D is not null)
)
--- exclude empty keys 
AND not 
(
       ( @p_norm_cf = 'I17G' and f.GRPIFRSSEG_CT is null and f.GRPINIPRO_CF is null and f.GRPIFRSTRA_CT is null )
    or ( @p_norm_cf = 'I17P' and f.PARIFRSSEG_CT is null and f.PARINIPRO_CF is null and f.PARIFRSTRA_CT is null )
    or ( @p_norm_cf = 'I17L' and f.LOCIFRSSEG_CT is null and f.LOCINIPRO_CF is null and f.LOCIFRSTRA_CT is null )	
)

GO

if object_id('dbo.PsFetchCTRI17PRD') is not null
  print '<<< CREATED PROC dbo.PsFetchCTRI17PRD >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFetchCTRI17PRD >>>'
go
grant execute on dbo.PsFetchCTRI17PRD TO GOMEGA
go
grant execute on dbo.PsFetchCTRI17PRD TO GDBBATCH
go



	 