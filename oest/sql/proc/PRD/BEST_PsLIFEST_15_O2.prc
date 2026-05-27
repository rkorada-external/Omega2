USE BEST
go
IF OBJECT_ID('PsLIFEST_15_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsLIFEST_15_O2
    IF OBJECT_ID('PsLIFEST_15_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsLIFEST_15_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsLIFEST_15_O2 >>>'
END
go
/*
 * creation de la procedure
*/
create procedure PsLIFEST_15_O2 (
  @p_end_nt       UEND_NT,
  @p_sec_nf       USEC_NF,
  @p_uw_nt        UUW_NT,
  @p_uwy_nf       UUWY_NF,
  @p_visu_mois	tinyint,
  @p_visu_an  	smallint,
  @p_ctr_nf       UCTR_NF,
  @p_ssd_cf       USSD_CF,
  @p_esb_cf         UESB_CF,
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

*****************************************************/

declare @erreur int

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

/* Lifdri réduit                                      */

Create table #TLIFDRI (
				CTR_NF      	UCTR_NF,
				END_NT			UEND_NT,
				SEC_NF      	USEC_NF,
				UWY_NF       	UUWY_NF,
				UW_NT		 	UUW_NT,
                ACY_NF      	smallint,
				SSD_CF			USSD_CF,
                AUTUPD_B        bit,
                COMACC_B        bit,
                CMT_NT       	UCMT_NT,
                CRE_D        	datetime,
                BALSHEY_NF   	smallint,
                BALSHTMTH_NF 	tinyint,
				CREUSR_CF       UUSR_CF,
				LSTUPD_D        datetime,
				LSTUPDUSR_CF    UUSR_CF)


/*--------------------------------------------------*/
/* Maj arrêté stat dans #stat, puis dans #liste     */
/*--------------------------------------------------*/
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
        VALUES (@p_ctr_nf,@p_sec_nf,@p_uwy_nf,@p_end_nt,@p_uw_nt,@p_ssd_cf,@p_esb_cf,@p_usr_cf,1, 4)
End


/* 1ère partie   */

Insert into #TLIFDRI
Select  dri.CTR_NF,
        dri.END_NT,
        dri.SEC_NF,
        dri.UWY_NF,
        dri.UW_NT,
        dri.ACY_NF,
        dri.SSD_CF,
        dri.AUTUPD_B,
        dri.COMACC_B,
        dri.CMT_NT,
        dri.CRE_D,
        dri.BALSHEY_NF,
        dri.BALSHTMTH_NF,
		dri.CREUSR_CF,
		dri.LSTUPD_D,
		dri.LSTUPDUSR_CF
from   BEST..TLIFDRI dri, #TLOADING t
where  
       dri.ctr_nf        = t.ctr_nf
and    dri.end_nt        = t.end_nt
and    dri.sec_nf        = t.sec_nf
and    dri.uw_nt         = t.uw_nt
and    dri.acy_nf 		 <= @p_visu_an + @p_higher_bound_year
and    dri.acy_nf 		 >= @p_visu_an - @p_lower_bound_year
and    dri.balshey_nf    = @p_visu_an
and    dri.balshtmth_nf <= @p_visu_mois


select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFDRI"
        return @erreur
        goto fin
    end


/*--------------------------------------------------*/
/* Select final                                     */
/*--------------------------------------------------*/

select 	A.CTR_NF,
        A.END_NT,
        A.SEC_NF,
        A.UWY_NF,
        A.UW_NT,
        A.ACY_NF,
        A.SSD_CF,
        A.AUTUPD_B,
        A.COMACC_B,
        A.CMT_NT,
        CONVERT(varchar(50), A.CRE_D,113) + ' ' + CONVERT(varchar(50), A.CRE_D,20) AS CRE_D, 
        A.BALSHEY_NF,
        A.BALSHTMTH_NF,
		CREUSR_CF,
		CONVERT(varchar(50), A.LSTUPD_D,113) + ' ' + CONVERT(varchar(50), A.LSTUPD_D,20) AS LSTUPD_D, 
		LSTUPDUSR_CF
from    #TLIFDRI A
where convert(char(4), A.balshey_nf) +
      right(convert(char(3),100 + A.balshtmth_nf), 2) +
      convert(char(4),datepart(yy, A.cre_d)) +
      right(convert(char(3),100 + datepart(mm, A.cre_d)), 2) +
      right(convert(char(3),100 + datepart(dd, A.cre_d)), 2) +
      convert(char(9), A.cre_d, 8) =                         (select max(convert(char(4), B.balshey_nf) +
                                                                     right(convert(char(3),100 + B.balshtmth_nf), 2) +
                                                                     convert(char(4),datepart(yy, B.cre_d)) +
                                                                     right(convert(char(3),100 + datepart(mm, B.cre_d)), 2) +
                                                                     right(convert(char(3),100 + datepart(dd, B.cre_d)), 2) +
                                                                     convert(char(9), B.cre_d, 8))
                                                              from   #TLIFDRI B
     					                                      where  B.acy_nf = A.acy_nf
                                                              and B.ctr_nf = A.ctr_nf
                                                              and B.end_nt = A.end_nt
                                                              and B.uw_nt = A.uw_nt
                                                              and B.sec_nf = A.sec_nf)
group by   A.CTR_NF,
        A.END_NT,
        A.SEC_NF,
        A.UWY_NF,
        A.UW_NT,
        A.ACY_NF,
        A.SSD_CF,
        A.AUTUPD_B,
        A.COMACC_B,
        A.CMT_NT,
        A.CRE_D,
        A.BALSHEY_NF,
        A.BALSHTMTH_NF,
		CREUSR_CF,
		LSTUPD_D,
		LSTUPDUSR_CF                                                            
order by A.SSD_CF, A.CTR_NF, A.SEC_NF, A.UWY_NF, A.END_NT, A.UW_NT, A.ACY_NF ASC

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLIFDRI"
        return @erreur
        goto fin
    end

/*--------------------------------------------------*/
/* Destruction des tables temporaires               */
/*--------------------------------------------------*/

fin:
drop table #TLOADING
drop table #TLIFDRI


return 0
go
EXEC sp_procxmode 'PsLIFEST_15_O2', 'unchained'
go
IF OBJECT_ID('PsLIFEST_15_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFEST_15_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFEST_15_O2 >>>'
go
GRANT EXECUTE ON PsLIFEST_15_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFEST_15_O2 TO GDBBATCH
go
