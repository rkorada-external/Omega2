/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsRETCTR_07
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsRETCTR_07') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsRETCTR_07
   PRINT '<<< DROPPED PROC dbo.PsRETCTR_07 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsRETCTR_07
     (
	 @p_rty_nf               UUWY_NF,
	@p_plc_nt      	   UPLC_NT, 
 	 @p_ctr_nf              UCTR_NF
     )
as

/***************************************************

Programme: PsRETCTR_07

Fichier script associé : ESSRET07.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 21/10/1997

Description du programme: 

      Sélection d'enregistrement dans RETRO / TPLACEMT (sert à ESTIMATIONS)

Parametres: 

	 @p_rty_nf               UUWY_NF,
	@p_plc_nt      	   UPLC_NT, 
 	 @p_ctr_nf              UCTR_NF

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 30/03/1998

Version:

Description: la longueur de @info passe de 17c à 20 c

*****************************************************/

declare @erreur int,
	 @info   char(20),
	 @RTO_NF       UCLI_NF,
	 @INT_NF       UCLI_NF,
   	@PAY_NF       UCLI_NF,
     	@KEY_CF       char(1)



/* ------------------------- Select dans la table TPLACEMT ----------------------------------*/
/* Info rétrocessionnaire-courtier / placements non historisés et comptables, valides (16)   */
/* ou résiliés (19)                                                                           */


 Select @RTO_NF = RTO_NF, 
	@INT_NF = INT_NF, 
	@PAY_NF = PAY_NF, 
	@KEY_CF = KEY_CF
	  
   	from BRET..TPLACEMT
		 where RETCTR_NF = @p_ctr_nf
			and RTY_NF = @p_rty_nf 
			and PLC_NT = @p_plc_nt 
			and HIS_B = 0
			and ACCPLC_B = 1
			and (PLCSTS_CT = 16 or PLCSTS_CT = 19)
			
 

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TPLACEMT" 
      return 1
   end


/* retour des info sous la forme d'une chaine de caractères */

select @info = convert(char(5),@RTO_NF) + "/" + convert(char(5),@INT_NF) + "/" + convert(char(5),@PAY_NF) + "/" + @KEY_CF

select @info



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSRET07', 'PsRETCTR_07', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsRETCTR_07') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsRETCTR_07 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsRETCTR_07 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRETCTR_07
 */
GRANT EXECUTE ON dbo.PsRETCTR_07 TO GOMEGA
go

