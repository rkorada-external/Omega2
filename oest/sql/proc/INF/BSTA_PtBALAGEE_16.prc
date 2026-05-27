use BSTA
go

-- DROP PROC dbo.PtBALAGEE_16

IF OBJECT_ID('dbo.PtBALAGEE_16') IS NOT NULL
BEGIN
    DROP PROC dbo.PtBALAGEE_16
    PRINT '<<< DROPPED PROC dbo.PtBALAGEE_16 >>>'
END
go

-- creation de la procedure

create procedure PtBALAGEE_16

(
    @p_FORCE_DTE 	varchar(8),    -- date de l'arreté demandé par les utilisateurs
    @p_LOCAL_CF 	varchar(1)     -- Indicateur 0 = BA date doc, 1= BA date bilan
)
as

/******************************************************************************************
Programme:        PtBALAGEE_16
Fichier script associé : bsta_BALAGEE5.prc
Domaine :         (ES) Estimation infoméga
Base principale : BSTA
Version:          1
Auteur:           VDE
Date de creation: 10/06/2010
Description du programme:

		*************************************************************************************
		RECHERCHE de la date de cloture de la dernière BA
        mise en forme de la date de cloture de la prochaine Balance agée à charger
		*************************************************************************************

Conditions d'execution:   Le traitement est journalier.
                          le déclenchement est géré par l'exploitation (automate).
MODIFICATIONS:
Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
 Van de velde   | 14/06/2010  |  [19323] - Refonte du déclenchement de la BA  et de la SDC
                | 07/10/2010  |  [19323] - Ajout du parametre LOCAL_CF (distinction BA date doc et BA date bilan)
 Prajakta       | 09/09/2013  |  Data selection changes	(Modification 2)		
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------

*************************************************************************************************/

Declare @clodate        datetime,
        @mthclodat      tinyint,
        @yeaclodat      smallint,
        @clodate_new    char(08),
        @clodate_last   char(08)


IF @p_FORCE_DTE = ' ' or @p_FORCE_DTE = 'null'

-- ********************
-- Treatment of DATE_T
-- ********************

BEGIN
    SELECT @clodate = max(T1.CLODATE_D) 
	FROM bsta..TDEBCRED T1,BREF..TBATCHSSD TSSD	-- Modification 2
    WHERE
        T1.tra_nf !=0                              -- Balance Agée
    and datepart(dd,T1.clodate_d) in (28,29,30,31) -- selected day
    and T1.LOCAL_CF = @p_LOCAL_CF                  -- Balance agée selon date doc ou date bilan
	and T1.ssd_cf = TSSD.ssd_cf           		-- Modification 2
	and TSSD.BATCHUSER_CF = suser_name()		-- Modification 2

    -- SELECT  @clodate = '20080129'
    -- SELECT '@clodate = ', @clodate

    -- Calcul de la nouvelle date de cloture (mois suivant)
    -- ====================================================
    select @clodate_last = convert (char(08),@clodate,112) -- stokage de la derniére date de cloture de la BA
    select @clodate = dateadd(mm,1,@clodate)

    select @mthclodat = datepart(mm,@clodate)
    select @yeaclodat = datepart(yy,@clodate)

    -- Quelque soit la fin du mois bilan on prendra tjrs la fin du mois calendaire pour la date de clôture (28,29,30, 31/MM/ssAA)
    -- ==========================================================================================================================
    if datepart(mm,@clodate) = 12
        begin
            select @clodate_new = convert (char(08) , @yeaclodat*10000+@mthclodat*100+31 )
        end
    else
        begin
            select @clodate_new = convert (char(08) , (dateadd(dd,-1,convert(datetime,convert(char(8),@yeaclodat*10000+(@mthclodat+1)*100+01,112))) ),112)
        end
 END
-- ***********************
-- Treatment of FORCE_DTE
-- ***********************

ELSE

    begin
        select @clodate     = convert(char(8),@p_FORCE_DTE,112)
        select @mthclodat   = datepart(mm,@clodate)          -- selected month
        select @yeaclodat   = datepart(yy,@clodate)          -- selected year
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

FIN:
-- select '@yeaclodat      = ', @yeaclodat
-- select '@mthclodat      = ', @mthclodat
-- select '@clodate_new    = ', @clodate_new
-- select '@clodate_last   = ', @clodate_last

-- Récupération de: l'année cloture (SSAA), du mois cloture (MM), de la date cloture à extraire (SSAAMMJJ), de la dernière date cloture existante(SSAAMMJJ)
SELECT convert(varchar,@yeaclodat) + '_' +  convert(varchar,@mthclodat) + '_'
       + convert(varchar,@clodate_new) + '_' + convert(varchar,@clodate_last)  + '_'
RETURN

go
IF OBJECT_ID('dbo.PtBALAGEE_16') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtBALAGEE_16 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtBALAGEE_16 >>>'
go

-- Granting/Revoking Permissions on dbo.PtBALAGEE_16

GRANT EXECUTE ON dbo.PtBALAGEE_16 TO GOMEGA
go
