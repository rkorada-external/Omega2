use BEST
go

use BEST 
go

/*
 * DROP PROC dbo.PsURRDAC_01
 */
IF OBJECT_ID('dbo.PsURRDAC_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsURRDAC_01
    PRINT '<<< DROPPED PROC dbo.PsURRDAC_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsURRDAC_01
     
as

/***************************************************

Programme: PsURRDAC_01

Fichier script associ_ : ESSURR01.PRC

Domaine : (ES) Estimation

Base principale :BCTA

Version: 1

Auteur: ME67

Date de creation: 

Description du programme: 

      Selection de tous les enregistrements dans TURRDAC (BCTA)

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


SELECT CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, DAC1_R, DAC2_R, ACY_NF, 
LSTUPD_D, LSTUPDUSR_CF 
FROM BCTA..TURRDAC 
ORDER BY CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT  

return 0
go
IF OBJECT_ID('dbo.PsURRDAC_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsURRDAC_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.URRDAC_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsURRDAC_01
 */
GRANT EXECUTE ON dbo.PsURRDAC_01 TO GOMEGA
go


