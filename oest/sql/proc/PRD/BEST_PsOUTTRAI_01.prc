use BEST
go

/*
 * DROP PROC PsOUTTRAI_01
 */
IF OBJECT_ID('PsOUTTRAI_01') IS NOT NULL
BEGIN
    DROP PROC PsOUTTRAI_01
    PRINT '<<< DROPPED PROC PsOUTTRAI_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsOUTTRAI_01(
	@p_clodat_d		datetime )
with execute as caller as

/***************************************************

Programme: PsOUTTRAI_01
Fichier script associé : ESSOIT01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: CGI (C.Soulier) 
Date de creation: 30 septembre 1997
Description du programme: 

		Extraction de la table TOUTTRAI de BRET
		(table des mouvements saisis ou calcules en attente)
            
Parametres: aucun
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur: M.HA-THUC
Date: 01/07/98
Version:
Description: filtre sur CRE_D <= @p_clodat_d

MODIFICATION 2
Auteur: O.GIRAUX
Date: 03/01/2000
Version:
Description: filtre sur LOB_CF not in (30, 31)

MODIFICATION 3
Description : Removed dbo and added ‘with execute as caller as’

[004] 24/11/2014 R. Cassis :spot:27740 Filter on rty lower than clodat year

*****************************************************/

declare @erreur int

select a.ssd_cf,
		retctr_nf,
		rty_nf,
		plc_nt,
		retsec_nf,
		ctr_nf,
		uw_nt,
		uwy_nf,
		end_nt,
		sec_nf,
		rcl_nf,
		trncod_cf,
		cur_cf,
		trn_m,
		occyea_nf,
		comtra_b,
		accyer_nf
from bret..TOUTTRAI A, btrav..testssd b
where a.ssd_cf=b.ssd_cf
and	convert(char(8),cre_d,112) <= @p_clodat_d
and   A.LOB_CF not in ('30','31')
and   a.comtra_b = 0  -- on ne prend pas les mvts de rachats
and   A.rty_nf <= datepart(yy,@p_clodat_d)  --[004]
   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TOUTTRAI" 
      return @erreur
   end

return 0
go

IF OBJECT_ID('PsOUTTRAI_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsOUTTRAI_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsOUTTRAI_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsOUTTRAI_01
 */
GRANT EXECUTE ON PsOUTTRAI_01 TO GOMEGA
go
GRANT EXECUTE ON PsOUTTRAI_01 TO GDBBATCH
go

