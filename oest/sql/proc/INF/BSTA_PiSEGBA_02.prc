USE BSTA
GO

IF OBJECT_ID('dbo.PiSEGBA_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PiSEGBA_02
    PRINT '<<< DROPPED PROC dbo.PiSEGBA_02 >>>'
END
GO

/********************************************************************************
PiSEGBA_02          BSTA_PiSEGBA_02.prc

Description :       Calqué sur BSTA_PiSEGBA_01.prc pour ESED0411.cmd

Parametres :
					ssd_cf 	integer	: filiale
					segtyp_ct	char(1)   	: type de segment (A ou E)

Valeurs de retour :
					0: 	OK
					-1:	Echec

Conditions d'execution : 

Commentaires :

Historique :        M. DJELLOULI - 07/10/2004

________________
MODIFICATION  : M.DJELLOULI - 09/12/2004 - MOD01
Description :        Modification des Noms de Segments des Contrats qui ont été affectés à Tort à SBALAI.
                         Il s'agit de Contrats dont l'avenant (END_NT) est = à déjà existant à 0 dans un autre SEGMENT.
                         Il faut donc, isoler tous les Contrats qui sont dans les Segments BALAI et qui existe déjà dans un autre SEGMENT. 

********************************************************************************/
CREATE PROCEDURE PiSEGBA_02
(
	@ssd_cf 	integer,
	@segtyp_ct	char(1)
)
AS

BEGIN

CREATE TABLE #TMpTSEGEST 
(
    SSD_CF    USSD_CF    NOT NULL,
    SEGTYP_CT USEGTYP_CT DEFAULT '' NOT NULL,
    SEG_NF    USEG_NF    DEFAULT '' NOT NULL,
    UWY_NF    UUWY_NF    NOT NULL,
    SEG_LL    UL64       NULL,
    CUR_CF    UCUR_CF    NOT NULL,
    SEGNAT_CT char(1)    NULL,
    CTRRET_B  bit        DEFAULT 0 NOT NULL,
    PRMAMT_M  UAMT_M     NULL,
    CLMAMT_M  UAMT_M     NULL,
    LOSRAT_R  USHORAT_R  NULL,
    AMORAT_CT char(1)    DEFAULT '' NOT NULL
)

CREATE TABLE #TCTRGRO_ERR
(
    CTR_NF    UCTR_NF    NOT NULL,
    END_NT    UEND_NT    NOT NULL,
    SEC_NF    USEC_NF    NOT NULL,
    SSD_CF    USSD_CF    NOT NULL,
    SEGTYP_CT USEGTYP_CT DEFAULT '' NOT NULL,
    SEG_NF    USEG_NF    DEFAULT '' NOT NULL
)

CREATE TABLE #TCTRGRO_UPD
(
    CTR_NF    UCTR_NF    NOT NULL,
    SEC_NF    USEC_NF    NOT NULL,
    SSD_CF    USSD_CF    NOT NULL,
    SEGTYP_CT USEGTYP_CT DEFAULT '' NOT NULL,
    SEG_NF    USEG_NF    DEFAULT '' NOT NULL
)

DECLARE @max_uwy 	integer
Declare @CurrentYear Integer
Select @CurrentYear = Year(Getdate())


set arithabort numeric_truncation off

BEGIN TRANSACTION
/***********************************************************************/
/*      On ajoute à TCTRGRO les enregistrements de TSEGPOR qui ne sont */
/*      pas encore dans TCTRGRO pour les segments de l'actuariat de	 */
/*      SCOR REASSURANCE uniquement (SEGMENT BALAI )		    	 */
/***********************************************************************/
INSERT
	BSAR..TCTRGRO
SELECT
	CTR_NF,
	END_NT,
	SEC_NF,
	SSD_CF,
	SEGTYP_CT,
	"SBALAI"+CTRNAT_CT+convert(char(1), CTRRET_B)
FROM
	BSAR..TSEGPOR B
WHERE
	( B.SEGTYP_CT = @segtyp_ct ) AND
	( B.SSD_CF = @ssd_cf ) AND
	( NOT EXISTS ( SELECT
				1
			FROM
				BSAR..TCTRGRO A
			WHERE
				( A.CTR_NF = B.CTR_NF ) AND
				( A.END_NT = B.END_NT ) AND
				( A.SEC_NF = B.SEC_NF ) AND
				( A.SEGTYP_CT = B.SEGTYP_CT ) AND
				( A.SSD_CF = B.SSD_CF ) 
		     )
	)

IF ( @@error != 0 ) GOTO ERREUR

/***********************************************************************/
/*      On ajoute le segment balai à TSEGEST                           */
/*      avec S/P = 100% 							 */
/*      et exercice = max(ex existant) + 2				 */
/*										 */
/***********************************************************************/

SELECT @max_uwy = max(UWY_NF)+2 FROM BSAR..TSEGEST WHERE SSD_CF=@ssd_cf AND SEGTYP_CT=@segtyp_ct
If (@max_uwy = Null) 
begin
    Select @max_uwy = @CurrentYear
end 

INSERT INTO #TMpTSEGEST
(SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, SEG_LL, CUR_CF, SEGNAT_CT, CTRRET_B, PRMAMT_M, CLMAMT_M, LOSRAT_R, AMORAT_CT)
SELECT DISTINCT
	A.SSD_CF,
	A.SEGTYP_CT,
	A.SEG_NF,
	@max_uwy,
       "BALAI SEGMENT ACCEPTANCE "+CTRNAT_CT+convert(char(1), B.CTRRET_B),
	C.SSDCUR_CF,
	B.CTRNAT_CT,
	B.CTRRET_B,
	NULL,
	NULL,
	1.00,
	"R"
FROM
	BSAR..TCTRGRO A,
	BSAR..TSEGPOR B,
	BREF..TSUBSID C
WHERE
	( A.CTR_NF = B.CTR_NF ) AND
	( A.END_NT = B.END_NT ) AND
	( A.SEC_NF = B.SEC_NF ) AND
	( A.SEGTYP_CT = B.SEGTYP_CT ) AND
	( A.SSD_CF = @ssd_cf ) AND
	( A.SEGTYP_CT = @segtyp_ct ) AND
	( A.SEG_NF like "SBALAI%" ) AND
	( A.SSD_CF = C.SSD_CF )
               
IF ( @@error != 0 ) GOTO ERREUR


DELETE #TMpTSEGEST
FROM #TMpTSEGEST A
 WHERE EXISTS (SELECT 1 FROM BSAR..TSEGEST B
               WHERE A.SSD_CF = B.SSD_CF and 
                     A.SEGTYP_CT = B.SEGTYP_CT and
                     A.SEG_NF = B.SEG_NF and 
                     A.UWY_NF = B.UWY_NF
               )
IF ( @@error != 0 ) GOTO ERREUR

							
INSERT
	BSAR..TSEGEST
SELECT SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, SEG_LL, 
       CUR_CF, SEGNAT_CT, CTRRET_B, PRMAMT_M, CLMAMT_M, LOSRAT_R, AMORAT_CT
FROM  #TMpTSEGEST
IF ( @@error != 0 ) GOTO ERREUR



COMMIT TRANSACTION

BEGIN TRANSACTION

/***************************************************************/
/*  MODIF DU 26/06 - 				    		*/
/*  On repere et on élimine le caractère "Retour charriot" dos */
/*  si il existe en fin de seg_nf					*/
/***************************************************************/
UPDATE 
	BSAR..TCTRGRO 
SET
	SEG_NF=substring(SEG_NF,1,datalength(ltrim(SEG_NF))-1)
WHERE
	( SSD_CF=@ssd_cf ) AND
	( SEGTYP_CT = @segtyp_ct ) AND
	( convert(integer,convert(binary,substring(SEG_NF,datalength(ltrim(SEG_NF)),1))) = 218103808 )

IF ( @@error != 0 ) GOTO ERREUR


/***************************************************************/
/*  MODIF DU 26/06 - 				    		*/
/*  On met tout les seg_nf en majuscule				*/
/***************************************************************/
UPDATE 
	BSAR..TCTRGRO 
SET
	SEG_NF=upper(SEG_NF)
WHERE
	( SSD_CF=@ssd_cf ) AND
	( SEGTYP_CT = @segtyp_ct )

IF ( @@error != 0 ) GOTO ERREUR

-- Ajout Modifications MOD01 - 09/12/2004
-- MOD01 Récupération des Contrats en Erreur
INSERT INTO #TCTRGRO_ERR (CTR_NF, END_NT, SEC_NF, SSD_CF, SEGTYP_CT, SEG_NF)
SELECT CTR_NF, END_NT, SEC_NF, SSD_CF, SEGTYP_CT, SEG_NF
FROM BSAR..TCTRGRO A
WHERE EXISTS (SELECT 1 FROM BSAR..TCTRGRO B
              WHERE A.CTR_NF = B.CTR_NF
                -- and A.END_NT = B.END_NT
                and A.SEC_NF = B.SEC_NF
                and A.SSD_CF = B.SSD_CF
                and A.SEGTYP_CT = B.SEGTYP_CT
                and B.SEG_NF NOT LIKE ('SBALAI%')
             )
  AND A.SEG_NF LIKE ('SBALAI%')
  AND A.SSD_CF=@ssd_cf AND A.SEGTYP_CT = @segtyp_ct

 
-- MOD01 Récupération des Noms de SEGMENTS
INSERT INTO #TCTRGRO_UPD (CTR_NF, SEC_NF, SSD_CF, SEGTYP_CT, SEG_NF)
SELECT DISTINCT CTR_NF, SEC_NF, SSD_CF, SEGTYP_CT, SEG_NF
FROM BSAR..TCTRGRO  A
WHERE EXISTS (SELECT 1 FROM #TCTRGRO_ERR B
              WHERE A.CTR_NF = B.CTR_NF
                and A.SEC_NF = B.SEC_NF
                and A.SSD_CF = B.SSD_CF
                and A.SEGTYP_CT = B.SEGTYP_CT
             )
  AND A.END_NT = 0
  AND A.SEG_NF NOT LIKE ('SBALAI%')
  AND A.SSD_CF=@ssd_cf AND A.SEGTYP_CT = @segtyp_ct


-- MOD01 UPDATE des Noms de SEGMENTS 'BALAIS' par NOM de SEGMENT Correct
UPDATE BSAR..TCTRGRO
SET SEG_NF = B.SEG_NF
FROM BSAR..TCTRGRO A, #TCTRGRO_UPD B
WHERE A.CTR_NF = B.CTR_NF
  and A.SEC_NF = B.SEC_NF
  and A.SSD_CF = B.SSD_CF
  and A.SEGTYP_CT = B.SEGTYP_CT
  and A.SEG_NF <> B.SEG_NF
  and A.SEG_NF LIKE ('SBALAI%')
  AND A.SSD_CF=@ssd_cf AND A.SEGTYP_CT = @segtyp_ct
 
 -- FIN Des Modifications 09/12/2004
 

UPDATE 
	BSAR..TSEGEST
SET
	SEG_NF=upper(SEG_NF)
WHERE
	( SSD_CF=@ssd_cf ) AND
	( SEGTYP_CT = @segtyp_ct )

IF ( @@error != 0 ) GOTO ERREUR


UPDATE 
	BSAR..TLABOCY
SET
	SEG_NF=upper(SEG_NF)
WHERE
	( SSD_CF=@ssd_cf ) AND
	( SEGTYP_CT = @segtyp_ct )

IF ( @@error != 0 ) GOTO ERREUR



/***************************************************************/
/*  MODIF DU 20/11/98 - 				    		*/
/*  On supprime dans TCTRGRO les lignes qui n'existe pas dans TSEGPOR */
/***************************************************************/
delete      BSAR..TCTRGRO 
from        BSAR..TCTRGRO B
WHERE
B.SEGTYP_CT = @segtyp_ct  	AND
B.SSD_CF = @ssd_cf  		AND
( NOT EXISTS ( 	SELECT 1
			FROM	BSAR..TSEGPOR  A
			WHERE	 A.CTR_NF = B.CTR_NF  AND
				 A.END_NT = B.END_NT  AND
				 A.SEC_NF = B.SEC_NF  AND
				 A.SEGTYP_CT = B.SEGTYP_CT  AND
				 A.SSD_CF = B.SSD_CF  
	     	)
)


IF ( @@error != 0 ) GOTO ERREUR



COMMIT TRANSACTION
RETURN 0

	ERREUR:
	ROLLBACK TRANSACTION
	RETURN -1

END
GO


IF OBJECT_ID('dbo.PiSEGBA_02') IS NOT NULL
BEGIN
	PRINT '<<< CREATED PROC dbo.PiSEGBA_02 >>>'
END
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiSEGBA_02 >>>'
GO
GRANT EXECUTE ON dbo.PiSEGBA_02 TO GOMEGA
go

