USE BEST
go
IF OBJECT_ID('dbo.PsLIFEST_02_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFEST_02_O2
    IF OBJECT_ID('dbo.PsLIFEST_02_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFEST_02_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFEST_02_O2 >>>'
END
go
/*
 * creation de la procedure
*/
create procedure dbo.PsLIFEST_02_O2 (
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
  @p_higher_bound_year smallint)
as

/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : C. Cros
Creation date     : 12/12/2013

Description       :  Retrieve estimation grids according to a perimeter

Domain            : Estimate
Base              : BEST
Version           : 
Author            : A.Deshpande
Creation date     : 23/07/2014

Description       :  For TRAN 13 evo card data will be inserted into TLIFEST if current balance sheet year equals visualized year and if not data will be inserted into TLIF_HISTO

_________________
MODIFICATIONS

1. A.Deshpande 06/10/2014 : For performance improvement addded index for spira # 33314 
2. Sumit Gupta 12/01/2015 : change DACTYPE_B to DACVOBATYPE_CT for CR 032408
3. Sumit Gupta 11/03/2015 : remove condition A.estmnt_m <> 0 for Defect spira #34627
*****************************************************/

declare @erreur int, 
		@current_balshtyear Datetime,
		@TYPPER  Char(1),
		@BLCSHTYEA_NF Smallint



/*--------------------------------------------------*/
/* Cr�ation tables temporaire                       */
/*--------------------------------------------------*/


/* Lifest r�duit                */
Create table #TLIFEST (
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

/* Montants estim�s             */
Create table #montants_w (
				DETTRNCOD_CF 		   	char(5),
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

/* montants cumul�s par ann�es de compte,           */
/* code traitement (prs_cf) et poste cumul          */
/* (acmtrc_nt)                                      */

Create table #montants (
            DETTRNCOD_CF       char(5),
            PRS_CF       smallint,
            ACY_NF       smallint,
            ESTMNT_M     UAMT_M,
			DIFF_M     	 UAMT_M null,
            GAAP_NT		 smallint)



/*--------------------------------------------------*/
/* Maj exc souscription, montants dans #montants_w  */
/*--------------------------------------------------*/

/* 1�re partie   */
 
/* We are using BREF..PsCALEND_02 to get the current Balance sheet year (@BLCSHTYEA_NF) */
select @current_balshtyear = getdate(), @TYPPER = 'C'
execute @erreur = BREF..PsCALEND_02 @current_balshtyear, @TYPPER, @BLCSHTYEA_NF output
 
if @erreur != 0
    begin
        Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND"
        return @erreur
    end 

/* When input balance sheet year is current balance sheet year, we retrieve from TLIFEST */

IF @BLCSHTYEA_NF = @p_visu_an 
	begin

Insert into #TLIFEST
Select 			DETTRNCOD_CF,
				ACMTRS_NT,
				UWY_NF,
				ACY_NF,
				CTR_NF, 
				END_NT, 
				SEC_NF,  
				UW_NT, 
				CRE_D, 
				BALSHEY_NF, 
				BALSHTMTH_NF,  
				PRS_CF,  
				SSD_CF, 
				CUR_CF, 
				ESTMNT_M, 
				INDSUP_B, 
				ORICOD_LS, 
				CREUSR_CF, 
				LSTUPD_D, 
				LSTUPDUSR_CF,  
				GAAP_NT,
				DIFF_M,
				PROPAGATION_B				
from   TLIFEST
where  ctr_nf        = @p_ctr_nf
and    end_nt        = @p_end_nt
and    sec_nf        = @p_sec_nf
and    uw_nt         = @p_uw_nt
and    acy_nf 		 <= @p_visu_an + @p_higher_bound_year
and    acy_nf 		 >= @p_visu_an - @p_lower_bound_year
and    balshey_nf    = @p_visu_an
and    balshtmth_nf <= @p_visu_mois

	end 
ELSE
/* Else, we retrieve from TLIFEST_H */

	begin
		Insert into #TLIFEST
		Select 		DETTRNCOD_CF,
					ACMTRS_NT,
					UWY_NF,
					ACY_NF,
					CTR_NF, 
					END_NT, 
					SEC_NF,  
					UW_NT, 
					CRE_D, 
					BALSHEY_NF, 
					BALSHTMTH_NF,  
					PRS_CF,  
					SSD_CF, 
					CUR_CF, 
					ESTMNT_M, 
					INDSUP_B, 
					ORICOD_LS, 
					CREUSR_CF, 
					LSTUPD_D, 
					LSTUPDUSR_CF,  
					GAAP_NT,
					DIFF_M,
					PROPAGATION_B				
		from   TLIFEST_H
		where  ctr_nf        = @p_ctr_nf
		and    end_nt        = @p_end_nt
		and    sec_nf        = @p_sec_nf
		and    uw_nt         = @p_uw_nt
		and    acy_nf 		 <= @p_visu_an + @p_higher_bound_year
		and    acy_nf 		 >= @p_visu_an - @p_lower_bound_year
		and    balshey_nf    = @p_visu_an
		and    balshtmth_nf <= @p_visu_mois
	end 

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#montants_w"
        return @erreur
        goto fin
    end

/* 2�me partie   */

CREATE CLUSTERED INDEX TLIFEST_00 ON #TLIFEST(PRS_CF, DETTRNCOD_CF, ACY_NF, UWY_NF, GAAP_NT)

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
from   #TLIFEST A
where  convert(char(4), A.balshey_nf) +
       right(convert(char(3),100 + A.balshtmth_nf), 2) +
       convert(char(4),datepart(yy, A.cre_d)) +
       right(convert(char(3),100 + datepart(mm, A.cre_d)), 2) +
       right(convert(char(3),100 + datepart(dd, A.cre_d)), 2) +
       convert(char(9), A.cre_d, 8)                             =  (select max(convert(char(4), B.balshey_nf) +
                                                                    right(convert(char(3),100 + B.balshtmth_nf), 2) +
                                                                    convert(char(4),datepart(yy, B.cre_d)) +
                                                                    right(convert(char(3),100 + datepart(mm, B.cre_d)), 2) +
                                                                    right(convert(char(3),100 + datepart(dd, B.cre_d)), 2) +
                                                                    convert(char(9), B.cre_d, 8))
                                                                    from   #TLIFEST B
                                                                    where  B.prs_cf   	= A.prs_cf
                                                                    and    B.DETTRNCOD_CF 	= A.DETTRNCOD_CF
                                                                    and    B.acy_nf    	= A.acy_nf
                                                                    and    B.uwy_nf    	= A.uwy_nf
																	and    B.gaap_nt    = A.gaap_nt)


															
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#montants_w"
        return @erreur
        goto fin
    end


/*--------------------------------------------------*/
/* Maj montants cumul�s par ann�es de compte,       */
/* code traitement (prs_cf) et poste cumul          */
/* (acmtrc_nt) dans #montants, puis dans #liste     */
/*--------------------------------------------------*/

Insert into #montants
Select DETTRNCOD_CF,
	   prs_cf,
	   acy_nf,
	   sum(estmnt_m),
	   sum(diff_m),
       gaap_nt
from #montants_w
group by acy_nf, prs_cf, DETTRNCOD_CF, gaap_nt
order by acy_nf, prs_cf, DETTRNCOD_CF, gaap_nt

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#montants"
        return @erreur
        goto fin
    end

update #montants_w
set    estmnt_m = M.estmnt_m, diff_m = M.diff_m
from   #montants_w A, #montants M
where  
A.DETTRNCOD_CF = M.DETTRNCOD_CF
and A.prs_cf = M.prs_cf
and A.acy_nf = M.acy_nf
and A.gaap_nt = M.gaap_nt
	
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#montants"
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
				BK.RANKORDER_NB	,
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
		LEFT OUTER JOIN BREF..TSUBTRSBLOCKLIFEST BK ON 
				CONVERT(tinyint, BK.PCPTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,1,2)) AND 
				CONVERT(tinyint, BK.TRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,3,1)) AND 
				CONVERT(tinyint, BK.SUBTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,4,2)) 
		LEFT OUTER JOIN BREF..TSUBTRSL SL ON 
				CONVERT(tinyint, SL.PCPTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,1,2)) AND 
				CONVERT(tinyint, SL.TRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,3,1)) AND 
				CONVERT(tinyint, SL.SUBTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,4,2)) AND 
				SL.LAG_CF = @p_lag_cf	
		LEFT OUTER JOIN BREF..TSUBTRS TS ON
				CONVERT(tinyint, TS.PCPTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,1,2)) AND
				CONVERT(tinyint, TS.TRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,3,1)) AND
				CONVERT(tinyint, TS.SUBTRS_CF) = CONVERT(tinyint, SUBSTRING(A.DETTRNCOD_CF,4,2)) 
		LEFT OUTER JOIN BREF..TSUBTRSESBPROP ES ON
				CONVERT(tinyint, ES.PCPTRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,1,2)) AND
				CONVERT(tinyint, ES.TRS_CF) = CONVERT(tinyint, SUBSTRING (A.DETTRNCOD_CF,3,1)) AND
				CONVERT(tinyint, ES.SUBTRS_CF) = CONVERT(tinyint, SUBSTRING(A.DETTRNCOD_CF,4,2)) AND
				ES.SSD_CF = A.SSD_CF AND
				ES.ESB_CF = @p_esb_cf
					
WHERE A.estmnt_m is not null
--and   A.estmnt_m <> 0 --Mod 3
order by  A.CTR_NF, A.SEC_NF, BK.BLOCK_NF, BK.RANKORDER_NB, A.ACY_NF ASC


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
drop table #montants_w
drop table #montants
drop table #TLIFEST

return 0
go
EXEC sp_procxmode 'dbo.PsLIFEST_02_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFEST_02_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFEST_02_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFEST_02_O2 >>>'
go
GRANT EXECUTE ON dbo.PsLIFEST_02_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFEST_02_O2 TO GDBBATCH
go
