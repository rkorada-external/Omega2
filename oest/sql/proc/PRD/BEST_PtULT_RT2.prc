
USE BEST
Go

/* DROP PROC dbo.PtULT_RT2 */
IF OBJECT_ID('dbo.PtULT_RT2') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RT2
   PRINT '<<< DROPPED PROC dbo.PtULT_RT2 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RT2
     (
       @p_taux_parametrage		USHORAT_R,
       @p_mt_propose_prm			UAMT_M,     
       @p_aliment_revise			UAMT_M,
       @p_aliment_estime			UAMT_M,
       @p_prime_forfaitaire		bit,
       @p_top_assiette_def		bit,
       @p_type_traitement		char(1),
       @p_mode_gestion			char(1) output
     )
as

/***************************************************

Programme: PtULT_RT2

Fichier script associé : ESTRT2.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

RT2 : Cette règle de transition "traité non/proportionnel" s'applique à la fois au 
	mode de gestion des primes et au mode de gestion du S/P. 
	Les algorithmes sont paramètrés en fonction du type de traitements(P:primes ou S:S/P).

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_regle_transition_trt_n" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "c_TransitionTraitNonProp" en C sous UNIX.
*******************************************************************************************

	
Parametres:
       @p_taux_parametrage	USHORAT_R		: (BEST..PsULTRT0).
       @p_mt_propose_prm		UAMT_M			: (TCTRULT) calamtprm_m.
       @p_aliment_revise		UAMT_M			: (TFAMLIA) scogloegp_m.
       @p_aliment_estime		UAMT_M   		: (TFAMLIA) scoorgegp_m.
       @p_prime_forfaitaire	bit			: (TFAMCOTP) flaprm_b.
       @p_top_assiette_def	bit			: (TFAMCOTP) sbjcptdef_b.
       @p_type_traitement	char(1)		: "P": Prime ou "S":S/P.
       @p_mode_gestion		char(1) output	: (TCTRULT)	Si as_type_traitement = "P" => admmodprm_ct.
                                                        	Si as_type_traitement = "S" => admmodclm_ct.
             
				
CODE RETOUR : 	Variables output

		

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare		@erreur		int,
			@aliment_retenu 	UAMT_M
			/*@mode_gestion	char(1)*/

set arithabort numeric_truncation off		/* éviter 'truncation error'	*/


/*------------------------------------------------
3. Traitement
--------------------------------------------------*/

IF @p_type_traitement = "S"
BEGIN
	IF  @p_mode_gestion = "F"
	BEGIN
		select @p_mode_gestion = @p_mode_gestion  /* on garde le même mode de gestion */
		goto select_final
	END
	ELSE
	BEGIN
		select @p_mode_gestion = "A"
		goto select_final
	END
END

/*---------------------------------------------------------------------------
	Si mode de gestion initial est "Forcé", on garde le même mode de gestion.  
---------------------------------------------------------------------------*/
IF  @p_mode_gestion = "F"
BEGIN	
	select @p_mode_gestion = @p_mode_gestion
	goto select_final
END

/*-----------------------------------------------------------------------------
	Si l'affaire est tarifée forfaitairement, il faut comparer l'aliment retenu
	en souscription via le taux de paramètrage au montant proposé, sinon le mode
	de gestion devient automatique si l'assiette comptable saisie en 
	souscription  est déclaré définitive.
-----------------------------------------------------------------------------*/
IF @p_prime_forfaitaire = 1
BEGIN
	IF @p_aliment_revise > 0
	BEGIN
		select @aliment_retenu = @p_aliment_revise
	END
	ELSE
	BEGIN
		select @aliment_retenu = @p_aliment_estime
	END
	
	IF @p_mt_propose_prm >= (@aliment_retenu * @p_taux_parametrage)
	BEGIN
		select @p_mode_gestion = "A"
	END
	ELSE
	BEGIN
		select @p_mode_gestion = "M"
	END
END
ELSE
BEGIN
	IF @p_top_assiette_def = 1
	BEGIN
		select @p_mode_gestion = "A"
	END
	ELSE
	BEGIN
		select @p_mode_gestion = "M"
	END
END

	
/*----------------
 Select de retour 
-----------------*/
select_final:
/*select @mode_gestion*/


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTRT2', 'PtULT_RT2', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RT2') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RT2 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RT2 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RT2
 */
GRANT EXECUTE ON dbo.PtULT_RT2 TO GOMEGA
go

