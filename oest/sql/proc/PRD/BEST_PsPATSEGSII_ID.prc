use BEST
go
if object_id('dbo.PsPATSEGSII_ID') is not null
begin
  drop PROC dbo.PsPATSEGSII_ID
  print '<<< DROPPED PROC dbo.PsPATSEGSII_ID >>>'
end
go
create procedure PsPATSEGSII_ID
  (
  @p_PATCAT_CT char(5)
 ,@p_PATTYP_CT char(5)
 ,@p_SSD_CF    USSD_CF
 ,@p_SEG_NF    USEG_NF
 ,@p_LOB_CF    char(2)
 ,@p_CUR_CF    UCUR_CF
 ,@p_NORME_CF  char(5)
 ,@p_RATING_CF char(5)
 ,@p_SEGNAT_CT char(1)
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 17/07/2012
Description du programme: :spot:23390 (SOLVENCY)
Conditions d'execution: Par d_ff_ex_es_sii_choix_dddw_id dans d_ff_ex_es_sii_choix et fenêtre w_feuille_es_sii_choix
Commentaires:
_________________
MODIFICATIONS
*****************************************************/
select PATTERN_ID
 from TPATSEGSII
  where PATCAT_CT=@p_PATCAT_CT
    and PATTYP_CT=@p_PATTYP_CT
    and isnull(SSD_CF,0)=isnull(@p_SSD_CF,0)
    and isnull(SEG_NF,'-1')=isnull(@p_SEG_NF,'-1')
    and isnull(LOB_CF,'-1')=isnull(@p_LOB_CF,'-1')
    and isnull(CUR_CF,'-1')=isnull(@p_CUR_CF,'-1')
    and isnull(NORME_CF,'-1')=isnull(@p_NORME_CF,'-1')
--    and isnull(RATING_CF,'-1')=isnull(@p_RATING_CF,'-1') -- à ajouter quand MPD de la table est fait
    and isnull(SEGNAT_CT,'-1')=isnull(@p_SEGNAT_CT,'-1')
go
if object_id('dbo.PsPATSEGSII_ID') is not null
  print '<<< CREATED PROC dbo.PsPATSEGSII_ID >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsPATSEGSII_ID >>>'
go
grant execute on dbo.PsPATSEGSII_ID TO GOMEGA
go
