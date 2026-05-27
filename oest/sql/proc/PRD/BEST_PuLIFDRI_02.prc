use BEST
go

IF OBJECT_ID('dbo.PuLIFDRI_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuLIFDRI_02
   PRINT '<<< DROPPED PROC dbo.PuLIFDRI_02 >>>'
END
go


/*
 * creation de la procedure 
*/

create procedure PuLIFDRI_02 (
       @p_ctr_nf    UCTR_NF,
       @p_erreur	int=NULL output)
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
       @p_erreur	varchar(64)=NULL output

Conditions d'execution: Procedure appelee par le TP Retro


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

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

select @erreur = 0
select @tran_imbr = 1		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 

select @p_erreur = 0

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
   select @p_erreur = -1
   select @p_erreur
   goto fin
  end

if @erreur != 0 
  begin 
 	   select @p_erreur = -1
       select @p_erreur
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

insert into #tlifdri_01
select a.*
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
   select @p_erreur = -1
   select @p_erreur
   goto fin
  end

if @erreur != 0 
  begin 
 	   select @p_erreur = -1
       select @p_erreur
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
   select @p_erreur = -1
   select @p_erreur
   goto fin
  end

if @erreur != 0 
  begin 
 	   select @p_erreur = -1
       select @p_erreur
       goto fin
  end

/********************************************************************/
/* 5 - Insertion dans TLIFDRI                                       */
/********************************************************************/

insert into BEST..TLIFDRI
select *
from   #tlifdri_01

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = -1
   select @p_erreur
   goto fin
  end

if @erreur != 0 
  begin 
 	   select @p_erreur = -1
       select @p_erreur
       goto fin
  end

select @p_erreur
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

IF OBJECT_ID('dbo.PuLIFDRI_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuLIFDRI_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuLIFDRI_02 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PuLIFDRI_02
 */
GRANT EXECUTE ON dbo.PuLIFDRI_02 TO GOMEGA
go

