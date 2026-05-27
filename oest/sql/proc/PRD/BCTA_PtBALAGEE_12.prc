use BCTA
go

-- DROP PROC BSTA.PtBALAGEE_12

IF OBJECT_ID('PtBALAGEE_12') IS NOT NULL
BEGIN
    DROP PROC PtBALAGEE_12
    PRINT '<<< DROPPED PROC PtBALAGEE_12 >>>'
END
go

-- creation de la procedure

create procedure PtBALAGEE_12
    (
	@p_DATE_T   	datetime,  	  -- closing date - origin production
	@p_FORCE_DTE 	varchar(8),   -- closing date - origin user
	@p_listssd		char(40),   	-- liste des filiales à prendre en compte ou 99 pour toutes les filiales
	@p_hostprdsit char(04), 	  -- récuperation du site geographique
	@SIMULATION		char          -- mode simultation
	)
with execute as caller as

/******************************************************************************************

Programme: PtBALAGEE_12
Fichier script associé : BCTA_PtBALAGEE_12.prc
Domaine : (ES) Estimation infomega
Base principale : BCTA
Version: 1
Auteur: VAN DE VELDE
Date de création: 05/02/2008
Description du programme:

		*************************************************************************************
		RECHERCHE A PARTIR DE LA TABLE TBRGLBALAGEE LES ELEMENTS POUR CONSTITUER LA BALANCE AGEE
		Mise à jour et récupération des lignes de la table #TDEBCRED
		*************************************************************************************

   	- Selection des postes comptables reglements acceptation & retrocession
		- Selection des filiales demandees par le parametre @p_listssd
		- Regroupement des postes comptables en code PCR
		- Conversion des montants au dernier cours connu
		- Calcule de la tranche ( 1, 2, 3, 4, 5 ou 6 ) - nbre de mois entre la date bilan et la date du jour
		- la position du tiers au niveau etablissement et filiale ( debiteur ou crediteur ) est initialisee à zero

Parametres:

 	@p_DATE_T
	@p_FORCE_DTE
	@p_listssd
	@p_hostprdsit

Conditions d'execution:
				Le traitement est hebdomadaire.
        Le declenchement est géré par l'exploitation.

Commentaires:
       le paramétre @p_DATE_T contient la date de cloture (ssaamm30, ssaamm31 ou ssaamm28)

__________________
MODIFICATIONS

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/03/2008  |spot13056: Prise en compte de la nouvelle LOCAL_CF pour le traitement de la nouvelle balance agée
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 28/03/2008  |spot13056: Application du traitement à une ou plusieurs filiales
_________________
MODIFICATION - Removed dbo and added ‘with execute as caller as’
*************************************************************************************************/

DECLARE
    @datarret       datetime,
		@mth            tinyint,
		@erreur         int,
		@errno          int,
		@errmsg         varchar,
		@tran_imbr      bit,
		@dte            datetime,
		@mth_nf         tinyint,
		@yea_nf         smallint,
 		@RetourProc     int,
    @RetourProc1    int,
		@p_FORCE_DTE_OK varchar(8)

SELECT
  	@erreur     = 0,
		@errmsg     = '',
		@tran_imbr	= 1,
    @RetourProc = 0,
    @RetourProc1 = 0

CREATE TABLE #TDEBCRED_2
    (
		SSD_CF       USSD_CF  NOT NULL,
		ESB_CF       UESB_CF  NOT NULL,
		CED_NF	     UCLI_NF  NOT NULL,
    BRK_NF       UCLI_NF  NULL,
    GEMPRMPAY_NF UCLI_NF  NULL,
    KEY_CF       char(1)  NULL,
    PCR_CF       char(8)  NOT NULL,
    TRA_NF	     tinyint  NOT NULL,
    CUR_CF	     UCUR_CF  NULL,
    AMT_M	       UAMT_M   NULL,
    AMTCUR_M     UAMT_M   NULL,
    AMTBALSSD_M  UAMT_M   NULL,
    AMTBALESB_M  UAMT_M   NULL,
		CLODATE_D    DATETIME DEFAULT getdate(),
		CRE_D        UUPD_D   DEFAULT getdate(),
    LOCAL_CF     CHAR(01) DEFAULT '0' NOT NULL     -- [15036]   ajout colonne 20/03/2008
		)


CREATE TABLE #TBALANAGE
    (
		SSD_CF		USSD_CF 		NULL,
		ESB_CF		UESB_CF 		NULL,
		CED_NF		UCLI_NF 		NULL,
		BRK_NF		UCLI_NF 		NULL,
		PAY_NF		UCLI_NF 		NULL,
		KEY_CF		UKEY_CF		  NULL,
		TRNCOD_CF	UDETTRS_CF	NULL,
		TRAN_NF	  INT			    NULL,
		CUR_CF		UCUR_CF 		NULL,
		AMT_M		  UAMT_M 		  NOT NULL,
		AMTCV_M	  UAMT_M 		  NULL,
		AMTSSD_M	UAMT_M 		  NULL,
		AMTESB_M	UAMT_M 		  NULL,
		BALSHT_D	datetime		not NULL,
		PCR_CF		CHAR(8)		  NULL,
		NBRJOUR	  INT			    not NULL
    )

-- Chargement des filiales en table  #TLSTSSD      vde le 28/03/2008
--==================================

CREATE TABLE #TLSTSSD
             ( SSD_CF 		USSD_CF 	NOT NULL )

exec @RetourProc1 = bref..PtUTILSTSSD_01
                    @p_listssd

if @@error <> 0 or @RetourProc1 <> 0 return
-- fin chargement


IF @p_FORCE_DTE  = ' ' or @p_FORCE_DTE  = 'null'
 	BEGIN
  print ' -- treatment of DATE_T'
  select @datarret =  convert(char(8),@p_DATE_T,112)
	END

ELSE
	BEGIN
    print '-- treatment of FORCE_DTE'
	  select @p_FORCE_DTE_OK = convert(char(8),@p_FORCE_DTE,112)
	  select @dte 		= @p_FORCE_DTE_OK
	  select @mth_nf	= datepart(mm,@dte)	--selected month
	  select @yea_nf	= datepart(yy,@dte)	--selected year
    -- update closing date
    -- *******************
    IF ( @mth_nf = 12)
    begin
	    select @mth=1
	    select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),(@yea_nf+1)*10000+@mth*100+01,102)))
	  end
    else
	    select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),@yea_nf*10000+(@mth_nf+1)*100+01,102)))
	END


IF ( @SIMULATION = 'Y')
BEGIN
    select @datarret = @p_FORCE_DTE_OK
END

--		------------- recherche des mvts acc & retro sur la table tcurtrs   -------
--		-------------            sélection pour les filiales paramétrées    -------
--		-------------            pour les comptes de tiers                  -------
--		******************************************************************************

INSERT INTO #TBALANAGE
         (ssd_cf, esb_cf, ced_nf, brk_nf, pay_nf, key_cf, trncod_cf, tran_nf, cur_cf, amt_m,
		amtcv_m, amtssd_m ,amtesb_m , balsht_d, pcr_cf, nbrjour )

   SELECT
 		SSD_CF, ESB_CF, CPY_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRA_NF, CUR_CF, AMTLFT_M, AMTCV_M,
		AMTSSD_M, AMTESB_M, convert(char(6), balsht_d,12), PCR_CF, NBRJOUR
	FROM BTRAV..TBRGLBALAGEE
	WHERE
    SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )		-- sélection des filiales paramétrées    vde le 28/03/2008
    AND
   ( (TRNCOD_CF IN ( '280100', '280110', '280600') AND rtrim(DMN_CT) = '1') OR -- sélection des postes acceptation

	   (TRNCOD_CF IN ( '280200', '280210') AND rtrim(DMN_CT) = '2') ) -- sélection des postes rétrocession

If @@error != 0
   	begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #TBALANAGE - 1 : ' + convert(varchar(10),@erreur) + ';'
	  goto erreur
   	end

PRINT '	-- Regroupement des postes comptables sous un même code PCR '
----------------------------------------------------------------------
 UPDATE #TBALANAGE
	-- postes 280100, 280110 & 280600 dans 41120001 (acceptation)
 	 SET PCR_CF = "41120001"
	 where TRNCOD_CF IN ( '280100', '280110', '280600')

 UPDATE #TBALANAGE
	-- postes 280200 & 280210 dans 41020001 (rétrocession)
 	 SET PCR_CF = "41020001"
	 where TRNCOD_CF IN ( '280200', '280210' )

PRINT 'calcule le nombre de mois entre la date d''arrêté et la date bilan'
PRINT 'mise à jour de la tranche d''appartenance dans la table temporaire #TBALANAGE'
-- *****************************************************************************

UPDATE #TBALANAGE
	SET  nbrjour = DATEDIFF (month, balsht_d, convert(char(8), @datarret, 112) )

UPDATE #TBALANAGE
	-- tranche = 1 pour les dates supérieures à 36 mois
	 SET TRAN_NF = 1
	 where nbrjour >= 36

UPDATE #TBALANAGE
	-- tranche = 2 pour les dates comprises entre 24 mois et 36 mois
	 SET TRAN_NF = 2
	 where nbrjour  < 36 and nbrjour >= 24

UPDATE #TBALANAGE
	-- tranche = 3 pour les dates comprises entre 12 mois et 24 mois
	 SET TRAN_NF = 3
	 where nbrjour < 24 and nbrjour >= 12

UPDATE #TBALANAGE
	-- tranche = 4 pour les dates comprises entre 6 mois et 12 mois
	 SET TRAN_NF = 4
	 where nbrjour  < 12 and nbrjour >= 6

UPDATE #TBALANAGE
	-- tranche = 5 pour les dates comprises entre 3 mois et 6 mois
	SET TRAN_NF = 5
	 where nbrjour  < 6 and  nbrjour >= 3

UPDATE #TBALANAGE
	-- tranche = 6 pour les dates comprises entre 2 mois et 3 mois
	SET TRAN_NF = 6
	 where nbrjour < 3 and  nbrjour >= 2

UPDATE #TBALANAGE
	-- tranche = 7 pour les dates comprises entre 1 mois et 2 mois
	SET TRAN_NF = 7
	 where nbrjour  < 2 and  nbrjour >= 1

UPDATE #TBALANAGE
	-- tranche = 8 pour les dates inferieures ou egales à 1 mois
	SET TRAN_NF = 8
	 where nbrjour < 1


PRINT 'Cumul des montants sur les critéres suivants: '
PRINT 'établisement/filiale/tiers/code PCR/tranche/monnaie'
-- ***********************************************************
INSERT  #TDEBCRED_2

SELECT
 	SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF, SUM(AMT_M),0, 0, 0,
	@datarret, getdate(),
  '1'   -- [15036]   ajout colonne LOCAL_CF 20/03/2008

FROM	#TBALANAGE
GROUP BY SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF
ORDER BY SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF    -- [TRV15180] ajout 20/03/2008  ASE 15

If @@error != 0
   begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #TBALANAGE - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
   end


SET ARITHABORT NUMERIC_TRUNCATION OFF

PRINT '-- conversion du montant au dernier cours connu'
--------------------------------------------------------
UPDATE #TDEBCRED_2
SET AMTCUR_M = a.AMT_M * b.EXC_R
FROM #TDEBCRED_2 a,
     btrav..TRGLBALAGEQUOT b
WHERE a.CUR_CF = b.CUR_CF
AND   a.SSD_CF = b.SSD_CF


PRINT 'select de la table temporaire #TDEBCRED_2 pour la récupération par BCP OUT dans le SHELL ESIH8021'

select * from   #TDEBCRED_2

--   DELETED tempory tables
-- ========================
--DROP TABLE #TDEBCRED_2
--DROP TABLE #TBALANAGE

return

ERREUR:
   raiserror @errno @errmsg
   ROLLBACK TRAN PtBALAGEE_12
   return @errno
go

IF OBJECT_ID('PtBALAGEE_12') IS NOT NULL
    PRINT '<<< CREATED PROC PtBALAGEE_12 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtBALAGEE_12 >>>'
go

-- Granting/Revoking Permissions on PtBALAGEE_12

GRANT EXECUTE ON PtBALAGEE_12 TO GOMEGA
go
