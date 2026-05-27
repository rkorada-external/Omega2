use BCTA
go

-- DROP PROC PtBALAGEE_03

IF OBJECT_ID('PtBALAGEE_03') IS NOT NULL
BEGIN
    DROP PROC PtBALAGEE_03
    PRINT '<<< DROPPED PROC PtBALAGEE_03 >>>'
END
go


-- creation de la procedure
create procedure PtBALAGEE_03
(
    @p_DATE_T		datetime, 	   -- date de l'arreté des écritures réglement fourni par l'exploitation
    @p_FORCE_DTE 	varchar(8),    -- date de l'arreté demandé par les utilisateurs
    @p_SIMULATION	char      ,    -- mode simultation
    @p_BLCSHTYEA    smallint,      -- année de la date de cloture de la BA à extraire
    @p_BLCSHTMTH    int,           -- mois de la date de cloture de la BA à extraire
    @p_CLODATNEW    datetime       -- date de cloture de la BA à extraire
)

with execute as caller as
/***************************************************
Programme: PtBALAGEE_03
Fichierscript associé : BALAGEE3.prc
Base principale : BCTA
Version: 1
Auteur: van de velde
Date de creation: 30/11/98
Description du programme:

Update the closing date (yyyymmmaa)
control the balance sheet period

Parametres:
		@p_DATE_T        datetime,
		@p_FORCE_DTE     varchar(8),
        @p simulation    char,
        @p_BLCSHTYEA     smallint,      -- année de la date de cloture de la BA à extraire
        @p_BLCSHTMTH     int,           -- mois de la date de cloture de la BA à extraire
        @p_CLODATNEW     datetime       -- date de cloture de la BA à extraire
Conditions d'execution:
Batch asynchrone

Commentaires:
_____________________________________________________
MODIFICATION 1
Auteur          	Date        	Description
van de velde 	01/12/1998   news parameters DATE_T & FORCE_DTE
		16/12/1998   Prise en compte du paramètre FORCE_DTE si égal à null ou blanc
_____________________________________________________
MODIFICATION 2
Auteur          	Date        	Description
van de velde 	13/07/2000	change table btrav..TRGLTBRQUOT by btrav..TRGLBALAGEQUOT
				change proc bcta..PsRGLTBR_05 by bcta..PsBALAGEE_06
_____________________________________________________
MODIFICATION [003]
Auteur          	Date        	Description
D.GATIBELZA 	03/12/2002	Ajout du'un paramètre supplémentaire pour le PsBALAGEE_06
                            paramètre: @p_SIMULATION char
_____________________________________________________
MODIFICATION [004]
Auteur          	Date        	Description
JF van de velde 	20/02/2006	  SPOT 12352: Remplacement de la table BREF..TCALEND par BCTA..TBLCSHTD
                                permettre le déclenchement si mois bilan est en plein w.e.
                                si fin mois bilan différent de la fin mois calendaire,
                                prévoir le déclenchement du traitement le week end qui suit la date de fin mois bilan
_____________________________________________________
MODIFICATION [005]
Auteur          	Date        	Description
JF van de velde 	06/06/2006	  SPOT 12352: pour la recherche sur la table BCTA..TBLCSHTD
                                prendre les infos du domaine règlement (DMN_CF=3) au lieu de compta (DMN_CF=1)
_________________
MODIFICATION    [006]
Auteur:         D.GATIBELZA
Date:           02/01/2007
Version:        6.1
Description:    RGL13651 : Correction plantage ESIH8000ESIH8010 pour calcul clôture 4T2006
                - Il faut différencier le cas "mth_nf = 12" des autres.

_________________
MODIFICATION    [007]
Auteur:         JF van de velde
Date:           10/06/2010
Version:        10.1
Description:    [19323]  : Refonte du déclenchement de la BA  et de la SDC
_________________
Description:Removed dbo and added 'with execute as caller as'
*****************************************************/
-- ---------------
-- Initialization
-- ---------------
declare @erreur         int,
        @tran_imbr      bit,
        @dte            datetime,
        @mth_nf         tinyint,
        @yea_nf         smallint,
        @RetourProc     int,
        @mth            tinyint,
        @p_messg        varchar(40),
        @p_datbilan     char(8),
        @ACCOUNT_D      datetime

select @erreur = 0
select @tran_imbr = 1
select @RetourProc = 0

-- ----------------------
-- update clothing date
-- ----------------------
IF @p_FORCE_DTE = ' ' or @p_FORCE_DTE = 'null'

-- ********************
-- Treatment of DATE_T
-- ********************

BEGIN
    -- recherche de la date de comptabilisation (calendrier groupe)
    -- ============================================================
    select @ACCOUNT_D = ACCOUNT_D
    from bref..TCALEND

    WHERE
        BLCSHTYEA_NF = @p_BLCSHTYEA
    and BLCSHTMTH_NF = @p_BLCSHTMTH

    -- la date du jour doit être strictement supérieure à la date de comptabilisation pour le déclenchement de la BA
    -- forcé le code retour à 0
    -- ==============================================================================================================
    IF @p_DATE_T > @ACCOUNT_D
    begin
         SELECT @RetourProc = 1                                     -- OK, green ligth to load Aged
         select @p_datbilan = convert (char(08),@p_CLODATNEW,112 )
         select @mth_nf     = @p_BLCSHTMTH
         select @yea_nf     = @p_BLCSHTYEA

    end

    IF @p_DATE_T <= @ACCOUNT_D
    begin
        SELECT @RetourProc = 2                                      -- KO, accounting date not validated
        goto fin
    end
END

-- ***********************
-- Treatment of FORCE_DTE
-- ***********************

ELSE

BEGIN
    select @RetourProc = 3                                  -- none control ageing balance exist
    select @dte        = convert(char(8),@p_FORCE_DTE,112)
    select @mth_nf     = datepart(mm,@dte)                  -- selected month
    select @yea_nf     = datepart(yy,@dte)                  -- selected year
    if @mth_nf = 12
    begin
        select @p_datbilan = convert (char(08) , @yea_nf*10000+@mth_nf*100+31 )
    end
    else
    begin
        select @p_datbilan = convert (char(08) , (dateadd(dd,-1,convert(datetime,convert(char(8),@yea_nf*10000+(@mth_nf+1)*100+01,112))) ),112)
    end
END

-- **************************************************************
-- Extraction et chargement en table Temporaire de bref..TCURQUOT
-- **************************************************************

truncate table btrav..TRGLBALAGEQUOT
execute BCTA..PsBALAGEE_06
                            @yea_nf,
                            @mth_nf,
                            @p_SIMULATION

-- **************************
-- control of the change rate
-- **************************
IF not exists (select 1 from btrav..TRGLBALAGEQUOT )
begin
    select @RetourProc	= 4	-- change rate not update for date parameter
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

     -- 1 ==> OK, green ligth to load Aged
     -- 2 ==> KO, accounting date not validated
     -- 3 ==> none control ageing balance exist
     -- 4 ==> change rate not update for date parameter

-- 2 la date de cloture pour une demande par DATE_T ou FORCE_DTE

SELECT convert(char(01),@RetourProc) + '_'  + convert(varchar,@p_datbilan)  + '_'

RETURN

go

IF OBJECT_ID ('PtBALAGEE_03') IS NOT NULL
    PRINT '<<< CREATED PROC PtBALAGEE_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtBALAGEE_03 >>>'
go


-- Granting/Revoking Permissions on PtBALAGEE_03

GRANT EXECUTE ON PtBALAGEE_03  TO GOMEGA
go
