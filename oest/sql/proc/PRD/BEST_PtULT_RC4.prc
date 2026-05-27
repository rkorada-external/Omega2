
USE BEST
Go

/* DROP PROC dbo.PtULT_RC4 */
IF OBJECT_ID('dbo.PtULT_RC4') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RC4
   PRINT '<<< DROPPED PROC dbo.PtULT_RC4 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RC4
     (
       @p_mode_gestion			char(1),
       @p_mt_propose_sp			dec(20,5),  
       @p_mt_manuel_sp			dec(20,5),
	 @p_mt_retenu_sp_ult		dec(20,5)	=NULL output 
     )
as

/***************************************************

Programme: PtULT_RC4

Fichier script associé : ESTRC4.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

RC4 : Cette règle de choix sinistre "non/traité proportionnel" sert à determiner le
		montant retenu en ultime.

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_regle_choix_sinistre_trt_n" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_RegleChoixSinistreTraitNonProp" en C sous UNIX.
*******************************************************************************************

	
Parametres:
      
       		@p_mode_gestion		char(1) 	: (TCTRULT) admmodclm_ct.
       		@p_mt_propose_sp		dec(20,5)		: (TCTRULT) calamtclm_m.
			@p_mt_manuel_sp		dec(20,5)		: (TCTRULT) entamtclm_m.
	 		@p_mt_retenu_sp_ult	dec(20,5)	=NULL output      
				
CODE RETOUR : 	Variables output

		

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 08/12/1997

Version:

Description: @p_mt_propose_sp, @p_mt_manuel_sp, @p_mt_retenu_sp_ult
		passent du format UAMT_M à dec(18,5), suite au stockage
		de pmlrat_r en 10 -4

_________________
MODIFICATION 2
Auteur: A. Terliska
Date:24/02/1998
Description: Les variables @mt_manuel_sp,	@mt_propose_sp, @mt_retenu_sp_ult,
             @pmd_m, @assiette_prime, @mt_retenu_prm_ult, @prime_reconstitution,
             @prime_burning_cost, @mt_aliment_scor, @mt_aliment100_scor
             ne sont plus déclarées en  dec(18,5), mais en dec(20,5) pour éviter les arithmetic
             overflow dans les cas de montants >= 9 999 999 999 999. (MMA 2534).

*****************************************************/

declare		@erreur		int
			


/*------------------------------------------------
 Traitement
--------------------------------------------------*/
IF @p_mode_gestion = "F" OR @p_mode_gestion = "M"
BEGIN
	select @p_mt_retenu_sp_ult = @p_mt_manuel_sp
END
ELSE
BEGIN
	select @p_mt_retenu_sp_ult = @p_mt_propose_sp
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

exec sp_SCOR_INSPRC 'ESTRC4', 'PtULT_RC4', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RC4') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RC4 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RC4 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RC4
 */
GRANT EXECUTE ON dbo.PtULT_RC4 TO GOMEGA
go

