use BSTA
go
if object_id('dbo.PsSEGEST_01') is not null
begin
  drop PROC dbo.PsSEGEST_01
  print '<<< DROPPED PROC dbo.PsSEGEST_01 >>>'
end
go
create procedure PsSEGEST_01
  (
  @p_ssd_cf       USSD_CF,
  @p_vrs_nf       numeric( 10, 0 ),
  @p_segtyp_ct    USEGTYP_CT,
  @p_cre_d        UUPD_D
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME27 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    - Extraction de la table BSAR..TSEGEST, avec mise au format de BEST..TSEGEST
Parametres:
    - @p_vrs_nf : version
    - @p_segtyp_ct : type de la segmentation
    - @p_cre_d : date du traitement
    - @p_ssd_cf : filiale
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  Florent   14/02/2012 :spot:23390 SOLVENCY II
2  Florent   01/06/2015 :spot:28694 Segmentation VIE
*****************************************************/
declare
  @erreur           int
 ,@segtyp_SII USEGTYP_CT     -- modif 1

-- on n'aura pas de type S ici, mais pour faire TSEGEST il faut prendre les type S quand on traite le type A
if @p_segtyp_ct='A'
  select @segtyp_SII='S'
else
  select @segtyp_SII=@p_segtyp_ct

select @erreur=0

-- selection d'enregistrements de BSAR..TSEGEST au format de BEST..TSEGEST
select
  @p_vrs_nf
 ,SSD_CF
 ,SEGTYP_CT
 ,SEG_NF
 ,UWY_NF
 ,@p_cre_d
 ,CUR_CF
 ,PRMAMT_M
 ,CLMAMT_M
 ,LOSRAT_R
 ,AMORAT_CT
 ,ACY_NF
 from BSAR..TSEGEST
  where SSD_CF=@p_ssd_cf
    and SEGTYP_CT in(@segtyp_SII,@p_segtyp_ct)
select @erreur=@@error
if @erreur!=0 goto fin

fin:
if @erreur!=0
begin
  raiserror 20005 "FAILED: PsSEGEST_01"
  return @erreur
end
return 0
go
if object_id('dbo.PsSEGEST_01') is not null
  print '<<< CREATED PROC dbo.PsSEGEST_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsSEGEST_01 >>>'
go
grant execute on dbo.PsSEGEST_01 TO GOMEGA, GDBBATCH
go
