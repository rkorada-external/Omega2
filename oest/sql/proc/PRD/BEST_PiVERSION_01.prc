use BEST
go


USE BEST
Go

/* DROP PROC dbo.PiVERSION_01
*/
IF OBJECT_ID('dbo.PiVERSION_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiVERSION_01
   PRINT '<<< DROPPED PROC dbo.PiVERSION_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiVERSION_01
     (
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_cre_d               UUPD_D,
       @p_vrs_lm              UL32,
       @p_cmt_nt              UCMT_NT = NULL,
       @p_ret		     char(64) = NULL output,      
       @p_erreur	           varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiVERSION_01

Fichier script associé : ESIVER01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO) 

Date de creation: 

Description du programme: 

      Insertion d'enregistrement dans TVERSION

Parametres: 
       @p_segtyp_ct           USEGTYP_CT,     : Type segment
       @p_ssd_cf              USSD_CF,        : Filiale
       @p_cre_d               UUPD_D,         : Date de la version
       @p_vrs_lm              UL32,           : Nom de la version
       @p_cmt_nt              UCMT_NT = NULL, : Commentaire
	 @p_ret     char(64) = NULL output,     : Code retour "vrs_nf" 
       @p_erreur  varchar(64)=NULL output 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: JP BESSY

Date:05/08/1997

Version:

Description:Le numéro de version n'est plus un Identity -> recherche de la clé.

*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @vrs_nf  numeric

/* Sélection de la dernière clé */
select @vrs_nf = ISNUll(max(VRS_NF),0) + 1
  from TVERSION
 where ssd_cf = @p_ssd_cf
   and segtyp_ct = @p_segtyp_ct 

select @erreur = @@error
  if @erreur != 0
     begin
       select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
       goto fin
      end
 

select @erreur = 0
select @tran_imbr = 1		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 

insert into TVERSION
      ( vrs_nf,
        segtyp_ct,
        ssd_cf,
        cre_d,
        creusr_cf,
        lstupd_d,
        lstupdusr_cf,
        vrs_lm,
        cmt_nt	
      )
 values
      ( @vrs_nf,
        @p_segtyp_ct,
        @p_ssd_cf,
        @p_cre_d,
        user,	
        getdate(),
        user,
        @p_vrs_lm,
        @p_cmt_nt
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


/*--------------------------------------------------
 Retourne par l'intermédiaire du paramètre @_ret, 
 le numéro de version affecté lors de l'insert 
---------------------------------------------------*/
Select @p_ret = convert(char(64),@vrs_nf)

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

exec sp_SCOR_INSPRC 'ESIVER01', 'PiVERSION_01', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PiVERSION_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiVERSION_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiVERSION_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiVERSION_01
 */
GRANT EXECUTE ON dbo.PiVERSION_01 TO GOMEGA
go

