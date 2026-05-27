use BEST
go


USE BEST
Go

/* DROP PROC dbo.PtULT_RC5 */
IF OBJECT_ID('dbo.PtULT_RC5') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RC5
   PRINT '<<< DROPPED PROC dbo.PtULT_RC5 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RC5
     (
       @p_mode_gestion			char(1),
       @p_mt_propose_prm			UAMT_M,  
       @p_mt_manuel_prm			UAMT_M,
	 @p_mt_retenu_prm_ult 		UAMT_M=NULL output 
     )
as

/***************************************************

Programme: PtULT_RC5

Fichier script associé : ESTRC5.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

 RC5 : Cette règle de choix primes "facultative" sert à determiner le
	montant retenu en ultime.

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_regle_choix_prime_fac" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_RegleChoixPrimefac" en C sous UNIX.
*******************************************************************************************

	
Parametres:
      
       @p_mode_gestion		char(1) 	: (TCTRULT)	admmodprm_ct.
       @p_mt_propose_prm		UAMT_M		: (TCTRULT) calamtprm_m.
       @p_mt_manuel_prm		UAMT_M		: (TCTRULT) entamtprm_m.
 	 @p_mt_retenu_prm_ult 	UAMT_M=NULL output      
				
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

declare		@erreur			int
		


/*------------------------------------------------
 Traitement
--------------------------------------------------*/
IF @p_mode_gestion = "F" OR @p_mode_gestion = "M"
BEGIN
	select @p_mt_retenu_prm_ult = @p_mt_manuel_prm
END
ELSE
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

exec sp_SCOR_INSPRC 'ESTRC5', 'PtULT_RC5', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RC5') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RC5 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RC5 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RC5
 */
GRANT EXECUTE ON dbo.PtULT_RC5 TO GOMEGA
go

