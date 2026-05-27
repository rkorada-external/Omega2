USE BEST
go
IF OBJECT_ID('dbo.PiTLIFPLN_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiTLIFPLN_01
    IF OBJECT_ID('dbo.PiTLIFPLN_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiTLIFPLN_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiTLIFPLN_01 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PiTLIFPLN_01
     (
       --@p_TRN_NT          numeric   ,
       @p_ACCTYP_NF       tinyint   ,
       @p_SSD_CF          USSD_CF   ,
       @p_ESB_CF          UESB_CF   ,
       @p_PLAN_NF         numeric(10,0)   , --MOD0012
       @p_BALSHEY_NF      smallint  ,
       @p_BALSHRMTH_NF    tinyint   ,
       @p_BALSHRDAY_NF    tinyint   ,
       @p_TRNCOD_CF       UDETTRS_CF,
       @p_DBLTRNCOD_CF    UDETTRS_CF,
       @p_CTR_NF          UCTR_NF   ,
       @p_END_NT          UEND_NT   ,
       @p_SEC_NF          USEC_NF   ,
       @p_UWY_NF          UUWY_NF   ,
       @p_UW_NT           UUW_NT    ,
       @p_OCCYEA_NF       smallint  ,
       @p_ACY_NF          smallint  ,
       @p_SCOSTRMTH_NF    tinyint   ,
       @p_SCOENDMTH_NF    tinyint   ,
       @p_CUR_CF          UCUR_CF   ,
       @p_AMT_M           UAMT_M    ,
       @p_CED_NF          UCLI_NF   ,
       @p_BRK_NF          UCLI_NF   ,
       @p_GEMPRMPAY_NF    UCLI_NF   ,
       @p_GANPAYORD_NT    UPAYORD_NT,
       @p_RETCTR_NF       URETCTR_NF,
       @p_RETEND_NT       tinyint   ,
       @p_RETSEC_NF       URETSEC_NF,
       @p_RETRTY_NF       UUWY_NF   ,
       @p_RETUW_NT        tinyint   ,
       @p_PLC_NT          UPLC_NT   ,
       @p_RETOCCYEA_NF    smallint  ,
       @p_RETACY_NF       smallint  ,
       @p_RETSCOSTRMTH_NF tinyint   ,
       @p_RETSCOENDMTH_NF tinyint   ,
       @p_RETCUR_CF       UCUR_CF   ,
       @p_RETAMT_M        UAMT_M    ,
       @p_RTO_NF          UCLI_NF   ,
       @p_INT_NF          UCLI_NF   ,
       @p_RETPAY_NF       UCLI_NF   ,
       @p_RETKEY_CF       char(1)   ,
       @p_COMMAC_LL       UL64      ,
       @p_CRE_D           UUPD_D    ,
       @p_CREUSR_CF       UUPDUSR_CF,
       @p_lstupd_d     UUPD_D=NULL output,
       @p_lstupdusr_cf     UUPDUSR_CF=NULL output,
       @p_ret		     char(64) = NULL output,
       @p_erreur	varchar(64)=NULL output,
	   @p_POSTBPC_B		  bit --MOD0011
     )
as

/***************************************************

Programme: PiTLIFPLN_01

Fichier script associé : BEST_PiTLIFPLN_01
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME57
Date de creation:13/04/2004
Description du programme:

      * Insertion d'enregistrement dans TLIFPLN
      * Appel proc de lancement de job asynchrone
	 de génération des écritures de rétrocession

Parametres:
    TRN_NT          identity
    ACCTYP_NF       tinyint
    SSD_CF          USSD_CF
    ESB_CF          UESB_CF
    PLAN_NF         UUWY_NF
    BALSHEY_NF      smallint
    BALSHRMTH_NF    tinyint
    BALSHRDAY_NF    tinyint
    TRNCOD_CF       UDETTRS_CF
    DBLTRNCOD_CF    UDETTRS_CF
    CTR_NF          UCTR_NF
    END_NT          UEND_NT
    SEC_NF          USEC_NF
    UWY_NF          UUWY_NF
    UW_NT           UUW_NT
    OCCYEA_NF       smallint
    ACY_NF          smallint
    SCOSTRMTH_NF    tinyint
    SCOENDMTH_NF    tinyint
    CUR_CF          UCUR_CF
    AMT_M           UAMT_M
    CED_NF          UCLI_NF
    BRK_NF          UCLI_NF
    GEMPRMPAY_NF    UCLI_NF
    GANPAYORD_NT    UPAYORD_NT
    RETCTR_NF       URETCTR_NF
    RETEND_NT       tinyint
    RETSEC_NF       URETSEC_NF
    RETRTY_NF       UUWY_NF
    RETUW_NT        tinyint
    PLC_NT          UPLC_NT
    RETOCCYEA_NF    smallint
    RETACY_NF       smallint
    RETSCOSTRMTH_NF tinyint
    RETSCOENDMTH_NF tinyint
    RETCUR_CF       UCUR_CF
    RETAMT_M        UAMT_M
    RTO_NF          UCLI_NF
    INT_NF          UCLI_NF
    RETPAY_NF       UCLI_NF
    RETKEY_CF       char(1)
    COMMAC_LL       UL64
    CRE_D           UUPD_D
    CREUSR_CF       UUPDUSR_CF
    LSTUPD_D        UUPD_D
    LSTUPDUSR_CF    UUPDUSR_CF
       @p_ret		     char(64) = NULL output,
       @p_erreur	varchar(64)=NULL output

Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: L.DEBEVER
Date: 25/11/1997
Version:
Description: Maj numéro de la ligne de participation variable créée
		suite à maj de base ;: désormais, les n° d'écriture
		ne sont plus 'numeric identity' => leur incrémentation
		n'est plus gérée par SYBASE
_________________
MODIFICATION 2
Auteur: L.DEBEVER
Date: 5/12/1997
Version:
Description: Rajout lancement batch asynchrone.
_________________
MODIFICATION 3
Auteur: L.DEBEVER
Date: 31/03/1998
Version:
Description: Acces direct à TREQJOB en remplacement du
	      lancement de la proc PsREQJOB_03 (Utilise
	      BTRAV -> Interdit en TP)
_________________
MODIFICATION 4
Auteur: L.DEBEVER
Date: 17/04/1998
Version:
Description: Rajout de trn_nt créé en parametre de PiJOBQUEUE_01
_________________
MODIFICATION 5
Auteur: L.DEBEVER
Date: 10/06/1998
Version:
Description: retend_nt = 0 / retuw_nt = 1 systématiquement
_________________
MODIFICATION 6
Auteur: M SPAGNOLI
Date: 23/06/2004
Version:
Description: Nouvelle proc qui a étét faite avec la proc existente suivante : PiACCSUP_01
_________________
MODIFICATION 7
Auteur: M SPAGNOLI
Date: 18/08/2004
Version:
Description: On recherche directement la date de cloture dans la proc.

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 10/07/2014 R. Cassis   :spot:25427  - Updates for omega2 1b variables called by pssite01 procedure
[102] 17/07/2014 R. Cassis   :spot:27176  - obtain data by ssd_cf parameter than 99
_________________
MODIFICATION 0011
Auteur: AbdulWaajed Shaikh
Date: 16/09/2014 (DD/MMM/YYYY)
Description: EST48 Changes : new column POSTBPC_B added in table BEST..TLIFPLN. Prefix MOD0011.
			 Also included condition for Balance sheet month & year. Prefix MOD0011.
_________________
MODIFICATION 0012
Auteur: AbdulWaajed Shaikh
Date: 11/02/2015 (DD/MMM/YYYY)
Description: CR #34454 Changes : datatype of column PLAN_NF changed to numeric from UUWY_NF in table BEST..TLIFPLN. Prefix MOD0012.
*****************************************************/

declare @erreur     int,
        @tran_imbr	bit,
	      @nb_lig     int,    /* numéro de l'écriture de service créée  */
	      @trn_nt     numeric
        
declare @getdate        datetime,
        @user           UUPDUSR_CF,
	      @date   	      varchar(30),
	      @ctr_nf   	    varchar(30),
	      @end_nt    	    varchar(30),
	      @sec_nf    	    varchar(30),
	      @uwy_nf   	    varchar(30),
	      @uw_nt     	    varchar(30),
	      @cur_cf    	    varchar(30),
	      @clodat_d  	    varchar(30),
	      @balshey_nf 	  varchar(30),
	      @pertyp_ct  	  varchar(30),
	      @blcshtmth_nf   varchar(30),
	      @blcshtmth1_nf  smallint,
 	      @blcshtmth2_nf  smallint,
	      @blcshtyea_nf   smallint,
	      @blcshtyea1_nf  smallint,
	      @dbclo_d    	  varchar(30),
	      @specend_d      varchar(30),
	      @account_d      varchar(30),
	      @clodatmax_d    varchar(30),
	      @num_trn        varchar(30)

/* Modif 3 : Variables pour accès TREQJOB */
declare @spcend_d		datetime
declare @closing_b		bit
declare @clodat0		char(8)

/**********************************************Calcul du clodat_e debut**************************************/
 declare       @max_cre DateTime
 declare       @datecloture DateTime
 declare       @month_clo    tinyint
 declare       @day_clo    tinyint
 declare       @year_clo    smallint

--[100]
declare @site_cf        varchar(10),
        @SSD_CF2     varchar(2)
select  @SSD_CF2 = convert(varchar(2),@p_SSD_CF)
Execute @erreur = BEST..PsSITE_01 @SSD_CF2,'2',@site_cf output

--[102]
select @max_cre = max(cre_d)
from BEST..TREQJOB
where ssd_cf = @p_SSD_CF
and reqcod_ct = "A"
--and site_cf = @site_cf
and balsheyea_nf = @p_BALSHEY_NF   --MOD0011
and balshtmth_nf = @p_BALSHRMTH_NF --MOD0011

--[102]
select @datecloture  =        ( select clodat_d
                                from BEST..TREQJOB
                                where ssd_cf  = @p_SSD_CF
                                and reqcod_ct = "A"
                                and cre_d     = @max_cre  
                                --and site_cf   = @site_cf
								and balsheyea_nf = @p_BALSHEY_NF   --MOD0011
                                and balshtmth_nf = @p_BALSHRMTH_NF --MOD0011
                               )


Select @month_clo  = datepart(mm, @datecloture)
Select @day_clo    = datepart(dd, @datecloture)
Select @year_clo   = datepart(yy, @datecloture)


/**********************************************Calcul du clodat_d fin **************************************/

select @getdate = GetDate()
select @user = user

select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


/* maj numéro de la ligne de participation variable créée */
/*Select @nb_lig = max(TRN_NT)+1
from TLIFPLN

select @erreur = @@error
if @erreur!= 0
goto fin*/

/* init nb_lig si aucun enreg. */

--If @nb_lig is null
--select @nb_lig = 1


/*-----------------------------------------------------------------------------
  Insertion dans TLIFPLN
---------------------------------------------------------------------------*/

insert into TLIFPLN
      (
                --TRN_NT          ,
                ACCTYP_NF       ,
                SSD_CF          ,
                ESB_CF          ,
                PLAN_NF         ,
                BALSHEY_NF      ,
                BALSHRMTH_NF    ,
                BALSHRDAY_NF    ,
                TRNCOD_CF       ,
                DBLTRNCOD_CF    ,
                CTR_NF          ,
                END_NT          ,
                SEC_NF          ,
                UWY_NF          ,
                UW_NT           ,
                OCCYEA_NF       ,
                ACY_NF          ,
                SCOSTRMTH_NF    ,
                SCOENDMTH_NF    ,
                CUR_CF          ,
                AMT_M           ,
                CED_NF          ,
                BRK_NF          ,
                GEMPRMPAY_NF    ,
                GANPAYORD_NT    ,
                RETCTR_NF       ,
                RETEND_NT       ,
                RETSEC_NF       ,
                RETRTY_NF       ,
                RETUW_NT        ,
                PLC_NT          ,
                RETOCCYEA_NF    ,
                RETACY_NF       ,
                RETSCOSTRMTH_NF ,
                RETSCOENDMTH_NF ,
                RETCUR_CF       ,
                RETAMT_M        ,
                RTO_NF          ,
                INT_NF          ,
                RETPAY_NF       ,
                RETKEY_CF       ,
                COMMAC_LL       ,
                CRE_D           ,
                CREUSR_CF       ,
                LSTUPD_D        ,
                LSTUPDUSR_CF	,
				POSTBPC_B		  --MOD0011
      )
 values
      (
       -- @nb_lig             ,
        @p_ACCTYP_NF        ,
        @p_SSD_CF           ,
        @p_ESB_CF           ,
        @p_PLAN_NF          ,
        @year_clo           , --@p_BALSHEY_NF       ,
        @month_clo          , --@p_BALSHRMTH_NF     ,
        @day_clo            , --@p_BALSHRDAY_NF     ,
        @p_TRNCOD_CF        ,
        @p_DBLTRNCOD_CF     ,
        @p_CTR_NF           ,
        @p_END_NT           ,
        @p_SEC_NF           ,
        @p_UWY_NF           ,
        @p_UW_NT            ,
        @p_OCCYEA_NF        ,
        @p_ACY_NF           ,
        @p_SCOSTRMTH_NF     ,
        @p_SCOENDMTH_NF     ,
        @p_CUR_CF           ,
        @p_AMT_M            ,
        @p_CED_NF           ,
        @p_BRK_NF           ,
        @p_GEMPRMPAY_NF     ,
        @p_GANPAYORD_NT     ,
        @p_RETCTR_NF        ,
        0, --@p_RETEND_NT
        @p_RETSEC_NF        ,
        @p_RETRTY_NF        ,
        1, --@p_RETUW_NT
        @p_PLC_NT           ,
        @p_RETOCCYEA_NF     ,
        @p_RETACY_NF        ,
        @p_RETSCOSTRMTH_NF  ,
        @p_RETSCOENDMTH_NF  ,
        @p_RETCUR_CF        ,
        @p_RETAMT_M         ,
        @p_RTO_NF           ,
        @p_INT_NF           ,
        @p_RETPAY_NF        ,
        @p_RETKEY_CF        ,
        @p_COMMAC_LL        ,
        GetDate()           ,                     --@p_CRE_D
        @p_CREUSR_CF        ,                     
        GetDate()           ,                     --@p_LSTUPD_D
        User                ,                     --@p_LSTUPDUSR_CF
		@p_POSTBPC_B		  --MOD0011
      )



select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   if @erreur = 2601
 	   select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliquée */
   else
 	   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

   goto fin
  end


/* Récup n° d'écriture créé   */
Select @trn_nt = max(trn_nt)
from TLIFPLN

select @erreur = @@error
if @erreur!= 0
goto fin


select @p_lstupdusr_cf = lstupdusr_cf,
          @p_lstupd_d = lstupd_d
from TLIFPLN
where trn_nt = @trn_nt

select @erreur = @@error
if @erreur != 0
   begin
      select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
   end


/*------------------------------------------------------
 Retourner via le paramètre @_ret, le numéro d'écriture
 affecté lors de l'insert
------------------------------------------------------*/

/* Retour                                             */
 Select @p_ret = convert(char(64),@trn_nt)

/*----------------------------------------------------------------------------*/
/* Fin transaction                                                            */
/*----------------------------------------------------------------------------*/

if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur
go
EXEC sp_procxmode 'dbo.PiTLIFPLN_01', 'unchained'
go
IF OBJECT_ID('dbo.PiTLIFPLN_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiTLIFPLN_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiTLIFPLN_01 >>>'
go
GRANT EXECUTE ON dbo.PiTLIFPLN_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiTLIFPLN_01 TO GDBBATCH
go
