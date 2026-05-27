use BSTA
go

-- DROP PROC dbo.PtBALAGEE_15

IF OBJECT_ID('dbo.PtBALAGEE_15') IS NOT NULL
BEGIN
    DROP PROC dbo.PtBALAGEE_15
    PRINT '<<< DROPPED PROC dbo.PtBALAGEE_15 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PtBALAGEE_15

    (
	@p_DATE_T   	datetime,   --  closing date - origin production
	@p_FORCE_DTE 	varchar(8), --  closing date - origin user
	@p_listssd		char(40),  	--  liste des filiales à prendre en compte ou 99 pour toutes les filiales
	@p_hostprdsit char(04),   --  récupération du site géographique ()
	@p_SIMULATION	char        --  champs supplémentaire pour SIMULATION
	)
as

/******************************************************************************************
Programme:        PtBALAGEE_15
Fichier script associé : BALAGEE5.prc
Domaine :         (ES) Estimation infoméga
Base principale : BSTA
Version:          1
Auteur:           VDE
Date de creation: 08/02/2008
Description du programme:
		*************************************************************************************
		DELETE des elements de la table bsta..TDEBCRED pour lesquels la date de cloture est égale à
		la date parametre ( FORCE_DTE )
		*************************************************************************************
Parametres:
 	@p_DATE_T
	@p_FORCE_DTE
	@p_listssd
	@p_hostprdsit
Conditions d'execution:   Le traitement est hebdomadaire.
                          le déclenchement est géré par l'exploitation (automate).
Commentaires:
__________________
MODIFICATIONS

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/03/2008  |spot15036: Prise en compte de la nouvelle colonne LOCAL_CF pour le traitement de la nouvelle balance agée
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 28/03/2008  |spot15036: Aménagement du traitement pour une ou plusieurs filiales

MODIFICATION 1 : JBG - 22/08/2013 - DATA SELECTION BASED ON SSD CF/SITE ID
*************************************************************************************************/

DECLARE	@datarret    datetime,
        @mth         tinyint,
        @erreur      int,
        @errno       int,
        @errmsg      varchar,
        @tran_imbr   bit,
        @dte         datetime,
        @mth_nf      tinyint,
        @yea_nf      smallint,
        @RetourProc  int,
        @RetourProc1 int

SELECT  @erreur	= 0,
        @errmsg	= '',
        @tran_imbr	= 1

-- Chargement des filiales en table  #TLSTSSD
--==================================

CREATE TABLE #TLSTSSD
             ( SSD_CF 		USSD_CF 	NOT NULL )

exec @RetourProc1 = bref..PtUTILSTSSD_01
                    @p_listssd

if @@error <> 0 or @RetourProc1 <> 0 return

----------------------------------------------------------------------------
--  Suppression des enregistrements des filliales concernées dans bsta..TDEBCRED
--  si le traitement précédent était une simulation
----------------------------------------------------------------------------
delete bsta..TDEBCRED
  from bsta..TDEBCRED a,
       bcta..TLSTTRT b,
	   BREF..TBATCHSSD TSSD -- MODIFICATION 1

where a.SSD_CF    = b.SSD_CF
  and a.CLODATE_D = b.BATCH_D    --- ou cre_d à vérifier
  and b.BATCH_LS  = 'ESIH8020'
  and b.SSD_CF    in (SELECT  SSD_CF FROM #TLSTSSD) 	-- sélection des filiales paramétrées   vde le 28/03/2008
  and a.LOCAL_CF = '1'   -- [15036] Balance agée référencé avec date du document
  and a.TRA_NF != 0      -- [15036] uniquement les mvts de la balance agée
  AND a.SSD_CF = TSSD.SSD_CF -- MODIFICATION 1
  AND TSSD.BATCHUSER_CF = suser_name() -- MODIFICATION 1

--  Suppression des enregistrements des filliales concernées dans TLSTTRT
--  ------------------------------------------------------------------
delete BCTA..TLSTTRT
  from BCTA..TLSTTRT a ,
       #TLSTSSD b
where a.BATCH_LS  = 'ESIH8020'
  and a.SSD_CF   = b.SSD_CF 	-- sélection des filiales paramétrées  vde le 28/03/2008


--  Création des enregistrements des filliales concernées dans TLSTTRT
--  ------------------------------------------------------------------
if @p_SIMULATION = 'Y'
BEGIN
    insert BCTA..TLSTTRT ( SSD_CF,
                           ESB_CF,
                           BATCH_LS,
                           BATCH_D )
   select SSD_CF, 99, 'ESIH8020', @p_FORCE_DTE
   from #TLSTSSD                               -- sélection des filiales paramétrées  vde le 28/03/2008

END

-- update clothing date
-- ----------------------

IF @p_FORCE_DTE = ' ' or @p_FORCE_DTE = 'null'
	goto fin
ELSE
	begin
	select @dte 		= convert(char(8),@p_FORCE_DTE,112)
	select @mth_nf	= datepart(mm,@dte)	--selected month
	select @yea_nf	= datepart(yy,@dte)	--selected year
	end

-- update closing date
--********************
IF ( @mth_nf = 12)

	begin
	select @mth=1
	select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),(@yea_nf+1)*10000+@mth*100+01,102)))
	end
else
	select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),@yea_nf*10000+(@mth_nf+1)*100+01,102)))

-- Avant mise à jour de la nouvelle extraction, il faut éléminer les mouvements qui existent déja sur bsta..TDEBCRED
-- pour la même date d'arrêté ( FORCE_DTE uniquement) et les filiales paramétrées.
-- ----------------------------------------------------------------------------------------------------------------------
DELETE  bsta..TDEBCRED
	 	WHERE TRA_NF != 0
	 	AND SSD_CF  in (SELECT  SSD_CF FROM #TLSTSSD) 	-- sélection des filiales paramétrées   vde le 28/03/2008
		AND CLODATE_D = @datarret
    and LOCAL_CF = '1'   -- [15036] Balance agée référence avec date du document

IF @@rowcount > 0
begin
	PRINT '<<< DELETED TABLE bsta..TDEBCRED (selon date arrêté FORCE_DTE /filiales ) >>>'
end

 COMMIT TRAN PtBALAGEE_02
  return @erreur

-- gestion des erreurs
-- *******************
erreur:
   raiserror @errno @errmsg /* erreur de modification */
   ROLLBACK TRAN PtBALAGEE_15

   return @errno

fin:

go
IF OBJECT_ID('dbo.PtBALAGEE_15') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtBALAGEE_15 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtBALAGEE_15 >>>'
go

-- Granting/Revoking Permissions on dbo.PtBALAGEE_15

GRANT EXECUTE ON dbo.PtBALAGEE_15 TO GOMEGA
go
