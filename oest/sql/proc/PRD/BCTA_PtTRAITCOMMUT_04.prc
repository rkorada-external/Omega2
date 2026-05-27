USE BCTA
go

IF OBJECT_ID('btrav..CNC_CNCD2000_COMMUTCPTA') IS NOT NULL
DROP table btrav..CNC_CNCD2000_COMMUTCPTA
go

-- Creating TABLE  btrav..CNC_CNCD2000_COMMUTCPTA

CREATE TABLE btrav..CNC_CNCD2000_COMMUTCPTA
	(
	CTR_NF		    UCTR_NF		    NOT NULL,
	UWY_NF		    UUWY_NF		    NOT NULL,
	SEC_NF		    USEC_NF		    NOT NULL,
	OCCYEA_NF     smallint      NULL,
	TRNCOD_CF     UDETTRS_CF    DEFAULT '' NOT NULL,
	ORICURAMT_M   UAMT_M        NOT NULL,
	ACY_NF        smallint      NOT NULL,
  CUR_CF        UCUR_CF       DEFAULT '' NOT NULL,
  SSD_CF        USSD_CF       NOT NULL
	)
go

--////////////////////////////////////////////////////////////////////////

IF OBJECT_ID('dbo.PtTRAITCOMMUT_04') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtTRAITCOMMUT_04
    IF OBJECT_ID('dbo.PtTRAITCOMMUT_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtTRAITCOMMUT_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtTRAITCOMMUT_04 >>>'
END
go

-- creation de la procedure

create procedure PtTRAITCOMMUT_04
 (
 @blcsht_d  char(8),
 @source    char(05)
)
as

/***************************************************

Programme: PtTRAITCOMMUT_04

Fichier script associé : bcta_PtTRAITCOMMUT_04.prc

Base principale : BCTA

Version: 1

Auteur: jfvdv

Date de creation: 04/10/2006

Description du programme:

  traitement des contrats commutés
	Mise en forme du fichier CP01 des chekerloader

Parametres:
Commentaires:

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 001       | 19/03/2007  |  Renseignement des n° de RES de production
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 17/09/2009  |[18053] Pour les fac xxLyyyyy, remplacement du test sur les lettres par un interval qui couvre l'ensemble du domaine des FACs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
 van de velde   | 20/05/2010  | [19484] Pour la commutation de RELIANCE ( affectation nouvelles RES)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
 van de velde   | 11/03/2011  | [21641] Pour la commutation d' AXA ( affectation nouvelles RES)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
[004] 11/041/2014 R. Cassis :spot:25427 Centralization Oemaga 2 1B - gestion type de contrat fac ou traite
******************************************************************************/

declare @erreur int

if object_id('#TMP_CPT_CHECKLOADER_COMMUT') is not null
	DROP table #TMP_CPT_CHECKLOADER_COMMUT

CREATE TABLE #TMP_CPT_CHECKLOADER_COMMUT
(
    CONVID_NF    varchar(15)   NOT NULL,                -- 1
    SSD_CF       USSD_CF       NOT NULL,                -- 2
    TRN_NT       numeric(10,0) IDENTITY,                -- 3
    CTR_NF       UCTR_NF       NOT NULL,                -- 4
    UWY_NF       UUWY_NF       NOT NULL,                -- 5
    UW_NT        UUW_NT        DEFAULT 1 NOT NULL,      -- 6
    END_NT       UEND_NT       DEFAULT 0 NOT NULL,      -- 7
    SEC_NF       USEC_NF       NULL,                    -- 8
    REB_NF       int           NULL,                    -- 9
    ACCTYP_CF    tinyint       NULL,                    --10
    SCOSTRMTH_NF tinyint       NOT NULL,                --11
    SCOENDMTH_NF tinyint       NOT NULL,                --12
    ACY_NF       smallint      NOT NULL,                --13
    BLCSHT_D     char(08)      NULL,                    --14
    TRNCOD_CF    UDETTRS_CF    DEFAULT '' NOT NULL,     --15
    ORICURAMT_M  UAMT_M        NOT NULL,                --16
    CUR_CF       UCUR_CF       DEFAULT '' NOT NULL,     --17
    MTH_B        bit           DEFAULT 0 NOT NULL,      --18
    MTH_D        char(08)      NULL,                    --19
    VLD_D        char(08)      NULL,                    --20
    OCCYEA_NF    smallint      NULL,                    --21
    PRMLIN_NT    smallint      NULL,                    --22
    RSVRLSFLG_B  bit           DEFAULT 0 NOT NULL,      --23
    CLM_NF       int           NULL,                    --24
    CC_ACY_NF    smallint      NULL,                    --25
    CC_SCOSTRMTH_NF tinyint    NULL,                    --26
    CC_SCOENDMTH_NF tinyint    NULL,                    --27
    CSHCAL_LM    varchar(32)   NULL,                    --28
    CSHCAL_D     char(08)      NULL                     --29
)

INSERT #TMP_CPT_CHECKLOADER_COMMUT
(   CONVID_NF,
    SSD_CF,
    CTR_NF,
    UWY_NF,
    UW_NT,
    END_NT,
    SEC_NF,
    REB_NF,
    ACCTYP_CF,
    SCOSTRMTH_NF,
    SCOENDMTH_NF,
    ACY_NF,
    BLCSHT_D,
    TRNCOD_CF,
    ORICURAMT_M,
    CUR_CF,
    MTH_B,
    MTH_D,
    VLD_D,
    OCCYEA_NF,
    PRMLIN_NT,
    RSVRLSFLG_B,
    CLM_NF,
    CC_ACY_NF,
    CC_SCOSTRMTH_NF,
    CC_SCOENDMTH_NF,
    CSHCAL_LM,
    CSHCAL_D
    )
SELECT
@SOURCE + convert(char(10),getdate(),112), --CONVID_NF
SSD_CF,
CTR_NF,
UWY_NF,
1,      --UW_NT
0,      --END_NT
SEC_NF,
1,      --REB_NF
1,      --ACCTYP_CF
3,      --SCOSTRMTH_NF
3,      --SCOENDMTH_NF
ACY_NF,
@BLCSHT_D,
TRNCOD_CF,
ORICURAMT_M,
CUR_CF,
0,      --MTH_B
NULL,   --MTH_D
NULL,   --VLD_D
OCCYEA_NF,
NULL,   --PRMLIN_NT
0,      --RSVRLSFLG_B
NULL,   --CLM_NF
NULL,   --CC_ACY_NF
NULL,   --CC_SCOSTRMTH_NF
NULL,   --CC_SCOENDMTH_NF
NULL,   --CSHCAL_LM
NULL   --CSHCAL_D

FROM btrav..CNC_CNCD2000_COMMUTCPTA

-- PRINT '-- pour les facultatives on force le type de compte à NULL'

--[004]
UPDATE #TMP_CPT_CHECKLOADER_COMMUT
SET ACCTYP_CF = NULL
from #TMP_CPT_CHECKLOADER_COMMUT a
--WHERE substring(ctr_nf,3,1) between 'A' and 'M'
Where exists (select 1 from bfac..tcontr b where a.ctr_nf = b.ctr_nf)

-- cas particuliers: MAJ de l'avenant  (car sinon ANO au checker/loader cncd2005.cmd)
-- UPDATE #TMP_CPT_CHECKLOADER_COMMUT
-- SET END_NT = 1
-- WHERE ctr_nf in ('10G20090P','10G20091P','10G20092P')

--   A faire si on connait les RES , sinon on laisse la RES à 1 par défaut

-- MAJ du n° de RES en fonction de l'établissement (traité ou FAC)
--================================================================

-- ------------------------------------------- en attentant les bons n° de RES à affecter 11/03/2011  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- ---------------------------- T E S T ------------- esb_cf = 1 alors RES = 400000
-- ---------------------------- T E S T ------------- esb_cf = 6 alors RES = 60000

-- ------------------------------------------- MAJ des bons n° de RES à affecter  30/05/2011   

-- ---------------------------- P R O D  ------------- esb_cf = 1 alors RES = 369276
-- ---------------------------- P R O D  ------------- esb_cf = 6 alors RES = 41786

-- PRINT '--FACULTATIVES'
UPDATE #TMP_CPT_CHECKLOADER_COMMUT
SET REB_NF =
    case when tcontr.accesb_cf = 1 then 369276
         when tcontr.accesb_cf = 6 then 41786
     --    when tcontr.accesb_cf = 9 then 648
    else REB_NF
    end

FROM #TMP_CPT_CHECKLOADER_COMMUT #TMP,
     bfac..TCONTR tcontr

WHERE #TMP.ctr_nf = tcontr.ctr_nf

-- PRINT '--TRAITES'
UPDATE #TMP_CPT_CHECKLOADER_COMMUT
SET REB_NF =
    case when tcontr.accesb_cf = 1 then 369276
         when tcontr.accesb_cf = 6 then 41786
  
    else REB_NF
     end

FROM #TMP_CPT_CHECKLOADER_COMMUT #TMP,
     btrt..TCONTR tcontr

WHERE #TMP.ctr_nf = tcontr.ctr_nf


-- PRINT 'SELECT FINAL'

SELECT * FROM #TMP_CPT_CHECKLOADER_COMMUT
go

-- ------------------------------
-- fin de la procédure
-- ------------------------------

-- Granting/Revoking Permissions on dbo.PtTRAITCOMMUT_04
GRANT EXECUTE ON dbo.PtTRAITCOMMUT_04 TO GOMEGA
go

IF OBJECT_ID('dbo.PtTRAITCOMMUT_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtTRAITCOMMUT_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtTRAITCOMMUT_04 >>>'
go

EXEC sp_procxmode 'dbo.PtTRAITCOMMUT_04','unchained'
go



