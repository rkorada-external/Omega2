use BEST
go
if object_id('PsPeriFac_01') is not null
begin
   drop procedure PsPeriFac_01
   if object_id('PsPeriFac_01') is not null
     print '<<< FAILED DROPPING procedure PsPeriFac_01 >>>'
   else
     print '<<< DROPPED procedure PsPeriFac_01 >>>'
end
go
create procedure PsPeriFac_01
(
  @p_segtyp_ct      char(1), --type de segmentation ( 'A' ou 'E' )
  @p_clo_date       char(8),
  @p_x_days         int,
  @norme_cf         char(4),
  @p_quarter_end    varchar(10), --quarter end for dry run,
  @p_typeinv_cf 	char(4) --[029]
)
as
/***************************************************
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:
    - Descente du p�rim�tre acceptation des bases facs au niveau CASEX.
Le filtre sur la date d'effet est fait ult�rieurement par un programme C
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  M.HA-THUC     12/03/1998 rajout de 2 champs suppl�mentaire au p�rim�tre 
                            - USRCRTCOD_CT ( code du crit�re utilisateur acceptation )
                            - USRCRTVAL_LM ( valeur du crit�re utilisateur acceptation )
2  M.Ha-Thuc     20/03/1998 rajout de 2 champs suppl�mentaires au p�rim�tre
                            - PRDBRKTYP_CT ( type de courtage apporteur )
                            - ACCBRKTYP_CT ( type de courtage �metteur de comptes )
3  M.Ha-Thuc     26/05/1998 rajout de 2 champs suppl�mentaires au p�rim�tre - UWORG_CF ( origine du portefeuille )
4  M.Ha-Thuc     15/09/1998 - suppression de la jointure avec BTRAV..TESTSSD; on descend maintenant quotidiennement
                            un p�rim�tre pour toutes les filiales. Le filtre sur les filiales de l'inventaire sera fait dans la cha�ne ESID0560.
                            - rajout de champs suppl�mentaires pour mise � jour des tables de l'infocentre ( TULTIMATES, TCTRSTAT)
                            - plus de restriction sur l'�tat de la section et du contrat lors de la descente quotidienne du p�rim�tre.
                            Le filtre sera fait dans la cha�ne ESID0001.
5  M.Ha-Thuc     06/10/1998 - cette proc�dure n'est plus appel�e pour les p�rim�tres de segmentation. En effet, la restriction sur la s�lection
                            des affaires des p�rim�tres n'est plus la m�me ( en segmentation, on ne prend que les contrats non termin�s SECACCSTS_CT != 9 ).
6  M.Ha-Thuc     08/10/1998 - suppression de la jointure avec la table BCLI..TCLREPCR ( qui �tait fausse !! ), qui permettait de r�cup�rer le champs ORDNBR_NT.
                            Cette donn�e n'est pas utilis�e par la vie.
7  M.Bourdaillet 05/03/1999 Rajout de six champs pour la segmentation client. Triple Jointure externe sur BCLI..TCLREPCR. (CLE CLI_NF/SSD_CF)
                            on fait correspondre cette cle avec TCONTR (ced_nf ou orgced_nf ou prd_nf , ssd_cf)
8  MONTAGNAC     25/08/1999 Ajout du bit FACADMTYP_B dans le select.
9  F Charles     06/05/2000 Ajout de la date CRTVRSINC_D dans le select.
10 O.Arik(AURA)  30/03/2001 Ajout de RECBRK_B (Indic d'existance de courtage sur REC) et de RECBRK_R (taux de court. sur reconstitution) dans le select.
11 J. Ribot      04/06/2003 Ajout de CNATYP_CT (Indic MODE CALCUL CNA) dans le select.
12 J. Ribot      31/03/2005 Ajout de CLMCUTOFF_B PRMCUTOFF_B CLMRUNOFF_B PRMRUNOFF_B dans le select.  pour alimenter colonnes table TLIFSTAREP
13 J. Ribot      09/12/2008 Champ SECTION.ASSFINANCE_CT rajout� au perim�tre SPOT16593
14 r. Cassis     03/06/2010 :spot:19204 - V114 - Optimisation requete en forcant l'utilisation de l'index dans #TCLI - Tctrult retire car pas de facs dedans
15 Kbagwe        16/04/2013 Replacing obsolete table TCLREPCR with TCLINTSU
16 P.Coppin      15/10/2013 :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
17 Florent       20/11/2014 :spot:27747 Multi Currency - ajout colonnes sur le p�rim�tre
                            :spot:27748 Loss Corridor  - ajout colonnes sur le p�rim�tre
18 P. Menant     02/03/2015 :spot:28306 EST37
19 -=Dch=-  	 10/02/2016 :spot:30167 Modification de la colonne ESTV2C_COL_17 pour les options de portefeuille
20 - MZM         05/02/2018 :Spira:42213 Arret des Estimations pour les traites invalides (CTRLCK_B = 0) 
							 et les FAC dont l'avenant est invalide (CTRLCK_B = 1)
[021] JYP        09/10/2018 :IFRS17 req 10.6 : ajout table TSECIFRS Loss Ratios
[022] TY         17/06/2019 :IFRS17 req 10.11 : ajout champ CANEGP_M de TSECIFRS
[023] MZM        04/08/2020 :spira:87324 SCOR EGPI data for dummy Contracts : AT INI Replace SCOADDEGP_M with SCOORGEGP_M  
[024] DaD        08/01/2022  spira : 94569 Condition on contract recognition date and inception dates in pericase extractions
[025] DaD        25/04/2022    spira : 94569 add parameter Quarter End
[026] DaD        23/01/2023    spira : 107224 not include contract recognized on cut off date
[027] DaD        21/06/2023    spira : 109347 add the status 14 - Accepted
[028] FCI        20/07/2023 :spira 109507 I17 - Modify rule of CSM and LC pattern computation for multi year contracts
[029] MZM        11/03/2025 :spira : 112796 Cut-off management : Contract recognized day of cut-off should be taken into account
[030] MZM           28/07/2025 :US 6250  : 112796 Cut-off management : Contract recognized day of cut-off should be taken into account
*****************************************************/
declare @erreur int

DECLARE
  @v_year_clo_date int,
  @v_month_clo_date int,
  @v_pos_booking_d datetime,
  @v_pos_booking_minus_days datetime,
  @v_clo_date datetime

-- [024]
IF(@norme_cf = 'EBS')
BEGIN
  SELECT @v_clo_date = CONVERT(datetime, @p_clo_date, 112)

  -- [025]
  IF(@p_quarter_end = 'NONE')
  BEGIN
    SELECT @v_year_clo_date = CONVERT(int, substring(@p_clo_date, 1, 4))
    SELECT @v_month_clo_date = CONVERT(int, substring(@p_clo_date, 5, 2))
    SELECT @v_pos_booking_d = EBSPSTOMGEND_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF = @v_month_clo_date
    SELECT @v_pos_booking_minus_days = dateadd(day,1,dateadd(day, @p_x_days * -1, @v_pos_booking_d) ) --030dateadd(day, @p_x_days * -1, @v_pos_booking_d)
  END
  ELSE 
  BEGIN
    SELECT @v_pos_booking_minus_days = dateadd(day, 1, convert(datetime, @p_quarter_end, 103) ) --030 dateadd(day, 1, convert(datetime, @p_quarter_end, 103) )  --[029] convert(datetime, @p_quarter_end, 103)
  END

  
END

-- P�rim�tre pour les facs
SELECT
  SECTION.SSD_CF
 ,@p_segtyp_ct
 ,SECTION.CTR_NF
 ,SECTION.END_NT
 ,SECTION.SEC_NF
 ,SECTION.UWY_NF
 ,SECTION.UW_NT
 ,ACCESB_CF
 ,'M'  --  isnull( CTRULT.ADMMODPRM_CT,'M' )
 ,ANLCTY_CF
 ,CONVERT(char(8),CAN_DT,112)
 ,CED_NF
 ,CLI1.CLICTY_CF
 ,CLI1.CLINAT_CF
 ,NULL
 ,1           -- En Facs il s agit toujours de commissions fixes
 ,CTBGENFEE_R
 ,CTBTYP_CT
 ,CONVERT(char(8),CTRINC_D,112)
 ,CLI1.CLISSD_CF -- Permet l'affectation de CTRRET_B
 ,CUTSHA_R
 ,SECTION.DIV_NT
 ,FAMLIA.EGPCUR_CF
 ,CONTR.ESTCRB_CT
 ,ESTCTR_NF
 ,ESTEND_B
 ,NULL -- ESTSEC_NF par defaut
 ,CONVERT(char(8),CTREXP_D,112)
 ,FIXCOM_R
 ,SECTION.FRSUWY_NF
 ,GANPAYORD_NT
 ,GAR_CF
 ,GENPRMPAY_NF
 ,GENPRMSEN_NF
 ,NULL -- Non renseigne pour les facs
 ,LAYCAP_M
 ,LIFTRTTYP_CF
 ,LOB_CF
 ,LOSCOREXI_B
 ,LOSCORHIG_R
 ,LOSCORLOW_R
 ,LOSCORRAT_R
 ,LOSCTB_R
 ,LOSCTBEXI_B
 ,MAXCOM_R
 ,MAXRATCLP_R
 ,MINCOM_R
 ,MINRATCLP_R
 ,NAT_CF
 ,NULL        -- modifs du 08/10/1998 le champs ORDNBR_NT est forc� � NULL
 ,PCPCUR_CF
 ,PCPRSKTRY_CF
 ,NULL  -- Non renseigne pour les facs
 ,PRD_NF
 ,PRFCOM_R
 ,PRFCOMEXI_B
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,NULL
 ,PRMNETCOM_B
 ,NULL -- Non renseigne pour les facs
 ,REIEXI_B
 ,REIFRE_B
 ,REINBR_N
 ,REIUNL_B
 ,RESTRFDUR_N
 ,RESTRFTYP_CF
 ,NULL
 ,NULL
 ,SCLCOMEXI_B
 ,SCLCTBEXI_B
 ,SCOADDEGP_M = (case when (SCOADDEGP_M=null and CONTR.UWORG_CF = 248) then SCOORGEGP_M else SCOADDEGP_M end) --[023] SCOADDEGP_M -- SCOEGP_M par defaut anciennement scogloegp (23/04/99)         
 ,CONVERT(char(8),SCOINC_D,112)
 ,SECACCSTS_CT
 ,CONVERT(char(8),CTRINC_D,112)  -- Affectation de SECINC_D
 ,SECSTS_CT
 ,SEG_NF
 ,SOB_CF
 ,SUBNAT_CF
 ,NULL
 ,TOP_CF
 ,'F'     -- CTRNAT_CT
 ,UWGRP_CF
 ,NULL
 ,NULL     -- Non renseigne pour les facs
 ,CONVERT(char(8),ORGINC_D,112)
 ,LIARIDSHA_B
 ,NULL
 ,RIDSHA_R
 ,CTBCALLVL_CF
 ,NULL -- Non renseigne pour les facs
 ,NULL
 ,NULL
 ,ACCADMTYP_CT
 ,NULL
 ,CTRSTS_CT
 ,OVRCOM_R
 ,OVRCOMTYP_CT
 ,TAXCNDEXI_B
 ,PRDBRK_R
 ,ACCBRK_R
 ,NULL -- LIACUR_CF : non utilis� pour les facs
 ,NULL -- ERNPRMADM_B : non utilis� pour les facs
 ,CONVERT(char(8),SECCAN_D,112) -- Permet l'affectation de EXP_D
 ,SCOORGEGP_M                     -- Permet l'affectation de SCOEGP_M
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond aux champs retro non utilises en acceptation
 ,NULL -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire
 ,SECTION.USRCRTCOD_CT   -- Champ rajout� au perim�tre modif du 12/03/98
 ,SECTION.USRCRTVAL_LM   -- Champ rajout� au perim�tre modif du 12/03/98
 ,FAMCHG.PRDBRKTYP_CT        -- Champ rajout� au perim�tre modif du 20/03/98
 ,FAMCHG.ACCBRKTYP_CT        -- Champ rajout� au perim�tre modif du 20/03/98
 ,CONTR.UWORG_CF     -- Champ rajout� au perim�tre modif du 26/05/98
 ,SECTION.SECQUA_CF      -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA2_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA3_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA4_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,SECTION.SECQUA5_CF     -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.ADMGRP_CF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.ORGCED_NF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CONTR.REITYP_CF        -- Champ rajout� au perim�tre modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,FAMLIA.PRTCUR_CF       -- Champ rajout� au perim�tre modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,NULL               -- Champ non utilis� modif du 15/09/98
 ,CONTR.CTRACCSTS_CT     -- Champ rajout� au perim�tre modif du 15/09/98
 ,datepart(yy,CONTR.CTRACC_D) -- Champ rajout� au perim�tre modif du 15/09/98
 ,FAMLIA.PMLRAT_R        -- Champ rajout� au perim�tre modif du 15/09/98
 ,CLI1.HORDNBR_NT        --MODIF 007
 ,CLREPCR1.SORDNBR_NT    --MODIF 007
 ,CLI2.HORDNBR_NT        --MODIF 007
 ,CLREPCR2.SORDNBR_NT    --MODIF 007
 ,CLI3.HORDNBR_NT        --MODIF 007
 ,CLREPCR3.SORDNBR_NT    --MODIF 007
 ,FACADMTYP_B             --MODIF 008
 ,CONVERT(char(8),CRTVRSINC_D,112) --MODIF 009
 ,RECBRK_B       --MODIF 010
 ,RECBRK_R        --MODIF 010
 ,CONTR.CNATYP_CT   --MODIF 011
 ,SECTION.CLMCUTOFF_B  --MODIF 012
 ,SECTION.PRMCUTOFF_B  --MODIF 012
 ,SECTION.CLMRUNOFF_B  --MODIF 012
 ,SECTION.PRMRUNOFF_B   --MODIF 012
 ,SECTION.ASSFINANCE_CT  --MODIF 013   Champ rajout� au perim�tre modif du 09/12/2008  JR SPOT16593
 ,FLAPRM4_M=null
 ,FLAPRMCU4_CF=null
 ,FLAPRM5_M=null
 ,FLAPRMCU5_CF=null
 ,MINPRVPR4_M=null
 ,PRVPRMCU4_CF=null
 ,MINPRVPR5_M=null
 ,PRVPRMCU5_CF=null
 ,ESTLOSCORTYP_CT=null
 ,ESTV2C_COL_01=null
 ,ESTV2C_COL_02=null
 ,ESTV2C_COL_03=null
 ,ESTV2C_COL_04=null
 ,ESTV2C_COL_05=null
 ,ESTV2C_COL_06=null
 ,ESTV2C_COL_07=null
 ,ESTV2C_COL_08=null
 ,ESTV2C_COL_09=null
 ,ESTV2C_COL_10=null
 ,0                                                                                    --MODIF 18
 ,'FAC'                                                                                --MODIF 18
 ,CONVERT(char(8),CTRINC_D,112)                                                        --MODIF 18
 ,ESTV2C_COL_14=null
 ,ESTV2C_COL_15=null
 ,ESTV2C_COL_16=null
 --,ESTV2C_COL_17=null
 ,ESTV2C_COL_17=FAMCHG.COMBAS_CF
 ,ESTV2C_COL_18=null
 ,ESTV2C_COL_19=null
 ,ESTV2C_COL_20=null
 ,ESTV2C_COL_21=null
 ,ESTV2C_COL_22=null
 ,ESTV2C_COL_23=null
 ,ESTV2C_COL_24=null
 ,isnull(SECIFRS.CTRPRI_B,0) -- modif [021]
 ,isnull(SECIFRS.PRILR_R,0)  -- modif [021]
 ,ESTV2C_COL_27=null
 ,ESTV2C_COL_28=null
 ,ESTV2C_COL_29=null
 ,isnull(SECIFRS.CANEGP_M,0) -- modif [022]
,NULL -- modif 028 CONTR.MULTUWY_NF for TRT
 ,convert(char(8), CONTR.SCOEXP_D , 112) -- modif 028 EXP2_D
 ,NULL -- modif 028 FAMRSVP.MULTICAN_D for TRT
 FROM BFAC..TSECTION SECTION, BFAC..TCONTR CONTR, BFAC..TFAMLIA FAMLIA, BFAC..TFAMCHG FAMCHG
    ,BCLI..TCLINTSU CLREPCR1  --MODIF 007 MODIF 15
    ,BCLI..TCLINTSU CLREPCR2  --MODIF 007 MODIF 15
    ,BCLI..TCLINTSU CLREPCR3  --MODIF 007 MODIF 15
    ,BCLI..TCLIENT CLI1
    ,BCLI..TCLIENT CLI2
    ,BCLI..TCLIENT CLI3
    ,BREF..TBATCHSSD T   -- Modif 16
	,BFAC..TSECIFRS SECIFRS   --[021]		
  WHERE SECSTS_CT IN (16,18,19) 
    and CTRSTS_CT IN (16,18,19) 
    and CTRLCK_B != 0 -- modif 20 du 05/02/2018 ;   FAC Invalides	
    and SECTION.CTR_NF=CONTR.CTR_NF
    and SECTION.END_NT=CONTR.END_NT
    and SECTION.UWY_NF=CONTR.UWY_NF
    and SECTION.UW_NT=CONTR.UW_NT

    and SECTION.CTR_NF*=FAMLIA.CTR_NF
    and SECTION.END_NT*=FAMLIA.END_NT
    and SECTION.SEC_NF*=FAMLIA.SEC_NF
    and SECTION.UWY_NF*=FAMLIA.UWY_NF
    and SECTION.UW_NT*=FAMLIA.UW_NT

    and SECTION.CTR_NF*=FAMCHG.CTR_NF
    and SECTION.END_NT*=FAMCHG.END_NT
    and SECTION.SEC_NF*=FAMCHG.SEC_NF
    and SECTION.UWY_NF*=FAMCHG.UWY_NF
    and SECTION.UW_NT*=FAMCHG.UW_NT

    and SECTION.CTR_NF*=SECIFRS.CTR_NF    -- MODIF [021]
    and SECTION.END_NT*=SECIFRS.END_NT    -- MODIF [021]
    and SECTION.SEC_NF*=SECIFRS.SEC_NF    -- MODIF [021]
    and SECTION.UWY_NF*=SECIFRS.UWY_NF    -- MODIF [021]
    and SECTION.UW_NT*=SECIFRS.UW_NT      -- MODIF [021]
  
     and CONTR.CED_NF*=CLI1.CLI_NF

     and CONTR.CED_NF*=CLREPCR1.CLI_NF
     and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF  -- MODIF 15
     
     and CONTR.ORGCED_NF*=CLI2.CLI_NF

     and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
     and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF  -- MODIF 15
     
     and CONTR.PRD_NF*=CLI3.CLI_NF

     and CONTR.PRD_NF*=CLREPCR3.CLI_NF
     and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF  -- MODIF 15

     and SECTION.SSD_CF  = T.SSD_CF           -- Modif 16
     and CONTR.SSD_CF  = T.SSD_CF             -- Modif 16
     and T.BATCHUSER_CF = suser_name()        -- Modif 16

    -- [038]
    and ( 
      ( ( @norme_cf = 'EBS' ) 
        and CONTR.CTRINC_D <= @v_clo_date 
        and SECIFRS.RECOD_D < @v_pos_booking_minus_days     --[026]
      ) 
      or ( @norme_cf != 'EBS' ) 
    )

if @@error!=0 return @@error

return 0
go
if object_id('PsPeriFac_01') is not null
  print '<<< CREATED procedure PsPeriFac_01 >>>'
else
  print '<<< FAILED CREATING procedure PsPeriFac_01 >>>'
go
grant execute on PsPeriFac_01 TO GDBBATCH, GOMEGA
go
