use BEST
go
if object_id('dbo.PsSEGEST_02') is not null
begin
  drop PROC dbo.PsSEGEST_02
  print '<<< DROPPED PROC dbo.PsSEGEST_02 >>>'
end
go
create procedure PsSEGEST_02
  (
  @p_ssd_cf int,
  @p_vrs_nf numeric(10,0),
  @p_segtyp_ct char(1)
  )
as
/***************************************************
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI -
Date de creation: 24/08/2004
Description du programme: Extraction de la Table pour chargement via ESED0421.cmd Asynchrone
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  Florent   14/02/2012 :spot:23390 SOLVENCY II
2  Florent   01/06/2015 :spot:28694 Segmentation VIE
*****************************************************/
declare
  @erreur           int
 ,@AnneeExist       int
 ,@p_blcshtyea_nf   smallint
 ,@p_blcshtyea_nfA0 smallint
 ,@segtyp_SII USEGTYP_CT     -- modif 1

-- on n'aura pas de type S ici, mais pour faire TSEGEST il faut prendre les type S quand on traite le type A
if @p_segtyp_ct='A'
  select @segtyp_SII='S'
else
  select @segtyp_SII=@p_segtyp_ct


create TABLE #TPTSEGEST
  (
  SSD_CF    USSD_CF NOT null
 ,SEGTYP_CT USEGTYP_CT DEFAULT '' NOT null
 ,SEG_NF    USEG_NF DEFAULT '' NOT null
 ,UWY_NF    UUWY_NF NOT null
 ,SEG_LL    UL64 null
 ,CUR_CF    UCUR_CF DEFAULT '' NOT null
 ,SEGNAT_CT char(1) DEFAULT '' NOT null
 ,CTRRET_B  bit DEFAULT 0 NOT null
 ,PRMAMT_M  UAMT_M null
 ,CLMAMT_M  UAMT_M null
 ,LOSRAT_R  USHORAT_R null
 ,AMORAT_CT char(1) DEFAULT '' NOT null
 ,ACY_NF    UUWY_NF DEFAULT 0 NOT null
)

select @erreur=0, @AnneeExist=1

-- Récupération de l'année de BILAN dans TCALEND pour la Date en Cours
select @p_blcshtyea_nf=A.blcshtyea_nf
from BREF..TCALEND A
  where ((A.blcshtyea_nf * 100) + A.blcshtmth_nf)=(select min((B.blcshtyea_nf * 100) + B.blcshtmth_nf) from BREF..TCALEND B
                                                    where convert(Char(10),B.specend_d,112) >= convert(Char(10),getdate(),112))
-- Mettre l'Année de Bilan a A-1 si Aucune Ligne n'existe dans TSEGEST
if NOT Exists (select 1 from BEST..TSEGEST
                        where VRS_NF=@p_vrs_nf
                        and segtyp_ct=@p_segtyp_ct
                        and uwy_nf=@p_blcshtyea_nf
                        and ssd_cf=@p_ssd_cf)
begin
    select @p_blcshtyea_nfA0=@p_blcshtyea_nf - 1
    select @AnneeExist=0
end

--***********************************
-- Descente de la table BEST..TSEGEST
--***********************************
insert into #TPTSEGEST (SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, SEG_LL, CUR_CF,SEGNAT_CT, CTRRET_B, PRMAMT_M, CLMAMT_M, LOSRAT_R, AMORAT_CT,ACY_NF)
select A.SSD_CF, A.SEGTYP_CT, A.SEG_NF, A.UWY_NF, B.SEG_LL,  A.CUR_CF,
       B.SEGNAT_CT, B.CTRRET_B, A.PRMAMT_M, A.CLMAMT_M, A.LOSRAT_R , A.AMORAT_CT,ACY_NF
from BEST..TSEGEST A, BEST..TSEGMENT B
where A.VRS_NF=@p_vrs_nf
and A.segtyp_ct=@p_segtyp_ct
and A.ssd_cf=@p_ssd_cf
and A.ssd_cf=B.ssd_cf
and a.vrs_nf=B.VRS_NF
and A.SEG_NF=B.SEG_NF
and A.SEGTYP_CT in(@p_segtyp_ct,@segtyp_SII) -- modif 1
and B.SEGTYP_CT=@p_segtyp_ct

/************************************
   on Change de BILAN, on simplifie la tâche,
   en dupliquant automatiquement,
   les Segments utilisés l'année précédente
************************************/
if (@AnneeExist=0)
begin
  insert into #TPTSEGEST (SSD_CF,SEGTYP_CT,SEG_NF,UWY_NF,SEG_LL,CUR_CF,SEGNAT_CT,CTRRET_B,PRMAMT_M,CLMAMT_M,LOSRAT_R,AMORAT_CT,ACY_NF)
   select A.SSD_CF,A.SEGTYP_CT,A.SEG_NF,@p_blcshtyea_nf,B.SEG_LL,A.CUR_CF,B.SEGNAT_CT,B.CTRRET_B,A.PRMAMT_M,A.CLMAMT_M,A.LOSRAT_R,A.AMORAT_CT,ACY_NF
    from BEST..TSEGEST A, BEST..TSEGMENT B
     where A.VRS_NF=@p_vrs_nf
       and A.segtyp_ct=@p_segtyp_ct
       and uwy_nf=@p_blcshtyea_nfA0
       and A.ssd_cf=@p_ssd_cf
       and A.ssd_cf=B.ssd_cf
       and a.vrs_nf=B.VRS_NF
       and A.SEG_NF=B.SEG_NF
       and A.SEGTYP_CT in(@p_segtyp_ct,@segtyp_SII) -- modif 1
       and B.SEGTYP_CT=@p_segtyp_ct
end

update #TPTSEGEST set LOSRAT_R=LOSRAT_R * 100 where AMORAT_CT='R'

select SSD_CF,SEGTYP_CT,SEG_NF,UWY_NF,SEG_LL,CUR_CF,SEGNAT_CT,CTRRET_B,PRMAMT_M,CLMAMT_M,LOSRAT_R,AMORAT_CT,ACY_NF
from #TPTSEGEST

return 0
go
if object_id('dbo.PsSEGEST_02') is not null
  print '<<< CREATED PROC dbo.PsSEGEST_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsSEGEST_02 >>>'
go
grant execute on dbo.PsSEGEST_02 TO GOMEGA, GDBBATCH
go
