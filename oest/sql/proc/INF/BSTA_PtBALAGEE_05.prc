use BSTA
go
/*
 * DROP PROC dbo.PtBALAGEE_05
 */
IF OBJECT_ID('dbo.PtBALAGEE_05') IS NOT NULL
BEGIN
    DROP PROC dbo.PtBALAGEE_05
    PRINT '<<< DROPPED PROC dbo.PtBALAGEE_05 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PtBALAGEE_05

    (
	@p_DATE_T   	datetime,  	/* closing date - origin production */
	@p_FORCE_DTE 	varchar(8), /* closing date - origin user */
	@p_listssd		char(40),  	/* liste des filiales à prendre en compte ou 99 pour toutes les filiales*/
	@p_hostprdsit 	char(04), 	/* récupération du site géographique ()*/
	@p_SIMULATION	char        /* [002] Ajout d'un champs supplémentaire pour SIMULATION */
	)
as

/******************************************************************************************
Programme:        PtBALAGEE_05
Fichier script associé : BALAGEE5.prc
Domaine :         (ES) Estimation infoméga
Base principale : BSTA
Version:          1
Auteur:           VDE
Date de creation: 03/12/98
Description du programme:
		*************************************************************************************
		DELETE des elements de la table TDEBCRED pour lesquels la date de cloture est égale à
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
_________________
MODIFICATIONS
Auteur             Date      Description
                16/12/1998   Prise en compte du paramètre FORCE_DTE si égal à null ou blanc
van de velde 	30/12/98     test sur date @p_FORCE_DTE_OK remplacée par  @p_FORCE_DTE
_________________
MODIFICATIONS      [002]
Auteur             Date      Description
D.GATIBELZA     03/12/2002   Mise à jour de TLSTTRT et suppression des enregistrements de TDEBCRED
                             venant de la précédente simulation
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/03/2008  |spot15036: Prise en compte de la nouvelle colonne LOCAL_CF pour le traitement de la nouvelle balance agée

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
        @RetourProc  int

SELECT  @erreur	= 0,
        @errmsg	= '',
        @tran_imbr	= 1


	-- Création des tables temporaires
	-- *******************************
CREATE TABLE #TLSTSSD ( SSD_CF 		USSD_CF 	NOT NULL )

IF OBJECT_ID('#TLSTSSD') IS NOT NULL
    PRINT '<<< CREATED TABLE #TLSTSSD >>>'
ELSE
  begin
    PRINT '<<< FAILED CREATING TABLE #TLSTSSD >>>'
  end

exec @RetourProc=BREF..PtUTILSTSSD_01 @p_listssd

if @@error<>0 or @RetourProc<>0 return
-- les filiales sont maintenant dans #TLSTSSD


/*début  [002] */
----------------------------------------------------------------
--  Suppression des enregistrements des filliales concernées dans TDEBCRED
--  si le traitement précédent était une simulation
--------------------------------------------------------------
delete BSTA..TDEBCRED
  from BSTA..TDEBCRED a,
       BCTA..TLSTTRT b,
       #TLSTSSD c
where a.SSD_CF    = b.SSD_CF
  and a.CLODATE_D = b.BATCH_D    --- ou cre_d à vérifier
  and b.BATCH_LS  = 'ESIH8000'
  and b.SSD_CF    = c.SSD_CF
  and a.LOCAL_CF = '0'  -- [15036] Balance agée référencée avec date bilan

--  Suppression des enregistrements des filliales concernées dans TLSTTRT
  ------------------------------------------------------------------
delete BCTA..TLSTTRT
  from BCTA..TLSTTRT a,
       #TLSTSSD b
where a.BATCH_LS  = 'ESIH8000'
  and a.SSD_CF    = b.SSD_CF

--  Création des enregistrements des filliales concernées dans TLSTTRT
------------------------------------------------------------------
if @p_SIMULATION = "Y"
BEGIN
    insert BCTA..TLSTTRT ( SSD_CF,
                           ESB_CF,
                           BATCH_LS,
                           BATCH_D )
    select SSD_CF, 99, 'ESIH8000', @p_FORCE_DTE
    from #TLSTSSD
END
----------------------------------------------------------------
/*fin  [002] */


-- update clothing date
----------------------

IF @p_FORCE_DTE = " " or @p_FORCE_DTE = "null"
	goto fin
ELSE
	begin
	select @dte 		= convert(char(8),@p_FORCE_DTE,112)
	select @mth_nf	= datepart(mm,@dte)	--selected month
	select @yea_nf	= datepart(yy,@dte)	--selected year
	end


--********************
-- update closing date
--********************
IF ( @mth_nf = 12)

	begin
	select @mth=1
	select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),
			(@yea_nf+1)*10000+@mth*100+01,102)))
	end

else
	select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),
			@yea_nf*10000+(@mth_nf+1)*100+01,102)))



-- Avant mise à jour de la nouvelle extraction, il faut éléminer les mouvements qui existent déja sur TDEBCRED
-- pour la même date d'arrêté ( FORCE_DTE uniquement) et les filiales paramétrées.
DELETE  BSTA..TDEBCRED
	 	WHERE TRA_NF != 0
	 	AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
		AND CLODATE_D = @datarret
    AND LOCAL_CF = '0'   -- [15036] Balance agée référencée avec date bilan

IF @@rowcount > 0
begin
	PRINT '<<< DELETED TABLE BSTA..TDEBCRED (selon date arrêté FORCE_DTE /filiales ) >>>'
end

 COMMIT TRAN PtBALAGEE_02
  return @erreur

/*------------------------------------------------**
**   DELETED tempory tables                       **
**------------------------------------------------*/
DROP TABLE #TLSTSSD

	-- gestion des erreurs
	-- *******************
erreur:
   raiserror @errno @errmsg /* erreur de modification */
   ROLLBACK TRAN PtBALAGEE_05

   return @errno


fin:

go
IF OBJECT_ID('dbo.PtBALAGEE_05') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtBALAGEE_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtBALAGEE_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtBALAGEE_05
 */
GRANT EXECUTE ON dbo.PtBALAGEE_05 TO GOMEGA
go

