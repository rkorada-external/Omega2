use BSAR
go

IF OBJECT_ID('btravi..CNC_CNCD2000_COMMUTCTRPROP') IS NOT NULL
DROP TABLE btravi..CNC_CNCD2000_COMMUTCTRPROP
go

-- Creating TABLE  btravi..CNC_CNCD2000_COMMUTCTRPROP

CREATE TABLE btravi..CNC_CNCD2000_COMMUTCTRPROP
(
    CTR_NF           UCTR_NF     NOT NULL,     -- 1
    NAT_CF           char(02)    NOT NULL,     -- 2
    ACY_NF           smallint    NOT NULL,     -- 3
    SCOSTRMTH_NF     tinyint     NOT NULL,     -- 4
    SCOENDMTH_NF     tinyint     NOT NULL,     -- 5

    M_ACY_NF         smallint    NOT NULL,     -- 6
    M_SCOSTRMTH_NF   tinyint     NOT NULL,     -- 7
    M_SCOENDMTH_NF   tinyint     NOT NULL,     -- 8

    GLT_ACY_NF       smallint    NOT NULL,     -- 9
    GLT_SCOSTRMTH_NF tinyint     NOT NULL,     --10
    GLT_SCOENDMTH_NF tinyint     NOT NULL      --11
)
go

--////////////////////////////////////////////////////////////////////////////////////
IF OBJECT_ID('dbo.PtTRAITCOMMUT_05') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtTRAITCOMMUT_05
    IF OBJECT_ID('dbo.PtTRAITCOMMUT_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtTRAITCOMMUT_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtTRAITCOMMUT_05 >>>'
END
go

--  création de la procedure

create procedure PtTRAITCOMMUT_05
(
  @CLODAT  char(8),
  @SSD_CF  USSD_cf
)
as

/***************************************************

Programme: PtTRAITCOMMUT_05


Fichier script associe : BSAR_PtTRAITCOMMUT_05.prc

Base principale : BSAR

Version: 1

Auteur: JFVDE
Date de creation: 9/10/2006
Description du programme:
        Procédure de commutation
	    recherche des années de comptes maxi et alimentation de la table btravi

Parametres:
Conditions d'execution:
Commentaires:

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
modif 001       |             |
                |             |
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------

    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs

******************************************************************************/

-- DROP des tables temporaires
-- ===========================
IF object_id('#TGLT_B') is not null
DROP TABLE #TGLT_B

IF object_id('#TGLT_01') is not null
DROP TABLE #TGLT_01

IF object_id('#TGLT_02') is not null
DROP TABLE #TGLT_02

CREATE  table #TGLT_01
(
    CTR_NF           UCTR_NF     NOT NULL,
    TRNCOD_CF       UDETTRS_CF    	DEFAULT '' NOT NULL,
    ACY_NF           smallint    NOT NULL,
    SCOSTRMTH_NF     tinyint     NOT NULL,
    SCOENDMTH_NF     tinyint     NOT NULL
)
/*****
CREATE table #TGLT_02
(
    CTR_NF           UCTR_NF     NOT NULL,
    TRNCOD_CF       UDETTRS_CF    	DEFAULT '' NOT NULL,
    ACY_NF           smallint    NOT NULL,
    SCOSTRMTH_NF     tinyint     NOT NULL,
    SCOENDMTH_NF     tinyint     NOT NULL
)
**/

-- DECLARATION des variables
-- =========================
DECLARE @p_CLODAT       char(08), -- Date d arrêté/Closing date
        @p_BALSHEY_NF   smallint, -- année bilan de la date d arrêté
        @p_SSD_CF       USSD_cf,  --varchar(20),
    	  @p_erreur		    varchar(100),
	 	    @sql_clause 	  varchar(10000),
		    @ttecleda_name	char(10)

/** --pour les tests
DECLARE @CLODAT  char(8),
        @SSD_CF  USSD_cf

select @CLODAT = '20060630'
select @SSD_CF = 2
**/

-- Récupération des paramètres
-- *****************************

select @p_CLODAT = @CLODAT
select @p_BALSHEY_NF=Datepart(year,@CLODAT)
select @p_SSD_CF = @SSD_CF

-- recherche de la table TTECLEDA_X à prendre en compte
-- ======================================================
SELECT 	@ttecleda_name = TABCIBLE_CF
FROM 	bsar..TBOPAR
WHERE 	DMN_CF = 'EST'
and		TAB_CF = 'TTECLEDA'
and		FIELD1_CF = substring(@p_CLODAT ,1,6)
and		convert( char(8),FIELD2_CF, 112 ) = @p_CLODAT
and		(PAR_D = NULL or PAR_D = '')
and		ARCH_B = 0

select 'TABCIBLE_CF = ', @ttecleda_name

select distinct ctr_nf
into #TGLT_B
from btravi..CNC_CNCD2000_COMMUTCTRPROP

-- A T T E N T I O N : si table TTECLEDA_X n'existe pas pour les critères demandés,
-- la proc se plante.
-- soit on teste @ttecleda_name = NULL et on va en fin de traitement, avec message d'ano
-- soit on contrôle l'existence avant de lancer le job dans le shell

-- construction de la requête SQL avec la table TTECLEDA en paramètre ***
--***********************************************************************

select @sql_clause = ''
select @sql_clause =  @sql_clause + " SELECT distinct ttecleda.ctr_nf,trncod_cf,acy_nf,scostrmth_nf,scoendmth_nf"
select @sql_clause =  @sql_clause + " into #TGLT_01"
select @sql_clause =  @sql_clause + " FROM bsar.." + @ttecleda_name + " ttecleda , #TGLT_B tglt"
select @sql_clause =  @sql_clause + " where ttecleda.ctr_nf = tglt.ctr_nf "
select @sql_clause =  @sql_clause + " group by ttecleda.ctr_nf"
select @sql_clause =  @sql_clause + " HAVING acy_nf=max(acy_nf)"
select @sql_clause =  @sql_clause + " order by ttecleda.ctr_nf"

--select @sql_clause

-- lancement de la requete
--=========================
execute(@sql_clause)

if @@error <> 0
begin
    Print '*** problème sur la requete @sql_clause ****'
    goto fin
end

select distinct ctr_nf,acy_nf,scostrmth_nf,scoendmth_nf
into #tGLT_02
FROM #TGLT_01
group by ctr_nf
HAVING scostrmth_nf=max(scostrmth_nf)
order by ctr_nf

UPDATE btravi..CNC_CNCD2000_COMMUTCTRPROP
SET glt_acy_nf       = a.acy_nf,
    glt_scostrmth_nf = a.scostrmth_nf,
    glt_scoendmth_nf = a.scoendmth_nf
FROM #TGLt_02 a,
     btravi..CNC_CNCD2000_COMMUTCTRPROP b
where a.ctr_nf = b.ctr_nf

-- select final pour le BCPout
--============================
SELECT * FROM btravi..CNC_CNCD2000_COMMUTCTRPROP where m_acy_nf!=9999 or glt_acy_nf!=9999
fin:
go

GRANT EXECUTE ON dbo.PtTRAITCOMMUT_05 TO GOMEGA
go
IF OBJECT_ID('dbo.PtTRAITCOMMUT_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtTRAITCOMMUT_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtTRAITCOMMUT_05 >>>'
