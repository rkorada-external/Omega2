use BREF
go

/* DROP PROC dbo.PsCURQUOT_09
*/
IF OBJECT_ID('dbo.PsCURQUOT_09') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCURQUOT_09
   PRINT '<<< DROPPED PROC dbo.PsCURQUOT_09 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsCURQUOT_09
as

/***************************************************

Programme: PsCURQUOT_09

Fichier script associé : RFSCUR09.PRC

Domaine : (RF) Références

Base principale : BREF

Version: 1

Auteur: ME65 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Sélection d'enregistrement dans TCURQUOT

_________________
MODIFICATION 1
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by sauf le dernier champs
_________________
MODIFICATION    [002]
Auteur:         D.GATIBELZA
Date:           23/06/2008
Version:        8.1
Description:    EDI15180
[003] 27/12/2013 R. cassis :spot:25427 Centralization - suppression proc sp...
*****************************************************/

declare @erreur int


	select
		cur_cf ,
		ssd_cf ,
		convert(smallint,datepart (yy,exc_d)) ,
		exc_r
	from bref..tcurquot
	group by cur_cf , ssd_cf , datepart (yy,exc_d)
	having exc_d = max(exc_d)
  order by cur_cf , ssd_cf , datepart (yy,exc_d)

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCURQUOT" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure
 */

IF OBJECT_ID('dbo.PsCURQUOT_09') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCURQUOT_09 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCURQUOT_09 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCURQUOT_09
 */
GRANT EXECUTE ON dbo.PsCURQUOT_09 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCURQUOT_09 TO GDBBATCH
go

