USE BEST
Go

/* DROP PROC dbo.PtULT_RT3 */
IF OBJECT_ID('dbo.PtULT_RT3') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RT3
   PRINT '<<< DROPPED PROC dbo.PtULT_RT3 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RT3
     (
       @p_taux_parametrage		USHORAT_R,
       @p_mt_propose_prm			UAMT_M,     
       @p_aliment_revise			UAMT_M,
       @p_type_traitement		char(1),
	 @p_ctrexp				datetime,
       @p_mode_gestion			char(1) output
     )
as

/***************************************************

Programme: PtULT_RT3

Fichier script associé : ESTRT3.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

RT3 : Cette règle de transition "facutative" s'applique à la fois au 
				mode de gestion des primes et au mode de gestion du S/P. 
				Les algorithmes sont paramètrés en fonction du type de traitements(P:primes ou S:S/P).

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_regle_transition_fac" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "c_TransitionFac" en C sous UNIX.
*******************************************************************************************

	
Parametres:
       @p_taux_parametrage	USHORAT_R		: (BEST..PsULTRT0).
       @p_mt_propose_prm		UAMT_M			: (TCTRULT) calamtprm_m.
       @p_aliment_revise		UAMT_M			: (TFAMLIA) scogloegp_m.
       @p_type_traitement	char(1)		: "P": Prime ou "S":S/P.
	 @p_ctrexp         	datetime     	: (BFAC..TCONTR) date d'expiration contrat
       @p_mode_gestion		char(1) 		: (TCTRULT)	Si as_type_traitement = "P" => admmodprm_ct.
                                                        	Si as_type_traitement = "S" => admmodclm_ct.
             
				
CODE RETOUR : 	@mode_gestion	char(1)

		

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 15/10/1998

Version:

Description: Rajout exploitation de ctrexp_d

*****************************************************/

declare			@erreur		int,
				@aliment_retenu 	UAMT_M,
				@mode_gestion	char(1),
				@ctrexp2		datetime


/*------------------------------------------------
3. Traitement
--------------------------------------------------*/
IF @p_type_traitement = "S"
BEGIN
	IF @p_mode_gestion = "F"
	BEGIN
		select @mode_gestion = @p_mode_gestion  /* on garde le même mode de gestion */
		goto select_final
	END
	ELSE
	BEGIN
		select @mode_gestion = "A"
		goto select_final
	END
END

IF @p_mode_gestion = "F"
BEGIN
	select @mode_gestion = @p_mode_gestion  /* on garde le même mode de gestion */
	goto select_final
END

/* Modif 1 : On passe en "auto" lorsque (prime proposée >= aliment révisé * % issu de TAUTPAR) */
/*           OU lorsque Date d'expiration contrat + 2 ans <= date de traitement                */

/* Date d'expiration contrat + 2 ans */
select @ctrexp2 = dateadd(yy, 2, @p_ctrexp)

IF (@p_mt_propose_prm >= (@p_aliment_revise * @p_taux_parametrage)) or (@ctrexp2 <= getdate())
BEGIN
	select @mode_gestion = "A"
END
ELSE
BEGIN
	select @mode_gestion = "M"
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

exec sp_SCOR_INSPRC 'ESTRT3', 'PtULT_RT3', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RT3') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RT3 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RT3 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RT3
 */
GRANT EXECUTE ON dbo.PtULT_RT3 TO GOMEGA
go

