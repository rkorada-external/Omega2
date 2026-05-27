USE BEST
Go

IF OBJECT_ID('dbo.PsPRINTB_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsPRINTB_01
   PRINT '<<< DROPPED PROC dbo.PsPRINTB_01 >>>'
END
go

create procedure PsPRINTB_01
as

/***************************************************

Programme               : PsPRINTB

Fichier script associé  : BEST_PsPRINTB.PRC

Domaine                 : (ES) Estimation

Base principale         : BREF

Version                 : 1

Auteur                  : Tony RIPERT

Date de creation        :

Description du programme:

      Sélection d'enregistrement dans TPRINTB

Parametres:

Conditions d'execution  :

Commentaires            :

*****************************************************/

declare @erreur int

select distinct a.ssd_cf, b.ssd_ll
from
bref..tprintb a,
bref..tsubsid b
where a.ssd_cf = b.ssd_cf
and   a.CRTTYP_CT = 99
and   a.CRTVAL_LS='ESB_CF'

select @erreur = @@error

if @erreur != 0
begin
   raiserror 20005 "Erreur Selection TPRINTB"
   return @erreur
end

return 0
go

IF OBJECT_ID('dbo.PsPRINTB_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsPRINTB_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsPRINTB_01 >>>'
go

GRANT EXECUTE ON dbo.PsPRINTB_01 TO PUBLIC
go

GRANT EXECUTE ON dbo.PsPRINTB_01 TO GOMEGA
go

