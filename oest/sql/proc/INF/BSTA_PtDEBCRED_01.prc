use BSTA
go
/*
 * DROP PROC dbo.PtDEBCRED_01
 */
IF OBJECT_ID('dbo.PtDEBCRED_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PtDEBCRED_01
    PRINT '<<< DROPPED PROC dbo.PtDEBCRED_01 >>>'
END
go

/*
 * creation de la procedure
*/
create procedure PtDEBCRED_01
(
    @p_DATE_T       datetime,   -- closing date  ( date production )
    @p_FORCE_DTE    varchar(8), -- closing date ( date user )
    @p_listssd      char(40),   -- list of subsidiary or '99' for all subsidiary of geosite
    @p_hostprdsit   char(04),   -- récupération du site géographique
    @p_balsheyea_nf char(4),    -- année de la date bilan inventaire
    @p_balshtmth_nf char(2),    -- mois de la date bilan inventaire
    @p_clodat_d     char(8),    -- date de la clôture de l'inventaire
    @SIMULATION		char        -- mode simultation
)
as

/******************************************************************************************

Programme: PtDEBCRED_01
Fichier script associé : DEBCRED1.prc
Domaine : (ES) Estimation infoméga
Base principale : BSTA
Version: 1
Auteur: VDE
Date de creation: 06/07/98
Description du programme:

    *************************************************************************************
    Recherche des postes de comptes à émettre ACEPTATION / RETROCESSION à partir des tables d'arrêté
    TTECLEDA_X & TTECLEDR_X
    Recherche des autres postes ACEPTATION / RETROCESSION à partir des tables comptables
    Mise à jour de la table BSTA..TDEBCRED
    La table TDEBCRED contient aussi les mouvements qui constituent la balance agée mis à jour
    dans la procédure DEBCRED01.PRC
    *************************************************************************************

    Sélection des postes comptables techniques acceptation & rétrocession
    Sélection des filiales demandées par le paramétre @p_listssd
    Regroupement des postes comptables en code PCR
    Conversion des montants au dernier cours connu
    Calcule de la position du tiers au niveau établissement et filiale ( tiers débiteur ou créditeur )
    Mise à jour de la table TDEBCRED aprés "delete" des mouvements débit/crédit ( tra_nf = 0 )

Parametres:

@p_yea_nf
@p_mth_nf
@p_listssd
@p_hostprdsit
@p_balsheyea_nf
@p_balshtmth_nf
@p_clodat_d

Conditions d'execution:
        Cette procédure est à lier à la constitution de tables estimation inventaire
Commentaires:

_________________
MODIFICATIONS

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 27/07/1998  |la devise XOF ( ancien franc CFA ) n'existe plus imposer le cours de la monnaie XAF
                | 16/12/1998  |Prise en compte du paramètre FORCE_DTE si égal à null ou blanc
                | 04/01/1999  |ajout des dépots dommages & vie
                | 14/01/1999  |utilisation de la table temporaire #TPCR - contient les postes acc + retro à sélectionner )
                | 15/01/1999  |Tenir compte de la cédante et du rétrocessionnaire à null dans les tables TTECLEDA & TTECLEDR
                | 25/02/1999  |les postes sinistres au comptant rétro pris à tort 2 fois pcr = 41802156 )
                | 10/03/1999  |pour les comptes retard rétrocession prendre le préfixe 21xxxxx au lieu de 22xxxxxx ( cptes à émettre uniquement)
                | 21/06/1999  |Ajout d'un colonne accept/retro sur la table #TPCR
                | 11/01/2000  |Ajout du test sur l'année bilan pour les tables TTECCLEDA & TTECLEDR
                | 27/06/2000  |Recherche du stock depots A & R sur TACCTRN et TRACCTRN
                | 10/07/2000  |Suppression des colonnes retctr,rty,plc sur #DEPORET1
                | 17/07/2001  |Ajout des tests sur TTECLEDA_D,TTECLEDA_E, TTECLEDA_F, TTECLEDR_D, TTECLEDR_E et TTECLEDR_F
                              |ajout des postes vie 32814300/32815300/42814300/42815300
                | 23/10/2001  |ajout des postes dommages 22100204/22108004--->41800116
                | 19/05/2005  |ajout de 2 codes de regroupement PCR - acceptation 23500105 (32814300/32815300) et rétrocession 17200106 (42814300/42815300)
                | 21/02/2006  |spot 12352 (v1 test) aménagement pour le déclenchement de la balance agée
                              |le paramètre @p_DATE_T contient la date de cloture (ssaamm30, ssaamm31 ou ssaamm28)
                | 06/10/2006  |spot 12352 (v2 tst) aménagement pour le déclenchement de la balance agée
                              |c'est le paramétre @p_clodat_d qui contient la date de cloture mise sous la forme ssaamm30,ssaamm31 ou ssaamm28
                              |plus besoin de faire de calcul savant (remplace le paramètre @p_DATE_T)
modif 017       |-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 17/10/2006  |spot13058 on garde l'historique des situations de chaque cloture
                              |seul le paramètre FORCE_DTE renseigné supprimera la situation existente
                              |seule la recherche des comptes à émettre A & R (#TPCR1)se fera par accès aux tables d'arrété
                              |les postes de dépôts seront toujours extraits de la comptabilité avec une nouvelle table (#TPCR3)
                              |tous les autres postes (#TPCR2) seront maintenant extraits à partir de la comptabilité
modif 018       |-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 07/02/2007  |spot13058 Pour la sélection des compte de tiers sur la B.A. on prendra la date de cloture demandée et non plus le max.
modif 019       |-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 14/02/2007  |spot13058 Eclatement en 2 parties pour la recherche des tables TTECLEDA & TTECLEDR selon le paramètre FORCE_DTE
                              |regroupement des tables #TPCR2 & #TPCR3 dans #TPCR2 ( traitement identique pour tous ces postes avec une seule requête).
                              |pour améliorer les temps de passage, sélection des élts comptables (tacctrn) en 2 étapes.
modif 020       |-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 01/06/2007  |spot13058:comptes de dépôts, ajout des postes acceptation (12851000 & 12852000) et rétrocession (22851000 & 22852000)
modif 021       |-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 11/09/2007  |spot13058:Amélioration des temps d'écution - création d'index TACCTRN + tables temporaires
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
  J. Ribot      | 14/03/2008  |SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 023       |             |
van de velde    | 20/03/2008  |spot15036: Prise en compte de la nouvelle LOCAL_CF (0 = calcul référence date bilan, 1 = calcul référence date document)
                | 02/04/2008  |           la variable LOCAL_CF est définie en char(1)  - modif du test
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 024       |             |
van de velde    | 16/06/2008  |spot15640: Amélioration des performances du traitement des Sociétés Débitrices/Créditrices
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 025       |             |
van de velde    | 03/12/2009  |spot18536: Prise en compte du parametre SIMULATION (permet de rechercher le dernier cours en vigueur quelque soit la date de cloture)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
Mod 026         |             |
Prajakta        | 09/09/2013  |Data selection changes
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 027       |             |
	        | 16/10/2013  |phase1b:removed 'CTR_NF like' and modified query with ssd_cf join
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
**/

PRINT 'CREATION DES TABLES TEMPORAIRES'
--=====================================

CREATE TABLE #TESTTBRQUOT
(
    SSD_CF USSD_CF         NOT NULL,
    CUR_CF UCUR_CF         NOT NULL,
    EXC_D  datetime        NOT NULL,
    EXC_R  ULNGDEC         NOT NULL
)

CREATE TABLE #TLSTSSD  ( SSD_CF	    USSD_CF 	NOT NULL )

CREATE TABLE #DEBCREAC
(
		SSD_CF		USSD_CF	    NULL,
		ESB_CF		UESB_CF	    NULL,
		CED_NF		UCLI_NF	    NULL,
		BRK_NF		UCLI_NF	    NULL,
		PAY_NF		UCLI_NF	    NULL,
		KEY_CF		UKEY_CF	    NULL,
		TRNCOD_CF	UDETTRS_CF	NULL,
		TRAN_NF	INT	            NULL,
		CUR_CF		UCUR_CF	    NULL,
		AMT_M		UAMT_M      NOT NULL,
		AMTCV_M	UAMT_M	        NULL,
		AMTSSD_M	UAMT_M	    NULL,
		AMTESB_M	UAMT_M	    NULL,
		PCR_CF		CHAR(8)	    NULL
)

CREATE TABLE #DEBCRERT
(
		SSD_CF		USSD_CF 		NULL,
		ESB_CF		UESB_CF 		NULL,
		CED_NF		UCLI_NF 		NULL,
		BRK_NF		UCLI_NF 		NULL,
		PAY_NF		UCLI_NF 		NULL,
		KEY_CF		UKEY_CF		NULL,
		TRNCOD_CF	UDETTRS_CF		NULL,
		TRAN_NF	INT			NULL,
		CUR_CF		UCUR_CF 		NULL,
		AMT_M		UAMT_M 		NOT NULL,
		AMTCV_M	UAMT_M 		NULL,
		AMTSSD_M	UAMT_M 		NULL,
		AMTESB_M	UAMT_M 		NULL,
		PCR_CF		CHAR(8)		NULL
)

CREATE TABLE #TCPTIERS
(
		SSD_CF		USSD_CF 		NULL,
		ESB_CF		UESB_CF 		NULL,
		CED_NF		UCLI_NF 		NULL,
		BRK_NF		UCLI_NF 		NULL,
		PAY_NF		UCLI_NF 		NULL,
		KEY_CF		UKEY_CF		NULL,
		TRNCOD_CF	UDETTRS_CF		NULL,
		TRAN_NF	INT			NULL,
		CUR_CF		UCUR_CF 		NULL,
		AMT_M		UAMT_M 		NOT NULL,
		AMTCV_M	UAMT_M 		NULL,
		AMTSSD_M	UAMT_M 		NULL,
		AMTESB_M	UAMT_M 		NULL,
		PCR_CF		CHAR(8)		NULL
)

CREATE TABLE #DEBCREAR
(
		SSD_CF		USSD_CF 		NULL,
		ESB_CF		UESB_CF 		NULL,
		CED_NF		UCLI_NF 		NULL,
		BRK_NF		UCLI_NF 		NULL,
		PAY_NF		UCLI_NF 		NULL,
		KEY_CF		UKEY_CF		NULL,
		TRNCOD_CF	UDETTRS_CF		NULL,
		TRAN_NF	INT			NULL,
		CUR_CF		UCUR_CF 		NULL,
		AMT_M		UAMT_M 		NOT NULL,
		AMTCV_M	UAMT_M 		NULL,
		AMTSSD_M	UAMT_M 		NULL,
		AMTESB_M	UAMT_M 		NULL,
		PCR_CF		CHAR(8)		NULL
)

CREATE TABLE #TDEBCRED
(
		SSD_CF		USSD_CF		NULL,
		ESB_CF		UESB_CF		NULL,
		CED_NF		UCLI_NF		NULL,
		BRK_NF		UCLI_NF		NULL,
		GEMPRMPAY_NF	UCLI_NF		NULL,
		KEY_CF		char(1)		NULL,
		PCR_CF		char(8)		NOT NULL,
		TRA_NF		tinyint		NOT NULL,
		CUR_CF		UCUR_CF		NULL,
		AMT_M		UAMT_M			NULL,
		AMTCUR_M	UAMT_M			NULL,
		AMTBALSSD_M	UAMT_M			NULL,
		AMTBALESB_M	UAMT_M			NULL,
		CLODATE_D	DATETIME		DEFAULT getdate(),
		CRE_D		UUPD_D			DEFAULT getdate(),
    LOCAL_CF     char(1)  DEFAULT '0' NOT NULL               -- JR 20/03/2008
)

CREATE TABLE #DEPOTAC
(
		SSD_CF		USSD_CF 		NULL,
		ESB_CF		UESB_CF 		NULL,
		CED_NF		UCLI_NF 		NULL,
		BRK_NF		UCLI_NF 		NULL,
		PAY_NF		UCLI_NF 		NULL,
		KEY_CF		UKEY_CF		NULL,
		TRNCOD_CF		UDETTRS_CF		NULL,
		TRAN_NF		INT			NULL,
		CUR_CF		UCUR_CF 		NULL,
		AMT_M		UAMT_M 		NOT NULL,
		AMTCV_M		UAMT_M 		NULL,
		AMTSSD_M		UAMT_M 		NULL,
		AMTESB_M		UAMT_M 		NULL,
		PCR_CF		CHAR(8)		NULL
)
-- modif spot15640
--CREATE TABLE #TFNCTRN1
--(
--    TRN_NT       numeric(10,0)     NOT NULL,
--    SSD_CF       USSD_CF           NOT NULL,
--    ESB_CF       UESB_CF           NOT NULL,
--    TRNCOD_CF    UDETTRS_CF        DEFAULT '',
--    LSTUPD_D     UUPD_D            DEFAULT getdate(),
--    MTH_D        UUPD_D            NULL
--)

CREATE TABLE #TFNCTRN2
(
    		TRN_NT           numeric(10,0)     NOT NULL,
	    	SSD_CF           USSD_CF           NOT NULL,
    		ESB_CF           UESB_CF           NOT NULL,
	    	TRNCOD_CF        UDETTRS_CF        DEFAULT '',
	    	LSTUPD_D         UUPD_D            DEFAULT getdate()
)

CREATE TABLE #DEPORET1
		(
		SSD_CF		USSD_CF     NULL,
		ESB_CF		UESB_CF     NULL,
		CED_NF		UCLI_NF     NULL,
		BRK_NF		UCLI_NF     NULL,
		PAY_NF		UCLI_NF     NULL,
		KEY_CF		UKEY_CF     NULL,
		TRNCOD_CF UDETTRS_CF  NULL,
		TRAN_NF   INT         NULL,
		CUR_CF    UCUR_CF     NULL,
		AMT_M     UAMT_M      NOT NULL,
		AMTCV_M   UAMT_M      NULL,
		AMTSSD_M  UAMT_M      NULL,
		AMTESB_M  UAMT_M      NULL,
		PCR_CF    CHAR(8)     NULL

    -- supprimées le 10/07/2000
    --RETCTR_NF		URETCTR_NF		NOT NULL,
    --RTY_NF		UUWY_NF		NOT NULL,
    --PLC_NT		UPLC_NT		NOT NULL
)

CREATE TABLE #DEPORET2
(
		SSD_CF    USSD_CF     NULL,
		ESB_CF    UESB_CF     NULL,
		CED_NF    UCLI_NF     NULL,
		BRK_NF    UCLI_NF     NULL,
		PAY_NF    UCLI_NF     NULL,
		KEY_CF    UKEY_CF     NULL,
		TRNCOD_CF UDETTRS_CF  NULL,
		TRAN_NF   INT         NULL,
		CUR_CF    UCUR_CF     NULL,
		AMT_M     UAMT_M      NOT NULL,
		AMTCV_M   UAMT_M      NULL,
		AMTSSD_M  UAMT_M      NULL,
		AMTESB_M  UAMT_M      NULL,
		PCR_CF    CHAR(8)     NULL
)

CREATE TABLE #TOTESB
(
    SSD_CF    USSD_CF   NULL,
    ESB_CF    UESB_CF   NULL,
    CED_NF    UCLI_NF   NULL,
    BRK_NF    UCLI_NF   NULL,
    PAY_NF    UCLI_NF   NULL,
    KEY_CF    char(1)   NULL,
    AMTCUR_M  UAMT_M    NULL
)

CREATE TABLE #TOTSSD
(
    SSD_CF    USSD_CF   NULL,
    CED_NF    UCLI_NF   NULL,
    BRK_NF    UCLI_NF   NULL,
    PAY_NF    UCLI_NF   NULL,
    KEY_CF    char(1)   NULL,
    AMTCUR_M  UAMT_M    NULL
)

CREATE TABLE #TPCR1
(
    PCR_CF      UDETTRS_CF,
    TRNCOD_CF   UDETTRS_CF,
    DMN_CT      char(1)
)

CREATE TABLE #TPCR2
(
    PCR_CF      UDETTRS_CF,
    TRNCOD_CF   UDETTRS_CF,
    DMN_CT      char(1)
)

-- modif 017 vde le 17/10/2006
CREATE TABLE #TPCR3
(
    PCR_CF      UDETTRS_CF,
    TRNCOD_CF   UDETTRS_CF,
    DMN_CT      char(1)
)

---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--    table #TPCR2
---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

PRINT 'Saisie des postes comptables acceptation & rétrocession et leur correspondance en postes PCR'
--==================================================================================================
-- A1 regroupement PCR = 41812055 		comptes de SAC acceptation vie
INSERT INTO  #TPCR2 VALUES ('41812055', '32841000','1')
INSERT INTO  #TPCR2 VALUES ('41812055', '32842000','1')
-- A2 regroupement PCR = 41120005		comptes de primes différees acceptation
INSERT INTO  #TPCR2 VALUES ('41120005', '12110000','1')
INSERT INTO  #TPCR2 VALUES ('41120005', '12111000','1')
-- A3 regroupement PCR =  41812155		comptes SAC acceptation dommages
INSERT INTO  #TPCR2 VALUES ('41812155', '12841000','1')
INSERT INTO  #TPCR2 VALUES ('41812155', '12842000','1')
-- R1 regroupement PCR =  41802156		comptes de SAC retro dommages
INSERT INTO  #TPCR2 VALUES ('41802156', '22841000','2')
INSERT INTO  #TPCR2 VALUES ('41802156', '22842000','2')
-- R2 regroupement PCR =  41020006		comptes de primes différees rétro
INSERT INTO  #TPCR2 VALUES ('41020006', '22110000','2')
INSERT INTO  #TPCR2 VALUES ('41020006', '22111000','2')
-- R6 regroupement PCR =  41802056		COMPTES SAC RETRO vie
INSERT INTO  #TPCR2 VALUES ('41802056', '42841000','2')
INSERT INTO  #TPCR2 VALUES ('41802056', '42842000','2')

--modif vde le 19/05/2005 - suppression
--INSERT INTO  #TPCR2 VALUES ('23500005', '32814300','1')   --ajout le 17/07/2001
--INSERT INTO  #TPCR2 VALUES ('23500005', '32815300','1')   --ajout le 17/07/2001

---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--   modif 019 - ancienne table #TPCR3 fusionnée dans #TPCR2
---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- A4 regroupement PCR =  23510005		comptes de depots acceptation dommage
INSERT INTO  #TPCR2 VALUES ('23510005', '12812000','1')
INSERT INTO  #TPCR2 VALUES ('23510005', '12813000','1')
INSERT INTO  #TPCR2 VALUES ('23510005', '12814000','1')
INSERT INTO  #TPCR2 VALUES ('23510005', '12814100','1')
INSERT INTO  #TPCR2 VALUES ('23510005', '12814200','1')
INSERT INTO  #TPCR2 VALUES ('23510005', '12815000','1')
INSERT INTO  #TPCR2 VALUES ('23510005', '12815100','1')
INSERT INTO  #TPCR2 VALUES ('23510005', '12815200','1')

INSERT INTO  #TPCR2 VALUES ('23510005', '12851000','1')  -- lignes ajoutées le 01/06/07
INSERT INTO  #TPCR2 VALUES ('23510005', '12852000','1')  --

-- A5 regroupement PCR =  23500005		comptes de depots acceptation vie
INSERT INTO  #TPCR2 VALUES ('23500005', '32810000','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32811000','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32812000','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32813000','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32814000','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32814100','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32814200','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32815000','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32815100','1')
INSERT INTO  #TPCR2 VALUES ('23500005', '32815200','1')
-- R7 regroupement PCR =  17210006		COMPTES DEPOTS RETRO DOMMAGES
INSERT INTO  #TPCR2 VALUES ('17210006', '22812000','2')
INSERT INTO  #TPCR2 VALUES ('17210006', '22813000','2')
INSERT INTO  #TPCR2 VALUES ('17210006', '22814000','2')
INSERT INTO  #TPCR2 VALUES ('17210006', '22814100','2')
INSERT INTO  #TPCR2 VALUES ('17210006', '22814200','2')
INSERT INTO  #TPCR2 VALUES ('17210006', '22815000','2')
INSERT INTO  #TPCR2 VALUES ('17210006', '22815100','2')
INSERT INTO  #TPCR2 VALUES ('17210006', '22815200','2')

INSERT INTO  #TPCR2 VALUES ('17210006', '22851000','2')   -- lignes ajoutées le 01/06/07
INSERT INTO  #TPCR2 VALUES ('17210006', '22852000','2')   --

-- R8 regroupement PCR =  17200006		comptes depots retro vie
INSERT INTO  #TPCR2 VALUES ('17200006', '42810000','2')
INSERT INTO  #TPCR2 VALUES ('17200006', '42811000','2')
INSERT INTO  #TPCR2 VALUES ('17200006', '42812000','2')
INSERT INTO  #TPCR2 VALUES ('17200006', '42813000','2')
INSERT INTO  #TPCR2 VALUES ('17200006', '42814000','2')
INSERT INTO  #TPCR2 VALUES ('17200006', '42814100','2')
INSERT INTO  #TPCR2 VALUES ('17200006', '42815000','2')
INSERT INTO  #TPCR2 VALUES ('17200006', '42815100','2')
-- R9 regroupement PCR =  17200106		comptes de policy retro vie   --modif vde le 19/05/2005 - Ajout d'un poste de regroupement rétrocession
INSERT INTO  #TPCR2 VALUES ('17200106', '42814300','2')
INSERT INTO  #TPCR2 VALUES ('17200106', '42815300','2')
-- A6 regroupement PCR =  23500105		comptes de policy dommage    -- modif vde le 19/05/2005 - Ajout d'un nouveau code de regroupement
INSERT INTO  #TPCR2 VALUES ('23500105', '32814300','1')
INSERT INTO  #TPCR2 VALUES ('23500105', '32815300','1')

--modif vde le 19/05/2005 - suppression
--INSERT INTO  #TPCR2 VALUES ('17200006', '42814300','2') --ajout le 17/07/2001
--INSERT INTO  #TPCR2 VALUES ('17200006', '42815300','2') --ajout le 17/07/2001

---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--    table #TPCR1
---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- R3 regroupement PCR =  41800116		comptes à émettre primes retro
INSERT INTO  #TPCR1 VALUES ('41800116', '21100004','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21100104','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21104004','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21104104','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21107004','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21107104','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21101104','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21101204','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21101304','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21101404','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21102004','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21102104','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21102204','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21102304','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21102404','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21102504','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21300004','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21300104','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21301004','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21301104','2')
INSERT INTO  #TPCR1 VALUES ('41800116', '21100204','2')   --ajout le 23/10/2001
INSERT INTO  #TPCR1 VALUES ('41800116', '21108004','2')   --ajout le 23/10/2001
-- R4 regroupement PCR =  41800126		comptes à émettre charges retro
INSERT INTO  #TPCR1 VALUES ('41800126', '21120004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21120104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21120204','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21120304','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21120404','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21121004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21121104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21122004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21122104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21122204','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21122304','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21122404','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21130004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21140004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21140104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21150004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21150104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21150204','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21150304','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21150404','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21150504','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21150604','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21151004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21151104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21310004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21310104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21310204','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21310304','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21311004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21311104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21312004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21312104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21313004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21313104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21450004','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21450104','2')
INSERT INTO  #TPCR1 VALUES ('41800126', '21450204','2')
-- R5 regroupement PCR =  41800136		comptes à émettre sinistres RETRO
INSERT INTO  #TPCR1 VALUES ('41800136', '21200004','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21200104','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21200404','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21200504','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21200604','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21200704','2')
INSERT INTO	 #TPCR1 VALUES ('41800136', '21207004','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21320004','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21320104','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21320204','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21320304','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21321004','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21321104','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21321204','2')
INSERT INTO  #TPCR1 VALUES ('41800136', '21321304','2')

PRINT 'Déclaration des paramètres'
--=================================

DECLARE   @erreur	int,
          @errno	int,
          @errmsg	varchar,
          @tabcibleA_cf	char(20),
          @tabcibleR_cf	char(20),
          @tran_imbr	bit,
          @RetourProc	int,
          @datarret	datetime,
          @dte		datetime,
          @mth		int,
          @mth_nf	tinyint,
          @yea_nf	smallint,
          @p_FORCE_DTE_OK varchar(8)

SELECT  @erreur     = 0,
        @errmsg     = '',
        @tran_imbr  = 1

PRINT 'mise en table de la liste des filiales passée par paramétre'
--==================================================================
EXEC @RetourProc=BREF..PtUTILSTSSD_01 @p_listssd

if @@error<>0 or @RetourProc<>0 return
PRINT 'les filiales sont dans #TLSTSSD'

------------------------
-- update clothing date
------------------------

IF @p_FORCE_DTE  = ' ' or @p_FORCE_DTE  = 'null'
   begin
      PRINT 'treatment of DATE_T (remplacée par @p_clodat_d, date en fonction des arrétes d''inventaire)'
      select @dte 		= convert(char(8),@p_clodat_d,112)
      select @mth_nf 	= datepart(mm,@dte)	--selected month of @p_clodat_d
      select @yea_nf 	= datepart(yy,@dte)	--selected year of @p_clodat_d
   end

ELSE
   begin
      PRINT 'treatment of FORCE_DTE'
      select @p_FORCE_DTE_OK = convert(char(8),@p_FORCE_DTE,112)
      select @dte 		= @p_FORCE_DTE_OK
      select @mth_nf	= datepart(mm,@dte)	--selected month
      select @yea_nf	= datepart(yy,@dte)	--selected year
   end

--------------------------------------------------------------------------------
PRINT 'Update of closing date with entry dates parameters (DATE_T or FORCE_DTE)'
--------------------------------------------------------------------------------

IF ( @mth_nf = 12)
    begin
      select @mth=1
      select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),(@yea_nf+1)*10000+@mth*100+01,102)))
    end
ELSE
      select @datarret = dateadd(dd,-1,convert(datetime,convert(char(8),@yea_nf*10000+(@mth_nf+1)*100+01,102)))
-- -----------------------------------------------------------------------------------------------
-- RECHERCHE et chargement du cours de change
-- si demande de SDC par simulation @SIMLATION = 'Y', on prendra le dernier cours de change cunnu. [18536]
-- sinon, on récupère le cours de change de la fin du mois passé en paramètre
-- -----------------------------------------------------------------------------------------------

if ( @simulation = 'Y')
begin
    INSERT INTO #TESTTBRQUOT        -- [18536] dernier cours connu
     SELECT
          SSD_CF = a.SSD_CF,
          CUR_CF = a.CUR_CF,
          EXC_D  = max(a.EXC_D),
          EXC_R  = 0.000
    FROM bref..TCURQUOT a
    group by a.SSD_CF, a.CUR_CF
    order by a.SSD_CF, a.CUR_CF

end
else
begin
    if ( @mth_nf = 12)
        begin
          select @mth=1
          INSERT INTO #TESTTBRQUOT
          select
          SSD_CF = a.SSD_CF,
          CUR_CF = a.CUR_CF,
          EXC_D  = max(a.EXC_D),
          EXC_R  = 0.000
          from BREF..TCURQUOT a
          where a.exc_d = dateadd(dd,-1,convert(datetime,convert(char(8),(@yea_nf+1)*10000+@mth*100+01,102)))
          group by a.SSD_CF, a.CUR_CF
          order by a.SSD_CF, a.CUR_CF

        end
    else
        begin
          INSERT INTO #TESTTBRQUOT
          select
          SSD_CF = a.SSD_CF,
          CUR_CF = a.CUR_CF,
          EXC_D  = max(a.EXC_D),
          EXC_R  = 0.000
          from BREF..TCURQUOT a
          where a.exc_d = dateadd(dd,-1,convert(datetime,convert(char(8),@yea_nf*10000+(@mth_nf+1)*100+01,102)))
          group by a.SSD_CF, a.CUR_CF
          order by a.SSD_CF, a.CUR_CF
         end
 end
------------------------------------------------------
PRINT 'chargement du cours dans la table #TESTTBRQUOT'
------------------------------------------------------
UPDATE #TESTTBRQUOT
SET EXC_R = a.EXC_R
from BREF..TCURQUOT a,
     #TESTTBRQUOT b
where a.EXC_D  = b.EXC_D
and   a.SSD_CF = b.SSD_CF
and   a.CUR_CF = b.CUR_CF

-- modification 19 : vde le 14/02/07

IF @p_FORCE_DTE  = ' ' or @p_FORCE_DTE  = 'null'
    begin
        PRINT 'sélection de TTECLEDA selon les paramétres inventaire (TREQJOB)'
        -- ********************************************************************
        SELECT @tabcibleA_cf = TABCIBLE_CF
        FROM BSAR..TBOPAR
        WHERE DMN_CF = 'EST' and
              TAB_CF = 'TTECLEDA' and
        (FIELD1_CF = @p_balsheyea_nf+@p_balshtmth_nf or
        FIELD1_CF  =@p_balsheyea_nf+ '0' +@p_balshtmth_nf ) and
        convert( char(8),FIELD2_CF, 112 ) = @p_clodat_d and
        (PAR_D = NULL or PAR_D = '') and
        ARCH_B = 0

        PRINT 'sélection de TTECLEDR selon les paramétres inventaire (TREQJOB)'
        -- *********************************************************************
       SELECT @tabcibleR_cf = TABCIBLE_CF
       FROM BSAR..TBOPAR
       WHERE DMN_CF = 'EST' and
             TAB_CF = 'TTECLEDR' and
         (FIELD1_CF = @p_balsheyea_nf+@p_balshtmth_nf or
       FIELD1_CF = @p_balsheyea_nf+'0'+@p_balshtmth_nf ) and
       convert( char(8),FIELD2_CF, 112 ) = @p_clodat_d and
       (PAR_D = NULL or PAR_D = '') and
       ARCH_B = 0
    end

ELSE
    begin
        PRINT 'sélection de TTECLEDA selon les paramétres de FORCE_DTE'
        -- ************************************************************
      SELECT @tabcibleA_cf = TABCIBLE_CF
      FROM BSAR..TBOPAR
      WHERE DMN_CF = 'EST' and
            TAB_CF = 'TTECLEDA' and
        (FIELD1_CF = convert(char(4),@yea_nf) + convert(char(2),@mth_nf) or
      FIELD1_CF =convert(char(4),@yea_nf )+ '0' + convert(char(2),@mth_nf )) and
      convert( char(8),FIELD2_CF, 112 ) = @datarret and
      (PAR_D = NULL or PAR_D = '') and
      ARCH_B = 0

        PRINT 'sélection de TTECLEDR selon les paramétres de FORCE_DTE'
        -- ************************************************************

      SELECT @tabcibleR_cf = TABCIBLE_CF
      FROM BSAR..TBOPAR
      WHERE DMN_CF = 'EST' and
            TAB_CF = 'TTECLEDR' and
        (FIELD1_CF = convert(char(4),@yea_nf) + convert(char(2),@mth_nf) or
      FIELD1_CF =convert(char(4),@yea_nf )+ '0' + convert(char(2),@mth_nf )) and
      convert( char(8),FIELD2_CF, 112 ) = @datarret and
      (PAR_D = NULL or PAR_D = '') and
      ARCH_B = 0

      PRINT 'on récupère l''année bilan et date cloture pour FORCE_DTE'
      -- ***************************************************************
      SELECT @p_balsheyea_nf = convert(char(4),@yea_nf)
      SELECT @p_clodat_d     = convert(char(8),@datarret, 112)
    end

--                          I
-- insertion dans la table temporaire acceptation #DEBCREAC
-- Sélection des postes comptables ACCEPTATION ( comptes à émettre )
-- Pour le tiers, seule la cédante est renseignée
-- le courtier le payeur et la clé sont initialisés à zéro
-- sélection pour les filiales paramétrées
-- *******************************************************************

-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
-- $$$$$ A C C E P T A T I O N   TTECLEDA_X   $$$$$$$$
-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


-- 1) Regroupement des postes comptables acceptation
--    **********************************************

IF @tabcibleA_cf = 'TTECLEDA_A'

begin
  INSERT INTO #DEBCREAC
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
  AMT_M, AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, CED_NF, 0, 0, "", '', 0, CUR_CF, SUM(AMT_M) ,0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDA_A a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '1'  -- postes acceptation vde le 21/06/1999
  AND CED_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf --selection du bilan vde le 11/01/2000
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF

   select @erreur = @@error
   if @erreur != 0
   begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #DEBCREAC - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
   end
end

ELSE IF @tabcibleA_cf = 'TTECLEDA_B'

begin
  INSERT INTO #DEBCREAC
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M,
  AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, CED_NF, 0, 0, "", '', 0, CUR_CF, SUM(AMT_M) ,0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDA_B a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '1'  -- postes acceptation vde le 21/06/1999
  AND CED_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf --selection du bilan vde le 11/01/2000
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF

   select @erreur = @@error
   if @erreur != 0
      begin
        select @errno = 20020 ,
        @errmsg = '20020 BATCH; Insert #DEBCREAC - 2 : ' + convert(varchar(10),@erreur) + ';'
        goto erreur
      end
end

ELSE IF @tabcibleA_cf = 'TTECLEDA_C'

begin
  INSERT INTO #DEBCREAC
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
  AMT_M, AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, CED_NF, 0, 0, "", '', 0, CUR_CF, SUM(AMT_M) ,0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDA_C a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '1'  -- postes acceptation vde le 21/06/1999
  AND CED_NF  != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf --selection du bilan vde le 11/01/2000
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF

   select @erreur = @@error
   if @erreur!= 0
    begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #DEBCREAC - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
    end
end

ELSE IF @tabcibleA_cf = 'TTECLEDA_D'

begin
  INSERT INTO #DEBCREAC
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M,
  AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, CED_NF, 0, 0, "", '', 0, CUR_CF, SUM(AMT_M) ,0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDA_D a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '1'
  AND CED_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF

   select @erreur = @@error
   if @erreur != 0
    begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #DEBCREAC - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
    end
end

ELSE IF @tabcibleA_cf = 'TTECLEDA_E'

begin
  INSERT INTO #DEBCREAC
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M,
  AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, CED_NF, 0, 0, "", '', 0, CUR_CF, SUM(AMT_M) ,0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDA_E a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '1'
  AND CED_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF

   select @erreur = @@error
   if @erreur != 0
    begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #DEBCREAC - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
    end
end

ELSE IF @tabcibleA_cf = 'TTECLEDA_F'

begin
  INSERT INTO #DEBCREAC
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M,
  AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, CED_NF, 0, 0, "", '', 0, CUR_CF, SUM(AMT_M) ,0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDA_F a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '1'
  AND CED_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, CED_NF, CUR_CF, b.PCR_CF

   select @erreur = @@error
   if @erreur != 0
    begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #DEBCREAC - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
    end
end
--                        II
-- insertion dans la table temporaire rétrocession #DEBCRERT
-- Sélection des postes comptables RETROCESSION   ( comptes à émettre )
-- Pour le tiers, seule la cédante est renseignée
-- (le courtier,le payeur et la clé sont initialisés à zéro )
-- Sélection des filiales contenues dans la table #TLSTSSD
-- **********************************************************

--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
--$$$$$ R E T R O C E S S I O N   TTECLEDA_X   $$$$$$$$
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

IF @tabcibleR_cf = 'TTECLEDR_A'
begin
  PRINT 'Regroupement des postes comptables RETROCESSION sous un même code PCR'
  INSERT INTO #DEBCRERT
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
  AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, RTO_NF, 0, 0, "", '', 0, RETCUR_CF, sum(RETAMT_M), 0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDR_A a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF  = b.TRNCOD_CF
  AND b.DMN_CT = '2'  -- postes retrocession vde le 21/06/1999
  AND RTO_NF  != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf --selection du bilan vde le 11/01/2000
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF

  select @erreur = @@error
  if @erreur != 0
     begin
       select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #DEBCRERT - 2 : ' + convert(varchar(10),@erreur) +';'
       goto erreur
  end
end

ELSE IF @tabcibleR_cf = 'TTECLEDR_B'

begin
  INSERT INTO #DEBCRERT
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
  AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, RTO_NF, 0, 0, "", '', 0, RETCUR_CF, sum(RETAMT_M), 0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDR_B a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '2'  -- postes retrocession vde le 21/06/1999
  AND RTO_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf --selection du bilan vde le 11/01/2000
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF

  select @erreur = @@error
  if @erreur != 0
     begin
      select @errno = 20020 ,
             @errmsg = '20020 BATCH; Insert #DEBCRERT - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
  end
end

ELSE IF @tabcibleR_cf = 'TTECLEDR_C'

begin
  INSERT INTO #DEBCRERT
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
  AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, RTO_NF, 0, 0, "", '', 0, RETCUR_CF, sum(RETAMT_M), 0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDR_C a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '2'  -- postes retrocession vde le 21/06/1999
  AND RTO_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf --selection du bilan vde le 11/01/2000
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF

   select @erreur = @@error
   if @erreur != 0
     begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert #DEBCRERT - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
    end
end

ELSE IF @tabcibleR_cf = 'TTECLEDR_D'

begin
  INSERT INTO #DEBCRERT
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
  AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, RTO_NF, 0, 0, "", '', 0, RETCUR_CF, sum(RETAMT_M), 0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDR_D a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '2'
  AND RTO_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF

  select @erreur = @@error
  if @erreur != 0
     begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert #DEBCRERT - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
  end
end

ELSE IF @tabcibleR_cf = 'TTECLEDR_E'

begin
  INSERT INTO #DEBCRERT
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
  AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, RTO_NF, 0, 0, "", '', 0, RETCUR_CF, sum(RETAMT_M), 0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDR_E a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF  = b.TRNCOD_CF
  AND b.DMN_CT = '2'
  AND RTO_NF  != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF

  select @erreur = @@error
  if @erreur != 0
    begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert #DEBCRERT - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
     end
end

ELSE IF @tabcibleR_cf = 'TTECLEDR_F'

begin
  INSERT INTO #DEBCRERT
  ( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
  AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF )
  SELECT
  SSD_CF, ESB_CF, RTO_NF, 0, 0, "", '', 0, RETCUR_CF, sum(RETAMT_M), 0, 0, 0, b.PCR_CF
  FROM BSAR..TTECLEDR_F a,
       #TPCR1 b
  WHERE
  a.TRNCOD_CF = b.TRNCOD_CF
  AND b.DMN_CT = '2'
  AND RTO_NF != null
  AND convert(char(04),BALSHEY_NF) = @p_balsheyea_nf
  AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
  GROUP BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF
  ORDER BY SSD_CF, ESB_CF, RTO_NF, RETCUR_CF, b.PCR_CF

  select @erreur = @@error
  if @erreur != 0
    begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert #DEBCRERT - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
    end
end

-- modif 017 vde le 17/10/06
-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
-- $$$$$ A C C E P T A T I O N   bcta..TACCTRN   $$$$$
-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


PRINT 'Sélection de tous les mvts non lettrés à partir de TACCTRN dans la table #TNCTRN1'
-- ======================================================================================
PRINT ''
select 'time 3 begin = ', convert(char(9),getdate(),8)

--declare @fil char(02)
--declare @compar varchar(10)

--select @fil =convert(char(02),ssd_cf)  FROM #TLSTSSD
--select  '@fil = ', @fil
--select 'lg fiiale',  datalength (RTRIM(@fil))
--select @fil = case when datalength (RTRIM(@fil)) > 1 then @fil else '0'+@fil end
--select '@fil = ', @fil
--select @compar = RTRIM(@fil) + '%'
--select  '@compar = ' , @compar

SELECT tacctrn.*
INTO  #TFNCTRN1
FROM bcta..TACCTRN tacctrn, #TLSTSSD tlstssd
WHERE    tacctrn.SSD_CF =  tlstssd.SSD_CF            -- sélection de la filiale --MOD026

-- création d'un index sur la table temporaire pour la récupération des postes acceptation
CREATE NONCLUSTERED INDEX IFNCTRN1_01
    ON dbo.#TFNCTRN1(TRNCOD_CF)

select 'time 3 end = ', convert(char(9),getdate(),8)

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PRINT ''
PRINT 'Sélection dans #TFNCTRN2 des tous les éléments non lettrés après la date d''arrété '
select 'time 4 begin = ', convert(char(9),getdate(),8)
INSERT INTO #TFNCTRN2
(
 TRN_NT,
 SSD_CF,
 ESB_CF,
 TRNCOD_CF,
 LSTUPD_D
)
SELECT
TRN_NT,
SSD_CF,
ESB_CF,
TRNCOD_CF,
LSTUPD_D
FROM #TFNCTRN1
WHERE  	MTH_D > @datarret
select 'time 4 end = ', convert(char(9),getdate(),8)

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PRINT ''
PRINT 'Chargement de la table bcta..TFNCTRN en table temporaire #TFNCTRN2'
-- ========================================================================
select 'time 5 begin = ', convert(char(9),getdate(),8)
PRINT ''

INSERT INTO #TFNCTRN2
SELECT
T1.TRN_NT,
T1.SSD_CF,
T1.ESB_CF,
T1.TRNCOD_CF,
getdate()
FROM bcta..TFNCTRN T1
,BREF..TBATCHSSD TSSD						-- Modification 026
where T1.ssd_cf = TSSD.ssd_cf           	-- Modification 026
and TSSD.BATCHUSER_CF = suser_name()		-- Modification 026

select @erreur = @@error
  if @erreur != 0
     begin
     select @errno = 20020,
            @errmsg = '20020 BATCH; Insert #TFNCTRN1 - 2 : ' + convert(varchar(10),@erreur) + ';'
     goto erreur
     end
select 'time 5 end = ', convert(char(9),getdate(),8)
PRINT ''

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

PRINT 'Extraction des POSTES ACCEPTATION: SAC, Primes différées, dépôts dommages & vie et policy'
-- ==============================================================================================

SELECT tacctrn.*
INTO  #TACCTRN1
-- FROM bcta..TACCTRN tacctrn ,
FROM #TFNCTRN1 tacctrn ,
     #TPCR2 tpcr2, #TLSTSSD tlstssd

WHERE
tacctrn.SSD_CF = tlstssd.SSD_CF   AND              -- sélection de la filiale --MOD026
tacctrn.TRNCOD_CF = tpcr2.TRNCOD_CF AND
tpcr2.DMN_CT      = '1'             AND               -- code poste acceptation
tacctrn.CED_NF   != null                              -- cédante non null

select @erreur = @@error
  if @erreur != 0
     begin
     select @errno = 20020,
            @errmsg = '20020 BATCH; Insert #TACCTRN1 : ' + convert(varchar(10),@erreur) + ';'
     goto erreur
     end

-- @@@@@@@@ modif 021  @@@@@@@@@@@@@@@@@@@@@@@@@

-- on libère de la place
DROP TABLE #TFNCTRN1

-- création des index sur les tables temporaires afin de diminuer les temps d'éxécution'
PRINT ''
PRINT 'Création de l'' index IACCTRN1_00 sur la table dbo.#TACCTRN1'

CREATE UNIQUE NONCLUSTERED INDEX IACCTRN1_00
    ON dbo.#TACCTRN1(TRN_NT,SSD_CF,ESB_CF)

PRINT ''
PRINT 'Création de l'' index IACCTRN1_01 sur la table dbo.#TACCTRN1'
CREATE NONCLUSTERED INDEX IACCTRN1_01
    ON dbo.#TACCTRN1(TRNCOD_CF)

PRINT ''
PRINT 'Création de l'' index IFNCTRN2_00 sur la table dbo.#TFNCTRN2'
CREATE UNIQUE CLUSTERED INDEX IFNCTRN2_00
    ON dbo.#TFNCTRN2(TRN_NT,SSD_CF,ESB_CF)

-- @@@@@@@@ fin ajout @@@@@@@@@@@@@@@@@@@@@@@@@@@@@

PRINT 'sélection des mvts comptables non lettrés'
-- ==============================================
select 'time 6 begin = ', convert(char(9),getdate(),8)
SELECT a.*
INTO  #TACCTRN2
--FROM bcta..TACCTRN a,
FROM #TACCTRN1 a,
     #TFNCTRN2 b
	WHERE
	a.TRN_NT       = b.TRN_NT     AND
	a.SSD_CF       = b.SSD_CF     AND
	a.ESB_CF       = b.ESB_CF     AND
	a.TRNCOD_CF    = b.TRNCOD_CF  AND
  a.ORICURAMT_M != 0              -- montant # de 0

select @erreur = @@error
  if @erreur != 0
     begin
     select @errno = 20020,
            @errmsg = '20020 BATCH; Insert #TACCTRN2 : ' + convert(varchar(10),@erreur) + ';'
     goto erreur
     end
select 'time 6 end = ', convert(char(9),getdate(),8)

PRINT ''
PRINT 'cumul par poste de regroupement PCR'
-- =======================================

INSERT INTO #DEPOTAC
		( SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF,
		AMT_M, AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF )
SELECT
tacctrn2.SSD_CF,
tacctrn2.ESB_CF,
tacctrn2.CED_NF,
0,              -- BRK_NF
0,              -- PAY_NF
'',             -- KEY_CF
'',             -- TRNCOD_CF
0,              -- TRAN_NF
tacctrn2.CUR_CF,
SUM(tacctrn2.ORICURAMT_M), -- AMT_M
0,              -- AMTCV_M
0,              -- AMTSSD_M
0,              -- AMTESB_M
tpcr2.PCR_CF    -- PCR_CF

FROM #TACCTRN2 tacctrn2,
     #TPCR2 tpcr2
WHERE
tacctrn2.TRNCOD_CF = tpcr2.TRNCOD_CF AND
tpcr2.DMN_CT       = '1'             AND                               -- code poste acceptation
tacctrn2.BLCSHT_D <= @datarret                                         -- sélection du bilan paramétre

-- AND convert(char(04),datepart(year,tacctrn2.BLCSHT_D)) = @p_balsheyea_nf   -- sélection du bilan / mis en commentaire le 01/03/2007

GROUP BY tacctrn2.SSD_CF, tacctrn2.ESB_CF, tacctrn2.CED_NF, tacctrn2.CUR_CF, tpcr2.PCR_CF
ORDER BY tacctrn2.SSD_CF, tacctrn2.ESB_CF, tacctrn2.CED_NF, tacctrn2.CUR_CF, tpcr2.PCR_CF

select @erreur = @@error
  if @erreur != 0
     begin
     select @errno = 20020,
            @errmsg = '20020 BATCH; Insert #DEPOTAC : ' + convert(varchar(10),@erreur) + ';'
     goto erreur
     end


-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
-- $$$$$ R E T R O C E S S I O N   bret..TRACCTRN   $$$$
-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

PRINT 'sélection des postes de SAC vie & dom, des primes différées et dépôts & de policy rétrocession (#TPCR2)'
-- ============================================================================================================

INSERT INTO #DEPORET1
(SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M, AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF)
SELECT
tractrn.SSD_CF,
ESB_CF,
RTO_NF,
0,
0,
'',
'',
0,
tractrn.CUR_CF,
tractrn.TRN_M,
0,
0,
0,
tpcr2.PCR_CF
FROM BRET..TRACCTRN tractrn,
     #TPCR2 tpcr2
WHERE
tractrn.BLCSHT_D   <= @datarret        AND                                  -- bilan
tractrn.TRNCOD_CF   = tpcr2.TRNCOD_CF  AND                                  -- postes SAC & Primes retrocession (#TPCR2)
tpcr2.DMN_CT       = '2'               AND                                  -- rétrocession
tractrn.TRN_M      != 0                AND
tractrn.SSD_CF in ( SELECT  tlstssd.SSD_CF FROM #TLSTSSD tlstssd )          --selection des filiales

-- AND convert(char(04),datepart(year,tractrn.BLCSHT_D)) = @p_balsheyea_nf AND     -- sélection du bilan en cours / mis en commentaire le 01/03/2007

select @erreur = @@error
  if @erreur != 0
     begin
     select @errno = 20020,
            @errmsg = '20020 BATCH; Insert #DEPORET1 : ' + convert(varchar(10),@erreur) + ';'
     goto erreur
     end

PRINT 'Cumul par poste de regroupement PCR'
--=========================================

INSERT INTO #DEPORET2
(SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M, AMTCV_M,AMTSSD_M, AMTESB_M, PCR_CF )
SELECT
SSD_CF,
ESB_CF,
CED_NF,
0,
0,
'',
'',
0,
CUR_CF,
SUM(AMT_M),
0,
0,
0,
PCR_CF

FROM #DEPORET1
GROUP BY SSD_CF,ESB_CF, CED_NF,CUR_CF,PCR_CF
ORDER BY SSD_CF,ESB_CF, CED_NF,CUR_CF,PCR_CF

select @erreur = @@error
  if @erreur != 0
     begin
     select @errno = 20020,
            @errmsg = '20020 BATCH; Insert #DEPORET2 : ' + convert(varchar(10),@erreur) + ';'
     goto erreur
     end

PRINT 'Récupération des comptes tiers à partir de la table TDEBCRED (prendre les mouvements du dernier arrété )'
-- ************************************************************************************************************
-- sélection des comptes de tiers acceptation & rétrocession regroupés par pcr
-- sélection des mouvements sur la dernière date d'arrrêté
-- Sélection des filiales contenues dans la table #TLSTSSD
-- ****************************************************************************

INSERT #TCPTIERS
(SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF )
SELECT
SSD_CF,
ESB_CF,
CED_NF,
BRK_NF,
GEMPRMPAY_NF,
KEY_CF,
' ',
TRA_NF,
CUR_CF,
AMT_M,
AMTCUR_M,
AMTBALSSD_M,
AMTBALESB_M,
PCR_CF
FROM bsta..TDEBCRED
WHERE (pcr_cf = '41120001' or pcr_cf = '41020001')
AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
-- modif 018
--AND CLODATE_D = ( SELECT max(CLODATE_D) FROM BSTA..TDEBCRED WHERE SSD_CF IN  (SELECT  SSD_CF FROM #TLSTSSD ))
AND CLODATE_D = @p_clodat_d
AND TRA_NF != 0 --On prend uniquement les mouvements de la balance agée
AND LOCAL_CF = '0' -- on prend en compte uniquement les mvts issus du calcul sur date bilan  --[15036] ajout vde
                   -- vde 02/04/2008

PRINT 'si la cédante n''est pas renseignée ( = 0 ), imposer ced_nf = brk_nf )'
-- *************************************************************************

UPDATE #TCPTIERS
SET CED_NF = BRK_NF
WHERE CED_NF = 0

-- mise à zéro du courtier, du payeur et du code tranche d'age
-- mise à blanc de la clé tiers
--****************************

UPDATE #TCPTIERS
SET   BRK_NF  = 0,
      PAY_NF  = 0,
      TRAN_NF = 0,
      KEY_CF  = ''

--  F U S I O N   des tables temporaires ACCEPTATION + RETROCESSION + TIERS
--  ACCEPTATION & RETROCESSION pour depots + autres postes + comptes à émettre + comptes de tiers
--  ( #DEBCREAC - #DEBCRERT - #TCPTIERS - #DEPOTAC - #DEPORET2 ---> #DEBCREAR )

INSERT  #DEBCREAR
SELECT
SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF
FROM  #DEBCREAC

UNION ALL

SELECT
SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF, CUR_CF, AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF
FROM  #DEBCRERT

UNION ALL

SELECT
SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF,CUR_CF, AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF
FROM  #DEPOTAC

UNION ALL

SELECT
SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF,CUR_CF, AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF
FROM  #DEPORET2

UNION ALL

SELECT
SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, TRNCOD_CF, TRAN_NF,CUR_CF, AMT_M, AMTCV_M, AMTSSD_M, AMTESB_M, PCR_CF
FROM  #TCPTIERS

select @erreur = @@error
if @erreur != 0
   begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert #DEBCREAR - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
   end

PRINT 'Cumul des montants sur les critéres suivants:'
PRINT 'filiale/établisement/tiers/code PCR/tranche/monnaie'
-- ********************************************************

INSERT  #TDEBCRED
SELECT
SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF, SUM(AMT_M),0, 0, 0,@datarret, GETDATE()
,'0'   -- [15036] JR 20/03/2008
FROM  #DEBCREAR
GROUP BY SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF
ORDER BY SSD_CF, ESB_CF, CED_NF, BRK_NF, PAY_NF, KEY_CF, PCR_CF, TRAN_NF, CUR_CF

select @erreur = @@error
  if @erreur != 0
   begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert #DEBCRED - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
   end

PRINT ' C O N V E R S I O N   des montants'
--  ***************************************
SET ARITHABORT NUMERIC_TRUNCATION OFF

-- conversion du montant au dernier cours connu
-- ********************************************
UPDATE #TDEBCRED
SET AMTCUR_M = a.AMT_M * b.EXC_R
FROM  #TDEBCRED a,
      #TESTTBRQUOT b
WHERE a.CUR_CF = b.CUR_CF
AND   a.SSD_CF = b.SSD_CF

-- conversion de la monnaie XOF au cours de la monnaie XAF ( maj demandée par j. vaillant)
UPDATE #TDEBCRED
SET AMTCUR_M = a.AMT_M * b.EXC_R
FROM #TDEBCRED a,
     #TESTTBRQUOT b
WHERE a.CUR_CF = 'XOF'
	AND b.CUR_CF = 'XAF'
	AND a.SSD_CF = b.SSD_CF

-- Recherche de la position du tiers ( crédit/débit ) par FILIALE/ETABLISSEMENT
-- le solde de chaque tiers ne doit pas intégrer les dépôts
-- ****************************************************************************
INSERT  #TOTESB
SELECT
SSD_CF, ESB_CF, CED_NF, BRK_NF, GEMPRMPAY_NF, KEY_CF, SUM(AMTCUR_M)
FROM #TDEBCRED
WHERE PCR_CF not in ('23500005', '23510005', '17200006', '17210006')  -- élimination des dépôts
GROUP BY SSD_CF, ESB_CF, CED_NF, BRK_NF, GEMPRMPAY_NF, KEY_CF
ORDER BY SSD_CF, ESB_CF, CED_NF, BRK_NF, GEMPRMPAY_NF, KEY_CF

select @erreur = @@error
if @erreur != 0
   begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert #TOESB - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
   end

-- ajout du total tiers FILIALE/ETABLISSEMENT à toutes les lignes de #TDEBCRED
-- **************************************************************************

UPDATE #TDEBCRED
SET AMTBALESB_M = b.AMTCUR_M
FROM #TDEBCRED a,
     #TOTESB b
WHERE
      a.SSD_CF        = b.SSD_CF
  AND a.ESB_CF        = b.ESB_CF
  AND a.CED_NF        = b.CED_NF
  AND a.BRK_NF        = b.BRK_NF
  AND a.GEMPRMPAY_NF  = b.PAY_NF
  AND a.KEY_CF        = b.KEY_CF

-- Recherche de la position du tiers ( crédit/débit ) par FILIALE
-- le solde de chaque tiers ne doit pas intégrer les dépôts
-- ********************************************************************
INSERT  #TOTSSD
SELECT
SSD_CF,CED_NF, BRK_NF, GEMPRMPAY_NF, KEY_CF, SUM(AMTCUR_M)
FROM #TDEBCRED
WHERE PCR_CF not in ('23500005', '23510005', '17200006', '17210006')
GROUP BY SSD_CF, CED_NF, BRK_NF, GEMPRMPAY_NF, KEY_CF
ORDER BY SSD_CF, CED_NF, BRK_NF, GEMPRMPAY_NF, KEY_CF

select @erreur = @@error
if @erreur != 0
   begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert #TOTSSD - 2 : ' + convert(varchar(10),@erreur) + ';'
      goto erreur
   end

-- ajout du total tiers FILIALE à toutes les lignes de #TDEBCRED
-- *************************************************************
UPDATE #TDEBCRED
SET AMTBALSSD_M = b.AMTCUR_M
FROM #TDEBCRED a,
     #TOTSSD b
WHERE
      a.SSD_CF       = b.SSD_CF
  AND a.CED_NF       = b.CED_NF
  AND a.BRK_NF       = b.BRK_NF
  AND a.GEMPRMPAY_NF = b.PAY_NF
  AND a.KEY_CF       = b.KEY_CF

BEGIN TRAN PtDEBCRED_01

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- la situation des sociétés débitrices/créditrices ne peut être présente pour la date de cloture
-- dans le cas où le paramètre force_date est renseigné, on supprimera la situation existante pour la date de cloture demandée(annule et remplace)
-- dans les autres cas on conservera l'historique des précédentes situations
-- les mouvements SDC à supprimer, seront identifiés par le code de la tranche d'age ( tra_nf = 0 )
-- et la date de cloture = force_date

IF @p_FORCE_DTE  = ' ' or @p_FORCE_DTE  = 'null'
    begin
    PRINT '<<<<< treatment of DATE_T >>>>>>>'
    PRINT '<<<<< new situation to a new closing date >>>>'
    end
else
    begin
      DELETE  BSTA..TDEBCRED
      WHERE TRA_NF = 0
      AND SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )
      AND CLODATE_D = @datarret
      AND LOCAL_CF = '0'  --[15036] calcul sur date bilan - ajout vde le 20/03/2008
                          -- vde 02/04/2008

      select @erreur = @@error
      if @erreur != 0
      begin
          select @errno = 20020,
          @errmsg = '20020 BATCH; DELETED TABLE BSTA..TDEBCRED (selon date arrêté FORCE_DTE /filiales ) : ' + convert(varchar(10),@erreur) + ';'
          goto erreur2
      end
end
-- Insertion des mouvements du mois dans la table TDEBCRED
-- *******************************************************
INSERT INTO BSTA..TDEBCRED
SELECT	SSD_CF,
		ESB_CF,
		CED_NF,
		BRK_NF,
		GEMPRMPAY_NF	,
		KEY_CF,
		PCR_CF,
		TRA_NF,
		CUR_CF,
		AMT_M,
		AMTCUR_M,
		AMTBALSSD_M,
		AMTBALESB_M,
		CLODATE_D,
		CRE_D,
    LOCAL_CF   --- JR 20/03/2008
FROM #TDEBCRED

select @erreur = @@error
   if @erreur != 0
   begin
      select @errno = 20020,
             @errmsg = '20020 BATCH; Insert BSTA..TDEBCRED : ' + convert(varchar(10),@erreur) + ';'
      goto erreur2
   end

SET arithabort numeric_truncation on

COMMIT TRAN PtDEBCRED_01
  return @erreur

DROP TABLE #TDEBCRED
DROP TABLE #DEBCREAC
DROP TABLE #DEBCRERT
DROP TABLE #DEPOTAC
DROP TABLE #DEPORET1
DROP TABLE #DEPORET2
DROP TABLE #DEBCREAR
DROP TABLE #TOTESB
DROP TABLE #TOTSSD
DROP TABLE #TLSTSSD
DROP TABLE #TESTTBRQUOT
DROP TABLE #TPCR1
DROP TABLE #TPCR2
DROP TABLE #TCPTIERS


erreur:
   raiserror @errno @errmsg      -- erreurs de select tables temporaire

 return @errno

erreur2:
   raiserror @errno @errmsg      -- erreur de maj tdebcred
   ROLLBACK TRAN PtDEBCRED_01

 return @errno
go

IF OBJECT_ID('dbo.PtDEBCRED_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtDEBCRED_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtDEBCRED_01 >>>'
go

-- Granting/Revoking Permissions on dbo.PtDEBCRED_01

GRANT EXECUTE ON dbo.PtDEBCRED_01 TO GOMEGA
go
