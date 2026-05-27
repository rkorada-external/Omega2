use BSTA
go
--
-- DROP PROC dbo.PtDEBCRED_02
--
IF OBJECT_ID('dbo.PtDEBCRED_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PtDEBCRED_02
    PRINT '<<< DROPPED PROC dbo.PtDEBCRED_02 >>>'
END
go

-- creation de la procedure

create procedure PtDEBCRED_02
     (
      @p_DATE_T     datetime,   --closing date
      @p_listssd    char(40)    --liste des filiales a prendre en compte ou 99 pour toutes les filiales
     )
as

/***************************************************

Programme: PtDEBCRED_02

Fichier script associé : BSTA_PtDEBCRED_02.prc

Base principale : BSTA

Version: 00001

Auteur: van de velde
Date de creation: 16/10/2006
Description du programme:
                            control company creditor/debitor exist on TDEBCRED
                            return code value @RetourProc
Parametres:

@p_DATE_T        datetime
@p_listssd       char(40)

Conditions d'execution:
Batch asynchrone
Commentaires:
__________________
MODIFICATIONS

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/03/2008  |spot15036: Prise en compte de la nouvelle colonne LOCAL_CF pour le traitement de la nouvelle balance agée

*****************************************************/
/*----------------*/
/* Initialization */
/*----------------*/
declare
    @erreur     int,
    @clodat     char(08),
    @mth_nf     tinyint,
    @yea_nf     smallint,
    @datarret   datetime,
    @RetourProc char(2),    --SDC = 1 already exist; = 0 not exist
    @mth        tinyint,
    @Ret_Proc   int

select  @erreur = 0
select  @RetourProc = '0'

-- Creation table temporaire
-- ****************************

CREATE TABLE #TLSTSSD
( SSD_CF    USSD_CF   NOT NULL )

exec @Ret_Proc=BREF..PtUTILSTSSD_01 @p_listssd

if @@error<>0 or @Ret_Proc<>0
begin
  select @RetourProc = '2_'
  goto fin
end

-- les filiales sont maintenant dans #TLSTSSD

select  @clodat  = convert(char(8),@p_date_t,112)     -- modif 0001

--**********************
-- control if SDC exist
--**********************

IF  not exists (select 1 from BSTA..TDEBCRED tdebcred
          where  @clodat = convert(char(8), CLODATE_D,112)
             and tdebcred.tra_nf =0  -- SDC
             and tdebcred.SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )   -- sélection des filiales paramétrées
             and LOCAL_CF = '0' )  -- [15036] SDC référencé avec date bilan

  select @RetourProc = '0_' -- SDC not exist
ELSE
  select @RetourProc = '1_' -- SDC already exist

SELECT @erreur = @@error
IF @erreur != 0 raiserror 20010 'ERROR IN THE REQUEST'

FIN:

select @RetourProc
go

IF OBJECT_ID('dbo.PtDEBCRED_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtDEBCRED_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtDEBCRED_02 >>>'
go

--
-- Granting/Revoking Permissions on dbo.PtDEBCRED_02
--
GRANT EXECUTE ON dbo.PtDEBCRED_02  TO GOMEGA
go
