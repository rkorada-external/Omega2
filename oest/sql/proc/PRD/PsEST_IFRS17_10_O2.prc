USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_10_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_10_O2
    IF OBJECT_ID('PsEST_IFRS17_10_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_10_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_10_O2 >>>'
END
go
create procedure PsEST_IFRS17_10_O2 
AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Riyadh
Creation date     : 09/07/2018

Description       : 
_________________
Modification: MOD1 
Author: Riyadh 
Date: 27/03/2019
Description: Spira 76818
_________________
Modification: MOD2
Author: S.Behague
Date: 26/03/2021
Description: Spira 92154 APOLO QE : GRID - Pas de beginning sur les postes de réserves pour ACY suivnant une ACY complete - Copy
_________________
*/


declare
        @error_type   int,
        @blcshtyea_nf smallint,
        @blcshtmth_nf tinyint,
        @TYPPER             Char(1),
        @DATE               Datetime,
        @SPCEND_D           Datetime,
        @ACCOUNT_D          Datetime,   
        @CLOSING_B          Bit  

Create table #TLIFDRI_ACYMIN (													
    CTR_NF        UCTR_NF    NOT NULL,
    ACYMIN_NF        smallint   NOT NULL)

Create table #POSTE_LIBERATION (
	  DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL)

Create table #TLIFEST_TEMP (													
    CTR_NF        UCTR_NF    NOT NULL,
    END_NT        UEND_NT    NOT NULL,
    SEC_NF        USEC_NF    NOT NULL,
    UWY_NF        UUWY_NF    NOT NULL,
    UW_NT         UUW_NT     NOT NULL,
    CRE_D         UUPD_D     NOT NULL,
    BALSHEY_NF    smallint   NOT NULL,
    BALSHTMTH_NF  tinyint    NOT NULL,
    ACY_NF        smallint   NOT NULL,
    GAAP_NT       tinyint    NOT NULL,
    DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
    ACM_NF        tinyint    DEFAULT 13 NOT NULL,
    PRS_CF        smallint   NOT NULL,
    ACMTRS_NT     smallint   NOT NULL,
    SSD_CF        USSD_CF    NOT NULL,
    CUR_CF        UCUR_CF    NOT NULL,
    ESTMNT_M      UAMT_M     NOT NULL,
    INDSUP_B      bit        DEFAULT 0  NOT NULL,
    ORICOD_LS     UL16       NULL,
    CREUSR_CF     UUPDUSR_CF NOT NULL,
    LSTUPD_D      UUPD_D     NOT NULL,
    LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
    ORICTR_NF     UCTR_NF    NULL,
    ORISEC_NF     USEC_NF    NULL,
    ORIUWY_NF     UUWY_NF    NULL,
    DIFF_M        UAMT_M     NULL,
    PROPAGATION_B bit        DEFAULT 0  NOT NULL,
    CALCULATED_B  bit        DEFAULT 0  NOT NULL,
    BATCH_B       bit        DEFAULT 0  NOT NULL)  
    
    Create table #TLIFEST_TEMP2 (													
    CTR_NF        UCTR_NF    NOT NULL,
    END_NT        UEND_NT    NOT NULL,
    SEC_NF        USEC_NF    NOT NULL,
    UWY_NF        UUWY_NF    NOT NULL,
    UW_NT         UUW_NT     NOT NULL,
    CRE_D         UUPD_D     NOT NULL,
    BALSHEY_NF    smallint   NOT NULL,
    BALSHTMTH_NF  tinyint    NOT NULL,
    ACY_NF        smallint   NOT NULL,
    GAAP_NT       tinyint    NOT NULL,
    DETTRNCOD_CF  char(5)    DEFAULT '' NOT NULL,
    ACM_NF        tinyint    DEFAULT 13 NOT NULL,
    PRS_CF        smallint   NOT NULL,
    ACMTRS_NT     smallint   NOT NULL,
    SSD_CF        USSD_CF    NOT NULL,
    CUR_CF        UCUR_CF    NOT NULL,
    ESTMNT_M      UAMT_M     NOT NULL,
    INDSUP_B      bit        DEFAULT 0  NOT NULL,
    ORICOD_LS     UL16       NULL,
    CREUSR_CF     UUPDUSR_CF NOT NULL,
    LSTUPD_D      UUPD_D     NOT NULL,
    LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
    ORICTR_NF     UCTR_NF    NULL,
    ORISEC_NF     USEC_NF    NULL,
    ORIUWY_NF     UUWY_NF    NULL,
    DIFF_M        UAMT_M     NULL,
    PROPAGATION_B bit        DEFAULT 0  NOT NULL,
    CALCULATED_B  bit        DEFAULT 0  NOT NULL,
    BATCH_B       bit        DEFAULT 0  NOT NULL,
    MAXCRE_D         UUPD_D      NULL)  
  
  
--MOD1 START

--SELECT  @blcshtyea_nf  = MIN(BLCSHTYEA_NF ) FROM BREF..TCALEND Where END_D > GETDATE()
--SELECT  @blcshtmth_nf  = MIN(BLCSHTMTH_NF ) FROM BREF..TCALEND Where END_D > GETDATE() AND BLCSHTYEA_NF  = @blcshtyea_nf

select @DATE   = getdate()
select @TYPPER = 'E'

execute @error_type = BREF..PsCALEND_02 @DATE ,
                                    @TYPPER ,
                                    @BLCSHTYEA_NF output,
                                    @BLCSHTMTH_NF output,
                                    @SPCEND_D     output,
                                    @ACCOUNT_D    output,
                                    @CLOSING_B    output
                                    
if @error_type != 0
begin
    Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND" /* erreur de lecture */
    return @error_type
end                                    
--MOD1 END




INSERT INTO #TLIFEST_TEMP 
SELECT DISTINCT L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D,BALSHEY_NF, BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,user,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B
FROM TLIFEST L, #TASSUMED A
WHERE L.CTR_NF = A.CTR_NF 
AND A.OLD_ESTCRB_CT = 'S' AND A.NEW_ESTCRB_CT = 'U'
AND L.ACY_NF NOT IN (SELECT DISTINCT ACY_NF FROM BCTA..TCPLACC C WHERE C.CTR_NF = L.CTR_NF )
AND  L.LSTUPD_D = (SELECT MAX(C.LSTUPD_D) FROM TLIFEST C where   C.DETTRNCOD_CF = L.DETTRNCOD_CF and C.acy_nf = L.acy_nf  and C.UWY_nf = L.UWy_nf  and C.CTR_NF = L.CTR_NF  and C.END_NT = L.END_NT and C.SEC_NF = L.SEC_NF and C.UW_NT = L.UW_NT and C.prs_cf = L.prs_cf and C.gaap_nt  = L.gaap_nt)
UNION
SELECT DISTINCT L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D,BALSHEY_NF, BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,user,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B
FROM TLIFEST L, #TASSUMED A
WHERE L.CTR_NF = A.CTR_NF 
AND A.OLD_ESTCRB_CT = 'S' AND A.NEW_ESTCRB_CT = 'U'
AND L.ACY_NF  IN (SELECT DISTINCT ACY_NF FROM BCTA..TCPLACC C WHERE C.CTR_NF = L.CTR_NF AND C.SCOENDMTH_NF <> 12)
AND  L.LSTUPD_D = (SELECT MAX(C.LSTUPD_D) FROM TLIFEST C where   C.DETTRNCOD_CF = L.DETTRNCOD_CF and C.acy_nf = L.acy_nf  and C.UWY_nf = L.UWy_nf  and C.CTR_NF = L.CTR_NF  and C.END_NT = L.END_NT and C.SEC_NF = L.SEC_NF and C.UW_NT = L.UW_NT and C.prs_cf = L.prs_cf and C.gaap_nt  = L.gaap_nt)AND  L.LSTUPD_D = (SELECT MAX(C.LSTUPD_D) FROM TLIFEST C where   C.DETTRNCOD_CF = L.DETTRNCOD_CF and C.acy_nf = L.acy_nf  and C.UWY_nf = L.UWy_nf  and C.CTR_NF = L.CTR_NF  and C.END_NT = L.END_NT and C.SEC_NF = L.SEC_NF and C.UW_NT = L.UW_NT and C.prs_cf = L.prs_cf and C.gaap_nt  = L.gaap_nt)              
UNION

SELECT DISTINCT L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D,BALSHEY_NF, BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,user,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B 
FROM TLIFEST L , #TRETRO R
WHERE L.CTR_NF = R.RETCTR_NF 
AND OLD_ESTCRB_CT = 'S' AND NEW_ESTCRB_CT = 'U'
AND L.ACY_NF  IN (SELECT DISTINCT retaccyer_nf FROM BRET..TRACCSEN R WHERE R.RETCTR_NF = L.CTR_NF AND R.ACCSENSTS_CT <>5 AND R.SCOENDMTH_NF <> 12 )
AND  L.LSTUPD_D = (SELECT MAX(C.LSTUPD_D) FROM TLIFEST C where   C.DETTRNCOD_CF = L.DETTRNCOD_CF and C.acy_nf = L.acy_nf  and C.UWY_nf = L.UWy_nf  and C.CTR_NF = L.CTR_NF  and C.END_NT = L.END_NT and C.SEC_NF = L.SEC_NF and C.UW_NT = L.UW_NT and C.prs_cf = L.prs_cf and C.gaap_nt  = L.gaap_nt)
--FROM STEP 8 CASE 1 : REMOVE ALL ESTIMATION (SET ESTIMATION TO 0) ESTIMATION CHANGE FROM O/V TO T

INSERT INTO #TLIFEST_TEMP
SELECT DISTINCT L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D,BALSHEY_NF, BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,user,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B
FROM TLIFEST L, #TASSUMED A
WHERE L.CTR_NF = A.CTR_NF 
AND A.OLD_ESTCRB_CT in ('O','V') AND A.NEW_ESTCRB_CT = 'T'
AND L.ACY_NF NOT IN (SELECT DISTINCT ACY_NF FROM BCTA..TCPLACC C WHERE C.CTR_NF = L.CTR_NF )
AND  L.LSTUPD_D = (SELECT MAX(C.LSTUPD_D) FROM TLIFEST C where   C.DETTRNCOD_CF = L.DETTRNCOD_CF and C.acy_nf = L.acy_nf  and C.UWY_nf = L.UWy_nf  and C.CTR_NF = L.CTR_NF  and C.END_NT = L.END_NT and C.SEC_NF = L.SEC_NF and C.UW_NT = L.UW_NT and C.prs_cf = L.prs_cf and C.gaap_nt  = L.gaap_nt)               
                    
UNION
SELECT DISTINCT L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D,BALSHEY_NF, BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,user,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B
FROM TLIFEST L, #TASSUMED A
WHERE L.CTR_NF = A.CTR_NF 
AND A.OLD_ESTCRB_CT in ('O','V') AND A.NEW_ESTCRB_CT = 'T'
AND L.ACY_NF  IN (SELECT DISTINCT ACY_NF FROM BCTA..TCPLACC C WHERE C.CTR_NF = L.CTR_NF AND C.SCOENDMTH_NF <> 12)
AND  L.LSTUPD_D = (SELECT MAX(C.LSTUPD_D) FROM TLIFEST C where   C.DETTRNCOD_CF = L.DETTRNCOD_CF and C.acy_nf = L.acy_nf  and C.UWY_nf = L.UWy_nf  and C.CTR_NF = L.CTR_NF  and C.END_NT = L.END_NT and C.SEC_NF = L.SEC_NF and C.UW_NT = L.UW_NT and C.prs_cf = L.prs_cf and C.gaap_nt  = L.gaap_nt)                  
UNION
SELECT Distinct L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D,BALSHEY_NF, BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,user,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B 
FROM TLIFEST L , #TRETRO R
WHERE L.CTR_NF = R.RETCTR_NF 
AND R.OLD_ESTCRB_CT in ('O','V') AND R.NEW_ESTCRB_CT = 'T'
AND L.ACY_NF  IN (SELECT DISTINCT retaccyer_nf FROM BRET..TRACCSEN R WHERE R.RETCTR_NF = L.CTR_NF AND R.ACCSENSTS_CT <>5 AND R.SCOENDMTH_NF <> 12 )
AND  L.LSTUPD_D = (SELECT MAX(C.LSTUPD_D) FROM TLIFEST C where   C.DETTRNCOD_CF = L.DETTRNCOD_CF and C.acy_nf = L.acy_nf  and C.UWY_nf = L.UWy_nf  and C.CTR_NF = L.CTR_NF  and C.END_NT = L.END_NT and C.SEC_NF = L.SEC_NF and C.UW_NT = L.UW_NT and C.prs_cf = L.prs_cf and C.gaap_nt  = L.gaap_nt)                  



 INSERT INTO #TLIFEST                   
 SELECT  * 
 FROM #TLIFEST_TEMP L
 GROUP BY
                    L.CTR_NF ,
                    L.END_NT ,
                    L.SEC_NF , 
                    L.UWY_NF ,
                    L.UW_NT ,
                    L.BALSHEY_NF ,
                    L.ACY_NF ,
                    L.ACMTRS_NT ,
                    L.GAAP_NT ,
                    L.DETTRNCOD_CF ,
                    
                    L.SSD_CF HAVING count(*)= 1

insert into #TLIFEST_TEMP2
SELECT  L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D,BALSHEY_NF, BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,user,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B, 
 (select MAX(CRE_D) FROM #TLIFEST_TEMP A where A.CTR_NF = L.CTR_NF and A.END_NT = L.END_NT  and A.SEC_NF = L.SEC_NF and A.UWY_NF = L.UWY_NF 
                                                                        and A.UW_NT = L.UW_NT and A.BALSHEY_NF = L.BALSHEY_NF and A.ACY_NF = L.ACY_NF and A.ACMTRS_NT = L.ACMTRS_NT
                                                                        and A.GAAP_NT = L.GAAP_NT and A.DETTRNCOD_CF = L.DETTRNCOD_CF and A.SSD_CF = L.SSD_CF )as MAXCRE_D
 FROM #TLIFEST_TEMP L
 GROUP BY
                    L.CTR_NF ,
                    L.END_NT ,
                    L.SEC_NF , 
                    L.UWY_NF ,
                    L.UW_NT ,
                    L.BALSHEY_NF ,
                    L.ACY_NF ,
                    L.ACMTRS_NT ,
                    L.GAAP_NT ,
                    L.DETTRNCOD_CF ,
                    L.SSD_CF HAVING count(*)> 1
                    
INSERT INTO #TLIFEST                   
select L.CTR_NF,END_NT,SEC_NF,L.UWY_NF,UW_NT,CRE_D,BALSHEY_NF, BALSHTMTH_NF, ACY_NF,GAAP_NT,DETTRNCOD_CF,ACM_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B, ORICOD_LS ,user,LSTUPD_D,  LSTUPDUSR_CF,ORICTR_NF, ORISEC_NF ,ORIUWY_NF, DIFF_M , PROPAGATION_B,CALCULATED_B,BATCH_B 
from  #TLIFEST_TEMP2  L
where CRE_D = MAXCRE_D
 
 
UPDATE #TLIFEST SET CRE_D = GETDATE() , LSTUPD_D = GETDATE(), ORICOD_LS = 'QE-RESET', ESTMNT_M = 0.000, LSTUPDUSR_CF = user ,  BALSHEY_NF=  @blcshtyea_nf,BALSHTMTH_NF =  @blcshtmth_nf

 
-- Effacement des libérations suivant la dernière année de compte complet 
INSERT INTO #TLIFDRI_ACYMIN
SELECT L.CTR_NF, max(L.ACY_NF)+1 FROM BEST..TLIFDRI L, #TLIFEST EST
WHERE L.CTR_NF = EST.CTR_NF
AND   L.COMACC_B = 1
GROUP BY L.CTR_NF

insert into #POSTE_LIBERATION select dettrncod2_CF from bref..tsubtrsasso where assotyp_ct = '1' and ctx_nt = 1

delete #TLIFEST from #TLIFEST l, #TLIFDRI_ACYMIN d, #POSTE_LIBERATION lib
where l.ctr_nf = d.ctr_nf
and     l.acy_nf = d.acymin_nf
and     l.dettrncod_cf = lib.DETTRNCOD_CF
 
GO

EXEC sp_procxmode 'PsEST_IFRS17_10_O2', 'unchained'
go

IF OBJECT_ID('PsEST_IFRS17_10_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_10_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_10_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_10_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_10_O2 TO GDBBATCH
go
