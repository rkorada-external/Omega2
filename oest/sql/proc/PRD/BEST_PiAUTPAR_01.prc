use BEST
go


USE BEST
Go

/* DROP PROC dbo.PiAUTPAR_01
*/
IF OBJECT_ID('dbo.PiAUTPAR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiAUTPAR_01
   PRINT '<<< DROPPED PROC dbo.PiAUTPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiAUTPAR_01
     (
       @p_ssd_cf              USSD_CF,
       @p_ctrnat_ct           char(1),
       @p_lob_cf              ULOB_CF,
       @p_pcprsktry_cf        UCTY_CF,
       @p_sob_cf              USOB_CF,   
       @p_limper_r            USHORAT_R,
       @p_quanum_nb           tinyint,
       @p_erreur              varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiAUTPAR_01

Fichier script associé : ESIAUT01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: Gordana DIMCEA avec Infotool version 2.0 (AUTO) 

Date de creation: 

Description du programme: 

      Insertion d'enregistrement dans TAUTPAR

Parametres: 
       @p_ssd_cf              USSD_CF,
       @p_ctrnat_ct           char(1),
       @p_lob_cf              ULOB_CF,
       @p_pcprsktry_cf        UCTY_CF,
       @p_sob_cf              USOB_CF,
       @p_limper_r            USHORAT_R,
       @p_quanum_nb           tinyint,
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

insert into TAUTPAR
      (
                ctrnat_ct,
                lob_cf,
                pcprsktry_cf,
                sob_cf,
                ssd_cf,
                limper_r,
                quanum_nb
      )
 values
      (
        @p_ctrnat_ct,
        @p_lob_cf,
        @p_pcprsktry_cf,
        @p_sob_cf,
        @p_ssd_cf,
        @p_limper_r,
        @p_quanum_nb
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

exec sp_SCOR_INSPRC 'ESIAUT01', 'PiAUTPAR_01', 'BEST', 'ME08'
go

IF OBJECT_ID('dbo.PiAUTPAR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiAUTPAR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiAUTPAR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiAUTPAR_01
 */
GRANT EXECUTE ON dbo.PiAUTPAR_01 TO GOMEGA
go

