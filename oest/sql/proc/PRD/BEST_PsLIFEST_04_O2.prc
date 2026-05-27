USE BEST
go
IF OBJECT_ID('PsLIFEST_04_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsLIFEST_04_O2
    IF OBJECT_ID('PsLIFEST_04_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsLIFEST_04_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsLIFEST_04_O2 >>>'
END
go
/*
 * creation de la procedure
*/
create procedure PsLIFEST_04_O2 (
  @p_end_nt       UEND_NT,
  @p_sec_nf       USEC_NF,
  @p_uw_nt        UUW_NT,
  @p_uwy_nf       UUWY_NF,
  @p_ssd_cf       USSD_CF,
  @p_esb_cf         UESB_CF,
  @p_visu_mois	tinyint,
  @p_visu_an  	smallint,
  @p_lag_cf		ULAG_CF,
  @p_ctr_nf       UCTR_NF,
  @p_usr_cf UUSR_CF,
  @p_lower_bound_year smallint,
  @p_higher_bound_year smallint,
  @p_loading_b          bit)
with execute as caller as

/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : C. Cros
Creation date     : 12/12/2013

Description       :  Retrieve estimation grids according to a perimeter

Domain            : Estimate
Base              : BEST
Version           : 1
Author            : A.Deshpande
Creation date     : 17/07/2014

Description       :  For TRAN 13 evo card data will be inserted into TLIFEST if current balance sheet year equals visualized year and if not data will be inserted into TLIF_HISTO

Domain            : Estimate
Base              : BEST
Version           : 3
Author            : K.Bagwe
Creation date     : 02/09/2014

Description       :  Optimisation of the SP response from TLIFEST

Domain            : Estimate
Base              : BEST
Version           : 4
Author            : mswaro
Creation date     : 10/10/2014

Description       :  Acmtrs_nt is removed from index and joins for #30743 - Zero insert does not replace in some cases

Domain            : Estimate
Base              : BEST
Version           : 5
Author            : mswaro
Creation date     : 10/13/2014

Description       :  added UWY_NF in the order by clause in final selet for - #30743

Domain            : Estimate
Base              : BEST
Version           : 6
Author            : Sumit Gupta
Creation date     : 12/01/2015
Description       : change DACTYPE_B to DACVOBATYPE_CT for CR 032408

Domain            : Estimate
Base              : BEST
Version           : 7
Author            : Sumit Gupta
Creation date     : 11/03/2015
Description       : remove condition A.estmnt_m <> 0 for Defect spira #34627
*****************************************************/

declare @erreur int,
		@ACCADMTYP_CT  UACCADMTYP_CT,
		@UWY_NF UUWY_NF,
		@current_balshtyear Datetime,
		@TYPPER  Char(1),
		@BLCSHTYEA_NF Smallint

/***************************************************

Output Table - # TLOADING

Description - This temp table comes in the scope when we upload from estimate file upload and asynch job ESID0811 will be invoked

*****************************************************/


Create table #TLOADING (
    CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NOT NULL,
    UWY_NF      UUWY_NF       NOT NULL,
    END_NT      UEND_NT       NOT NULL,
    UW_NT       UUW_NT        NOT NULL,
    SSD_CF      USSD_CF       NOT NULL,
    ESB_CF      UESB_CF       NOT NULL,
    USR_CF      UUSR_CF       NOT NULL,
    ACCADMTYP_CT UACCADMTYP_CT NULL,
    RETRO_B     bit           DEFAULT 0 NOT NULL,
	PROCE       smallint      DEFAULT 3 NOT NULL)

/* Lifest r�duit                                    */

/***************************************************
Output table # TLIFEST

Description - This temp table is the output for the particular fields in TLIFEST
*****************************************************/
Create table #TLIFEST (
                DETTRNCOD_CF 		char(5),
				ACMTRS_NT		smallint,
				UWY_NF			UUWY_NF,
				ACY_NF			smallint,
				CTR_NF			UCTR_NF, 
				END_NT			UEND_NT, 
				SEC_NF			USEC_NF,  
				UW_NT			UUW_NT, 
				CRE_D			datetime, 
				BALSHEY_NF		smallint, 
				BALSHTMTH_NF	tinyint,  
				PRS_CF			smallint NULL,  
				SSD_CF			USSD_CF, 
				CUR_CF			UCUR_CF, 
				ESTMNT_M		UAMT_M NULL, 
				INDSUP_B		bit, 
				ORICOD_LS		varchar(16), 
				CREUSR_CF		UUSR_CF, 
				LSTUPD_D		datetime, 
				LSTUPDUSR_CF	UUSR_CF,  
				GAAP_NT			smallint,
				DIFF_M			UAMT_M NULL,
				PROPAGATION_B bit)

/* Montants estim�s                                 */
 
Create table #TLIFEST_BAL (										--MOD3
                DETTRNCOD_CF 		char(5),
				ACMTRS_NT		smallint,
				UWY_NF			UUWY_NF,
				ACY_NF			smallint,
				CTR_NF			UCTR_NF, 
				END_NT			UEND_NT, 
				SEC_NF			USEC_NF,  
				UW_NT			UUW_NT, 
				CRE_D			datetime, 
				BALSHEY_NF		smallint, 
				BALSHTMTH_NF	tinyint,  
				PRS_CF			smallint NULL,  
				SSD_CF			USSD_CF, 
				CUR_CF			UCUR_CF, 
				ESTMNT_M		UAMT_M NULL, 
				INDSUP_B		bit, 
				ORICOD_LS		varchar(16), 
				CREUSR_CF		UUSR_CF, 
				LSTUPD_D		datetime, 
				LSTUPDUSR_CF	UUSR_CF,  
				GAAP_NT			smallint,
				DIFF_M			UAMT_M NULL,
				PROPAGATION_B bit)

/***************************************************

OUTPUT TABLE -#montants_w Estimated amounts

*****************************************************/

Create table #montants_w (
                DETTRNCOD_CF 			char(5),
				ACMTRS_NT		smallint,
				UWY_NF			UUWY_NF,
				ACY_NF			smallint,
				CTR_NF			UCTR_NF, 
				END_NT			UEND_NT, 
				SEC_NF			USEC_NF,  
				UW_NT			UUW_NT, 
				CRE_D			datetime, 
				BALSHEY_NF		smallint, 
				BALSHTMTH_NF	tinyint,  
				PRS_CF			smallint,  
				SSD_CF			USSD_CF, 
				CUR_CF			UCUR_CF, 
				ESTMNT_M		UAMT_M NULL, 
				INDSUP_B		bit, 
				ORICOD_LS		varchar(16), 
				CREUSR_CF		UUSR_CF, 
				LSTUPD_D		datetime, 
				LSTUPDUSR_CF	UUSR_CF,  
				GAAP_NT			smallint,
				DIFF_M			UAMT_M NULL,
				PROPAGATION_B bit)

/*--------------------------------------------------*/
/* Maj exc souscription, montants dans #montants_w  */
/*--------------------------------------------------*/

/***************************************************

STEP 1

Description - This temp table comes in the scope when we upload from estimate file upload and asynch job ESID0811 will be invoked

Input - LOADING_B to to load data from BTRAV..EST_ESID0811_PERIMETER to temp table # Tloading

Output - # temporary table TLOADING

*****************************************************/

--DECLARE @Time1 datetime,@Time2 datetime,@Time3 datetime, @Time4 datetime, @Time5 datetime 
--SELECT @Time1=GETDATE() 

select  @ACCADMTYP_CT = ACCADMTYP_CT 
from    BTRT..TSECTION 
where   CTR_NF = @p_ctr_nf 
and     END_NT = @p_END_NT 
and     SEC_NF = @p_SEC_NF 
and     UW_NT  = @p_UW_NT 
and     UWY_NF = @UWY_NF

IF (@p_loading_b = 1)
begin
Insert into #TLOADING
SELECT DISTINCT	    
  CTR_NF,
  SEC_NF,
  UWY_NF,
  END_NT,
  UW_NT,
  SSD_CF,
  ESB_CF,
  USR_CF,
  ACCADMTYP_CT,
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
        goto fin
    end
end
ELSE
Begin
Insert into #TLOADING ( CTR_NF, SEC_NF, UWY_NF, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF, ACCADMTYP_CT, PROCE) 
        VALUES (@p_ctr_nf,@p_sec_nf,@p_uwy_nf,@p_end_nt,@p_uw_nt,@p_ssd_cf,@p_esb_cf,@p_usr_cf,@ACCADMTYP_CT, 4)
End

/* 1�re partie   */
/***************************************************

STEP 2

Description - 

Input - TLIFEST

Output - #TLIFEST

*****************************************************/


/* We are using BREF..PsCALEND_02 to get the current Balance sheet year (@BLCSHTYEA_NF) */
select @current_balshtyear = getdate(), @TYPPER = 'C'
execute @erreur = BREF..PsCALEND_02 @current_balshtyear, @TYPPER, @BLCSHTYEA_NF output

IF @BLCSHTYEA_NF = @p_visu_an 
BEGIN
Insert into #TLIFEST
Select 			t.DETTRNCOD_CF,
				t.ACMTRS_NT,
				t.UWY_NF,
				t.ACY_NF,
				t.CTR_NF, 
				t.END_NT, 
				t.SEC_NF,  
				t.UW_NT, 
				t.CRE_D, 
				t.BALSHEY_NF, 
				t.BALSHTMTH_NF,  
				t.PRS_CF,  
				t.SSD_CF, 
				t.CUR_CF, 
				t.ESTMNT_M, 
				t.INDSUP_B, 
				t.ORICOD_LS, 
				t.CREUSR_CF, 
				t.LSTUPD_D, 
				t.LSTUPDUSR_CF,  
				t.GAAP_NT,
				t.DIFF_M,
				t.PROPAGATION_B
from   TLIFEST t, #TLOADING l 
where  l.CTR_NF = t.CTR_NF 
and    l.SEC_NF = t.SEC_NF 
and    l.END_NT = t.END_NT 
and    l.UW_NT  = t.UW_NT
and    l.UWY_NF = t.UWY_NF 
and    l.SSD_CF = @p_ssd_cf 
and    l.ESB_CF = @p_esb_cf 
and    l.USR_CF = @p_usr_cf
and    l.PROCE  = 4
and    t.acy_nf 		 <= @p_visu_an + @p_higher_bound_year
and    t.acy_nf 		 >= @p_visu_an - @p_lower_bound_year
and    t.balshey_nf    = @p_visu_an
and    t.balshtmth_nf <= @p_visu_mois
END

ELSE 
	/* Else, we retrieve from TLIFEST_H */
     BEGIN
     	 Insert into #TLIFEST
Select 			t.DETTRNCOD_CF,
				t.ACMTRS_NT,
				t.UWY_NF,
				t.ACY_NF,
				t.CTR_NF, 
				t.END_NT, 
				t.SEC_NF,  
				t.UW_NT, 
				t.CRE_D, 
				t.BALSHEY_NF, 
				t.BALSHTMTH_NF,  
				t.PRS_CF,  
				t.SSD_CF, 
				t.CUR_CF, 
				t.ESTMNT_M, 
				t.INDSUP_B, 
				t.ORICOD_LS, 
				t.CREUSR_CF, 
				t.LSTUPD_D, 
				t.LSTUPDUSR_CF,  
				t.GAAP_NT,
				t.DIFF_M,
				t.PROPAGATION_B
from   TLIFEST_H t, #TLOADING l 
where  l.CTR_NF = t.CTR_NF 
and    l.SEC_NF = t.SEC_NF 
and    l.END_NT = t.END_NT 
and    l.UW_NT  = t.UW_NT
and    l.UWY_NF = t.UWY_NF 
and    l.SSD_CF = @p_ssd_cf 
and    l.ESB_CF = @p_esb_cf 
and    l.USR_CF = @p_usr_cf
and    l.PROCE  = 4
and    t.acy_nf 		 <= @p_visu_an + @p_higher_bound_year
and    t.acy_nf 		 >= @p_visu_an - @p_lower_bound_year
and    t.balshey_nf    = @p_visu_an
and    t.balshtmth_nf <= @p_visu_mois

END

--SELECT @Time2=GETDATE()   
--SELECT "Time2", DATEDIFF(ms,@Time1,@Time2)

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#liste"
        return @erreur
        goto fin
    end

/* 2�me partie   */

/***************************************************

STEP 3

Description - 

Input - temp table #TLIFEST A

Output - temp table #montants_w

*****************************************************/

CREATE CLUSTERED INDEX TLIFEST_TEMP_05
    ON #TLIFEST(DETTRNCOD_CF, UWY_NF, ACY_NF, CTR_NF,  END_NT, SEC_NF, UW_NT, PRS_CF,  GAAP_NT) --Mod4

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFEST"
        return @erreur
        goto fin
    end
--DROP INDEX #TLIFEST.TLIFEST_TEMP_05

Insert into #TLIFEST_BAL												--MOD3
Select 			A.DETTRNCOD_CF,
				A.ACMTRS_NT,
				A.UWY_NF,
				A.ACY_NF,
				A.CTR_NF, 
				A.END_NT, 
				A.SEC_NF,  
				A.UW_NT, 
				A.CRE_D, 
				A.BALSHEY_NF, 
				A.BALSHTMTH_NF,  
				A.PRS_CF,  
				A.SSD_CF, 
				A.CUR_CF, 
				A.ESTMNT_M, 
				A.INDSUP_B, 
				A.ORICOD_LS, 
				A.CREUSR_CF, 
				A.LSTUPD_D, 
				A.LSTUPDUSR_CF,  
				A.GAAP_NT,
				DIFF_M,
				A.PROPAGATION_B
from   #TLIFEST A
  WHERE A.BALSHTMTH_NF = (SELECT MAX(BALSHTMTH_NF) FROM #TLIFEST D
    where   D.DETTRNCOD_CF = A.DETTRNCOD_CF
	 -- and   D.ACMTRS_NT = A.ACMTRS_NT --Mod4
      and   D.UWY_NF = A.UWY_NF
      and   D.acy_nf    = A.acy_nf
      and   D.CTR_NF = A.CTR_NF
      and   D.END_NT = A.END_NT
      and   D.SEC_NF = A.SEC_NF
      and   D.UW_NT = A.UW_NT
      and   D.prs_cf    = A.prs_cf
      and   D.gaap_nt    = A.gaap_nt)

--SELECT @Time3=GETDATE()   
--SELECT "Time3", DATEDIFF(ms,@Time1,@Time3)

CREATE INDEX TLIFEST_BAL_01
    ON #TLIFEST_BAL(DETTRNCOD_CF, UWY_NF, ACY_NF, CTR_NF,  END_NT, SEC_NF, UW_NT, BALSHTMTH_NF, PRS_CF,  GAAP_NT) --Mod4

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFEST_BAL"
        return @erreur
        goto fin
    end
--DROP INDEX #TLIFEST_BAL.TLIFEST_BAL_01

Insert into #montants_w
Select 			A.DETTRNCOD_CF,
				A.ACMTRS_NT,
				A.UWY_NF,
				A.ACY_NF,
				A.CTR_NF, 
				A.END_NT, 
				A.SEC_NF,  
				A.UW_NT, 
				A.CRE_D, 
				A.BALSHEY_NF, 
				A.BALSHTMTH_NF,  
				A.PRS_CF,  
				A.SSD_CF, 
				A.CUR_CF, 
				A.ESTMNT_M, 
				A.INDSUP_B, 
				A.ORICOD_LS, 
				A.CREUSR_CF, 
				A.LSTUPD_D, 
				A.LSTUPDUSR_CF,  
				A.GAAP_NT,
				DIFF_M,
				A.PROPAGATION_B
from   #TLIFEST_BAL A												--MOD3
  WHERE A.CRE_D = (SELECT MAX(CRE_D) FROM #TLIFEST_BAL C
    where   C.DETTRNCOD_CF = A.DETTRNCOD_CF
	 --and   C.ACMTRS_NT = A.ACMTRS_NT --Mod4
      and   C.UWY_NF = A.UWY_NF
      and   C.acy_nf    = A.acy_nf
      and   C.CTR_NF = A.CTR_NF
      and   C.END_NT = A.END_NT
      and   C.SEC_NF = A.SEC_NF
      and   C.UW_NT = A.UW_NT
      and   C.BALSHTMTH_NF = A.BALSHTMTH_NF
      and   C.prs_cf    = A.prs_cf
      and   C.gaap_nt    = A.gaap_nt)

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#montants_w"
        return @erreur
        goto fin
    end

/*--------------------------------------------------*/
/* Select final                                     */
/*--------------------------------------------------*/


select 			A.CTR_NF, 
				A.END_NT, 
				A.SEC_NF, 
				A.UWY_NF, 
				A.UW_NT, 
				CONVERT(varchar(50), A.CRE_D,113) + ' ' + CONVERT(varchar(50), A.CRE_D,20) AS CRE_D,
				A.BALSHEY_NF, 
				A.BALSHTMTH_NF, 
				A.ACY_NF,
				A.PRS_CF, 
				A.ACMTRS_NT, 
				A.SSD_CF, 
				A.CUR_CF, 
				A.ESTMNT_M, 
				A.INDSUP_B, 
				A.ORICOD_LS, 
				A.CREUSR_CF, 
				CONVERT(varchar(50), A.LSTUPD_D,113) + ' ' + CONVERT(varchar(50), A.LSTUPD_D,20) AS LSTUPD_D, 
				A.LSTUPDUSR_CF, 
				A.DETTRNCOD_CF, 
				SL.SUBTRS_GL, 
				SL.SUBTRS_GS, 
				A.GAAP_NT,
				A.DIFF_M,
				A.PROPAGATION_B,
				BK.BLOCK_NF, 
				BK.RANKORDER_NB,
				TS.TRSINPUTTYPE_CT, 
				TS.TRSNATURE_CT, 
				TS.LOGSIG_CT, 
				TS.TRSTYPE_CT, 
				TS.DACVOBATYPE_CT, 
				TS.CELLPROTECEXC_B,
				ES.PREMIUMPNPEGPI_CT, 
				ES.COMACIMPACT_B, 
				ES.RETROAUTO_B, 
				ES.GAAP1TRS_CT, 
				ES.GAAP2TRS_CT, 
				ES.GAAP3TRS_CT, 
				ES.GAAP4TRS_CT, 
				ES.GAAP5TRS_CT 
				
from    #montants_w A
		LEFT OUTER JOIN BREF..TSUBTRSBLOCKLIFEST BK ON 											--MOD3
				CONVERT(tinyint, BK.PCPTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,1,2)) AND 
				CONVERT(tinyint, BK.TRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,3,1)) AND 
				CONVERT(tinyint, BK.SUBTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,4,2)) 
		LEFT OUTER JOIN BREF..TSUBTRSL SL ON 													--MOD3
				CONVERT(tinyint, SL.PCPTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,1,2)) AND 
				CONVERT(tinyint, SL.TRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,3,1)) AND 
				CONVERT(tinyint, SL.SUBTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,4,2)) AND 
				SL.LAG_CF = @p_lag_cf	
		LEFT OUTER JOIN BREF..TSUBTRS TS ON														--MOD3
				CONVERT(tinyint, TS.PCPTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,1,2)) AND
				CONVERT(tinyint, TS.TRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,3,1)) AND
				CONVERT(tinyint, TS.SUBTRS_CF) = CONVERT(tinyint, SUBSTRING(A.DETTRNCOD_CF,4,2)) 
		LEFT OUTER JOIN BREF..TSUBTRSESBPROP ES ON												--MOD3
				CONVERT(tinyint, ES.PCPTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,1,2)) AND
				CONVERT(tinyint, ES.TRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,3,1)) AND
				CONVERT(tinyint, ES.SUBTRS_CF) = CONVERT(tinyint, SUBSTRING(A.DETTRNCOD_CF,4,2)) AND
				ES.SSD_CF = A.SSD_CF AND
				ES.ESB_CF = @p_esb_cf
		
		
				-- AND ES.SSD_CF =   @p_ssd_cf AND
				--ES.ESB_CF = @p_esb_cf

WHERE   A.estmnt_m is not null
--and     A.estmnt_m <> 0 --MOD7
order by  A.CTR_NF, A.SEC_NF, A.UWY_NF, BK.BLOCK_NF, BK.RANKORDER_NB, A.ACY_NF ASC --mod5

--SELECT @Time5=GETDATE()   
--SELECT "Time5", DATEDIFF(ms,@Time1,@Time5)



select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#stat"
        return @erreur
        goto fin
    end

/*--------------------------------------------------*/
/* Destruction des tables temporaires               */
/*--------------------------------------------------*/

fin:
if object_id('#montants_w')     is not null drop Table #montants_w
if object_id('#TLIFEST')     is not null drop table #TLIFEST
if object_id('#TLIFEST_BAL')     is not null drop table #TLIFEST_BAL
if object_id('#TLOADING')     is not null drop table #TLOADING

return 0
go
EXEC sp_procxmode 'PsLIFEST_04_O2', 'unchained'
go
IF OBJECT_ID('PsLIFEST_04_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFEST_04_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFEST_04_O2 >>>'
go
GRANT EXECUTE ON PsLIFEST_04_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFEST_04_O2 TO GDBBATCH
go
