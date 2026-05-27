USE BEST
Go

/* DROP PROC dbo.PtULT_RC2 */
IF OBJECT_ID('dbo.PtULT_RC2') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtULT_RC2
   PRINT '<<< DROPPED PROC dbo.PtULT_RC2 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PtULT_RC2
     (
       @p_mode_gestion			char(1),
       @p_mt_propose_sp			dec(20,5),
       @p_mt_manuel_sp			dec(20,5),
	 @p_accadmtyp_ct       		UACCADMTYP_CT,
	 @p_mt_retenu_sp_ult		dec(20,5)	=NULL output
     )
as

/***************************************************

Programme: PtULT_RC2

Fichier script associé : ESTRC2.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34

Date de creation: 26/06/1997

Description du programme:

RC2 : Cette règle de choix sinistre "traité proportionnel" sert à determiner le
	montant retenu en ultime.

*******************************************************************************************
Attention ! : Toutes modif sur cette procédure doit être répercutée sur la fonction
		 "uf_regle_choix_sinistre_trt_p" de l'objet "u_nv_estimation" utilisé par
              l'application estimation, ainsi qu'au niveau du script
              "d_RegleChoixSinistreTraitProp" en C sous UNIX.
*******************************************************************************************


Parametres:

       @p_mode_gestion			char(1) 	: (TCTRULT) admmodclm_ct.
       @p_mt_propose_sp			dec(20,5)	: (TCTRULT) calamtclm_m.
       @p_mt_manuel_sp			dec(20,5)	: (TCTRULT) entamtclm_m.
	@p_accadmtyp_ct       		UACCADMTYP_CT : (TSECTION) accadmtyp_ct.
	 @p_mt_retenu_sp_ult			dec(20,5)	= NULL output

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

_________________
MODIFICATION 3
Auteur      : L.DEBEVER
Date        : 01/09/1999
Description : Prise en compte du type comptable dans l'algorithme :
 		        * Si le mode de gestion est "manuel" ou "forcé", on retient le S/P saisi
		        * Sinon:
			- Si 'type comptable' <> 1, on retient le plus pessimiste du  S/P saisi
			  et du S/P proposé.
			- Si type comptable = 1, on retient le S/P comptable.
_________
MODIFICATION 4
Auteur      : JF VDV
Date        : 16/10/2009
Description :[15043] changement dans l'alimenation du montant des S/P ultimes (inverion du montant propose avec le montant manuel)

*****************************************************/

declare		@erreur		int


------------------------------------------------
-- Traitement
--------------------------------------------------
IF @p_mode_gestion = "F" OR @p_mode_gestion = "M"
BEGIN
	select @p_mt_retenu_sp_ult = @p_mt_manuel_sp
END

ELSE

BEGIN
	IF @p_accadmtyp_ct <> 1
	BEGIN
		IF @p_mt_manuel_sp < @p_mt_propose_sp
			BEGIN
                select @p_mt_retenu_sp_ult = @p_mt_propose_sp
				-- select @p_mt_retenu_sp_ult = @p_mt_manuel_sp   [15043]
			END
		ELSE
			BEGIN
                select @p_mt_retenu_sp_ult = @p_mt_manuel_sp
				-- select @p_mt_retenu_sp_ult = @p_mt_propose_sp  [15043]
			END
	END

	IF @p_accadmtyp_ct = 1
	BEGIN
        select @p_mt_retenu_sp_ult = @p_mt_propose_sp
		-- select @p_mt_retenu_sp_ult = @p_mt_manuel_sp  [15043]
	END

END

--------------------
-- Select de retour
--------------------
select_final:


return 0
go

-- fin de la procedure

--    Insertion dans la table des procedures
-- -------------------------------------------

exec sp_SCOR_INSPRC 'ESTRC2', 'PtULT_RC2', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PtULT_RC2') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PtULT_RC2 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PtULT_RC2 >>>'
go


-- Granting/Revoking Permissions on dbo.PtULT_RC2

GRANT EXECUTE ON dbo.PtULT_RC2 TO GOMEGA
go
