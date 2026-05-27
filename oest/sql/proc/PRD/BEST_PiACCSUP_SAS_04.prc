USE BEST
go
IF OBJECT_ID('dbo.PiACCSUP_SAS_04') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiACCSUP_SAS_04
    IF OBJECT_ID('dbo.PiACCSUP_SAS_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiACCSUP_SAS_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiACCSUP_SAS_04 >>>'
END
go
create procedure PiACCSUP_SAS_04(
  @p_ssd_cf USSD_CF,
  @p_ESB    UESB_CF,
  @p_usr_cf UUSR_CF,
  @p_batch_mode UL16 = NULL,
  @p_date_d    datetime = NULL,
  @isPostingSas_d datetime = NULL)
with execute as caller as 
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: S.Behague
Date de creation: 17/07/2025

Description du programme:
---------------------------
Copie et regroupement des procedures PiACCSUP_04/PtSUIVINTACC_01
----------------------------
[01] 17/07/2025 S.Behague :US5603 SAS AE load- CSUOE control based on pericase - Spira 111627
******************************************************************************************************************************************************/
	
	

CREATE TABLE #TCTRANO_TMP
(
    CTR_NF     UCTR_NF       NULL,
    END_NT     UEND_NT       NULL,
    SEC_NF     USEC_NF       NULL,
    VRS_NF     numeric(10,0) NULL, 
    SSD_CF     USSD_CF       NULL,
    SEGTYP_CT  USEGTYP_CT    DEFAULT '' NULL,
    SEG_NF     USEG_NF       DEFAULT '' NULL,
    ANO_CT     int           NULL,
    NUMLINE_NT int           DEFAULT 0 NULL

)


Declare 
	@MsgAnomalie    varchar(120),
	@NumMsgAnomalie    varchar(120),                                               -- MOD003 Nb Anomalies : Numéros des Erreurs Rencontrées
	@MsgGlobalAnomalie    varchar(240),
    @Post_Omega_Entry_I4I_D                          Char(8) ,
    @Post_Omega_Entry_EBS_D                          Char(8) ,
    @Post_Omega_Entry_I17_D                          Char(8) ,
    @Post_Omega_Yea_I4I_D                            numeric(4,0) ,
    @Post_Omega_Yea_EBS_D                            numeric(4,0) ,
    @Post_Omega_Yea_I17_D                            numeric(4,0) ,
    @Post_Omega_Mth_I4I_D                            numeric(4,0) ,
    @Post_Omega_Mth_EBS_D                            numeric(4,0) ,
    @Post_Omega_Mth_I17_D                            numeric(4,0) ,
    @INV_Entry_I4I_D                                 Char(8) ,
    @INV_Entry_EBS_D                                 Char(8) ,
    @INV_Entry_I17_D                                 Char(8) ,
    @INV_Mth_I4I_D                                   numeric(4,0) ,
    @INV_Mth_EBS_D                                   numeric(4,0) ,
    @INV_Mth_I17_D                                   numeric(4,0) ,
    @INV_Yea_I4I_D                                   numeric(4,0) ,
    @INV_Yea_EBS_D                                   numeric(4,0) ,
    @INV_Yea_I17_D                                   numeric(4,0) ,
    @P_SuffixeTable                                 char(1) ,
    @blcshtyea_nf smallint ,
    @blcshtmth_nf tinyint ,
    @balshtmth_nf tinyint ,
    @spcend_d    datetime, 
    @account_d    datetime, 
    @closing_b    bit ,
    @NORME varchar(20),
    @Verif_d      datetime,
    @entpery_nf   smallint, /* année de saisie */
    @entpermth_nf   tinyint  ,/* mois de saisie */
    @DateInventaireConso   Char(8),   -- Date Libelle Inventaire Pour Saisie Ecriture Conso & Social (Periode T-1)
    @PeriodeConsoAA     numeric(4,0), -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
    @PeriodeConsoMM     numeric(2,0), -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
	@PeriodeInvAA		numeric(4,0),
	@PeriodeInvMM   	numeric(2,0),
    @DateInventaireService Char(8),    -- Date Libelle Inventaire Pour Saisie Ecriture Service (Periode T)
    --@cre_d      datetime,
    @p_site_cf   char(4)  ,
	@erreur  int,
	@error_type int ,
	--@p_date_t DateTime ,
	@Last_Booking_I4I_D     			 Char(8)  ,              -- Last Booking IFRS4 Q-1	
	@Last_Booking_EBS_D     			 Char(8)  ,             -- Last Booking EBS Q-1 (New)
	@Last_Booking_17_D      			 Char(8)  ,			        	-- Last Booking IFRS 17 Q-1
	@End_POS_I4I_D          			 Char(8)  ,               -- End date of POS IFRS4 Entry Q  
	@End_POS_EBS_D          			 Char(8)  ,               -- End date of POS EBS Entry Q (New)
	@End_POS_I17_D		    			 Char(8)  ,			          -- End date of POS IFRS17 Entry Q 
	@End_POC_I4I_D          			 Char(8)  ,               -- End date of POC IFRS4 Entry Q-1	 
	@End_POC_EBS_D          			 Char(8)  ,               -- End date of POC EBS Entry Q-1 (New)
	@End_POC_I17_D          			 Char(8)  ,               -- End date of POC IFRS17 Entry Q-1 (New)
	@isEnabledPOSocialEbs 		bit  ,
	@isEnabledPOSocialIfrs17 	bit  ,
	@isEnabledPOSocialIfrs 		bit  ,
	@isEnabledPOConsoIfrs		 bit  ,
	@isEnabledPOConsoEbs 		bit  ,
	@isEnabledPOConsoIfrs17 		bit  ,
	@isEnabledServiceIfrs 				bit  ,
	@isEnabledServiceEbs 				bit  ,
	@isEnabledServiceIfrs17 			bit  ,
	@isEnabledServiceLocal 				bit  ,
	@P_Erreur               			int     ,        -- CodeRetour Erreur pour Message Appli
    @site_cf        varchar(10) ,
    @param1         varchar(20),
	@nbligne_tctrano  int ,
    @tran_imbr    bit,
	@PARM5_MAX   tinyint ,    --  count days of POSX
	@sys_date_d      datetime 
select @tran_imbr = 1 



CREATE  TABLE #EST_ESID0801_TESTUTISUP 
(
    TRN_NT          numeric(10,0) NULL,           
    ACCTYP_NF       tinyint       NULL,
    SSD_CF          tinyint       NULL,
    ESB_CF          tinyint       NULL,
    ENTPERY_NF      smallint      NULL,
    ENTPERMTH_NF    tinyint       NULL,
    BALSHEY_NF      smallint      NOT NULL,
    BALSHRMTH_NF    tinyint       NOT NULL,
    BALSHRDAY_NF    tinyint       NOT NULL,
    VALPERY_NF      smallint      NOT NULL, 
    VALPERMTH_NF    tinyint       NOT NULL,
    TRNCOD_CF       char(8)       NOT NULL,
    DBLTRNCOD_CF    varchar(8)    NULL,
    RETAUTGEN_B     bit           NOT NULL,
    CTR_NF          varchar(9)    NULL,
    END_NT          tinyint       NULL,
    SEC_NF          tinyint       NULL,
    UWY_NF          smallint      NULL,
    UW_NT           tinyint       NULL,
    OCCYEA_NF       smallint      NULL,
    ACY_NF          smallint      NULL,
    SCOSTRMTH_NF    tinyint       NULL,
    SCOENDMTH_NF    tinyint       NULL,
    CLM_NF          int           NULL,
    CUR_CF          varchar(3)    NULL,
    AMT_M           decimal(18,3) NULL,
    CED_NF          int           NULL,
    BRK_NF          int           NULL,
    GEMPRMPAY_NF    int           NULL,
    GANPAYORD_NT    varchar(2)    NULL,
    RETCTR_NF       varchar(9)    NULL,
    RETEND_NT       tinyint       NULL,
    RETSEC_NF       tinyint       NULL,
    RTY_NF          smallint      NULL,
    RETUW_NT        tinyint       NULL,
    PLC_NT          int           NULL,
    RETOCCYEA_NF    smallint      NULL,
    RETACY_NF       smallint      NULL,
    RETSCOSTRMTH_NF tinyint       NULL,
    RETSCOENDMTH_NF tinyint       NULL,
    RCL_NF          int           NULL,
    RETCUR_CF       varchar(3)    NULL,
    RETAMT_M        decimal(18,3) NULL,
    RTO_NF          int           NULL,
    INT_NF          int           NULL,
    RETPAY_NF       int           NULL,
    RETKEY_CF       char(1)       NULL,
    ACCTRN_NT       numeric(10,0) NULL,
    COMMAC_LL       varchar(64)   NULL,
    CRE_D           datetime      NULL,
    CREUSR_CF       varchar(4)    NULL,
    LSTUPD_D        datetime      NULL,
    LSTUPDUSR_CF    varchar(4)    NULL,
    NUMLINE_NT      int           NOT NULL,
    SPEENTTYP_CF    tinyint       NULL,
    SPEENTNAT_CT    tinyint       NULL,
    EVT_NF          varchar(10)   NULL,
    REVT_NF         varchar(10)   NULL,
    CTRSTS_CT       tinyint       NULL,
    RETCTRSTS_CT    int           NULL,
    CTRLOB_CF       char(2)       NULL,
    RETLOB_CF       char(2)       NULL,
    TERCTR_B        int           NULL,
    CLMDET_NF       UCLM_NF       NULL,
    --CLMDET_EVT_NF   UEVT_NF       NULL,
    CHECK_21031     char(2)       NULL,
    GEV_NF          UEVT_NF       NULL,
    SUBEVT_NF       UEVT_NF       NULL,
    SUP_B           int           NULL,
    LOCALAE_CT      int 	      NULL,
    CHECK_307       char(2)       NULL,
    CHECK_21033     char(2)       NULL,
    SECSTS_CT       tinyint       NULL,
    SECACCSTS_CT    tinyint       NULL,
    ACCPLC_B        tinyint       NULL,
    PLCSTS_CT       tinyint       NULL,
    RETSIGSHA_R     USHA_R        NULL,
    LCKCLO_B        tinyint       NULL,
    TYPCTR          char(3)       NULL, 
    TYPRETCTR       char(3)       NULL,
	LIFE_CF			tinyint       NULL,
	OPN_B			tinyint		  NULL,
    CHECK_30020     char(2)       NULL,
    CHECK_24        char(2)       NULL,
    CHECK_25        char(2)       NULL,
    CHECK_106       char(2)       NULL,
	CHECK_21030		char(2)       NULL,
	CHECK_21032		char(2)       NULL,
	CHECK_118		char(2)       NULL,
	CHECK_119		char(2)       NULL,
	CHECK_120		char(2)       NULL,
	CHECK_121		char(2)       NULL,
	CHECK_122		char(2)       NULL,
	CHECK_123	char(2)       NULL,
    FRCIFRSBTCH_NT tinyint null,     --MOD06
	IS_BBNI tinyint DEFAULT 0 NULL   --MOD016
)


-- Copie de la partie d'insertion dans BTRAV..EST_ESID0801_TESTUTISUP de PtTSUIVINTACC_01
--=> alimenter la table BTRAV..EST_ESID0801_TESTUTISUP pour le contrôle de cohérence    
     INSERT INTO BTRAV..EST_ESID0801_TESTUTISUP
        (
        TRN_NT
        ,NUMLINE_NT
        ,SSD_CF         
        ,ESB_CF             
        ,BALSHEY_NF     
        ,BALSHRMTH_NF       
        ,BALSHRDAY_NF       
        ,VALPERY_NF     
        ,VALPERMTH_NF   
        ,TRNCOD_CF      
        ,RETAUTGEN_B    
        ,CTR_NF         
        ,END_NT              
        ,SEC_NF          
        ,UWY_NF              
        ,UW_NT               
        ,OCCYEA_NF       
        ,ACY_NF         
        ,SCOSTRMTH_NF   
        ,SCOENDMTH_NF       
        ,CLM_NF         
        ,CUR_CF         
        ,AMT_M          
        ,RETCTR_NF          
        ,RETEND_NT      
        ,RETSEC_NF      
        ,RTY_NF         
        ,RETUW_NT       
        ,PLC_NT         
        ,RETOCCYEA_NF   
        ,RETACY_NF      
        ,RETSCOSTRMTH_NF
        ,RETSCOENDMTH_NF
        ,RCL_NF         
        ,RETCUR_CF      
        ,RETAMT_M       
        ,COMMAC_LL      
        ,SPEENTTYP_CF   
        ,SPEENTNAT_CT
        ,CRE_D          
        ,CREUSR_CF      
        ,LSTUPD_D       
        ,LSTUPDUSR_CF      
        )
          SELECT convert(numeric(10,0),TRN_NT),
                 convert(int,NUMLIGNE_NT),
                 @p_ssd_cf,
                 @p_ESB,
                 convert(smallint,BALSHEY_NF),
                 convert(tinyint,BALSHRMTH_NF),
                 convert(tinyint,BALSHRDAY_NF),
                 convert(smallint,VALPERY_NF),
                 convert(tinyint,VALPERMTH_NF),
                 convert(char(8),rtrim(ltrim(TRNCOD_CF))),
                 convert(bit,RETAUTGEN_B),
                 convert(char(9),CTR_NF),
                 convert(tinyint,END_NT),
                 convert(tinyint,SEC_NF),
                 convert(smallint,UWY_NF),
                 convert(tinyint,UW_NT),
                 convert(smallint,OCCYEA_NF),
                 convert(smallint,ACY_NF),
                 convert(tinyint,SCOSTRMTH_NF),
                 convert(tinyint,SCOENDMTH_NF),
                 convert(int,CLM_NF),
                 convert(char(3),CUR_CF),
                 convert(decimal(18,3),str(round(convert(decimal(18,3),AMT_M),3),18,3)),
                 convert(char(9),RETCTR_NF),
                 convert(tinyint,RETEND_NT),
                 convert(tinyint,RETSEC_NF),
                 convert(smallint,RTY_NF),
                 convert(tinyint,RETUW_NT),
                 convert(int,PLC_NT),
                 convert(smallint,RETOCCYEA_NF),
                 convert(smallint,RETACY_NF),
                 convert(tinyint,RETSCOSTRMTH_NF),
                 convert(tinyint,RETSCOENDMTH_NF),
                 convert(int,RCL_NF),
                 convert(char(3),RETCUR_CF),
                 convert(decimal(18,3),str(round(convert(decimal(18,3),RETAMT_M),3),18,3)),
                 convert(varchar(64),rtrim(ltrim(COMMAC_LL))),
                 convert(tinyint,SPEENTTYP_CF),
                 convert(tinyint,SPEENTNAT_CT),
                 getdate(),
                 @p_USR_CF,
                 getdate(),
                 @p_USR_CF
           FROM BTRAV..EST_ESIJ0801_TESTUTISUP
        -- traiter code retour insert --
        SELECT @erreur = @@error
        IF @erreur != 0
            BEGIN
                GOTO ErreurNorm
            END
-- Fin de la copie de la partie d'insertion dans BTRAV..EST_ESID0801_TESTUTISUP de PtTSUIVINTACC_01


if @p_date_d = NULL 
	select @p_date_d =getdate()

select @sys_date_d = getdate()


INSERT INTO #EST_ESID0801_TESTUTISUP(
	TRN_NT          ,
	ACCTYP_NF       ,
	SSD_CF          ,
	ESB_CF          ,
	ENTPERY_NF      ,
	ENTPERMTH_NF    ,
	BALSHEY_NF      ,
	BALSHRMTH_NF    ,
	BALSHRDAY_NF    ,
	VALPERY_NF      ,
	VALPERMTH_NF    ,
	TRNCOD_CF       ,
	DBLTRNCOD_CF    ,
	RETAUTGEN_B     ,
	CTR_NF          ,
	END_NT          ,
	SEC_NF          ,
	UWY_NF          ,
	UW_NT           ,
	OCCYEA_NF       ,
	ACY_NF          ,
	SCOSTRMTH_NF    ,
	SCOENDMTH_NF    ,
	CLM_NF          ,
	CUR_CF          ,
	AMT_M           ,
	CED_NF          ,
	BRK_NF          ,
	GEMPRMPAY_NF    ,
	GANPAYORD_NT    ,
	RETCTR_NF       ,
	RETEND_NT       ,
	RETSEC_NF       ,
	RTY_NF          ,
	RETUW_NT        ,
	PLC_NT          ,
	RETOCCYEA_NF    ,
	RETACY_NF       ,
	RETSCOSTRMTH_NF ,
	RETSCOENDMTH_NF ,
	RCL_NF          ,
	RETCUR_CF       ,
	RETAMT_M        ,
	RTO_NF          ,
	INT_NF          ,
	RETPAY_NF       ,
	RETKEY_CF       ,
	ACCTRN_NT       ,
	COMMAC_LL       ,
	CRE_D           ,
	CREUSR_CF       ,
	LSTUPD_D        ,
	LSTUPDUSR_CF    ,
	NUMLINE_NT      ,
	SPEENTTYP_CF    ,
	SPEENTNAT_CT    ,
	EVT_NF          ,
	REVT_NF   )      
SELECT *
from BTRAV..EST_ESID0801_TESTUTISUP 
where
    SSD_CF= @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur  création de la table tempo #EST_ESID0801_TESTUTISUP'
    goto ErreurNorm
END


-- we remove from btrav..TESTUTISUP all subsidiary lines different from the subsidiary
-- use as parameter, it is normally rarely fall in this case, it means
-- that the user has mistakenly entered several subsidiaries in the file

-- Delete the existing lines from BTRAV..EST_ESID0801_TESTUTISUP with the appropriate subsidiary from input file and last updated usr_cf


DELETE btrav..EST_ESID0801_TESTUTISUP
where
    SSD_CF       != @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur  delete  de la table btrav..EST_ESID0801_TESTUTISUP'
    goto ErreurNorm
END

-- *************************************************************************************
--
--       FIRST STEP : AUTOMATIC UPDATING IN SOME FIELDS
--
-- *************************************************************************************

-- access to the  BREF..TCALEND table to determinate the entry period
-- -------------------------------------------------------------------

Execute @erreur = BREF..PsCALEND_02
      @p_date_d , --  @cre_d,
      'C',
      @entpery_nf output,
      @entpermth_nf output,
      @spcend_d output,
      @account_d output,
      @closing_b output

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur BREF..PsCALEND_02'
    goto ErreurNorm
END



----------------------------------------------------------------------------------
    
select  @param1 = convert(varchar,@p_ssd_cf)
execute @erreur = BEST..PsSITE_01 @param1,'2',@site_cf output

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur BEST..PsSITE_01'
    goto ErreurNorm
END


Select 
 @NORME =
CASE
    WHEN SPEENTNAT_CT in (9,10,11)  THEN "IFRS17"
    WHEN SPEENTNAT_CT in (4,5,6)  THEN "EBS"
    WHEN SPEENTNAT_CT in (1,2,3)  THEN "IFRS4"
END
FROM #EST_ESID0801_TESTUTISUP

--Select @p_date_t = getdate()
Select @Verif_d  = GetDate()


				   
If EXISTS (Select 1 FROM btrav..EST_ESID0801_TESTUTISUP
                    where
                       SSD_CF       = @p_ssd_cf
                   and LSTUPDUSR_CF = @p_usr_cf)

   Begin
							   
	Execute @erreur =  BEST..PtREQJOB_I17_05 
		@sys_date_d ,-- @p_date_t               			,
		@site_cf              			,
		@Last_Booking_I4I_D     	output ,              -- Last Booking IFRS4 Q-1	
		@Last_Booking_EBS_D     	output ,             -- Last Booking EBS Q-1 (New)
		@Last_Booking_17_D      	output ,			        	-- Last Booking IFRS 17 Q-1
		@End_POS_I4I_D          	output ,               -- End date of POS IFRS4 Entry Q  
		@End_POS_EBS_D          	output ,               -- End date of POS EBS Entry Q (New)
		@End_POS_I17_D		    	output ,			          -- End date of POS IFRS17 Entry Q 
		@End_POC_I4I_D          	output ,               -- End date of POC IFRS4 Entry Q-1	 
		@End_POC_EBS_D          	output ,               -- End date of POC EBS Entry Q-1 (New)
		@End_POC_I17_D          	output ,               -- End date of POC IFRS17 Entry Q-1 (New)
		@Post_Omega_Entry_I4I_D 	output ,               -- Quarter post omega IFRS4 (New)
		@Post_Omega_Entry_EBS_D 	output ,               -- Quarter post omega EBS (New)
		@Post_Omega_Entry_I17_D 	output ,               -- Quarter post omega IFRS17 (New)
		@Post_Omega_Yea_I4I_D   	output   ,   -- Year post omega IFRS4 (New)
		@Post_Omega_Yea_EBS_D   	output   ,   -- Year post omega EBS (New)
		@Post_Omega_Yea_I17_D   	output   ,   -- Year post omega IFRS17 (New)
		@Post_Omega_Mth_I4I_D   	output    ,  -- Month post omega IFRS4 (New)
		@Post_Omega_Mth_EBS_D   	output  ,    -- Month post omega EBS (New)
		@Post_Omega_Mth_I17_D   	output   ,   -- Month post omega IFRS17 (New)
		@INV_Entry_I4I_D        	output ,               -- Quarter INV IFRS4 (New)
		@INV_Entry_EBS_D        	output ,               -- Quarter INV EBS (New)
		@INV_Entry_I17_D        	output ,               -- Quarter INV IFRS17 (New)
		@INV_Mth_I4I_D          	output   ,  -- Month INV IFRS4 (New)
		@INV_Mth_EBS_D          	output  ,   -- Month INV EBS (New)
		@INV_Mth_I17_D          	output  ,   -- Month INV IFRS17 (New)
		@INV_Yea_I4I_D          	output  ,   -- Year INV IFRS4 (New)
		@INV_Yea_EBS_D          	output  ,   -- Year INV EBS (New)
		@INV_Yea_I17_D          	output   ,  -- Year INV IFRS17 (New)
		@isEnabledPOSocialEbs 		output ,
		@isEnabledPOSocialIfrs17 	output ,
		@isEnabledPOSocialIfrs 		output ,
		@isEnabledPOConsoIfrs		output ,
		@isEnabledPOConsoEbs 		output ,
		@isEnabledPOConsoIfrs17 	output ,
		@isEnabledServiceIfrs 		output ,
		@isEnabledServiceEbs 		output ,
		@isEnabledServiceIfrs17 	output ,
		@isEnabledServiceLocal 		output ,
		@P_SuffixeTable         	output ,               -- Nom de Suffixe de TABLE : '0' si Erreur
		@P_Erreur               	output          -- CodeRetour Erreur pour Message Appli
								   
        select @erreur = @@error


			   
			   
	    Select
		   @DateInventaireConso= CASE
									WHEN @NORME = "IFRS17"  THEN @Post_Omega_Entry_I17_D
									WHEN @NORME = "EBS"   	THEN @Post_Omega_Entry_EBS_D
									WHEN @NORME = "IFRS4"   THEN @Post_Omega_Entry_I4I_D
								 END,
		   @PeriodeConsoAA= 	 CASE
									WHEN @NORME = "IFRS17"  THEN @Post_Omega_Yea_I17_D
									WHEN @NORME = "EBS"   	THEN @Post_Omega_Yea_EBS_D
									WHEN @NORME = "IFRS4"   THEN @Post_Omega_Yea_I4I_D
								END,
		   @PeriodeConsoMM= 	 CASE
									WHEN @NORME = "IFRS17"  THEN @Post_Omega_Mth_I17_D
									WHEN @NORME = "EBS"   	THEN @Post_Omega_Mth_EBS_D
									WHEN @NORME = "IFRS4"   THEN @Post_Omega_Mth_I4I_D
								END,
			-- SPIRA 108733
		   	@PeriodeInvAA= 	 	CASE
									WHEN @NORME = "IFRS17"  THEN @INV_Yea_I17_D
									WHEN @NORME = "EBS"   	THEN @INV_Yea_EBS_D
									WHEN @NORME = "IFRS4"   THEN @INV_Yea_I4I_D
								END,
		   @PeriodeInvMM= 	 	CASE
									WHEN @NORME = "IFRS17"  THEN @INV_Mth_I17_D
									WHEN @NORME = "EBS"   	THEN @INV_Mth_EBS_D
									WHEN @NORME = "IFRS4"   THEN @INV_Mth_I4I_D
								END,	
			-- END SPIRA 108733
		   @DateInventaireService= CASE
									WHEN @NORME = "IFRS17"  THEN @INV_Entry_I17_D
									WHEN @NORME = "EBS"   	THEN @INV_Entry_EBS_D
									WHEN @NORME = "IFRS4"   THEN @INV_Entry_I4I_D
								END
--               @P_Erreur                as 'P_Erreur',
			   
			   

        if @erreur != 0
            begin
              select @MsgAnomalie  = 'Erreur Accès BEST..PtREQJOB_05'
               goto ErreurNorm
            end

        If (@P_SuffixeTable = '0') or (@P_SuffixeTable = Null)
                Begin
                    select @MsgAnomalie = "Erreur Paramètres CONSO/SOCIAL Incorrect" + Convert(Char(5), @P_Erreur)
                    goto ErreurNorm
                End
            Else
                Begin
                  If EXISTS (Select 1 FROM #EST_ESID0801_TESTUTISUP
                                      where
                                           SPEENTNAT_CT not in(1,4,9))   --[23390]
                    Begin
                       Select @entpery_nf = @PeriodeConsoAA
                       Select @entpermth_nf = @PeriodeConsoMM
                       Select @Verif_d = DateAdd(Day, -1, @DateInventaireConso)
                    End
					
                  Else
                    Begin
					   Select @entpery_nf = @PeriodeInvAA
                       Select @entpermth_nf = @PeriodeInvMM
                       Select @Verif_d = DateAdd(Day, -1, @DateInventaireService)
					   
                    End
                End
    End





--select @cre_d = getdate()

-- MN 05
UPDATE  #EST_ESID0801_TESTUTISUP
SET ENTPERY_NF   = @entpery_nf,
  ENTPERMTH_NF = @entpermth_nf,
  CRE_D        = @sys_date_d ,--@cre_d,
  LSTUPD_D     = @sys_date_d ,--@cre_d,
  CREUSR_CF    = @p_usr_cf                  -- MOD012-11/04/2006 CREUSR_CF = "DSK"

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur update #EST_ESID0801_TESTUTISUP / set ENTPERY_NF .....'
    goto ErreurNorm
END




UPDATE #EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ACCESB_CF,
  CED_NF = B.CED_NF,
  BRK_NF = B.PRD_NF,
  GEMPRMPAY_NF = B.GENPRMPAY_NF,
  GANPAYORD_NT = B.GANPAYORD_NT,
  TYPCTR ="FAC",
  CTRSTS_CT = B.CTRSTS_CT
FROM  #EST_ESID0801_TESTUTISUP A, 
    BFAC..TCONTR B
where
    A.CTR_NF        = B.CTR_NF
and A.END_NT        = B.END_NT
and A.UWY_NF        = B.UWY_NF
and A.UW_NT         = B.UW_NT

                        

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 06'
    goto ErreurNorm
END 


UPDATE #EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ACCESB_CF,
  CED_NF = B.CED_NF,
  BRK_NF = B.PRD_NF,
  GEMPRMPAY_NF = B.GENPRMPAY_NF,
  GANPAYORD_NT = B.GANPAYORD_NT,
 TYPCTR ="TRT",
  CTRSTS_CT = B.CTRSTS_CT
FROM  #EST_ESID0801_TESTUTISUP A,
        btrt..TCONTR B
where
    A.CTR_NF       = B.CTR_NF
and A.END_NT       = B.END_NT
and A.UWY_NF       = B.UWY_NF
and A.UW_NT        = B.UW_NT

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 07'
    goto ErreurNorm
END 


UPDATE #EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ESB_CF,
  TYPRETCTR ="RET",
    RETCTRSTS_CT = B.RETCTRSTS_CT,
    TERCTR_B = B.TERCTR_B
FROM  #EST_ESID0801_TESTUTISUP A,
        bret..TRETCTR B
where
     A.RETCTR_NF     = B.RETCTR_NF
and A.RTY_NF        = B.RTY_NF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 08'
    goto ErreurNorm
END 

/********UPDATE FRCIFRSBTCH_NT INFO for TRT/FAC - MOD06******/

UPDATE #EST_ESID0801_TESTUTISUP
SET FRCIFRSBTCH_NT=0

UPDATE #EST_ESID0801_TESTUTISUP
SET FRCIFRSBTCH_NT = 1
FROM #EST_ESID0801_TESTUTISUP T, BTRT..TSECIFRS TS
WHERE    T.CTR_NF      != NULL
and         T.CTR_NF       = TS.CTR_NF
and         T.UWY_NF      = TS.UWY_NF
and         T.END_NT       = TS.END_NT
and         T.UW_NT        = TS.UW_NT
and         T.TYPCTR ="TRT"
and         TS.FRCIFRSBTCH_NT = 1

UPDATE #EST_ESID0801_TESTUTISUP
SET FRCIFRSBTCH_NT = 1
FROM #EST_ESID0801_TESTUTISUP T, BFAC..TSECIFRS TS
WHERE    T.CTR_NF      != NULL
and         T.CTR_NF       = TS.CTR_NF
and         T.UWY_NF      = TS.UWY_NF
and         T.END_NT       = TS.END_NT
and         T.UW_NT        = TS.UW_NT
and         T.TYPCTR ="FAC"
and         TS.FRCIFRSBTCH_NT = 1

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 30'
    goto ErreurNorm
END 


UPDATE #EST_ESID0801_TESTUTISUP
SET A.LIFE_CF = B.LIFE_CF 
FROM  	#EST_ESID0801_TESTUTISUP A,  BREF..TESB B
where  	A.SSD_CF   = B.SSD_CF
and 	A.ESB_CF   = B.ESB_Cf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 09'
    goto ErreurMaj
END 


UPDATE #EST_ESID0801_TESTUTISUP
SET A.LOCALAE_CT = B.LOCALAE_CT
FROM  	#EST_ESID0801_TESTUTISUP A,  BREF..TESB B
where  	A.SSD_CF   = B.SSD_CF
and 	A.ESB_Cf   = B.ESB_Cf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 10'
    goto ErreurMaj
END 

UPDATE #EST_ESID0801_TESTUTISUP 
SET CTRLOB_CF =s.LOB_CF,
 SECSTS_CT  =s.SECSTS_CT,
 SECACCSTS_CT=s.SECACCSTS_CT
from #EST_ESID0801_TESTUTISUP  a, btrt..tsection s where
	 a.ctr_nf = s.ctr_nf
 and A.END_NT = s.END_NT
 and a.sec_nf = s.sec_nf
 and a.uwy_nf = s.uwy_nf
 and a.uw_nt = s.uw_nT

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 11'
    goto ErreurMaj
END 

UPDATE #EST_ESID0801_TESTUTISUP 
SET CTRLOB_CF =s.LOB_CF ,
 SECSTS_CT  =s.SECSTS_CT,
 SECACCSTS_CT=s.SECACCSTS_CT
from #EST_ESID0801_TESTUTISUP  a, bfac..tsection s where
	 a.ctr_nf = s.ctr_nf
 and A.END_NT = s.END_NT
 and a.sec_nf = s.sec_nf
 and a.uwy_nf = s.uwy_nf
 and a.uw_nt = s.uw_nT
 
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 12'
    goto ErreurMaj
END 
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 13'
    goto ErreurMaj
END 

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 14'
    goto ErreurMaj
END 

UPDATE #EST_ESID0801_TESTUTISUP 
SET RETLOB_CF =s.LOB_CF
from #EST_ESID0801_TESTUTISUP  a, bret..tretsec s where
        a.retctr_nf = s.retctr_nf
 and a.retsec_nf = s.retsec_nf
 and a.rty_nf = s.rty_nf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 15'
    goto ErreurMaj
END 

-- MN 09
UPDATE #EST_ESID0801_TESTUTISUP
SET OCCYEA_NF = UWY_NF
where
    CTR_NF       != NULL
and OCCYEA_NF    = null


-- MN 10
UPDATE #EST_ESID0801_TESTUTISUP
SET RETOCCYEA_NF = RTY_NF
where
    RETCTR_NF    != NULL
and RETOCCYEA_NF = null


select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 16'
    goto ErreurMaj
END 

-- MN 11
UPDATE #EST_ESID0801_TESTUTISUP
SET a.RTO_NF    = b.RTO_NF,
    a.INT_NF    = b.INT_NF,
    RETPAY_NF = PAY_NF,
    RETKEY_CF = KEY_CF,
    ACCPLC_B  = b.ACCPLC_B,
    PLCSTS_CT = b.PLCSTS_CT,
    RETSIGSHA_R = b.RETSIGSHA_R,
    LCKCLO_B = b.LCKCLO_B
FROM #EST_ESID0801_TESTUTISUP a,
     bret..TPLACEMT b
where
    a.RETCTR_NF = b.RETCTR_NF
    and a.RTY_NF    = b.RTY_NF
    and a.PLC_NT    = b.PLC_NT
    and HIS_B       = 0

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 17'
    goto ErreurMaj
END 


-- MN 12        
UPDATE #EST_ESID0801_TESTUTISUP
SET  DBLTRNCOD_CF = CTRSCOD_CF,
	a.OPN_B = b.OPN_B  
FROM #EST_ESID0801_TESTUTISUP a,
     bref..TDETTRS b
where
    b.DETTRS_CF      = a.TRNCOD_CF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 21'
    goto ErreurMaj
END 


Update #EST_ESID0801_TESTUTISUP
SET CLMDET_NF= CLM.CLMDET_NF ,
      SUBEVT_NF = EVT.SUBEVT_NF,
      GEV_NF = EVT.GEV_NF
from #EST_ESID0801_TESTUTISUP a,
                BCTA..TCLAIM CLM,
                BCTA..TCLMDET CLMDET, 
                BCTA..TEVENT EVT
WHERE 
       EVT.SSD_CF = CLM.SSD_CF 
	     AND  CLM.CLM_NF = a.clm_nf       
       AND  CLM.SSD_CF = a.SSD_CF
       AND  CLM.CLMDET_NF = CLMDET.CLM_NF
       AND  CLMDET.EVT_NF = EVT.SUBEVT_NF
       AND  CLMDET.SSD_CF = EVT.SSD_CF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 28'
    goto ErreurMaj
END 

 -- MN err_21030      
Update #EST_ESID0801_TESTUTISUP       
SET SUP_B =T2.SUP_B 
from #EST_ESID0801_TESTUTISUP A,
    BCTA..TEVTDET T2,
    BCTA..TGRPEVT T7
 WHERE
    T7.GEV_NF = T2.EVT_NF AND
    T7.SSD_CF = T2.SSD_CF AND
    T2.SUP_B = 0 AND
    T2.SSD_CF = 0 AND
    T2.SUP_B = 0 AND
    T2.SSD_CF = 0 AND
  A.EVT_NF = ("G"+CAST( T2.EVT_NF AS VARCHAR(10))) AND
  A.EVT_NF IS NOT NULL AND
  A.EVT_NF <> ""     
       
       
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 29'
    goto ErreurMaj
END 


-------------------------------------------------------------------------------
    
    -- MN 02
    select top 1 @p_site_cf = b.PRDSIT_CF  --, @cre_d = getdate() 
    from bref..TBATCHSSD a, BREF..TBATCHNIGHT b
    where a.BATCHUSER_CF=b.BATCHUSER_CF and a.SSD_CF=@p_SSD_CF

 



select @blcshtmth_nf = blcshtmth_nf+1 from bref..tcalend a
where account_d = (select max(account_d) from bref..tcalend b
                   where account_d <  @sys_date_d ) -- getdate())
				   
-- MN 03
  select @blcshtyea_nf = A.blcshtyea_nf,
     @blcshtmth_nf = A.blcshtmth_nf,            
     
     @spcend_d = A.specend_d,
     @account_d = A.account_d,
     @closing_b = A.closing_b
    from BREF..TCALEND A
      where ((A.blcshtyea_nf * 100) + A.blcshtmth_nf)=(     select min((B.blcshtyea_nf * 100) + B.blcshtmth_nf)
                                                                                from BREF..TCALEND B 
                                                                                where convert(Char(10),B.account_d,112) >= convert(Char(10),@p_date_d,112))



select @blcshtmth_nf = blcshtmth_nf+1 from bref..tcalend a
where account_d = (select max(account_d) from bref..tcalend b
                   where account_d < @sys_date_d ) -- getdate())
                   
                   
                   
                   select @balshtmth_nf = balshtmth_nf from best..treqjob a
where dbclo_d = (select max(dbclo_d) from best..treqjob b
                 where reqcod_ct = 'B'
                 and   site_cf = @p_site_cf
                 and   launch_d is not null)
                 
                 
--print '==> @cre_d = %1! ',  @cre_d
print '==> @isPostingSas_d = %1! ',  @isPostingSas_d
print '==> @sys_date_d = %1! ',  @p_date_d
print '==> @p_date_d = %1! ',  @p_date_d
print '==> @End_POS_I17_D = %1! ',  @End_POS_I17_D
                 

--[016] END

/* writing of type 1 */
/* pure acceptance    */
/* ------------------- */
UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 1
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF = NULL OR RETCTR_NF = "")
--or SPEENTTYP_CF in (8,9)

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 1 "
goto ErreurMaj
end



/* pure acceptance */
/* pure retro 100%      */
/* ------------------- */

UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 2,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF = NULL OR CTR_NF = "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT = NULL OR PLC_NT = 0)           -- 100%


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 2 "
goto ErreurMaj
end
/* writing of type 3 */
/* acceptance and retro 100%*/
/* ------------------- */


UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 3,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT = NULL OR PLC_NT = 0)      -- 100%


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 3 "
goto ErreurMaj
end

/* Writing of type 4 */
/* REtro pure à la part */
/* ------------------- */

UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 4,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF = NULL OR CTR_NF = "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT != NULL AND PLC_NT != 0)


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 4 "
goto ErreurMaj
end
/* writing of type 5 */
/* Accept et rétro à la part */
/* ------------------- */

UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 5,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT != NULL AND PLC_NT != 0)


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 5 "
goto ErreurMaj
end
Update #EST_ESID0801_TESTUTISUP
   set ENTPERY_NF = BALSHEY_NF
      ,ENTPERMTH_NF = BALSHRMTH_NF
where SPEENTNAT_CT  in (7,8)



declare     @max_trn_nt   numeric( 10, 0 )
select @max_trn_nt = isnull(max( TRN_NT ),0)
FROM  BEST..TACCSUP

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end
  
INSERT into BEST..TACCSUP
( TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M,
  CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RETRTY_NF,
  RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF)                                     -- MOD005 26/04/2005 -- MOD007
select A.TRN_NT+@max_trn_nt, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from #EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT      --Mod31
  where   (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")     --Mod31
  and A.REVT_NF = CAST(TCLM.EVT_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF         --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF
UNION
select A.TRN_NT+@max_trn_nt, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from #EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT      --Mod31
  where  (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")           --Mod31
  and A.REVT_NF = "G" + CAST(EVT.GEV_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF        --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF 

UNION
-- if the claim is null or the claim is null, there should be no error
select A.TRN_NT+@max_trn_nt, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from #EST_ESID0801_TESTUTISUP A
 WHERE  (A.REVT_NF is null OR A.RCL_NF is null OR A.REVT_NF is null OR  A.REVT_NF = "")

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- If posting SAS AE are also inserted in TACCSUPSAP to make them undeleted from TACCSUP
if @isPostingSas_d is not NULL
begin

INSERT into BEST..TACCSUPSAP
( TRN_NT, PARM1, PARM2, PARM3, CTR_NF, SEC_NF, UWY_NF, RETCTR_NF, RETSEC_NF, RETRTY_NF,POSTING_D, SENDED_B, LSTUPDUSR_CF)
select A.TRN_NT+@max_trn_nt, '', '', '', A.CTR_NF, A.SEC_NF, A.UWY_NF, A.RETCTR_NF, A.RETSEC_NF, A.RTY_NF, NULL, 0, suser_name()
 from #EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT
  where   (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")
  and A.REVT_NF = CAST(TCLM.EVT_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF         --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF
UNION
select A.TRN_NT+@max_trn_nt, '', '', '', A.CTR_NF, A.SEC_NF, A.UWY_NF, A.RETCTR_NF, A.RETSEC_NF, A.RTY_NF, NULL, 0, suser_name()
 from #EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT
  where  (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")
  and A.REVT_NF = "G" + CAST(EVT.GEV_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF 

UNION
-- if the claim is null or the claim is null, there should be no error
select A.TRN_NT+@max_trn_nt, '', '', '', A.CTR_NF, A.SEC_NF, A.UWY_NF, A.RETCTR_NF, A.RETSEC_NF, A.RTY_NF, NULL, 0, suser_name()
 from #EST_ESID0801_TESTUTISUP A
 WHERE  (A.REVT_NF is null OR A.RCL_NF is null OR A.REVT_NF is null OR  A.REVT_NF = "")	

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

end

DELETE btrav..EST_ESID0801_TESTUTISUP 
where
  SSD_CF       = @p_ssd_cf
  and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- -----------------------------------------------------------
--  End of the transaction 
------------------------------------------------------------
   
--	MOD034

Fin:
     if ( @MsgGlobalAnomalie != null )
        print @MsgGlobalAnomalie
    if @tran_imbr = 0
        COMMIT TRAN
    return 0
	

ErreurNorm:
    Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie 
    raiserror 20113 @MsgGlobalAnomalie
    return 1




ErreurAno:
-- MOD034 anomaly insertion removed from this

-- [026]
    if @p_batch_mode != 'batch'
        BEGIN
            Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie 
            raiserror 20113 @MsgGlobalAnomalie
        END
    return 1

ErreurMAJ:
    if @tran_imbr = 0 ROLLBACK TRAN

    Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie 
    raiserror 20113 @MsgGlobalAnomalie
    Select @MsgGlobalAnomalie 
    return 1
go

EXEC sp_procxmode 'dbo.PiACCSUP_SAS_04', 'unchained'
go
IF OBJECT_ID('dbo.PiACCSUP_SAS_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiACCSUP_SAS_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiACCSUP_SAS_04 >>>'
go
GRANT EXECUTE ON dbo.PiACCSUP_SAS_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiACCSUP_SAS_04 TO GDBBATCH
go
