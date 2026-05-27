USE BEST
go
IF OBJECT_ID('PsLIFMOD2_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsLIFMOD2_01_O2
    IF OBJECT_ID('PsLIFMOD2_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsLIFMOD2_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsLIFMOD2_01_O2 >>>'
END
go
create procedure PsLIFMOD2_01_O2
  (
 @p_CTR_NF       UCTR_NF
,@p_SEC_NF       USEC_NF
,@p_BALSHEY_NF   smallint
,@p_BALSHTMTH_NF tinyint
,@p_CRE_D        datetime=null
,@p_RETRO_B      bit=0
,@p_LAG_CF       ULAG_CF          --Modif 9 add
,@p_usr_cf       UUSR_CF
,@p_ssd_cf       USSD_CF
,@p_esb_cf       UESB_CF
,@p_loading_b    bit
  )
with execute as caller as
/***************************************************
Domaine                   : Estimation
Base principale           : BEST
Auteur                    : Florent
Date de création          : 12/10/2004
Description du programme  : Estimations Vie, suivi du dépassement du seuil
Conditions d'éxécution    : par la dw d_seuil_lifmod2
Commentaires              : Requête croisée : Pour avoir les 7 acy_nf de ligne en colonne, utilisation du Case avec un group by
_________________
MODIFICATIONS
M  Auteur      Date       Description
1  Florent     15/11/2004 :spot:10260, on ne prend plus dans le regroupement 4 les postes de dépôts 2303,2304,2323,2324,1303,1304,1323,1324
2  GIBU        23/09/2005 Les montants en différence ne sont plus calculés dans la DW mais dans la proc.
3  GIBU        28/06/2006 Les postes CNA ne sont plus différenciés par filiale
4  GIBU        16/11/2007 :spot:14286 Ajout du poste 1011 (Primes liées à la sinistralité) qui doit être géré comme le 1010
5  Florent     05/06/2008 :spot:14205 debug recherche des derniers montants pour calcul positions
6  Florent     22/12/2008 :spot:16651 ajout de l'exe pour la séléction du dernier mois bilan !!
7  Florent     27/11/2009 :spot:17244 ajout de la VOBA et de poste cumul manquant dans la retro, libellé du poste 1450 pour le résultat financier comme sur la grille estimation
               25/01/2010 :spot:17244 groupe 3 devient le 4 et le 3 (RT + CNA) devient le 4
8  Tony        15/10/2010 Remettre la modif 6
                  _________________
MODIFICATION 9
 
Auteur: J.CHOCHON
 
Date: 10/07/2012
 
Version:
 
Description: The table TACMTRSH is now obsolet
              TACMTRSH --> TACMTRSL
              TACMTRSH.ACMTRS_LL --> TACMTRSL.ACMTRS_GL
                                _________________
MODIFICATION 10
Author: C. CROS
Date: 19/06/2013
Version: OMEGA2 - Branch1A
 
Description: Divide by 1000 the amount diff and threshold are no longer necessary
 
MODIFICATION 11
Auhtor : Amit Deshpande
Description -  Added GAAP for SGLA 06 and extension of 2 years for SGLA06

MODIFICATION 12
Auhtor : Pierre Colle
Description -  Optimisation of the SP response from TLIFEST
Spliting the double max request (cre_d and Balshmth) on TLIFEST to 3 requests with temp tables

MODIFICATION 13
Auhtor : Kirtishekhar Bagwe
Description -  Tran13 changes

MODIFICATION 14
Auhtor : Manoja Swaro
Description -  TLoading file upload fix - Test it in the file upload context (with 2 different uwy_nf , same ctr/sec as input)

MODIFICATION 15
Auhtor : Sumit Gupta
Description -  Commented out the condition for threshold(SEUIL_M) where it is set to 0 for spira

MODIFICATION 16
Auhtor : Manoja swaro
Description -  order by CTR_NF,SEC_NF,ACMTRS_NT,GAAP_NT for File upload in case of multiple ctr_nf,Sec_Nf

MODIFICATION 17
Auhtor : KBagwe
Description -  Optimisation of the SP response from TLIFEST. Modified indexes.

MODIFICATION 18
Auhtor : GLeclerc
Description -  Optimisation of the SP response from TLIFEST. Modified indexes.

MODIFICATION 19
Author : GLeclerc
Description - When 2 UWY have 2 different ACCADMTYP_CT, #TLOADING have duplicated CTR_NF/SEC_NF
*****************************************************/
declare
  @erreur     integer
,@lignes     integer
,@STAT_REP_D datetime
,@SEUIL_M    UAMT_M
,@SSD_CF     USSD_CF
,@ESB_CF     UESB_CF
,@CURLIF_CF  UCUR_CF
,@CURCTR_CF  UCUR_CF
,@current_balshtyear Datetime
,@TYPPER  Char(1)
,@BLCSHTYEA_NF Smallint
 
Create table #TLOADING (
    CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NOT NULL,
   -- UWY_NF      UUWY_NF       NOT NULL, --14
    END_NT      UEND_NT       NOT NULL,
    UW_NT       UUW_NT        NOT NULL,
    SSD_CF      USSD_CF       NOT NULL,
    ESB_CF      UESB_CF       NOT NULL,
    USR_CF      UUSR_CF       NOT NULL,
   -- ACCADMTYP_CT UACCADMTYP_CT NULL, -- 19
    RETRO_B     bit           DEFAULT 0 NOT NULL,
     PROCE       smallint      DEFAULT 3 NOT NULL)
 
Create table #TMPCONTEXT (
    SSD_CF      USSD_CF       NOT NULL,
    ESB_CF      UESB_CF       NOT NULL,
    CURCTR_CF   UCUR_CF       NOT NULL,
    CURLIF_CF   UCUR_CF       NULL,
    CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NOT NULL
)
 
Create table #TLIFEST_AV (
  ACMTRS_NT  smallint
,CTR_NF     UCTR_NF null
,SEC_NF     USEC_NF null
,GAAP_NT tinyint null
,ESTMNT_M1  UAMT_M null
,ESTMNT_M2  UAMT_M null
,ESTMNT_M3  UAMT_M null
,ESTMNT_M4  UAMT_M null
,ESTMNT_M5  UAMT_M null
,ESTMNT_M6  UAMT_M null
,ESTMNT_M7  UAMT_M null
,ESTMNT_M8  UAMT_M null
,ESTMNT_M9  UAMT_M null
)
 
Create table #TLIFEST_AP (
  ACMTRS_NT  smallint
,CTR_NF     UCTR_NF null
,SEC_NF     USEC_NF null
,GAAP_NT tinyint null
,AESTMNT_M1  UAMT_M null
,AESTMNT_M2  UAMT_M null
,AESTMNT_M3  UAMT_M null
,AESTMNT_M4  UAMT_M null
,AESTMNT_M5  UAMT_M null
,AESTMNT_M6  UAMT_M null
,AESTMNT_M7  UAMT_M null
,AESTMNT_M8  UAMT_M null
,AESTMNT_M9  UAMT_M null
)
 
Create table #TMPEXISTINGTLIFMOD (
    CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NOT NULL,
    EXISTB      bit           DEFAULT 0,
    CUR_CF      UCUR_CF       NULL
)
 
Create table #THRESHOLD (
    SSD_CF      USSD_CF       NOT NULL,
    ESB_CF      UESB_CF       NOT NULL,
    SEUIL_M    UAMT_M         NULL,
     CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NOT NULL
)
 
create Table #LISTE
  (
  CTR_NF     UCTR_NF null
,SEC_NF     USEC_NF null
,ACMTRS_NT  smallint
,GAAP_NT tinyint null
,ESTMNT_M1  UAMT_M null
,ESTMNT_M2  UAMT_M null
,ESTMNT_M3  UAMT_M null
,ESTMNT_M4  UAMT_M null
,ESTMNT_M5  UAMT_M null
,ESTMNT_M6  UAMT_M null
,ESTMNT_M7  UAMT_M null
,ESTMNT_M8  UAMT_M null
,ESTMNT_M9  UAMT_M null
,COMACC_B1  bit default 0
,COMACC_B2  bit default 0
,COMACC_B3  bit default 0
,COMACC_B4  bit default 0
,COMACC_B5  bit default 0
,COMACC_B6  bit default 0
,COMACC_B7  bit default 0
,COMACC_B8  bit default 0
,COMACC_B9  bit default 0
,AESTMNT_M1 UAMT_M null
,AESTMNT_M2 UAMT_M null
,AESTMNT_M3 UAMT_M null
,AESTMNT_M4 UAMT_M null
,AESTMNT_M5 UAMT_M null
,AESTMNT_M6 UAMT_M null
,AESTMNT_M7 UAMT_M null
,AESTMNT_M8 UAMT_M null
,AESTMNT_M9 UAMT_M null
,ACMTRS_GL  varchar(64) NOT null 
 )
create Table #LISTE2
  (
  CTR_NF     UCTR_NF null
,SEC_NF     USEC_NF null
,GAAP_NT tinyint null
,COMACC_B  bit default 0
,PRIPRMAMT_M UAMT_M null
,PRIRESTECAMT_M UAMT_M null
,PRIRESDACAMT_M UAMT_M null
,PRIRESFINAMT_M UAMT_M null
,AFTPRMAMT_M UAMT_M null
,AFTRESTECAMT_M UAMT_M null
,AFTRESDACAMT_M UAMT_M null
,AFTRESFINAMT_M UAMT_M null 
 ,ACY_NF UUWY_NF NOT NULL
,ACMTRS_NT tinyint NOT NULL
)
create Table #ACMTRSNT(
     ACMTRS_NT tinyint NOT NULL
) 
 
create Table #TLIFDRI(
  CTR_NF     UCTR_NF null
,SEC_NF     USEC_NF null
,ACMTRS_NT  smallint
,GAAP_NT tinyint null
,COMACC_B1  bit default 0
,COMACC_B2  bit default 0
,COMACC_B3  bit default 0
,COMACC_B4  bit default 0
,COMACC_B5  bit default 0
,COMACC_B6  bit default 0
,COMACC_B7  bit default 0
,COMACC_B8  bit default 0
,COMACC_B9  bit default 0
)

-- Modif12 : add 3 optimisation tables, indexes are added after the insert statement
Create table #TLIFEST (
                DETTRNCOD_CF 	char(5),
				ACMTRS_NT		smallint,
				UWY_NF			UUWY_NF,
				ACY_NF			smallint,
				CTR_NF			UCTR_NF, 
				SEC_NF			USEC_NF,  
				CRE_D			datetime, 
				BALSHTMTH_NF	tinyint,  
				CUR_CF			UCUR_CF, 
				ESTMNT_M		UAMT_M NULL, 
				GAAP_NT			smallint,
                BEFORESTATREP_NT tinyint)


Create table #TLIFEST_BAL (
                DETTRNCOD_CF 	char(5),
				ACMTRS_NT		smallint,
				UWY_NF			UUWY_NF,
				ACY_NF			smallint,
				CTR_NF			UCTR_NF, 
				SEC_NF			USEC_NF,  
				CRE_D			datetime, 
				BALSHTMTH_NF	tinyint,  
				CUR_CF			UCUR_CF, 
				ESTMNT_M		UAMT_M NULL, 
				GAAP_NT			smallint,
                BEFORESTATREP_NT tinyint)
			
Create table #TLIFEST_CRED (
                DETTRNCOD_CF 	char(5),
				ACMTRS_NT		smallint,
				UWY_NF			UUWY_NF,
				ACY_NF			smallint,
				CTR_NF			UCTR_NF, 
				SEC_NF			USEC_NF,  
				CRE_D			datetime, 
				BALSHTMTH_NF	tinyint,  
				CUR_CF			UCUR_CF, 
				ESTMNT_M		UAMT_M NULL, 
				GAAP_NT			smallint,
                BEFORESTATREP_NT tinyint)

-- End Modif12
	

Create table #TLIFMOD2 (
  CTR_NF     UCTR_NF null
,SEC_NF     USEC_NF null
,ACMTRS_NT  smallint
,GAAP_NT tinyint null
,COMACC_B1  bit default 0
,COMACC_B2  bit default 0
,COMACC_B3  bit default 0
,COMACC_B4  bit default 0
,COMACC_B5  bit default 0
,COMACC_B6  bit default 0
,COMACC_B7  bit default 0
,COMACC_B8  bit default 0
,COMACC_B9  bit default 0
,ESTMNT_M1  UAMT_M null
,ESTMNT_M2  UAMT_M null
,ESTMNT_M3  UAMT_M null
,ESTMNT_M4  UAMT_M null
,ESTMNT_M5  UAMT_M null
,ESTMNT_M6  UAMT_M null
,ESTMNT_M7  UAMT_M null
,ESTMNT_M8  UAMT_M null
,ESTMNT_M9  UAMT_M null
,AESTMNT_M1 UAMT_M null
,AESTMNT_M2 UAMT_M null
,AESTMNT_M3 UAMT_M null
,AESTMNT_M4 UAMT_M null
,AESTMNT_M5 UAMT_M null
,AESTMNT_M6 UAMT_M null
,AESTMNT_M7 UAMT_M null
,AESTMNT_M8 UAMT_M null
,AESTMNT_M9 UAMT_M null
)
-- Step1 : Define the Stored procedure perimeter (perimeter based on: ctr - sec)
-- Description:
-- In case of File loading the perimeter is retrieved from the table containing the list of CTR / SEC to load (BTRAV..EST_ESID0811_PERIMETER )
-- In case of GUI call the perimeter is only the CTR / SEC given in stored procedure input parameters
-- INput:
-- Case1: List of CTR/SEC from BTRAV..EST_ESID0811_PERIMETER 
-- Case2: a single CTR/SEC from input parameters
-- OUTput: temporary table #TLOADING
-- -- DEsc: this table contains the Stored procedure perimeter (perimeter based on: ctr - sec) which will be used in the whole procedure (JOIN perimeter) 
-- -- Example:
-- CTR_NF SEC_NF    UWY_NF    END_NT    UW_NT     SSD_CF    ESB_CF    USR_CF     ACCADMTYP_CT  RETRO_B   PROCE
-- 04T004241  1    2013 0    1    4    1    B540 2    0    4
-- 04T000699  1    2013 0    1    4    1    B540 1    0    3
 
 
 /* We are using BREF..PsCALEND_02 to get the current Balance sheet year (@BLCSHTYEA_NF)  - MOD13*/
select @current_balshtyear = getdate(), @TYPPER = 'C'
execute @erreur = BREF..PsCALEND_02 @current_balshtyear, @TYPPER, @BLCSHTYEA_NF output
 
if @erreur != 0
    begin
        Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND"
        return @erreur
    end 

 
IF (@p_loading_b = 1)
begin
Insert into #TLOADING
Select    Distinct    CTR_NF,
                    SEC_NF,
                  --  UWY_NF, --14
                    END_NT,
                    UW_NT,
                    SSD_CF,
                    ESB_CF,
                    USR_CF,
                   -- ACCADMTYP_CT, --19
                    RETRO_B,
                        PROCE
FROM BTRAV..EST_ESID0811_PERIMETER 
WHERE 
USR_CF = @p_usr_cf AND
SSD_CF = @p_ssd_cf AND
ESB_CF = @p_esb_cf AND
ERRORCODE_CT = null
 
 
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLOADING"
        return @erreur
    end
end
ELSE
Begin
Insert into #TLOADING ( CTR_NF, SEC_NF, 
--UWY_NF, --14
 END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF, 
 --ACCADMTYP_CT, -- 19
 RETRO_B, PROCE) 
        VALUES (@p_ctr_nf,@p_sec_nf,
		--0, --14
		0,1,@p_ssd_cf,@p_esb_cf,@p_usr_cf,
		-- 1 -- 19,
		@p_RETRO_B, 4)
End
 
CREATE INDEX TLOADING_00 ON #TLOADING(CTR_NF, END_NT, SEC_NF, UW_NT)
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLOADING"
        return @erreur
    end
	
Insert into #TMPCONTEXT
SELECT 
    ret.SSD_CF,
    ret.ESB_CF,
    ret.RETPCPCUR_CF AS CURCTR_CF,
    NULL,
    l.CTR_NF,
    l.SEC_NF
FROM BRET..TRETCTR ret, #TLOADING l
WHERE
    l.RETRO_B = 1 AND
    ret.RETCTR_NF = l.CTR_NF AND
    ret.RTY_NF=(select max(RTY_NF) from BRET..TRETCTR c where c.RETCTR_NF=l.ctr_nf and RETCTRSTS_CT in(3,19))
 
Insert into #TMPCONTEXT
SELECT 
    tc.SSD_CF,
    tc.ACCESB_CF,
    sec.PCPCUR_CF AS CURCTR_CF,
    NULL,
    l.CTR_NF,
    l.SEC_NF
FROM BTRT..TCONTR tc, #TLOADING l, BTRT..TSECTION sec
WHERE
    l.RETRO_B = 0 AND
    tc.ctr_nf = l.ctr_nf AND
    tc.UWY_NF=(select max(UWY_NF) from BTRT..TCONTR c where c.CTR_NF=l.ctr_nf and CTRSTS_CT in(14,16,17,19)) AND
    sec.ctr_nf = l.ctr_nf AND
    sec.sec_nf = l.sec_nf AND
    sec.uwy_nf = (select max(UWY_NF) from BTRT..TSECTION c where c.CTR_NF=l.ctr_nf and SEC_NF=l.SEC_NF and SECSTS_CT in(14,16,17,19))
 
-- Modif 9 : SSD_CF n'est pas dans TACMTRSL, on prend donc le LAG_CF
 
INSERT INTO #ACMTRSNT values (1) 
INSERT INTO #ACMTRSNT values (2) 
INSERT INTO #ACMTRSNT values (3) 
INSERT INTO #ACMTRSNT values (4)
 
-- This Steps inserts one row per ACMTRS_NT per GAAP
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 1,1, ta.ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where ta.PRS_CF=500 and ta.ACMTRS_NT=1010 and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf 
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 2,1, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=1400 and ta.LAG_CF = @P_LAG_CF  AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf 
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 3,1, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2450 else 1450 end) and ta.LAG_CF = @P_LAG_CF  AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 4,1, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2460 else 1460 end) and ta.LAG_CF = @P_LAG_CF  AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
 
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 1,2, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=1010 and ta.LAG_CF = @P_LAG_CF  AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 2,2, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=1400 and ta.LAG_CF = @P_LAG_CF  AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 3,2, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2450 else 1450 end) and ta.LAG_CF = @P_LAG_CF  AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 4,2, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2460 else 1460 end) and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
 
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 1,3, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT= 1010 and ta.LAG_CF = @P_LAG_CF  AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 2,3, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT= 1400 and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 3,3, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2450 else 1450 end) and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 4,3, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta,#TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2460 else 1460 end) and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
 
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 1,4, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta, #TLOADING tl where PRS_CF=500 and ACMTRS_NT=1010 and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 2,4, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta, #TLOADING tl where PRS_CF=500 and ACMTRS_NT=1400 and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 3,4, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta, #TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2450 else 1450 end) and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 4,4, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta, #TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2460 else 1460 end) and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
 
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 1,5, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta, #TLOADING tl where PRS_CF=500 and ACMTRS_NT= 1010 and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 2,5, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta, #TLOADING tl where PRS_CF=500 and ACMTRS_NT= 1400 and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 3,5, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta, #TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2450 else 1450 end) and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
insert #LISTE(ACMTRS_NT,GAAP_NT,ACMTRS_GL, CTR_NF, SEC_NF) select DISTINCT 4,5, ACMTRS_GL, tl.CTR_NF, tl.SEC_NF from BREF..TACMTRSL ta, #TLOADING tl where PRS_CF=500 and ACMTRS_NT=(case when tl.RETRO_B=1 then 2460 else 1460 end) and ta.LAG_CF = @P_LAG_CF AND tl.USR_CF = @p_usr_cf AND tl.SSD_CF = @p_ssd_cf AND tl.ESB_CF = @p_esb_cf  
 

CREATE UNIQUE CLUSTERED INDEX ILISTE_00			--Mod17
    ON #LISTE(ACMTRS_NT,GAAP_NT,CTR_NF, SEC_NF)
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#LISTE"
        return @erreur
    end
	
Select TOP 1 @SSD_CF = SSD_CF FROM #TMPCONTEXT
Select TOP 1 @ESB_CF = ESB_CF FROM #TMPCONTEXT
 
select @STAT_REP_D=max(CRE_D)
from TREQJOB
  where SSD_CF=@SSD_CF
    and REQCOD_CT='L'
    and BALSHEYEA_NF=1900
    and BALSHTMTH_NF=1
    and CLODAT_D='19000101'
 
select @SEUIL_M=AMT_M from TLIFTHR where SSD_CF=@SSD_CF and ESB_CF=@ESB_CF -- en cours de la devise filiale
 
 
-- On regarde dans TLIFMOD2 si le mouvement existe sinon dans TLIFEST2
Insert into #TMPEXISTINGTLIFMOD
select DISTINCT tl.CTR_NF, tl.SEC_NF, CASE WHEN tlif2.CTR_NF is null THEN 0 ELSE 1 END, tlif.CUR_CF
from #TLOADING tl
LEFT OUTER JOIN TLIFMOD2 tlif2 ON
    tlif2.CTR_NF=tl.CTR_NF 
and tlif2.SEC_NF=tl.SEC_NF 
and tlif2.BALSHEY_NF=@p_BALSHEY_NF 
and tlif2.BALSHTMTH_NF=@p_BALSHTMTH_NF 
and tlif2.CRE_D=@p_CRE_D
LEFT OUTER JOIN TLIFMOD tlif ON
    tlif.CTR_NF=tl.CTR_NF 
and tlif.SEC_NF=tl.SEC_NF 
and tlif.BALSHEY_NF=@p_BALSHEY_NF 
and tlif.BALSHTMTH_NF=@p_BALSHTMTH_NF 
and tlif.CRE_D=@p_CRE_D
 
CREATE CLUSTERED INDEX ITMPEXISTINGTLIFMOD_00				--Mod17
    ON #TMPEXISTINGTLIFMOD(CTR_NF, SEC_NF)
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TMPEXISTINGTLIFMOD"
        return @erreur
    end
	
-- IF A MVT FILE EXIST for this CRE_D (for example in History of update case)
INSERT INTO #LISTE2
     select
       a.CTR_NF
      ,a.SEC_NF
       ,a.GAAP_NT --Added GAAP_NT
      ,a.COMACC_B 
       ,a.PRIPRMAMT_M
       ,a.PRIRESTECAMT_M
       ,a.PRIRESDACAMT_M
       ,a.PRIRESFINAMT_M
       ,a.AFTPRMAMT_M
       ,a.AFTRESTECAMT_M
       ,a.AFTRESDACAMT_M
       ,a.AFTRESFINAMT_M
       ,a.ACY_NF
       ,b.ACMTRS_NT 
       
      from TLIFMOD2 a, #LISTE b --, #TMPEXISTINGTLIFMOD c
       where 
            --c.EXISTB = 1
          --a.CTR_NF   =  c.CTR_NF
         --and a.SEC_NF   =  c.SEC_NF
           a.CTR_NF   =  b.CTR_NF
         and a.SEC_NF   =  b.SEC_NF
          and b.GAAP_NT  =  a.GAAP_NT
         and a.CRE_D    =  @p_CRE_D
          and a.ACY_NF BETWEEN @p_BALSHEY_NF -4 and @p_BALSHEY_NF +4
         and a.BALSHEY_NF     =  @p_BALSHEY_NF
         and a.BALSHTMTH_NF   =  @p_BALSHTMTH_NF
          
insert into #TLIFMOD2 
select
          b.CTR_NF
          ,b.SEC_NF
          ,b.ACMTRS_NT
          ,b.GAAP_NT --Added GAAP_NT
          ,COMACC_B1 = ISNULL((select c.COMACC_B from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF -4 and c.gaap_nt = b.gaap_nt),0)
          ,COMACC_B2 = ISNULL((select c.COMACC_B from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF -3 and c.gaap_nt = b.gaap_nt),0)
          ,COMACC_B3 = ISNULL((select c.COMACC_B from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF -2 and c.gaap_nt = b.gaap_nt),0)
          ,COMACC_B4 = ISNULL((select c.COMACC_B from  #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF -1 and c.gaap_nt = b.gaap_nt),0)
          ,COMACC_B5 = ISNULL((select c.COMACC_B from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF    and c.gaap_nt = b.gaap_nt),0)
          ,COMACC_B6 = ISNULL((select c.COMACC_B from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF +1 and c.gaap_nt = b.gaap_nt),0)
          ,COMACC_B7 = ISNULL((select c.COMACC_B from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF +2 and c.gaap_nt = b.gaap_nt),0)
          ,COMACC_B8 = ISNULL((select c.COMACC_B from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF +3 and c.gaap_nt = b.gaap_nt),0)
          ,COMACC_B9 = ISNULL((select c.COMACC_B from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF = @p_BALSHEY_NF +4 and c.gaap_nt = b.gaap_nt),0)
          ,ESTMNT_M1 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF - 4 and c.gaap_nt = b.gaap_nt)
          ,ESTMNT_M2 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF - 3 and c.gaap_nt = b.gaap_nt)
          ,ESTMNT_M3 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF - 2 and c.gaap_nt = b.gaap_nt)
          ,ESTMNT_M4 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF - 1 and c.gaap_nt = b.gaap_nt)
          ,ESTMNT_M5 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF       and c.gaap_nt = b.gaap_nt)
          ,ESTMNT_M6 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF + 1 and c.gaap_nt = b.gaap_nt)
          ,ESTMNT_M7 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF + 2 and c.gaap_nt = b.gaap_nt)
          ,ESTMNT_M8 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF + 3 and c.gaap_nt = b.gaap_nt)
          ,ESTMNT_M9 = (select (case when b.ACMTRS_NT = 1 then c.PRIPRMAMT_M when b.ACMTRS_NT = 2 then c.PRIRESTECAMT_M when b.ACMTRS_NT = 3 then c.PRIRESFINAMT_M when  b.ACMTRS_NT = 4 then c.PRIRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF + 4 and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M1 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF - 4 and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M2 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF - 3 and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M3 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF - 2 and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M4 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF - 1 and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M5 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF       and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M6 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF + 1 and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M7 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF + 2 and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M8 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF + 3 and c.gaap_nt = b.gaap_nt)
          ,AESTMNT_M9 = (select (case when b.ACMTRS_NT = 1 then c.AFTPRMAMT_M when b.ACMTRS_NT = 2 then c.AFTRESTECAMT_M when b.ACMTRS_NT = 3 then c.AFTRESFINAMT_M when  b.ACMTRS_NT = 4 then c.AFTRESDACAMT_M end) from #LISTE2 c where c.ACMTRS_NT = a.ACMTRS_NT and c.ACY_NF =@p_BALSHEY_NF + 4 and c.gaap_nt = b.gaap_nt)
   from #ACMTRSNT a, #LISTE b
   WHERE
     A.ACMTRS_NT = B.ACMTRS_NT
          
     update #LISTE
      set COMACC_B1=b.COMACC_B1
         ,COMACC_B2=b.COMACC_B2
         ,COMACC_B3=b.COMACC_B3
         ,COMACC_B4=b.COMACC_B4
         ,COMACC_B5=b.COMACC_B5
         ,COMACC_B6=b.COMACC_B6
         ,COMACC_B7=b.COMACC_B7
         ,ESTMNT_M1=b.ESTMNT_M1
         ,ESTMNT_M2=b.ESTMNT_M2 
         ,ESTMNT_M3=b.ESTMNT_M3 
         ,ESTMNT_M4=b.ESTMNT_M4 
         ,ESTMNT_M5=b.ESTMNT_M5 
         ,ESTMNT_M6=b.ESTMNT_M6 
         ,ESTMNT_M7=b.ESTMNT_M7 
           ,ESTMNT_M8=b.ESTMNT_M8
          ,ESTMNT_M9=b.ESTMNT_M9
         ,AESTMNT_M1=b.AESTMNT_M1
         ,AESTMNT_M2=b.AESTMNT_M2
         ,AESTMNT_M3=b.AESTMNT_M3
         ,AESTMNT_M4=b.AESTMNT_M4
         ,AESTMNT_M5=b.AESTMNT_M5
         ,AESTMNT_M6=b.AESTMNT_M6
         ,AESTMNT_M7=b.AESTMNT_M7
          ,AESTMNT_M8=b.AESTMNT_M8
          ,AESTMNT_M9=b.AESTMNT_M9
          ,GAAP_NT = a.GAAP_NT   
       from #LISTE a, #TLIFMOD2 b, #TMPEXISTINGTLIFMOD c
        where  a.ACMTRS_NT=b.ACMTRS_NT
                   and c.EXISTB = 1
                   and a.CTR_NF   =  c.CTR_NF
                   and a.ctr_nf = b.ctr_nf
                   and b.ctr_nf = c.ctr_nf
                  and a.sec_nf = b.sec_nf
                   and b.GAAP_NT  =  a.GAAP_NT
				   
				   
                   
-- ELSE IF A MVT FILE DOES NOT EXISTS for this CRE_D
 
-- It checks if the contract is not present in TLIFMOD2 then it looks into TLIFDRI for the given contract,section, bal year/ month
   
   begin
   insert into #TLIFDRI
      select
        x.CTR_NF
       ,x.SEC_NF
       ,x.ACMTRS_NT
        ,x.GAAP_NT -- Added GAAP_NT for second case where contract is not present in TLIFMOD2
       ,COMACC_B1=max(case when a.ACY_NF=@p_BALSHEY_NF - 4 then a.COMACC_B else 0 end)
       ,COMACC_B2=max(case when a.ACY_NF=@p_BALSHEY_NF - 3 then a.COMACC_B else 0 end)
       ,COMACC_B3=max(case when a.ACY_NF=@p_BALSHEY_NF - 2 then a.COMACC_B else 0 end)
       ,COMACC_B4=max(case when a.ACY_NF=@p_BALSHEY_NF - 1 then a.COMACC_B else 0 end)
       ,COMACC_B5=max(case when a.ACY_NF=@p_BALSHEY_NF     then a.COMACC_B else 0 end)
       ,COMACC_B6=max(case when a.ACY_NF=@p_BALSHEY_NF + 1 then a.COMACC_B else 0 end)
       ,COMACC_B7=max(case when a.ACY_NF=@p_BALSHEY_NF + 2 then a.COMACC_B else 0 end)
        ,COMACC_B8=max(case when a.ACY_NF=@p_BALSHEY_NF + 3 then a.COMACC_B else 0 end)
        ,COMACC_B9=max(case when a.ACY_NF=@p_BALSHEY_NF + 4 then a.COMACC_B else 0 end)
       from TLIFDRI a, #LISTE x, #TMPEXISTINGTLIFMOD b
        where 
            b.EXISTB = 0 -- ExistB equals to zero when contract is not present in TLIFMOD2 with bal month, year and Cred
          and a.CTR_NF   =  b.CTR_NF
          and a.SEC_NF   =  b.SEC_NF
          and x.CTR_NF   =  b.CTR_NF
          and x.SEC_NF   =  b.SEC_NF
          and a.ACY_NF between @p_BALSHEY_NF - 4 and @p_BALSHEY_NF + 4
          and a.BALSHEY_NF=@p_BALSHEY_NF
          and a.BALSHTMTH_NF <= @p_BALSHTMTH_NF
          -- modif 5
          and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFDRI m
                               where m.ACY_NF=a.ACY_NF
                                 and m.CTR_NF=a.CTR_NF
                                 and m.SEC_NF=a.SEC_NF
                                 and m.BALSHEY_NF=a.BALSHEY_NF
                                 and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF)
          and a.COMACC_B=1
          and a.CRE_D=(select max(b.CRE_D) from TLIFDRI b
                                             where b.CTR_NF=a.CTR_NF
                                               and b.SEC_NF=a.SEC_NF
                                               and b.ACY_NF=a.ACY_NF
                                               and b.BALSHEY_NF=a.BALSHEY_NF
                                               and b.BALSHTMTH_NF=a.BALSHTMTH_NF)
      group by x.CTR_NF, X.SEC_NF, x.ACMTRS_NT,x.GAAP_NT
      order by x.CTR_NF, X.SEC_NF, x.ACMTRS_NT,x.GAAP_NT
 
      update #LISTE
      set   COMACC_B1=b.COMACC_B1,
            COMACC_B2=b.COMACC_B2,
            COMACC_B3=b.COMACC_B3,
            COMACC_B4=b.COMACC_B4,
            COMACC_B5=b.COMACC_B5,
            COMACC_B6=b.COMACC_B6,
            COMACC_B7=b.COMACC_B7,
              COMACC_B8=b.COMACC_B8,
              COMACC_B9=b.COMACC_B9
      from  #LISTE a, #TLIFDRI b, #TMPEXISTINGTLIFMOD c
      where     a.ACMTRS_NT=b.ACMTRS_NT
                   and c.EXISTB = 0
                   and a.CTR_NF = c.CTR_NF
                   and a.SEC_NF = c.SEC_NF
                   and a.CTR_NF = b.CTR_NF
                   and a.SEC_NF = b.SEC_NF
       
      -- si pas de lignes en base alors liste à partir de TLIFEST2
-- Create a table group which will fetch 5 digit transaction code to add it to a main #LISTE appending ACMTRS_NT PRS_CF is set to 569 for GUI      
      create Table #GROUPE(GP Tinyint, DETTRNCOD_CF char(5))
 
      --Primes
 
      Insert into #GROUPE
      Select distinct
            1,
            DETTRNCOD_CF
      FROM BREF..TSUBTRSBASE tb
      WHERE tb.ACMTRS_NT = 1010
       AND tb.PRS_CF = 569   
 
      --Résultat technique
      Insert into #GROUPE
      Select distinct
            2,
            DETTRNCOD_CF
      FROM BREF..TSUBTRSBASE tb
      WHERE tb.ACMTRS_NT = 1400
       AND tb.PRS_CF = 569
 
      --Résultat Tech. + Financier
      Insert into #GROUPE
      Select distinct
            3,
            DETTRNCOD_CF
      FROM BREF..TSUBTRSBASE tb,#TLOADING tld
      WHERE tb.ACMTRS_NT =1450
       AND tb.PRS_CF = 569   
       
      --Résultat Tech. + Financier + CNA + VOBA
      Insert into #GROUPE
      Select distinct
            4,
            DETTRNCOD_CF
      FROM BREF..TSUBTRSBASE tb,#TLOADING tldg
      WHERE tb.ACMTRS_NT = 1460 
       AND tb.PRS_CF = 569

CREATE INDEX TGROUPE_00				--Mod17
    ON #GROUPE(GP)
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#GROUPE"
        return @erreur
    end
	
-- Modif12 : we create a temp table (#TLIFEST) on a smaller perimeter

--DECLARE 
--    @StartTime datetime,
--    @Time1 datetime,
--    @Time2 datetime,
--    @Time3 datetime,
--    @Time4 datetime,
--    @Time5 datetime,
--    @Time6 datetime,
--    @Time7 datetime,
--    @Time8 datetime,
--    @EndTime datetime 
    
--SELECT @StartTime=GETDATE() 


IF @BLCSHTYEA_NF = @p_BALSHEY_NF						--Mod13
	Begin
		Insert into #TLIFEST
			Select 	t.DETTRNCOD_CF,
							t.ACMTRS_NT,
							t.UWY_NF,
							t.ACY_NF,
							t.CTR_NF, 
							t.SEC_NF,  
							t.CRE_D, 
							t.BALSHTMTH_NF,  
							t.CUR_CF, 
							t.ESTMNT_M,
							t.GAAP_NT,
							BEFORESTATREP_NT = CASE WHEN (t.CRE_D <= @STAT_REP_D) THEN 1 ELSE 0 END
			from   TLIFEST t, #TLOADING l
			where  l.CTR_NF = t.CTR_NF 
			and    l.SEC_NF = t.SEC_NF 
			and    l.END_NT = t.END_NT 
			and    l.UW_NT  = t.UW_NT 
			and    l.SSD_CF = @p_ssd_cf 
			and    l.ESB_CF = @p_esb_cf 
			and    l.USR_CF = @p_usr_cf
			and    t.acy_nf 	   <= @p_BALSHEY_NF + 4
			and    t.acy_nf 	   >= @p_BALSHEY_NF - 4
			and    t.balshey_nf    = @p_BALSHEY_NF
			and    t.balshtmth_nf  <= @p_BALSHTMTH_NF 
			
		-- Modif12 : for perf, the index is :
		-- created after the insert
		-- organized with BALSHTMTH_NF as the first key
	End
ELSE
	Begin
		Insert into #TLIFEST
			Select 			t.DETTRNCOD_CF,
							t.ACMTRS_NT,
							t.UWY_NF,
							t.ACY_NF,
							t.CTR_NF, 
							t.SEC_NF,  
							t.CRE_D, 
							t.BALSHTMTH_NF,  
							t.CUR_CF, 
							t.ESTMNT_M,
							t.GAAP_NT,
							BEFORESTATREP_NT = CASE WHEN (t.CRE_D <= @STAT_REP_D) THEN 1 ELSE 0 END
			from   TLIFEST_H t, #TLOADING l											--Mod13
			where  l.CTR_NF = t.CTR_NF 
			and    l.SEC_NF = t.SEC_NF 
			and    l.END_NT = t.END_NT 
			and    l.UW_NT  = t.UW_NT 
			and    l.SSD_CF = @p_ssd_cf 
			and    l.ESB_CF = @p_esb_cf 
			and    l.USR_CF = @p_usr_cf
			and    t.acy_nf 	   <= @p_BALSHEY_NF + 4
			and    t.acy_nf 	   >= @p_BALSHEY_NF - 4
			and    t.balshey_nf    = @p_BALSHEY_NF
			and    t.balshtmth_nf  <= @p_BALSHTMTH_NF 
			
		-- Modif12 : for perf, the index is :
		-- created after the insert
		-- organized with BALSHTMTH_NF as the first key
	End
	
	
CREATE CLUSTERED INDEX TLIFEST_00
    ON #TLIFEST(CTR_NF,SEC_NF,UWY_NF,ACY_NF,GAAP_NT,DETTRNCOD_CF,CRE_D,BEFORESTATREP_NT)				--Mod17
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFEST"
        return @erreur
    end
	
-- Modif12 
-- SELECT @Time1=GETDATE() 
-- SELECT "Before Bal",DATEDIFF(ms,@StartTime,@Time1) 
 Insert into #TLIFEST_BAL
 	Select 			a.DETTRNCOD_CF,
					a.ACMTRS_NT,
					a.UWY_NF,
                    a.ACY_NF,
					a.CTR_NF, 
					a.SEC_NF,  
					a.CRE_D, 
					a.BALSHTMTH_NF,  
					a.CUR_CF, 
					a.ESTMNT_M,
                    a.GAAP_NT,
                    a.BEFORESTATREP_NT
	        from   #TLIFEST a
       where   a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF)
                                 from #TLIFEST m
                                where m.ACY_NF=a.ACY_NF
                                  and m.ACMTRS_NT=a.ACMTRS_NT                                 
                                  and m.CTR_NF=a.CTR_NF
                                  and m.UWY_NF=a.UWY_NF  -- modif 6
                                  and m.SEC_NF=a.SEC_NF
                                  and m.gaap_nt = a.gaap_nt
                                  and m.DETTRNCOD_CF=a.DETTRNCOD_CF
                                  and m.BEFORESTATREP_NT = a.BEFORESTATREP_NT)

-- Modif12 : for perf, the index is :
-- created after the insert
-- organized with CRE_D as the first key
CREATE CLUSTERED INDEX TLIFEST_BAL_00				--Mod17
    ON #TLIFEST_BAL(DETTRNCOD_CF,UWY_NF,ACY_NF,CTR_NF,SEC_NF,BALSHTMTH_NF,GAAP_NT,BEFORESTATREP_NT)
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFEST_BAL"
        return @erreur
    end

-- Modif12 
--SELECT @Time2=GETDATE() 
--SELECT "Before Cre_d",DATEDIFF(ms,@StartTime,@Time2) 

  Insert into #TLIFEST_CRED
  Select 			a.DETTRNCOD_CF,
					a.ACMTRS_NT,
					a.UWY_NF,
					a.ACY_NF,
					a.CTR_NF, 
					a.SEC_NF,  
					a.CRE_D, 
					a.BALSHTMTH_NF,  
					a.CUR_CF, 
					a.ESTMNT_M,
					a.GAAP_NT,
                    a.BEFORESTATREP_NT
	        from    #TLIFEST_BAL a
       where   a.CRE_D=( select max(b.CRE_D)
								  from #TLIFEST_BAL b
                                  WHERE b.DETTRNCOD_CF=a.DETTRNCOD_CF			--Mod17
                                  and b.UWY_NF = a.UWY_NF
                                  and b.ACY_NF = a.ACY_NF
                                  and b.CTR_NF = a.CTR_NF
                                  and b.SEC_NF = a.SEC_NF  
                                  and b.BALSHTMTH_NF = a.BALSHTMTH_NF
                                  and b.gaap_nt = a.gaap_nt
                                  and b.BEFORESTATREP_NT = a.BEFORESTATREP_NT)

-- Modif12 : for perf, the index is :
--   created after the insert
--   organized with CRE_D as the first key

CREATE INDEX TLIFEST_CRED_00																--MOD 18
    ON #TLIFEST_CRED(BEFORESTATREP_NT,CTR_NF,SEC_NF,UWY_NF,ACY_NF,GAAP_NT,DETTRNCOD_CF)		--MOD 18
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFEST_CRED"
        return @erreur
    end

CREATE INDEX TLIFEST_CRED_01										--Mod17
          ON #TLIFEST_CRED(CTR_NF, SEC_NF, DETTRNCOD_CF,GAAP_NT)
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFEST_CRED"
        return @erreur
    end


-- Modif12 : uncomment to monitor time spent
-- SELECT @Time3=GETDATE() 
-- SELECT "Before tmp_context",DATEDIFF(ms,@StartTime,@Time3) 	 

    Update #TMPCONTEXT
    SET CURLIF_CF = max(a.CUR_CF)
        from   #TMPCONTEXT tmp, #TLIFEST_CRED a, #GROUPE x, #TMPEXISTINGTLIFMOD c
       where   
               tmp.SSD_CF = @p_ssd_cf
         and   tmp.ESB_CF = @p_esb_cf
         and   tmp.CTR_NF = c.CTR_NF
         and   tmp.SEC_NF = c.SEC_NF
         and   a.DETTRNCOD_CF=x.DETTRNCOD_CF
         and   c.EXISTB = 0
         and   a.CTR_NF=c.CTR_NF
         and   a.SEC_NF=c.SEC_NF
         and   a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
         and   a.BEFORESTATREP_NT = 1 -- modif12

                       
-- Modif12 : #TLIFEST_AV is deduced from #TLIFEST_CRED when a.BEFORESTATREP_NT = 1
-- uncomment to monitor time spent
-- SELECT @Time4=GETDATE() 
-- SELECT "Before #TLIFEST_AV",DATEDIFF(ms,@StartTime,@Time4) 

insert into #TLIFEST_AV
select
        ACMTRS_NT=x.GP
       ,c.CTR_NF
       ,c.SEC_NF 
        ,lg.GAAP_NT
       ,ESTMNT_M1=sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then a.ESTMNT_M end)
       ,ESTMNT_M2=sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then a.ESTMNT_M end)
       ,ESTMNT_M3=sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then a.ESTMNT_M end)
       ,ESTMNT_M4=sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then a.ESTMNT_M end)
       ,ESTMNT_M5=sum(case when a.ACY_NF=@p_BALSHEY_NF     then a.ESTMNT_M end)
       ,ESTMNT_M6=sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then a.ESTMNT_M end)
       ,ESTMNT_M7=sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then a.ESTMNT_M end)
       ,ESTMNT_M8=sum(case when a.ACY_NF=@p_BALSHEY_NF + 3 then a.ESTMNT_M end)
       ,ESTMNT_M9=sum(case when a.ACY_NF=@p_BALSHEY_NF + 4 then a.ESTMNT_M end)
       from #TLIFEST_CRED a, #GROUPE x, #TMPEXISTINGTLIFMOD c , #LISTE lg
       where 
              c.EXISTB = 0
          and a.CTR_NF = c.CTR_NF
          and a.SEC_NF = c.SEC_NF
          and x.GP = lg.ACMTRS_NT
          and a.DETTRNCOD_CF=x.DETTRNCOD_CF
          and a.GAAP_NT = lg.GAAP_NT
          and a.BEFORESTATREP_NT = 1
		  and a.CTR_NF = lg.CTR_NF
          and a.SEC_NF = lg.SEC_NF
      group by c.CTR_NF, c.SEC_NF, x.GP, lg.GAAP_NT
      order by 1
      
--select * from #TLIFEST_BAL a where a.ACY_NF=@p_BALSHEY_NF - 1 and a.GAAP_NT = 1 and a.CTR_NF = @p_CTR_NF and a.SEC_NF = @p_SEC_NF and a.CRE_D<=@STAT_REP_D 
--select * from #TLIFEST a where a.ACY_NF=@p_BALSHEY_NF - 1 and a.GAAP_NT = 1 and a.CTR_NF = @p_CTR_NF and a.SEC_NF = @p_SEC_NF and a.CRE_D<=@STAT_REP_D 


-- Modif12 : #TLIFEST_AV is deduced from #TLIFEST_CRED when a.LAST_NT = 1
-- uncomment to monitor time spent
-- SELECT @Time5=GETDATE() 
-- SELECT "Before #TLIFEST_AP",DATEDIFF(ms,@StartTime,@Time5) 


insert into #TLIFEST_AP
select
        ACMTRS_NT=x.GP
       ,c.CTR_NF
       ,c.SEC_NF 
        ,lg.GAAP_NT
       ,ESTMNT_M1=sum(case when a.ACY_NF=@p_BALSHEY_NF - 4 then a.ESTMNT_M end)
       ,ESTMNT_M2=sum(case when a.ACY_NF=@p_BALSHEY_NF - 3 then a.ESTMNT_M end)
       ,ESTMNT_M3=sum(case when a.ACY_NF=@p_BALSHEY_NF - 2 then a.ESTMNT_M end)
       ,ESTMNT_M4=sum(case when a.ACY_NF=@p_BALSHEY_NF - 1 then a.ESTMNT_M end)
       ,ESTMNT_M5=sum(case when a.ACY_NF=@p_BALSHEY_NF     then a.ESTMNT_M end)
       ,ESTMNT_M6=sum(case when a.ACY_NF=@p_BALSHEY_NF + 1 then a.ESTMNT_M end)
       ,ESTMNT_M7=sum(case when a.ACY_NF=@p_BALSHEY_NF + 2 then a.ESTMNT_M end)
       ,ESTMNT_M8=sum(case when a.ACY_NF=@p_BALSHEY_NF + 3 then a.ESTMNT_M end)
       ,ESTMNT_M9=sum(case when a.ACY_NF=@p_BALSHEY_NF + 4 then a.ESTMNT_M end)
       from #TLIFEST_CRED a, #GROUPE x, #TMPEXISTINGTLIFMOD c , #LISTE lg
       where 
              c.EXISTB = 0
          and a.CTR_NF = c.CTR_NF
          and a.SEC_NF = c.SEC_NF
          and x.GP = lg.ACMTRS_NT
          and a.DETTRNCOD_CF=x.DETTRNCOD_CF
          and a.GAAP_NT = lg.GAAP_NT
		  and a.CTR_NF = lg.CTR_NF
          and a.SEC_NF = lg.SEC_NF
          and a.CRE_D = (select max(b.CRE_D)
								  from #TLIFEST_CRED b
								 where b.CTR_NF = a.CTR_NF
								  and b.UWY_NF = a.UWY_NF
								  and b.SEC_NF = a.SEC_NF
								  and b.ACY_NF = a.ACY_NF
								  and b.BALSHTMTH_NF = a.BALSHTMTH_NF
								  and b.gaap_nt = a.gaap_nt
								  and b.DETTRNCOD_CF=a.DETTRNCOD_CF)
          and a.BALSHTMTH_NF = (select max(b.BALSHTMTH_NF)
								  from #TLIFEST_CRED b
								 where b.CTR_NF = a.CTR_NF
								  and b.UWY_NF = a.UWY_NF
								  and b.SEC_NF = a.SEC_NF
								  and b.ACY_NF = a.ACY_NF
								  and b.gaap_nt = a.gaap_nt
								  and b.DETTRNCOD_CF=a.DETTRNCOD_CF)
      group by c.CTR_NF, c.SEC_NF, x.GP,lg.GAAP_NT
      order by 1

      update #LISTE
       set COMACC_B1=b.COMACC_B1
          ,COMACC_B2=b.COMACC_B2
          ,COMACC_B3=b.COMACC_B3
          ,COMACC_B4=b.COMACC_B4
          ,COMACC_B5=b.COMACC_B5
          ,COMACC_B6=b.COMACC_B6
          ,COMACC_B7=b.COMACC_B7
          ,COMACC_B8=b.COMACC_B7
          ,COMACC_B9=b.COMACC_B7
        from #LISTE a, #TLIFDRI b, #TMPEXISTINGTLIFMOD c
      where     a.ACMTRS_NT=b.ACMTRS_NT
                   and c.EXISTB = 0
                   and a.CTR_NF = c.CTR_NF
                   and a.SEC_NF = c.SEC_NF
                   and a.CTR_NF = b.CTR_NF
                   and a.SEC_NF = b.SEC_NF
 
      update #LISTE
       set ESTMNT_M1=b.ESTMNT_M1
          ,ESTMNT_M2=b.ESTMNT_M2
          ,ESTMNT_M3=b.ESTMNT_M3
          ,ESTMNT_M4=b.ESTMNT_M4
          ,ESTMNT_M5=b.ESTMNT_M5
          ,ESTMNT_M6=b.ESTMNT_M6
          ,ESTMNT_M7=b.ESTMNT_M7
            ,ESTMNT_M8=b.ESTMNT_M8
            ,ESTMNT_M9=b.ESTMNT_M9
       from #LISTE a, #TLIFEST_AV b, #TMPEXISTINGTLIFMOD c
      where     a.ACMTRS_NT=b.ACMTRS_NT
                   and c.EXISTB = 0
                   and a.CTR_NF = c.CTR_NF
                   and a.SEC_NF = c.SEC_NF
                   and a.CTR_NF = b.CTR_NF
                   and a.SEC_NF = b.SEC_NF
                   and a.GAAP_NT = b.GAAP_NT
 
      update #LISTE
       set AESTMNT_M1=b.AESTMNT_M1
          ,AESTMNT_M2=b.AESTMNT_M2
          ,AESTMNT_M3=b.AESTMNT_M3
          ,AESTMNT_M4=b.AESTMNT_M4
          ,AESTMNT_M5=b.AESTMNT_M5
          ,AESTMNT_M6=b.AESTMNT_M6
          ,AESTMNT_M7=b.AESTMNT_M7
            ,AESTMNT_M8=b.AESTMNT_M8
            ,AESTMNT_M9=b.AESTMNT_M9
        from #LISTE a, #TLIFEST_AP b, #TMPEXISTINGTLIFMOD c
      where     a.ACMTRS_NT=b.ACMTRS_NT
                   and c.EXISTB = 0
                   and a.CTR_NF = c.CTR_NF
                   and a.SEC_NF = c.SEC_NF
                   and a.CTR_NF = b.CTR_NF
                   and a.SEC_NF = b.SEC_NF
                   and a.GAAP_NT = b.GAAP_NT
   End
-- FIN IF
 
 
 
 
Insert into #THRESHOLD
select   c.ssd_cf,
         c.esb_cf,
         (case when @SEUIL_M is null then null else (round(@SEUIL_M / b.EXC_R,3)) end) AS SEUIL_M, --MODIFICATION 15
         c.CTR_NF,
          c.SEC_NF
  from   #TMPCONTEXT c, BREF..TCURQUOT b
where   b.CUR_CF=isnull(c.CURLIF_CF, c.CURCTR_CF)
   and   b.SSD_CF=@p_ssd_cf
   and   b.EXC_D=( select  max(x.EXC_D)
                     from  BREF..TCURQUOT x
                    where  x.EXC_D<=isnull(@p_CRE_D,@STAT_REP_D)
                      and  x.CUR_CF=b.CUR_CF
                      and  x.SSD_CF=b.SSD_CF)

--SELECT * FROM #TLIFEST_CRED as a WHERE a.LAST_NT = 1 and a.GAAP_NT = 1 and a.ACY_NF = @p_BALSHEY_NF        
--SELECT * FROM #TLIFEST_AP
--SELECT * FROM #TLIFEST_AV

--if @SEUIL_M=null select @SEUIL_M=0 MODIFICATION 15

select
  l.CTR_NF
,l.SEC_NF
,l.ACMTRS_NT  
,l.GAAP_NT --GAAP NT
,l.ESTMNT_M1
,l.ESTMNT_M2
,l.ESTMNT_M3
,l.ESTMNT_M4
,l.ESTMNT_M5
,l.ESTMNT_M6
,l.ESTMNT_M7
,l.ESTMNT_M8
,l.ESTMNT_M9
,l.COMACC_B1
,l.COMACC_B2
,l.COMACC_B3
,l.COMACC_B4
,l.COMACC_B5
,l.COMACC_B6
,l.COMACC_B7
,l.COMACC_B8
,l.COMACC_B9
,AN1=@p_BALSHEY_NF - 4
,AN2=@p_BALSHEY_NF - 3
,AN3=@p_BALSHEY_NF - 2
,AN4=@p_BALSHEY_NF - 1
,AN5=@p_BALSHEY_NF
,AN6=@p_BALSHEY_NF + 1
,AN7=@p_BALSHEY_NF + 2
,AN8=@p_BALSHEY_NF + 3
,AN9=@p_BALSHEY_NF + 4
,l.AESTMNT_M1
,l.AESTMNT_M2
,l.AESTMNT_M3
,l.AESTMNT_M4
,l.AESTMNT_M5
,l.AESTMNT_M6
,l.AESTMNT_M7
,l.AESTMNT_M8
,l.AESTMNT_M9
,SEUIL_M = CASE WHEN t.SEUIL_M is NULL THEN @SEUIL_M ELSE t.SEUIL_M END
,l.ACMTRS_GL
,DIFF_M1=isnull(l.AESTMNT_M1,0) - isnull(l.ESTMNT_M1,0)
,DIFF_M2=isnull(l.AESTMNT_M2,0) - isnull(l.ESTMNT_M2,0)
,DIFF_M3=isnull(l.AESTMNT_M3,0) - isnull(l.ESTMNT_M3,0)
,DIFF_M4=isnull(l.AESTMNT_M4,0) - isnull(l.ESTMNT_M4,0)
,DIFF_M5=isnull(l.AESTMNT_M5,0) - isnull(l.ESTMNT_M5,0)
,DIFF_M6=isnull(l.AESTMNT_M6,0) - isnull(l.ESTMNT_M6,0)
,DIFF_M7=isnull(l.AESTMNT_M7,0) - isnull(l.ESTMNT_M7,0)
,DIFF_M8=isnull(l.AESTMNT_M8,0) - isnull(l.ESTMNT_M8,0)
,DIFF_M9=isnull(l.AESTMNT_M9,0) - isnull(l.ESTMNT_M9,0)
 From #LISTE l
 LEFT OUTER JOIN #THRESHOLD t ON
	l.CTR_NF = t.CTR_NF
	and l.SEC_NF = t.SEC_NF
--GROUP BY l.GAAP_NT
ORDER BY l.CTR_NF,l.SEC_NF,l.ACMTRS_NT,l.GAAP_NT --MODIFICATION 16
  

if object_id('#TLOADING')     is not null drop Table #TLOADING
if object_id('#TMPCONTEXT')     is not null drop Table #TMPCONTEXT
if object_id('#TMPEXISTINGTLIFMOD')     is not null drop Table #TMPEXISTINGTLIFMOD
if object_id('#THRESHOLD')     is not null drop Table #THRESHOLD
if object_id('#LISTE')     is not null drop Table #LISTE
if object_id('#TLIFEST')     is not null drop Table #TLIFEST
if object_id('#TLIFEST_BAL')     is not null drop Table #TLIFEST_BAL
if object_id('#TLIFEST_CRED')     is not null drop Table #TLIFEST_CRED
if object_id('#TLIFDRI')   is not null drop Table #TLIFDRI
if object_id('#TLIFMOD2')  is not null drop Table #TLIFMOD2
if object_id('#TLIFEST_AV')is not null drop Table #TLIFEST_AV
if object_id('#TLIFEST_AP')is not null drop Table #TLIFEST_AP
if object_id('#GROUPE')    is not null drop Table #GROUPE
if object_id('#GROUPE')    is not null drop Table #GROUPE
if object_id('#LISTE2')    is not null drop Table #LISTE2
if object_id('#ACMTRSNT')    is not null drop Table #ACMTRSNT
 
return 0
go
EXEC sp_procxmode 'PsLIFMOD2_01_O2', 'unchained'
go
IF OBJECT_ID('PsLIFMOD2_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFMOD2_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFMOD2_01_O2 >>>'
go
GRANT EXECUTE ON PsLIFMOD2_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFMOD2_01_O2 TO GDBBATCH
go
