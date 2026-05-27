use BSTA
go
if object_id('dbo.PsSEGMENT_02') is not null
begin
  drop PROC dbo.PsSEGMENT_02
  print '<<< DROPPED PROC dbo.PsSEGMENT_02 >>>'
end
go
create table #tsegment
  (
  VRS_NF    numeric(10,0) NOT null
 ,SSD_CF    USSD_CF       NOT null
 ,SEGTYP_CT USEGTYP_CT    DEFAULT ''
 ,SEG_NF    USEG_NF       DEFAULT ''
 ,SEG_LL    UL64          null
 ,CUR_CF    UCUR_CF       DEFAULT ''
 ,SEGNAT_CT char(1)       DEFAULT ''
 ,CTRRET_B  bit           DEFAULT 0
 ,ANO_B     bit           DEFAULT 0
 ,RETRO_NP  bit           DEFAULT 0
  )
go
create procedure PsSEGMENT_02
  (
  @p_segtyp_ct USEGTYP_CT
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME27 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    - Obtenir au final une table au format de BEST..TSEGMENT
    - Extraction de la table BSAR..TCTRGRO et BSAR..TSEGEST,
    avec mise au format de BEST..TSEGMENT
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  Florent   14/02/2012 :spot:23390 SOLVENCY II
2  Florent   01/06/2015 :spot:28694 Segmentation VIE
*****************************************************/
declare
  @erreur     int
 ,@segtyp_SII USEGTYP_CT     -- modif 1

-- on n'aura pas de type S ici, mais pour faire TSEGMENT il faut prendre les type S quand on traite le type A
if @p_segtyp_ct='A'
  select @segtyp_SII='S'
else
  select @segtyp_SII=@p_segtyp_ct

select @erreur=0

update #tsegment
 set SEG_LL=e.SEG_LL,
     CUR_CF=e.CUR_CF,
     SEGNAT_CT=e.SEGNAT_CT,
     CTRRET_B=e.CTRRET_B
  from #tsegment s, BSAR..TSEGEST e
   where e.SEG_NF=s.SEG_NF
     and e.SSD_CF=s.SSD_CF
     and e.SEGTYP_CT in(@segtyp_SII,@p_segtyp_ct)
     and s.SEGTYP_CT=@p_segtyp_ct
     and e.UWY_NF*10000+e.ACY_NF=(select max(UWY_NF*10000+ACY_NF) from BSAR..TSEGEST x where x.SEG_NF=e.SEG_NF and x.SSD_CF=e.SSD_CF and x.SEGTYP_CT in(@segtyp_SII,@p_segtyp_ct))
select @erreur=@@error
if @erreur != 0 goto fin

-- select pour le BCP (en effet l'update n'est pas forcement valable
-- pour toutes les lignes
select VRS_NF,
       SSD_CF,
       SEGTYP_CT,
       SEG_NF,
       SEG_LL,
       CUR_CF,
       SEGNAT_CT,
       CTRRET_B,
       ANO_B,
       RETRO_NP -- modif 1
from #tsegment

select @erreur=@@error
if @erreur!=0
   goto fin

fin:
if @erreur!=0
begin
  raiserror 20005 "FAILED: PsSEGMENT_02"
  return @erreur
end
return 0
go
drop table #tsegment
go
if object_id('dbo.PsSEGMENT_02') is not null
  print '<<< CREATED PROC dbo.PsSEGMENT_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsSEGMENT_02 >>>'
go
grant execute on dbo.PsSEGMENT_02 TO GOMEGA
go
