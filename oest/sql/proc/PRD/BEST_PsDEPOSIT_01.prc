use BEST
go

use BEST 
go

/*
 * DROP PROC PsDEPOSIT_01
 */
IF OBJECT_ID('PsDEPOSIT_01') IS NOT NULL
BEGIN
    DROP PROC PsDEPOSIT_01
    PRINT '<<< DROPPED PROC PsDEPOSIT_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsDEPOSIT_01
     
with execute as caller as

/***************************************************

Programme: PsDEPOSIT_01

Fichier script associ_ : ESSDEP01.PRC

Domaine : (ES) Estimation

Base principale :BRET

Version: 1

Auteur: ME32 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Selection de tous les enregistrements dans TDEPOSIT

Parametres: 
       

Conditions d'execution: 


Commentaires:
_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description : Removed dbo and added ‘with execute as caller as’

*****************************************************/

declare @erreur int


Select RETCTR_NF, RTY_NF, A.SSD_CF, CLMFUNMOD_CT, 
       CLMFUN_R, URRFUNMOD_CT, URRFUN_R, IBNFUNMOD_CT, IBNFUN_R,
       DEPADM_CT, DEPORI_B, CANDEP_B,
       convert (char(8), CRE_D, 112)
from	BRET..TDEPOSIT A, BTRAV..TESTSSD B
where A.SSD_CF=B.SSD_CF
order	by RETCTR_NF, RTY_NF asc



return 0
go
IF OBJECT_ID('PsDEPOSIT_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsDEPOSIT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC DEPOSIT_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsDEPOSIT_01
 */
GRANT EXECUTE ON PsDEPOSIT_01 TO GOMEGA
go


