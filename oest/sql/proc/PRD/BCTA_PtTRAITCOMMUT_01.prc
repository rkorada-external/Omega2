USE BCTA
go

IF OBJECT_ID('dbo.PtTRAITCOMMUT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtTRAITCOMMUT_01
    IF OBJECT_ID('dbo.PtTRAITCOMMUT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtTRAITCOMMUT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtTRAITCOMMUT_01 >>>'
END
go
/* creation de la procedure */
create procedure PtTRAITCOMMUT_01

as

/***************************************************

Programme: PtTRAITCOMMUT_01

Fichier script associé : bcta_PtTRAITCOMMUT_01.prc

Base principale : BCTA

Version: 1

Auteur: jfvdv

Date de creation: 04/10/2006

Description du programme:

  reprise de la procédure PtTRAITEMENT_01.prc
	recherche des contrats commutés
	chargement de la table BTRAV..CNC_CNCD2000_COMMUTCTRPROP
	recherche du max des AC pour la compta(TACCTRN) et les comptes complets (TCPLACC)

Parametres:

Commentaires:

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 001       |-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 06/03/2007  | prise en compte des commutations St PAUL (UWORG_CF = 65 de TRFCROSSREF)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------

    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 17/09/2009  |[18053] Pour les fac xxLyyyyy, remplacement du test sur les lettres par un interval qui couvre l'ensemble du domaine des FACs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/05/2010  | [19484] Pour la commutation de RELIANCE (prendre UWORF_CF = 95 )
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 11/03/2011  | [21641] Pour la commutation d'AXA (prendre UWORF_CF = 211 )
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
*****************************************************/

declare @erreur int

-- recherche de la nature de tous les contrats traités commutés
-- stockage des contrats en commutation
-- ************************************

if object_id('BTRAV..CNC_CNCD2000_COMMUTCTRUWY') is not null
TRUNCATE TABLE  BTRAV..CNC_CNCD2000_COMMUTCTRUWY

           -- FACULTATIVES

INSERT BTRAV..CNC_CNCD2000_COMMUTCTRUWY
SELECT distinct
tcontr.ctr_nf,
tcontr.uwy_nf,
getdate(),  --cre_d
0           --TOP_COMUT
from bfac..TCONTR tcontr,
     btrt..TRFCROSSREF trfcrossref
where trfcrossref.ctr_nf = tcontr.ctr_nf
and   trfcrossref.uworg_cf = 211

            -- TRAITES

INSERT BTRAV..CNC_CNCD2000_COMMUTCTRUWY
SELECT distinct
tcontr.ctr_nf,
tcontr.uwy_nf,
getdate(),  --cre_d
0           --TOP_COMUT
from btrt..TCONTR tcontr,
     btrt..TRFCROSSREF trfcrossref
where trfcrossref.ctr_nf = tcontr.ctr_nf
and   trfcrossref.uworg_cf = 211


UPDATE BTRAV..CNC_CNCD2000_COMMUTCTRUWY
SET TOP_COMUT = 0


select distinct ctr_nf,nat_cf='00'
into  #TEMP20
from btrav..CNC_CNCD2000_COMMUTCTRUWY
where substring (ctr_nf,3,1) not between 'A' and 'M'

UPDATE #TEMP20
SET nat_cf= b.nat_cf

FROM #TEMP20 a,
     btrt..TSECTION b
WHERE a.ctr_nf = b.ctr_nf

-- ---------------------------------------------
PRINT ''
PRINT '-- Sélection des traités Proportionnels'
-- ---------------------------------------------

INSERT INTO BTRAV..CNC_CNCD2000_COMMUTCTRPROP
SELECT
ctr_nf,
nat_cf,
acy_nf=9999,
SCOSTRMTH_NF=99,
SCOENDMTH_NF=99,
m_acy_nf=9999,
m_scostrmth_nf=99,
m_scoendmth_nf=99,
glt_acy_nf=9999,
glt_scostrmth_nf=99,
glt_scoendmth_nf=99

FROM #TEMP20
WHERE nat_cf < '30' or nat_cf in ('40','41')

-- ----------------------------------------------------------------------------------------
PRINT '-- stockage des n° de contrat des traités proportionnels'
PRINT '-- cette table est utilisée dans le traitement des comptes complets (CNCD2002.cd)'
-- ----------------------------------------------------------------------------------------
INSERT into BTRAV..CNC_CNCD2000_COMMUTCTRPROPCC
(
ctr_nf,
top_comut
)
SELECT ctr_nf, 1 FROM BTRAV..CNC_CNCD2000_COMMUTCTRPROP

-- --------------------------------------------------------
PRINT '-- recherche dernière AC complète (T C P L A C C)'
-- --------------------------------------------------------

SELECT
ctr_nf,
acy_nf,
SCOSTRMTH_NF,
SCOENDMTH_NF

INTO #TCPLACC

FROM BCTA..TCPLACC
group by ctr_nf
HAVING acy_nf=max(acy_nf)
order by ctr_nf


SELECT ctr_nf, acy_nf, SCOSTRMTH_NF, SCOENDMTH_NF
INTO #LAST_ACC

FROM #TCPLACC

Group by ctr_nf
HAVING scostrmth_nf=max(scostrmth_nf)
order by ctr_nf


UPDATE BTRAV..CNC_CNCD2000_COMMUTCTRPROP
SET acy_nf       = a.acy_nf,
    SCOSTRMTH_NF = a.SCOSTRMTH_NF,
    SCOENDMTH_NF = a.SCOENDMTH_NF

FROM #LAST_ACC a,
     BTRAV..CNC_CNCD2000_COMMUTCTRPROP b

WHERE a.ctr_nf = b.ctr_nf

-- --------------------------------------------------------------------------------------------
PRINT ''
PRINT '-- sélection du max de AC pour les postes de réserve des Traités Prop ( T A C C T R N).'
-- --------------------------------------------------------------------------------------------

SELECT distinct a.ctr_nf,a.acy_nf,a.scostrmth_nf,a.scoendmth_nf
INTO #LAST_CPTA

FROM BCTA..TACCTRN a,
     BTRAV..CNC_CNCD2000_COMMUTCTRPROP b

where a.ctr_nf = b.ctr_nf
and (a.trncod_cf like '1141%' or a.trncod_cf like '1142%')
group by a.ctr_nf
having a.acy_nf = max(a.acy_nf)
order by a.ctr_nf


SELECT ctr_nf,acy_nf,scostrmth_nf,scoendmth_nf
INTO #LAST_ACCPTA
FROM #LAST_CPTA
group by ctr_nf
having scostrmth_nf = max(scostrmth_nf)
order by ctr_nf


UPDATE BTRAV..CNC_CNCD2000_COMMUTCTRPROP
SET m_acy_nf       = a.acy_nf,
    m_scostrmth_nf = a.scostrmth_nf,
    m_scoendmth_nf = a.scoendmth_nf
FROM #LAST_ACCPTA a,
     BTRAV..CNC_CNCD2000_COMMUTCTRPROP b
where a.ctr_nf = b.ctr_nf

select * from BTRAV..CNC_CNCD2000_COMMUTCTRPROP --order by acy_nf desc,m_acy_nf desc,glt_acy_nf desc
go

-- fin de la procedure

-- Granting/Revoking Permissions on dbo.PtTRAITCOMMUT_01

GRANT EXECUTE ON dbo.PtTRAITCOMMUT_01 TO GOMEGA
go
IF OBJECT_ID('dbo.PtTRAITCOMMUT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtTRAITCOMMUT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtTRAITCOMMUT_01 >>>'
go