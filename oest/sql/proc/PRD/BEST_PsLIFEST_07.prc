use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsLIFEST_07
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsLIFEST_07') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsLIFEST_07
   PRINT '<<< DROPPED PROC dbo.PsLIFEST_07 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsLIFEST_07
     (
      @p_balshey_nf          smallint,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT
     )
as

/***************************************************

Programme: PsLIFEST_07

Fichier script associé : ESSLIF07.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 12/05/1997

Description du programme: 

      Sélection d'enregistrement dans TLIFEST

Parametres: 
       @p_balshey_nf          smallint,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT

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
	 @ligne int,
	 @UWY_NF         UUWY_NF,
	 @CUR_CFE       UCUR_CF,		/* zones table TLIFEST - monnaie estimation (base ESTIMATION) */
	 @RETPCPCUR_CF      UCUR_CF,	/* zones table TRETCTR- Devise rétro de représentation (base Retro) */
	@CUR_CF       UCUR_CF,		/* monnaie estimation ou à défaut Devise rétro de représentation */
	@monnaie  	tinyint     /* valeur 1 si la monnaie estimation existe et est différente */
					/* de la Devise rétro de représentation, valeur 0 sinon */

/********************************************************************************************/ 
/* Select dans TRETCTR :                                                                    */
/*	Exercice de souscription le plus récent où l'état du contrat est ... :		     */  
/*         - Valide (code 03)                                                               */
/*         - Résilié (code 19)                                                              */
/*    and contrat non terminé                                                               */
/********************************************************************************************/
 
Select  @UWY_NF = max(RTY_NF)
   
   from BRET..TRETCTR
  where RETCTR_NF = @p_CTR_NF
    and (RETCTRSTS_CT = 3 or RETCTRSTS_CT = 19) 
    and TERCTR_B = 0  

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TRETCTR"
      return 1
   end



/********************************************************************************************/ 
/* Select dans TRETCTR (correspondant au dernier ex de souscription) :                      */
/*    Devise rétro de représentation                                                        */ 
/********************************************************************************************/

 Select @RETPCPCUR_CF = RETPCPCUR_CF

   from BRET..TRETCTR
  where RETCTR_NF = @p_CTR_NF
    and RTY_NF = @UWY_NF

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TRETCTR"
      return 1
   end



/********************************************************************************************/
/* Select dans TLIFEST                                                                      */
/* 	Monnaie des estimations                                                              */
/* Maj @monnaie : valeur 1 si la monnaie estimation existe et est différente                */
/* de la devise rétro de représentation, valeur 0 sinon                                     */
/********************************************************************************************/

 Select  @CUR_CFE = cur_cf
   from TLIFEST
  where balshey_nf = @p_balshey_nf
    and ctr_nf = @p_ctr_nf
    and end_nt = @p_end_nt
    and sec_nf = @p_sec_nf
    and uw_nt = @p_uw_nt

   select @erreur = @@error, @ligne = @@rowcount

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TLIFEST" /* erreur de modification */
      return @erreur
   end


 

If @ligne != 0 and @CUR_CFE != @RETPCPCUR_CF
  begin
	select @CUR_CF = @CUR_CFE
	select @monnaie = 1
  end
else
  begin
	select @CUR_CF = @RETPCPCUR_CF
	select @monnaie = 0
  end

/********************************************************************************************/
/* Select final                                                                             */
/********************************************************************************************/

 Select @CUR_CF CUR_CF,
	  @monnaie monnaie


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSLIF07', 'PsLIFEST_07', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PsLIFEST_07') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsLIFEST_07 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsLIFEST_07 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsLIFEST_07
 */
GRANT EXECUTE ON dbo.PsLIFEST_07 TO GOMEGA
go

