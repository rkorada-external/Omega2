use BEST
go


IF OBJECT_ID('dbo.PsRETCTR_05') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETCTR_05
   PRINT '<<< DROPPED PROC dbo.PsRETCTR_05 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsRETCTR_05
     (
	 @p_rty_nf               UUWY_NF,
 	 @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsRETCTR_05

Fichier script associé : ESSRET05.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 20/10/1997

Description du programme:

      Sélection d'enregistrement dans RETRO / TPLACEMT (sert à ESTIMATIONS)

Parametres:

	 @p_rty_nf               UUWY_NF,
 	 @p_ctr_nf              UCTR_NF

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int

/* ------------------------- Select dans la table TPLACEMT ---------------------------- */
/* Liste des placements non historisés et comptables, valides (16) ou résiliés (19)     */


 Select PLC_NT

   	from BRET..TPLACEMT
		 where RETCTR_NF = @p_ctr_nf
			and RTY_NF = @p_rty_nf
			and HIS_B = 0
			and ACCPLC_B = 1
			and (PLCSTS_CT = 16 or PLCSTS_CT = 19)


   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TPLACEMT"
      return 1
   end



return 0
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSRET05', 'PsRETCTR_05', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsRETCTR_05') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETCTR_05 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETCTR_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETCTR_05
 */
GRANT EXECUTE ON dbo.PsRETCTR_05 TO GOMEGA
go

