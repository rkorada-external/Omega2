USE BEST
go
IF OBJECT_ID('dbo.PiACCSUP_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiACCSUP_02
    IF OBJECT_ID('dbo.PiACCSUP_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiACCSUP_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiACCSUP_02 >>>'
END
go
create procedure PiACCSUP_02(
  @p_ssd_cf USSD_CF,
  @p_usr_cf UUSR_CF,
  @p_batch_mode UL16 = NULL )
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: O.GIRAUX/J.RIBOT
Date de creation: Reecriture complète en Janvier 2003
Description du programme:
---------------------------
Contrôles de cohérences lors du chargement massif par fichier d'écritures de service.
Si tout est OK, INSERTion des lignes ds BEST..TACCSUP.
Fonctionnement de la proc :
----------------------------
Pour repérer les anomalies, on remplit une table tempo à partir de btrav..TESTUTISUP
et de la requête correspondant aux règles que doivent suivre les mouvements.
Un écart du nombre de lignes indique que certains mouvements sont en anomalies et
il y a débranchement sur la fin de la proc pour remplir la table des anos.
Description générale:
------------------------
Plus grande décomposition des anos pour une meilleure compréhension des anos par les users.
ATTENTION, L'ORDRE DES CONTROLES EST IMPORTANT. Par ex ano 18 doit être controlée après les controles
des sections.
( libellés visibles ds TBANTECL : COL_LS = ANO_CT )
        - Libellé inventaire ( ano 19)
        - Periode de validité ( ano 20 )
        - Poste comptable ( ano 33 )                (code 33 utilisé également ds chargmt massif rétro)
        - Année Compte acceptation ( ano 21 )
        - Année compte rétro ( ano 22 )
        - Section acceptation inconnue ( ano 28 )  (code 28 utilisé également ds chargmt massif rétro)
        - Section rétro inconnue ( ano 27 )        (code 27 utilisé également ds chargmt massif rétro)
        - Poste comptable incorrect par rapport à la lob (ano 18 )
        - Placement incorrect ( ano 23 )
        - Devise accept incorrecte ( ano 24 )
        - Devise rétro incorrecte ( ano 25 )
+
    - mise a jour automatique des infos tiers
    - mise a jour du poste de contrepartie
    - mise a jour de l'année de survenance retro a partir exercice retro
         si partie retro renseignée et année de survenance retro non renseignée
    - mise a jour systématique du montant acceptation et de la devise à partir du montant
    retro et de la devise retro lors de la maj des types comptables.( ACCTYP)
    - ajout du num de ligne ds la table TCTRANO

+

    Comme on n'a au niveau de la fenêtre d'affichage des anomalies qu'une zone "Contrat",
    cette zone contiendra:
    - le contrat accept si on est sur une anomalie purement acceptation
    (ex: A/C accept incorrecte,section accept incorrecte ....)
    - le contrat rétro si on est sur une anomalie purement rétro
    - le contrat accept par défaut lorsqu'on est sur une anomalie générale ( de poste comptable, d'année bilan ...)
    ou le contrat rétro si l'acceptation n'est pas renseignée.
     -> fait au niveau de la maj finale de BEST..TCTRANO

Au niveau de l'appli, on a déjà un ens de contrôles vérifiant si lorsqu'une info acceptation est saisie,
le contrat l'est également (idem coté rétro) + d'autres vérifiant que les champs obligatoires sont bien présents.

O.GIRAUX
_________________
MODIFICATION 1 - MOD001
Auteur: M. DJELLOULI
Date: 31-03-2004
Description:
    Modification des Erreurs liées au Retour de Fonction
    Simplification de l'enregistrement des erreurs (Fin de Procédure)

_________________
MODIFICATION 2 - MOD002
Auteur: M. DJELLOULI
Date: 22-06-2004
Description:
    Modification BUG - Contrôle Chargement Ecriture Service

_________________
MODIFICATION 3 - MOD003
Auteur: M. DJELLOULI
Date: 30-03-2005
Description:

Contrôle de la période bilan:
Ø	Doit être de type " Libellé d'inventaire ", c'est à dire sur le dernier jour du mois
Ø	Doit être sur l'année de la période de saisie.Sinon Anomalie " Libellé inventaire incorrect " à ANO_CT=19 dans REFERENCES.

Contrôle de la période de fin de validité :
Ø	L'année doit correspondre à l'année de la période de saisie.
Ø	Periode_De_Validité >= Periode_Inventaire >= Periode_Saisie
      Sinon Anomalie " Période fin de validité incorrecte " à ANO_CT=20 dans REFERENCES.

Autres Développements à faire :
-	Mettre en place un nouveau contrôle vérifiant que :
      La date du 1er inventaire est supérieure à la date du dernier inventaire ayant tourné dans l'environnement
      (champs à prendre en compte : BALSHEY_NF, BALSHRMTH_NF et BALSHRDAY_NF de la table : BEST..TACCSUP).
      Pour ce contrôle, utiliser le code erreur : ANO_CT=19.

Ø	Cela revient à Vérifier : Periode-Bilan_Saisie >= Periode-Bilan_EnCours
      Similaire à Anomalie 19 précédente


    Autre Correction :
    Seule la Dernière Anomalie était relevé dans le Fichier de Retour des Anos.
    Affichage du Dernier Message Ano et des Codes Anomalies rencontrées En Retour de Proc.
    MsgGlobalAnomalie = Deniere Anomalie + NumMsgAnomalie

_________________
MODIFICATION 4 - MOD004
Auteur: M. DJELLOULI
Date: 11-04-2005
Description:  VERSION 5.1 - Omega Estimations
                    Correction Chargement sur Poste Comptables d'Ouvertures Qd Période de Validité <> Période de Bilan
                  -> Génération Anomalie ANO_CT = 46 : Poste Ouverture: Périodes non =
                    Pour cette Modif, la proc temporaire (jusqui'ici) est stockée dans O:\PROJETS\ORET\1.SUIVI\SPOT\10775

_________________
MODIFICATION 5 - MOD005
Auteur: M. DJELLOULI
Date: 26-04-2005
Description:  VERSION 5.1 - Omega Estimations
                  Ajour du champ 'Type d'ecriture Service' dans le Chargement des Ecritures Services.
                  SPOT 5084 - Ajout de la Colonne SPEENTTYP_CF
_________________
MODIFICATION 6
Auteur: M.DJELLOULI
Date:	27/04/2005
Version:
Description: SPOT 14445 - EST_ESID0801_TESTUTISUP remplace TESTUTISUP
_________________
MODIFICATION 7
Auteur:     M.DJELLOULI - MOD007
Date:        24/06/2005
Description: SPOT 5085 - Ajout Zone SPEENTNAT_CT

_________________
MODIFICATION 8
Auteur:     M.DJELLOULI - MOD008
Date:        20/10/2005
Description: SPOT 10833 - Correction des Mois Validité Période pour Ano_ct = 46
_________________
MODIFICATION 9
Auteur:     M.DJELLOULI - MOD009
Date:        05/01/2006
Description: Correction Bug Chargement Ecriture Service sur Contrôle Période de Saisie (Ano 20)
_________________
MODIFICATION 10
Auteur:     M.DJELLOULI - MOD010
Date:        06/01/2006
Description: Annulation Correction MOD008
_________________
MODIFICATION 11
Auteur:     M.DJELLOULI - MOD011
Date:        20/02/2006
Description: SPOT 12520 - Quand ils existent d'anciens enregistrments dans la table EST_ESID0801_TESTUTISUP
             les nouvelles anomalies générées , reprennent les anciennes données de EST_ESID0801_TESTUTISUP
             Lors de l'INSERTion dans TCTRANO_TMP, on vérifie que le User et SSD_CF sont bien ceux liés à EST_ESID0801_TESTUTISUP
_________________
MODIFICATION 12
Auteur:     M.DJELLOULI - MOD012
Date:        11/04/2006
Description: SPOT 12408 - Correction CREUSR_CF par @p_usr_cf au lieu de "DSK"
_________________
MODIFICATION 13
Auteur:     Dominique Ourmiah - MOD013
Date:        21/03/2007
Description: SPOT 13135 - Rendre impossible la création d'écritures service
                          sur des contrats "terminés comptable"
_________________
MODIFICATION 14
Auteur:     Dominique Ourmiah - MOD014
Date:        16/12/2008
Description: SPOT 16593 - Ajout nouveaux codes postes comptable pour comptabilisation IFRS dans les chaines Inventaire
_________________
MODIFICATION 15
Auteur:     Dominique Ourmiah - MOD015
Date:        30/01/2009
Description: SPOT 15577 - Rendre impossible la création d'écritures service
                          sur des sections à l'état autre que "Accepté", "Définitif", "Renouvelé" ou "Résilié"
_________________
MODIFICATION 16
Auteur:     Dominique Ourmiah - MOD016
Date:        18/03/2009
Description: SPOT 17099 - Idem MOD015 Ajout état "Expiré"

_________________
MODIFICATION 17
Auteur:     Jacky Ribot - MOD017
Date:        29/06/2009
Description: SPOT 16657  Interdire la création d'ES le jour du booking (saisie + chargement)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 17/09/2009  |[18053] pour les fac xxLyyyyy, remplacement du test sur les lettres par un interval qui couvre l'ensemble du domaine des FACs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
_________________
MODIFICATION    [019]
Auteur:         D.GATIBELZA
Date:           15/09/2009 - retouché au 02/10/2009
Version:        9.1
Description:    ESTVIE17265 Il faut ajouter un contrôle sur l'ACY quand saisie manuelle d'écriture service  on ne doit pas avoir ACYUWY
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 21/10/2009  |[14839] Ajout d'un contrôle supplémentaire entre poste principal et poste de contre-partie ( ANO ===> 33)
                |             |vérification du contrôle sur le statut 'Terminé Comptable'
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 22/01/2010  |[18612] modification de la gestions des anomalies
                |             |        Pour ANO 18, ne pas sortir en anomalie, mais continuer les controles.
                |             |        Interdire les postes de bilan service et bilan service rejet (x5yyyyyz et x8yyyyyz)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
22 Florent 25/01/2012 :spot:22456 EVOLUTION DES REGROUPEMENTS PARENT GAAP
23 Florent 05/03/2012 :spot:23494 correction EVOLUTION DES REGROUPEMENTS PARENT GAAP
24 JF VDV  31/05/2012 : [23390] - Amenagements SOLVENCY
[025] 23/07/2012 R. Cassis  :spot:23802 - Modifs 1er car trncod a 4% et 2% dans le like
[026] 01/08/2012 L. Rakotozafy :spot:23860 ajout paramètre pour différencier traitement TP et batch
_________________
MODIFICATION 27
Auteur:     Kbagwe - MOD027
Date:        12/04/2013
Description: Replacing obsolete table TSUBTRSESB
_________________
Modification - Removed dbo and added 'with execute as caller as'
_________________
Author: Ashish Kumar Singh
Date: 15/10/2013
Version: 1
Description: Phase1b: Removed CTR_NF like
[028] 04/02/2014  R. Cassis :spot:25427 Ajout grant GDBBATCH et appel BEST..PsSITE_01
_________________
Modification 29 - Adapted SP for SII06a changes (SCOR Spira defect #29158)
Author: Pierre Etienne MARX, Capgemini
Date: 25/07/2014
Version: [029]
Description: Adapted SP for SII06a changes (SCOR Spira defect #29158)

_________________
Modification 30 - EST 43a Evo card added Event_nt for assume and retro
Author: Amit Deshpande
Date: 17/02/2015
Description: EST 43a Evo card added Event_nt for assume and retro
_________________
Modification 31 - Single claim number not linked to the Sub or Group Event
Author: Avijit Roy
Date: 20/05/2015
Description: EST 43a - Defect #35474
_________________
Modification 32 - Spira 038110 - Load AE file : Life Entries on Non Life treaty
Author: Amit D
Date: 18/06/2015
Description: Fixing - During the closing, we have loaded Life AE  ( with prefix 3) on Non life treaty ( LOB 31)

33 28/04/2015 Florent :spot:26391 pour prendre les comptes de dépôts
_________________
Modification 34 - Spira 034416 - Assistance entries load : AE load is failed
Author: Pierre-Etienne Marx
Date: 25/06/2015
Description: remove insertion of anomalies into TCTRANO from the ErrorAno label: error should not be raised just because an anomaly was met
Also includes merge of the contents of :spot:28388 by Florent (on enlève le test FAC ou TRT sur les lettres du contrat)
_________________
Modification 35 - Spira 038110 - Load AE file : Life Entries on Non Life treaty
Author: Pierre-Etienne Marx
Date: 21/07/2015
Description: Added InsertAno label to redirect the insertion mid-SP. This avoids returning an error when the SP is behaving properly.

_________________
Modification 36 - EST 29 Evo Card - Added TERCTR_B =0 which checks retrocession contract / underwriting year is closed
Author: Amit D
Date: 14/08/2015
Description: EST 29 Evo Card - Added TERCTR_B =0 which checks retrocession contract / underwriting year is closed

_________________
Modification 37 - 43094 - AE on retro contract in to be checked or checked status
Author: Amit D
Date: 30/11/2015
Description: We should be AE upload when status of retro contract is checked or to be checked status

_________________
Modification 38 - 41200 - LOADING AE FILE : New Life AE transaction codes should not be available for P&C
Author: Sumit Gupta
Date: 21/12/2015
Description: Block new life AE T.code for P&C

_________________
Modification 39 - 32392 - Block the AEs booking on FACULTATIVE with Accepted status
Author: Gaurav Pujari
Date: 22/12/2015
Description: Remove acceptance section status for upload

_________________
Modification 40 - 40189 - Error message inconsistent in the List of Assitance entry laoding error
Author: Amit D
Date: 08/02/2016
Description: In order to check section existence first moving errors 27,28 to # TACCSUP1 and error numbers 21,22 to #TACCSUP 2

_________________
Modification 41 - 41200 - LOADING AE FILE : New Life AE transaction codes should not be available for P&C
Author: Sumit Gupta
Date: 04/03/2016
Description: Block new life AE T.code for P&C (RETRO)

_________________
Modification 42 - 46056 - ABLE TO BOOK AE WITH ACY GREATER THAN BALANCE SHEET
Author: Avanti Pannala
Date: 21/06/2016
Description: Block the possibility to book an AE (manual and Loading) with ACY greater than balance sheet year.
_________________
Modification 43 - 50721 - AE booking should be locked on a section in Closed status
Author: Avanti Pannala
Date: 1/07/2016
Description: Block the possibility to book an AE (manual and Loading) with section in Closed status.

_________________
Modification 44 - 46056 - ABLE TO BOOK AE WITH ACY GREATER THAN BALANCE SHEET
Author: Sumit Gupta
Date: 13/09/2016
Description: Added check for retro contract

_________________
Modification 45 - 54801 - Load AE :  No blocking control on TC ( assumed TC loading on retro treaty)
Author: Sumit Gupta
Date: 13/09/2016
Description: Added check for retro contract

_________________
Modification 46 - 59050- Load AE :  Control the existance of TC in DB
Author: Riyadh
Date: 26/04/2017
Description: Added check for TC exist in DB

Modification 47 - 57781 - Incoherence message estimation 3038 et erreur effective
Author: Dimitry BERTÉ
Date: 05/05/2017
Description: Added check contract : Treaty | Facultative | Retrocession

[048] 04/02/2014  R. Cassis :spira:56031 Adherence Estimate/ RETRO - RET 03B Stop locking account - ECRITURE DE SERVICE
                                         if LCKCLO_B = 0 -> there IS Estimate / Closing Impact else no impact -- ERROR 107
[049] 27/10/2017  R. Cassis :spira 61508 Modification et ajout controles pour Ecritures locales
[050] 10/11/2017 FDE: spira 61508: Local AE asynchronous batch
[051] 20/12/2017 R. Cassis :spira:66334 Correction sur ES Local
[052] 28/02/2018 D. Berté :spira:66674 Confusing error message while loading locale AE on treaty with unauthorized Sub Ledger
[053] 29/03/2018 E. de Nicolay :spira:68027 Local AE loading - Incoherence transaction code/lob

_________________
Modification [056] - 67689 - Upload AE : To not allow AEs on NTU Assumed/Retro treaties/sections
Author      : Belaid.L
Date        : 28/02/2019
Description : Added check for CTR is not NTU, only for life domain
[057] 25/03/2020 S.behague :spira82196 - IFRS17- REQ.LIF.01: AE interface for Life from SAS 
[058] 13/08/2020 S.behague :spira87212 - IFRS17- REQ.LIF.01: AE interface for Life from SAS - lot2
[059] 19/08/2020 L. Wernert :spira 88061: Interdire la saisie d'une AE retro sur un placement résilié avec une part à Zéro
[060] 14/10/2020 KBagwe: 90678-IFRS17 - AE upload - Allow Tc on P&C subleder that ends by A to Z
[061] 02/11/2020 Riyadh: 87517AE for claim 05-330459 (Ciara ou Covid?)
[062] 27/11/2020 S.behague :spira 92041 Chargement AE en retro sur 02P000111 en échec , regression # 88061 ?
[063] 01/12/2020 S.behague :spira 92030 I17 SAS AE UPload: Remove control on the Period scor
[064] 20/01/2021 S.behague :spira 93317 Chargement AE en retro sur 02P000111 en échec , regression # 88061 ? - Copy
[065] 24/03/2021 S.behague :spira 94383 CAT COVER : problème sur contrat 02N000652
[066] 12/04/2021 R.Cassis  :spira 95109 Ajout controle validité de la date bilan
[067] 17/05/2021 HR : spira 94391 subsidiary event (no G prefix)
[068] 15/03/2021 S.behague :spira 102715 IFRS17 FWH Bookings - Assistance Entries (Everest)
[069] 04/04/2022 S.behague :spira 103555 IFRS17 SAS AE - Traité avec changement de devise
[070] 11/04/2022 S.behague :spira 102716 IFRS17 SAS AE - Placement résilié avec une part à 0
[071] 04/07/2022 JYP       :spira 105395 bugfix old spira 67689 [056] not allow AEs on NTU Assumed/Retro treaties/sections
[072] 18/08/2022 M.NAJI    :spira 105224 mise à jour des contrôle lors des chargement des AE: période,moi, année post omega et période inventaire 
[073] 27/04/2023 Riyadh    :spira 109065 Onerous Q+1 - Possibility to book AEs
******************************************************************************************************************************************************/

declare @erreur       int,
    @error_type   int,
        @tran_imbr    bit,
        @MsgAnomalie    varchar(120),
        @NumMsgAnomalie    varchar(120),                                               -- MOD003 Nb Anomalies : Numéros des Erreurs Rencontrées
        @MsgGlobalAnomalie    varchar(240),                                            -- MOD003 Anomalies GLobales Rencontrées
    @cre_d      datetime, /* date du jour */
    @entpery_nf   smallint, /* année de saisie */
    @entpermth_nf   tinyint,  /* mois de saisie */
    @spcend_d   datetime, /* variable en sortie de PsCALEND_02 */
    @account_d    datetime, /* variable en sortie de PsCALEND_02 */
    @closing_b    bit,    /* variable en sortie de PsCALEND_02 */
    @nbligne_testutisup int,    /* nbre lignes de la table utilisateurs en entrée */
    @nbligne_tempaccsup int,    /* nbre lignes en sortie de traitement */
    @nbligne_tctrano  int,    /* MOD001 - nbre lignes en Anomalies */
    @max_trn_nt   numeric( 10, 0 ), /* numéro d'écriture maxi de BEST..TACCSUP */
    @nbligne_PosteOuverture int,    -- nbre lignes des Postes d'Ouvertures - MOD004
    @Verif_d      datetime,           -- Date de Verification - Si Conso/Social : Antérieur < PeriodePrecedente, Sinon Date du Jour
    @balshtmth_nf  tinyint,  /* Dernier mois bilan du trimestre comptabilisé */
    @blcshtmth_nf  tinyint  /* Dernier mois bilan comptabilisé */
  --	@astartTime 		datetime

select @erreur = 0
select @tran_imbr = 1
select @cre_d = getdate()
select @error_type = -1
select @MsgAnomalie = ""
select @NumMsgAnomalie = " - Autres Anomalies Trouvées N° "


--select @astartTime = getDate()

/* ------------------------------------------------------------
   Creating temporary tables
 -------------------------------------------------------------- */

create table #TACCSUP1 (
  TRN_NT      numeric(10,0) NULL,
  ACCTYP_NF   tinyint NULL,
  SSD_CF      USSD_CF NULL,
  ESB_CF      UESB_CF NULL,
  ENTPERY_NF    UUWY_NF NULL,
  ENTPERMTH_NF  tinyint NULL,
  BALSHEY_NF    UUWY_NF NULL,
  BALSHRMTH_NF  tinyint NULL,
  BALSHRDAY_NF  tinyint NULL,
    VALPERY_NF      UUWY_NF NULL,
  VALPERMTH_NF  tinyint NULL,
  TRNCOD_CF   UDETTRS_CF  NULL,
  DBLTRNCOD_CF  UDETTRS_CF  NULL,
  RETAUTGEN_B   tinyint NULL,
  CTR_NF      UCTR_NF NULL,
  END_NT      UEND_NT NULL,
  SEC_NF      USEC_NF NULL,
  UWY_NF      UUWY_NF NULL,
  UW_NT     UUW_NT    NULL,
  OCCYEA_NF   UUWY_NF NULL,
  ACY_NF      UUWY_NF NULL,
  SCOSTRMTH_NF  tinyint NULL,
  SCOENDMTH_NF  tinyint NULL,
  CLM_NF      UCLM_NF NULL,
  CUR_CF      UCUR_CF NULL,
  AMT_M     UAMT_M    NULL,
  CED_NF      UCLI_NF NULL,
  BRK_NF      UCLI_NF NULL,
  GEMPRMPAY_NF  UCLI_NF NULL,
  GANPAYORD_NT  UPAYORD_NT  NULL,
  RETCTR_NF   URETCTR_NF  NULL,
  RETEND_NT   UEND_NT NULL,
  RETSEC_NF   URETSEC_NF  NULL,
  RTY_NF      UUWY_NF NULL,
  RETUW_NT    UUW_NT  NULL,
  PLC_NT      UPLC_NT NULL,
  RETOCCYEA_NF  UUWY_NF NULL,
  RETACY_NF   UUWY_NF NULL,
  RETSCOSTRMTH_NF tinyint NULL,
  RETSCOENDMTH_NF tinyint NULL,
  RCL_NF      UCLM_NF NULL,
  RETCUR_CF   UCUR_CF NULL,
  RETAMT_M    UAMT_M  NULL,
  RTO_NF      UCLI_NF NULL,
  INT_NF      UCLI_NF NULL,
  RETPAY_NF   UCLI_NF NULL,
  RETKEY_CF   char(1) NULL,
  ACCTRN_NT   numeric(10,0) NULL,
  COMMAC_LL   UL64      NULL,
  CRE_D     UUPD_D      NULL,
  CREUSR_CF   UUPDUSR_CF    NULL,
  LSTUPD_D    UUPD_D      NULL,
  LSTUPDUSR_CF  UUPDUSR_CF    NULL,
    SPEENTTYP_CF    tinyint       NULL,               -- MOD005 26/04/2005
    SPEENTNAT_CT    tinyint       NULL,                -- MOD007 27/06/2005
  EVT_NF      varchar(10)   NULL,
  REVT_NF         varchar(10)   NULL
 )

create table #TACCSUP2 (
  TRN_NT      numeric(10,0) NULL,
  ACCTYP_NF   tinyint NULL,
  SSD_CF      USSD_CF NULL,
  ESB_CF      UESB_CF NULL,
  ENTPERY_NF    UUWY_NF NULL,
  ENTPERMTH_NF  tinyint NULL,
  BALSHEY_NF    UUWY_NF NULL,
  BALSHRMTH_NF  tinyint NULL,
  BALSHRDAY_NF  tinyint NULL,
    VALPERY_NF      UUWY_NF NULL,
  VALPERMTH_NF  tinyint NULL,
  TRNCOD_CF   UDETTRS_CF  NULL,
  DBLTRNCOD_CF  UDETTRS_CF  NULL,
  RETAUTGEN_B   tinyint NULL,
  CTR_NF      UCTR_NF NULL,
  END_NT      UEND_NT NULL,
  SEC_NF      USEC_NF NULL,
  UWY_NF      UUWY_NF NULL,
  UW_NT     UUW_NT    NULL,
  OCCYEA_NF   UUWY_NF NULL,
  ACY_NF      UUWY_NF NULL,
  SCOSTRMTH_NF  tinyint NULL,
  SCOENDMTH_NF  tinyint NULL,
  CLM_NF      UCLM_NF NULL,
  CUR_CF      UCUR_CF NULL,
  AMT_M     UAMT_M    NULL,
  CED_NF      UCLI_NF NULL,
  BRK_NF      UCLI_NF NULL,
  GEMPRMPAY_NF  UCLI_NF NULL,
  GANPAYORD_NT  UPAYORD_NT  NULL,
  RETCTR_NF   URETCTR_NF  NULL,
  RETEND_NT   UEND_NT NULL,
  RETSEC_NF   URETSEC_NF  NULL,
  RTY_NF      UUWY_NF NULL,
  RETUW_NT    UUW_NT    NULL,
  PLC_NT      UPLC_NT NULL,
  RETOCCYEA_NF  UUWY_NF NULL,
  RETACY_NF   UUWY_NF NULL,
  RETSCOSTRMTH_NF tinyint NULL,
  RETSCOENDMTH_NF tinyint NULL,
  RCL_NF      UCLM_NF NULL,
  RETCUR_CF   UCUR_CF NULL,
  RETAMT_M    UAMT_M    NULL,
  RTO_NF      UCLI_NF NULL,
  INT_NF      UCLI_NF NULL,
  RETPAY_NF   UCLI_NF NULL,
  RETKEY_CF   char(1) NULL,
  ACCTRN_NT   numeric(10,0) NULL,
  COMMAC_LL   UL64    NULL,
  CRE_D     UUPD_D    NULL,
  CREUSR_CF   UUPDUSR_CF  NULL,
  LSTUPD_D    UUPD_D    NULL,
  LSTUPDUSR_CF  UUPDUSR_CF  NULL,
    SPEENTTYP_CF    tinyint       NULL,                -- MOD005 26/04/2005
    SPEENTNAT_CT    tinyint       NULL,                -- MOD007 27/06/2005
  EVT_NF      varchar(10)   NULL,
  REVT_NF         varchar(10)   NULL
   )

create table #TACCSUP3 (
  TRN_NT      numeric(10,0) identity,
  ACCTYP_NF   tinyint NULL,
  SSD_CF      USSD_CF NULL,
  ESB_CF      UESB_CF NULL,
  ENTPERY_NF    UUWY_NF NULL,
  ENTPERMTH_NF  tinyint NULL,
  BALSHEY_NF    UUWY_NF NULL,
  BALSHRMTH_NF  tinyint NULL,
  BALSHRDAY_NF  tinyint NULL,
    VALPERY_NF    UUWY_NF NULL,
  VALPERMTH_NF  tinyint NULL,
  TRNCOD_CF   UDETTRS_CF  NULL,
  DBLTRNCOD_CF  UDETTRS_CF  NULL,
  RETAUTGEN_B   tinyint NULL,
  CTR_NF      UCTR_NF NULL,
  END_NT      UEND_NT NULL,
  SEC_NF      USEC_NF NULL,
  UWY_NF      UUWY_NF NULL,
  UW_NT     UUW_NT    NULL,
  OCCYEA_NF   UUWY_NF NULL,
  ACY_NF      UUWY_NF NULL,
  SCOSTRMTH_NF  tinyint NULL,
  SCOENDMTH_NF  tinyint NULL,
  CLM_NF      UCLM_NF NULL,
  CUR_CF      UCUR_CF NULL,
  AMT_M     UAMT_M    NULL,
  CED_NF      UCLI_NF NULL,
  BRK_NF      UCLI_NF NULL,
  GEMPRMPAY_NF  UCLI_NF NULL,
  GANPAYORD_NT  UPAYORD_NT  NULL,
  RETCTR_NF   URETCTR_NF  NULL,
  RETEND_NT   UEND_NT NULL,
  RETSEC_NF   URETSEC_NF  NULL,
  RTY_NF      UUWY_NF NULL,
  RETUW_NT    UUW_NT    NULL,
  PLC_NT      UPLC_NT NULL,
  RETOCCYEA_NF  UUWY_NF NULL,
  RETACY_NF   UUWY_NF NULL,
  RETSCOSTRMTH_NF tinyint NULL,
  RETSCOENDMTH_NF tinyint NULL,
  RCL_NF      UCLM_NF NULL,
  RETCUR_CF   UCUR_CF NULL,
  RETAMT_M    UAMT_M    NULL,
  RTO_NF      UCLI_NF NULL,
  INT_NF      UCLI_NF NULL,
  RETPAY_NF   UCLI_NF NULL,
  RETKEY_CF   char(1) NULL,
  ACCTRN_NT   numeric(10,0) NULL,
  COMMAC_LL   UL64    NULL,
  CRE_D     UUPD_D    NULL,
  CREUSR_CF   UUPDUSR_CF  NULL,
  LSTUPD_D    UUPD_D    NULL,
  LSTUPDUSR_CF  UUPDUSR_CF  NULL,
    SPEENTTYP_CF    tinyint       NULL,                -- MOD005 26/04/2005
    SPEENTNAT_CT    tinyint       NULL,                -- MOD007 27/06/2005
  EVT_NF      varchar(10)   NULL,
  REVT_NF         varchar(10)   NULL
  )


-- Debut MOD001 - Creating temporary tables of anomalies
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

-- deleting by security anomalies lines
--Normally this is also done in the application when sending the request

Execute BEST..PdCTRANO_05 @p_ssd_cf,@p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Accès BEST..PdCTRANO_05'
  goto ErreurNorm
    end


-- we remove from btrav..TESTUTISUP all subsidiary lines different from the subsidiary
-- use as parameter, it is normally rarely fall in this case, it means
-- that the user has mistakenly entered several subsidiaries in the file

-- Delete the existing lines from BTRAV..EST_ESID0801_TESTUTISUP with the appropriate subsidiary from input file and last updated usr_cf


DELETE btrav..EST_ESID0801_TESTUTISUP
where
    SSD_CF      != @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf

Declare @p_date_t DateTime
Select @p_date_t = GetDate()
Select @Verif_d  = GetDate()


-- *********************************************************************************************
-- Calculating and storing of number of lines in the table users btrav..EST_ESID0801_TESTUTISUP
-- **********************************************************************************************

-- Count the number of lines from btrav..EST_ESID0801_TESTUTISUP uploaded from input file

select @nbligne_testutisup = count(*) FROM btrav..EST_ESID0801_TESTUTISUP
where
  SSD_CF       = @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf


-- *************************************************************************************
--
--       FIRST STEP : AUTOMATIC UPDATING IN SOME FIELDS
--
-- *************************************************************************************

-- access to the  BREF..TCALEND table to determinate the entry period
-- -------------------------------------------------------------------

Execute @erreur = BREF..PsCALEND_02
      @cre_d,
      'C',
      @entpery_nf output,
          @entpermth_nf output,
      @spcend_d output,
      @account_d output,
      @closing_b output

if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Accès BREF..PsCALEND_02'
  goto ErreurNorm
    end

-- SPOT 16657 JR 29 06 2009    MOD017
-- ---------------------------------------------------------
-- test if we are between the end of exceptional period and the accounting date
-- ---------------------------------------------------------
--[025]
--if (@p_date_t > @spcend_d and @p_date_t <= @account_d)

-- [050]: Checking Exceptional period for non local AE only
If EXISTS (SELECT 1 FROM BTRAV..EST_ESID0801_TESTUTISUP
                    WHERE
                       SPEENTNAT_CT NOT IN (7, 8) AND
                       SSD_CF       = @p_ssd_cf AND
                       LSTUPDUSR_CF = @p_usr_cf)
    begin
        if (convert(Char(10),@p_date_t,112) > convert(Char(10),@spcend_d,112) and convert(Char(10),@p_date_t,112) <= convert(Char(10),@account_d,112) )
            begin
              select @MsgAnomalie = 'Erreur No AEs are allowed before booking'
              goto ErreurNorm
            end
    end

-- FIN SPOT 16657 JR 29 06 2009      MOD017

-- Debut MOD007 M.DJELLOULI - 19/07/2005 - SPOT 5085 - Si SPEENTNAT_CT est Conso ou Social, Récupération Période Conso/social
-- ---------------------------------------------------------
-- test procedure's call to retrieve the periods PtREQJOB_05
-- ---------------------------------------------------------

Declare 
--        @P_Booking_D       Char(8),       -- Date de Booking T-1
--        @P_PsTomGen_D      Char(8),       -- Date de Fin de Saisie Post Omega Social (Periode T)
--        @P_EnConso_D       Char(8),       -- Date de Fin de Saisie Ecritures Conso (Periode T)
        @DateInventaireConso   Char(8),   -- Date Libelle Inventaire Pour Saisie Ecriture Conso & Social (Periode T-1)
        @PeriodeConsoAA     numeric(4,0), -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
        @PeriodeConsoMM     numeric(2,0), -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
        @DateInventaireService Char(8) --,   -- Date Libelle Inventaire Pour Saisie Ecriture Service (Periode T)
--        @PeriodeServiceAA   numeric(4,0), -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
--        @PeriodeServiceMM   numeric(2,0), -- Periode MM Pour Saisie Ecriture Services (Periode T)
--        @P_SuffixeTable       char(1),
--        @P_Erreur               int,
--		@P_EBSPsTomGen_D    Char(8),     -- Date de Fin de Saisie Post Omega Social (Periode T)	--[23390]
--		@P_Booking17_D      Char(8),
--		@P_PsTomGen17_D     Char(8),
--		@P_EnConso17_D      Char(8)

declare
--	@p_date_t               datetime,
--	@p_site_cf              varchar(10),
	@Last_Booking_I4I_D     			 Char(8)  ,              -- Last Booking IFRS4 Q-1	
	@Last_Booking_EBS_D     			 Char(8)  ,             -- Last Booking EBS Q-1 (New)
	@Last_Booking_17_D      			Char(8)  ,			        	-- Last Booking IFRS 17 Q-1
	@End_POS_I4I_D          			 Char(8)  ,               -- End date of POS IFRS4 Entry Q  
	@End_POS_EBS_D          			 Char(8)  ,               -- End date of POS EBS Entry Q (New)
	@End_POS_I17_D		    			 Char(8)  ,			          -- End date of POS IFRS17 Entry Q 
	@End_POC_I4I_D          			 Char(8)  ,               -- End date of POC IFRS4 Entry Q-1	 
	@End_POC_EBS_D          			 Char(8)  ,               -- End date of POC EBS Entry Q-1 (New)
	@End_POC_I17_D          			 Char(8)  ,               -- End date of POC IFRS17 Entry Q-1 (New)
	@Post_Omega_Entry_I4I_D 			 Char(8)  ,               -- Quarter post omega IFRS4 (New)
	@Post_Omega_Entry_EBS_D 			 Char(8)  ,               -- Quarter post omega EBS (New)
	@Post_Omega_Entry_I17_D 			 Char(8)  ,               -- Quarter post omega IFRS17 (New)
	@Post_Omega_Yea_I4I_D   			 numeric(4,0)    ,   -- Year post omega IFRS4 (New)
	@Post_Omega_Yea_EBS_D   			 numeric(4,0)    ,   -- Year post omega EBS (New)
	@Post_Omega_Yea_I17_D   			 numeric(4,0)    ,   -- Year post omega IFRS17 (New)
	@Post_Omega_Mth_I4I_D   			 numeric(4,0)     ,  -- Month post omega IFRS4 (New)
	@Post_Omega_Mth_EBS_D   			 numeric(4,0)   ,    -- Month post omega EBS (New)
	@Post_Omega_Mth_I17_D   			 numeric(4,0)    ,   -- Month post omega IFRS17 (New)
	@INV_Entry_I4I_D        			 Char(8)  ,               -- Quarter INV IFRS4 (New)
	@INV_Entry_EBS_D        			 Char(8)  ,               -- Quarter INV EBS (New)
	@INV_Entry_I17_D        			 Char(8)  ,               -- Quarter INV IFRS17 (New)
	@INV_Mth_I4I_D          			 numeric(4,0)    ,  -- Month INV IFRS4 (New)
	@INV_Mth_EBS_D          			 numeric(4,0)   ,   -- Month INV EBS (New)
	@INV_Mth_I17_D          			 numeric(4,0)   ,   -- Month INV IFRS17 (New)
	@INV_Yea_I4I_D          			 numeric(4,0)   ,   -- Year INV IFRS4 (New)
	@INV_Yea_EBS_D          			 numeric(4,0)   ,   -- Year INV EBS (New)
	@INV_Yea_I17_D          			 numeric(4,0)    ,  -- Year INV IFRS17 (New)
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
	@P_SuffixeTable         			char(1)  ,               -- Nom de Suffixe de TABLE : '0' si Erreur
	@P_Erreur               			int             -- CodeRetour Erreur pour Message Appli



declare @site_cf        varchar(10)
declare @param1         varchar(20)
select  @param1 = convert(varchar,@p_ssd_cf)

execute @erreur = BEST..PsSITE_01 @param1,'2',@site_cf output




declare @NORME varchar(20)

Select 
 @NORME =
CASE
    WHEN SPEENTNAT_CT in (9,10,11)  THEN "IFRS17"
    WHEN SPEENTNAT_CT in (4,5,6)  THEN "EBS"
    WHEN SPEENTNAT_CT in (1,2,3)  THEN "IFRS4"
END
FROM btrav..EST_ESID0801_TESTUTISUP
where	SSD_CF   = @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf



If EXISTS (Select 1 FROM btrav..EST_ESID0801_TESTUTISUP
                    where
                       SSD_CF       = @p_ssd_cf
                   and LSTUPDUSR_CF = @p_usr_cf)

   Begin
       --Execute @erreur = BEST..PtREQJOB_05
       --                       @p_date_t,
       --                       @site_cf,
       --                       @P_Booking_D           Output,
       --                       @P_PsTomGen_D          Output,
       --                       @P_EnConso_D           Output,
       --                       @DateInventaireConso   Output,
       --                       @PeriodeConsoAA        Output,
       --                       @PeriodeConsoMM        Output,
       --                       @DateInventaireService Output,
       --                       @PeriodeServiceAA      Output,
       --                       @PeriodeServiceMM      Output,
       --                       @P_SuffixeTable        Output,
       --                       @P_Erreur              Output,
       --                       @P_EBSPsTomGen_D       Output, -- modif 24
		--					   @P_Booking17_D	      Output,       
		--					   @P_PsTomGen17_D        Output,
		--					   @P_EnConso17_D         Output
		--					   
		--					   
							   
	Execute @erreur =  BEST..PtREQJOB_I17_05 
		@p_date_t               			,
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
								   

      -- Select @P_Booking_D             as 'Booking_D',
      --        @P_PsTomGen_D            as 'PsTomGen_D',
      --        @P_EnConso_D             as 'EnConso_D',
      --        @DateInventaireConso     as 'DateInventaireConso',
      --        @PeriodeConsoAA          as 'PeriodeConsoAA',
      --        @PeriodeConsoMM          as 'PeriodeConsoMM',
      --        @DateInventaireService   as 'DateInventaireService',
      --        @PeriodeServiceAA        as 'PeriodeServiceAA',
      --        @PeriodeServiceMM        as 'PeriodeServiceMM',
      --        @P_SuffixeTable          as 'P_SuffixeTable',
      --        @P_Erreur                as 'P_Erreur',
	  --	   @P_Booking17_D 			as 'Booking17_d',
	  --	   @P_PsTomGen17_D 			as 'Pstomgen17_d',
      --        @P_EnConso17_D 			as 'Enconso17_d'
			   
			   
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
		   @DateInventaireService= CASE
									WHEN @NORME = "IFRS17"  THEN @INV_Entry_I17_D
									WHEN @NORME = "EBS"   	THEN @INV_Entry_EBS_D
									WHEN @NORME = "IFRS4"   THEN @INV_Entry_I4I_D
								END
--               @P_Erreur                as 'P_Erreur',
			   
			   

        if @erreur != 0
            begin
                select @MsgAnomalie = 'Erreur Accès BEST..PtREQJOB_05'
              goto ErreurNorm
            end

        If (@P_SuffixeTable = '0') or (@P_SuffixeTable = Null)
                Begin
                    select @MsgAnomalie = "Erreur Paramètres CONSO/SOCIAL Incorrect" + Convert(Char(5), @P_Erreur)
                  goto ErreurNorm
                End
            Else
                Begin
                  If EXISTS (Select 1 FROM btrav..EST_ESID0801_TESTUTISUP
                                      where
                                          SSD_CF       = @p_ssd_cf
                                      and LSTUPDUSR_CF = @p_usr_cf
                                      and SPEENTNAT_CT not in(1,4))   --[23390]
                    Begin
                       Select @entpery_nf = @PeriodeConsoAA
                       Select @entpermth_nf = @PeriodeConsoMM
                       Select @Verif_d = DateAdd(Day, -1, @DateInventaireConso)
                    End
                  Else
                    Begin
                       Select @Verif_d = DateAdd(Day, -1, @DateInventaireService)
                    End
                End
    End





UPDATE  btrav..EST_ESID0801_TESTUTISUP
SET ENTPERY_NF   = @entpery_nf,
  ENTPERMTH_NF = @entpermth_nf,
  CRE_D        = @cre_d,
  LSTUPD_D     = @cre_d,
  CREUSR_CF    = @p_usr_cf                  -- MOD012-11/04/2006 CREUSR_CF = "DSK"
FROM  btrav..EST_ESID0801_TESTUTISUP
where   SSD_CF       = @p_ssd_cf
and     LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error

if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur MAJ btrav..EST_ESID0801_TESTUTISUP - Periode de Saisie"
  goto ErreurNorm
    end

-- access to the table BFAC..TCONTR to inquire the informations accepted
-- ---------------------------------------------------------------

UPDATE btrav..EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ACCESB_CF,
  CED_NF = B.CED_NF,
  BRK_NF = B.PRD_NF,
  GEMPRMPAY_NF = B.GENPRMPAY_NF,
  GANPAYORD_NT = B.GANPAYORD_NT
FROM  btrav..EST_ESID0801_TESTUTISUP A, BFAC..TCONTR B
where
  A.SSD_CF        = @p_ssd_cf
and A.LSTUPDUSR_CF  = @p_usr_cf
and A.CTR_NF        = B.CTR_NF
and A.END_NT        = B.END_NT
and A.UWY_NF        = B.UWY_NF
and A.UW_NT         = B.UW_NT

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0801_TESTUTISUP - Info Acceptation BFAC..TCONTR'
  goto ErreurNorm
    end

-- access to the table BTRT..TCONTR to inquire the informations accepted
-- --------------------------------------------------------------

UPDATE btrav..EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ACCESB_CF,
  CED_NF = B.CED_NF,
  BRK_NF = B.PRD_NF,
  GEMPRMPAY_NF = B.GENPRMPAY_NF,
  GANPAYORD_NT = B.GANPAYORD_NT
FROM  btrav..EST_ESID0801_TESTUTISUP A,
        btrt..TCONTR B
where
    A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf
and A.CTR_NF       = B.CTR_NF
and A.END_NT       = B.END_NT
and A.UWY_NF       = B.UWY_NF
and A.UW_NT        = B.UW_NT

select @erreur = @@error
if @erreur != 0
    begin
      select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0801_TESTUTISUP - Info Acceptation BTRT..TCONTR'
      goto ErreurNorm
    end


-- access to the table BRET..TRETCTR to inquire the fields subsidiary , ledgers
--for the case where we don't have any acceptance , then  such informations are not updated yet
-- --------------------------------------------------------------------------------

UPDATE btrav..EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ESB_CF
FROM  btrav..EST_ESID0801_TESTUTISUP A,
        bret..TRETCTR B
where
    A.SSD_CF        = @p_ssd_cf
and A.LSTUPDUSR_CF  = @p_usr_cf
and A.RETCTR_NF     = B.RETCTR_NF
and A.RTY_NF        = B.RTY_NF

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur MAJ btrav..EST_ESID0801_TESTUTISUP - Info Contrats BRET..TRETCTR"
  goto ErreurNorm
    end

-- updating by default of the exercise of occurrence acceptance
-- ---------------------------------------------------

UPDATE btrav..EST_ESID0801_TESTUTISUP
SET OCCYEA_NF = UWY_NF
where
    CTR_NF       != NULL
and OCCYEA_NF    = null
and SSD_CF       = @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = '"Erreur MAJ btrav..EST_ESID0801_TESTUTISUP - Maj par défaut de l''ex de survenance acceptation'
  goto ErreurNorm
    end

-- updating by default of the exercise of occurrence retrocession
-- -------------------------------------------------------

UPDATE btrav..EST_ESID0801_TESTUTISUP
SET RETOCCYEA_NF = RTY_NF
where
    RETCTR_NF    != NULL
and RETOCCYEA_NF = null
and SSD_CF       = @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0801_TESTUTISUP - Maj par défaut de l''ex de survenance rétro '
  goto ErreurNorm
    end

-- updating of the  third party informations retro *
-- placements no recorded and accountable ,valid (16) or canceled (19)
-- --------------------------------------------------------------------------

UPDATE btrav..EST_ESID0801_TESTUTISUP
SET a.RTO_NF    = b.RTO_NF,
    a.INT_NF    = b.INT_NF,
      RETPAY_NF = PAY_NF,
    RETKEY_CF = KEY_CF

FROM btrav..EST_ESID0801_TESTUTISUP a,
     bret..TPLACEMT b
   where
             a.RETCTR_NF != NULL
         and a.RETCTR_NF = b.RETCTR_NF
     and a.RTY_NF    = b.RTY_NF
     and a.PLC_NT    = b.PLC_NT
     and HIS_B       = 0
     and ACCPLC_B    = 1
       and (PLCSTS_CT  = 16 or PLCSTS_CT = 19)
         and A.SSD_CF    = @p_ssd_cf
         and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0801_TESTUTISUP - Maj infos tiers rétro '
  goto ErreurNorm
    end

-- updating counter balance
-- -------------------------

UPDATE btrav..EST_ESID0801_TESTUTISUP
SET  DBLTRNCOD_CF = CTRSCOD_CF
FROM btrav..EST_ESID0801_TESTUTISUP a,
     bref..TDETTRS b
where
    DETTRS_CF      = TRNCOD_CF
and A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur MAJ btrav..EST_ESID0801_TESTUTISUP - Maj poste de contrepartie'
  goto ErreurNorm
    end
-- **********************************************************************************
--                                                                                  *
--                     SECOND STEP: CHECKING OF CONSISTENCY                         *
--   			 The labels of anomalies below are in the table BREF..TBANTECL      *
--      	            it is  referenced by "ANO_CT"                               *
--                                                                                  *
-- **********************************************************************************

-- -----------------------------------------------------------------------------*
--                   CHECKING OF LABEL INVENTORY                                *
--                the year has to match to the entry year                       *
--                + it has to be on the last day of the month                   *
--                otherwise anomaly 19                                          *
-- -----------------------------------------------------------------------------*

-- ----------------------------------------------------------------------------------------------------------------*
-- datepart( dd, dateadd( dd, -1, dateadd( mm, +1, convert( char(6), BALSHEY_NF * 100+ BALSHRMTH_NF ) + '01' ) ) ) *
-- This function fetches the last day of the month                                                                 *
-- Add new columns EVT_NF annd REVT_NF into #TACCSUP1															   *
-- --------------------------------------------------------------------------------------------------------------- *

INSERT INTO #TACCSUP1
SELECT  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF,
  CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF,REVT_NF                                                       -- MOD005 26/04/2005 -- MO007
FROM  BTRAV..EST_ESID0801_TESTUTISUP
WHERE   SSD_CF = @P_SSD_CF
AND LSTUPDUSR_CF = @P_USR_CF
AND (
    ( 
    BALSHEY_NF = ENTPERY_NF
    AND BALSHRDAY_NF = datepart( dd, dateadd( dd, -1, dateadd( mm, +1, convert( char(6), BALSHEY_NF * 100+ BALSHRMTH_NF ) + '01' ) ) )
    AND BALSHRMTH_NF >= ENTPERMTH_NF            -- MOD003 Vérifier que le Mois de Bilan >= Periode de Bilan En Cours
    AND SPEENTNAT_CT NOT IN (7,8,9)
    )
    OR  SPEENTNAT_CT IN (7,8,9) )  /* [CDU] BY-PASS THIS CONTROL FOR LOCAL AE TEMPORARY UNTIL THE CONTROL IS IMPLEMENTED [049] */
                                                /* [050] BY-PASS from 049 REMOVED [050] */

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP1 - Anomalie(s) liee(s) au libelle d''inventaire'
  goto ErreurAno
    end

-- compare the number of lines between EST_ESIDO801_TESTUTISUP and #TACCSUP1
-- generation of an anomaly => anomaly 19 and exit of the procedure
-- --------------------------------------------------------------------------

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 19
    select @MsgAnomalie = 'Anomalie(s) liee(s) au libelle d''inventaire'
    select @NumMsgAnomalie = @NumMsgAnomalie + '19 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP 
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
  end

-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------

DELETE #TACCSUP1

-- ---------------------------------------
-- date format check [066]
-- ---------------------------------------

INSERT INTO #TACCSUP1
SELECT  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF,
  CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF,REVT_NF                                                       -- MOD005 26/04/2005 -- MO007
FROM  BTRAV..EST_ESID0801_TESTUTISUP
WHERE   SSD_CF = @P_SSD_CF
AND LSTUPDUSR_CF = @P_USR_CF
AND isdate(convert(char(4),BALSHEY_NF)+ "/" + convert(char(2),BALSHRMTH_NF) + "/" + convert(char(2),BALSHRDAY_NF)) = 1  -- [066] controle validité de date 1 = good

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 529"
  goto ErreurAno
    end

-- --------------------------------------------------------------------------
-- compare the number of lines between EST_ESIDO801_TESTUTISUP and #TACCSUP1
-- [066] generation of an anomaly => anomaly 529 and exit of the procedure
-- --------------------------------------------------------------------------

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 529
    select @MsgAnomalie = 'Bilan origine incorrect'
    select @NumMsgAnomalie = @NumMsgAnomalie + '529 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
  end

-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------

DELETE #TACCSUP1

-- ----------------------------------------------------------------------------
--                   CHECKING NEW LIFE TCODE FOR P&C CONTRACT
--                    				MOD-38
-- -----------------------------------------------------------------------------
--ASSUME
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
  from BTRAV..EST_ESID0801_TESTUTISUP A,BREF..TESB B,btrt..tcontr C
  WHERE
                  A.SSD_CF=B.SSD_CF
                                AND A.ESB_CF=B.ESB_CF
                AND A.UWY_NF=C.UWY_NF -- MOD 41
                                AND A.SSD_CF=@p_ssd_cf
                                AND A.LSTUPDUSR_CF = @p_usr_cf
                                AND B.LIFE_CF=2
                                AND C.CTR_NF=A.CTR_NF
                                --AND C.LSTUWY_B=1
                                AND A.TRNCOD_CF LIKE '%[A-Z]'
                                AND A.SPEENTNAT_CT NOT IN (9,10,11) --MOD[060]

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 21036"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 21036
        select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
        select @NumMsgAnomalie = @NumMsgAnomalie + '21036 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
            FROM btrav..EST_ESID0801_TESTUTISUP
            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
              and SSD_CF       = @p_ssd_cf
              and LSTUPDUSR_CF = @p_usr_cf
    end

-- Début modification 58 spira 87212 
-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------

DELETE #TACCSUP1

-- ----------------------------------------------------------------------------
-- 30132 - SAS AE type: Expected value 8 or 9 for SAS AE
--                    				MOD-58
-- -----------------------------------------------------------------------------
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
  from BTRAV..EST_ESID0801_TESTUTISUP A
  WHERE
	    A.SPEENTTYP_CF in (8,9)
	AND A.SPEENTNAT_CT not in (9,10,11)

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 30132"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 30132
        select @MsgAnomalie = "Anomalie(s) liee(s) aux natures d'AE CSMENGINE"
        select @NumMsgAnomalie = @NumMsgAnomalie + '30132'

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
            FROM btrav..EST_ESID0801_TESTUTISUP
            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
              and SSD_CF       = @p_ssd_cf
              and LSTUPDUSR_CF = @p_usr_cf
    end

-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------

DELETE #TACCSUP1

-- ----------------------------------------------------------------------------
-- 30133 - SAS AE Currency: must be equal to main currency of the section
--                    				MOD-58
-- -----------------------------------------------------------------------------
/*INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
  from BTRAV..EST_ESID0801_TESTUTISUP A, BTRT..TSECTION s
  WHERE
	    A.SPEENTTYP_CF in (8,9)
	and A.CTR_NF = s.CTR_NF
	and A.END_NT = s.END_NT
	and A.SEC_NF = s.SEC_NF
	and A.UWY_NF = s.UWY_NF
	and A.CUR_CF <> s.PCPCUR_CF
	
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 30133"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 30133
        select @MsgAnomalie = "Anomalie(s) liee(s) aux devises d'AE CSMENGINE"
        select @NumMsgAnomalie = @NumMsgAnomalie + '30133'

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
            FROM btrav..EST_ESID0801_TESTUTISUP
            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
              and SSD_CF       = @p_ssd_cf
              and LSTUPDUSR_CF = @p_usr_cf
    end
*/
-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------

DELETE #TACCSUP1

-- ----------------------------------------------------------------------------
-- 30134 - SAS AE Currency: must be equal to  currency of the Retro treaty
--                    				MOD-58
-- -----------------------------------------------------------------------------
/*INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
  from BTRAV..EST_ESID0801_TESTUTISUP A, BRET..TRETCTR s
  WHERE
	    A.SPEENTTYP_CF in (8,9)
	and A.RETCTR_NF = s.RETCTR_NF
	and A.RTY_NF = s.RTY_NF
	and A.RETCUR_CF <> s.retpcpcur_cf
	
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 30134"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 30134
        select @MsgAnomalie = "Anomalie(s) liee(s) aux devises retro d'AE CSMENGINE"
        select @NumMsgAnomalie = @NumMsgAnomalie + '30134'

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
            FROM btrav..EST_ESID0801_TESTUTISUP
            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
              and SSD_CF       = @p_ssd_cf
              and LSTUPDUSR_CF = @p_usr_cf
    end
*/
-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------

DELETE #TACCSUP1

-- ----------------------------------------------------------------------------
-- 30135 - SAS 17 AE: beginning accounting period should be >= balance sheet month
--                    				MOD-58
-- -----------------------------------------------------------------------------
--INSERT into #TACCSUP1
--select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
--  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
--  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
--  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
--  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
--  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
--  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
--  from BTRAV..EST_ESID0801_TESTUTISUP A
--  WHERE
--	    A.SPEENTTYP_CF in (8,9)
--	and A.SCOSTRMTH_NF < A.BALSHRMTH_NF
--	
--	
--select @erreur = @@error
--if @erreur != 0
--begin
--  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 30135"
--                goto ErreurAno
--end
--
--select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
--if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
--
--if ( @nbligne_tempaccsup > 0 )
--    begin
--                select @error_type = 30135
--        select @MsgAnomalie = "Anomalie(s) liee(s) aux scor periode d'AE CSMENGINE"
--        select @NumMsgAnomalie = @NumMsgAnomalie + '30135'
--
--        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
--        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
--            FROM btrav..EST_ESID0801_TESTUTISUP
--            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
--              and SSD_CF       = @p_ssd_cf
--              and LSTUPDUSR_CF = @p_usr_cf
--    end

-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------

DELETE #TACCSUP1

-- ----------------------------------------------------------------------------
-- 30136 - SAS I17 AE :End accounting period should be between the beginning and the end of balance sheet quarter
--                    				MOD-58
-- -----------------------------------------------------------------------------
--INSERT into #TACCSUP1
--select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
--  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
--  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
--  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
--  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
--  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
--  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
--  from BTRAV..EST_ESID0801_TESTUTISUP A
--  WHERE
--	    A.SPEENTTYP_CF in (8,9)
--	and( A.SCOENDMTH_NF < case when A.BALSHRMTH_NF between 1 and 3 then 1
--                                             when A.BALSHRMTH_NF between 4 and 6 then 4
--                                             when A.BALSHRMTH_NF between 7 and 9 then 7
--                                             when A.BALSHRMTH_NF between 10 and 12 then 10
--                                      end
--	or A.SCOENDMTH_NF > case when A.BALSHRMTH_NF between 1 and 3 then 3
--                                             when A.BALSHRMTH_NF between 4 and 6 then 6
--                                             when A.BALSHRMTH_NF between 7 and 9 then 9
--                                             when A.BALSHRMTH_NF between 10 and 12 then 12
--                                      end
--		)
--
--	
--select @erreur = @@error
--if @erreur != 0
--begin
--  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 30136"
--                goto ErreurAno
--end
--
--select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
--if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
--
--if ( @nbligne_tempaccsup > 0 )
--    begin
--                select @error_type = 30136
--        select @MsgAnomalie = "Anomalie(s) liee(s) aux scor periode d'AE CSMENGINE"
--        select @NumMsgAnomalie = @NumMsgAnomalie + '30136'
--
--        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
--        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
--            FROM btrav..EST_ESID0801_TESTUTISUP
--            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
--              and SSD_CF       = @p_ssd_cf
--              and LSTUPDUSR_CF = @p_usr_cf
--    end
       
-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------

DELETE #TACCSUP1

-- ----------------------------------------------------------------------------
-- 30137 - SAS AE TC:  suffix I,J,K,L,M,N are allowed
--                    				MOD-58
-- -----------------------------------------------------------------------------
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
  from BTRAV..EST_ESID0801_TESTUTISUP A
  WHERE
	    A.TRNCOD_CF not like '%[I-N]'
	AND A.SPEENTTYP_CF in (8,9)

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 30137"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 30137
        select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
        select @NumMsgAnomalie = @NumMsgAnomalie + '30137'

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
            FROM btrav..EST_ESID0801_TESTUTISUP
            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
              and SSD_CF       = @p_ssd_cf
              and LSTUPDUSR_CF = @p_usr_cf
    end


DELETE #TACCSUP1

-- MOD 41 START
--RETRO
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
  from BTRAV..EST_ESID0801_TESTUTISUP A,BREF..TESB B,BRET..TRETCTR C
  WHERE
                  A.SSD_CF=B.SSD_CF
                                AND A.ESB_CF=B.ESB_CF
                                AND A.RTY_NF=C.RTY_NF
                                AND A.SSD_CF=@p_ssd_cf
                                AND A.LSTUPDUSR_CF = @p_usr_cf
                                AND B.LIFE_CF=2
                                AND C.RETCTR_NF=A.RETCTR_NF
                                AND A.TRNCOD_CF LIKE '%[A-Z]'
                                AND A.SPEENTNAT_CT NOT IN (9,10,11) --MOD[060]

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 21036"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 21036
        select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
        select @NumMsgAnomalie = @NumMsgAnomalie + '21036 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
          WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
          and SSD_CF       = @p_ssd_cf
          and LSTUPDUSR_CF = @p_usr_cf
  end

DELETE #TACCSUP1

--MOD 42 start
-- Accounting Year greater than balance sheet year
INSERT into #TACCSUP1
select  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF,
  CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
FROM btrav..EST_ESID0801_TESTUTISUP
where SSD_CF = @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf
and ACY_NF > BALSHEY_NF
AND RETCTR_NF in ('',null)  --check for assume    --mod 44

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "A/C year > annee bilan"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 21038
        select @MsgAnomalie = "A/C year > annee bilan"
        select @NumMsgAnomalie = @NumMsgAnomalie + '21038 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
            FROM btrav..EST_ESID0801_TESTUTISUP
            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
              and SSD_CF       = @p_ssd_cf
              and LSTUPDUSR_CF = @p_usr_cf
              AND RETCTR_NF in ('',null) -- check for assume --mod 44
    end

DELETE #TACCSUP1

INSERT into #TACCSUP1
select  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF,
  CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
FROM btrav..EST_ESID0801_TESTUTISUP
where SSD_CF = @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf
and RETACY_NF > BALSHEY_NF
AND CTR_NF in ('',null)    -- Check for retro --mod 44

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "A/C year > annee bilan"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 21038
        select @MsgAnomalie = "A/C year > annee bilan"
        select @NumMsgAnomalie = @NumMsgAnomalie + '21038 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
            FROM btrav..EST_ESID0801_TESTUTISUP
            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
              and SSD_CF       = @p_ssd_cf
              and LSTUPDUSR_CF = @p_usr_cf
              AND CTR_NF in ('',null)  --check for retro --mod 44
    end

DELETE #TACCSUP1

--FAC
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,          A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
  from BTRAV..EST_ESID0801_TESTUTISUP A,BREF..TESB B,BFAC..tcontr C
  WHERE
                  A.SSD_CF=B.SSD_CF
                                AND A.ESB_CF=B.ESB_CF
                AND A.UWY_NF=C.UWY_NF
                                AND A.SSD_CF=@p_ssd_cf
                                AND A.LSTUPDUSR_CF = @p_usr_cf
                                AND B.LIFE_CF=2
                                AND C.CTR_NF=A.CTR_NF
                                AND A.TRNCOD_CF LIKE '%[A-Z]'
                                AND A.SPEENTNAT_CT NOT IN (9,10,11) --MOD[060]

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - During check 21036"
                goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup > 0 )
    begin
                select @error_type = 21036
        select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
        select @NumMsgAnomalie = @NumMsgAnomalie + '21036 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
            FROM btrav..EST_ESID0801_TESTUTISUP
            WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
              and SSD_CF       = @p_ssd_cf
              and LSTUPDUSR_CF = @p_usr_cf
    end

DELETE #TACCSUP1

-- MOD 41 END
-- ----------------------------------------------------------------------------
--                   CHECKING OF THE VALIDITY PERIOD
--                    if problem => anomaly 20
-- -----------------------------------------------------------------------------

INSERT into #TACCSUP1
select  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF,
  CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
  RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF                                           -- MOD005 26/04/2005 -- MOD007
FROM btrav..EST_ESID0801_TESTUTISUP
where SSD_CF = @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf
and (
		(
            ( --period end of validity >= entry period
				( VALPERMTH_NF >= DatePart(mm, @Verif_d) and VALPERY_NF = DatePart(yy, @Verif_d) )      -- MOD007
			 or ( VALPERY_NF > DatePart(yy, @Verif_d) )
            )
			and
            ( -- period end of validity <= balance sheet period
				( VALPERMTH_NF >= BALSHRMTH_NF and VALPERY_NF = BALSHEY_NF )
            )
            AND SPEENTNAT_CT NOT IN (7,8)
		)
    or  SPEENTNAT_CT in (7,8) /* [CDU] BY-PASS THIS CONTROL FOR LOCAL AE TEMPORARY UNTIL THE CONTROL IS IMPLEMENTED [049] */
    ) 
                                      /* [050] BY-PASS from 049 REMOVED [050] */
select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP1 - Anomalie(s) liee(s) aux periodes de validite'
  goto ErreurAno
    end

-- compare the number of lines between the tables btrav..EST_ESID0801_TESTUTISUP and  #TACCSUP1
-- generation of an anomaly ===> anomaly 20 and exit of the procedure.
-- ----------------------------------------------------------------------------------------------

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 20
    select @MsgAnomalie = 'Anomalie(s) liee(s) aux periodes de validite'
    select @NumMsgAnomalie = @NumMsgAnomalie + '20 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF = @p_ssd_cf                    -- MOD011 MDJ 21/02/2006
      and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
end




--Modification 46 START

/***********************************
Verification if the TRNCOD_CF exist in BREF..TDETTRS++
generation of an anomaly ===> anomaly 105 and exit of the procedure.
*************************************/
--Clear Temp table
DELETE #TACCSUP1

-- Insertion in Temp table
 INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
    and A.TRNCOD_CF  in  (SELECT DETTRS_CF FROM BREF..TDETTRS )
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) aux  postes comptables"
  goto ErreurAno
end

select count(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
--Comparsion of no. of rows
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 105
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '105 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
      and RETCTR_NF in(NULL,'')   -- ASSUME  

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT) 
      SELECT DISTINCT RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
      FROM btrav..EST_ESID0801_TESTUTISUP sup
      WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
        and SSD_CF       = @p_ssd_cf
        and LSTUPDUSR_CF = @p_usr_cf
        and CTR_NF in(NULL,'')   -- RETRO

      end
-- --Modification 46 END
------------------------------------------------------------------------------------------------------

--Modification [056] START--
--------------------------------------------
-- Purge de  #TACCSUP1 avant réutilisation-
-- -----------------------------------------
DELETE #TACCSUP1

-- Insertion in Temp table
--------------------------
INSERT into #TACCSUP1
SELECT A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM BTRAV..EST_ESID0801_TESTUTISUP A
WHERE A.SSD_CF=@p_ssd_cf
  and A.LSTUPDUSR_CF=@p_usr_cf
  and (select LIFE_CF from BREF..TESB E where E.SSD_CF = A.SSD_CF and E.ESB_CF = A.ESB_CF) = 1
  and 
  (
    (select CTRSTS_CT    from BTRT..TCONTR  B where B.CTR_NF = A.CTR_NF and B.END_NT = A.END_NT and B.UWY_NF = A.UWY_NF and B.UW_NT = A.UW_NT) not in (22, null)
   or 
    (select CTRSTS_CT    from BFAC..TCONTR  C where C.CTR_NF = A.CTR_NF and C.END_NT = A.END_NT and C.UWY_NF = A.UWY_NF and C.UW_NT = A.UW_NT) not in (22, null)
  )
  and (select RETCTRSTS_CT from BRET..TRETCTR D where D.RETCTR_NF = A.RETCTR_NF and D.RTY_NF = A.RTY_NF) not in (22, null)

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) aux  postes comptables, code " + convert(varchar,@erreur)
  goto ErreurAno
end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
--Comparsion of no. of rows
if ( @nbligne_tempaccsup != @nbligne_testutisup )
begin
  select @error_type = 2043
  select @MsgAnomalie = "Anomalie(s) liee(s) aux  contrats NTU"
  select @NumMsgAnomalie = @NumMsgAnomalie + '2043 '

  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
  SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
  FROM btrav..EST_ESID0801_TESTUTISUP A
  WHERE CTR_NF NOT IN (SELECT CTR_NF FROM #TACCSUP1)
    and A.SSD_CF       = @p_ssd_cf
    and A.LSTUPDUSR_CF = @p_usr_cf
    and (select LIFE_CF from BREF..TESB E where E.SSD_CF = A.SSD_CF and E.ESB_CF = A.ESB_CF) = 1 
    and 
    (
      (select CTRSTS_CT    from BTRT..TCONTR  B where B.CTR_NF = A.CTR_NF and B.END_NT = A.END_NT and B.UWY_NF = A.UWY_NF and B.UW_NT = A.UW_NT) = 22
     or 
      (select CTRSTS_CT    from BFAC..TCONTR  C where C.CTR_NF = A.CTR_NF and C.END_NT = A.END_NT and C.UWY_NF = A.UWY_NF and C.UW_NT = A.UW_NT) = 22
    )

select @erreur = @@error

if @erreur != 0
begin
  select @MsgAnomalie = "Erreur contrats NTU TRT_FAC , inserting TCTRANO_TMP code "  + convert(varchar,@erreur)
  goto ErreurAno
end


  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT) 
  SELECT DISTINCT RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
  FROM btrav..EST_ESID0801_TESTUTISUP A
  WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
    and A.SSD_CF       = @p_ssd_cf
    and A.LSTUPDUSR_CF = @p_usr_cf
    and (select RETCTRSTS_CT from BRET..TRETCTR D where D.RETCTR_NF = A.RETCTR_NF and D.RTY_NF = A.RTY_NF) = 22
    and (select LIFE_CF from BREF..TESB E where E.SSD_CF = A.SSD_CF and E.ESB_CF = A.ESB_CF) = 1

select @erreur = @@error	
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur contrats NTU RETRO , inserting TCTRANO_TMP code "  + convert(varchar,@erreur)
  goto ErreurAno
end	
	
end
--- --Modification [056] END
------------------------------------------------------------------------------------------------------

-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------
DELETE #TACCSUP1

-- -----------------------------------------------------------------------------
--                   CHECKING OF THE ACCOUNTING TRANSACTION CODE
--                   if problem ===> anomaly 33
-- -----------------------------------------------------------------------------
-- I - VERIFY
-- when the retrocession contract is inquired, even if we have  acceptance, the file contains a transaction code with retro type.
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, B.CTRSCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF   -- MOD005 26/04/2005 -- MOD007
 from BTRAV..EST_ESID0801_TESTUTISUP A, BREF..TDETTRS B
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
    and A.TRNCOD_CF=B.DETTRS_CF
    and B.OPN_B=1          -- poste open
    and (  (A.SPEENTNAT_CT in(4,5,6) and (TRNCOD_CF LIKE '_[EGHJL]%' or TRNCOD_CF LIKE '%G') ) -- EBS MOD029 EBS AE for Solvency (G suffix) should ignore the 2nd prefix test -- MOD033 take into account deposits
        or (A.SPEENTNAT_CT in(1,2,3) and TRNCOD_CF LIKE '_[4679CNORSUVWXY]%')  -- IFRS
        or (A.SPEENTNAT_CT in(9,10,11) and TRNCOD_CF LIKE '_[456789CNORSUVWXY]%')  -- IFRS
        or (A.SPEENTNAT_CT in(7,8) and TRNCOD_CF LIKE '_[4679CNORSUVWXY]%') ) -- LOCAL IFRS [049]
    and (  (CTR_NF!=NULL and RETCTR_NF in(NULL,'') and TRNCOD_CF like '[13]%')
        or (RETCTR_NF!=NULL and TRNCOD_CF like '[24]%') )
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) aux  postes comptables"
  goto ErreurAno
end

-- modif 22, modif 23
--delete #TACCSUP1
-- from #TACCSUP1 a
 --where TRNCOD_CF like '_[1-9]%'
-- and not exists(select 1 from BREF..TDETTRS d, BREF..TSUBTRSESB s				--MOD027
--               where d.dettrs_cf=a.TRNCOD_CF
--               and s.ssd_cf=a.SSD_CF
--             and s.ESB_CF=a.ESB_CF										--MOD027
      --           and d.pcptrs_cf=s.pcptrs_cf
          --         and d.trs_cf=s.trs_cf
              --       and d.subtrs_cf=s.subtrs_cf
--
  --                   and d.opn_b=1
    --                 and d.dettrs_cf!=d.ctrscod_cf)
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) aux  postes comptables"
  goto ErreurAno
end

/* compare the number of lines between EST_ESIDO801_TESTUTISUP and #TACCSUP1 */
/* generation of an anomaly and exit of the procedure, anomaly 33   */
/* ------------------------------------------------------------- */
select count(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 33
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '33 a '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP sup
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
      and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
    and (RETCTR_NF in(NULL,'') OR (RETCTR_NF not in(NULL,'') AND CTR_NF not in (NULL,'')))   -- ASSUME  -- [MOD53]
    and sup.NUMLINE_NT NOT IN (SELECT ano.NUMLINE_NT FROM #TCTRANO_TMP ano WHERE ano. ANO_CT = 105) -- Modification 46

--Mod 45 START
  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP sup
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
    and CTR_NF in(NULL,'')   -- RETRO
    and sup.NUMLINE_NT NOT IN (SELECT ano.NUMLINE_NT FROM #TCTRANO_TMP ano WHERE ano. ANO_CT = 105) -- Modification 46
end
--Mod 45 END

-- Add JVDV [14839]

-- II - VERIFY
-- if the accounting transaction code is the same as counter balance  transaction code, it means that the main accounting transaction code entered is a counter balance  transaction code
-- (reminder that the counter balance  transaction code is updated in the procedure with the help of the table bref..TDETTRS)
--                   if problem ===> anomaly 50

-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------
DELETE #TACCSUP1             --[18612]

INSERT into #TACCSUP1
select
    A.TRN_NT,A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  btrav..EST_ESID0801_TESTUTISUP A
where
        A.SSD_CF       = @p_ssd_cf
and     A.LSTUPDUSR_CF = @p_usr_cf
and   A.TRNCOD_CF   != A.DBLTRNCOD_CF   -- le poste principal doit toujours être différent du poste de contre-partie.

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Anomalie(s) liee(s) aux postes comptables'
  goto ErreurAno
    end

-- compare the number of lines between the tables btrav..EST_ESID0801_TESTUTISUP and #TACCSUP1
-- generation of an anomaly => anomaly 50 and exit of the procedure
-- ---------------------------------------------------------------------------------------------

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 50
    select @MsgAnomalie = 'Anomalie(s) liee(s) au poste comptable principal = poste de contre-partie'
    select @NumMsgAnomalie = @NumMsgAnomalie + '50 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP sup
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
    and RETCTR_NF in(NULL,'')   -- ASSUME
    and sup.NUMLINE_NT NOT IN (SELECT ano.NUMLINE_NT FROM #TCTRANO_TMP ano WHERE ano. ANO_CT = 105) -- Modification 46

  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP sup
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
    and CTR_NF in(NULL,'')   -- RETRO
    and sup.NUMLINE_NT NOT IN (SELECT ano.NUMLINE_NT FROM #TCTRANO_TMP ano WHERE ano. ANO_CT = 105) -- Modification 46
  end


-- [18612] --------------------------------------------------------------------------
--            OTHER CHECKING OF THE ACCOUNTING TRANSACTION CODE
--            if problem ===> anomaly 49 'service balance sheet transaction code unauthorized '
--            the accounting transaction codes below are unauthorized:
--            - service balance sheet transaction code x5yyyyyz
--            - service balance sheet transaction code rejection x8yyyyyz
-- -----------------------------------------------------------------------------


DELETE #TACCSUP1        -- Purge de  #TACCSUP1 avant réutilisation

INSERT into #TACCSUP1
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF

FROM  btrav..EST_ESID0801_TESTUTISUP A

WHERE
    A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf
and ( substring( A.TRNCOD_CF,2,1 ) != '5'
      AND
      substring( A.TRNCOD_CF,2,1 ) != '8'
    )
UNION -- Assumed
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
from btrav..EST_ESID0801_TESTUTISUP a, btrt..tsection s where
		 a.ctr_nf is not null
 and a.ctr_nf = s.ctr_nf
 and a.sec_nf = s.sec_nf
 and a.uwy_nf = s.uwy_nf
 and s.lob_cf in ('30','31')
 and SPEENTNAT_CT in (9, 10, 11)
 
UNION -- Retro
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
from btrav..EST_ESID0801_TESTUTISUP a, bret..tretsec s where
     a.retctr_nf is not null and a.ctr_nf is null
 and a.retctr_nf = s.retctr_nf
 and a.retsec_nf = s.retsec_nf
 and a.rty_nf = s.rty_nf
 and s.lob_cf in ('30','31') 
 and SPEENTNAT_CT in (9, 10, 11)
  

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Cas de Poste bilan de service non autorisé '
  goto ErreurAno
    end

/* compare the number of lines between the tables EST_ESID0801_TESTUTISUP and #TACCSUP1 */
/* generation of an anomaly and exit of the procedure, anomaly 49   */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
      select @error_type = 49
        select @MsgAnomalie = 'Anomalie(s) liee(s) aux  postes comptables service'
        select @NumMsgAnomalie = @NumMsgAnomalie + '49'

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, 'A', @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
        and SSD_CF       = @p_ssd_cf
        and LSTUPDUSR_CF = @p_usr_cf
  end

-- Purge de la table #TACCSUP1 avant réutilisation
-- -----------------------------------------------
DELETE #TACCSUP1

-- ---------------------------------------------------------------------------------------------------------
--              MOD004            NEW ANOMALY 46 - MOD004 11/04/2005
-- ---------------------------------------------------------------------------------------------------------
-- selection of the number of opening transaction codes concerned
Select @nbligne_PosteOuverture = Count(*)
FROM btrav..EST_ESID0801_TESTUTISUP
where SSD_CF = @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf
and (CTR_NF != NULL OR RETCTR_NF != NULL )
and  ( substring( TRNCOD_CF, 2, 1 ) = '7' OR
       substring( TRNCOD_CF, 2, 1 ) = '8' OR
       substring( TRNCOD_CF, 2, 1 ) = '9'
      )

-- selection of opening transaction code for the validity period = balance period
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF                    -- MOD005 26/04/2005 -- MOD007
FROM  btrav..EST_ESID0801_TESTUTISUP A
where
    A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf
and (CTR_NF       != NULL OR RETCTR_NF != NULL )
and ( substring( TRNCOD_CF, 2, 1 ) = '7' or
      substring( TRNCOD_CF, 2, 1 ) = '8' or
      substring( TRNCOD_CF, 2, 1 ) = '9'
    )
and (VALPERMTH_NF = BALSHRMTH_NF and VALPERY_NF = BALSHEY_NF)     -- MOD010

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) aux  postes Ouvertures "
  goto ErreurAno
    end

-- Compare EST_ESID0801_TESTUTISUP and #TACCSUP1
-- anomaly and exit of the procedure, anomaly 46
-- -----------------------------------------------------------------------------------

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_PosteOuverture )
  begin
      select @error_type = 46
        select @MsgAnomalie = "Postes Ouvertures : Période Validité <> Période Bilan ! "
        select @NumMsgAnomalie = @NumMsgAnomalie + '46 '

        -- Selection opening transaction code ACCEPT
        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
        and SSD_CF = @p_ssd_cf
        and LSTUPDUSR_CF = @p_usr_cf
        and (CTR_NF != NULL)
        and ( substring( TRNCOD_CF, 2, 1 ) = '7' or
              substring( TRNCOD_CF, 2, 1 ) = '8' or
              substring( TRNCOD_CF, 2, 1 ) = '9'
            )

        -- Selection opening transaction code RETRO
        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
        and SSD_CF = @p_ssd_cf
        and LSTUPDUSR_CF = @p_usr_cf
        and (RETCTR_NF != NULL )
        and ( substring( TRNCOD_CF, 2, 1 ) = '7' or
              substring( TRNCOD_CF, 2, 1 ) = '8' or
              substring( TRNCOD_CF, 2, 1 ) = '9'
            )
        and NUMLINE_NT NOT IN (SELECT NUMLINE_NT FROM #TCTRANO_TMP WHERE ANO_CT = 46)
    end


-- Purge de la table #TACCSUP1 avant réutilisation
DELETE #TACCSUP1

-- ---------------------------------------------------------------------------------------------------------
--  FIN ANOMALIE 46 - MOD004 11/04/2005
-- ---------------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
--                   CHECKING OF UWY NO EXIST
--                    if problem => anomaly 106          			-- MODIF 47
-- ----------------------------------------------------------------------------
-- Case Treaty
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A
 WHERE  A.SSD_CF = @p_ssd_cf
  AND A.LSTUPDUSR_CF = @p_usr_cf
  AND A.CTR_NF IN ( SELECT B.CTR_NF FROM BTRT..TCONTR B WHERE B.CTR_NF = A.CTR_NF )
  AND A.CTR_NF NOT IN ( SELECT B.CTR_NF FROM BTRT..TCONTR B WHERE B.CTR_NF = A.CTR_NF and B.UWY_NF = A.UWY_NF )

select @erreur = @@error
  if @erreur != 0
  begin
    select @MsgAnomalie = "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) au cas Treaty"
    goto ErreurAno
  end

-- Case Facultative
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A
 WHERE  A.SSD_CF = @p_ssd_cf
  AND A.LSTUPDUSR_CF = @p_usr_cf
  AND A.CTR_NF IN ( SELECT C.CTR_NF FROM BFAC..TCONTR C WHERE C.CTR_NF = A.CTR_NF )
  AND A.CTR_NF NOT IN ( SELECT C.CTR_NF FROM BFAC..TCONTR C WHERE C.CTR_NF = A.CTR_NF and C.UWY_NF = A.UWY_NF )

select @erreur = @@error
  if @erreur != 0
  begin
    select @MsgAnomalie = "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) au cas Facultative"
    goto ErreurAno
  end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup > 0 )
  begin
  select @error_type = 106
    select @MsgAnomalie = 'Anomalie(s) liee(s) à l''année d''exercice comptable'

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
  end

-- Purge de la table #TACCSUP1 avant réutilisation
-- ------------------------------------------------
DELETE #TACCSUP1

-- Case Retrocession
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A
 WHERE A.SSD_CF = @p_ssd_cf
  AND A.LSTUPDUSR_CF = @p_usr_cf
  AND A.CTR_NF NOT IN ( SELECT B.CTR_NF FROM BTRT..TCONTR B WHERE B.CTR_NF = A.CTR_NF )
  AND A.RETCTR_NF IS NOT NULL
  AND A.RETCTR_NF IN ( SELECT C.RETCTR_NF FROM BRET..TRETCTR C WHERE C.RETCTR_NF = A.RETCTR_NF )
  AND A.RETCTR_NF NOT IN (SELECT C.RETCTR_NF FROM BRET..TRETCTR C where C.RETCTR_NF = A.RETCTR_NF AND C.RTY_NF = A.RTY_NF)

select @erreur = @@error
  if @erreur != 0
  begin
    select @MsgAnomalie = "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) au cas Retrocession"
    goto ErreurAno
  end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup > 0 )
  begin
  select @error_type = 106
    select @MsgAnomalie = 'Anomalie(s) liee(s) à l''année d''exercice comptable'

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
  end

-- Purge de la table #TACCSUP1 avant réutilisation
-- ------------------------------------------------
DELETE #TACCSUP1


/*-----------------------------------------------------------------------------*/
/*                EXISTENCE CHECKING OF RETROCESSION SECTION                   */
/*                      if problem => anomaly 27                                           */
/*-----------------------------------------------------------------------------*/


INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF    -- MOD005 26/04/2005 - MOD007
FROM  BTRAV..EST_ESID0801_TESTUTISUP A,
        bret..TRETSEC B
where
    A.RETCTR_NF != NULL
and A.RETCTR_NF = B.RETCTR_NF
and A.RETSEC_NF = B.RETSEC_NF
and A.RTY_NF    = B.RTY_NF
and A.RETEND_NT = 0
and A.RETUW_NT  = 1
and A.SSD_CF    = B.SSD_CF
and A.SSD_CF    = @p_ssd_cf

-- We are in the existence checking of  retro sections, we have to insert all "pure" acceptance
--  otherwise , we will have a shift by counting the number of lines

INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF         -- MOD005 26/04/2005 - MOD007
FROM  btrav..EST_ESID0801_TESTUTISUP A
where
    (A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
and A.CTR_NF != NULL

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP1 - Contrôle Existance Section Rétro'
  goto ErreurAno
    end

/* we compare the number of lines between EST_ESID0801_TESTUTISUP and #TACCSUP2 */
/* generation of an anomaly and exit of the procedure, anomaly 27   */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
   begin
      SELECT @error_type     = 27
        select @MsgAnomalie    = 'Section rétro inconnue'
        select @NumMsgAnomalie = @NumMsgAnomalie + '27 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP sup
        WHERE sup.TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
             and sup.SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
             and sup.LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
             and sup.NUMLINE_NT NOT IN (SELECT ano.NUMLINE_NT FROM #TCTRANO_TMP ano WHERE ano. ANO_CT = 106) -- Modification 47
  end


-- Purge de  #TACCSUP1 avant réutilisation
-- ---------------------------------------
DELETE #TACCSUP1

/*-----------------------------------------------------------------------------*/
/*                 EXISTENCE CHECKING OF ACCEPTANCE SECTION       	           */
/*                      if problem =>  anomaly 28                                           */
/*-----------------------------------------------------------------------------*/

/* access to the table  BFAC..TSECTION only for the acceptance business inquired */
/* ------------------------------------------------------------------------------------ */

INSERT into #TACCSUP1
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF      -- MOD005 26/04/2005 - MOD007
FROM  btrav..EST_ESID0801_TESTUTISUP A, BFAC..TSECTION B
where
    A.CTR_NF != NULL
and A.CTR_NF = B.CTR_NF -- MOD034 remove check on contract ID
and A.END_NT = B.END_NT
and A.SEC_NF = B.SEC_NF
and A.UWY_NF = B.UWY_NF
and A.UW_NT  = B.UW_NT
and A.SSD_CF = B.SSD_CF
and A.SSD_CF = @p_ssd_cf


select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP1 - CONTROLE D''EXISTENCE DES SECTIONS ACCEPTATION'
  goto ErreurAno
    end

-- access to the table  BTRT..TSECTION  only for the acceptance business inquired
-- ------------------------------------------------------------------------------------

INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF         -- MOD005 26/04/2005 - MOD007
FROM  btrav..EST_ESID0801_TESTUTISUP A,
        btrt..TSECTION B
where
    A.CTR_NF != NULL
and A.CTR_NF = B.CTR_NF -- MOD034 remove check on contract ID
and A.END_NT = B.END_NT
and A.SEC_NF = B.SEC_NF
and A.UWY_NF = B.UWY_NF
and A.UW_NT  = B.UW_NT
and A.SSD_CF = B.SSD_CF
and A.SSD_CF = @p_ssd_cf

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TACCSUP1 - Accès à la table BTRT..TSECTION "
  goto ErreurAno
    end

-- We are in the existence checking of acceptance sections, we need to insert all  pure retro,
-- otherwise, we will have a shift by counting the number of lines.

INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF  -- MOD005 26/04/2005 - MOD007
FROM  btrav..EST_ESID0801_TESTUTISUP A
where
    A.RETCTR_NF != NULL
AND (A.CTR_NF = NULL OR A.CTR_NF = '')

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP1 - Contrôle Existance Section Acceptation'
  goto ErreurAno
    end

/* compare the number of lines between EST_ESIDO801_TESTUTISUP and #TACCSUP1 */
/* generation of an anomaly and exit of the procedure, anomaly 28   */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
      -- generation of an anomaly and exit of the procedure
      SELECT @error_type = 28
        select @MsgAnomalie = "Section acceptation inconnue"
        select @NumMsgAnomalie = @NumMsgAnomalie + '28 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, 'A', @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP sup
        WHERE sup.TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
             and sup.SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
             and sup.LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
             and sup.NUMLINE_NT NOT IN (SELECT ano.NUMLINE_NT FROM #TCTRANO_TMP ano WHERE ano. ANO_CT = 106) -- Modification 47
  end

-- Purge de la table #TACCSUP1 avant réutilisation
-- -----------------------------------------------
DELETE #TACCSUP1





----- MODIF37 To restrict retro contracts uploading with the status to be checked or checked start

---------------------------------------------------------------------------------------------------------------------------------
--  ERROR  21034-  The restrict retro contracts with to be checked start RETCTRSTS_CT = 1(To_be_checked) or 2(CHECKED)
---------------------------------------------------------------------------------------------------------------------------------

INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF,  A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A, BRET..TRETCTR s
  where A.SSD_CF=@p_ssd_cf
  and s.RETCTR_NF=A.RETCTR_NF
  and s.RTY_NF=A.RTY_NF
  and s.RETCTRSTS_CT NOT IN(1,2)
  and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - The retro contract status is 'To be checked' or 'Checked' "
  goto ErreurAno
end

INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  btrav..EST_ESID0801_TESTUTISUP A
where
    (A.RETCTR_NF   = NULL OR A.RETCTR_NF = '')  -- ok contrat rétro.
and A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP1 - Anomalie(s) liee(s) a l''annee de compte rétrocession'
  goto ErreurAno
end


/* Compare line number bt EST_ESID0801_TESTUTISUP and #TACCSUP1 */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 21034
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '21034'

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP sup
    WHERE sup.TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
         and sup.SSD_CF       = @p_ssd_cf
         and sup.LSTUPDUSR_CF = @p_usr_cf
         and sup.NUMLINE_NT NOT IN (SELECT ano.NUMLINE_NT FROM #TCTRANO_TMP ano WHERE ano. ANO_CT = 106) -- Modification 47
  end

-- Purge de la table #TACCSUP1 avant réutilisation
-- ------------------------------------------------
DELETE #TACCSUP1
--------------------------- END for uploading Retro - to be checked





---------------------------------------------------------------------------------------------------------------------------------
--  ERROR 104 -  The contract/underwriting year is closed i.e. TERCTR_B=0 - MODIF 36
---------------------------------------------------------------------------------------------------------------------------------

INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF,  A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A, BRET..TRETCTR s
  where A.SSD_CF=@p_ssd_cf
  and s.RETCTR_NF=A.RETCTR_NF
  and s.RTY_NF=A.RTY_NF
  and s.TERCTR_B=0
  and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to retro subisdiary events"
  goto ErreurAno
end

INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  btrav..EST_ESID0801_TESTUTISUP A
where
    (A.RETCTR_NF   = NULL OR A.RETCTR_NF = '')  -- ok contrat rétro.
and A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP1 - Anomalie(s) liee(s) a l''annee de compte rétrocession'
  goto ErreurAno
end


/* Compare line number bt EST_ESID0801_TESTUTISUP and #TACCSUP1 */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 104
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '104 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP sup
    WHERE sup.TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
         and sup.SSD_CF       = @p_ssd_cf
         and sup.LSTUPDUSR_CF = @p_usr_cf
         and sup.NUMLINE_NT NOT IN (SELECT ano.NUMLINE_NT FROM #TCTRANO_TMP ano WHERE ano. ANO_CT = 106) -- Modification 47
  end



---------------------------------------------------------------------------------------------------
--  ERROR 21050 -  Assumed Event does not exists 								-- MODIF 61
---------------------------------------------------------------------------------------------------

-- SPIRA 94391 addition of condition AND t.EVT_NF !=  CAST( EVT.SUBEVT_NF AS VARCHAR(10))

declare @counterror int 

SELECT @counterror = count (*)
  FROM BCTA..TCLMDET CLMDET,  
       BCTA..TCLAIM CLM,
       BCTA..TEVENT EVT,
       btrav..EST_ESID0801_TESTUTISUP t
 WHERE     CLM.SSD_CF = @p_ssd_cf                                       --From input
       AND t.LSTUPDUSR_CF = @p_usr_cf                            --From input
       AND CLM.CLM_NF = t.clm_nf                                 
       AND CLM.CLMDET_NF = CLMDET.CLM_NF
       AND CLMDET.EVT_NF = EVT.SUBEVT_NF
       AND CLMDET.SSD_CF = EVT.SSD_CF
       AND t.EVT_NF !=  ("G"+CAST( EVT.GEV_NF AS VARCHAR(10)))
       AND t.EVT_NF !=  ("G"+CAST( EVT.SUBEVT_NF AS VARCHAR(10)))
-- [067]	   
       AND t.EVT_NF !=  CAST( EVT.SUBEVT_NF AS VARCHAR(10))

if(@counterror>0)
    begin
        select @error_type = 21050
        select @MsgAnomalie = "Cet événement ne correspond pas à ce Sinistre."
        select @NumMsgAnomalie = @NumMsgAnomalie + '21050 '
       
    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP sup
    where SUP.SSD_CF = @p_ssd_cf 
    and SUP.LSTUPDUSR_CF = @p_usr_cf
    and sup.NUMLINE_NT in (SELECT t.NUMLINE_NT
    FROM BCTA..TCLMDET CLMDET,  
       BCTA..TCLAIM CLM,
       BCTA..TEVENT EVT,
       btrav..EST_ESID0801_TESTUTISUP t
         WHERE     CLM.SSD_CF = @p_ssd_cf                                       --From input
       AND t.LSTUPDUSR_CF = @p_usr_cf                            --From input
       AND CLM.CLM_NF = t.clm_nf                                 
       AND CLM.CLMDET_NF = CLMDET.CLM_NF
       AND CLMDET.EVT_NF = EVT.SUBEVT_NF
       AND CLMDET.SSD_CF = EVT.SSD_CF
       AND t.EVT_NF !=  ("G"+CAST( EVT.GEV_NF AS VARCHAR(10)))
       AND t.EVT_NF !=  ("G"+CAST( EVT.SUBEVT_NF AS VARCHAR(10)))
-- [067]	   
	   AND t.EVT_NF !=  CAST( EVT.SUBEVT_NF AS VARCHAR(10)))
       and CTR_NF !=null
    End

-- Purge de la table #TACCSUP1 avant réutilisation
-- ------------------------------------------------
DELETE #TACCSUP1
---------------------------------------------------------------------------------------------------
--  ERROR 21030 -  Assumed Event does not exists 								-- MODIF 30
---------------------------------------------------------------------------------------------------
--select "21030", Datediff(MS,@astartTime ,getDate())
-- subsidiary events
INSERT into #TACCSUP1
select A.TRN_NT,
A.ACCTYP_NF,
A.SSD_CF,
A.ESB_CF,
A.ENTPERY_NF,
A.ENTPERMTH_NF,
A.BALSHEY_NF,
A.BALSHRMTH_NF,
  A.BALSHRDAY_NF,
  A.VALPERY_NF,
  A.VALPERMTH_NF,
  A.TRNCOD_CF,
  A.DBLTRNCOD_CF,
  A.RETAUTGEN_B,
  A.CTR_NF,
  A.END_NT,
  A.SEC_NF,
  A.UWY_NF,
  A.UW_NT,
  A.OCCYEA_NF,
  A.ACY_NF,
  A.SCOSTRMTH_NF,
  A.SCOENDMTH_NF,
  A.CLM_NF,
  A.CUR_CF,
  A.AMT_M,
  A.CED_NF,
  A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT,A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A, BCTA..TEVENT EVT
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
  and A.EVT_NF = CAST( EVT.SUBEVT_NF AS VARCHAR(10))
  and A.SSD_CF = EVT.SSD_CF
  and A.EVT_NF IS NOT NULL
  and A.EVT_NF <> ""

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed subsidiary events"
  goto ErreurAno
end

--group events -- to fix
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A,
    BCTA..TEVTDET T2,
    BCTA..TGRPEVT T7
 WHERE
    A.SSD_CF = @p_ssd_cf AND
    A.LSTUPDUSR_CF = @p_usr_cf and
    T7.GEV_NF = T2.EVT_NF AND
    T7.SSD_CF = T2.SSD_CF AND
    T2.SUP_B = 0 AND
    T2.SSD_CF = 0 AND
  A.EVT_NF = ("G"+CAST( T2.EVT_NF AS VARCHAR(10))) AND
  A.EVT_NF IS NOT NULL AND
  A.EVT_NF <> ""

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed group events"
  goto ErreurAno
end

--then if event is null there should be no error
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A
 WHERE  A.SSD_CF=@p_ssd_cf
  AND A.LSTUPDUSR_CF = @p_usr_cf
  and (A.EVT_NF is null OR A.EVT_NF = "")

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed events"
  goto ErreurAno
end
  /* Compare line number bt EST_ESID0801_TESTUTISUP and #TACCSUP1 */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 21030
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '21030 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
  end
-- Purge de la table #TACCSUP1 avant réutilisation
-- ------------------------------------------------
DELETE #TACCSUP1

-----------------------------------------------------------------------------------------------------------
--  ERROR 21031 -  The assumed event does not correspond to the Assumed single Claim           -- MODIF 30
-- --------------------------------------------------------------------------------------------------------
-- select "21031", Datediff(MS,@astartTime ,getDate())

--subsidiary event
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A, BCTA..TCLMDET TCLM,BCTA..TCLAIM CLM,BCTA..TEVENT EVT     --Mod31
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
  and (A.CLM_NF is not null) and (A.EVT_NF is not null) and  (A.EVT_NF <> "")
  and A.EVT_NF = CAST(TCLM.EVT_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.CLM_NF = CLM.CLM_NF                 --Mod31
    and CLM.CLMDET_NF =  TCLM.CLM_NF     --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed subsidiary events and claims"
  goto ErreurAno
end

--group events
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A, BCTA..TCLMDET TCLM,BCTA..TCLAIM CLM,BCTA..TEVENT EVT     --Mod31
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
  and (A.CLM_NF is not null) and (A.EVT_NF is not null) and  (A.EVT_NF <> "")
  and A.EVT_NF = "G" + CAST(EVT.GEV_NF AS VARCHAR(10) )
  and A.SSD_CF = TCLM.SSD_CF
  and A.CLM_NF = CLM.CLM_NF                  --Mod31
    and CLM.CLMDET_NF =  TCLM.CLM_NF      --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed group events and claims"
  goto ErreurAno
end

-- if the claim is null or the claim is null, there should be no error
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A
 WHERE A.SSD_CF=@p_ssd_cf
    AND A.LSTUPDUSR_CF=@p_usr_cf
  AND (A.EVT_NF is null OR A.CLM_NF is null OR A.EVT_NF is null OR  A.EVT_NF = "")

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed and claims"
  goto ErreurAno
end

/* Compare line number bt EST_ESID0801_TESTUTISUP and #TACCSUP1 */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 21031
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '21031 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
  end

-- Purge de la table #TACCSUP1 avant réutilisation
-- ------------------------------------------------
DELETE #TACCSUP1



---------------------------------------------------------------------------------------------------------------
--  ERROR 21032 -  Retro Event does not exists 														-- MODIF 30
-- ------------------------------------------------------------------------------------------------------------
-- select "21032", Datediff(MS,@astartTime ,getDate())
-- subsidiary events
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF,  A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A, BCTA..TEVENT EVT
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
  and A.REVT_NF is not null
  and A.REVT_NF <> ""
  and A.REVT_NF = CAST( EVT.SUBEVT_NF AS VARCHAR(10))
  and A.SSD_CF = EVT.SSD_CF

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to retro subisdiary events"
  goto ErreurAno
end


--group events -- to fix
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF,  A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A,
    BCTA..TEVTDET T2,
    BCTA..TGRPEVT T7
WHERE
    A.SSD_CF = @p_ssd_cf AND
    A.LSTUPDUSR_CF = @p_usr_cf and
    T7.GEV_NF = T2.EVT_NF AND
    T7.SSD_CF = T2.SSD_CF AND
    T2.SUP_B = 0 AND
    T2.SSD_CF = 0 AND
  A.REVT_NF = ("G"+CAST( T2.EVT_NF AS VARCHAR(10))) AND
  A.REVT_NF IS NOT NULL AND
  A.REVT_NF <> ""
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to retro group events"
  goto ErreurAno
end

--then if event is null there should be no error
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A
 WHERE  A.SSD_CF=@p_ssd_cf
  AND A.LSTUPDUSR_CF = @p_usr_cf
  and (A.REVT_NF is null OR A.REVT_NF = "")

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to retro events"
  goto ErreurAno
end

/* Compare line number bt EST_ESID0801_TESTUTISUP and #TACCSUP1 */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 21032
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '21032 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
  end


/****************** Modification 050 START ******************
******************* New Assistance Entries ******************/

/********************************************************
-- Functional test of ssb end esb local AE
*********************************************************/
/****************** Modification 052 START ******************/
/********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1

-- Insert working data into Temp table
INSERT INTO #TACCSUP1
SELECT A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM BTRAV..EST_ESID0801_TESTUTISUP A
WHERE
    A.SSD_CF = @P_SSD_CF AND
    A.LSTUPDUSR_CF = @P_USR_CF AND
	(A.SPEENTNAT_CT not in (7,8) OR
    (A.SPEENTNAT_CT in (7,8) AND
    (0 <   (SELECT C.LOCALAE_CT
            FROM
                BTRT..TCONTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ACCESB_CF = C.ESB_CF AND
                    A.CTR_NF != NULL AND
                    A.END_NT != NULL AND
                    A.UWY_NF != NULL AND
                    A.UW_NT != NULL AND
                    A.CTR_NF = B.CTR_NF AND
                    A.END_NT = B.END_NT AND
                    A.UWY_NF = B.UWY_NF AND
                    A.UW_NT = B.UW_NT
            )
    OR
    0 <   (SELECT C.LOCALAE_CT
            FROM
                BFAC..TCONTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ACCESB_CF = C.ESB_CF AND
                    A.CTR_NF != NULL AND
                    A.END_NT != NULL AND
                    A.UWY_NF != NULL AND
                    A.UW_NT != NULL AND
                    A.CTR_NF = B.CTR_NF AND
                    A.END_NT = B.END_NT AND
                    A.UWY_NF = B.UWY_NF AND
                    A.UW_NT = B.UW_NT
            )
    OR
    0 <   (SELECT C.LOCALAE_CT
            FROM
                BRET..TRETCTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ESB_CF = C.ESB_CF AND
                    A.RETCTR_NF != NULL AND
                    A.RTY_NF != NULL AND
                    A.RETCTR_NF = B.RETCTR_NF AND
                    A.RTY_NF = B.RTY_NF
            )
    )))
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "#TACCSUP1 Error - SSD and ESB are not in local AE"
  goto ErreurAno
end

SELECT COUNT(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 308
    select @MsgAnomalie = "Unauthorized Ledger for local "
    select @NumMsgAnomalie = @NumMsgAnomalie + '308 '

    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf AND
            RETCTR_NF IN ( NULL, '' ) -- ASSUMED
    
    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf AND
            CTR_NF IN ( NULL, '' ) -- RETRO
end

/****************** Modification 052 END ******************/
/********************************************************
-- Check 1:
-- Checking the detailled transaction codes authorized for local AE. ==> If SPEENTNAT_CT in (7,8) then we have to have DETTRS_CF in (select DETTRS_CF from bref..ttrslnk 
    where ((prs_cf=610 and acmtrs_nt=200)
          or (prs_cf=605 and acmtrs_nt=300)
          or (prs_cf=605 and acmtrs_nt=310)
          or (prs_cf=605 and acmtrs_nt=320))

-- Generating the anomaly 307 and exit the procedure.
*********************************************************/

/********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1


/********************************************************
-- Functional test of the authorized T. Codes for local AE
*********************************************************/
-- Insert working data into Temp table
INSERT INTO #TACCSUP1
SELECT A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM BTRAV..EST_ESID0801_TESTUTISUP A
WHERE
    A.SSD_CF = @P_SSD_CF AND
    A.LSTUPDUSR_CF = @P_USR_CF AND
    (A.SPEENTNAT_CT NOT IN (7,8) OR
    (A.SPEENTNAT_CT IN (7,8) AND
    A.TRNCOD_CF IN (SELECT DETTRS_CF
                    FROM BREF..TTRSLNK
                    WHERE
                        ((PRS_CF = 610 AND ACMTRS_NT = 200) and exists (select 1 from BREF..TBANTECESB b where b.SSD_CF = @P_SSD_CF and b.ESB_CF = A.ESB_CF and b.COL_LS='LOCADJLVL_CT' and b.COLVAL_CT in ('1','3'))) OR
                        ((PRS_CF = 605 AND ACMTRS_NT = 300) and exists (select 1 from BREF..TBANTECESB b where b.SSD_CF = @P_SSD_CF and b.ESB_CF = A.ESB_CF and b.COL_LS='LOCADJLVL_CT' and b.COLVAL_CT in ('2','3'))) OR
                        ((PRS_CF = 605 AND ACMTRS_NT = 310) and exists (select 1 from BREF..TBANTECESB b where b.SSD_CF = @P_SSD_CF and b.ESB_CF = A.ESB_CF and b.COL_LS='LOCADJLVL_CT' and b.COLVAL_CT in ('2','3'))) OR
                        ((PRS_CF = 605 AND ACMTRS_NT = 320) and exists (select 1 from BREF..TBANTECESB b where b.SSD_CF = @P_SSD_CF and b.ESB_CF = A.ESB_CF and b.COL_LS='LOCADJLVL_CT' and b.COLVAL_CT in ('2','3'))))))
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Error while generating TACCSUP1 temp table - T. Code processing anomaly"
  goto ErreurAno
end

SELECT COUNT(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 307
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables ES locales"
    select @NumMsgAnomalie = @NumMsgAnomalie + '307 '

    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf AND
            RETCTR_NF IN ( NULL, '' ) -- ASSUMED
    
    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf AND
            CTR_NF IN ( NULL, '' ) -- RETRO
end

/********************************************************
-- Check 2:
-- Checking the Balance Sheet and Validity Period consistency of the new local AE.
-- Generating new anomalies :
-- 1- Balance sheet year and end of validity year must be equal ==> We have to have BALSHEY_NF = VALPERY_NF 
-- 2- Balance sheet month and end of validity month must be equal ==> We have to have BALSHRMTH_NF = VALPERMTH_NF 

*********************************************************/

/********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1


/********************************************************
-- Functional test of the Balance sheet year and end of validity year of local AE
*********************************************************/
-- Insert working data into Temp table
INSERT INTO #TACCSUP1
SELECT A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM BTRAV..EST_ESID0801_TESTUTISUP A
WHERE
    A.SSD_CF = @P_SSD_CF AND
    A.LSTUPDUSR_CF = @P_USR_CF AND
    (A.SPEENTNAT_CT NOT IN (7,8) OR
    (A.SPEENTNAT_CT IN (7,8) AND
    A.BALSHEY_NF = A.VALPERY_NF))
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "#TACCSUP1 Error - Balance sheet and end of validity year must be equal"
  goto ErreurAno
end

SELECT COUNT(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 300
    select @MsgAnomalie = "Annees de date bilan et de fin de periode de validite doivent etre egales"
    select @NumMsgAnomalie = @NumMsgAnomalie + '300 '

    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf
end

/********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1


/********************************************************
-- Functional test of the Balance sheet month and end of validity month of local AE
*********************************************************/
-- Insert working data into Temp table
INSERT INTO #TACCSUP1
SELECT A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM BTRAV..EST_ESID0801_TESTUTISUP A
WHERE
    A.SSD_CF = @P_SSD_CF AND
    A.LSTUPDUSR_CF = @P_USR_CF AND
    (A.SPEENTNAT_CT NOT IN (7,8) OR
    (A.SPEENTNAT_CT IN (7,8) AND
    A.BALSHRMTH_NF = A.VALPERMTH_NF))
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "#TACCSUP1 Error - Balance sheet and end of validity month must be equal"
  goto ErreurAno
end

SELECT COUNT(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 301
    select @MsgAnomalie = "Mois de date bilan et de fin de periode de validite doivent etre egales"
    select @NumMsgAnomalie = @NumMsgAnomalie + '301 '

    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf
end

/********************************************************
-- Check 3:
-- Quarterly local AE.
-- Generating new anomaly :
-- - Balance Sheet month must be a quarter's starting month ==> If SPEENTNAT_CF = 8 then we have to have BALSHRMTH_NF in (3,6,9,12)


*********************************************************/

/********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1


/********************************************************
-- Functional test of the Balance sheet month starting on a quarter
*********************************************************/
-- Insert working data into Temp table
INSERT INTO #TACCSUP1
SELECT A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM BTRAV..EST_ESID0801_TESTUTISUP A
WHERE
    A.SSD_CF = @P_SSD_CF AND
    A.LSTUPDUSR_CF = @P_USR_CF AND
    (A.SPEENTNAT_CT != 8 OR
    (A.SPEENTNAT_CT = 8 AND
    A.BALSHRMTH_NF IN (3, 6, 9, 12)))
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "#TACCSUP1 Error - Balance Sheet month must be a quarter month"
  goto ErreurAno
end

SELECT COUNT(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 302   
    select @MsgAnomalie = "Le mois bilan doit etre un mois de trimestre"
    select @NumMsgAnomalie = @NumMsgAnomalie + '302 '

    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf
end

/********************************************************
-- Check 4:
-- Checking the Ledger and nature consistency of the new local AE.
-- Generating new anomalies :
-- 1- This Ledger cannot load quaterly local AE ==> If LOCALAE_CT = 1 then we have to have SPEENTNAT_CT = 7
-- 2- This Ledger cannot load monthly local AE ==> If LOCALAE_CT = 2 then we have to have SPEENTNAT_CT = 8

*********************************************************/

/********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1


/********************************************************
-- Functional test of the Ledger authorised to load quaterly local AE
*********************************************************/
-- Insert working data into Temp table
INSERT INTO #TACCSUP1
SELECT A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM BTRAV..EST_ESID0801_TESTUTISUP A
WHERE
    A.SSD_CF = @P_SSD_CF AND
    A.LSTUPDUSR_CF = @P_USR_CF AND
    (A.SPEENTNAT_CT != 7 OR
    (A.SPEENTNAT_CT = 7 AND
    (1 =   (SELECT C.LOCALAE_CT
            FROM
                BTRT..TCONTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ACCESB_CF = C.ESB_CF AND
                    A.CTR_NF != NULL AND
                    A.END_NT != NULL AND
                    A.UWY_NF != NULL AND
                    A.UW_NT != NULL AND
                    A.CTR_NF = B.CTR_NF AND
                    A.END_NT = B.END_NT AND
                    A.UWY_NF = B.UWY_NF AND
                    A.UW_NT = B.UW_NT
            )
    OR
    1 =   (SELECT C.LOCALAE_CT
            FROM
                BFAC..TCONTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ACCESB_CF = C.ESB_CF AND
                    A.CTR_NF != NULL AND
                    A.END_NT != NULL AND
                    A.UWY_NF != NULL AND
                    A.UW_NT != NULL AND
                    A.CTR_NF = B.CTR_NF AND
                    A.END_NT = B.END_NT AND
                    A.UWY_NF = B.UWY_NF AND
                    A.UW_NT = B.UW_NT
            )
    OR
    1 =   (SELECT C.LOCALAE_CT
            FROM
                BRET..TRETCTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ESB_CF = C.ESB_CF AND
                    A.RETCTR_NF != NULL AND
                    A.RTY_NF != NULL AND
                    A.RETCTR_NF = B.RETCTR_NF AND
                    A.RTY_NF = B.RTY_NF
            )
    )))
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "#TACCSUP1 Error - This Ledger cannot load quaterly local AE"
  goto ErreurAno
end

SELECT COUNT(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 303
    select @MsgAnomalie = "Cet Etablissement ne peut pas charger d ES locales trimestrielles"
    select @NumMsgAnomalie = @NumMsgAnomalie + '303 '

    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf AND
            RETCTR_NF IN ( NULL, '' ) -- ASSUMED
    
    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf AND
            CTR_NF IN ( NULL, '' ) -- RETRO
end

/********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1


/********************************************************
-- Functional test of the Ledger authorised to load monthly local AE
*********************************************************/
-- Insert working data into Temp table
INSERT INTO #TACCSUP1
SELECT A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM BTRAV..EST_ESID0801_TESTUTISUP A
WHERE
    A.SSD_CF = @P_SSD_CF AND
    A.LSTUPDUSR_CF = @P_USR_CF AND
    (A.SPEENTNAT_CT != 8 OR
    (A.SPEENTNAT_CT = 8 AND
    (2 =   (SELECT C.LOCALAE_CT
            FROM
                BTRT..TCONTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ACCESB_CF = C.ESB_CF AND
                    A.CTR_NF != NULL AND
                    A.END_NT != NULL AND
                    A.UWY_NF != NULL AND
                    A.UW_NT != NULL AND
                    A.CTR_NF = B.CTR_NF AND
                    A.END_NT = B.END_NT AND
                    A.UWY_NF = B.UWY_NF AND
                    A.UW_NT = B.UW_NT
            )
    OR
    2 =   (SELECT C.LOCALAE_CT
            FROM
                BFAC..TCONTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ACCESB_CF = C.ESB_CF AND
                    A.CTR_NF != NULL AND
                    A.END_NT != NULL AND
                    A.UWY_NF != NULL AND
                    A.UW_NT != NULL AND
                    A.CTR_NF = B.CTR_NF AND
                    A.END_NT = B.END_NT AND
                    A.UWY_NF = B.UWY_NF AND
                    A.UW_NT = B.UW_NT
            )
    OR
    2 =   (SELECT C.LOCALAE_CT
            FROM
                BRET..TRETCTR B
                JOIN
                BREF..TESB C
                ON
                    B.SSD_CF = C.SSD_CF AND
                    B.ESB_CF = C.ESB_CF AND
                    A.RETCTR_NF != NULL AND
                    A.RTY_NF != NULL AND
                    A.RETCTR_NF = B.RETCTR_NF AND
                    A.RTY_NF = B.RTY_NF
            )
    )))
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "#TACCSUP1 Error - This Ledger cannot load monthly local AE"
  goto ErreurAno
end

SELECT COUNT(*) FROM #TACCSUP1

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 304
    select @MsgAnomalie = "Cet Etablissement ne peut pas charger d ES locales mensuelles"
    select @NumMsgAnomalie = @NumMsgAnomalie + '304 '

    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf AND
            RETCTR_NF IN ( NULL, '' ) -- ASSUMED
    
    INSERT
        INTO
            #TCTRANO_TMP
            (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT
            DISTINCT RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", @P_USR_CF, @ERROR_TYPE, NUMLINE_NT
        FROM BTRAV..EST_ESID0801_TESTUTISUP SUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT
                           FROM #TACCSUP1) AND
            SSD_CF = @p_ssd_cf AND
            LSTUPDUSR_CF = @p_usr_cf AND
            CTR_NF IN ( NULL, '' ) -- RETRO
end

/********************************************************
-- Check 5:
-- Checking the loading period:
-- - SPEENTNAT_CT = 7 (monthly AE):
| IFRS BALSHTMNTH | IFRS Quarter | Entered monthly AE|
|----------------------------|-------------------|---------------------------|
| 1                         | Q1                | 10, 11, 12           |
| 2                         | Q1                | 10, 11, 12, 1       |
| 3                         | Q1                | 10, 11, 12, 1, 2    |
| 4                         | Q2                | 1, 2, 3                |
| 5                         | Q2                | 1, 2, 3, 4            |
| 6                         | Q2                | 1, 2, 3, 4, 5         |
| 7                         | Q3                | 4, 5, 6                |
| 8                         | Q3                | 4, 5, 6, 7             |
| 9                         | Q3                | 4, 5, 6, 7, 8         |
| 10                        | Q4                | 7, 8, 9                |
| 11                        | Q4                | 7, 8, 9, 10           |
| 12                        | Q4                | 7, 8, 9, 10, 11      |

-- - SPEENTNAT_CT = 8 (Quaterly AE):
BALSHRMTH_NF = last month of the previous quarter

-- Generating the anomaly 19 and exit the procedure.
*********************************************************/

/********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1

/********************************************************
-- Functional test of the loading period on monthly AE
*********************************************************/
--[051] Last Account month
select @blcshtmth_nf = blcshtmth_nf+1 from bref..tcalend a
where account_d = (select max(account_d) from bref..tcalend b
                   where account_d < getdate())

if @blcshtmth_nf > 12
   select @blcshtmth_nf = 1

-- Insert working data into Temp table
INSERT
    INTO #TACCSUP1
    SELECT  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
                BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
                END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF,
                CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
                RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
                RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
                CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF,REVT_NF
    FROM BTRAV..EST_ESID0801_TESTUTISUP
    WHERE
        SSD_CF = @p_ssd_cf AND
        LSTUPDUSR_CF = @p_usr_cf AND
        (SPEENTNAT_CT != 7 OR
         (SPEENTNAT_CT = 7 AND
          (@blcshtmth_nf =  1 AND BALSHRMTH_NF IN (10, 11, 12)) OR
          (@blcshtmth_nf =  2 AND BALSHRMTH_NF IN (10, 11, 12, 1)) OR
          (@blcshtmth_nf =  3 AND BALSHRMTH_NF IN (10, 11, 12, 1, 2)) OR
          (@blcshtmth_nf =  4 AND BALSHRMTH_NF IN (1, 2, 3)) OR
          (@blcshtmth_nf =  5 AND BALSHRMTH_NF IN (1, 2, 3, 4)) OR
          (@blcshtmth_nf =  6 AND BALSHRMTH_NF IN (1, 2, 3 ,4, 5)) OR
          (@blcshtmth_nf =  7 AND BALSHRMTH_NF IN (4, 5, 6)) OR
          (@blcshtmth_nf =  8 AND BALSHRMTH_NF IN (4, 5, 6, 7)) OR
          (@blcshtmth_nf =  9 AND BALSHRMTH_NF IN (4, 5, 6, 7, 8)) OR
          (@blcshtmth_nf = 10 AND BALSHRMTH_NF IN (7, 8, 9)) OR
          (@blcshtmth_nf = 11 AND BALSHRMTH_NF IN (7, 8, 9, 10)) OR
          (@blcshtmth_nf = 12 AND BALSHRMTH_NF IN (7, 8, 9 ,10, 11))
         )
        )
         
select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = '#TACCSUP1 Error - Wrong loading period on monthly AE'
  goto ErreurAno
    end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 305
    select @MsgAnomalie = 'Anomalie(s) liee(s) au libelle d''inventaire'
    select @NumMsgAnomalie = @NumMsgAnomalie + '305 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM BTRAV..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      AND SSD_CF = @p_ssd_cf
      AND LSTUPDUSR_CF = @p_usr_cf
  end
  
  /********************************************************
--- Purge of #TACCSUP1 before reuse
*********************************************************/
DELETE #TACCSUP1

/********************************************************
-- Functional test of the loading period on quarterly AE
*********************************************************/

--[051] Last quaterly account month
select @balshtmth_nf = balshtmth_nf from best..treqjob a
where dbclo_d = (select max(dbclo_d) from best..treqjob b
                 where reqcod_ct = 'B'
                 and   site_cf = @site_cf
                 and   launch_d is not null)
and reqcod_ct = 'B'
and site_cf = @site_cf 

-- Insert working data into Temp table
INSERT
    INTO #TACCSUP1
    SELECT  TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
                BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
                END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF  , CLM_NF,
                CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
                RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
                RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
                CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF,REVT_NF
    FROM BTRAV..EST_ESID0801_TESTUTISUP
    WHERE
        SSD_CF = @p_ssd_cf AND
        LSTUPDUSR_CF = @p_usr_cf AND
        (SPEENTNAT_CT != 8 OR (SPEENTNAT_CT = 8 AND BALSHRMTH_NF = @balshtmth_nf))
         
select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = '#TACCSUP1 Error - Wrong loading period on quarterly AE'
  goto ErreurAno
    end

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 306
    select @MsgAnomalie = 'Anomalie(s) liee(s) au libelle d''inventaire'
    select @NumMsgAnomalie = @NumMsgAnomalie + '306 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM BTRAV..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      AND SSD_CF = @p_ssd_cf
      AND LSTUPDUSR_CF = @p_usr_cf
  end
  
  
/****************** Modification 50 END ******************/

-- Purge de la table #TACCSUP1 avant réutilisation
-- ------------------------------------------------
DELETE #TACCSUP1

-------------------------------------------------------------------------------------------------------------------
-- ERROR 21033 The retro event does not correspond to the Retro single Claim  						  -- MODIF 30
-------------------------------------------------------------------------------------------------------------------
-- select "21033", Datediff(MS,@astartTime ,getDate())
--subsidiary event
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT      --Mod31
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
  and (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")     --Mod31
  and A.REVT_NF = CAST(TCLM.EVT_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF         --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to retro subsidiary events and claims"
  goto ErreurAno
end


--group events
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT      --Mod31
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
  and (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")           --Mod31
  and A.REVT_NF = "G" + CAST(EVT.GEV_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF        --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to retro group events and claims"
  goto ErreurAno
end

-- if the claim is null or the claim is null, there should be no error
INSERT into #TACCSUP1
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from BTRAV..EST_ESID0801_TESTUTISUP A
 WHERE A.SSD_CF=@p_ssd_cf
    AND A.LSTUPDUSR_CF=@p_usr_cf
AND (A.REVT_NF is null OR A.RCL_NF is null OR A.REVT_NF is null OR  A.REVT_NF = "")


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to retro events and claims"
  goto ErreurAno
end


-- [048]
-------------------------------------------------------------------------------------------------------------------
-- ERROR 107 is there Estimate / Closing Impact
-------------------------------------------------------------------------------------------------------------------
-- if LCKCLO_B = 0 then there is Estimate / Closing Impact --> it's an error

select @nbligne_tempaccsup = count(*)
 from BTRAV..EST_ESID0801_TESTUTISUP A,
      BRET..TPLACEMT B
 WHERE A.SSD_CF=@p_ssd_cf
   AND A.LSTUPDUSR_CF=@p_usr_cf
   AND A.RETCTR_NF=B.RETCTR_NF
   AND A.RTY_NF=B.RTY_NF
   AND A.PLC_NT=B.PLC_NT
   AND B.HIS_B=0
   AND B.LCKCLO_B=0

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Comptage sur closing impact code 107"
  goto ErreurAno
end

if ( @nbligne_tempaccsup > 0 )
begin
  select @error_type = 107
  select @MsgAnomalie = "Anomalie(s) liee(s) a l'impact closing"
  select @NumMsgAnomalie = @NumMsgAnomalie + '107 '

  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
  SELECT DISTINCT A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF, 1, A.SSD_CF, "A", @p_usr_cf, @error_type, A.NUMLINE_NT
  from BTRAV..EST_ESID0801_TESTUTISUP A,
       BRET..TPLACEMT B
  WHERE A.SSD_CF=@p_ssd_cf
    AND A.LSTUPDUSR_CF=@p_usr_cf
    AND A.RETCTR_NF=B.RETCTR_NF
    AND A.RTY_NF=B.RTY_NF
    AND A.PLC_NT=B.PLC_NT
    AND B.HIS_B=0
    AND B.LCKCLO_B=0

  select @erreur = @@error
  if @erreur != 0
  begin
    select @MsgAnomalie = "Erreur insertion dans #TCTRANO sur closing impact code 107"
    goto ErreurAno
  end
end

/* Compare line number and EST_ESID0801_TESTUTISUP and #TACCSUP1 */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP1
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
  select @error_type = 21033
    select @MsgAnomalie = "Anomalie(s) liee(s) aux  postes comptables"
    select @NumMsgAnomalie = @NumMsgAnomalie + '21033 '

    INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
    FROM btrav..EST_ESID0801_TESTUTISUP
    WHERE TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP1)
      and SSD_CF       = @p_ssd_cf
      and LSTUPDUSR_CF = @p_usr_cf
  end


-- -----------------------------------------------------------------------------
-- MOD001 - GENERATION & CONTROLE DES ERREURS de NIVEAU 1
-- -----------------------------------------------------------------------------
select @nbligne_tctrano = 0
select @nbligne_tctrano = count(*) FROM #TCTRANO_TMP
if ( @nbligne_tctrano = Null ) Select @nbligne_tctrano = 0
if ( @nbligne_tctrano > 0 )
  begin
  goto InsertAno --MOD035 Insert TCTRANO anomalies
  end

-- A PARTIR DE CE NIVEAU DU CODE, LA PROC TRAVAILLE SYSTEMATIQUEMENT A PARTIR DES TABLES TEMPO
-- ET PLUS A PARTIR DE btrav..EST_ESID0801_TESTUTISUP, POUR DES QUESTIONS DE RAPIDITE
-- O.GIRAUX

/*-----------------------------------------------------------------------------*/
/*               CHECKING OF ACCOUNTING YEAR ACCEPTANCE                        */
/*                      if problem => anomaly 21                                           */
/*-----------------------------------------------------------------------------*/
-- TRT
INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
       A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
       A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
       A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
       A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
       A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
       A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT,A.EVT_NF, A.REVT_NF -- MOD005 26/04/2005 - MOD007
FROM #TACCSUP1 A,
     btrt..TSECTION B                                 --[019] ajout jointure TSECTION
where A.SSD_CF       = @p_ssd_cf
  and A.LSTUPDUSR_CF = @p_usr_cf
  and A.CTR_NF       = B.CTR_NF                       --[019]
  and A.END_NT       = B.END_NT                       --[019]
  and A.SEC_NF       = B.SEC_NF                       --[019]
  and A.UWY_NF       = B.UWY_NF                       --[019]
  and A.UW_NT        = B.UW_NT                        --[019]
  and A.SSD_CF       = B.SSD_CF                       --[019]
  and (
        ( A.CTR_NF = NULL OR A.CTR_NF = '' )
      OR
        ( A.CTR_NF != NULL  and ( A.ACY_NF >= A.UWY_NF or B.LOB_CF not in ( '30', '31'))     --[019]
        )
      )

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Anomalie(s) liee(s) a l''annee de compte acceptation'
  goto ErreurAno
    end

-- FAC
INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
       A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
       A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
       A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
       A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
       A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
       A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT,A.EVT_NF, A.REVT_NF -- MOD005 26/04/2005 - MOD007
FROM #TACCSUP1 A,
     bfac..TSECTION B                           --[019] ajout jointure TSECTION
where A.SSD_CF       = @p_ssd_cf
  and A.LSTUPDUSR_CF = @p_usr_cf
  and A.CTR_NF       = B.CTR_NF                       --[019]
  and A.END_NT       = B.END_NT                       --[019]
  and A.SEC_NF       = B.SEC_NF                       --[019]
  and A.UWY_NF       = B.UWY_NF                       --[019]
  and A.UW_NT        = B.UW_NT                        --[019]
  and A.SSD_CF       = B.SSD_CF                       --[019]
  and (
        ( A.CTR_NF = NULL OR A.CTR_NF = '' )
       OR
        ( A.CTR_NF != NULL  and ( A.ACY_NF >= A.UWY_NF  or B.LOB_CF not in ( '30', '31' ) )        --[019]
        )                                                                                          --[019]
      )

select @erreur = @@error
if @erreur != 0
begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Anomalie(s) liee(s) a l''annee de compte acceptation'
  goto ErreurAno
end

-- we are in the checking of account year, but we have also to insert all retrocession contracts
-- (are not due to the joining with table acceptance section )
-- otherwise, we will have a shift by counting the number of lines

INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT,A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A
where
    (A.CTR_NF = NULL OR A.CTR_NF = '')  -- ko contract accept.
and A.RETCTR_NF   != NULL               -- ok contract retro
and A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Anomalie(s) liee(s) a l''annee de compte acceptation'
  goto ErreurAno
end

-- compare the number of lines between EST_ESID0801_TESTUTISUP and #TACCSUP2
-- generation of an anomaly and exit of the procedure, anomaly 21
-- -------------------------------------------------------------
select @nbligne_tempaccsup = count(*) FROM #TACCSUP2
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
      select @error_type     = 21
        select @MsgAnomalie    = 'Anomalie(s) liee(s) a l''annee de compte acceptation'
        select @NumMsgAnomalie = @NumMsgAnomalie + '21 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
        and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
        and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
  end



-- Purge de la table #TACCSUP2 avant réutilisation
-- ------------------------------------------------
DELETE #TACCSUP2


/*-----------------------------------------------------------------------------*/
/*                checking of year retro accounting year                       */
/*                      if problem => anomaly 22                               */
/*-----------------------------------------------------------------------------*/
INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
       A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
       A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
       A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
       A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
       A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
       A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF -- MOD005 26/04/2005 - MOD007
FROM #TACCSUP1 A,
     bret..TRETSEC B                              --[019] ajout jointure TRETSEC
where
      A.SSD_CF       = @p_ssd_cf
  and A.LSTUPDUSR_CF = @p_usr_cf
  and A.RETCTR_NF    = B.RETCTR_NF                 --[019]
  and A.RETSEC_NF    = B.RETSEC_NF                 --[019]
  and A.RTY_NF       = B.RTY_NF                    --[019]
  and A.SSD_CF       = B.SSD_CF                    --[019]
  and (
        ( A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
        OR
        ( A.RETCTR_NF != NULL  and ( A.RETACY_NF >= A.RTY_NF or B.LOB_CF not in ( '30', '31' )))       --[019]
      )

select @erreur = @@error
if @erreur != 0
begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Anomalie(s) liee(s) à l''année de compte rétrocession'
    goto ErreurAno
end

-- We are in the checking of account year, but we have also to insert all acceptance contracts
-- (are not due to the joining with tables section of the rétrocession)
-- otherwise, we will have a shift by counting the number of lines

INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A
where
    (A.RETCTR_NF   = NULL OR A.RETCTR_NF = '')  -- ok contrat rétro.
and A.CTR_NF      != NULL                       -- ko contrat accept.
and A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Anomalie(s) liee(s) a l''annee de compte rétrocession'
  goto ErreurAno
end

/* compare the number of lines between EST_ESID0801_TESTUTISUP and #TACCSUP2 */
/* the generation of an anomaly and  exit of the procedure, anomaly 22   */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP2
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0

if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
      select @error_type = 22
        select @MsgAnomalie = "Anomalie(s) liee(s) a l'annee de compte retrocession"
        select @NumMsgAnomalie = @NumMsgAnomalie + '22 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
        and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
        and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
  end

DELETE #TACCSUP2


-- -----------------------------------------------------------------------------
--           CHECKING ABOUT STATUS OF SECTION TREATIES AND FACULTATIVE
--                    if problem ===> anomaly 48
-- -----------------------------------------------------------------------------


/* FACS */
INSERT into #TACCSUP2
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A,
        bfac..TSECTION B
where
    A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf
and A.CTR_NF      != NULL
and A.CTR_NF       = B.CTR_NF
and A.UWY_NF       = B.UWY_NF
and A.END_NT       = B.END_NT
and A.SEC_NF       = B.SEC_NF
and A.UW_NT        = B.UW_NT
and A.SSD_CF       = B.SSD_CF
and B.SECSTS_CT in (16, 17, 18, 19) -- "Definitive", "Renewed", "Expired", "canceled"     MOD016  MOD39(removed Accepted section status)
UNION
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF, --109065 MOD073
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A,
       BFAC..TSECIFRS TSECIFRS B
where
    A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf
and A.CTR_NF      != NULL
and A.CTR_NF       = B.CTR_NF
and A.UWY_NF       = B.UWY_NF
and A.END_NT       = B.END_NT
and A.UW_NT        = B.UW_NT
and B.FRCIFRSBTCH_NT = 1

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - CONTROLE DU STATUT DE LA SECTION'
  goto ErreurAno
end


/* TRAITES */
INSERT into #TACCSUP2
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A,
        btrt..TSECTION B
where
    A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf
and A.CTR_NF      != NULL
and A.CTR_NF       = B.CTR_NF
and A.UWY_NF       = B.UWY_NF
and A.END_NT       = B.END_NT
and A.SEC_NF       = B.SEC_NF
and A.UW_NT        = B.UW_NT
and A.SSD_CF       = B.SSD_CF
and B.SECSTS_CT    in (14, 16, 17, 18, 19) -- "Accepted", "Definitive", "Renewed", "Expired", " canceled "     MOD016

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP2 - CONTROLE DU STATUT DE LA SECTION"
  goto ErreurAno
end

-- We are in the checking status of the sections, and so we  insert all  pure retrocession
-- ,otherwise we will have a shift by counting the number of lines

INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A
where
    (A.CTR_NF      = NULL OR A.CTR_NF = '')
and A.RETCTR_NF   != NULL
and A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - CONTROLE DU STATUT DE LA SECTION'
  goto ErreurAno
end

--  compare the number of lines between EST_ESID0801_TESTUTISUP and #TACCSUP2
-- generation of an anomaly===> anomaly 48
-- -------------------------------------------------------------

select @nbligne_tempaccsup = count(*) FROM #TACCSUP2
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
begin
-- generation of an anomaly and exit of the procedure
  SELECT @error_type     = 48
  select @MsgAnomalie    = 'Etat section incorrect'
  select @NumMsgAnomalie = @NumMsgAnomalie + '48 '

  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
  SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, 'A', @p_usr_cf, @error_type, NUMLINE_NT
  FROM btrav..EST_ESID0801_TESTUTISUP
  WHERE
      TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
  and SSD_CF       = @p_ssd_cf
  and LSTUPDUSR_CF = @p_usr_cf
end

-- Purge de  #TACCSUP2 avant réutilisation
-- ---------------------------------------
DELETE #TACCSUP2
-- -----------------------------------------------------------------------------
--            OTHER CHECKING IN  ACCOUNTING TRANSACTION CODE  / LOB
--             we do this after the checks for sections
--                      if problem ===> anomaly 18
--                  We verify only when we have entered:
--            - a transaction code of 1xxx or 2xxx type: we are on 1 "lob" no life
--            -a transaction code of 3xxx  or 4xxx type: we are on 1 "lob" life
-- -----------------------------------------------------------------------------

-- case of pure acceptance and "fac" business
-- ---------------------------------------------
select ESB_CF,* from #TACCSUP2
INSERT into #TACCSUP2
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF    -- MOD005 26/04/2005 - MOD007
 FROM #TACCSUP1 A, bfac..TSECTION B
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
    and A.CTR_NF!=NULL
    and A.RETCTR_NF in(NULL,'')
    and EXISTS(Select 1 from BFAC..TCONTR TC where
    TC.CTR_NF=A.CTR_NF
    and TC.END_NT=A.END_NT
    and TC.UWY_NF=A.UWY_NF
    and TC.UW_NT=A.UW_NT )
    and A.CTR_NF=B.CTR_NF
    and A.END_NT=B.END_NT
    and A.SEC_NF=B.SEC_NF
    and A.UWY_NF=B.UWY_NF
    and A.UW_NT=B.UW_NT
    and A.SSD_CF=B.SSD_CF
    and A.TRNCOD_CF like case when B.LOB_CF='30' and A.SPEENTNAT_CT in(4,5,6) then '3%G' --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix)
                              when B.LOB_CF='31' and A.SPEENTNAT_CT in(4,5,6) then '1%G' --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix) -- modif 24 pas de poste comptable pour les LOB vie EBS pour le moment
                              when B.LOB_CF='30' and A.SPEENTNAT_CT in(1,2,3,7,8,9,10,11) then '3%' --[053] Local AE loading - Incoherence transaction code/lob 
                              when B.LOB_CF!='30' then '1%'
                         end
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Cas de l''acceptation pure et affaire fac'
  goto ErreurAno
end

-- case of pure acceptance and treaty business
-- --------------------------------------------
INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF     -- MOD005 26/04/2005 - MOD007
 FROM #TACCSUP1 A, BTRT..TSECTION B
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
    and A.CTR_NF!=NULL
    and A.RETCTR_NF in(NULL,'')
    and EXISTS(Select 1 from BTRT..TCONTR TC where TC.CTR_NF=A.CTR_NF and TC.END_NT=A.END_NT and TC.UWY_NF=A.UWY_NF and TC.UW_NT=A.UW_NT )
    and A.CTR_NF=B.CTR_NF
    and A.END_NT=B.END_NT
    and A.SEC_NF=B.SEC_NF
    and A.UWY_NF=B.UWY_NF
    and A.UW_NT=B.UW_NT
    and A.SSD_CF=B.SSD_CF
    and A.TRNCOD_CF like case when B.LOB_CF='30' and A.SPEENTNAT_CT in(4,5,6) then '3%G' --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix) --Modification 32
    when B.LOB_CF='31' and A.SPEENTNAT_CT in(4,5,6) then '1%G' --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix) -- modif 24 pas de poste comptable pour les LOB vie EBS pour le moment --Modification 32
    when B.LOB_CF='30' and A.SPEENTNAT_CT in(1,2,3,7,8,9,10,11) then '3%' --Modification 32 [053] Local AE loading - Incoherence transaction code/lob
    when B.LOB_CF!='30' then '1%'--Modification 32
    end
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Cas de l''acceptation pure et affaire trt '
  goto ErreurAno
end


-- case where the retro contract is inquired
-- even if we have acceptance, the file contains a transaction code of retrocession type.
INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF     -- MOD005 26/04/2005 - MOD007
 FROM #TACCSUP1 A, bret..TRETSEC B
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
    and A.RETCTR_NF!=NULL
    and A.RETCTR_NF=B.RETCTR_NF
    and A.RETSEC_NF=B.RETSEC_NF
    and A.RTY_NF=B.RTY_NF
    and A.SSD_CF=B.SSD_CF
    and A.TRNCOD_CF like case when B.LOB_CF='30' and A.SPEENTNAT_CT in(4,5,6) then '4%G' --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix)
                              when B.LOB_CF='31' and A.SPEENTNAT_CT in(4,5,6) then '2%G' --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix) -- modif 24 pas de poste comptable pour les LOB vie EBS pour le moment
                              when B.LOB_CF='30' and A.SPEENTNAT_CT in(1,2,3,7,8,9,10,11) then '4%'  --[025] [053] Local AE loading - Incoherence transaction code/lob
                              when B.LOB_CF!='30' then '2%'  --[025]
                         end
select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Cas où le contrat rétro est renseignét'
  goto ErreurAno
end

-- compare the number of lines between EST_ESID0801_TESTUTISUP and #TACCSUP2
-- generation of an anomaly and exit of the procedure at the end of the checking , anomaly 18
select @nbligne_tempaccsup = count(*) FROM #TACCSUP2
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
      select @error_type = 18
        select @MsgAnomalie = 'Anomalie(s) liee(s) aux  postes comptables'
        select @NumMsgAnomalie = @NumMsgAnomalie + '18 '

/*        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
        and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
        and	LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006       */

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            CTR_NF != NULL and ( RETCTR_NF = NULL OR RETCTR_NF = "")
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
        and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
        and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'A', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            RETCTR_NF   != NULL
        and TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
        and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
        and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
  end

/* Adaptive Server has expanded all '*' elements in the following statement */ select '#TACCSUP1', #TACCSUP1.TRN_NT, #TACCSUP1.ACCTYP_NF, #TACCSUP1.SSD_CF, #TACCSUP1.ESB_CF, #TACCSUP1.ENTPERY_NF, #TACCSUP1.ENTPERMTH_NF, #TACCSUP1.BALSHEY_NF, #TACCSUP1.BALSHRMTH_NF, #TACCSUP1.BALSHRDAY_NF, #TACCSUP1.VALPERY_NF, #TACCSUP1.VALPERMTH_NF, #TACCSUP1.TRNCOD_CF, #TACCSUP1.DBLTRNCOD_CF, #TACCSUP1.RETAUTGEN_B, #TACCSUP1.CTR_NF, #TACCSUP1.END_NT, #TACCSUP1.SEC_NF, #TACCSUP1.UWY_NF, #TACCSUP1.UW_NT, #TACCSUP1.OCCYEA_NF, #TACCSUP1.ACY_NF, #TACCSUP1.SCOSTRMTH_NF, #TACCSUP1.SCOENDMTH_NF, #TACCSUP1.CLM_NF, #TACCSUP1.CUR_CF, #TACCSUP1.AMT_M, #TACCSUP1.CED_NF, #TACCSUP1.BRK_NF, #TACCSUP1.GEMPRMPAY_NF, #TACCSUP1.GANPAYORD_NT, #TACCSUP1.RETCTR_NF, #TACCSUP1.RETEND_NT, #TACCSUP1.RETSEC_NF, #TACCSUP1.RTY_NF, #TACCSUP1.RETUW_NT, #TACCSUP1.PLC_NT, #TACCSUP1.RETOCCYEA_NF, #TACCSUP1.RETACY_NF, #TACCSUP1.RETSCOSTRMTH_NF, #TACCSUP1.RETSCOENDMTH_NF, #TACCSUP1.RCL_NF, #TACCSUP1.RETCUR_CF, #TACCSUP1.RETAMT_M, #TACCSUP1.RTO_NF, #TACCSUP1.INT_NF, #TACCSUP1.RETPAY_NF, #TACCSUP1.RETKEY_CF, #TACCSUP1.ACCTRN_NT, #TACCSUP1.COMMAC_LL, #TACCSUP1.CRE_D, #TACCSUP1.CREUSR_CF, #TACCSUP1.LSTUPD_D, #TACCSUP1.LSTUPDUSR_CF, #TACCSUP1.SPEENTTYP_CF, #TACCSUP1.SPEENTNAT_CT,#TACCSUP1.EVT_NF, #TACCSUP1.REVT_NF from #TACCSUP1      -- vde
/* Adaptive Server has expanded all '*' elements in the following statement */ select '#TACCSUP2', #TACCSUP2.TRN_NT, #TACCSUP2.ACCTYP_NF, #TACCSUP2.SSD_CF, #TACCSUP2.ESB_CF, #TACCSUP2.ENTPERY_NF, #TACCSUP2.ENTPERMTH_NF, #TACCSUP2.BALSHEY_NF, #TACCSUP2.BALSHRMTH_NF, #TACCSUP2.BALSHRDAY_NF, #TACCSUP2.VALPERY_NF, #TACCSUP2.VALPERMTH_NF, #TACCSUP2.TRNCOD_CF, #TACCSUP2.DBLTRNCOD_CF, #TACCSUP2.RETAUTGEN_B, #TACCSUP2.CTR_NF, #TACCSUP2.END_NT, #TACCSUP2.SEC_NF, #TACCSUP2.UWY_NF, #TACCSUP2.UW_NT, #TACCSUP2.OCCYEA_NF, #TACCSUP2.ACY_NF, #TACCSUP2.SCOSTRMTH_NF, #TACCSUP2.SCOENDMTH_NF, #TACCSUP2.CLM_NF, #TACCSUP2.CUR_CF, #TACCSUP2.AMT_M, #TACCSUP2.CED_NF, #TACCSUP2.BRK_NF, #TACCSUP2.GEMPRMPAY_NF, #TACCSUP2.GANPAYORD_NT, #TACCSUP2.RETCTR_NF, #TACCSUP2.RETEND_NT, #TACCSUP2.RETSEC_NF, #TACCSUP2.RTY_NF, #TACCSUP2.RETUW_NT, #TACCSUP2.PLC_NT, #TACCSUP2.RETOCCYEA_NF, #TACCSUP2.RETACY_NF, #TACCSUP2.RETSCOSTRMTH_NF, #TACCSUP2.RETSCOENDMTH_NF, #TACCSUP2.RCL_NF, #TACCSUP2.RETCUR_CF, #TACCSUP2.RETAMT_M, #TACCSUP2.RTO_NF, #TACCSUP2.INT_NF, #TACCSUP2.RETPAY_NF, #TACCSUP2.RETKEY_CF, #TACCSUP2.ACCTRN_NT, #TACCSUP2.COMMAC_LL, #TACCSUP2.CRE_D, #TACCSUP2.CREUSR_CF, #TACCSUP2.LSTUPD_D, #TACCSUP2.LSTUPDUSR_CF, #TACCSUP2.SPEENTTYP_CF, #TACCSUP2.SPEENTNAT_CT                      from #TACCSUP2      -- vde


-- [18612] Commenting to continue the checking
--/*-----------------------------------------------------------------------------*/
--/* MOD001 - GENERATION & CONTROLE DES ERREURS de NIVEAU 1                      */
--/*-----------------------------------------------------------------------------*/
--select @nbligne_tctrano = 0
--select @nbligne_tctrano = count(*) FROM #TCTRANO_TMP
--if ( @nbligne_tctrano = Null ) Select @nbligne_tctrano = 0
--if ( @nbligne_tctrano > 0 )
--	begin
--	goto ErreurAno
--	end


-- Purge de la table #TACCSUP2 avant réutilisation
-- -----------------------------------------------
DELETE #TACCSUP2

/*-----------------------------------------------------------------------------*/
/*                CHECKING OF PLACEMENTS                                       */
/*              if any problem => anomaly 23                                   */
/*-----------------------------------------------------------------------------*/

/* A checking is already done at the application level to have a value of placement
only when the retro contract is inquired */

INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF     -- MOD005 26/04/2005 - MOD007
FROM  #TACCSUP1 A,
        bret..TPLACEMT B
where
        A.PLC_NT != NULL
  and A.RETCTR_NF = B.RETCTR_NF
  and A.RTY_NF = B.RTY_NF
  and A.PLC_NT = B.PLC_NT
  and B.HIS_B = 0
  and B.ACCPLC_B = 1
  and (B.PLCSTS_CT = 16 or B.PLCSTS_CT = 19)


-- we are in the checking of placement number, we have to insert everything
-- which is without placement otherwise, we will have a shift by counting the number of lines

INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF       -- MOD005 26/04/2005 - MOD007
FROM  #TACCSUP1 A
where
  A.PLC_NT = NULL OR A.PLC_NT = 0

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP2 - CONTROLE DES PLACEMENTS '
  goto ErreurAno
    end

/* compare the number of lines between EST_ESID0801_TESTUTISUP et #TACCSUP1 */
/* generation of an anomaly  and exit of the procedure, anomaly 23   */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP2
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin -- ##
      SELECT @error_type = 23
        select @MsgAnomalie = 'certain(s) placement(s) ne sont pas référencés dans la base rétrocession'
        select @NumMsgAnomalie = @NumMsgAnomalie + '23 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'A', @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
        and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
        and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
  end


-- Purge de la table #TACCSUP2 avant réutilisation
-- -----------------------------------------------
DELETE #TACCSUP2

/*-----------------------------------------------------------------------------*/
/*                CHECKING OF CANCELED PLACEMENTS                              */
/*              if any problem => anomaly 30020                                */
/*-----------------------------------------------------------------------------*/
-- [064] --
INSERT INTO 
	#TACCSUP2
SELECT 
	A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  
	#TACCSUP1 A, BRET..TPLACEMT tpla
WHERE
 	A.SSD_CF = @p_ssd_cf AND 
	A.LSTUPDUSR_CF = @p_usr_cf AND
	(
		(A.RETCTR_NF != NULL AND 
		A.RETCTR_NF = tpla.RETCTR_NF AND 
		A.PLC_NT = tpla.PLC_NT AND 
		A.SSD_CF = tpla.SSD_CF AND
		A.RTY_NF = tpla.RTY_NF AND 
		not (tpla.PLCSTS_CT = 19 AND tpla.RETSIGSHA_R = 0) AND
		tpla.HIS_B = 0 AND 
		tpla.ACCPLC_B = 1)
	)
-- [062] --
UNION
SELECT 
	A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  
	#TACCSUP1 A
WHERE
 	A.SSD_CF = @p_ssd_cf AND 
	A.LSTUPDUSR_CF = @p_usr_cf AND
    A.PLC_NT is NULL 
		AND EXISTS(
        select 1 from BRET..TPLACEMT tpla where tpla.RETCTR_NF = A.RETCTR_NF AND tpla.RTY_NF = A.RTY_NF AND
        (tpla.PLCSTS_CT <> 19 OR
        tpla.RETSIGSHA_R <> 0 )AND
        tpla.HIS_B = 0 AND 
        tpla.ACCPLC_B = 1 )
        OR 
		(A.RETCTR_NF = NULL OR A.RETCTR_NF = '')
		
select @erreur = @@error
if @erreur != 0
	begin
  	select @MsgAnomalie = "Erreur Génération TACCSUP2 - CONTROLE RÉTRO SUR PLACEMENTS RÉSILIÉS"
  	goto ErreurAno
  end

/* compare the number of lines between  EST_ESID0801_TESTUTISUP and #TACCSUP2 */
/* generation of an anomaly and exit of the procedure, anomaly 25   */
/* ------------------------------------------------------------- */
SELECT @nbligne_tempaccsup = COUNT(*) FROM #TACCSUP2
if (@nbligne_tempaccsup = NULL) SELECT @nbligne_tempaccsup = 0
if (@nbligne_tempaccsup != @nbligne_testutisup)
  begin
		SELECT @error_type = 30020
    SELECT @MsgAnomalie = 'The placement is disabled for estimates.'
    SELECT @NumMsgAnomalie = @NumMsgAnomalie + '30020 '

    INSERT INTO 
			#TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT DISTINCT 
			RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, 'A', @p_usr_cf,  @error_type, NUMLINE_NT
    FROM 
			BTRAV..EST_ESID0801_TESTUTISUP
    WHERE
      TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2) and 
			SSD_CF = @p_ssd_cf and 
			LSTUPDUSR_CF = @p_usr_cf
  end

-- Purge de  #TACCSUP2 avant réutilisation
-- ---------------------------------------
DELETE #TACCSUP2



/*-----------------------------------------------------------------------------*/
/*                checking acceptance currencies                               */
/*                     if problem anomaly 24                                   */
/*-----------------------------------------------------------------------------*/


-- access to the table BREF..TCURQUOT ( acceptance business inquired) to check CUR_CF
-- ----------------------------------------------------------------------------------------

INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF  -- MOD005 26/04/2005 - MOD007
FROM  #TACCSUP1 A
where
    (A.CTR_NF != NULL
and exists( select 1 FROM BREF..TCURQUOT B
                   where  A.CUR_CF = B.CUR_CF
                   and  A.SSD_CF = B.SSD_CF )
and not exists( select 1 FROM BREF..TEUROCUR C
                         where   A.CUR_CF = C.CUR_CF
                         and     A.CUR_CF != 'EUR'  )
   )
OR   ( A.CTR_NF = NULL OR A.CTR_NF = '')

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = 'Erreur Génération TACCSUP2 - CONTROLE DES DEVISES ACCEPTATION'
  goto ErreurAno
    end

/* compare the number of lines between EST_ESID0801_TESTUTISUP and #TACCSUP2 */
/* generation of an anomaly and exit of the procedure, anomaly 24   */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP2
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin
      SELECT @error_type = 24
        select @MsgAnomalie = 'Devise acceptation incorrecte'
        select @NumMsgAnomalie = @NumMsgAnomalie + '24 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, 'A', @p_usr_cf, @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
        and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
        and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
  end

-- Purge de la table #TACCSUP2 avant réutilisation
-- -----------------------------------------------
DELETE #TACCSUP2

/*-----------------------------------------------------------------------------*/
/*                checking for the retro currencies                                   */
/*                      if problem anomaly 25                                           */
/*-----------------------------------------------------------------------------*/

INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF       -- MOD005 26/04/2005 - MOD007
FROM  #TACCSUP1 A
where
    ( A.RETCTR_NF != NULL
and exists( select 1 FROM BREF..TCURQUOT B
                   where  A.RETCUR_CF = B.CUR_CF
                   and  A.SSD_CF = B.SSD_CF )
and not exists(select 1 FROM BREF..TEUROCUR C
                        where   A.RETCUR_CF = C.CUR_CF
                        and     A.RETCUR_CF != 'EUR'  )
   )
OR ( A.RETCTR_NF = NULL OR A.RETCTR_NF = "")

select @erreur = @@error
if @erreur != 0
    begin
    select @MsgAnomalie = "Erreur Génération TACCSUP2 - CONTROLE DES DEVISES RETRO "
  goto ErreurAno
    end

/* compare the number of lines between  EST_ESID0801_TESTUTISUP and #TACCSUP2 */
/* generation of an anomaly and exit of the procedure, anomaly 25   */
/* ------------------------------------------------------------- */

select @nbligne_tempaccsup = count(*) FROM #TACCSUP2
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
  begin -- ##
      SELECT @error_type = 25
        select @MsgAnomalie = "Devise rétro incorrecte"
        select @NumMsgAnomalie = @NumMsgAnomalie + '25 '

        INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
        SELECT DISTINCT RETCTR_NF, RETEND_NT, RETSEC_NF, 1, SSD_CF, "A", @p_usr_cf,  @error_type, NUMLINE_NT
        FROM btrav..EST_ESID0801_TESTUTISUP
        WHERE
            TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
        and SSD_CF       = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
        and LSTUPDUSR_CF = @p_usr_cf              -- MOD011 MDJ 21/02/2006
  end


-- Purge de  #TACCSUP2 avant réutilisation
-- ---------------------------------------
DELETE #TACCSUP2

/*-----------------------------------------------------------------------------*/
/*                    checking to know if the business acceptance has          */
/*                     the status "COMPLETED ACCOUNTING "                         */
/*                             if problem anomaly 47                                   */
/*-----------------------------------------------------------------------------*/


/* FACS */
INSERT into #TACCSUP2
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A,
       bfac..TSECTION B
where
    A.SSD_CF       = @p_ssd_cf
and A.LSTUPDUSR_CF = @p_usr_cf
and A.CTR_NF      != NULL
and A.CTR_NF       = B.CTR_NF
and A.END_NT       = B.END_NT
and A.UWY_NF       = B.UWY_NF
and A.UW_NT        = B.UW_NT
and A.SEC_NF = B.SEC_NF
and B.SECACCSTS_CT != 9  --we exclude contracts "completed accounting"(MOD 43)

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Cas de l''affaire FAC terminée comptable'
  goto ErreurAno
end


/* TRAITES */
INSERT into #TACCSUP2
select  A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF, A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A,
       btrt..TSECTION B
where
    A.SSD_CF        = @p_ssd_cf
and A.LSTUPDUSR_CF  = @p_usr_cf
and A.CTR_NF       != NULL
and A.CTR_NF        = B.CTR_NF
and A.END_NT        = B.END_NT
and A.UWY_NF        = B.UWY_NF
and A.UW_NT         = B.UW_NT
and A.SEC_NF = B.SEC_NF
and B.SECACCSTS_CT != 9  -- we exclude contracts "completed accounting"

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Cas de l''affaire terminée comptable'
  goto ErreurAno
end

-- We are in the checking of status "TERMINE COMPTABLE",then we  insert everything
-- which is without pure retro otherwise , we will have a shift by counting the number of lines

INSERT into #TACCSUP2
select A.TRN_NT, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
FROM  #TACCSUP1 A
where
    (A.CTR_NF = NULL OR A.CTR_NF =  '')
and A.RETCTR_NF != NULL

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = 'Erreur Génération TACCSUP2 - Cas de l''affaire terminée comptable'
  goto ErreurAno
end

-- compare the number of lines between EST_ESID0801_TESTUTISUP and #TACCSUP2
-- generation of an anomaly  ===>  anomaly 47
-- -----------------------------------------------------------------------------

select @nbligne_tempaccsup = count(*) FROM #TACCSUP2
if ( @nbligne_tempaccsup = Null ) Select @nbligne_tempaccsup = 0
if ( @nbligne_tempaccsup != @nbligne_testutisup )
begin
  -- generation of an anomaly and exit of the procedure
  SELECT @error_type     = 47
  select @MsgAnomalie    = 'Affaire terminée comptable'
  select @NumMsgAnomalie = @NumMsgAnomalie + '47 '

  INSERT INTO #TCTRANO_TMP (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
  SELECT DISTINCT CTR_NF, END_NT, SEC_NF, 1, SSD_CF, 'A', @p_usr_cf, @error_type, NUMLINE_NT
  FROM btrav..EST_ESID0801_TESTUTISUP
  WHERE
      TRN_NT NOT IN (SELECT TRN_NT FROM #TACCSUP2)
  and SSD_CF       = @p_ssd_cf
  and LSTUPDUSR_CF = @p_usr_cf
end


/************************************************************************************/
/*                                                                                  */
/*                     THIRD STEP: DETERMINATION OF WRITING TYPE	                */
/*                                                                                  */
/************************************************************************************/


-- As soon as the number of retro contract is provided , we crush the amount accepted with the retro amount

/* writing of type 1 */
/* pure acceptance    */
/* ------------------- */


UPDATE #TACCSUP1
SET ACCTYP_NF = 1
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF = NULL OR RETCTR_NF = "")
--or SPEENTTYP_CF in (8,9)

select @erreur = @@error
if @erreur != 0
    begin
      select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 1 "
    goto ErreurAno
    end

/* pure acceptance */
/* pure retro 100%      */
/* ------------------- */

UPDATE #TACCSUP1
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
    goto ErreurAno
    end

/* writing of type 3 */
/* acceptance and retro 100%*/
/* ------------------- */


UPDATE #TACCSUP1
SET ACCTYP_NF = 3,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT = NULL OR PLC_NT = 0)      -- 100%
select @erreur = @@error
if @erreur != 0
    begin
      select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 2 "
    goto ErreurAno
    end

/* Writing of type 4 */
/* REtro pure à la part */
/* ------------------- */

UPDATE #TACCSUP1
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
    goto ErreurAno
    end

/* writing of type 5 */
/* Accept et rétro à la part */
/* ------------------- */

UPDATE #TACCSUP1
SET ACCTYP_NF = 5,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT != NULL AND PLC_NT != 0)

select @erreur = @@error
if @erreur != 0
    begin
   select @MsgAnomalie = 'Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 4'
   goto ErreurAno
    end

InsertAno:
--MOD035 Avoid checking further errors when lvl 1 errors are found

/*-----------------------------------------------------------------------------*/
/* MOD001 - GENERATION & CONTROLE DES ERREURS de NIVEAU 1                      */
/*-----------------------------------------------------------------------------*/
select @nbligne_tctrano = 0
select @nbligne_tctrano = count(*) FROM #TCTRANO_TMP
if ( @nbligne_tctrano = Null ) Select @nbligne_tctrano = 0
if ( @nbligne_tctrano > 0 )
  begin

  -- MOD034 start - move anomaly management outside of errors

  -- Errors are recorded in anomalies Tables.
  -- We return an error code,  Failed Procedure. Since MOD034, inserting in TCTRANO no longer returns an error code as this is normal behaviour!
  -- Instead, error code will only be returned if insert into TCTRANO fails.
  -- Management of previous defect was replaced (Errors are recorded gradually  rather than one checking at the end of procedure
  -- There is no procedure ROLLBACK at this level .

    INSERT INTO BEST..TCTRANO (CTR_NF, END_NT, SEC_NF, VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, ANO_CT, NUMLINE_NT)
    SELECT ISNULL(CTR_NF, ''), ISNULL(END_NT, 0),
           ISNULL(SEC_NF, 0),  ISNULL(VRS_NF, 0),
           ISNULL(SSD_CF, 0),  ISNULL(SEGTYP_CT, ''),
           ISNULL(SEG_NF, ''),  ISNULL(ANO_CT, 0),
           ISNULL(NUMLINE_NT, -1)
    FROM #TCTRANO_TMP
    WHERE SSD_CF = @p_ssd_cf              -- MOD011 MDJ 21/02/2006
      and SEG_NF = @p_usr_cf              -- MOD011 MDJ 21/02/2006

  select @erreur = @@error
  if @erreur != 0
    begin
     select @MsgAnomalie = 'Erreur INSERT TCTRANO - Generation des anomalies'
     goto ErreurAno
    end

  goto Fin

  -- MOD034 end - move anomaly management outside of errors

  end
-- ***********************************************************************************
--
--    ETAPE 4 - ALL GOES WELL, THERE WAS NOT A DISCONNECTION BECAUSE OF AN  ANOMALY
--
-- ************************************************************************************


/*********************************************/
/*management  of counter for the fields TRN_NT */
/*********************************************/

-- search for the maximum line number in BEST..TACCSUP
select @max_trn_nt = max( TRN_NT )
FROM  BEST..TACCSUP
-- Insertion into  #TACCSUP3

INSERT into #TACCSUP3
  ( ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF,
  VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF, END_NT, SEC_NF,
  UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M,
  CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
  RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF)                         -- MOD005  -- MOD007
select ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF,
  VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF, END_NT, SEC_NF,
  UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M,
  CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
  RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF                                      -- MOD005 26/04/2005 -- MOD007
FROM  #TACCSUP1
select @erreur = @@error
if @erreur != 0
    begin
  select @MsgAnomalie = 'Erreur generation TACCSUP3 '
  goto ErreurAno
    end

--[051]
-- ********************************************************************
-- Si Type d'ecritures Local (7,8) maj des périodes années/mois
-- ********************************************************************
Update #TACCSUP3 
   set ENTPERY_NF = BALSHEY_NF
      ,ENTPERMTH_NF = BALSHRMTH_NF
where SPEENTNAT_CT  in (7,8)

-- ********************************************************************
-- Insertion into the table BEST..TACCSUP if the checks are OK
-- ********************************************************************

-- -------------------------------------------------------------
-- Beginning of the transaction
-- --------------------------------------------------------------

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
select TRN_NT + @max_trn_nt, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF,
  BALSHRMTH_NF, BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B,
  CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF,
  CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT,
  RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF,
  RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,
  ACCTRN_NT, COMMAC_LL, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF  -- MOD005 26/04/2005 - MOD007
FROM  #TACCSUP3

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- *****************************************************************************************
-- Removing lines of btrav..EST_ESID0801_TESTUTISUP for the subsidiary and the user
-- *****************************************************************************************

DELETE btrav..EST_ESID0801_TESTUTISUP
where
    SSD_CF       = @p_ssd_cf
  and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- -----------------------------------------------------------
--  End of the transaction
-- ------------------------------------------------------------

Fin:
--	MOD034

if @tran_imbr = 0
    COMMIT TRAN
    return 0

/************************************************************************************/
/*                     if anomaly detection  (MOD001                     */
/************************************************************************************/

ErreurNorm:
    Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
    raiserror 20113 @MsgGlobalAnomalie
    return 1


ErreurAno:
-- MOD034 anomaly insertion removed from this

-- [026]
    if @p_batch_mode != 'batch'
        BEGIN
            Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
            raiserror 20113 @MsgGlobalAnomalie
        END
    return 1

ErreurMAJ:
    if @tran_imbr = 0 ROLLBACK TRAN

    Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie + @NumMsgAnomalie
    raiserror 20113 @MsgGlobalAnomalie
    return 1
go
EXEC sp_procxmode 'dbo.PiACCSUP_02', 'unchained'
go
IF OBJECT_ID('dbo.PiACCSUP_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiACCSUP_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiACCSUP_02 >>>'
go
GRANT EXECUTE ON dbo.PiACCSUP_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiACCSUP_02 TO GDBBATCH
go
