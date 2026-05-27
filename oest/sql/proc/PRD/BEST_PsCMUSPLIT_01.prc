use BEST
go

/*
 * DROP PROC PsCMUSPLIT_01
 */
IF OBJECT_ID('PsCMUSPLIT_01') IS NOT NULL
BEGIN
    DROP PROC PsCMUSPLIT_01
    PRINT '<<< DROPPED PROC PsCMUSPLIT_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsCMUSPLIT_01

with execute as caller as

/***************************************************

Programme: PsCMUSPLIT_01
Fichier script associé : ESSCIT01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: CGI (C.Soulier) 
Date de creation: 15 octobre 1997
Description du programme: 

		Extraction de la table TCMUSPLIT de BRET
            
Parametres: aucun
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:

_________________
MODIFICATION - Removed dbo and added ‘with execute as caller as’
*****************************************************/

declare @erreur int

select		a.ssd_cf,
		retctr_nf,
		rty_nf,
		retsec_nf,
		ctr_nf,
		uw_nt,
		uwy_nf,
		sec_nf,
		end_nt,
		trncod_cf,
		cnvcur_cf,
		cnvamt_m,
		convert(char(8),acc_d,112)
from bret..tcmusplit a, btrav..testssd b
where a.ssd_cf=b.ssd_cf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCMUSPLIT" 
      return @erreur
   end

return 0
go

IF OBJECT_ID('PsCMUSPLIT_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsCMUSPLIT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsCMUSPLIT_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsCMUSPLIT_01
 */
GRANT EXECUTE ON PsCMUSPLIT_01 TO GOMEGA
go

