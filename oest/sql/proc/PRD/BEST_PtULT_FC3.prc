use BEST
go


USE BEST
Go

/* DROP PROC dbo.PtULT_FC3 */
IF OBJECT_ID('dbo.PtULT_FC3') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_FC3
   PRINT '<<< DROPPED PROC dbo.PtULT_FC3 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_FC3
     (
             @p_type_chargement		USHORAT_R	,
             @p_assiette_prime		UAMT_M		,
             @p_mt_sinistre_retenu	UAMT_M		,
             @p_taux_effectif_min	USHORAT_R	,
             @p_taux_effectif_max	USHORAT_R	,
             @p_mt_chargement_eff	UAMT_M		,
             @p_taux_chargement_eff	USHORAT_R	,
	       @p_part_scor_courante	USHA_R		,
             @p_part_cedee		USHA_R		,
             @p_part_100_cedee		bit,
		 @p_prime_burning_cost	UAMT_M=NULL output
     )
as

/***************************************************

Programme: PtULT_FC3

Fichier script associé : ESTFC3.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

FC3 : Calcul de la prime de Burning Cost.


*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_calcul_prime_burning_cost" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_calculPrimeBurningCost" en C sous UNIX.
*******************************************************************************************

	
Parametres:
             @p_type_chargement		USHORAT_R	: (TFAMCOTP) suploatyp_ct.
             @p_assiette_prime		UAMT_M		: (Pt_PMD) comptable, révisé, estimé
             @p_mt_sinistre_retenu	UAMT_M		: (PtULT_RC4).
             @p_taux_effectif_min	USHORAT_R	: (TFAMCOTP) prmmineff_r.
             @p_taux_effectif_max	USHORAT_R	: (TFAMCOTP) prmmaxeff_r.
             @p_mt_chargement_eff	UAMT_M		: (TFAMCOTP) prmeffloa_m.
             @p_taux_chargement_eff	USHORAT_R	: (TFAMCOTP) prmeffloa_r.
             @p_part_scor_courante	USHA_R		: (TFAMLIA) cutsha_r.
             @p_part_cedee		USHA_R		: (TFAMLIA) ridsha_r.
             @p_part_100_cedee		bit		: (TFAMLIA) liaridsha_b.
		 @p_prime_burning_cost	UAMT_M=NULL output
                           

	
CODE RETOUR : Variables output

		

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare		@erreur			int,
			/*@prime_burning_cost	UAMT_M,*/
			@ratio_sinistre_assiette	dec(23,8),
			@sinistre_100		UAMT_M




/*--------------------------
Initialisation des variables
---------------------------*/
select @p_prime_burning_cost = 0

IF @p_part_100_cedee = 1 
BEGIN
	select @p_part_cedee = 1
END

/*-----------------------------------------------
 Contrôle des données d'entrée de type "diviseur"
------------------------------------------------*/
IF (@p_part_cedee = 0 OR @p_assiette_prime = 0 OR @p_part_scor_courante = 0)
BEGIN
	goto select_final
END


/*--------------------------------------------------------------
 Traitement 
--------------------------------------------------------------*/
set arithabort numeric_truncation off		/* éviter 'truncation error'	*/

select @sinistre_100 = - (@p_mt_sinistre_retenu / @p_part_cedee) / @p_part_scor_courante
select @ratio_sinistre_assiette = @sinistre_100 / @p_assiette_prime


IF @p_type_chargement = 1 
BEGIN
	/* Chargement multiplicatif -------------*/

	IF (@ratio_sinistre_assiette * @p_taux_chargement_eff) < @p_taux_effectif_min
	BEGIN
		select @p_prime_burning_cost = @p_taux_effectif_min * @p_assiette_prime
	END
	ELSE
	BEGIN
		IF (@ratio_sinistre_assiette * @p_taux_chargement_eff) > @p_taux_effectif_max
		BEGIN			
			select @p_prime_burning_cost = @p_taux_effectif_max * @p_assiette_prime

		END
		ELSE
		BEGIN
			select @p_prime_burning_cost = @ratio_sinistre_assiette * @p_taux_chargement_eff * @p_assiette_prime
		END
	END

END

IF @p_type_chargement = 2 
BEGIN
	/* Chargement additif -------------------*/
				
	IF (@ratio_sinistre_assiette + @p_taux_chargement_eff) < @p_taux_effectif_min
	BEGIN
		select @p_prime_burning_cost = @p_taux_effectif_min * @p_assiette_prime
	END
	ELSE
	BEGIN
		IF (@ratio_sinistre_assiette + @p_taux_chargement_eff) > @p_taux_effectif_max
		BEGIN
			select @p_prime_burning_cost = @p_taux_effectif_max * @p_assiette_prime
		END
		ELSE
		BEGIN
			select @p_prime_burning_cost = (@ratio_sinistre_assiette + @p_taux_chargement_eff) * @p_assiette_prime
		END
	END
END

IF @p_type_chargement = 3
BEGIN
	/* Chargement en montant ----------------*/

	IF ((@sinistre_100 + @p_mt_chargement_eff) / @p_assiette_prime) < @p_taux_effectif_min
	BEGIN
		select @p_prime_burning_cost = @p_taux_effectif_min * @p_assiette_prime
	END
	ELSE
	BEGIN
		IF ((@sinistre_100 + @p_mt_chargement_eff) / @p_assiette_prime) > @p_taux_effectif_max
		BEGIN
			select @p_prime_burning_cost = @p_taux_effectif_max * @p_assiette_prime
		END
		ELSE
		BEGIN
			select @p_prime_burning_cost = @sinistre_100 + @p_mt_chargement_eff
		END
	END
END

IF @p_type_chargement = 4
BEGIN
	/* Chargement sans montant --------------*/

	IF @ratio_sinistre_assiette < @p_taux_effectif_min
	BEGIN
		select @p_prime_burning_Cost = @p_taux_effectif_min * @p_assiette_prime
	END
	ELSE
	BEGIN
		IF @ratio_sinistre_assiette > @p_taux_effectif_max
		BEGIN
			select @p_prime_burning_cost = @p_taux_effectif_max * @p_assiette_prime
		END
		ELSE
		BEGIN
			select @p_prime_burning_cost = @sinistre_100
		END
	END
END


/* Il faut ramener la prime de Burning Cost à la part SCOR -------------------------------*/
select @p_prime_burning_cost = @p_prime_burning_cost * @p_part_cedee * @p_part_scor_courante

/*----------------
 Select de retour 
-----------------*/
select_final:
/*select @prime_burning_cost*/

set arithabort numeric_truncation on	/* remettre 'truncation error'	*/
return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTFC3', 'PtULT_FC3', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_FC3') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_FC3 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_FC3 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_FC3
 */
GRANT EXECUTE ON dbo.PtULT_FC3 TO GOMEGA
go

