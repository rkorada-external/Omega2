use BEST
go

USE BEST
Go

DROP PROC dbo.PiANASEG_01
go

IF OBJECT_ID('dbo.PiANASEG_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiANASEG_01
   PRINT '<<< DROPPED PROC dbo.PiANASEG_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiANASEG_01
     (
       @p_seg_nf              USEG_NF,
       @p_ssd_cf              USSD_CF,
       @p_cre_d               UUPD_D,
       @p_creusr_cf           UUPDUSR_CF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_seg_ls              UL16,
       @p_seg_lm              UL32,
       @p_erreur	      varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiANASEG_01

Fichier script associé : ESIANA01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ANB avec Infotool version 2.0

Date de creation: 

Description du programme: 

      Insertion d'enregistrement dans TANASEG

Parametres: 
       @p_seg_nf              USEG_NF,
       @p_ssd_cf              USSD_CF,
       @p_cre_d               UUPD_D,
       @p_creusr_cf           UUPDUSR_CF,
       @p_lstupd_d            UUPD_D=NULL output,
       @p_lstupdusr_cf        UUPDUSR_CF=NULL output,
       @p_seg_ls              UL16,
       @p_seg_lm              UL32,
       @p_erreur              varchar(64)=NULL output

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

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

insert into TANASEG
      (
                seg_nf,
                ssd_cf,
                cre_d,
                creusr_cf,
                lstupd_d,
                lstupdusr_cf,
                seg_ls,
                seg_lm
      )
 values
      (
        @p_seg_nf,
        @p_ssd_cf,
        getdate(),
        user,
        getdate(),
        user,
        @p_seg_ls,
        @p_seg_lm
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
from TANASEG
       where seg_nf = @p_seg_nf
         and ssd_cf = @p_ssd_cf

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

exec sp_SCOR_INSPRC 'ESIANA01', 'PiANASEG_01', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PiANASEG_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiANASEG_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiANASEG_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiANASEG_01
 */
GRANT EXECUTE ON dbo.PiANASEG_01 TO GOMEGA
go

