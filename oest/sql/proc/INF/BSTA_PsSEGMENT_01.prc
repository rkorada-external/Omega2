use BSTA
go
if object_id('dbo.PsSEGMENT_01') is not null
begin
  drop PROC dbo.PsSEGMENT_01
  print '<<< DROPPED PROC dbo.PsSEGMENT_01 >>>'
end
go
create procedure PsSEGMENT_01
  (
  @p_ssd_cf    USSD_CF
 ,@p_vrs_nf    numeric(10,0)
 ,@p_segtyp_ct USEGTYP_CT
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
Parametres:
    - @p_vrs_nf : version
    - @p_segtyp_ct : type de la segmentation
    - @p_ssd_cf : filiale
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 M. DJELLOULI 15/10/2004 Ajout des Segments Non Contenus dans TCTRGRO à partir de TSEGEST
2  Florent     14/02/2012 :spot:23390 SOLVENCY II
*****************************************************/
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

declare
  @erreur     int
 ,@segtyp_SII USEGTYP_CT     -- modif 1

-- on n'aura pas de type S ici, mais pour faire TSEGMENT il faut prendre les type S quand on traite le type A
if @p_segtyp_ct='A'
  select @segtyp_SII='S'
else
  select @segtyp_SII=@p_segtyp_ct

select @erreur = 0

-- selection d'enregistrements de BSTA..TSEGMENT au format de BEST..TSEGMENT

-- insert des Cles de bsar..tctrgro
insert into #tsegment (VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF)
select distinct @p_vrs_nf,SSD_CF,SEGTYP_CT,SEG_NF
 from BSAR..TCTRGRO
  where SSD_CF=@p_ssd_cf
    and SEGTYP_CT=@p_segtyp_ct
select @erreur=@@error
if @erreur!=0 goto fin

-- insert des Cles de BSAR..TSEGEST
insert into #tsegment (VRS_NF,SSD_CF,SEGTYP_CT,SEG_NF)
select distinct @p_vrs_nf,SSD_CF,@p_segtyp_ct,SEG_NF
 from BSAR..TSEGEST a
  where SSD_CF=@p_ssd_cf
    and SEGTYP_CT in(@p_segtyp_ct,@segtyp_SII) -- modif 1
    and not exists(select 1 from #tsegment b where a.SSD_CF=b.SSD_CF and @p_segtyp_ct=b.SEGTYP_CT and a.SEG_NF=b.SEG_NF) -- modif 1
select @erreur=@@error
if @erreur!=0 goto fin

-- Appel de la proc fille avec select final
execute @erreur=PsSEGMENT_02 @p_segtyp_ct with recompile
if @erreur!=0 goto fin

fin:
if @erreur!=0
begin
  raiserror 20005 "FAILED: PsSEGMENT_01"
  drop table #tsegment
  return @erreur
end

drop table #tsegment
return 0
go
if object_id('dbo.PsSEGMENT_01') is not null
  print '<<< CREATED PROC dbo.PsSEGMENT_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsSEGMENT_01 >>>'
go
grant execute on dbo.PsSEGMENT_01 TO GOMEGA
go
