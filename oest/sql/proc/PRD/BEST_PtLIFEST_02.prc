USE BEST
go
IF OBJECT_ID('dbo.PtLIFEST_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtLIFEST_02
    IF OBJECT_ID('dbo.PtLIFEST_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtLIFEST_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtLIFEST_02 >>>'
END
go
-- creation de la procedure

create procedure PtLIFEST_02
(
	@p_balshtyea_nf	 smallint,
    @p_balshtmth_nf  tinyint,
	@p_cre_d         datetime
)
with execute as caller as

/***************************************************
Programme               : PtLIFEST_02
Fichier script associé  : BEST_PtLIFEST_02.PRC
Domaine                 : (EST) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  : JF VDV
Date de creation        : 24/09/2010
Description du programme:

 	ESTIMATIONS VIE : [20198] - Sauvegarde des elements supprimes de la tabe best..TLIFEST
Parametres              :

       @p_balshtyea_nf       smallint,
       @p_balshtmth_nf       tinyint,
       @p_cre_d              datetime

Conditions d'execution  :
Commentaires            :

_________________
MODIFICATION 1
Auteur                  :  Tony RIPERT
Date                    :  04/10/2010
Version                 :
Description             :  [18235] Ne pas supprimer les postes de SUM at RISK dans TLIFEST
[002] 21/10/2011 Roger Cassis   :spot:22674 - Suppression enregistrements du jour en fin de procedure

MODIFICATION "Removed dbo and added 'with execute as caller as'"
_________________
MODIFICATION 3
Auteur: P. COPPIN
Date: 16/10/2013
Description: :spot:25427 - Ajout jointure table #TESTSSD pour Omega2 (delete).
[004] 06/01/2014 R. BEN EZZINE :spot:25427  - Extraction des derniers mouvements uniquement pour insertion en incremental dans la Tlifest
[005] 12/06/2014 R. BEN EZZINE :spot:25427  - Extraction des derniers mouvements uniquement pour insertion en incremental dans la TLIFDRI
[006] 09/09/2014    ABJ  spot:25773  - Correction du Delete ( la Cre_date)
[007] 15/04/2019 R,VIEVILLE :spot:70045 clear TLIFESTD/TLIFDRID
*****************************************************/

-- Déclaration de variables
declare @erreur int


CREATE TABLE #TESTSSD
(
    SSD_CF     USSD_CF       NULL
)

-- Récupération des filiales de l'inventaire
-- ==========================================

INSERT  into #TESTSSD
SELECT  distinct SSD_CF
FROM btrav..TESTSSD

-- Récupération des lignes à supprimer
-- sauvegarde dans la table  btrav..EST_ESID8031_TLIFEST
-- ===================================================
/* [004]
INSERT into btrav..EST_ESID8031_TLIFEST
SELECT
tlifest.CTR_NF,
tlifest.END_NT,
tlifest.SEC_NF,
tlifest.UWY_NF,
tlifest.UW_NT,
tlifest.CRE_D,
tlifest.BALSHEY_NF,
tlifest.BALSHTMTH_NF,
tlifest.ACY_NF,
tlifest.PRS_CF,
tlifest.ACMTRS_NT,
tlifest.SSD_CF,
tlifest.CUR_CF,
tlifest.ESTMNT_M,
tlifest.INDSUP_B,
tlifest.ORICOD_LS,
tlifest.CREUSR_CF,
tlifest.LSTUPD_D,
tlifest.LSTUPDUSR_CF

FROM    best..TLIFEST tlifest,
        #TESTSSD testssd
WHERE
    BALSHEY_NF    = @p_balshtyea_nf
AND BALSHTMTH_NF !> @p_balshtmth_nf
AND CRE_D         < DATEADD(DAY,1,@p_cre_d)
AND tlifest.SSD_CF = testssd.SSD_CF

--select @erreur = @@error
--if @erreur != 0
--begin
--	raiserror 20020 'Erreur SELECT TLIFEST '
--	goto fin
--end
*/

BEGIN

-- Suppression des lignes dans la table best..TLIFEST avant insertion [004]
-- --------------------------------------------------
DELETE best..TLIFEST
FROM
    best..TLIFEST tlifest,
    #TESTSSD testssd
WHERE
    BALSHEY_NF    = @p_balshtyea_nf
--AND BALSHTMTH_NF  = @p_balshtmth_nf
AND CRE_D         between substring(convert(char(8), @p_cre_d, 112),1,10) + " 23:59:00" and substring(convert(char(8), @p_cre_d, 112),1,10) + " 23:59:59"
AND tlifest.SSD_CF = testssd.SSD_CF
AND tlifest.BATCH_B = 1

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20020 'Erreur DELETE TLIFEST '
    ROLLBACK Tran
	goto fin
end

-- BEGIN
-- add clear tlifestd
DELETE best..TLIFESTD
FROM
    best..TLIFESTD tlifestd,
    #TESTSSD testssd
WHERE
    BALSHEY_NF    = @p_balshtyea_nf
--AND BALSHTMTH_NF  = @p_balshtmth_nf
AND CRE_D         between substring(convert(char(8), @p_cre_d, 112),1,10) + " 23:59:00" and substring(convert(char(8), @p_cre_d, 112),1,10) + " 23:59:59"
AND tlifestd.SSD_CF = testssd.SSD_CF
AND tlifestd.BATCH_B = 1

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20020 'Erreur DELETE TLIFEST '
    ROLLBACK Tran
	goto fin
end
-- END


-- Suppression des lignes dans la table best..TLIFDRI avant insertion [005]
-- --------------------------------------------------
DELETE best..TLIFDRI
FROM
    best..TLIFDRI tlifdri,
    #TESTSSD testssd
WHERE
    BALSHEY_NF    = @p_balshtyea_nf
--AND BALSHTMTH_NF !> @p_balshtmth_nf
AND CRE_D         between substring(convert(char(8), @p_cre_d, 112),1,10) + " 23:59:00" and substring(convert(char(8), @p_cre_d, 112),1,10) + " 23:59:59"
AND tlifdri.SSD_CF = testssd.SSD_CF

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20020 'Erreur DELETE TLIFDRI '
    ROLLBACK Tran
	goto fin
end

-- BEGIN
-- clear tlifrdrid
DELETE best..TLIFDRID
FROM
    best..TLIFDRID tlifdrid,
    #TESTSSD testssd
WHERE
    BALSHEY_NF    = @p_balshtyea_nf
--AND BALSHTMTH_NF !> @p_balshtmth_nf
AND CRE_D         between substring(convert(char(8), @p_cre_d, 112),1,10) + " 23:59:00" and substring(convert(char(8), @p_cre_d, 112),1,10) + " 23:59:59"
AND tlifdrid.SSD_CF = testssd.SSD_CF

select @erreur = @@error
if @erreur != 0
begin
	raiserror 20020 'Erreur DELETE TLIFDRI '
    ROLLBACK Tran
	goto fin
end
-- END

--[002]
DELETE best..TLIFMOD
FROM best..TLIFMOD a, #TESTSSD testssd
WHERE a.CRE_D  = substring(convert(char(8), @p_cre_d, 112),1,10)  + ' 23:59:59'
AND   a.SSD_CF = testssd.SSD_CF


select @erreur = @@error
if @erreur != 0
begin
	raiserror 20020 'Erreur DELETE TLIFMOD '
    ROLLBACK Tran
	goto fin
end

DELETE best..TLIFMOD2
from best..TLIFMOD2 a, BTRT..TCONTR b, #TESTSSD testssd 
WHERE a.CRE_D  = substring(convert(char(8), @p_cre_d, 112),1,10)  + ' 23:59:59'
AND   a.CTR_NF = b.CTR_NF
AND   b.SSD_CF = testssd.SSD_CF



select @erreur = @@error
if @erreur != 0
begin
	raiserror 20020 'Erreur DELETE TLIFMOD2 '
    ROLLBACK Tran
	goto fin
end

DELETE best..TLIFMOD2
from best..TLIFMOD2 a, BRET..TRETCTR b, #TESTSSD testssd 
WHERE a.CRE_D  = substring(convert(char(8), @p_cre_d, 112),1,10)  + ' 23:59:59'
AND   a.CTR_NF = b.RETCTR_NF
AND   b.SSD_CF = testssd.SSD_CF



select @erreur = @@error
if @erreur != 0
begin
	raiserror 20020 'Erreur DELETE TLIFMOD2 '
    ROLLBACK Tran
	goto fin
end

DELETE best..TLIFPEN
from best..TLIFPEN a, BTRT..TCONTR b, #TESTSSD testssd
WHERE a.CRE_D  = substring(convert(char(8), @p_cre_d, 112),1,10)  + ' 23:59:59'
AND   a.CTR_NF = b.CTR_NF
AND   b.SSD_CF = testssd.SSD_CF



select @erreur = @@error
if @erreur != 0
begin
	raiserror 20020 'Erreur DELETE TLIFPEN '
    ROLLBACK Tran
	goto fin
end

COMMIT Tran


-- SELECT FINAL pour sauvegarde dans un fichier sur ${DFILI}
-- ==========================================================
-- [004] SELECT * FROM btrav..EST_ESID8031_TLIFEST

FIN:
END
go
EXEC sp_procxmode 'dbo.PtLIFEST_02', 'unchained'
go
IF OBJECT_ID('dbo.PtLIFEST_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtLIFEST_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtLIFEST_02 >>>'
go
GRANT EXECUTE ON dbo.PtLIFEST_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtLIFEST_02 TO GDBBATCH
go
