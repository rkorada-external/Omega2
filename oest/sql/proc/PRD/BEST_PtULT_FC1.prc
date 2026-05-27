use BEST
go


USE BEST
Go

/* DROP PROC dbo.PtULT_FC1 */
IF OBJECT_ID('dbo.PtULT_FC1') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_FC1
   PRINT '<<< DROPPED PROC dbo.PtULT_FC1 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_FC1
     (
       @p_mt_retenu_prm_ult	UAMT_M,
       @p_part_scor_courante	USHA_R,
       @p_part_cedee		USHA_R,
       @p_part_100_cedee		bit
     )
as

/***************************************************

Programme: PtULT_FC1

Fichier script associé : ESTFC1.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

 FC1 : Calcul de l'aliment 100% "traité proportionnel" .


*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_calcul_aliment_100%_trt_p" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_calculAliment100TraitProp" en C sous UNIX.
*******************************************************************************************

	
Parametres:
       @p_mt_retenu_prm_ult	UAMT_M : (PtULT_RC1).
       @p_part_scor_courante	USHA_R : (TFAMLIA) cutsha_r.
       @p_part_cedee		USHA_R : (TFAMLIA) ridsha_r.
       @p_part_100_cedee		bit    : (TFAMLIA) liaridsha_b.
     
				
CODE RETOUR : 	@mt_aliment_100%_calcule.

		

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare		@erreur				int,
			@mt_aliment_100_calcule	 	UAMT_M


/*------------------------------------------------
 Traitement
--------------------------------------------------*/
IF @p_part_100_cedee = 1 
BEGIN
   	select @p_part_cedee = 1
END

/*-------------------------------------------------
 Contrôle des données d'entrée de type "diviseur"
-------------------------------------------------*/
IF @p_part_cedee = 0 OR @p_part_scor_courante = 0
BEGIN
		select @mt_aliment_100_calcule = 0
		goto select_final
END


select @mt_aliment_100_calcule = (@p_mt_retenu_prm_ult / @p_part_cedee) / @p_part_scor_courante

	
/*----------------
 Select de retour 
-----------------*/
select_final:
select @mt_aliment_100_calcule 


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESTFC1', 'PtULT_FC1', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_FC1') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_FC1 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_FC1 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_FC1
 */
GRANT EXECUTE ON dbo.PtULT_FC1 TO GOMEGA
go

