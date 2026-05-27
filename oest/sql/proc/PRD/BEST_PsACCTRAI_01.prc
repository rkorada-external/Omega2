use BEST
go

use BEST
go

use BEST
go

/*
 * DROP PROC dbo.PsACCTRAI_01
 */
IF OBJECT_ID('dbo.PsACCTRAI_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsACCTRAI_01
    PRINT '<<< DROPPED PROC dbo.PsACCTRAI_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsACCTRAI_01

as

/***************************************************

Programme: PsACCTRAI_01
Fichier script associé : ESSACI01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: CGI (C.Soulier) 
Date de creation: 30 septembre 1997
Description du programme: 

		Extraction de la table TACCTRAI de BRET
		(table des mouvements saisis ou calcules comptabilises)
            
Parametres: aucun
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
*****************************************************/

declare @erreur int

select		ssd_cf,
		retctr_nf,
		rty_nf,
		plc_nt,
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
		comtra_b		
from bret..tacctrai

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TACCTRAI" 
      return @erreur
   end

return 0
go

IF OBJECT_ID('dbo.PsACCTRAI_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsACCTRAI_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsACCTRAI_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsACCTRAI_01
 */
GRANT EXECUTE ON dbo.PsACCTRAI_01 TO GOMEGA
go

