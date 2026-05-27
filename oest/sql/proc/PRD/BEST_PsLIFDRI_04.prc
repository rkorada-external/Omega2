USE BEST
go
/*
 * DROP PROC dbo.PsLIFDRI_04
 */
IF OBJECT_ID('dbo.PsLIFDRI_04') IS NOT NULL
BEGIN
    DROP PROC dbo.PsLIFDRI_04
    PRINT '<<< DROPPED PROC dbo.PsLIFDRI_04 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsLIFDRI_04
	
as

/***************************************************

Programme: PsLIFDRI_04

Fichier script associé : ESSDRI04.PRC

Domaine : (RT) Rétro

Base principale : BRET

Version: 1

Auteur: ME21 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Extraction de TLIFDRI pour le programme 

Parametres: 


Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/


/* Modification pour CRE_D: ajout de l'heure */

SELECT distinct CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,ACY_NF,BALSHEY_NF,BALSHTMTH_NF,AUTUPD_B,COMACC_B,
	convert(char(8),CRE_D,112) + ' ' + convert(char,CRE_D,108),SSD_CF,CMT_NT,CREUSR_CF,convert(char,LSTUPD_D,109),
	LSTUPDUSR_CF
FROM TLIFDRI
order by CTR_NF,END_NT,SEC_NF,ACY_NF,CRE_D DESC



go
IF OBJECT_ID('dbo.PsLIFDRI_04') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsLIFDRI_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsLIFDRI_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsLIFDRI_04
 */
GRANT EXECUTE ON dbo.PsLIFDRI_04 TO GOMEGA
go

