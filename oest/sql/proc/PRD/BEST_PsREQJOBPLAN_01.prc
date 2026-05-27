use BEST
go
if object_id('dbo.PsREQJOBPLAN_01') is not null
begin
  drop PROC dbo.PsREQJOBPLAN_01
  print '<<< DROPPED PROC dbo.PsREQJOBPLAN_01 >>>'
end
go
create procedure PsREQJOBPLAN_01
  (
  @p_balsheyea_nf smallint
 ,@p_balshtmth_nf tinyint
 ,@p_clodat_d     datetime
 ,@p_cre_d        UUPD_D
 ,@p_reqcod_ct    char(1)
 ,@p_ssd_cf       USSD_CF
  )
as
/***************************************************
Domaine: (ES) Estimation
Base principale: BEST
Version: 1
Auteur: Tony RIPERT
Date de creation:
Description du programme: Sélection d'enregistrement dans TREQJOB + Libellé de la version dans TVERSION
                           + Période exceptionnelle
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  Florent   25/06/2012 :spot:23390 SOLVENCY II
*****************************************************/
declare
  @erreur int
 ,@v_segtyp_ct USEGTYP_CT
 ,@v_VRS_NF   numeric(10,0)
 ,@v_VRS_LM   UL32
 ,@ls_ssd_cf  USSD_CF
 ,@zz_ssd_cf  USSD_CF

select @v_segtyp_ct=''

-- Recherche la filiale de la demande
select   @ls_ssd_cf = SSD_CF
from     BEST..TREQJOBPLAN
where    balsheyea_nf   = @p_balsheyea_nf
    and  balshtmth_nf   = @p_balshtmth_nf
    and  clodat_d       = @p_clodat_d
    and  cre_d          = @p_cre_d
    and  reqcod_ct      = @p_reqcod_ct
--    and  cloper_ls      = @p_ssd_cf

-- Proposition de sinistralité
if @p_reqcod_ct = 'S' select @v_segtyp_ct = 'E'

-- Demande d'inventaire
if @p_reqcod_ct = 'I' select @v_segtyp_ct = 'A'

select distinct
      @zz_ssd_cf = b.ssd_cf,
      @v_VRS_NF = max(B.vrs_nf)
 from  TVERSION B, TVERPAR C
where VRSSTS_CT <> 'AN' and VRSLOC_B = 0
  and C.SEGTYP_CT = @v_segtyp_ct
  and b.ssd_cf = @ls_ssd_cf
  and b.ssd_cf = c.ssd_cf
  and b.vrs_nf = c.vrs_nf
group by b.ssd_cf
having C.PAR_D = max( C.PAR_D )
order by b.ssd_cf

select distinct @v_VRS_LM=VRS_LM
 from  BEST..TVERSION
  where ssd_cf=@p_ssd_cf
    and vrs_nf=@v_VRS_NF
    and SEGTYP_CT=@v_segtyp_ct

select
  TR.balsheyea_nf
 ,TR.balshtmth_nf
 ,TR.clodat_d
 ,TR.cre_d
 ,TR.reqcod_ct
 ,TR.ssd_cf
 ,TR.cloper_ls
 ,TR.dbclo_d
 ,TR.launch_d
 ,TR.updusr_cf
 ,VRS_NF=case when @p_reqcod_ct in('D','E','T','A') then TR.VRS_NF else @v_VRS_NF end
 ,@v_VRS_LM
 ,TC.specend_d
 ,TC.account_d
 ,TR.start_d
 ,END_D=case when TR.end_d=TR.launch_d then convert(datetime,convert(char(8),TR.end_d,112)) else TR.end_d end
 from TREQJOBPLAN TR, BREF..TCALEND TC
  where TR.balsheyea_nf = @p_balsheyea_nf
    and TR.balshtmth_nf = @p_balshtmth_nf
    and TR.clodat_d     = @p_clodat_d
    and TR.cre_d        = @p_cre_d
    and TR.reqcod_ct    = @p_reqcod_ct
    and TR.ssd_cf       = @ls_ssd_cf
    and TC.blcshtyea_nf = @p_balsheyea_nf
    and TR.balshtmth_nf *= TC.blcshtmth_nf
select @erreur = @@error
if @erreur != 0
begin
  raiserror 20005 "Erreur selection TREQJOB"
  return @erreur
end

return 0
go
if object_id('dbo.PsREQJOBPLAN_01') is not null
  print '<<< CREATED PROC dbo.PsREQJOBPLAN_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsREQJOBPLAN_01 >>>'
go
grant execute on dbo.PsREQJOBPLAN_01 TO GOMEGA
go

