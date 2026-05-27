use BEST
go
/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
/* DROP PROC PsCPLACC_02
 */
IF OBJECT_ID('PsCPLACC_02') IS NOT NULL
   BEGIN
   DROP PROC PsCPLACC_02
   PRINT '<<< DROPPED PROC PsCPLACC_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCPLACC_02
	(
	@p_clodat_d	datetime
	)
with execute as caller as

/***************************************************
Programme: PsCPLACC_02
Fichier script associé : ESSCPL02.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME27 avec Infotool version 2.0 (AUTO)
Date de creation: 
Description du programme: 

      Sélection d'enregistrement dans TCPLACC

Parametres: 
	- libellé d'inventaire

Conditions d'execution: 
Commentaires:

_________________
MODIFICATION 1
Auteur: ANB
Date: 25/11/97
Version:1.1
Description: Sélection des AS pour la filiale 4 à partir du 1/11/97
_________________
MODIFICATION 2
Auteur: Marc HA-THUC
Date: 07/01/98
Version:1.12
Description: Filtre sur le libellé d'inventaire 
_________________
MODIFICATION 3
Auteur: C.Soulier
Date: 15/01/98
Version:1.3
Description: Suppression de la sélection des AS pour la filiale 4 à partir du 1/11/97
_________________
MODIFICATION 4
Auteur: M.Ha-Thuc
Date: 12/03/98
Version:1.4
Description: rajout de la colonne LSTUPD_D
_________________
MODIFICATION 5
Description : Removed dbo and added ‘with execute as caller as’

[006] 31/10/2013 R. Cassis :spot:25427 - Correction nom de champ BATCHUSER_CF pour Centralization O2B
_________________
MODIFICATION 6
Description : Ajout extraction champ RESPROPAG_B

[007] 29/08/2014 S. Behague
_________________
MODIFICATION 7
Description : Ajout extraction champ LSTUPDUSR_CF et Conversion LSTUPD_D dans un format exploitable (YYYYMMDD hh:mm:ss)

[008] 04/12/2015 N. Esse
*****************************************************/


/*SELECT c.SSD_CF,CTR_NF,ACY_NF,SCOSTRMTH_NF,SCOENDMTH_NF
FROM BCTA..TCPLACC c , BTRAV..TESTSSD e
WHERE c.SSD_CF = e.SSD_CF*/

SELECT SSD_CF,
CTR_NF,
ACY_NF,
SCOSTRMTH_NF,
SCOENDMTH_NF,
convert(char(8),LSTUPD_D,112) + ' ' + convert(char(8),LSTUPD_D,108),
RESPROPAG_B,
LSTUPDUSR_CF
FROM BCTA..TCPLACC

where convert(char(8), blcsht_d, 112) <= @p_clodat_d
and SSD_CF in ( select s.SSD_CF from BREF..TBATCHSSD s where BATCHUSER_CF = suser_name() )
order by ctr_nf

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/


IF OBJECT_ID('PsCPLACC_02') IS NOT NULL
   PRINT '<<< CREATED PROC PsCPLACC_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PsCPLACC_02 >>>'
go
/*
 * Granting/Revoking Permissions on PsCPLACC_02
 */
GRANT EXECUTE ON PsCPLACC_02 TO GOMEGA
go
GRANT EXECUTE ON PsCPLACC_02 TO GDBBATCH
go

