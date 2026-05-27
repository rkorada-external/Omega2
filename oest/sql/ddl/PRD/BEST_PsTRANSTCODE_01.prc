use BEST
go

use BEST
go

/*
 * DROP PROC PsTRANSTCODE_01
 */
IF OBJECT_ID('PsTRANSTCODE_01') IS NOT NULL
BEGIN
    DROP PROC PsTRANSTCODE_01
    PRINT '<<< DROPPED PROC PsTRANSTCODE_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsTRANSTCODE_01
	
as

/***************************************************

Programme: PsTRANSTCODE_01
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Date de creation: mardi 25 août 2015 
Description du programme: 
 
      Extraction de la table TTRANSTCODE

Parametres: aucun
Conditions d'execution: 
Commentaires: servira en estimation pour la fonction de transformation 
	de poste comptable acceptation en poste retrocession

_________________
MODIFICATION 1
[001] 25/08/2015 -=Dch=-  :spot:29162 impact projet retro sur P&C
*****************************************************/


select 
	TRANSTYP_CF          ,
   	FAMTRAN_CF           ,
   	CTRNAT_CT            ,
   	ACCADMTYP_CT         ,
   	ORIDETTRS_CF         ,
   	TRADETTRS_CF         
from bret..TRTRANSTCODE
order by ORIDETTRS_CF, CTRNAT_CT



go

IF OBJECT_ID('PsTRANSTCODE_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsTRANSTCODE_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsTRANSTCODE_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsTRANSTCODE_01
 */
GRANT EXECUTE ON PsTRANSTCODE_01 TO GOMEGA,GDBBATCH
go

