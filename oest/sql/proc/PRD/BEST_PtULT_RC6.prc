use BEST
go


USE BEST
Go

/* DROP PROC dbo.PtULT_RC6 */
IF OBJECT_ID('dbo.PtULT_RC6') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RC6
   PRINT '<<< DROPPED PROC dbo.PtULT_RC6 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PtULT_RC6
     (
       @p_mode_gestion			char(1),
       @p_mt_propose_sp			UAMT_M,  
       @p_mt_manuel_sp			UAMT_M,
	 @p_mt_retenu_sp_ult		UAMT_M	=NULL output  
     )
as

/***************************************************

Programme: PtULT_RC6

Fichier script associé : ESTRC6.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 

Date de creation: 26/06/1997

Description du programme: 

RC6 : Cette règle de choix sinistre "facultative" sert à determiner le
	montant retenu en ultime.

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction 
		 "uf_regle_choix_sinistre_fac" de l'objet "u_nv_estimation" utilisé par 
              l'application estimation, ainsi qu'au niveau du script 
              "d_RegleChoixSinistrefac" en C sous UNIX.
*******************************************************************************************

	
Parametres:
      
       		@p_mode_gestion		char(1) 	: (TCTRULT) admmodclm_ct.
       		@p_mt_propose_sp		UAMT_M		: (TCTRULT) calamtclm_m.
			@p_mt_manuel_sp		UAMT_M		: (TCTRULT) entamtclm_m. 
	 		@p_mt_retenu_sp_ult	UAMT_M	=NULL output       
				
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

exec sp_SCOR_INSPRC 'ESTRC6', 'PtULT_RC6', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RC6') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RC6 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RC6 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtULT_RC6
 */
GRANT EXECUTE ON dbo.PtULT_RC6 TO GOMEGA
go

