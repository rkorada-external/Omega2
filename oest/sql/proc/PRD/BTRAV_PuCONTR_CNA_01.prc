use BTRAV
go

-- Création de la table temporaire
IF OBJECT_ID('dbo.EST_ESTD2530_TCNATYP') IS NOT NULL
  begin
    drop table dbo.EST_ESTD2530_TCNATYP
    PRINT '<<< drop TABLE dbo.EST_ESTD2530_TCNATYP >>>'
  end
go

CREATE TABLE dbo.EST_ESTD2530_TCNATYP
(
    CTR_NF      UCTR_NF    NOT NULL,
    UWY_NF      smallint   NOT NULL
)
LOCK ALLPAGES
go
GRANT REFERENCES ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
GRANT SELECT ON dbo.EST_ESTD2530_TCNATYP TO GCONSULT
go
GRANT SELECT ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
GRANT INSERT ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
GRANT DELETE ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
GRANT UPDATE ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
IF OBJECT_ID('dbo.EST_ESTD2530_TCNATYP') IS NOT NULL
    PRINT '<<< CREATED TABLE dbo.EST_ESTD2530_TCNATYP >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dbo.EST_ESTD2530_TCNATYP >>>'
go




IF OBJECT_ID('dbo.PuCONTR_CNA_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuCONTR_CNA_01
    IF OBJECT_ID('dbo.PuCONTR_CNA_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuCONTR_CNA_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuCONTR_CNA_01 >>>'
END
go


/*
 * creation de la procedure */
create procedure PuCONTR_CNA_01
as
/***************************************************
Programme: PuCONTR_CNA_01
Fichier script associé : TUCON01.PRC
Domaine : (TR) Traités
Base principale : BTRT
Version: 1
Auteur: J Ribot
Date de creation: 
Description du programme: 
      MaJ CNATYP_CT d'enregistrement dans TCONTR 
_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:           23/06/2008
Version:        8.1
Description:    - TRANS15179 MIGRATION ASE 15  spot créé pour livraison si recompilation
                -- Création préalable de la table temporaire pour permettre la compilation.
*****************************************************/
declare @erreur     int,
        @tran_imbr  bit

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
begin
    select @tran_imbr = 0
    BEGIN TRAN
end
 
update BTRT..TCONTR
   set CNATYP_CT = '1'
from BTRT..TCONTR a, BTRAV..EST_ESTD2530_TCNATYP b
where a.ctr_nf = b.ctr_nf
  and a.uwy_nf = b.uwy_nf


if @tran_imbr = 0
    COMMIT TRAN

return @erreur

fin:
if @tran_imbr = 0
    ROLLBACK TRAN

return @erreur
go

GRANT EXECUTE ON dbo.PuCONTR_CNA_01 TO GOMEGA
go

IF OBJECT_ID('dbo.PuCONTR_CNA_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuCONTR_CNA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuCONTR_CNA_01 >>>'
go

EXEC sp_procxmode 'dbo.PuCONTR_CNA_01','unchained'
go

