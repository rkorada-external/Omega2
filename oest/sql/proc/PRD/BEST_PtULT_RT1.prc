USE BEST
Go

/* DROP PROC dbo.PtULT_RT1 */
IF OBJECT_ID('dbo.PtULT_RT1') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RT1
   PRINT '<<< DROPPED PROC dbo.PtULT_RT1 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RT1
     (
       @p_exercice				UUWY_NF,
       @p_type_comptable			UACCADMTYP_CT,
       @p_taux_parametrage		USHORAT_R,
       @p_nb_trimestre			tinyint,
       @p_mt_propose_prm			UAMT_M,
       @p_aliment_revise			UAMT_M,
       @p_aliment_estime			UAMT_M,
       @p_type_traitement		char(1),
	@p_mode_gestion  char(1)=NULL output,
       @p_fin_periode_scor		tinyint,
       @p_annee_compte			smallint,
	 @p_top_estimations_terminees 	bit=NULL output,
       @p_categorie_age_contrat  char(6)=NULL output
     )
as

/***************************************************

Programme: PtULT_RT1

Fichier script associé : ESTRT1.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

  RT1 : Cette règle de transition "traité proportionnel" s'applique à la fois au 
		  mode de gestion des primes et au mode de gestion du S/P. 
		  Les algorithmes sont paramètrés en fonction du type de traitements(P:primes ou S:S/P).

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_regle_transition_trt_p" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "c_TransitionTraitProp" en C sous UNIX.
*******************************************************************************************

	
Parametres:
	 @p_exercice			UUWY_NF		: (TSECTION) uwy_nf.
       @p_type_comptable		UACCADMTYP_CT	: (TSECTION) accadmtyp_ct .
       @p_taux_parametrage	USHORAT_R		: (BEST..PsULTRT0).
       @p_nb_trimestre		tinyint		: (BEST..PsULTRT0).
       @p_mt_propose_prm		UAMT_M			: (TCTRULT) calamtprm_m.
       @p_aliment_revise		UAMT_M			: (TFAMLIA) scogloegp_m.
       @p_aliment_estime		UAMT_M   		: (TFAMLIA) scoorgegp_m.
       @p_type_traitement	char(1)		: "P": Prime ou "S":S/P.
       @p_mode_gestion		char(1) 		: (TCTRULT)	Si as_type_traitement = "P" => admmodprm_ct.
                                                        	Si as_type_traitement = "S" => admmodclm_ct.
             
       @p_fin_periode_scor	tinyint 		: (TUNDSTA) scoendmth_nf.
       @p_annee_compte		smallint 		: (TUNDSTA) acy_nf.
	 @p_top_estimations_terminees 	bit=NULL output,
	@p_mode_gestion  char(1)=NULL output,
       @p_categorie_age_contrat  char(6)=NULL output

				
CODE RETOUR : 	variables output
		

Conditions d'execution: 


Commentaires:


*****************************************************/

declare		@erreur				int,
			@rowcount				int,
			@d					tinyint,
			@annee					smallint,
			@mois					tinyint,
			@periode_calculee			char(6),
			@periode_compte_complet		char(6),
			@recent				char(6),
			@ancien				char(6),
			@aliment_retenu			UAMT_M
			

set arithabort numeric_truncation off		/* éviter 'truncation error'	*/

/*----------------------------
2. Initialisation des variables  
-----------------------------*/
select @recent = "RECENT"
select @ancien = "ANCIEN"

/*------------------------------------------------
3. Recherche si le contrat est 'Récent' ou 'Ancien' 
--------------------------------------------------*/

select @d 		= 	convert(tinyint,(@p_nb_trimestre -1 )/4) 
select @annee	=	@p_exercice + @d	
select @mois		=	(@p_nb_trimestre * 3) -(12 * @d)

select @periode_calculee			=	convert(char(4),@annee)          + substring(convert(char(3),@mois + 100),2,2)
select @periode_compte_complet		=	convert(char(4),@p_annee_compte) + substring(convert(char(3),@p_fin_periode_scor + 100),2,2)

select @p_top_estimations_terminees	= 0 


	/*---------------------------------------------------------------------
	3.1 Si le contrat est considéré comme "récent", 
	    le mode de gestion est inchangé si "forcé" sinon passe à "manuel".
	----------------------------------------------------------------------*/
	IF @periode_calculee > @periode_compte_complet
	BEGIN
		IF @p_mode_gestion = "F"
		BEGIN
			select @p_mode_gestion = "F" 
		END
		ELSE
		BEGIN
			select @p_mode_gestion = "M" 
		END
		select @p_categorie_age_contrat = @recent
		goto select_final
	END
	ELSE
	BEGIN
		select @p_categorie_age_contrat = @ancien	
	END


	/* --------------------------------------------------------------------
	3.2 Suite traitement catégorie d'age contrat comme "ancien".
	-----------------------------------------------------------------------*/

		/*----------------------------------------------
		3.2.1	Positionnement de l'indicateur estimation.
		-----------------------------------------------*/
		IF @p_type_comptable = 1 OR @p_type_comptable = 3
		BEGIN
			select @p_top_estimations_terminees	= 1
		END
	

		/*---------------------------------------------- 
		3.2.2 Recherche du mode de gestion 
		-----------------------------------------------*/

		/*---------------------------------------------------------------------
			Si type comptable = 1 : Mode de gestion "automatique" pour la  
			prime et sinistre quel que soit l'état initial du mode de gestion
		----------------------------------------------------------------------*/
		IF	@p_type_comptable = 1 
		BEGIN
			select @p_mode_gestion = "A"
			goto select_final
		END 	

		/*---------------------------------------------------------------------
		Si type comptable = 3 :  Mode de gestion "automatique" pour la 
		prime et sinistre quel que soit l'état initiale du mode de gestion,
		le mode de gestion inchangé pour sinistre si "forcé".
		---------------------------------------------------------------------*/

		IF @p_type_comptable = 3 
		BEGIN

			IF @p_type_traitement = "P" 
				BEGIN
					select @p_mode_gestion = "A"
				END
	
			ELSE

				BEGIN

					IF @p_mode_gestion <> "F" 
					BEGIN
						 select @p_mode_gestion = "A"
					END
				ELSE
					BEGIN
						 select @p_mode_gestion = @p_mode_gestion
					END
			END

			goto select_final
		END
	
		/*--------------------------------------------------------------------
			Mode gestion initial "forcé" : Mode de gestion reste inchangé.
		--------------------------------------------------------------------*/
		IF @p_mode_gestion = "F" 
		BEGIN
			select @p_mode_gestion = "F"
			goto select_final
		END
	
		/*--------------------------------------------------------------------
			 Autre cas : Il faut comparer l'aliment retenu en souscription via 
			 le taux de paramètrage au montant proposé.
		--------------------------------------------------------------------*/
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

	
/*----------------
 Select de retour 
-----------------*/
select_final:

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTRT1', 'PtULT_RT1', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RT1') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RT1 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RT1 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RT1
 */
GRANT EXECUTE ON dbo.PtULT_RT1 TO GOMEGA
go

