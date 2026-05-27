use BCTA
go

-- DROP PROC PtDEBCRED_03

IF OBJECT_ID('PtDEBCRED_03') IS NOT NULL
BEGIN
    DROP PROC PtDEBCRED_03
    PRINT '<<< DROPPED PROC PtDEBCRED_03 >>>'
END
go


-- creation de la procedure
create procedure PtDEBCRED_03
(
    @p_BLCSHTMTH    int,       -- mois de la date de cloture des SDC à extraire
    @p_BLCSHTYEA    smallint,  -- année de la date de cloture des SDC à extraire
    @p_SIMULATION	char       -- mode simultation    ('Y' or ' ')

)

with execute as caller as
/***************************************************
Programme: PtDEBCRED_03
Fichierscript associé : BCTA_PtDEBCRED_03.prc
Base principale : BCTA
Version: 1
Auteur: van de velde
Date de creation: 30/11/98
Description du programme:

Update the closing date (yyyymmmaa)
control the balance sheet period

Parametres:

    @p_BLCSHTMTH    int,       -- mois de la date de cloture des SDC à extraire
    @p_BLCSHTYEA    smallint,  -- année de la date de cloture des SDC à extraire
    @p_SIMULATION	char       -- mode simultation    ('Y' or ' ')

Conditions d'execution:
Batch asynchrone

MODIFICATIONS:
Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
 Van de velde   | 14/06/2010  |  [19323] - Refonte du déclenchement de la BA  et de la SDC
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
_________________
MODIFICATION   [002]
Description:   Removed dbo and added 'with execute as caller as'
*****************************************************/
-- ---------------
-- Initialization
-- ---------------

declare @erreur         int,
        @RetourProc     int

select @erreur = 0
select @RetourProc = 0

-- **************************************************************
-- Extraction et chargement en table Temporaire de bref..TCURQUOT
-- **************************************************************

truncate table btrav..TRGLBALAGEQUOT
execute bcta..PsBALAGEE_06
                            @p_BLCSHTYEA,
                            @p_BLCSHTMTH,
                            @p_SIMULATION

-- **************************
-- control of the change rate
-- **************************
IF not exists (select 1 from btrav..TRGLBALAGEQUOT )
begin
    select @RetourProc	= 1	-- change rate not update for date parameter
end

SELECT @erreur = @@error
IF @erreur != 0
BEGIN
    raiserror 20010 'ERROR IN THE REQUEST'
END


fin:
-- Récupération de:
-- ============================
-- 1 code retour

     -- 0 ==> OK, green ligth to load Aged
     -- 1 ==> KO, accounting date not validated

SELECT convert(char(01),@RetourProc) + '_'

RETURN

go

IF OBJECT_ID ('PtDEBCRED_03') IS NOT NULL
    PRINT '<<< CREATED PROC PtDEBCRED_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtDEBCRED_03 >>>'
go


-- Granting/Revoking Permissions on PtDEBCRED_03

GRANT EXECUTE ON PtDEBCRED_03  TO GOMEGA
go
