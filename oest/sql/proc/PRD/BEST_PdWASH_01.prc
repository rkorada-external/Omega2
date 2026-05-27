USE BEST
Go

/*
 * DROP PROC PdWASH_01 */
IF OBJECT_ID('PdWASH_01') IS NOT NULL
BEGIN
    DROP PROC PdWASH_01
    PRINT '<<< DROPPED PROC PdWASH_01 >>>'
END
go

/*
 * creation de la procedure */
create procedure PdWASH_01

with execute as caller as
/***************************************************
Programme:                  PdWASH_01
Fichier script associé :    ESDWAS01.PRC
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation:           19/06/97
Description du programme:   - Réinitialisation des tables de travail temporaires.

_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:           07/12/2009
Version:        9.1
Description:    ESTDOM15043 Ultimes  Revisions des regles de gestion et corrections de l'écran estimation des ultimes
                - Mise aux normes de la table BTRAV TESTCTRULT devient : BTRAV..EST_ULT_ESEJ1000_TCTRULT et n'est plus supprimée ici.
_________________
Modification - Removed dbo and added ‘with execute as caller as’
*****************************************************/
declare @erreur      int,
        @tran_imbr	  bit
        
select @erreur = 0
select @tran_imbr = 1


/* ------------------------------------------------------------
   Truncate des tables de travail temporaires
 -------------------------------------------------------------- */

-- ****************************************
truncate table BTRAV..TESTCTRLIS

select @erreur = @@error
if @erreur != 0  goto fin


-- ****************************************
truncate table BTRAV..TESTPMDCTR

select @erreur = @@error
if @erreur != 0  goto fin


--[001] -- ****************************************
--[001] truncate table BTRAV..TESTCTRULT
--[001] 
--[001] select @erreur = @@error
--[001] if @erreur != 0  goto fin


-- ****************************************
truncate table BTRAV..TESTRECPAR

select @erreur = @@error
if @erreur != 0  goto fin


-- ****************************************
truncate table BTRAV..TESTEXCCUR

select @erreur = @@error
if @erreur != 0  goto fin


-- ****************************************
truncate table BTRAV..TESTTRSLNK

select @erreur = @@error
if @erreur != 0  goto fin


               
/**********************************************************************************/
return 0

fin:

return 1
go

/*
 * fin de la procedure  */

/*   Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDWAS01', 'PdWASH_01', 'BEST', 'ME69'
go

IF OBJECT_ID('PdWASH_01') IS NOT NULL
    PRINT '<<< CREATED PROC PdWASH_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PdWASH_01 >>>'
go

/*
 * Granting/Revoking Permissions on PdWASH_01 */
GRANT EXECUTE ON PdWASH_01 TO GOMEGA
go

