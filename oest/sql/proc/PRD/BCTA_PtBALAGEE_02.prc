use BCTA
go
/*
 * DROP PROC BSTA.PtBALAGEE_02
 */
IF OBJECT_ID('dbo.PtBALAGEE_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PtBALAGEE_02
    PRINT '<<< DROPPED PROC dbo.PtBALAGEE_02 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PtBALAGEE_02
    (
	@p_DATE_T   	datetime,  	/* closing date - origin production */
	@p_FORCE_DTE 	varchar(8), /* closing date - origin user */
	@p_listssd		char(40),  	/* liste des filiales a prendre en compte ou 99 pour toutes les filiales*/
	@p_hostprdsit 	char(04), 	/* recuperation du site geographique ()*/
	@SIMULATION		char        /* [009] mode simultation */
	)
with execute as caller as

/******************************************************************************************

Programme: PtBALAGEE_02

Fichier script associé : BALAGEE2.prc

Domaine : (ES) Estimation infomega

Base principale : BCTA

Version: 1

Auteur: VDE

Date de creation: 06/07/98

Description du programme:

		*************************************************************************************
		RECHERCHE A PARTIR DE LA TABLE TBRGLBALAGEE LES ELEMENTS POUR CONSTITUER LA BALANCE AGEE
					Mise à jour de la table TDEBCRED
		La table TDEBCRED contient aussi les mouvements des compagnies debitrices/creditrices
		mis  à jour dans la procédure PtDEBCRED_01
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
            				le declenchement est gere par l'exploitation.

Commentaires:

_________________
MODIFICATIONS

Auteur          	Date        	Description
van de velde 	29/07/1998  la devise XOF ( ancien franc CFA ) n'existe plus imposer le cours de la monnaie XAF
		          01/12/1998  news parameters DATE_T & FORCE_DTE
		          16/12/1998  Prise en compte du parametre FORCE_DTE si egal à null ou blanc
		          14/06/1999  Modification sur la colonne domaine DMN_CT. on peut avoir:
					                "2    " 2 + 4 blancs ou "2" ( utilisation de la fonction RTRIM )
		          21/06/1999  modifie pour les tests - mis en commentaire du DELETE de BTRAV..TBRGLBALAGEE
		          25/11/1999  Ajout de 2 tranches d'appartenance:
					                    - T1 >= 1085 jours
					                    - 720 =< T2 < 1085
					                    - 365 =< T3 < 720  ( ancienne tranche T1 )
		          04/01/2000  calcul des tranches d'age en mois ( au lieu de jours)
		          10/01/2000  calcul des tranches: modifications des bornes >=
		          01/08/2000  suppression de la création de la table des cours de change ( deja fait dans Balagee3.prc)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    |             |aménagement pour le déclenchement de la balance agée
                |             |le paramétre @p_DATE_T contient la date de cloture (ssaamm30, ssaamm31 ou ssaamm28)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
J. Ribot        | 13/03/2008  |SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 28/03/2008  |spot13056:  Prise en compte de la nouvelle LOCAL_CF pour le traitement de la nouvelle balance agée
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
Prajakta        | 09/09/2013  |Data selection changes (Modification 5)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
Leclerc         | 12/02/2014  |Modification - Removed dbo and added ‘with execute as caller as’
*************************************************************************************************/

DECLARE @datarret   datetime,
		@mth        tinyint,
		@erreur     int,
		@errno      int,
		@errmsg     varchar,
		@tran_imbr  bit,
		@dte        datetime,
		@mth_nf     tinyint,
		@yea_nf     smallint,
 		@RetourProc int,
		@p_FORCE_DTE_OK varchar(8)

SELECT 	@erreur     = 0,
		@errmsg     = '',
		@tran_imbr	= 1


	-- Creation des tables temporaires
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

--IF OBJECT_ID('#TLSTSSD') IS NOT NULL
--  begin
--    PRINT '<<< DROP TABLE #TLSTSSD >>>'
--    DROP TABLE #TLSTSSD
--  end


CREATE TABLE #TDEBCRED(
		SSD_CF       USSD_CF    NOT NULL,
		ESB_CF       UESB_CF    NOT NULL,
		CED_NF	     UCLI_NF    NOT NULL,
    BRK_NF       UCLI_NF    NULL,
    GEMPRMPAY_NF UCLI_NF    NULL,
    KEY_CF       char(1)    NULL,
    PCR_CF       char(8)    NOT NULL,
    TRA_NF	     tinyint    NOT NULL,
    CUR_CF	     UCUR_CF    NULL,
    AMT_M	       UAMT_M     NULL,
    AMTCUR_M     UAMT_M     NULL,
    AMTBALSSD_M  UAMT_M     NULL,
    AMTBALESB_M  UAMT_M     NULL,
		CLODATE_D    DATETIME   DEFAULT getdate(),
		CRE_D        UUPD_D     DEFAULT getdate(),
    LOCAL_CF     CHAR(01) DEFAULT '0' NOT NULL     -- [15036]   ajout colonne 28/03/2008
		)


CREATE TABLE #TBALANAGE(
		SSD_CF		USSD_CF 		NULL,
		ESB_CF		UESB_CF 		NULL,
		CED_NF		UCLI_NF 		NULL,
		BRK_NF		UCLI_NF 		NULL,
		PAY_NF		UCLI_NF 		NULL,
		KEY_CF		UKEY_CF		NULL,
		TRNCOD_CF	              UDETTRS_CF		NULL,
		TRAN_NF	              INT			NULL,
		CUR_CF		UCUR_CF 		NULL,
		AMT_M		UAMT_M 		NOT NULL,
		AMTCV_M	              UAMT_M 		NULL,
		AMTSSD_M	              UAMT_M 		NULL,
		AMTESB_M	              UAMT_M 		NULL,
		BALSHT_D	              datetime		not NULL,
		PCR_CF		CHAR(8)		NULL,
		NBRJOUR	              INT			not NULL
           )

IF @p_FORCE_DTE  = " " or @p_FORCE_DTE  = "null"

-- treatment of DATE_T
--********************
	BEGIN
  select @datarret =  convert(char(8),@p_DATE_T,112)
/****   modif 0010
	select @dte 		= convert(char(8),@p_DATE_T,112)
	select @mth_nf 	= datepart(mm,@dte)	--selected month of DATE_T
	select @yea_nf 	= datepart(yy,@dte)	--selected year of DATE_T
	select @mth_nf 	= @mth_nf - 1
	IF @mth_nf = 0
	   Begin
	   select @mth_nf 	= 12
	   select @yea_nf 	= @yea_nf - 1
	   end
***/
	END
ELSE
-- treatment of FORCE_DTE
--***********************
	BEGIN
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


/***************************************************
 next lines, not used :  last modif 01/08/2000

 --*************************************************
-- research change rate for date parameter
--**************************************************

if ( @mth_nf = 12)

begin
select @mth=1

INSERT INTO BTRAV..TRGLTBRQUOT
select
	SSD_CF = a.SSD_CF,
	CUR_CF = a.CUR_CF,
	EXC_D  = max(a.EXC_D),
	EXC_R  = 0.000
from BREF..TCURQUOT a
,BREF..TBATCHSSD TSSD						-- Modification 5
where a.exc_d = dateadd(dd,-1,convert(datetime,convert(char(8),
			(@yea_nf+1)*10000+@mth*100+01,102)))
and a.ssd_cf = TSSD.ssd_cf           		-- Modification 5
and TSSD.BATCHUSER_CF = suser_name()		-- Modification 5

group by a.SSD_CF, a.CUR_CF
end

else

begin

INSERT INTO BTRAV..TRGLTBRQUOT
select
	SSD_CF = a.SSD_CF,
	CUR_CF = a.CUR_CF,
	EXC_D  = max(a.EXC_D),
	EXC_R  = 0.000
from BREF..TCURQUOT a
,BREF..TBATCHSSD TSSD						-- Modification 5
where a.exc_d = dateadd(dd,-1,convert(datetime,convert(char(8),
			@yea_nf*10000+(@mth_nf+1)*100+01,102)))
and a.ssd_cf = TSSD.ssd_cf           		-- Modification 5
and TSSD.BATCHUSER_CF = suser_name()		-- Modification 5
group by a.SSD_CF, a.CUR_CF
end


update BTRAV..TRGLTBRQUOT
	set EXC_R = a.EXC_R
	from BREF..TCURQUOT a, BTRAV..TRGLTBRQUOT b
	where a.EXC_D = b.EXC_D
	and   a.SSD_CF = b.SSD_CF
	and   a.CUR_CF= b.CUR_CF

-- end of the modifications  01/08/2000
*******************************************************/

--[009]
IF ( @SIMULATION = 'Y')
BEGIN
    select @datarret = @p_FORCE_DTE_OK
END
	-- Gestion de la transaction
	-- *************************

--BEGIN TRAN PtBALAGEE_02

		/* ------------- recherche des mvts acc & retro sur la table tcurtrs   -------*/
		/* -------------            sélection pour les filiales paramétrées    -------*/
		/* -------------            pour les comptes de tiers                  -------*/
		--******************************************************************************

INSERT INTO #TBALANAGE
         (ssd_cf, esb_cf, ced_nf, brk_nf, pay_nf, key_cf, trncod_cf, tran_nf, cur_cf, amt_m,
		amtcv_m, amtssd_m ,amtesb_m , balsht_d, pcr_cf, nbrjour )

   SELECT
 		SSD_CF, ESB_CF, CPY_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRA_NF, CUR_CF, AMTLFT_M, AMTCV_M,
		AMTSSD_M, AMTESB_M, convert(char(6), balsht_d,12), PCR_CF, NBRJOUR
	FROM BTRAV..TBRGLBALAGEE
	WHERE  (
	-- sélection des postes acceptation
	   (TRNCOD_CF IN ( '280100', '280110', '280600')
	   AND rtrim(DMN_CT) = '1') OR

	-- sélection des postes rétrocession
	  (TRNCOD_CF IN ( '280200', '280210')
	  AND rtrim(DMN_CT) = '2') )
	AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )		-- sélection des filiales paramétrées 22/09/98

	-- gestion des erreurs
	--*******************
   select @erreur = @@error
   if @erreur != 0
   	begin
      select @errno = 20020 ,
             @errmsg = "20020 BATCH; Insert #TBALANAGE - 2 : " + convert(varchar(10),@erreur) + ";"
	goto erreur
   	end

		-- Regroupement des postes comptables sous un même code PCR
		-- ********************************************************
 UPDATE #TBALANAGE
	-- postes 280100, 280110 & 280600 dans 41120001 (acceptation)
 	 SET PCR_CF = "41120001"
	 where TRNCOD_CF IN ( '280100', '280110', '280600')

 UPDATE #TBALANAGE
	-- postes 280200 & 280210 dans 41020001 (rétrocession)
 	 SET PCR_CF = "41020001"
	 where TRNCOD_CF IN ( '280200', '280210' )

		-- calcule le nombre de mois entre la date d'arrêté et la date bilan
		-- mise à jour de la tranche d'appartenance dans la table temporaire #TBALANAGE
		-- *****************************************************************************
UPDATE #TBALANAGE
	SET  nbrjour = DATEDIFF (month, balsht_d, convert(char(8), @datarret, 112) )

--ajout vde le 25/11/1999
--=========== debut ========================
UPDATE #TBALANAGE
	-- tranche = 1 pour les dates supérieures à 36 mois
	 SET TRAN_NF = 1
	 where nbrjour >= 36

UPDATE #TBALANAGE
	-- tranche = 2 pour les dates comprises entre 24 mois et 36 mois
	 SET TRAN_NF = 2
	 where nbrjour  < 36 and nbrjour >= 24

--========== f i n =========================

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


		--Cumul des montants sur les critéres suivants:
		--établisement/filiale/tiers/code PCR/tranche/monnaie
		-- **************************************************************************
INSERT  #TDEBCRED
SELECT
 	SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF, SUM(AMT_M),0, 0, 0,
	@datarret, getdate(),
  '0'   -- [15036]   ajout colonne LOCAL_CF 28/03/2008

	FROM	#TBALANAGE
 	GROUP BY SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF
  ORDER BY SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF

	-- gestion des erreurs
	-- ********************
   select @erreur = @@error
   if @erreur != 0
   begin
      select @errno = 20020 ,
             @errmsg = "20020 BATCH; Insert #TBALANAGE - 2 : " + convert(varchar(10),@erreur) + ";"
      goto erreur
   end


SET ARITHABORT NUMERIC_TRUNCATION OFF


		-- conversion du montant au dernier cours connu
		-- ********************************************
UPDATE #TDEBCRED
	SET AMTCUR_M = a.AMT_M * b.EXC_R
	FROM #TDEBCRED a,  BTRAV..TRGLBALAGEQUOT b
	WHERE a.CUR_CF = b.CUR_CF
	AND a.SSD_CF = b.SSD_CF

		--conversion de la monnaie XOF au cours de la monnaie XAF ( maj demandée par j. vaillant)
UPDATE #TDEBCRED
	SET AMTCUR_M = a.AMT_M * b.EXC_R
	FROM #TDEBCRED a, BTRAV..TRGLBALAGEQUOT b
	WHERE a.CUR_CF = 'XOF'
	AND b.CUR_CF = 'XAF'
	AND a.SSD_CF = b.SSD_CF

--select de la table temporaire #TDEBCRED pour la récupération par BCP OUT dans le CHAIN.

select * from   #TDEBCRED

/*------------------------------------------------**
**   DELETED tempory tables                       **
**------------------------------------------------*/

DROP TABLE #TDEBCRED
DROP TABLE #TBALANAGE
DROP TABLE #TLSTSSD

/*------------------------------------------------**
**   DELETED table TBRGLBALAGEE                   **
**------------------------------------------------*/

--DELETE BTRAV..TBRGLBALAGEE


	-- gestion des erreurs

return
	-- *******************
erreur:
   raiserror @errno @errmsg
   ROLLBACK TRAN PtBALAGEE_02

   return @errno
go

IF OBJECT_ID('dbo.PtBALAGEE_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtBALAGEE_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtBALAGEE_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PtBALAGEE_02
 */
GRANT EXECUTE ON dbo.PtBALAGEE_02 TO GOMEGA
go
