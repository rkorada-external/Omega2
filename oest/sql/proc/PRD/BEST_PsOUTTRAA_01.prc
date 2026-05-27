use BEST
go

/*
 * DROP PROC PsOUTTRAA_01
 */
IF OBJECT_ID('PsOUTTRAA_01') IS NOT NULL
BEGIN
    DROP PROC PsOUTTRAA_01
    PRINT '<<< DROPPED PROC PsOUTTRAA_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsOUTTRAA_01(
	@p_clodat_d	datetime )
with execute as caller as

/***************************************************

Programme: PsOUTTRAA_01
Fichier script associé : ESSOAT01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: CGI (C.Soulier) 
Date de creation: 30 septembre 1997
Description du programme: 

		Extraction de la table TOUTTRAA de BRET
		(table des mouvements retro a 100% en attente)
            
Parametres: aucun
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur: M.HA-THUC
Date: 01/07/98
Version: 
Description: filtre sur blcsht_d <= date bilan ( clodat_d )

MODIFICATION 2
Auteur: O.GIRAUX
Date: 03/01/2000
Version: 
Description: filtre sur LOB_CF not in (30, 31)

MODIFICATION 3
Description : Removed dbo and added ‘with execute as caller as’
*****************************************************/

declare @erreur int

select		retctr_nf,
		rty_nf,
		retsec_nf,
		a.ssd_cf,
		ctr_nf,
		end_nt,
		sec_nf,
		uw_nt,
		uwy_nf,
		scostrmth_nf,
		scoendmth_nf,
		accyer_nf,
		convert(char(8),blcsht_d,112),
		clm_nf,
		trncod_cf,
		acpcur_cf,
		ced_m,
		retact_ct,
		occyea_nf
from bret..TOUTTRAA A, BTRAV..TESTSSD B
where A.SSD_CF=B.SSD_CF
and   A.LOB_CF not in ('30','31')
and 	convert(char(8),blcsht_d,112) <= @p_clodat_d


   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TOUTTRAA" 
      return @erreur
   end

return 0
go

IF OBJECT_ID('PsOUTTRAA_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsOUTTRAA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsOUTTRAA_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsOUTTRAA_01
 */
GRANT EXECUTE ON PsOUTTRAA_01 TO GOMEGA
go

