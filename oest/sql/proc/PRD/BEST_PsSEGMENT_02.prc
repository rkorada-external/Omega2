/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/* DROP PROC PsSEGMENT_02
 */
IF OBJECT_ID('PsSEGMENT_02') IS NOT NULL
   BEGIN
   DROP PROC PsSEGMENT_02
   PRINT '<<< DROPPED PROC PsSEGMENT_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSEGMENT_02
	
with execute as caller as

/***************************************************
Programme: PsSEGMENT_02
Fichier script associé : ESSSEG03.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME69 avec Infotool version 2.0 (AUTO)
Date de creation: 
Description du programme: 

      Sélection des lignes de BEST..TSEGMENT pour la version active et le segtyp_ct = 'A'

Parametres: 
Conditions d'execution: 

Commentaires:

_________________
MODIFICATION 1
_________________
Modification - Removed dbo and added ‘with execute as caller as’
[001] 27/12/2013 R. cassis :spot:25427 Centralization - ajout Grant
*****************************************************/


select A.VRS_NF, A.SSD_CF, A.SEGTYP_CT, A.SEG_NF, A.CUR_CF, A.SEGNAT_CT
from   BEST..TSEGMENT A, BTRAV..TESTSSD B
where  A.SEGTYP_CT = 'A'
and 	A.SSD_CF = B.SSD_CF
and 	A.VRS_NF = B.VRS_NF
order by A.SSD_CF


return 0
go

/*
 * fin de la procedure 
 */

IF OBJECT_ID('PsSEGMENT_02') IS NOT NULL
   PRINT '<<< CREATED PROC PsSEGMENT_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PsSEGMENT_02 >>>'
go
/*
 * Granting/Revoking Permissions on PsSEGMENT_02
 */
GRANT EXECUTE ON PsSEGMENT_02 TO GOMEGA
go
GRANT EXECUTE ON PsSEGMENT_02 TO GDBBATCH
go

