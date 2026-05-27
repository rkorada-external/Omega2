use BEST
go
if object_id('dbo.PiLIFDRI_01') is not null
begin
   drop PROC dbo.PiLIFDRI_01
   print '<<< DROPPED PROC dbo.PiLIFDRI_01 >>>'
end
go
create procedure PiLIFDRI_01
  (
  @p_acy_nf       smallint,
  @p_balshey_nf   smallint,
  @p_balshtmth_nf tinyint,
  @p_ctr_nf       UCTR_NF,
  @p_end_nt       UEND_NT,
  @p_sec_nf       USEC_NF,
  @p_uw_nt        UUW_NT,
  @p_uwy_nf       UUWY_NF,
  @p_autupd_b     bit,
  @p_cmt_nt       UCMT_NT,
  @p_comacc_b     bit,
  @p_creusr_cf    UUPDUSR_CF,
  @p_lstupd_d     UUPD_D=null output,
  @p_lstupdusr_cf UUPDUSR_CF=null output,
  @p_ssd_cf       USSD_CF,
  @p_erreur       varchar(64)=null output
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)
Date de creation:
Description du programme: Insertion d'enregistrement dans TLIFDRI
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur:         G. Buisson
Date:           05/01/2004
Description:    on force la filiale avec les 2 premiers caracteres
                du contrat (probleme du a la filialisation vie)
_________________
MODIFICATION 2
Auteur:         Sohal Sinha
Date:           12/02/2014
Description:    Changes done to remove the substring code for fetching the subsidiary from Contract.
*****************************************************/
declare @erreur int,
        @tran_imbr  bit,
        @ssd_cf USSD_CF

select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   begin tran
  end

--Modification 2
--select @ssd_cf = convert(tinyint,substring(@p_ctr_nf, 1, 2))

/***********************************************************************************/
/* Insertion dans TLIFDRI                                                          */
/***********************************************************************************/

insert into TLIFDRI
      (
                acy_nf,
                balshey_nf,
                balshtmth_nf,
                cre_d,
                ctr_nf,
                end_nt,
                sec_nf,
                uw_nt,
                uwy_nf,
                autupd_b,
                cmt_nt,
                comacc_b,
                creusr_cf,
                lstupd_d,
                lstupdusr_cf,
                ssd_cf
      )
 values
      (
        @p_acy_nf,
        @p_balshey_nf,
        @p_balshtmth_nf,
        getdate(),
        @p_ctr_nf,
        @p_end_nt,
        @p_sec_nf,
        @p_uw_nt,
        @p_uwy_nf,
        @p_autupd_b,
        @p_cmt_nt,
        @p_comacc_b,
        @p_creusr_cf,
        getdate(),
        user,
        @p_ssd_cf
      )

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = "ERREUR trigger"
   goto fin
  end

if @erreur != 0
  begin
   if @erreur = 2601
     select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliquée */
   else
     select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

   goto fin
  end

select @p_lstupdusr_cf = lstupdusr_cf,
       @p_lstupd_d = lstupd_d
from TLIFDRI
       where acy_nf = @p_acy_nf
         and balshey_nf = @p_balshey_nf
         and balshtmth_nf = @p_balshtmth_nf
         and ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uw_nt = @p_uw_nt
         and uwy_nf = @p_uwy_nf

select @erreur = @@error
if @erreur != 0
   select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"


/***********************************************************************************/
/* Maj du n° de commentaire sur toutes les années de compte                        */
/***********************************************************************************/

begin

update TLIFDRI
  set cmt_nt = @p_cmt_nt
where
  ctr_nf = @p_ctr_nf and
        end_nt =  @p_end_nt and
      sec_nf = @p_sec_nf and
  uw_nt = @p_uw_nt and
  uwy_nf = @p_uwy_nf and
  acy_nf = @p_acy_nf

 select @erreur = @@error
   if @erreur != 0
     begin
      select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
      goto fin
     end


end

if @tran_imbr = 0
   commit tran
return 0

fin:
if @tran_imbr = 0
   rollback tran
return @erreur
go
if object_id('dbo.PiLIFDRI_01') is not null
  print '<<< CREATED PROC dbo.PiLIFDRI_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PiLIFDRI_01 >>>'
go
grant execute on dbo.PiLIFDRI_01 TO GOMEGA
go
grant execute on dbo.PiLIFDRI_01 TO GDBBATCH
go
