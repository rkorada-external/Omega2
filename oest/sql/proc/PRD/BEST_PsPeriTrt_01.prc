use BEST
go
if object_id('PsPeriTrt_01') is not null
begin
  drop procedure PsPeriTrt_01
  if object_id('PsPeriTrt_01') is not null
    print '<<< FAILED DROPPING procedure PsPeriTrt_01 >>>'
  else
    print '<<< DROPPED procedure PsPeriTrt_01 >>>'
end
go
create table #TFAMRSVP
  (
  CTR_NF       UCTR_NF    NOT null,
  UWY_NF       UUWY_NF    NOT null,
  UW_NT        UUW_NT     DEFAULT  1,
  END_NT       UEND_NT    DEFAULT  0,
  SEC_NF       USEC_NF    NOT null,
  ERNPRMADM_B  tinyint        null,
  POLDURMTH_NF UPERIOD    DEFAULT 12,
  INSPOL_R     USHORAT_R  DEFAULT 1,
  URRCAL_R     USHORAT_R   NULL    )  --MODIF 006
go
create table #TCLI
  (
  CLI_NF        UCLI_NF   NOT null,
  CLIRESSSD_CF  USSD_CF   null,
  HORDNBR_NT    int       null
  )
go
create procedure PsPeriTrt_01
(
  @p_segtyp_ct      char(1), --type de segmentation ( 'A' ou 'E' )
  @p_clo_date       char(8),
  @p_x_days         int,
  @norme_cf         char(4),
  @p_quarter_end    varchar(10) --quarter end for dry run,
)
as
/***************************************************
Domaine :   Estimations
Base principale : BEST
Version:    1
Auteur:     ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme:       Descente du p�rim�tre acceptation trait�s au niveau CASEX sans filtre sur la date d'effet
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: M.Ha-Thuc
Date: 12/03/1998
Version:
Description: rajout de 2 champs suppl�mentaires au p�rim�tre
  - USRCRTCOD_CT ( code du crit�re utilisateur acceptation )
  - USRCRTVAL_LM ( valeur du crit�re utilisateur acceptation )
_________________
MODIFICATION 2
Auteur: M.Ha-Thuc
Date: 20/03/1998
Version:
Description: rajout de 2 champs suppl�mentaires au p�rim�tre
  - PRDBRKTYP_CT ( type de courtage apporteur )
  - ACCBRKTYP_CT ( type de courtage �metteur de comptes )
_________________
MODIFICATION 3
Auteur: M.Ha-Thuc
Date: 26/05/1998
Version:
Description: rajout de 2 champs suppl�mentaires au p�rim�tre
  - UWORG_CF ( origine du portefeuille )
_________________
MODIFICATION 4
Auteur: M.Ha-Thuc
Date: 15/09/1998
Version:
Description:
  - suppression de la jointure avec BTRAV..TESTSSD; on descend maintenant
quotidiennement un p�rim�tre pour toutes les filiales. Le filtre sur les
filiales de l'inventaire sera fait dans la cha�ne ESID0560.
  - rajout de champs suppl�mentaires pour mise � jour des tables de
l'infocentre ( TULTIMATES, TCTRSTAT )
  - plus de restriction sur l'�tat de la section et l'�tat du contrat lors
de la descente quotidienne du p�rimetre. Le filtre sera fait dans la cha�ne
ESID0001.
_________________
MODIFICATION 5
Auteur: M.Ha-Thuc
Date: 06/10/1998
Version:
Description:
  - cette proc�dure n'est plus appel�e pour les p�rim�tres de segmentation. En
effet, la restriction sur la s�lection des affaires des p�rim�tres n'est plus la
m�me ( en segmentation, on ne prend que les contrats non termin�s SECACCSTS_CT != 9 ).
_________________
MODIFICATION 6
Auteur: M.Ha-Thuc
Date: 08/10/1998
Version:
Description:
  - suppression de la jointure avec la table BCLI..TCLREPCR ( qui �tait fausse !! ),
qui permettait de r�cup�rer le champs ORDNBR_NT. Cette donn�e n'est pas utilis�e par la vie.
_________________
MODIFICATION 7
Auteur: M.Bourdaillet
Date: 05/03/1999
Version:
Description: .
Rajout de six champs pour la segmentation client. Triple Jointure externe
sur BCLI..TCLREPCR. (CLE CLI_NF/SSD_CF)
on fait correspondre cette cle avec TCONTR (ced_nf ou orgced_nf ou prd_nf , ssd_cf)
_________________
MODIFICATION 8
Auteur: MONTAGNAC(ASCOTT)
Date: 25/08/1999
Version:
Description: .
Ajout de FACADMTYP_B � la fin du select
mis � 0 pour les trait�s
_________________
MODIFICATION 9
Auteur: FCharles
Date: 06/05/2000
Version:
Description: .
Ajout de la date CRTVRSINC_D dans le select.
_________________
MODIFICATION 10
Auteur: O.Arik(AURA)
Date: 30/03/2001
Version:
Description: .
Ajout de RECBRK_B (Indic d'existance de courtage sur REC)
et de RECBRK_R (taux de court. sur reconstitution)
dans le select.
_________________
MODIFICATION 11
Auteur: J. Ribot
Date: 04/06/2003
Version:
Description: .
Ajout de CNATYP_CT (Indic MODE CALCUL CNA)
dans le select.
__________________
MODIFICATION 12
Auteur: J. Ribot
Date: 31/03/2005
Version:
Description: .
Ajout de CLMCUTOFF_B PRMCUTOFF_B CLMRUNOFF_B PRMRUNOFF_B
dans le select.  pour alimenter colonnes table TLIFSTAREP
_________________
MODIFICATION 13
Auteur: M. DJELLOULI
Date: 18/05/2005
Version:
Description:
      S�lection des Enregistrements de TFAMCHG pour les postes � Risques
      SPOT 11772 - 11775 - Postes � Risques - SOX

-- NB : Important! Concernant COMTYP_CT , la Valeur COMTYP_CT=4 ("Estimation Manuelle") n'existe plus.
--                       Elle est remplac�e par la Valeur ESTCOMTYP_CT=1.
--                       Donc, COMTYP_CT prend toutes les Valeurs sauf 4.
--                       Pour le traitement ESID2000 (ESTC1015), on simule COMTYP_CT=4 quand ESTCOMTYP_CT=1

                          IDEM pour CTBTYP_CT et ESTCTBTYP_CT
                          Valeur de ESTCTBTYP_CT & ESTCOMTYP_CT : Manuel=1, A V�rifier=2, null
_________________
MODIFICATION 14
Auteur: M. DJELLOULI
Date: 25/10/2005
Version:
Description:
                Inclusion ESTCOMTYP_CT, ESTCBTTYP_CT, ESTREITYP_CT, ESTPRMTYP_CT � Test null
                null Equivalence � Estimation Manuelle (Valeur = 1)
_________________
MODIFICATION 15
Auteur: M. DJELLOULI
Date: 30/01/2005
Version:
Description:
                Inclusion ESTCOMTYP_CT, ESTCBTTYP_CT, ESTREITYP_CT, ESTPRMTYP_CT � Test null
                null Equivalence � Estimation Manuelle (Valeur = 3) (et non pas =1 !)
_________________
MODIFICATION 16
Auteur: J. Ribot
Date: 09/12/2008
Version:
Description:
               Champ SECTION.ASSFINANCE_CT rajout� au perim�tre SPOT16593
_________________
MODIFICATION    [017]
Auteur:         D.GATIBELZA
Date:           23/04/2010
Version:        10.1
Description:    ESTVIE18710 Alimentation du MGTAR lors de la comptabilisation de l'arr�t� pour la r�allocation asie
_________________
MODIFICATION    [018]
Auteur:         D.GATIBELZA
Date:           13/07/2010
Version:        10.2
Description:    ESTDOM17226 V10 Bug Commission Estimates
                4/ si calcul estimation de comm (ESTCOMTYP) est vide, alors on consid�re qu'il est automatique et non pas manuel
                20100803 => retour arri�re
_______________________
MODIFICATION    [019]
Auteur:         Kbagwe
Date:           17/04/2010
Version:        10.3
Description:   Replacing obsolete table TCLREPCR with TCLINTSU
__________________
MODIFICATION     [020]
Auteur: P.Coppin
Date:   16/10/2013
Description:  :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
__________________
21 Florent 20/11/2014 :spot:27747 Multi Currency - ajout colonnes sur le p�rim�tre
                      :spot:27748 Loss Corridor  - ajout colonnes sur le p�rim�tre
[022] P. Menant     02/03/2015 :spot:28306 EST37
[023] D. Fillinger  03/06/2015 :spot:28742 EST41 ajout de l'USGAAP et des taux manquants
[024] R. Cassis     01/09/2015 :spot:29052 On extrait pas les traites en statut invalide pour ne plus faire d'estimations
[025] -=Dch=-       10/02/2016 :spot:30167 Modification de la colonne ESTV2C_COL_17 pour les nouveaux calculs de commissions 
[026] R. Cassis     31/05/2015 :spot:30167 Re-annulation de la modif spot 29052
[027] S.Behague     16/08/2016 :spot:31066 Spira 52504 - Prise en compte poste PMD
[028] MZM           05/02/2018 :spira:42213 Arret des estimations des traites invalides (CTRLCK_B = 0) et des FAC invalides (CTRLCK_B = 1)
[029] MZM				    13/02/2018 :spira:57585 Ajout d'une nouvelle valeur "Suivi Closing" dans la codification TRAITE / ESTCOMTYP_CT
[030] HHH			      21/08/2018 :spira:68968 ajout du taux d'annuit� des r�serves.(ANNFUNINT_R ) dans le fichier pericase, ESTV2C_COL_10 = ANNFUNINT_R
[031] S.Behague     20/09/2019 :spira:60627 - PPrise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro
[032] JYP           08/10/2018 : IFRS17 req 10.6 : ajout table TSECIFRS Loss Ratios
[033] L.DOAN        15/03/2019 : spira 69939 et spira 66615 -  Ajout deux nouveaux champs (payment frequency, first due date)  dans le PERICASE pour les trait�s
[034] TY            17/06/2019 :IFRS17 req 10.11 : ajout champ CANEGP_M de TSECIFRS
[035] 10/09/2019 S.Behague :REQ_9.2: REQ.P.9.2 - Change in UPR calculation rules
[036] MZM           04/08/2020 :spira:87324 SCOR EGPI data for dummy Contracts : AT INI Replace SCOGLOEGP_M with SCOORGEGP_M 
[037] MZM           25/09/2020 :spira:89714 NI - Variable Premiums - Regression
[038] DaD           08/01/2022    spira : 94569 Condition on contract recognition date and inception dates in pericase extractions
[039] DaD           25/04/2022    spira : 94569 add parameter Quarter End
[040] DaD           23/01/2023    spira : 107224 not include contract recognized on cut off date
[041] FCI           20/07/2023 :spira 109507 I17 - Modify rule of CSM and LC pattern computation for multi year contracts
[042] MZM           11/03/2025 :spira : 112796 Cut-off management : Contract recognized day of cut-off should be taken into account
[043] MZM           28/07/2025 :US 6250  : 112796 Cut-off management : Contract recognized day of cut-off should be taken into account
*****************************************************/
declare @erreur int
select @erreur = 0

DECLARE
  @v_year_clo_date int,
  @v_month_clo_date int,
  @v_pos_booking_d datetime,
  @v_pos_booking_minus_days datetime,
  @v_clo_date datetime

-- [038]
IF(@norme_cf = 'EBS')
BEGIN
  SELECT @v_clo_date = CONVERT(datetime, @p_clo_date, 112)

  -- [039]
  IF(@p_quarter_end = 'NONE')
  BEGIN
    SELECT @v_year_clo_date = CONVERT(int, substring(@p_clo_date, 1, 4))
    SELECT @v_month_clo_date = CONVERT(int, substring(@p_clo_date, 5, 2))
    SELECT @v_pos_booking_d = EBSPSTOMGEND_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF = @v_month_clo_date 
    SELECT @v_pos_booking_minus_days = dateadd(day,1,dateadd(day, @p_x_days * -1, @v_pos_booking_d) ) -- 043
  END
  ELSE 
  BEGIN
    SELECT @v_pos_booking_minus_days = dateadd(day, 1, convert(datetime, @p_quarter_end, 103) ) -- 042 convert(datetime, @p_quarter_end, 103)
  END
END

-----------------------------
-- P�rim�tre pour les trait�s
-----------------------------
select SECTION.SSD_CF,
      @p_segtyp_ct,
      SECTION.CTR_NF,
      SECTION.END_NT,
      SECTION.SEC_NF,
      SECTION.UWY_NF,
      SECTION.UW_NT,
      ACCESB_CF,
      ADMMODPRM_CT,
      ANLCTY_CF,
      convert(char(8), CAN_DT, 112),
      CED_NF,
      CLICTY_CF,
      CLINAT_CF,
      CLMACT_M,
      COMTYP_CT=(case when ESTCOMTYP_CT=3 then 4                             -- MOD015 ESTCOMTYP_CT=1 then 4
            when ESTCOMTYP_CT=4 then 2                             -- MOD029 ESTCOMTYP_CT=4 then 4
                      when ESTCOMTYP_CT=null then 5                --[018] 5 au lieu de 4
                      else COMTYP_CT
                end),                                                       -- MOD013 - MDJ 20/05/2005 + MOD014 MDJ 20/10/2005
      CTBGENFEE_R,
      CTBTYP_CT=(case when ESTCBTTYP_CT=3 then 4                             -- MOD015 ESTCBTTYP_CT=1 then 4
                      when ESTCBTTYP_CT=null then 4
                      else CTBTYP_CT
                end),                                                       -- MOD005 - MDJ 20/05/2005 + MOD014 MDJ 20/10/2005
      convert(char(8), CTRINC_D, 112),
      CLISSD_CF,       -- Permet l'affectation de CTRRET_B
      CUTSHA_R,
      0,
      FAMLIA.EGPCUR_CF,
      CONTR.ESTCRB_CT,
      ESTCTR_NF,
      ESTEND_B,
      null,            -- ESTSEC_NF par defaut
      convert(char(8), SCOEXP_D, 112), -- EXP_D par defaut
      FIXCOM_R,
      SECTION.FRSUWY_NF,
      GANPAYORD_NT,
      GAR_CF,
      GENPRMPAY_NF,
      GENPRMSEN_NF,
      isnull(INSPOL_R,1),
      LAYCAP_M,
      LIFTRTTYP_CF,
      LOB_CF,
      LOSCOREXI_B,
      LOSCORHIG_R,
      LOSCORLOW_R,
      LOSCORRAT_R,
      LOSCTB_R,
      LOSCTBEXI_B,
      MAXCOM_R,
      MAXRATCLP_R,
      MINCOM_R,
      MINRATCLP_R,
      NAT_CF,
      null,        -- modifs du 08/10/1998, le champs ORDNBR_NT est forc� � null
      PCPCUR_CF,
      PCPRSKTRY_CF,
      isnull(POLDURMTH_NF,12),
      PRD_NF,
      PRFCOM_R,
      PRFCOMEXI_B,
      PRMEFFLOA_M,
      PRMEFFLOA_R,
      PRMFIXEFF_R,
      PRMFLCRAT_B,
      PRMMAXEFF_R,
      PRMMINEFF_R,
      PRMNETCOM_B,
      PRMPRTSCL_B,
      REIEXI_B,
      REIFRE_B, -- = (case when (FAMREI.REIPRMPTP_R=null OR FAMREI.REIPRMPTP_R != 0) then 0 else 1 end), -- REIFRE_B, [037]
      REINBR_N,
      REIUNL_B,
      RESTRFDUR_N,
      RESTRFTYP_CF,
      SBJCPTDEF_B,
      DEFSBJPRM_M,     --SBJPRM_M par defaut
      SCLCOMEXI_B,
      SCLCTBEXI_B,
      SCOGLOEGP_M = (case when (SCOGLOEGP_M=null and CONTR.UWORG_CF = 248) then SCOORGEGP_M else SCOGLOEGP_M end),     --SCOEGP_M par defaut  -- [036] SCOGLOEGP_M 
      convert(char(8), SCOINC_D, 112),
      SECACCSTS_CT,
      convert(char(8), SECINC_D, 112),
      SECSTS_CT,
      SEG_NF,
      SOB_CF,
      SUBNAT_CF,
      SUPLOATYP_CT,
      TOP_CF,
      'N',           -- CTRNAT_CT par defaut
      UWGRP_CF,
      ACCFRQ_CT,
      WRKCAT_CT,
      convert(char(8), ORGINC_D, 112),
      LIARIDSHA_B,
      FLAPRM_B,
      RIDSHA_R,
      CTBCALLVL_CF,
      0,               -- CTBCOM_B par defaut
      PRMPRT_M,
      PRMPRTCUR_CF,
      ACCADMTYP_CT,
      SBJPRMCUR_CF,
      CTRSTS_CT,
      OVRCOM_R,
      OVRCOMTYP_CT,
      TAXCNDEXI_B,
      PRDBRK_R,
      ACCBRK_R,
      LIACUR_CF,
      isnull(ERNPRMADM_B, 1),
      convert(char(8), SECCAN_D, 112), -- Permet l'affectation de EXP_D
      SCOORGEGP_M,                     -- Permet l'affectation de SCOEGP_M
      ESTSBJPRM_M,                     -- Permet l'affectation de SBJPRM_M
      SBJPRMCPT_M,                     -- Permet l'affectation de SBJPRM_M

      null, -- Correspond aux champs retro non utilises en acceptation
      null, -- Correspond aux champs retro non utilises en acceptation
      null, -- Correspond aux champs retro non utilises en acceptation
      null, -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire

      SECTION.USRCRTCOD_CT,          -- Champ rajout� au perim�tre, modif du 12/03/98
      SECTION.USRCRTVAL_LM,            -- Champ rajout� au perim�tre, modif du 12/03/98

      FAMCHG.PRDBRKTYP_CT,             -- Champ rajout� au perim�tre, modif du 20/03/98
      FAMCHG.ACCBRKTYP_CT,             -- Champ rajout� au perim�tre, modif du 20/03/98

      CONTR.UWORG_CF,                -- Champ rajout� au perim�tre, modif du 26/05/98

      SECTION.SECQUA_CF,           -- Champ rajout� au perim�tre, modif du 15/09/98
      SECTION.SECQUA2_CF,            -- Champ rajout� au perim�tre, modif du 15/09/98
      SECTION.SECQUA3_CF,            -- Champ rajout� au perim�tre, modif du 15/09/98
      SECTION.SECQUA4_CF,            -- Champ rajout� au perim�tre, modif du 15/09/98
      SECTION.SECQUA5_CF,            -- Champ rajout� au perim�tre, modif du 15/09/98
      CONTR.ADMGRP_CF,               -- Champ rajout� au perim�tre, modif du 15/09/98
      CONTR.ORGCED_NF,               -- Champ rajout� au perim�tre, modif du 15/09/98
      CONTR.REITYP_CF,               -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.PRMMINACT_R,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.PRMFIXACT_R,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.PRMMAXACT_R,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.CLMPRMACT_R,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.FLAPRM1_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.FLAPRMCU1_CF,          -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.FLAPRM2_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.FLAPRMCU2_CF,          -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.FLAPRM3_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.FLAPRMCU3_CF,          -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.MINPRVPR1_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.PRVPRMCU1_CF,          -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.MINPRVPR2_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.PRVPRMCU2_CF,          -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.MINPRVPR3_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.PRVPRMCU3_CF,          -- Champ rajout� au perim�tre, modif du 15/09/98
      null,                            -- notion Fac uniquement, modif du 15/09/98
      FAMCOTP.PRVPRM_B,            -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.DEFSBJPRM_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.ESTSBJPRM_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMCOTP.SBJPRMCPT_M,           -- Champ rajout� au perim�tre, modif du 15/09/98
      CONTR.CTRACCSTS_CT,            -- Champ rajout� au perim�tre, modif du 15/09/98
      datepart( yy, CONTR.CTRACC_D ),  -- Champ rajout� au perim�tre, modif du 15/09/98
      FAMLIA.PMLRAT_R,                 -- Champ rajout� au perim�tre, modif du 15/09/98
      CLI1.HORDNBR_NT,                     --MODIF 007
      CLREPCR1.SORDNBR_NT,                 --MODIF 007
      CLI2.HORDNBR_NT,                     --MODIF 007
      CLREPCR2.SORDNBR_NT,                 --MODIF 007
      CLI3.HORDNBR_NT,                     --MODIF 007
      CLREPCR3.SORDNBR_NT,                 --MODIF 007
      CONTR.FACADMTYP_B,                   --MODIF 008
      convert(char(8), CRTVRSINC_D, 112),  --MODIF 009
      RECBRK_B,                          --MODIF 010
      RECBRK_R,                          --MODIF 010
      CONTR.CNATYP_CT,                     --MODIF 011
      SECTION.CLMCUTOFF_B,                 --MODIF 012
      SECTION.PRMCUTOFF_B,                 --MODIF 012
      SECTION.CLMRUNOFF_B,                 --MODIF 012
      SECTION.PRMRUNOFF_B,                 --MODIF 012
      SECTION.ASSFINANCE_CT                --MODIF 016   Champ rajout� au perim�tre, modif du 09/12/2008  JR SPOT16593
    ,FAMCOTP.FLAPRM4_M
    ,FAMCOTP.FLAPRMCU4_CF
    ,FAMCOTP.FLAPRM5_M
    ,FAMCOTP.FLAPRMCU5_CF
    ,FAMCOTP.MINPRVPR4_M
    ,FAMCOTP.PRVPRMCU4_CF
    ,FAMCOTP.MINPRVPR5_M
    ,FAMCOTP.PRVPRMCU5_CF
    ,FAMCHG.ESTLOSCORTYP_CT
    ,ESTV2C_COL_01=null
    ,SECTION.USGAAP_CT        --MODIF 023
    ,FAMRSVP.URRCAL_R         --MODIF 023
    ,FAMFUNW.CLMFUN_R         --MODIF 023
    ,FAMFUNW.CLMFUNCAS_R      --MODIF 023
    ,FAMFUNW.CLMFUNINT_R      --MODIF 023
    ,FAMFUNW.URRFUN_R         --MODIF 023
    ,FAMFUNW.URRFUNCAS_R      --MODIF 023
    ,FAMFUNW.URRFUNINT_R      --MODIF 023
    ,FAMFUNW.ANNFUNINT_R      --MODIF 030      
    ,(case when ACCSEND.PAYFRQ_CT is not null then isnull(convert(int,ACCSNDDEL_N),0) else isnull(convert(int,ACCSNDDEL_N),0) +isnull(convert(int,STLREQDEL_N),0)+isnull(convert(int,CFLDEL_N),0) end)                       --MODIF 022 + modif 033 : if the "Payment frequency" field is entered  then total delay = account delay, else  total delay = account delay + payment delay + cashflow delay.
    ,"TRT"  
    ,convert(char(8), CTRINC_D, 112) 
    ,SECTION.PARENTGAAPIO_CT
    ,SECTION.LOCALGAAPIO_CT
    ,ESTV2C_COL_16=null
    --,ESTV2C_COL_17=null
    ,ESTV2C_COL_17=FAMCHG.COMBAS_CF
    ,FAMCOTP.PAYFRQ_CT                                -- [027]
    ,convert ( char (8), FAMCOTP.FIRPAYDUE_D, 112)    -- [027]
    ,null
    ,null
    ,convert(char(8), FAMRSVP.POLED_D, 112)            -- modif [035] 
    ,ESTV2C_COL_23=null
    ,ESTV2C_COL_24=null
    ,isnull(SECIFRS.CTRPRI_B,0) -- modif [032]
    ,isnull(SECIFRS.PRILR_R,0)  -- modif [032]
    ,ESTV2C_COL_27=null	  
    ,ACCSEND.PAYFRQ_CT		  -- modif 	[033]
    ,substring(convert(char(8), CTRINC_D, 112), 1,4)+isnull(substring(convert ( char (8), ACCSEND.PAYDUE_D, 112),5,4), '0101')       -- modif 	[033]
    ,isnull(SECIFRS.CANEGP_M,0)         -- modif [034]
	,CONTR.MULTUWY_NF
    ,convert(char(8), CONTR.CTREXP_D, 112) -- Modif 041 EXP2_D
    ,convert(char(8), FAMRSVP.MULTICAN_D, 112) -- Modif 041
from BTRT..TSECTION SECTION,
   BTRT..TCONTR CONTR,
   BTRT..TFAMLIA FAMLIA,
   BTRT..TFAMCHG FAMCHG,
   BTRT..TFAMCOTP FAMCOTP,
   BTRT..TACCSEND ACCSEND,
   BCLI..TCLIENT CLIENT,
--   BCLI..TCLREPCR CLREPCR,  - modifs du 08/10/1998
     #TFAMRSVP FAMRSVP
  ,BCLI..TCLINTSU CLREPCR1    --MODIF 007 , MODIF 019
  ,BCLI..TCLINTSU CLREPCR2    --MODIF 007 , MODIF 019
  ,BCLI..TCLINTSU CLREPCR3    --MODIF 007 , MODIF 019
    ,#TCLI CLI1               --MODIF 007
    ,#TCLI CLI2               --MODIF 007
    ,#TCLI CLI3               --MODIF 007
    ,BREF..TBATCHSSD T        --MODIF 020
    ,BTRT..TFAMFUNW FAMFUNW   --MODIF 023
	,BTRT..TSECIFRS SECIFRS   --[032]
	--,BTRT..TFAMREI FAMREI --[037]

--[017]where ( SECSTS_CT IN(14, 16, 17, 19)    or
--[017]        ( SECSTS_CT = 23 and LOB_CF in ('30', '31') )   )
--[017]  and ( CTRSTS_CT IN(14, 16, 17, 19)    or
--[017]        ( CTRSTS_CT = 23 and LOB_CF in ('30', '31') )   )
--[017]  and
where   --[017]
      SECTION.CTR_NF=CONTR.CTR_NF
  and SECTION.END_NT=CONTR.END_NT
  and SECTION.UWY_NF=CONTR.UWY_NF
  and SECTION.UW_NT=CONTR.UW_NT
  and CTRLCK_B <> 1 -- [028] Arret des estimations pour les traites Invalides
  
  and SECTION.CTR_NF*=FAMLIA.CTR_NF
  and SECTION.END_NT*=FAMLIA.END_NT
  and SECTION.SEC_NF*=FAMLIA.SEC_NF
  and SECTION.UWY_NF*=FAMLIA.UWY_NF
  and SECTION.UW_NT*=FAMLIA.UW_NT
                                    --[037]
 -- and SECTION.CTR_NF*=FAMREI.CTR_NF
 -- and SECTION.END_NT*=FAMREI.END_NT
 -- and SECTION.SEC_NF*=FAMREI.SEC_NF
 -- and SECTION.UWY_NF*=FAMREI.UWY_NF
 -- and SECTION.UW_NT*=FAMREI.UW_NT  

  and SECTION.CTR_NF*=FAMCHG.CTR_NF
  and SECTION.END_NT*=FAMCHG.END_NT
  and SECTION.SEC_NF*=FAMCHG.SEC_NF
  and SECTION.UWY_NF*=FAMCHG.UWY_NF
  and SECTION.UW_NT*=FAMCHG.UW_NT

  and SECTION.CTR_NF*=FAMCOTP.CTR_NF
  and SECTION.END_NT*=FAMCOTP.END_NT
  and SECTION.SEC_NF*=FAMCOTP.SEC_NF
  and SECTION.UWY_NF*=FAMCOTP.UWY_NF
  and SECTION.UW_NT*=FAMCOTP.UW_NT

  and SECTION.CTR_NF*=ACCSEND.CTR_NF
  and CONTR.CED_NF*=CLIENT.CLI_NF
--and CONTR.CED_NF*=CLREPCR.CLI_NF  - modifs du 08/10/1998
--and CONTR.SSD_CF*=CLREPCR.SSD_CF  - modifs du 08/10/1998

  and SECTION.CTR_NF*=FAMRSVP.CTR_NF
  and SECTION.END_NT*=FAMRSVP.END_NT
  and SECTION.SEC_NF*=FAMRSVP.SEC_NF
  and SECTION.UWY_NF*=FAMRSVP.UWY_NF
  and SECTION.UW_NT*=FAMRSVP.UW_NT

  and SECTION.CTR_NF*=FAMFUNW.CTR_NF --MODIF 023
  and SECTION.END_NT*=FAMFUNW.END_NT --MODIF 023
  and SECTION.SEC_NF*=FAMFUNW.SEC_NF --MODIF 023
  and SECTION.UWY_NF*=FAMFUNW.UWY_NF --MODIF 023
  and SECTION.UW_NT*=FAMFUNW.UW_NT   --MODIF 023

  and SECTION.CTR_NF*=SECIFRS.CTR_NF    -- MODIF [032]
  and SECTION.END_NT*=SECIFRS.END_NT    -- MODIF [032]
  and SECTION.SEC_NF*=SECIFRS.SEC_NF    -- MODIF [032]
  and SECTION.UWY_NF*=SECIFRS.UWY_NF    -- MODIF [032]
  and SECTION.UW_NT*=SECIFRS.UW_NT      -- MODIF [032]
  
  and CONTR.CED_NF*=CLI1.CLI_NF
  and CONTR.CED_NF*=CLREPCR1.CLI_NF
  and CONTR.SSD_CF*=CLREPCR1.CLIINTSSD_CF     -- MODIF 019
  and CONTR.ORGCED_NF*=CLI2.CLI_NF
  and CONTR.ORGCED_NF*=CLREPCR2.CLI_NF
  and CONTR.SSD_CF*=CLREPCR2.CLIINTSSD_CF     -- MODIF 019
  and CONTR.PRD_NF*=CLI3.CLI_NF
  and CONTR.PRD_NF*=CLREPCR3.CLI_NF
  and CONTR.SSD_CF*=CLREPCR3.CLIINTSSD_CF     -- MODIF 019


  and CONTR.SSD_CF  = T.SSD_CF                      -- Modif 020
  and T.BATCHUSER_CF = suser_name()                      -- Modif 020

  -- [038]
  and ( 
    ( ( @norme_cf = 'EBS' ) 
      and CONTR.CTRINC_D <= @v_clo_date 
      and SECIFRS.RECOD_D < @v_pos_booking_minus_days   -- [040]
    ) 
    or ( @norme_cf != 'EBS' ) 
  )


select @erreur = @@error
if @erreur != 0
begin
    return @erreur
end

return 0
go
if object_id('PsPeriTrt_01') is not null
  print '<<< CREATED procedure PsPeriTrt_01 >>>'
else
  print '<<< FAILED CREATING procedure PsPeriTrt_01 >>>'
go
grant execute on PsPeriTrt_01 TO GOMEGA,GDBBATCH
go
 
