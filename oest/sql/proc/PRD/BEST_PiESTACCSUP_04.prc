USE BEST
go
IF OBJECT_ID('PiESTACCSUP_04') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_04
  PRINT '<<< DROPPED PROC PiESTACCSUP_04 >>>'
END
go
create procedure PiESTACCSUP_04
(
  @PARM_DATE_DEB datetime   --@p_ENCONSO_D datetime datetime
, @PARM_DATE_FIN datetime   --@p_ENCONSO_D datetime
, @p_NORM   varchar(4) 
)
with execute as caller as
/***************************************************
Programme: PiESTACCSUP_04
Fichier script associé : ESIACC02.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: J. Ribot
Date de creation: 23/06/2005
Description du programme: recherche de la période comptable en cours
                          - sélection des écritures de services post omega pour generation retro
Parametres: date de lancement de la chaîne
Conditions d'execution:
Commentaires:

--BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- INV IFRS17 : SPEENNAT_CF = 9   "
--BORNE DATE_FIN ===> PARM_BOOKINGNEXT_D  ....:${PARM_BOOKINGNEXT_D}       -- INV IFRS17 : SPEENNAT_CF = 9    " 

--BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- POS IFRS17 : SPEENNAT_CF = 10  "
--BORNE DATE_FIN ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POS IFRS17 : SPEENNAT_CF = 10   " 
 
--BORNE DATE_DEB===>  PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POC IFRS17 : SPEENNAT_CF = 11  " 
--BORNE DATE_FIN ===> PARM_PSTOMGCONEND17_D..:${PARM_PSTOMGCONEND17_D}    -- POC IFRS17 : SPEENNAT_CF = 11   "
                                                                                                                      
                                                                                                                      
--BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- POS I4I    : SPEENNAT_CF = 2   " 
--BORNE DATE_FIN ===> PARM_PSTOMGEN_D     ....:${PARM_PSTOMGEN_D}          -- POS I4I    : SPEENNAT_CF = 2   "

--BORNE DATE_DEB ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POC I4I    : SPEENNAT_CF = 3   "
--BORNE DATE_FIN ===> PARM_PSTOMGCONEND_D ....:${PARM_PSTOMGCONEND_D}      -- POC I4I    : SPEENNAT_CF = 3    "
                                                                                                                      
--BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- INV EBS    : SPEENNAT_CF = 4   " 
--BORNE DATE_FIN ===> PARM_BOOKINGNEXT_D .....:${PARM_BOOKINGNEXT_D}       -- INV EBS    : SPEENNAT_CF = 4   "

 
--BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- POS EBS    : SPEENNAT_CF = 5   "
--BORNE DATE_FIN ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POS EBS    : SPEENNAT_CF = 5    "
 
--BORNE DATE_DEB ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POC EBS    : SPEENNAT_CF = 6   " 
--BORNE DATE_FIN ===> PARM_EBSPSTOMGCONEND_D..:${PARM_EBSPSTOMGCONEND_D}   -- POC EBS    : SPEENNAT_CF = 6    " 

------------------------------------------------------------------------------------------------------------- "                                                                                                                       
                                                                                                                                                                                                                                            

                                                                                                                                                                                                                                              

_________________
MODIFICATIONS
001 23/05/2012 JF VDV    [23390] - SOLVENCY aménagements
002 08/08/2013 R. CASSIS :spot:25427 - Ajout jointure table tbatchssd pour Omega2
003 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
004 03/12/2015 Florent   :spot:29162 utilisation des ${EPO_FCES} et ${EPO_FPLC} et plus les table BTRAV
005 19/03/2021 MZM       :spira:92592 Extraction des AE I17 P&C :   V5 ; Ajout Param VNORM, "SPEENTTYP_CF is null OR SPEENTTYP_CF not in (8,9)"  pour Dissocier EBS et I17 Life
006 28/04/2021 MZM       :spira:90073 Extraction des AE I17 :   V5 ; TRNSCODIFICATIN DES Suffices des TRNCOD selon la Norme :G --> (‘I’, ‘J’) ;  P --> ('K', 'L') ;  L --> ('M', 'N') 
007 08/07/2021 MZM       :spira:92592 DELTA INT / IN2 Rajout des SPeenat IFRS 4
008 17/08/2021 MZM       :spira:95950 Ajout spleennat 5 et mise à jour du parametrage des dates
009 15/09/2021 MZM       :spira:95950 Ajout extraction champ DBLTRNCOD_CF dans la generation du fichier
010 11/10/2022 M.NAJI    :spira:107109  Ajout 107109  with recompile dans exec  BEST..PdACCSUP_03
*****************************************************/
declare
 @erreur     int
,@tran_imbr  bit

select @erreur = 0, @tran_imbr = 1

truncate table BTRAV..EST_ESPJ0090_TACCSUP

-- Sélection des écritures de service


insert into BTRAV..EST_ESPJ0090_TACCSUP
select  TRN_NT, 
        ACCTYP_NF, 
        a.SSD_CF, 
        ESB_CF, 
        ENTPERY_NF, 
        ENTPERMTH_NF, 
        BALSHEY_NF, 
        BALSHRMTH_NF,
        BALSHRDAY_NF, 
        VALPERY_NF, 
        VALPERMTH_NF, 
        TRNCOD_CF,
        DBLTRNCOD_CF,   
        RETAUTGEN_B, 
        CTR_NF,
        END_NT, 
        SEC_NF, 
        UWY_NF, 
        UW_NT, 
        OCCYEA_NF, 
        ACY_NF, 
        SCOSTRMTH_NF, 
        SCOENDMTH_NF    , 
        CLM_NF,
        CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
        RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
        RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT,   COMMAC_LL, CRE_D,
        CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, 
        SPEENTTYP_CF, 
        SPEENTNAT_CT, 
        EVT_NF, 
        REVT_NF      -- MOD001  [003]
from    BEST..TACCSUP a, BREF..TBATCHSSD b
where   ( ACCTYP_NF = 1 or ACCTYP_NF = 99 )
and   RETAUTGEN_B = 1
and  ( (SPEENTNAT_CT in (9,10,11)  AND ( substring(@p_NORM,1,3) = 'I17' AND ( (substring(@p_NORM,4,4) = 'G' AND substring(TRNCOD_CF,8,8) IN ('I', 'J') ) OR (substring(@p_NORM,4,4) = 'P' AND substring(TRNCOD_CF,8,8) IN ('K', 'L') ) OR (substring(@p_NORM,4,4) = 'L' AND substring(TRNCOD_CF,8,8) IN ('M', 'N')) )  ) AND (SPEENTTYP_CF is null OR SPEENTTYP_CF not in (8,9) ) )  
       OR (SPEENTNAT_CT in (2,3,4,5,6)   AND ( substring(@p_NORM,1,3) != 'I17') )  )  --[005]  --[006] --[008]
and  ( CRE_D >= @PARM_DATE_DEB and CRE_D <= @PARM_DATE_FIN )
and   a.SSD_CF=b.SSD_CF
AND   b.BATCHUSER_CF = suser_name()
select @erreur = @@error
if @erreur != 0  goto fin

--   Début de la transaction
if @@trancount = 0
begin
  select @tran_imbr = 0
  BEGIN TRAN
end

-- Mise à jour de la table des écritures de services BEST..TACCSUP
Execute @erreur = BEST..PdACCSUP_03   with recompile
select @erreur = @@error
if @erreur != 0  goto fin

--   Fin de la transaction
if @tran_imbr = 0
  COMMIT TRAN

-- Descente de la table en fichiers
select TRN_NT, 
       ACCTYP_NF, 
       SSD_CF, 
       ESB_CF, 
       ENTPERY_NF, 
       ENTPERMTH_NF, 
       BALSHEY_NF, 
       BALSHRMTH_NF,
       BALSHRDAY_NF, 
       VALPERY_NF, 
       VALPERMTH_NF, 
       TRNCOD_CF,
       DBLTRNCOD_CF,         
       RETAUTGEN_B, 
       CTR_NF,
       END_NT, 
       SEC_NF, 
       UWY_NF, 
       UW_NT, 
       OCCYEA_NF, 
       ACY_NF, 
       SCOSTRMTH_NF, 
       SCOENDMTH_NF    , 
       CLM_NF,
       CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
       RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
       RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT,   COMMAC_LL,
       convert( char(8), CRE_D, 112 ), CREUSR_CF, convert( char(8), LSTUPD_D, 112 ), LSTUPDUSR_CF ,
       SPEENTTYP_CF, 
       SPEENTNAT_CT, 
       EVT_NF, 
       REVT_NF      -- [003]
 from BTRAV..EST_ESPJ0090_TACCSUP
return 0

fin:
if @tran_imbr = 0
  ROLLBACK TRAN
return 1
go
IF OBJECT_ID('PiESTACCSUP_04') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTACCSUP_04 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTACCSUP_04 >>>'
go
GRANT EXECUTE ON PiESTACCSUP_04 TO GOMEGA
go
GRANT EXECUTE ON PiESTACCSUP_04 TO GDBBATCH
go
