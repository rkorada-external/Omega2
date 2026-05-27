use BEST
go
if object_id('dbo.PuPATSEGSII_01') is not null
begin
  drop PROC dbo.PuPATSEGSII_01
  print '<<< DROPPED PROC dbo.PuPATSEGSII_01 >>>'
end
go
create procedure PuPATSEGSII_01
  (
  @p_PATCAT_CT    char(5)
 ,@p_PATTYP_CT    char(5)
 ,@p_SSD_CF       USSD_CF
 ,@p_SEG_NF       USEG_NF
 ,@p_LOB_CF       char(2)
 ,@p_CUR_CF       UCUR_CF
 ,@p_NORME_CF     char(5)
 ,@p_RATING_CF    char(5)
 ,@p_SEGNAT_CT    char(1)
 ,@p_CLODAT_D     datetime
 ,@p_PER_CF       char(5)
 ,@p_PATTERN_ID   char(21)
 ,@p_LSTUPD_D     UUPD_D=null output
 ,@p_LSTUPDUSR_CF UUPDUSR_CF=null output
 ,@p_erreur       varchar(64)=null output
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 17/07/2012
Description du programme: :spot:23390 (SOLVENCY)
Conditions d'execution: Par d_ff_ex_es_sii_choix et fenêtre w_feuille_es_sii_choix
Commentaires:
_________________
MODIFICATIONS
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@nbligne   int

if @p_lstupd_d=null select @p_lstupd_d=getdate()
if isnull(@p_lstupdusr_cf,'')='' select @p_lstupdusr_cf=suser_name()

select @erreur = 0,@tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

update TPATSEGSII
 set CLODAT_D=case when PATTERN_ID=@p_PATTERN_ID then @p_CLODAT_D else null end
    ,PER_CF=case when PATTERN_ID=@p_PATTERN_ID then @p_PER_CF else null end
  where PATCAT_CT=@p_PATCAT_CT
    and PATTYP_CT=@p_PATTYP_CT
    and isnull(SSD_CF,0)=isnull(@p_SSD_CF,0)
    and isnull(SEG_NF,'-1')=isnull(@p_SEG_NF,'-1')
    and isnull(LOB_CF,'-1')=isnull(@p_LOB_CF,'-1')
    and isnull(CUR_CF,'-1')=isnull(@p_CUR_CF,'-1')
    and isnull(NORME_CF,'-1')=isnull(@p_NORME_CF,'-1')
--    and isnull(RATING_CF,'-1')=isnull(@p_RATING_CF,'-1') -- à ajouter quand MPD de la table est fait
    and isnull(SEGNAT_CT,'-1')=isnull(@p_SEGNAT_CT,'-1')
select @erreur = @@error, @nbligne = @@rowcount
if @erreur != 0
begin
  select @p_erreur="20004 APPLICATIF;TPATSEGSII " + convert(varchar(10), @erreur) + ";"
  goto fin
end
if @nbligne = 0
begin
  select @p_erreur = "20006 APPLICATIF;TPATSEGSII " + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
go
if object_id('dbo.PuPATSEGSII_01') is not null
  print '<<< CREATED PROC dbo.PuPATSEGSII_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuPATSEGSII_01 >>>'
go
grant execute on dbo.PuPATSEGSII_01 TO GOMEGA
go
