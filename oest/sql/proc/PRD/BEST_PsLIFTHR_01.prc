use BEST
go

/* DROP PROC dbo.PsLIFTHR_01
 */
IF OBJECT_ID('dbo.PsLIFTHR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsLIFTHR_01
   PRINT '<<< DROPPED PROC dbo.PsLIFTHR_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsLIFTHR_01
as

/***************************************************
Programme: PsLIFTHR_01
Fichier script associé :
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: J. Ribot
Date de creation: 26/08/2004
Description du programme:
      Sélection d'enregistrement dans TLIFTHR

Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
[001]  08/08/2013   R. CASSIS  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
*****************************************************/

declare @erreur int

Select a.ssd_cf ,
       a.esb_cf,
       a.cur_cf,
       a.amt_m
from BEST..TLIFTHR a, BREF..TBATCHSSD c
Where a.SSD_CF=c.SSD_CF
AND   c.BATCHUSER_CF = suser_name()
and   a.AMT_M = (select max(b.amt_m)
                 from BEST..TLIFTHR b
                 where a.ssd_cf       = b.ssd_cf
                 and   a.esb_cf       = b.esb_cf
                 and   a.cur_cf       = b.cur_cf )

select @erreur = @@error

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TACMTRSH" /* erreur de modification */
   return @erreur
end



return 0
go

/*
 * fin de la procedure
 */

IF OBJECT_ID('dbo.PsLIFTHR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsLIFTHR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsLIFTHR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsLIFTHR_01
 */
GRANT EXECUTE ON dbo.PsLIFTHR_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFTHR_01 TO GDBBATCH
go


