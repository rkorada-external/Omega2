use BEST
go

IF OBJECT_ID('dbo.PiCTRFIC_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiCTRFIC_01
   PRINT '<<< DROPPED PROC dbo.PiCTRFIC_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiCTRFIC_01
     (
       @p_liftrttyp_cf        char(2),
       @p_pcprsktry_cf        UCTY_CF,
       @p_ssd_cf              USSD_CF,
       @p_uwgrp_cf            UGRP_CF,
       @p_ced_nf              UCLI_NF,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_erreur     	      varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiCTRFIC_01

Fichier script associé : ESICTR01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0

Date de creation:

Description du programme:

      Insertion d'enregistrement dans TCTRFIC

Parametres:
       @p_liftrttyp_cf        char(2),
       @p_pcprsktry_cf        UCTY_CF,
       @p_ssd_cf              USSD_CF,
       @p_uwgrp_cf            UGRP_CF,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_erreur	      varchar(64)=NULL output

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:       Tony RIPERT

Date:         24 Juin 2010

Version:

Description:  Ajout la cédante

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

If @p_ced_nf = null select @p_ced_nf = 0

insert into TCTRFIC
      (         liftrttyp_cf,
                pcprsktry_cf,
                ssd_cf,
                uwgrp_cf,
                cre_d,
                creusr_cf,
                ctr_nf,
                end_nt,
                lstupd_d,
                lstupdusr_cf,
                ced_nf
      )
 values
      ( @p_liftrttyp_cf,
        @p_pcprsktry_cf,
        @p_ssd_cf,
        @p_uwgrp_cf,
        getdate(),
        user,
        @p_ctr_nf,
        @p_end_nt,
        getdate(),
        user,
        @p_ced_nf
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
from TCTRFIC
       where liftrttyp_cf = @p_liftrttyp_cf
         and pcprsktry_cf = @p_pcprsktry_cf
         and ssd_cf       = @p_ssd_cf
         and uwgrp_cf     = @p_uwgrp_cf
         and ced_nf       = @p_ced_nf

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

exec sp_SCOR_INSPRC 'ESICTR01', 'PiCTRFIC_01', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PiCTRFIC_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiCTRFIC_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiCTRFIC_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiCTRFIC_01
 */
GRANT EXECUTE ON dbo.PiCTRFIC_01 TO GOMEGA
go

