USE BEST
go

IF NULLIF(object_id('#tlifdri_01'), 0) IS NOT NULL 
begin
	drop table #tlifdri_01
	PRINT '<<< DROPPED temp table #tlifdri_01 >>>'
end
go

CREATE TABLE #tlifdri_01 (
    CTR_NF       UCTR_NF    NOT NULL,
    END_NT       UEND_NT    NOT NULL,
    SEC_NF       USEC_NF    NOT NULL,
    UWY_NF       UUWY_NF    NOT NULL,
    UW_NT        UUW_NT     NOT NULL,
    CRE_D        UUPD_D     DEFAULT getdate() NOT NULL,
    BALSHEY_NF   smallint   NOT NULL,
    BALSHTMTH_NF tinyint    NOT NULL,
    ACY_NF       smallint   NOT NULL,
    SSD_CF       USSD_CF    NOT NULL,
    AUTUPD_B     bit        DEFAULT 0 NOT NULL,
    COMACC_B     bit        DEFAULT 0 NOT NULL,
    CMT_NT       UCMT_NT    NULL,
    CREUSR_CF    UUPDUSR_CF DEFAULT user NOT NULL,
    LSTUPD_D     UUPD_D     DEFAULT getdate() NOT NULL,
    LSTUPDUSR_CF UUPDUSR_CF DEFAULT user NOT NULL)

go


IF OBJECT_ID('dbo.PuLIFDRI_02_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuLIFDRI_02_O2
    IF OBJECT_ID('dbo.PuLIFDRI_02_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuLIFDRI_02_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuLIFDRI_02_O2 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure dbo.PuLIFDRI_02_O2 (
       @p_ctr_nf    UCTR_NF,
       @p_ret	int=NULL output)
as

/***************************************************

Programme: PuLIFDRI_02

Fichier script associé : BEST_PuLIFDRI_02

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: G Buisson

Date de creation: 07/05/2003

Description du programme: 

        Mise à jour du top mise à jour automatique 
        par insertion de nouveaux enregistrements

Parametres: 

       @p_ctr_nf              UCTR_NF,
       @p_ret	varchar(64)=NULL output

Conditions d'execution: Procedure appelee par le TP Retro


Commentaires:

_________________
MODIFICATION 1

Auteur: Abha Apte

Date: 26 June 2013

Version: 

Description: Temp table creation is moved to caller Java service to have transaction handling from Java side than from DB side.
		Replaced p_erreur with p_ret.
		Additional "select @p_ret" statements are received, othewise SP was failing with Java though was working standlaone.

_________________
MODIFICATION 2

Auteur: Capgemini

Date: 24 July 2014

Version: 

Description: SPIRA [IN:029651] Impossibility to create a specific retro : blocking with an error message [IN:029651]

*****************************************************/

declare @erreur         int,
        @tran_imbr	    bit,
        @acy_nf_1       smallint,
	    @acy_nf_2       smallint,
	    @acy_nf_3       smallint,
	    @acy_nf_4       smallint,
	    @acy_nf_5       smallint,
	    @acy_nf_6       smallint,
	    @acy_nf_7       smallint,
        @BLCSHTYEA_NF   smallint,		
        @BLCSHTMTH_NF   tinyint,
        @TYPPER	        char(1),
 	    @DATE		    datetime,
        @SPCEND_D       datetime,
 	    @ACCOUNT_D	    datetime,
 	    @CLOSING_B	    bit


select @erreur = 0
select @tran_imbr = 1		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 

select @p_ret = 0

/********************************************************************/
/* 1 - Select dans BREF..TCALEND                                    */ 
/*     Recherche de la période 'année' et 'mois' en cours           */ 
/********************************************************************/

select @DATE= getdate() 
select @TYPPER = 'E'

Execute @erreur = BREF..PsCALEND_02 
			@DATE ,          
			@TYPPER ,
			@BLCSHTYEA_NF output,
        	@BLCSHTMTH_NF output,
			@SPCEND_D output,
			@ACCOUNT_D output,
			@CLOSING_B output

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_ret = -1
   goto fin
  end

if @erreur != 0 
  begin 
 	   select @p_ret = -1
       goto fin
  end

/********************************************************************/
/* 2 - Calcul années de compte : bilan - 4 -> bilan + 2             */
/********************************************************************/

Select @acy_nf_1 = @BLCSHTYEA_NF - 4
Select @acy_nf_2 = @BLCSHTYEA_NF - 3
Select @acy_nf_3 = @BLCSHTYEA_NF - 2
Select @acy_nf_4 = @BLCSHTYEA_NF - 1
Select @acy_nf_5 = @BLCSHTYEA_NF 
Select @acy_nf_6 = @BLCSHTYEA_NF + 1
Select @acy_nf_7 = @BLCSHTYEA_NF + 2

/********************************************************************/
/* 3 - Recherche dans TLIFDRI                                       */
/********************************************************************/

/* Adaptive Server has expanded all '*' elements in the following statement */ insert into #tlifdri_01
select a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.SSD_CF, a.AUTUPD_B, a.COMACC_B, a.CMT_NT, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF                                  
from   BEST..TLIFDRI a
where  a.CTR_NF      = @p_CTR_NF
and    a.BALSHEY_NF  = @BLCSHTYEA_NF
and    a.AUTUPD_B    = 1
and    a.ACY_NF     !< @acy_nf_1
and    a.ACY_NF     !> @acy_nf_7
and    a.CRE_D       = (select max(CRE_D)
                        from   BEST..TLIFDRI b
                        where  a.CTR_NF     = b.CTR_NF
                        and    a.END_NT     = b.END_NT
                        and    a.SEC_NF     = b.SEC_NF
                        and    a.UWY_NF     = b.UWY_NF
                        and    a.UW_NT      = b.UW_NT
                        and    a.BALSHEY_NF = b.BALSHEY_NF
                        and    a.ACY_NF     = b.ACY_NF)

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_ret = -1
   goto fin
  end

if @erreur != 0 
  begin 
 	   select @p_ret = -1
       goto fin
  end

/********************************************************************/
/* 4 - Modification table temporaire                                */
/********************************************************************/

update #tlifdri_01
set    CRE_D        = getdate(),
       BALSHEY_NF   = @BLCSHTYEA_NF,
       BALSHTMTH_NF = @BLCSHTMTH_NF,
       AUTUPD_B     = 0,
       CREUSR_CF    = user,
       LSTUPD_D     = getdate(),
       LSTUPDUSR_CF = user

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_ret = -1
   goto fin
  end

if @erreur != 0 
  begin 
 	   select @p_ret = -1
       goto fin
  end

/********************************************************************/
/* 5 - Insertion dans TLIFDRI                                       */
/********************************************************************/

/* Adaptive Server has expanded all '*' elements in the following statement */ 
insert into BEST..TLIFDRI
(CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, SSD_CF, AUTUPD_B, COMACC_B, CMT_NT, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF)
select #tlifdri_01.CTR_NF, #tlifdri_01.END_NT, #tlifdri_01.SEC_NF, #tlifdri_01.UWY_NF, #tlifdri_01.UW_NT, #tlifdri_01.CRE_D, #tlifdri_01.BALSHEY_NF, #tlifdri_01.BALSHTMTH_NF, #tlifdri_01.ACY_NF, #tlifdri_01.SSD_CF, #tlifdri_01.AUTUPD_B, #tlifdri_01.COMACC_B, #tlifdri_01.CMT_NT, #tlifdri_01.CREUSR_CF, #tlifdri_01.LSTUPD_D, #tlifdri_01.LSTUPDUSR_CF
from   #tlifdri_01

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_ret = -1
   goto fin
  end

if @erreur != 0 
  begin 
 	   select @p_ret = -1
       goto fin
  end

if @tran_imbr = 0
   COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN
return @erreur

/*
 * fin de la procedure 
 */
go
EXEC sp_procxmode 'dbo.PuLIFDRI_02_O2', 'unchained'
go
IF OBJECT_ID('dbo.PuLIFDRI_02_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuLIFDRI_02_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuLIFDRI_02_O2 >>>'
go
GRANT EXECUTE ON dbo.PuLIFDRI_02_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuLIFDRI_02_O2 TO GDBBATCH
go
