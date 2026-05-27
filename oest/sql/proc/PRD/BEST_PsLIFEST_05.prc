use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * USE BEST
 * Go
 * DROP PROC dbo.PsLIFEST_05
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsLIFEST_05') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsLIFEST_05
   PRINT '<<< DROPPED PROC dbo.PsLIFEST_05 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsLIFEST_05
     (
      @p_balshey_nf          smallint,
       @p_ctr_nf              UCTR_NF,
       @p_end_nt              UEND_NT,
       @p_sec_nf              USEC_NF,
       @p_uw_nt               UUW_NT
     )
as

/***************************************************

Programme: PsLIFEST_05

Fichier script associé : ESSLIF05.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 21/04/1997

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
	 @CUR_CFA       UCUR_CF,		/* zones table TFAMLIA - monnaie alim. part scor (base Traité) */
	@CUR_CFS       UCUR_CF,            /* monnaie section   */
	@CUR_CF       UCUR_CF,		/* monnaie estimation ou à défaut monnaie alim. part scor */
	@monnaie  	tinyint     /* valeur 1 si la monnaie estimation existe et est différente */
					/* de la monnaie de l'aliment à la part scor, valeur 0 sinon */

/********************************************************************************************/ 
/* Select dans TSECTION :                                                                   */
/*	Exercice de souscription le plus récent où l'état de la section est :		     */  
/*         - Accepté (code 14)                                                              */
/*         - Définitif (code 16)                                                            */
/*         - Renouvelé (code 17)                                                            */
/*         - Résilié (code 19)                                                              */
/********************************************************************************************/
 
Select  @UWY_NF = max(UWY_NF)
   
   from BTRT..TSECTION
  where CTR_NF = @p_CTR_NF
    and END_NT = @p_END_NT
    and UW_NT = @p_UW_NT
    and SEC_NF = @p_SEC_NF
    and (SECSTS_CT = 14 or SECSTS_CT = 16 or SECSTS_CT = 17 or SECSTS_CT = 19)     

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TCONTR"
      return 1
   end


/********************************************************************************************/ 
/* Select dans TSECTION  (correspondant au dernier ex de souscription)                      */      
/*     Monnaie section                                                                      */
/********************************************************************************************/

 Select @CUR_CFS = PCPCUR_CF		
   
   from BTRT..TSECTION
  where CTR_NF = @p_CTR_NF
    and END_NT = @p_END_NT
    and SEC_NF = @p_SEC_NF
    and UW_NT = @p_UW_NT
    and UWY_NF = @UWY_NF

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TSECTION"
      return 1
   end

/********************************************************************************************/
/* Select dans TLIFEST                                                                      */
/* 	Monnaie des estimations                                                             */
/* (Select dans TFAMLIA  -> NON (modif 1)                                                   */
/*    Monnaie de l'aliment à la part scor (correspondant au dernier ex de souscription))     */
/* Maj @monnaie : valeur 1 si la monnaie estimation existe et est différente                */
/* de la monnaie de l'aliment à la part scor, valeur 0 sinon                                */
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


/* Select @CUR_CFA = EGPCUR_CF
        
   	from BTRT..TFAMLIA
  where CTR_NF = @p_CTR_NF
    and END_NT = @p_END_NT
    and SEC_NF = @p_SEC_NF
    and UW_NT = @p_UW_NT
    and UWY_NF = @UWY_NF

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TFAMLIA" 
      return 1
   end

*/

If @ligne != 0 and @CUR_CFE != @CUR_CFS
  begin
	select @CUR_CF = @CUR_CFE
	select @monnaie = 1
  end
else
  begin
	select @CUR_CF = @CUR_CFS
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

exec sp_SCOR_INSPRC 'ESSLIF05', 'PsLIFEST_05', 'BEST', 'ANB'
go

IF OBJECT_ID('dbo.PsLIFEST_05') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsLIFEST_05 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsLIFEST_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsLIFEST_05
 */
GRANT EXECUTE ON dbo.PsLIFEST_05 TO GOMEGA
go

