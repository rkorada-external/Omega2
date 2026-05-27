use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PiCTREST_02
*/
IF OBJECT_ID('dbo.PiCTREST_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiCTREST_02
   PRINT '<<< DROPPED PROC dbo.PiCTREST_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiCTREST_02
     (
       @p_acmtrs_nt           smallint,
       @p_cre_d               UUPD_D,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_prs_cf              smallint,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_admmod_ct           char(1),
       @p_calamt_m            UAMT_M,
       @p_clodat_d            datetime,
       @p_creusr_cf           UUPDUSR_CF,
       @p_cur_cf              UCUR_CF,
       @p_div_nt              UDIV_NT,
       @p_entamt_m            UAMT_M,
       @p_lstupd_d     UUPD_D=NULL output,
       @p_lstupdusr_cf     UUPDUSR_CF=NULL output,
       @p_oricod_ls           UL16,
       @p_retamt_m            UAMT_M,
       @p_ssd_cf              USSD_CF,
       @p_updusr_cf           char(10),
       @p_cmt_nt            UCMT_NT, -- modif 002
	    @p_Incurredci_M  	  UAMT_M, --MOD003
      @p_erreur	varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiCTREST_02

Fichier script associé : ESICTR02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER - ASCOTT - ME01) 

Date de creation: 20/05/1997

Description du programme: 

      Insertion d'enregistrement dans TCTREST

Parametres: 
       @p_acmtrs_nt           smallint,
       @p_cre_d               UUPD_D,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_prs_cf              smallint,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
       @p_admmod_ct           char(1),
       @p_calamt_m            UAMT_M,
       @p_clodat_d            datetime,
       @p_creusr_cf           UUPDUSR_CF,
       @p_cur_cf              UCUR_CF,
       @p_div_nt              UDIV_NT,
       @p_entamt_m            UAMT_M,
       @p_lstupd_d     UUPD_D=NULL output,
       @p_lstupdusr_cf     UUPDUSR_CF=NULL output,
       @p_oricod_ls           UL16,
       @p_retamt_m            UAMT_M,
       @p_ssd_cf              USSD_CF,
       @p_updusr_cf           char(10),
	   @p_Incurredci_M  	  UAMT_M, --MOD003
       @p_erreur	varchar(64)=NULL output

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:
[002] 15/03/2018 D. Berté :spira:65703 FORCAGE IBNR : Ajouter l'obligation de renseigner un commentaire lorsque le mode de gestion est FORCE 
MOD03   23/04/2020  Riyadh	 Spira 85772 Added field Incurredci_M
*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 

insert into TCTREST
      (
                acmtrs_nt,
                cre_d,
                ctr_nf,
                end_nt,
                prs_cf,
                sec_nf,
                uw_nt,
                uwy_nf,
                admmod_ct,
                calamt_m,
                clodat_d,
                creusr_cf,
                cur_cf,
                div_nt,
                entamt_m,
                lstupd_d,
                lstupdusr_cf,
                oricod_ls,
                retamt_m,
                ssd_cf,
                updusr_cf,
				Incurredci_M, --MOD003
                cmt_nt  -- modif 002
      )
 values
      (
        @p_acmtrs_nt,
        @p_cre_d,
        @p_ctr_nf,
        @p_end_nt,
        @p_prs_cf,
        @p_sec_nf,
        @p_uw_nt,
        @p_uwy_nf,
        @p_admmod_ct,
        @p_calamt_m,
        @p_clodat_d,
        @p_creusr_cf,
        @p_cur_cf,
        @p_div_nt,
        @p_entamt_m,
        getdate(),
        user,
        @p_oricod_ls,
        @p_retamt_m,
        @p_ssd_cf,
        @p_updusr_cf,
		@p_Incurredci_M, --MOD003
        @p_cmt_nt  -- modif 002
      )

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
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
from TCTREST
       where acmtrs_nt = @p_acmtrs_nt
         and cre_d = @p_cre_d
         and ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and prs_cf = @p_prs_cf
         and sec_nf = @p_sec_nf
         and uw_nt = @p_uw_nt
         and uwy_nf = @p_uwy_nf

select @erreur = @@error
if @erreur != 0 
   select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur

go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESICTR02', 'PiCTREST_02', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PiCTREST_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiCTREST_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiCTREST_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiCTREST_02
 */
GRANT EXECUTE ON dbo.PiCTREST_02 TO GOMEGA
go

