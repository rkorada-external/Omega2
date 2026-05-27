use BEST
go


USE BEST
Go

/* DROP PROC dbo.PtULT_FC2 */
IF OBJECT_ID('dbo.PtULT_FC2') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_FC2
   PRINT '<<< DROPPED PROC dbo.PtULT_FC2 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_FC2
     (
             @p_mt_retenu_prm_ult	UAMT_M		,
             @p_part_scor_courante	USHA_R		,
             @p_part_cedee		USHA_R		,
             @p_part_100_cedee		bit		,
             @p_taux_prm_variable	bit		,
             @p_taux_effectif_fixe	USHORAT_R	,
             @p_taux_effectif_min	USHORAT_R	,
             @p_taux_effectif_max	USHORAT_R	,
             @p_prm_forfaitaire		bit			
     )
as

/***************************************************

Programme: PtULT_FC2

Fichier script associé : ESTFC2.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

 FC2 : Calcul de aliment assiette "traité non/proportionnel" .


*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_calcul_aliment_assiette_trt_n" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_calculAlimentAssietteTraitNonProp" en C sous UNIX.
*******************************************************************************************

	
Parametres:
             @p_mt_retenu_prm_ult	UAMT_M		: (PtULT_RC3).
             @p_part_scor_courante	USHA_R		: (TFAMLIA) cutsha_r.
             @p_part_cedee		USHA_R		: (TFAMLIA) ridsha_r.
             @p_part_100_cedee		bit		: (TFAMLIA) liaridsha_b.
             @p_taux_prm_variable	bit		: (TFAMCOTP) prmflcrat_b.
             @p_taux_effectif_fixe	USHORAT_R	: (TFAMCOTP) prmfixeff_r.
             @p_taux_effectif_min	USHORAT_R	: (TFAMCOTP) prmmineff_r.
             @p_taux_effectif_max	USHORAT_R	: (TFAMCOTP) prmmaxeff_r.
             @p_prm_forfaitaire		bit		: (TFAMCOTP) flaprm_b.                     

	
CODE RETOUR : @mt_aliment_100_calcule.
              @assiette_revisee

		

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 001

Auteur: ome43

Date: 28/10/1997

Version: 1.1

Description: calcul de l'assiette par rapport à l'aliment 100% : application du taux mini et non du taux moyen

*****************************************************/

declare	@erreur			int,
		@mt_aliment_100_calcule	UAMT_M,
		@assiette_revisee 		UAMT_M,
		@taux_tarification 	USHA_R


/*---------------------------------
 Initialisation des variables 
---------------------------------*/
IF @p_part_100_cedee = 1
BEGIN
		select @p_part_cedee = 1
END

/*-----------------------------------------------
 Contrôle des données d'entrée de type "diviseur"
-----------------------------------------------*/
IF @p_part_cedee = 0 OR @p_part_scor_courante = 0
BEGIN
		select @mt_aliment_100_calcule = 0
		select @assiette_revisee = 0
		goto select_final
END

/*------------------------------------------------------------------------
 En tarification forfaitaire, le montant aliment 100% est calculé à partir 
 du montant retenu de prime ultime.
-------------------------------------------------------------------------*/
IF @p_prm_forfaitaire = 1
BEGIN
	select @mt_aliment_100_calcule = (@p_mt_retenu_prm_ult / @p_part_cedee) / @p_part_scor_courante
	select @assiette_revisee = 0
END
ELSE
BEGIN
	/*---------------------------------------------------------------------------- 
	   Saisie assiette comptable.
	   En tarification non forfaitaire, le montant aliment 100% et le montant de
	   l'assiette révisée sont calculée à partir du montant retenu en prime ultime. 
	-----------------------------------------------------------------------------*/

	/*-----------------------------------
	 Recherche du taux de tarification.
	-----------------------------------*/
	IF @p_taux_prm_variable = 0
	BEGIN
		select @taux_tarification = @p_taux_effectif_fixe
	END
	ELSE
	BEGIN
		/* MODIFICATION 001 */
		/* select @taux_tarification = (@p_taux_effectif_min + @p_taux_effectif_max) / 2 */
		select @taux_tarification = @p_taux_effectif_min
	END
	

	/*-------------------------------------
	 Tarification en prime non forfaitaire.
	--------------------------------------*/
	IF @taux_tarification = 0
	BEGIN
		/* Problème division par zéro */
		select @mt_aliment_100_calcule = 0
		select @assiette_revisee = 0	
	END
	ELSE
	BEGIN
		select @mt_aliment_100_calcule = (@p_mt_retenu_prm_ult / @p_part_cedee) / @p_part_scor_courante
		select @assiette_revisee = @mt_aliment_100_calcule  / @taux_tarification
	END

END

	
/*----------------
 Select de retour 
-----------------*/
select_final:
select @mt_aliment_100_calcule, @assiette_revisee


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTFC2', 'PtULT_FC2', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_FC2') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_FC2 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_FC2 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_FC2
 */
GRANT EXECUTE ON dbo.PtULT_FC2 TO GOMEGA
go

