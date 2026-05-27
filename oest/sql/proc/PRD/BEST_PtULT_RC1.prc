
USE BEST
Go

/* DROP PROC dbo.PtULT_RC1 */
IF OBJECT_ID('dbo.PtULT_RC1') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RC1
   PRINT '<<< DROPPED PROC dbo.PtULT_RC1 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RC1
     (
       @p_mode_gestion			char(1),
       @p_mt_propose_prm			dec(20,5),  
       @p_mt_manuel_prm			dec(20,5),
	 @p_mt_retenu_prm_ult 		dec(20,5)=NULL output 
     )
as

/***************************************************

Programme: PtULT_RC1

Fichier script associé : ESTRC1.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

RC1 : Cette règle de choix primes "traité proportionnel" sert à determiner le
				montant retenu en ultime.

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_regle_choix_prime_trt_p" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_RegleChoixPrimeTraitProp" en C sous UNIX.
*******************************************************************************************

	
Parametres:
      
       @p_mode_gestion		char(1) 	: (TCTRULT)	admmodprm_ct.
       @p_mt_propose_prm		dec(20,5)	: (TCTRULT) calamtprm_m.
	 @p_mt_manuel_prm		dec(20,5)		: (TCTRULT) entamtprm_m. 
	 @p_mt_retenu_prm_ult 	dec(20,5)=NULL output      
				
CODE RETOUR : 	Variables output 

		

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: L.DEBEVER

Date: 08/12/1997

Version:

Description: @p_mt_propose_prm, @p_mt_manuel_prm, @p_mt_retenu_sp_ult
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

declare		@erreur					int

		
/*------------------------------------------------
 Traitement
--------------------------------------------------*/
IF @p_mode_gestion = "F" OR @p_mode_gestion = "M"
BEGIN
	select @p_mt_retenu_prm_ult = @p_mt_manuel_prm
END

IF @p_mode_gestion = "A"
BEGIN
	select @p_mt_retenu_prm_ult = @p_mt_propose_prm
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

exec sp_SCOR_INSPRC 'ESTRC1', 'PtULT_RC1', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RC1') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RC1 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RC1 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RC1
 */
GRANT EXECUTE ON dbo.PtULT_RC1 TO GOMEGA
go

