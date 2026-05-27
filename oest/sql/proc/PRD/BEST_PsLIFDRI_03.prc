use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC PsLIFDRI_03
*/

IF OBJECT_ID('PsLIFDRI_03') IS NOT NULL
BEGIN
    DROP PROCEDURE PsLIFDRI_03
    IF OBJECT_ID('PsLIFDRI_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsLIFDRI_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsLIFDRI_03 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsLIFDRI_03
	(
	@p_balshtyea_nf	 smallint,
    @p_balshtmth_nf  tinyint
	)
with execute as caller as

/***************************************************

Programme: PsLIFDRI_03

Fichier script associé : ESSDRI03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME27 avec Infotool version 2.0

Date de creation: 

Description du programme: 

      Extraction de TLIFDRI pour le programme ESIX0061.c

Parametres: 


Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:C.Soulier

Date: 23 janvier 1998

Version:1.0

Description:

Le tri est modifie :  
"order by CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,ACY_NF,CRE_D DESC"
est remplace par :
"order by CTR_NF,END_NT,convert(varchar(3),SEC_NF),UWY_NF,UW_NT,ACY_NF,CRE_D DESC"

La section est donc triee par ordre ascii (ex : 1, 10, 11, 2, 21, 3,....) au lieu d'etre
triee par ordre numerique (ex : 1, 2, 3, 10, 11, 21, ...).
Ceci afin que ce tri soit coherent avec les tris des fichiers de donnees dans les chaines
batch ESID2030.cmd et ESID2040.cmd

_________________
MODIFICATION 2

Auteur:A. BORDET

Date: 10 septembre 1998

Version:2.0

Description:

Ajout du test sur le bilan en cours et modification du CRE_D pour avoir l'heure

_________________
MODIFICATION 3

Auteur:A. BORDET

Date: 18 janvier 1999

Version:2.0

Description:

Ajout du test sur les filiales qui ont demandé le traitement

_________________
MODIFICATION 4

Auteur: G. BUISSON

Date: 05 Septembre 2003

Version:2.0

Description:

   Ajout de la selection sur le mois bilan pour eviter de prendre
   des lignes saisies après le mois en cours dans le cas du
   deblocage des periodes exceptionnelles
_________________
Modification - Removed dbo and added ‘with execute as caller as’
*****************************************************/

SELECT distinct CTR_NF,END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF,
       BALSHEY_NF, BALSHTMTH_NF, AUTUPD_B, COMACC_B, 
       convert(char(8),CRE_D,112) + ' ' + convert(char,CRE_D,108),
       l.SSD_CF, CMT_NT, CREUSR_CF, convert(char,LSTUPD_D,109),
	   LSTUPDUSR_CF
FROM   BEST..TLIFDRI l, BTRAV..TESTSSD e
where  l.SSD_CF        = e.SSD_CF
and    l.BALSHEY_NF    = @p_balshtyea_nf
and    l.BALSHTMTH_NF !> @p_balshtmth_nf
order by CTR_NF, END_NT, convert(varchar(3),SEC_NF), UWY_NF, UW_NT,
         ACY_NF, CRE_D DESC
go

IF OBJECT_ID('PsLIFDRI_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFDRI_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFDRI_03 >>>'
go

/*
 * Granting/Revoking Permissions on PsLIFDRI_02
 */

GRANT EXECUTE ON PsLIFDRI_03 TO GOMEGA
go
GRANT EXECUTE ON PsLIFDRI_03 TO GDBBATCH
go
