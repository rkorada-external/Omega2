use BSTA
go

-- DROP PROC dbo.PtBALAGEE_17

IF OBJECT_ID('dbo.PtBALAGEE_17') IS NOT NULL
BEGIN
    DROP PROC dbo.PtBALAGEE_17
    PRINT '<<< DROPPED PROC dbo.PtBALAGEE_17 >>>'
END
go


-- creation de la procedure

create procedure PtBALAGEE_17
(
    @p_FORCE_DTE 	varchar(8),     -- date de l'arreté demandé par les utilisateurs
    @p_SSD_CF       USSD_CF         -- filiale à traitée
)

as

/******************************************************************************************
Programme:        PtBALAGEE_17
Fichier script associé : bsta_BALAGEE_17.prc
Domaine :         (ES) Estimation infoméga
Base principale : BSTA
Version:          1
Auteur:           VDE
Date de creation: 10/06/2010
Description du programme:

		*************************************************************************************
		RECHERCHE de la date de cloture de la dernière BA
		RECHERCHE de la date de cloture de la dernière SDC
        mise en forme de la date de cloture de la prochaine SDC à charger
        controler que la nouvelle date de cloture des SDC à charger existe bien en BA
		*************************************************************************************


Conditions d'execution:   Le traitement est journalier.
                          le déclenchement est géré par l'exploitation (automate).
Commentaires:
MODIFICATIONS
Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
 Van de velde   | 14/06/2010  |  [19323] - Refonte du déclenchement de la BA  et de la SDC
                | 07/10/2010  |  [19323] - Ajout filiale pour recherche derniére SDC
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
  Prajakta      | 09/09/2013  |  Data selection changes (Modification 2)
*************************************************************************************************/

Declare
        @clodate_BA     datetime,
        @clodate_SDC    datetime,
        @mthclodat      tinyint,
        @yeaclodat      smallint,
        @clodate_new    char(08),
        @clodate_last   char(08),
        @clodatBA       char(08),
        @RetourProc     int

select @RetourProc = 0


IF @p_FORCE_DTE = ' ' or @p_FORCE_DTE = 'null'

-- ********************
-- Treatment of DATE_T
-- ********************

BEGIN

    -- Recherche de la dernière date de cloture pour la balance agée
    -- =============================================================
    SELECT @clodate_BA = max(T1.CLODATE_D) FROM bsta..TDEBCRED T1
	,BREF..TBATCHSSD TSSD						-- Modification 2
    WHERE
       T1.tra_nf !=0                              -- Balance Agée
    and datepart(dd,T1.clodate_d) in (28,29,30,31) -- selected day
    and T1.LOCAL_CF = '0'                          -- Balance agée référencée avec date bilan
	and T1.ssd_cf = TSSD.ssd_cf           		-- Modification 2
	and TSSD.BATCHUSER_CF = suser_name()		-- Modification 2

--   SELECT '@clodate_BA = ', @clodate_BA

    -- Recherche de la dernière date de cloture pour les Sociétés Débitrices/Créditrices
    -- =================================================================================
    SELECT @clodate_SDC = max(CLODATE_D) FROM bsta..TDEBCRED
    WHERE
        tra_nf = 0                              -- Sociétés Débitrices/Créditrices
    and datepart(dd,clodate_d) in (28,29,30,31) -- selected day     / ignorer les BA par simulation
    and ssd_cf =@p_ssd_cf        --[19323]

--   SELECT '@clodate_SDC = ', @clodate_SDC

    -- Calcul de la nouvelle date de cloture (mois suivant)
    -- ====================================================

    -- stokage de la dernière date de cloture de la SDC
    select @clodate_last = convert (char(08),@clodate_SDC,112)
    select @clodate_SDC = dateadd(mm,1,@clodate_SDC)
    select @mthclodat = datepart(mm,@clodate_SDC)
    select @yeaclodat = datepart(yy,@clodate_SDC)

    -- Quelque soit la fin du mois bilan on prendra tjrs la fin du mois calendaire pour la date de clôture (28,29,30, 31/MM/ssAA)
    if datepart(mm,@clodate_SDC) = 12
        begin
            select @clodate_new = convert (char(08) , @yeaclodat*10000+@mthclodat*100+31 )
        end
    else
        begin
            select @clodate_new = convert (char(08) , (dateadd(dd,-1,convert(datetime,convert(char(8),@yeaclodat*10000+(@mthclodat+1)*100+01,112))) ),112)
        end

    -- TESTS pour validation du traitement (code retour procédure)
    -- ===========================================================
    If   @clodate_new = @clodate_BA
        begin
            select @RetourProc = 1    -- OK le traitement peut continuer
        end

    If   @clodate_new <> @clodate_BA
        begin
            select @RetourProc = 2    -- KO, la balance agée doit exister pour la nouvelle date de cloture à généréer sur SDC
                                      --     ou la date de cloture
        end

END
-- ***********************
-- Treatment of FORCE_DTE
-- ***********************

ELSE

    begin

        -- Controle de l'existence de la balance agée pour FORCE_DTE (la BA doit exister)
        -- =========================================================
        SELECT distinct @clodate_BA = T1.CLODATE_D
        FROM bsta..TDEBCRED T1
		,BREF..TBATCHSSD TSSD						-- Modification 2
        WHERE
            T1.tra_nf !=0                                             -- Balance Agée
        and convert(char(8),@p_FORCE_DTE,112) = T1.CLODATE_D
        and T1.LOCAL_CF = '0'
		and T1.ssd_cf = TSSD.ssd_cf           		-- Modification 2
		and TSSD.BATCHUSER_CF = suser_name()		-- Modification 2
       -- and datepart(dd,clodate_d) in (28,29,30,31)                 -- selected day / ignorer les BA par simulation

        IF convert(varchar,@clodate_BA) = NULL   or convert(varchar,@clodate_BA) = ''
           select @RetourProc  = 4                                   -- fin du traitement, BA not exists
        else
        begin
            select @RetourProc  = 3                                  -- ageing balance exist
            select @clodate_SDC = convert(char(8),@p_FORCE_DTE,112)
            select @mthclodat   = datepart(mm,@clodate_SDC)          -- selected month
            select @yeaclodat   = datepart(yy,@clodate_SDC)          -- selected year
            if @mthclodat = 12
                begin
                    select @clodate_new  = convert (char(08) , @yeaclodat*10000+@mthclodat*100+31 )
                    select @clodate_last = @clodate_new
                end
            else
                begin
                    select @clodate_new = convert (char(08) , (dateadd(dd,-1,convert(datetime,convert(char(8),@yeaclodat*10000+(@mthclodat+1)*100+01,112))) ),112)
                    select @clodate_last = @clodate_new
                end
        end
     end

FIN:

select @clodatBA = convert(char(8),@clodate_BA,112)

-- select '@yeaclodat      = ', @yeaclodat
-- select '@mthclodat      = ', @mthclodat
-- select '@clodate_last   = ', @clodate_last
-- select '@clodate_new    = ', @clodate_new

-- valeurs code retour

     -- 1 ==> OK green ligth to load Aged
     -- 2 ==> KO accounting date not validated
     -- 3 ==> OK FORCE_DTE is used, ageing balance exist
     -- 4 ==> KO FORCE_DTE is used, no ageing balance exist

-- Récupération de:code retour, de l'année cloture (SSAA), du mois cloture (MM), de la date cloture à extraire (SSAAMMJJ), de la dernière date cloture existante(SSAAMMJJ)
SELECT convert(char(01),@RetourProc) + '_' + convert(varchar,@yeaclodat) + '_' +  convert(varchar,@mthclodat) + '_'
       + convert(varchar,@clodate_last) + '_' + convert(varchar,@clodate_new)  + '_' + convert(varchar,@clodatBA)  + '_'
RETURN

go
IF OBJECT_ID('dbo.PtBALAGEE_17') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtBALAGEE_17 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtBALAGEE_17 >>>'
go

-- Granting/Revoking Permissions on dbo.PtBALAGEE_17

GRANT EXECUTE ON dbo.PtBALAGEE_17 TO GOMEGA
go
