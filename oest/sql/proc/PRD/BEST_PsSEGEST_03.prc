use BEST
go
if object_id('dbo.PsSEGEST_03') is not null
begin
  drop PROC dbo.PsSEGEST_03
  print '<<< DROPPED PROC dbo.PsSEGEST_03 >>>'
end
go
create procedure PsSEGEST_03
  (
  @P_VRS_NF    numeric(10,0),
  @P_SSD_CF    USSD_CF,
  @P_SEGTYP_CT USEGTYP_CT,
  @P_SEG_NF    USEG_NF,
  @P_UWY_NF    UUWY_NF,
  @P_ACY_NF    UUWY_NF
  )
as
/***************************************************
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI -
Date de creation: 24/08/2004
Description du programme: Extraction de la Table BEST..TSEGEST & BEST..TSEGMENT pour chargement via ESED0431.cmd Asynchrone
Conditions d'execution:
Commentaires:
_________________
1  Florent   09/05/2012 :spot:23390 SOLVENCY II
2  Florent   01/06/2015 :spot:28694 Segmentation VIE
*****************************************************/
declare
  @erreur int
 ,@segtyp    USEGTYP_CT     -- modif 1

-- pour les jointures sur les autres table que TSEGEST il faut prendre le A si on a S
if @p_segtyp_ct='S'
  select @segtyp='A'
else
  select @segtyp=@p_segtyp_ct

select @erreur=0

select
  isnull(B.SEG_LL,'')
 ,isnull(B.SEGNAT_CT,'')
 ,isnull(B.CTRRET_B,0)
 ,isnull(A.PRMAMT_M,0)
 ,isnull(A.CLMAMT_M,0)
 ,isnull(A.LOSRAT_R,0)
 ,isnull(A.AMORAT_CT,'')
 from TSEGEST A, TSEGMENT B
  where A.VRS_NF=@P_VRS_NF
    and A.SSD_CF=@P_SSD_CF
    and A.SEGTYP_CT=@P_SEGTYP_CT
    and A.SEG_NF=@P_SEG_NF
    and A.UWY_NF=@P_UWY_NF
    and A.ACY_NF=@P_ACY_NF
    and A.VRS_NF=B.VRS_NF
    and A.SSD_CF=B.SSD_CF
    and B.SEGTYP_CT=@segtyp -- modif 1
    and A.SEG_NF=B.SEG_NF
select @erreur=@@error
if @erreur!=0
  return @erreur

return 0
go
if object_id('dbo.PsSEGEST_03') is not null
  print '<<< CREATED PROC dbo.PsSEGEST_03 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsSEGEST_03 >>>'
go
grant execute on dbo.PsSEGEST_03 TO GOMEGA, GDBBATCH
go
