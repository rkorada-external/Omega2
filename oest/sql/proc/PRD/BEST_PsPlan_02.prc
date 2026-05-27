USE BEST
go
IF OBJECT_ID('dbo.PsPlan_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPlan_02
    IF OBJECT_ID('dbo.PsPlan_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPlan_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPlan_02 >>>'
END
go
/*
 * creation de la procedure */
create procedure PsPlan_02  (
    @p_CRE_D        char(8),
    @p_CLONUM       tinyint,
    @p_BLCSHTYEA_NF smallint,
    @p_BLCSHTMTH_NF tinyint ,
    @p_SPCEND_D     char(8) ,
    @p_ACCOUNT_D    char(8) ,
    @p_CLODAT_D     char(8) ,
    @p_PERTYP_CT    char(1) ,
    @p_CLOTYP_CT    char(1) ,
    @p_CLOEXIST_CT  bit ,
    @p_CONSOMTH     smallint,           ---@P_BOOKING_D    char(8) ,
    @p_CONSOYEA     int,                --- MOD018
    @p_SSDACC_LL    varchar(64),
    @p_IsPlan       varchar(64)         --[029]
)

with execute as caller as
/***************************************************
Programme: PsPlan_02
Fichier script associé : BEST_PsPlan_02.prc
Domaine : (ES)Estimation
Base principale: BEST
Version: 1
Auteur: ME65 avec Infotool version 2.0 (AUTO)
7
Date de creation:
Description du programme: generation des fichiers PLAN
      Sélection d'enregistrement dans TREQJOB
Parametres:
      @p_CRE_D      UUPD_D
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1     -> MOD01
Auteur:  O.GIRAUX
Date: 06 mai 2003
Description:  Ajout chaine DWUD0010

_________________
MODIFICATION 2     -> MOD02
Auteur:  H.VALCKE
Date: 29 Juillet 2003
Description:  CLOTYP n'est jamais renseigné.
Donc mise à GO des jobs DWUD0010 et DWUD0030 en fonction du bilan.

_________________
MODIFICATION 3     -> MOD03
Auteur:  J. RIBOT
Date: 24 sept 2003
Description:  Ajout chaine ESID1520

_________________
MODIFICATION 4     -> MOD04
Auteur:  J. RIBOT
Date: 28 nov 2003
Description:  Ajout chaine ESID1520 STAD1200 STAD1280 en variante 4

_________________
MODIFICATION 5     -> MOD05
Auteur:  M. DJELLOULI
Date: 27/04/2004
Description:  Faire tourner  ESID1550 comme le ESID1800 en Période de Service

_________________
MODIFICATION 6     -> MOD06
Auteur:  J. RIBOT
Date: 06/05/2004
Description:  création fichier PLAN + chargement photo PR au 30/06 lors de la comptabilisation de JUIN.

_________________
MODIFICATION 7     -> MOD07
Auteur:  J. RIBOT
Date: 02/06/2004
Description:  maj COND1 du PARM1 = 'Y' pour jobs ESID1800 ESID1520 ESID1550 en variante 4.
              maj COND2 du PARM2 = 'Y' pour jobs ESID3800 ESID3900 en variante 4.
              maj COND1 du PARM1 = 'Y' pour jobs ESID2060 ESID2560 en variante 4.

_________________
MODIFICATION 8     -> MOD08
Auteur:  J. RIBOT
Date: 14 sept 2004
Description:  Ajout chaines ESID2020 ESID1530 en variante 3 4 7  (echanges internes vie)
               + GONOGO = 'Y' pour ESID4000 en VARIANTE 7

_________________
MODIFICATION 3     -> MOD09
Auteur:  J. RIBOT
Date: 05 Avril 2005
Description:  Ajout chaine STAD1500 STAD1530 STAD1550 + ajout @IsTrim

MODIFICATION 3     -> MOD10
Auteur:  J. RIBOT
Date: 01 Juillet 2005
Description:  Ajout chaines ESTPxx ESPJxx ESPDxx + ajout @IsEpo et @IsEpo31_12
              pour traitements des ecritures post omega

MODIFICATION 4     -> MOD11
Auteur:  M.DJELLOULI
Date: 22/07/2005
Description:  Conditionnement du Flag @IsEpoComptaRequestF sur Demande de type F

MODIFICATION 5     -> MOD12
Auteur:  J. Ribot
0Date: 08/09/2005
Description:  Ajout chaine ESPD9990

MODIFICATION 5     -> MOD13
Auteur:  J. Ribot
0Date: 28/09/2005
Description:  Ajout chaine ESPD1520 STPD1200 STPD1280 STPD1500

MODIFICATION 14     -> MOD14
Auteur:  M.DJELLOULI
0Date: 17/10/2005
Description:  Ajout chaine ESID7100

MODIFICATION 15     -> MOD15
Auteur:  J. Ribot
0Date: 09/11/2005
Description:  Ajout chaine STPD0020

MODIFICATION 15     -> MOD16
Auteur:  J. Ribot
0Date: 16/12/2005
Description:  Ajout chaine BTID0050

MODIFICATION 17     -> MOD17
Auteur:  J. Ribot
0Date: 26/01/2006
Description:  Peux-tu modifier la proc PsPlan02 pour mettre en NO GO en permanence les jobs suivants :
            - ESPD8800,
            - ESPD3900,
            - ESPD8900,
            - ESPD7000,
            - ESPD9990,
            - ESPD8830,
            - STPD0020
            Dans les commentaires, identifie bien les modifs car c'est une solution très temporaire.

MODIFICATION 18     -> MOD018
Auteur: M.DJELLOULI  / JM HOFFMANN
0Date: 08/02/2006
Description:  Extension Fiche 5085
              Les jobs qui tournent actuellement à chaque fois et qui ne doivent plus tourner lorsqu'on a passé
              la traitement final Post Oméga et qu'on ne traite plus que des écritures Post Oméga conso sont :
                  - ESPD3900 & ESPD8900 : traitement et chargement Oméga SAR,
                  - ESPD8800 : chargement GLT,
                  - ESPD7000 : comptabilisation PeopleSoft,
                  - ESPD1520, STPD1200, STPD1500, STPD1280 : traitements Vie
              Cette modification annulle la modification MOD17

              Après le passage du traitement Post Oméga, seule la mise à jour d'AIB doit continuer à tourner.
              Dans la PsPlan02, si le traitement est passé, mettre COND1='Y' pour DWPD0010.
              Dans le job, tester cette condition pour ne pas exécuter le DWUD0011 si COND1='Y'

              Compléter la proc PsPlan02 pour lancer le BTID0050 :
              - comme actuellement : variante 3 ou 4,
              - également à chaque traitement Post Oméga (REQCOD_CT='T')

MODIFICATION 19     -> MOD19
Auteur:  J. Ribot
Date: 02/06/2006
Description:  Spot12860     variante = 2 si pas de demande d'inventaire le jour de la comptabilisation trimestrielle

MODIFICATION 20     -> MOD20
Auteur:  J. Ribot et paul
Date: 25/09/2006
Description:  Ajout chaine BTID0090


MODIFICATION 21     -> MOD21
Auteur:  J. Ribot et paul
Date: 03/10/2006
Description:  SPOT13233  Modif lancement ESID7100 - Etats CAC

MODIFICATION 22    -> MOD22
Auteur:  J. Ribot
Date: 08/03/2007
Description: Ajout chaine DWMD0000 Consolidation ES Magnitude
             a declencher lors de comptabilisation EPO Sociale  (Delphine Brulard)

MODIFICATION 23     -> MOD23
Auteur:  J. Ribot
Date: 29/08/2007
Description:  Ajout chaine DWUD0130

MODIFICATION 24     -> MOD24
Auteur:  J. Ribot
Date: 05/09/2007
Description:  Ajout chaine DWUJ0070
_________________
MODIFICATION    [025]
Auteur:         D.GATIBELZA
Date:           09/09/2008
Version:        8.1
Description:    ESTDOM16015 Specifications for the Omega to Visma interface (phase mensuelle)
_________________
MODIFICATION    [026]
Auteur:         J. Ribot
Date:           11/12/2008
Version:        8.1
Description:    SPOT16606 remplace chaine DWUD0130 par chaine DWUD9130
_________________
MODIFICATION    [027]
Auteur:         D.GATIBELZA
Date:           25/05/2009
Version:        9.1
Description:    ESTDOM17427 Envoi DWUD9130 au lieu de DWUD0130 (extraction ReCube)
_________________
MODIFICATION    [028]
Auteur:         D.GATIBELZA
Date:           13/08/2009
Version:        9.1
Description:    ESTDOM17908 Activation des 2 jobs DWUD0130 et DWUD9130 (extraction RECUBE)
_________________
MODIFICATION    [029]
Auteur:         D.GATIBELZA
Date:           12/03/2010
Version:        10.1
Description:    SRVIE16960 Adaptation de TLIFSTAREP  création d'une version du plan vie à la demande + ES plan à intégrer
_________________
MODIFICATION    [030]
Auteur:         D.GATIBELZA
Date:           15/06/2010
Version:        10.1
Description:    ESTVIE19204 :spot:19204 Optimisation des nuits batch  Optimisation des tests (environnements pour la non regression)
                - ESID7100 ( états CAC ) passe en NOGO
                - Ajout du ESID0070 et ESID0080 et ESEH1110
_________________
MODIFICATION    [031]
Auteur          D.GATIBELZA
Date            07/02/2011
Version         11.1
Description     ESTDOM21408 :1GL
_________________
MODIFICATION    [032]
Auteur:         R. CASSIS
Date:           15/03/2011
Version:        11.2
Description:    :spot:21408 Ajout chaine ESID7050 : Generation des fichiers CMGT et ESID8700
_________________
MODIFICATION    [033]
Auteur:         P. COPPIN
Date:           29/03/2011
Version:        11.3
Description:    spot 21408 Ajout ligne dans le select final pour indiquer si demande de Comptabilisation PostOmega/Conso
_________________
MODIFICATION    [035] - SPOT [22435]
Auteur:         D. Chetboul
Date:           05.08.2011
Version:        11.3
_________________
Description:    Ajout de @ComptaSocialDone = 0
MODIFICATION    [034] - SPOT [22435]
Auteur:         D. Chetboul
Date:           19.08.2011
Version:        11.3
Description:    Ajout de @ComptaSocialDone = 0
[036] 09/05/2012 Roger Cassis  :spot:23802 - Modifications pour Solvency
                 sur PLAN1 valeurs des CONDs :
                 COND1 = Y (Social) / N (Conso)
                 COND2 = Y (EBS)    / N (IFRS)
                 COND3 = Y (ComptasocialDone=1) / N (ComptasocialDone=0)
[037] 09/05/2012 Roger Cassis  :spot:24041 - Modifications pour Solvency 2
[038] 05/12/2012 -=Dch=-    :spot:24041 - Modifications pour Solvency 2
[039] 20/01/2013 P. Pezout  :spot:24698 ajout des indicateurs EBS (p_CONSOMTH/p_CONSOYEA/ComptaSocialEBSDone/IsEpo/TypePOST/nb_NoEBS)
[040] 30/01/2013 R. Cassis  :spot:24659 Ajustements pour post omega
[041] 30/01/2013 R. Cassis  :spot:24775 Ajustements pour post omega ESPD3850-60
[042] 27/02/2013 R. Cassis  :spot:24904 Mettre en go le ESID7000 et le ESID7050 (compta mensuelle)
[043] 20/03/2013 P. Pezout  :spot:24979 Ajout cond2 
[044] 22/03/2013 R. Cassis  :spot:25006 Gestion OneGl avec les 3850
[045] 13/05/2013 R. Cassis  :spot:25171 Suppression commentaires qui boguaient la planif du ESPD0060
[046] 17/05/2013 R. Cassis  :spot:25171 Ajout dernier jour inventaire postomega social positionné
[047] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
[048] 04/12/2013 R. Cassis  :spot:25894 Gestion ESID2500 pour traitement annuel
[049] 30/01/2014 R. Cassis  :spot:26209 ESPD8830 sur Plan 1 au lieu de Plan 0
[050] 20/03/2014 R. Cassis  :spot:25427 Gestion archivage fichiers POST-CONSO et plantage ESPD3860 si fichier onegl pas extrait.
[051] 23/01/2015 R. Cassis  :spot:28117 Ajout DWPD0020 - DWPD1430
[053] 19/02/2015 P. Menant  :spot:28306 Ajout de la chaine STAD1540 (EST37).
[054] 06/03/2015 R. Cassis  :spot:28139 Add chain ESIJ2000
[055] 25/03/2015 R. Cassis  :spot:28483 Add chain ESID0110
[056] 20/03/2014 R. Cassis  :spot:28660 Ajout chaines ESID8050 et ESPD8050.
[057] 28/08/2015 R. Cassis  :spot:29095 Ajout chaines journalieres plan 0(ESDJ0110 - ESDJ1010 - ESDJ5020 - ESDJ5040 - ESDJ7000) plan1(ESDJ8040 -  ESID8040)
[058] 04/11/2015 R. Cassis  :spot:29654 Gestion plan2 pour le Post-omega + Ajout ESPD2050 + ESID8100 et ESPD8100
[059] 29/01/2016 R. Cassis  :spot:30085 Le DWUD9130 tourne tous les jours
[060] 18/07/2016 M. Bonato  :spot:30898 ESDJ5020 s'execute en même temps que ESID0060 et ESID2030
[061] 08/08/2016 M. Bonato  :spot:30898 MaJ [060]
[062] 18/08/2016 R. Cassis  :spot:30985 Ajout chaine pour RA ESID8120
[063] 21/09/2016 R. Cassis  :spot:31263 Ajout conditions pour POC EBS et POC IFRS et ajout rubrique COND5
[064] 28/12/2016 R. Cassis  :spot:31263 spira:#55930 Le ESIJ0090 ne tourne plus en periode de comptabilisation
[065] 11/07/2016 MMA        :Spot:30917 Planification de l'ESID8040 pour tourner les 15 derniers jours de la période normale et jusqu'à la fin de la période exceptionnelle.
[066] 22/05/2017 R. Cassis  :Spira:42211 Ajout test de condition 2 sur ESID8000 pour la gestion de TCONPAR en mode trimestriel
[067] 23/05/2017 R. Cassis  :Spira:60187 Modification test de condition 3 sur ESID7000 pour le test de compta trimestrielle
[068] 11/07/2017 R. Cassis  :Spira:61508 Mise a jour pour chaines ecritures locales ESLD..
[069] 18/10/2017 S.Behague  :Spira:64716 EST26B : Supprimer la fonction qui déclenche le programme en fonction de la période closing
[070] 27/10/2017 S.Behague  :Spira:64714 EST26B : Modifier la période de déclenchement du traitement
[071] 27/12/2017 R. Cassis  :Spira:66794 Le job ESLD3850 doit tout le temps tourner pour le parametrage de OTGL0010 
[072] 13/02/2018 R. Cassis  :Spira:67394 Modification d'une condition pour la selection du local
[073] 26/04/2018 R. Cassis  :Spira:65651 Ajout chaine ESPD3710 pour ventilation NP EBS.
[074] 21/01/2019 JYP        :Spira:74540 bugfix variable ComptaSocialEBSDone
[075] 26/04/2018 R. Cassis  :Spira:70671 Ajout chaine ESPD2570.
[076] 28/02/2019 JYP        :Spira 74540 report code : bugfix variable ComptaSocialEBSDone 
[077] 18/02/2019 R. Cassis  :Spira:73851 Ajout condition de non-parallélisme du Local avec la compta trimestrielle et correction de la planification du POCE
[078] 12/04/2019 R. Cassis  :Spira:65656 Ajout chaine ESPD8000 pour recharger la table FCTREST en mode post-omega
[079] 19/04/2019 MIS    :Spira:76548 Ajout chaine ESDJ7010
[080] 09/05/2019 S.Behague:spira:70045 Evolution Quarterly - Ajout chaine ESID2080
[081] 23/08/2019 R.VIeville :spira:78996 optimisation ESID0110
[082] 14/02/2020 L. Wernert	:spira:73774: Modification planification STAD7500 (annuelle/mensuelle)
[083] 25/02/2020 S.Behague  :spira:85042 Batch ESID0120 et ESID0130
[084] 08/04/2020 R. Cassis  :Spira:76698 Ajout chaine ESLD2900 pour gerer les ouvertures Local annuelles
[085] 08/04/2020 R. Cassis  :Spira:76698 Ajout chaine ESLD2900 pour gerer les ouvertures Local annuelles
[086] 08/04/2020 N L.DOAN   :Spira:83103  Ajout chaine ESID3810 
[087] 28/10/2020 T. DEUTSCH :SPIRA 91141 revert for Prod until test in Release
[088] 18/01/2021 R. Cassis  :Spira:92383 Correction sur les conditions du Local
[089] 19/03/2021 B. Lagha   :Spira:90055 Activation de l'archivage monsuel et du ouvertures/purge annuel
[090] 30/06/2021 B. Lagha   :Spira:97422 Change GONOGO condition of STAD7500
****************************************************/

 
 
CREATE TABLE #PLANNING (
    CHAINE   varchar(20),
    variante tinyint,
    GONOGO   char(1) DEFAULT 'N',
    del      char(1) DEFAULT 'N',
    cond1    char(1) DEFAULT 'N',
    cond2    char(1) DEFAULT 'N',
    cond3    char(1) DEFAULT 'N',
    cond4    char(1) DEFAULT 'N',
    cond5    char(1) DEFAULT 'N'
)


-- Recherche des dates dans BREF..TCALEND
-----------------------------------------------------------------------------------------
declare @variante           tinyint,
        @erreur             int,
        --[031] @nbinventaireOld    int,
        @Is31_12            char(1),
        @IsP31_12           char(1),
        @Title              varchar(90),
        @IsCOMPTA           char(1),
        @IsCLOSING          char(1),            -- MOD19
        @IsSNEM             char(1),
        --[031] @IsLife     char(1),
        @nb_SNEM            int,
        @nb_Life            int,
        @nb_NoLife          int,
        @nb_NoEBS           int,                -- [036]
        @CLODAT0            char(8),
        @Is30_06            char(1),
        @IsTrim             char(1),            -- JR 13/04/2005
        @IsEpo              char(1),            -- JR 01/07/2005 traitement ecritures post omega demandé
        @IsESLOC            char(1),            -- [068]
        @IsEpo31_12         char(1),
        @IsEpoComptaRequestF   char(1),    -- [063]
        @ComptaSocialIFRSDone  int,     -- [036] Compta Sociale IFRS effectuée 0/1 = Non/Oui
        @ComptaSocialEBSDone   int,     -- [036] Compta Sociale EBS effectuée 0/1 = Non/Oui
        @ComptaSocialLastDay   char(1), -- dernier jour inventaire postomega social positionné à N par défaut PP [046]
        --@IsReqcodEqualT     int,        -- MDJ 08/02/2006 - MOD018 -- REQCOD_CT = T  - 0/1 = Non/Oui
        @IsPlan             int,                 --[029]
        -- PHP0907
      --@IsPOsocialEBS      char(1),    --[036]
      --  @IsPOconsoEBS       char(1)     --[036]
        @TypePOST      char(6),
        @TotalPOST      varchar(16),       -- [068]
        @End_D            char(8),                --[065] ESID8040 tourne selon une planification
        @p_SPCENDT_D      char(8),                --[069]
        @p_BLCSHTMTHT_NF  int                 --[069]
        
declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

-- AJOUT Jr 02/06/2006   spot 12860 indication si comptabilisation trimestrielle       MOD19
select @IsCLOSING = 'Y'
FROM BREF..TCALEND
WHERE @p_ACCOUNT_D    = @p_CRE_D
  AND @p_BLCSHTYEA_NF = BLCSHTYEA_NF
  AND @p_BLCSHTMTH_NF = BLCSHTMTH_NF
  AND CLOSING_B       = 1
-- Fin AJOUT Jr 02/06/2006   spot 12860         MOD19

--------------------------------------------------------------------
print '==> @IsCLOSING = %1! @p_CLOEXIST_CT = %2!', @IsCLOSING, @p_CLOEXIST_CT
--------------------------------------------------------------------  

--------------------------------------------------------------------
print '==> @p_ACCOUNT_D = %1! @p_PERTYP_CT = %2!', @p_ACCOUNT_D, @p_PERTYP_CT
--------------------------------------------------------------------  

-- pour les tests
-- Aucun inventaire n'est demandé ---------------------------------------
if @p_CLOEXIST_CT = 0
    --- La date de lancement est différente de la date de comptabilisation ------------------
    if  @p_ACCOUNT_D != @p_CRE_D
        if @p_PERTYP_CT = 'H'   ------- Hors service --------------------------------------
            select @variante = 1
        else
        begin
            if @p_ACCOUNT_D > @p_CRE_D
                select @variante = 2
        end
    else
        -- AJOUT Jr 02/06/2006   spot 12860       MOD19
        if @IsCLOSING = 'Y'                  --  jour comptabilisation mois inventaire
            select @variante = 2
        else
            -- Fin AJOUT Jr 02/06/2006   spot 12860    MOD19
            select @variante = 5
else
    ------- Hors service -------------------------------------------
    if @p_PERTYP_CT = 'H'
        select @variante = 3
    else
        --- La date de lancement et inférieur à la date de comptabilisation ---------------
        if  @p_ACCOUNT_D > @p_CRE_D
            select @variante = 4
        else
            select @variante = 6

--------------------------------------------------------------------
print '==> @variante = %1!', @variante
--------------------------------------------------------------------  

-- [058]
if @variante = 5
begin
  If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN
              WHERE REQCOD_CT = 'C'
                and LAUNCH_D != Null
                and SITE_CF = @site_cf
                and isnull(VRS_Nf,0) = 0
                and BALSHEYEA_NF = @p_BLCSHTYEA_NF
                and BALSHTMTH_NF = @p_BLCSHTMTH_NF )
      Select @variante = 1  -- La Comptabilisation technique a déjà été faite dans la journée, on l'annule pour ne pas la refaire le soir
End


-- Variante 7: inventaire vie uniquement --------------------------------------------
/**********************************************************************************************
    LIBELLE INVENTAIRE :
    remplacer la premier jour du mois par le dernier jour du même mois pour
    obtenir le vrai libéllé d'inventaire principal
***********************************************************************************************/
select @CLODAT0 = convert(char(6),@p_BLCSHTYEA_NF*100 +  @p_BLCSHTMTH_NF) + '01'
select @CLODAT0 = convert(char(8),dateadd(dd,-1,dateadd(mm,1,@CLODAT0)),112)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification*/
    return @erreur
end

--[036] PHP0907
select @nb_NoEBS = count(*)
from BEST..TREQJOBPLAN r
WHERE r.LAUNCH_D = NULL
  and isnull(vrs_nf,0)=1
  and SITE_CF = @site_cf
  AND ((convert(char(8),r.CLODAT_D,112) >= @CLODAT0 and
        convert(char(8),r.DBCLO_D,112) <= @p_CRE_D  and
        reqcod_ct in ('E','D'))
       or
       (BALSHEYEA_NF = @p_CONSOYEA and
        BALSHTMTH_NF = @p_CONSOMTH and
        convert(char(8),r.DBCLO_D,112) <= @p_CRE_D and
        reqcod_ct in ('T','F'))
      )

-- test type post-omega ES locales [068] [088]
Select @IsESLOC = 'N'
If Exists ( SELECT 1 FROM BEST..TREQJOBPLAN a, BREF..TCALEND
            WHERE REQCOD_CT = 'Y'
              and LAUNCH_D = Null
              and isnull(VRS_Nf,0) = 0
              and @variante != 6  -- [077]
              and SITE_CF = @site_cf
              and datepart(yy,CLODAT_D) = @p_CONSOYEA  -- [072] and BALSHEYEA_NF = @p_CONSOYEA  
              and datepart(mm,CLODAT_D) = @p_CONSOMTH
--              and BALSHEYEA_NF = BLCSHTYEA_NF [088]
              and datepart(yy,CLODAT_D) = BLCSHTYEA_NF
              and datepart(mm,CLODAT_D) = BLCSHTMTH_NF
              and DBCLO_D <= @p_CRE_D
              and DBCLO_D <= (select min(SPECEND_D) from BREF..TCALEND c 
                              where CLOSING_B = 1
                              and   ACCOUNT_D > a.DBCLO_D
                              and   ACCOUNT_D > (select max(DBCLO_D) from BEST..TREQJOB r
                                                 where r.REQCOD_CT = 'B'
                                                 and   a.DBCLO_D > r.DBCLO_D
                                                 and   r.SITE_CF = @site_cf)
                             )
          )
Begin
    Select @IsESLOC = 'Y'
End

--------------------------------------------------------------------
print '==> @CLODAT0 = %1! @IsESLOC = %2!', @CLODAT0, @IsESLOC
--------------------------------------------------------------------  

select @nb_NoLife = count(*)
from BEST..TREQJOB r
WHERE r.LAUNCH_D = NULL
  AND convert(char(8),r.CLODAT_D,112) >= @CLODAT0
  and convert(char(8),r.DBCLO_D,112) <= @p_CRE_D
  and r.reqcod_ct in ('I','J')
  and SITE_CF = @site_cf

--------------------------------------------------------------------
print '==> @nb_NoLife = %1!', @nb_NoLife
--------------------------------------------------------------------  

select @nb_Life = count(*)
from BEST..TREQJOB r
WHERE r.LAUNCH_D = NULL
  and convert(char(8),r.CLODAT_D,112) >= @CLODAT0
  and r.reqcod_ct in ('L', 'A')
  and SITE_CF = @site_cf

--------------------------------------------------------------------
print '==> @nb_NoLife = %1!', @nb_NoLife
--------------------------------------------------------------------  

IF @nb_NoLife = 0  and @nb_Life > 0
BEGIN
    select @variante = 7
END


-- Debut MOD018
--[036]
Select @ComptaSocialIFRSDone = 0         -- Non par défaut
If Exists ( SELECT 1 FROM BEST..TREQJOB
            WHERE REQCOD_CT = 'F'
              and LAUNCH_D != Null
              and SITE_CF = @site_cf
              and isnull(VRS_Nf,0) = 0
              and BALSHEYEA_NF = @p_CONSOYEA
              and BALSHTMTH_NF = @p_CONSOMTH )
Begin
    Select @ComptaSocialIFRSDone = 1     -- La Comptabilisation Sociale IFRS est Passée pour la Période
End

--[036][074]
Select @ComptaSocialEBSDone = 0         -- Non par défaut
If Exists ( SELECT 1 FROM BEST..TREQJOB
            WHERE REQCOD_CT = 'F'
              and LAUNCH_D != Null
              and isnull(VRS_Nf,0) = 1
              and SITE_CF = @site_cf
              and BALSHEYEA_NF = @p_CONSOYEA
              and BALSHTMTH_NF = @p_CONSOMTH )
   AND
   Exists ( SELECT 1 FROM BEST..TREQJOB, bref..tcalend 
            WHERE REQCOD_CT = 'F'
              and LAUNCH_D != Null   -- [077]
              and isnull(VRS_Nf,0) = 1
              and SITE_CF = @site_cf
              and BALSHEYEA_NF = @p_CONSOYEA
              and BALSHTMTH_NF = @p_CONSOMTH
              and BALSHEYEA_NF = BLCSHTYEA_NF
              and BALSHTMTH_NF = BLCSHTMTH_NF
              and @p_CRE_D > isnull(EBSPSTOMGEND_D,getdate()) )    -- [077]
Begin
    Select @ComptaSocialEBSDone = 1     -- La Comptabilisation Sociale EBS est Passée pour la Période
End


              
--Select @IsReqcodEqualT = 0          -- Non Par Défaut
--If Exists ( SELECT 1 FROM BEST..TREQJOB
--            WHERE REQCOD_CT = 'T'
--            and SITE_CF = @site_cf
--              and LAUNCH_D = Null )
--Begin
--    Select @IsReqcodEqualT = 1     -- Demande Post-omega T active
--End
--
-- top à 'Y' @IsEpo si demande traitement ecritures post omega  ------------MOD10 jr 01/07/2005
select @IsEpo = "N"         -- Non Par Défaut
If Exists ( SELECT 1 FROM BEST..TREQJOB
            WHERE REQCOD_CT in ('T')
              and SITE_CF = @site_cf
              and LAUNCH_D = Null )
Begin
    Select @IsEpo = "Y"     -- Demande Post-omega T active
End

-- PHP0907
--                ComptaSocialeIFRSDone   | ComptaSocialeEBSDone
--              | 0           | 1         |   0       |   1
--@nb_NoEBS 0 |Social IFRS  |Conso IFRS |Conso IFRS |Conso IFRS
--            1 |Social EBS   |Social EBS |Social EBS |Conso EBS
--
--
--  case (ComptaSocialeIFRSDone = 0)
--  ==> social
--  case (ComptaSocialeEBSDone = 1)
--  ==> conso
--  case @NoEBS>0
--  ==> social (EBS)
--
--[040]
select @TypePOST=""
if ( @IsEpo = "Y")
begin
  if (@nb_NoEBS = 0 )
    if (@ComptaSocialIFRSDone = 1 )
      select @TypePOST = "CONSO "
    else
      select @TypePOST = "SOCIAL"
  else
    if (@ComptaSocialEBSDone = 1 )
      select @TypePOST = "CONSO "
    else
      select @TypePOST = "SOCIAL"
end

-- [068]
select @TotalPOST = @TypePOST
if (@IsESLOC = "Y")
begin
  select @TotalPOST = "ESLOCAL"
   if ( @TypePOST != "")
   begin
     select @TotalPOST = @TypePOST + "ESLOCAL"
   end
end

--------------------------------------------------------------------
print '==> @TotalPOST = %1! @IsEpo = %2!', @TotalPOST, @IsEpo
--------------------------------------------------------------------  

-- Fin MOD018


-- Initialisation à nom des variables GONOGO, DELETE, COND1, COND2, COND3 pour toutes les ------ chaînes
-- [036][063]
insert into #PLANNING values("ESCJ0000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESCJ0060",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESDJ0110",1,"N","N","N","N","N","N","N")  --[057]
insert into #PLANNING values("ESDJ1010",1,"N","N","N","N","N","N","N")  --[057]
insert into #PLANNING values("ESDJ5020",1,"N","N","N","N","N","N","N")  --[057]
insert into #PLANNING values("ESDJ5040",1,"N","N","N","N","N","N","N")  --[057]
insert into #PLANNING values("ESDJ7000",1,"N","N","N","N","N","N","N")  --[057]
insert into #PLANNING values("ESDJ7010",1,"N","N","N","N","N","N","N")  --[057]
insert into #PLANNING values("ESDJ8040",1,"N","N","N","N","N","N","N")  --[057]
insert into #PLANNING values("ESIJ1000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESIJ2000",1,"N","N","N","N","N","N","N")  --[054]
insert into #PLANNING values("ESCJ8990",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEJ0000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEJ0200",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEJ0210",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEJ0220",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEJ0230",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEJ0240",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESED0300",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEJ1000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEH1100",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESEH1110",1,"N","N","N","N","N","N","N")  --[030]
insert into #PLANNING values("ESEH1200",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID0060",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID0070",1,"N","N","N","N","N","N","N")  --[030]
insert into #PLANNING values("ESID0080",1,"N","N","N","N","N","N","N")  --[030]
insert into #PLANNING values("ESIJ0090",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID0110",1,"N","N","N","N","N","N","N")  --[055]
insert into #PLANNING values("ESID0120",1,"N","N","N","N","N","N","N")  --[074]
insert into #PLANNING values("ESID0130",1,"N","N","N","N","N","N","N")  --[080]
insert into #PLANNING values("ESID0560",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1010",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1500",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1520",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1530",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1550",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1600",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1800",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID1900",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2010",1,"N","N","N","N","N","N","N")  -- [036] provisoire pour controles
insert into #PLANNING values("ESID2020",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2030",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2070",1,"N","N","N","N","N","N","N")  -- [074]
insert into #PLANNING values("ESID3020",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2040",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2080",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2050",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2060",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2090",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2100",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2500",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2530",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2550",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2560",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2600",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2590",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2800",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID2900",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID3600",1,"N","N","N","N","N","N","N")  --[036]
insert into #PLANNING values("ESID3700",1,"N","N","N","N","N","N","N")  --[036]
insert into #PLANNING values("ESID3800",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID3810",1,"N","N","N","N","N","N","N")  --[086]
insert into #PLANNING values("ESID3850",1,"N","N","N","N","N","N","N")  --[031]
insert into #PLANNING values("ESID3860",1,"N","N","N","N","N","N","N")  --[032]
insert into #PLANNING values("ESID3900",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID4000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID4010",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESIJ7000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID7000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID7050",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID7100",1,"N","N","N","N","N","N","N")  -- MOD014
insert into #PLANNING values("ESID7200",1,"N","N","N","N","N","N","N")  --[025]
insert into #PLANNING values("ESID7500",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID7550",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8030",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8040",1,"N","N","N","N","N","N","N")  --[057]
insert into #PLANNING values("ESID8050",1,"N","N","N","N","N","N","N")  -- [056]
insert into #PLANNING values("ESID8060",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8100",1,"N","N","N","N","N","N","N")  -- (058]
insert into #PLANNING values("ESID8120",1,"N","N","N","N","N","N","N")  -- (062]
insert into #PLANNING values("ESID8500",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8530",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8600",1,"N","N","N","N","N","N","N")  --[050]
insert into #PLANNING values("ESID8700",1,"N","N","N","N","N","N","N")  --[032]
insert into #PLANNING values("ESID8800",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8830",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8900",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID8930",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("DWED0010",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESRD0000",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESRD0010",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESRD0020",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("STAD7500",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("STAD1200",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("STAD1500",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("STAD1220",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("STAD1280",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("STAD1530",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("STAD1540",1,"N","N","N","N","N","N","N")  --[053]
insert into #PLANNING values("STAD1550",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("STAD1290",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESIJ0010",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESRD2530",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("ESID9990",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("DWUD0010",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("DWUD0030",1,"N","N","N","N","N","N","N")
insert into #PLANNING values("BTID0050",1,"N","N","N","N","N","N","N")  -- JR 16/12/2005  MOD16
insert into #PLANNING values("BTID0090",1,"N","N","N","N","N","N","N")  -- JR 16/12/2005  MOD20
insert into #PLANNING values("DWUD0130",1,"N","N","N","N","N","N","N")  --[027] JR 29/08/2007  MOD23
insert into #PLANNING values("DWUJ0070",1,"N","N","N","N","N","N","N")  -- JR 05/09/2007  MOD24
insert into #PLANNING values("DWUD9130",1,"N","N","N","N","N","N","N")  -- JR 11/12/2008  MOD26  --[027][028] réactivation
insert into #PLANNING values("ESLD1800",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLD1900",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLD2900",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLD3800",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLD3850",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLD3860",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLD8100",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLD8700",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLD8830",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLJ0090",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESLJ8990",1,"N","N","N","N","N","N","N")  -- [068]
insert into #PLANNING values("ESPT0000",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPJ0090",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPD0060",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPD1520",1,"N","N","N","N","N","N","N")  -- JR 28/09/2005  MOD13
insert into #PLANNING values("ESPD1800",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
--insert into #PLANNING values("ESPD1900",1,"N","N","N","N","N","N")  -- JR 01/07/2005  MOD10  -- [063] retire car existe plus.
insert into #PLANNING values("ESPD2900",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPD3800",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPD3850",1,"N","N","N","N","N","N","N")  -- [032]
insert into #PLANNING values("ESPD3860",1,"N","N","N","N","N","N","N")  -- [032]
insert into #PLANNING values("ESPD3900",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPD2000",1,"N","N","N","N","N","N","N")  -- PHP0907
insert into #PLANNING values("ESPD2010",1,"N","N","N","N","N","N","N")  -- PHP0907
insert into #PLANNING values("ESPD2050",1,"N","N","N","N","N","N","N")  -- [058]
insert into #PLANNING values("ESPD2500",1,"N","N","N","N","N","N","N")  -- PHP0907
insert into #PLANNING values("ESPD2550",1,"N","N","N","N","N","N","N")  -- PHP0907
insert into #PLANNING values("ESPD2570",1,"N","N","N","N","N","N","N")  -- [075]
insert into #PLANNING values("ESPD3700",1,"N","N","N","N","N","N","N")  -- PHP0907
insert into #PLANNING values("ESPD3710",1,"N","N","N","N","N","N","N")  -- [073]
insert into #PLANNING values("ESPD4000",1,"N","N","N","N","N","N","N")  -- PHP0907
insert into #PLANNING values("ESPD8000",1,"N","N","N","N","N","N","N")  -- [078]
insert into #PLANNING values("ESPD8050",1,"N","N","N","N","N","N","N")  -- [056]
insert into #PLANNING values("ESPD8100",1,"N","N","N","N","N","N","N")  -- [058]
insert into #PLANNING values("ESPD8600",1,"N","N","N","N","N","N","N")  -- PHP0907
insert into #PLANNING values("ESPD8700",1,"N","N","N","N","N","N","N")  -- [032]
insert into #PLANNING values("ESPD8800",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPD8900",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPD8830",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("ESPD7000",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("DWPD0010",1,"N","N","N","N","N","N","N")  -- JR 01/07/2005  MOD10
insert into #PLANNING values("DWPD0020",1,"N","N","N","N","N","N","N")  -- [051]
insert into #PLANNING values("DWPD1430",1,"N","N","N","N","N","N","N")  -- [051]
insert into #PLANNING values("ESPJ8990",1,"N","N","N","N","N","N","N")  -- MDJ 22-07-2005 MOD011
insert into #PLANNING values("ESPD9990",1,"N","N","N","N","N","N","N")  -- JR  08-09-2005 MOD012
insert into #PLANNING values("STPD1200",1,"N","N","N","N","N","N","N")  -- JR  28-09-2005 MOD013
insert into #PLANNING values("STPD1280",1,"N","N","N","N","N","N","N")  -- JR  28-09-2005 MOD013
insert into #PLANNING values("STPD1500",1,"N","N","N","N","N","N","N")  -- JR  28-09-2005 MOD013
insert into #PLANNING values("STPD0020",1,"N","N","N","N","N","N","N")  -- JR 09/11/2005  MOD15
insert into #PLANNING values("DWMD0000",1,"N","N","N","N","N","N","N")  -- JR 08/03/2006  MOD22


-- top à 'Y' la variable Is31_12 si la pariode de l'inventaire est égal à 12 -------------------
if datepart(mm,@p_CLODAT_D) = 12
    select @Is31_12 = "Y"

-- top à 'Y' la variable IsP31_12 si l'inventaire est principal la periode est égal à 12 ------
if datepart(mm,@p_CLODAT_D) = 12 and @p_CLOTYP_CT = 'P'
    select @IsP31_12 = "Y"

-- top à 'Y' la variable Is30_06 si la periode de l'inventaire est égal à 06 ------
-- JR 06/05/2004   MOD6
if datepart(mm,@p_CLODAT_D) = 06
    select @Is30_06 = "Y"


-- top à 'Y' la variable IsTrim si la periode de l'inventaire est égal à 03 06 09 ou 12 ------
-- JR 13/04/2005
if datepart(mm,@p_CLODAT_D) in (03, 06, 09, 12)
    select @Istrim = "Y"

-- top à 'Y' la variable @IsCOMPTA si c'est un jour de comptabilisation et CLOSING_B = 1 on est à J --------------------------------------------------
select  @IsCOMPTA = 'Y'
FROM BREF..TCALEND
WHERE @p_ACCOUNT_D    = @p_CRE_D
  AND @p_BLCSHTYEA_NF = BLCSHTYEA_NF
  AND @p_BLCSHTMTH_NF = BLCSHTMTH_NF
  AND CLOSING_B       = 1



-- top à 'Y' @IsSNEM si l'inventaire est SNEM --------------------------------------------
IF @p_CLONUM != 0
BEGIN
    select @IsSNEM = "N"
    select @nb_SNEM = count(*)
    from BTRAV..TESTSSD s, BEST..TREQJOB r
    where s.SSD_CF = r.SSD_CF
      AND convert( char(8),r.CLODAT_D,112) = @p_CLODAT_D
      and r.LAUNCH_D = NULL
      and r.REQCOD_CT = 'J'
      and SITE_CF = @site_cf

    IF @nb_SNEM > 0
    BEGIN
        select @IsSNEM = 'Y'
    END
END



-- top à 'Y' @IsEpo si demande traitement ecritures post omega  ------------MOD10 jr 01/07/2005
--select @IsEpo = "Y"
--from BEST..TREQJOB
--where LAUNCH_D = NULL
--  and REQCOD_CT = 'T'

/* [100] supprimé */
if (@IsEpo = "Y" OR @IsESLOC = "Y")
BEGIN
    if @p_PERTYP_CT = 'H'
        select @variante = 1
    else
        select @variante = 2
END

-- Di Demande de Comptabilisation PostOmega/Conso
select @IsEpoComptaRequestF = "Y"
from BEST..TREQJOB
where LAUNCH_D = NULL
  and REQCOD_CT = 'F'
  and DBCLO_D <= @p_CRE_D  -- [063]
  and SITE_CF = @site_cf

-- le dernier jour du postomegasocial
Select @ComptaSocialLastDay = 'N'     -- dernier jour inventaire postomega social positionné à N par défaut [046]
If Exists ( SELECT 1 FROM BEST..TREQJOB, bref..tcalend 
            WHERE REQCOD_CT = 'T'
              and LAUNCH_D = Null
              and SITE_CF = @site_cf
              and BALSHEYEA_NF = @p_CONSOYEA
              and BALSHTMTH_NF = @p_CONSOMTH
              and BALSHEYEA_NF = BLCSHTYEA_NF
              and BALSHTMTH_NF = BLCSHTMTH_NF
              and ( DBCLO_D = isnull(EBSPSTOMGEND_D,getdate()) or DBCLO_D = isnull(PSTOMGEND_D,getdate()) ) )
Begin
    Select @ComptaSocialLastDay = 'Y'     -- dernier jour inventaire postomega social [046]
End

if @p_CONSOMTH = 12 -- MOD011 - Conditionné uniquement
    select @IsEpo31_12 = "Y"

-- ---------------------------------
--[029]
select @IsPlan=0
if @p_IsPlan not in ( "---", "", "_" )
    select @IsPlan = 1

--[065] --[070]
if ( @p_BLCSHTMTH_NF = 1 or @p_BLCSHTMTH_NF = 2 or @p_BLCSHTMTH_NF = 3 )
begin
        select @p_BLCSHTMTHT_NF = 3
end
if ( @p_BLCSHTMTH_NF = 4 or @p_BLCSHTMTH_NF = 5 or @p_BLCSHTMTH_NF = 6 )
begin
        select @p_BLCSHTMTHT_NF = 6
end
if ( @p_BLCSHTMTH_NF = 7 or @p_BLCSHTMTH_NF = 8 or @p_BLCSHTMTH_NF = 9 )
begin
        select @p_BLCSHTMTHT_NF = 9
end
if ( @p_BLCSHTMTH_NF = 10 or @p_BLCSHTMTH_NF = 11 or @p_BLCSHTMTH_NF = 12 )
begin
        select @p_BLCSHTMTHT_NF = 12
end

SELECT @End_D= Convert(Char(8), End_D, 112), @p_SPCENDT_D = Convert(Char(8), SPECEND_D, 112)
FROM BREF..TCALEND
WHERE BLCSHTYEA_NF = @p_BLCSHTYEA_NF
AND BLCSHTMTH_NF = @p_BLCSHTMTHT_NF

--[036] AJOUT PHP0907
--select @IsPOsocialEBS = 'N'
--select @IsPOconsoEBS = 'N'
--IF @ComptaSocialEBSDone = 0 AND @IsReqcodEqualT = 1
--BEGIN
--   select @IsPOsocialEBS = "Y"
--   from BEST..TREQJOB a, BREF..TCALEND b
--   where a.REQCOD_CT      =  'T'
--   AND   a.BALSHTMTH_NF   =  b.BLCSHTMTH_NF
--   AND   a.BALSHEYEA_NF   =  b.BLCSHTYEA_NF
--   AND   b.CLOSING_B      =  1
--   AND   a.LAUNCH_D       =  NULL
--   and   isnull(a.VRS_NF,0) = 1
--   AND   b.ACCOUNT_D      <  @p_CRE_D
--   AND   b.EBSPSTOMGEND_D >= @p_CRE_D
--END
--ELSE IF @ComptaSocialEBSDone = 1 AND @IsReqcodEqualT = 1
--BEGIN
--   select @IsPOconsoEBS = "Y"
--   from BEST..TREQJOB a, BREF..TCALEND b
--   where a.REQCOD_CT      =  'T'
--   AND   a.BALSHTMTH_NF   =  b.BLCSHTMTH_NF
--   AND   a.BALSHEYEA_NF   =  b.BLCSHTYEA_NF
--   AND   b.CLOSING_B      =  1
--   AND   a.LAUNCH_D       =  NULL
--   and   isnull(a.VRS_NF,0) = 1
--   AND   b.EBSPSTOMGEND_D <  @p_CRE_D
--END
--

-- ******
-- PLAN 0
-- ******
IF @p_CLONUM = 0
BEGIN
--- Top des GONOGO pour plan 0 -----------------------------------------------------------------
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWUJ0070" and    @variante in(1,2,3,4,5,6,7)        -- JR 05/09/2007  MOD24
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESCJ0000" and    @variante in(1,2,3,4,5,6,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESCJ0060" and    @variante in(1,2,3,4,5,6,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESCJ8990" and    @variante in(1,2,3,4,5,6,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESDJ0110" and    @variante in(1,2,3,4,5,6,7)        --[057]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESDJ1010" and    @variante in(1,2,3,4,5,6,7)        --[057]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESDJ5020" and    @variante in(1,2,3,4,5,6,7)        --[057] --[060] --[061]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESDJ5040" and    @variante in(1,2,3,4,5,6,7)        --[057]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESDJ7000" and    @variante in(1,2,3,4,5,6,7)        --[057]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESDJ7010" and    @variante in(1,2,3,4,5,6,7)        --[057]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESDJ8040" and    @variante in(1,2,3,4,5,6,7)        --[057]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESEJ0000" and    @variante in(1,  3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE like "ESEJ02?0" and    @variante in(1,2,3        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESEJ1000" and    @variante in(1,  3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESIJ1000" and    @variante in(    3        )        -- JR 17/01/03
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESIJ2000" and    @variante in(1,2,3,4,5,6,7)        -- [054]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESED0300" and    @variante in(1,  3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESEH1100" and    @variante in(1,  3,  5  ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESEH1110" and    @variante in(1,  3,  5  ,7)        --[030]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESEH1200" and    @variante in(1,  3      ,7)        --OG 18/11/03 ajout variante 7
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1000" and    @variante in(    3,  5  ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1010" and    @variante in(    3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1500" and    @variante in(    3,  5  ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1600" and    @variante in(    3        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1900" and    @variante in(    3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2030" and    @variante in(    3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2070" and    @variante in(    3      ,7)        -- [074]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID3020" and    @variante in(    3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESIJ0010" and    @variante in(1,2,3,4,5,6,7)        -- SL 2000-10-16
--    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8700" and     @variante in(    3,4,6    )      --[032] car export plan1 dans .env
--    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8800" and     @variante in(    3,4,6    )      --[031] ajout variante 5    -- Modif HV : Pas de V6     -- FC 2000-12-15  -- [032] remplacement 5 par 6  car export plan1 dans .env
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESRD0010" and    @variante in(    3,4      )        -- Modif HV : Pas de V6     -- FC 2000-12-15
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESRD0020" and    @variante in(    3,4      )        -- Modif HV : Pas de V6     -- OG 2001/06/12
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESIJ0090" and    @variante in(1,2,3,4    ,7)        -- [064]
                                                                 and    ( @p_PERTYP_CT = 'H' or
                                                                          ( @p_PERTYP_CT    =  'S' and
                                                                            @p_BLCSHTMTH_NF in (3,6,9,12)) )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESIJ7000" and    @variante in(1,2,3,4,5,6,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID0060" and    @variante in(    3,4,5,6,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID0070" and    @variante in(    3,4,  6,7)        --[030]  -- [032]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID0080" and    @variante in(    3,4,5,6,7)        --[030]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID0110" and    @variante in(    3,4,5,6,7)        --[055]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID0120" and    @variante in(    3,      7)        --[074] [083]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID0130" and    @variante in(    3,      7)        --[080] [083]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8030" and    @variante in(    3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID7000" and    @variante in(        5,6  )
                                                                 and    @p_ACCOUNT_D = @p_CRE_D
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID7050" and    @variante in(        5,6  )        --[032]
                                                                 and    @p_ACCOUNT_D = @p_CRE_D
    -- update #PLANNING set GONOGO="Y" where CHAINE =    "ESID7100"   and     @variante in(          6)     -- MOD014
    --[030] update #PLANNING set GONOGO="Y" where CHAINE =    "ESID7100"   and     @IsEpo =  'Y'  and     @IsEpoComptaRequestF = 'Y'  -- MOD21 SPOT13233 JR 03/10/2006

    --[025] on copie sur le ESID7000
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID7200" and    @variante in(        5,6  )
                                                                 and    @p_ACCOUNT_D = @p_CRE_D
    -- Modif HV : Pas de V5
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID7550" and    @variante in(          6  )
                                                                 and    @IsCOMPTA =  'Y'
                                                                 and    @Is31_12 = 'Y'
    -- Modif HV : Pas de V5
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8060" and    @variante in(          6  )
                                                                 and    @IsCOMPTA =  'Y'
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8100" and    @variante in(    3,4,6    )        --[058]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8120" and    @variante in(    3,4,6    )        --[062]
    -- Modif HV : Pas de V5
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8500" and    @variante in(          6  )
                                                                 and    @IsCOMPTA =  'Y'
                                                                 and    @Is31_12 = 'Y'
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8830" and    @variante in(          6  )        -- Modif HV : Pas de V5
		
	-- [082]
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD7500" and    @variante in(          5,6)
		
	-- [083] to revert [082]
	--update #PLANNING set GONOGO="Y" where CHAINE =    "STAD7500" and    @variante in(          6  )
    --                                                             and    @IsCOMPTA = 'Y'
    --                                                             and    @Is31_12 = 'Y'
	
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD1290" and    @variante in(        5,6  )        -- HG 200/10/09
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID9990" and    @variante in(          6  )
                                                                 and    @IsCOMPTA =  'Y'
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWUD0010" and    @variante in(    3,4      )        -- OG 06/05/2003 MOD01
                                                                 and    @p_BLCSHTMTH_NF in (3,6,9,12)      --MOD02
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWUD0030" and    @variante in(    3,4      )        -- OG 06/05/2003 MOD01
                                                               --and     @p_BLCSHTMTH_NF in (3,6,9,12)     --MOD02
    -- update #PLANNING set GONOGO="Y" where CHAINE =    "BTID0050" and     @variante in(    3,4 )         -- JR 16/12/2005 MOD16
    update #PLANNING set GONOGO="Y" where CHAINE =    "BTID0050" and    (@variante in(    3,4      )       -- JR 16/12/2005 MOD16
                                                                         --or  @IsReqcodEqualT = 1           -- M.DJ 08/02/2006 MOD018
                                                                         or @IsEpo =  'Y'                   -- PHP 0907
                                                                        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "BTID0090" and    (@variante in(    3,4      )       -- JR 25/09/2006 MOD20
                                                                         --or  @IsReqcodEqualT = 1
                                                                         or @IsEpo =  'Y'                   -- PHP 0907
                                                                        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWUD0130" and    (@variante in(1,2,3,4,5,6,7)       --[027] JR 29/08/2007 MOD23 [032] [059]
                                                                         --or  @IsReqcodEqualT = 1           --[027]
                                                                        -- or @IsEpo =  'Y'           -- PHP 0907  [059]
                                                                        )                                  --[027]
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWUD9130" and    (@variante in(1,2,3,4,5,6,7)       -- JR 11/12/2008 MOD26  --[027] [028] [032]  [059]
                                                                         --or  @IsReqcodEqualT = 1           --[027]                           [028]
                                                                        -- or @IsEpo =  'Y'           -- PHP 0907  [059]
                                                                        )                                  --[027]                           [028]
    --- TRAITEMENT ECRITURES POST OMEGA --- JR 01/07/2005 MOD10
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPT0000" and    @variante in(        6)

--- Top des conditions COND1 pour le plan 0 -----------------------------------------------------
    update #PLANNING set COND1="Y" where CHAINE =    "ESIJ0090" and     @variante in(      4    )          --[064]
    update #PLANNING set COND1="Y" where CHAINE =    "ESIJ0010" and     @variante in(      3,  7)          --[030]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID0060" and     @variante in(      4,  6)
    update #PLANNING set COND1="Y" where CHAINE =    "ESID0070" and     @variante in(      4,  6)          --[030]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID0080" and     @variante in(      4,  6)          --[030]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID7000" and     @IsCOMPTA =  'Y'
    update #PLANNING set COND1="Y" where CHAINE =    "ESID7050" and     @IsCOMPTA =  'Y'                   --[032]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID8060" and     @Is31_12 = 'Y'
    update #PLANNING set COND1="Y" where CHAINE =    "ESCJ8990" and     @p_CRE_D < @p_SPCEND_D
    update #PLANNING set COND1="Y" where CHAINE =    "ESEH1100" and     @variante in(1,     3)
    update #PLANNING set COND1="Y" where CHAINE =    "ESEH1110" and     @variante in(1,     3)             --[030]
    update #PLANNING set COND1="Y" where CHAINE =    "ESEH1200" and     @variante in(1,     3)
    --update #PLANNING set COND1="Y" where CHAINE =    "ESPT0000" and     @nb_NoEBS > 0                    jamais utilisé (063)
		-- Beg. [083] to revert [082]
		-- [082] 
    update #PLANNING set COND1="Y" where CHAINE =    "STAD7500" and     @variante in (6) and @IsCOMPTA =  'Y' and    @Is31_12 = 'Y'
		-- End [083] to revert [082]
--- Top des conditions COND2 pour le plan 0 -----------------------------------------------------
    update #PLANNING set COND2="Y" where CHAINE =    "ESID0060" and     @variante = 3
                                                                and     exists( SELECT NULL
                                                                                FROM BTRAV..TESTSSD
                                                                                where CLOTYP_B  != 1 )
    update #PLANNING set COND2="Y" where CHAINE =    "ESID0070" and     @variante = 3                      --[030]
                                                                and     exists( SELECT NULL
                                                                                FROM BTRAV..TESTSSD
                                                                                where CLOTYP_B  != 1 )
    update #PLANNING set COND2="Y" where CHAINE =    "ESID0080" and     @variante = 3                      --[030]
                                                                and     exists( SELECT NULL
                                                                                FROM BTRAV..TESTSSD
                                                                                where CLOTYP_B  != 1 )
    update #PLANNING set COND2="Y" where CHAINE =    "ESID7000" and     @Is31_12='Y'
    update #PLANNING set COND2="Y" where CHAINE =    "ESID7050" and     @Is31_12='Y'                       --[032]
    update #PLANNING set COND2="Y" where CHAINE =    "ESCJ8990" and     @IsCOMPTA =  'Y'

--- Top des conditions COND3 pour le plan 0 -----------------------------------------------------
    update #PLANNING set COND3="Y" where CHAINE =    "ESID0060" and     @variante in(         5,6)
    update #PLANNING set COND3="Y" where CHAINE =    "ESID0070" and     @variante in(         5,6)         --[030]
    update #PLANNING set COND3="Y" where CHAINE =    "ESID0080" and     @variante in(         5,6)         --[030]
    update #PLANNING set COND3="Y" where CHAINE =    "ESID7000" and     @variante in(           6)         --[030][067]
    update #PLANNING set COND3="Y" where CHAINE =    "ESID7050" and     @variante in(         5  )         --[032]
--    update #PLANNING set COND3="Y" where CHAINE =    "ESPD0060" and     @nb_NoEBS > 0 and @TypePOST = "SOCIAL"    -- PHP0907

--- Top des conditions COND4 pour le plan 0 -----------------------------------------------------
    update #PLANNING set COND4="Y" where CHAINE =    "ESID0060" and     @nb_NoEBS > 0                      --[036]

--- Top des conditions COND5 pour le plan 0 -----------------------------------------------------
-----------------------------------------------------------------------------------------------------------
END


-- ******
-- PLAN 1
-- ******
IF @p_CLONUM = 1
BEGIN
--- Top des GONOGO pour plan 1 -----------------------------------------------------------------
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID0560" and    @variante in(    3,4,    7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1520" and    @variante in(    3,4    ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1530" and    @variante in(    3,4    ,7)        -- JR 14/09/2004 MOD08
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1550" and    @variante in(    3,4      )        -- MD 27/04/2004 MOD05 - @variante in(    3      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID1800" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2000" and    @variante in(    3        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2010" and    @variante in(    3        )        -- [036] provisoire pour controles
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2020" and    @variante in(    3,4    ,7)        -- JR 14/09/2004 MOD08
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2040" and    @variante in(    3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2080" and    @variante in(    3      ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2050" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID4000" and    @variante in(    3,4    ,7)        -- JR 14/10/2004
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID4010" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2100" and    @variante in(    3        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2060" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2090" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2500" and    @variante in(    3        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2530" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESRD2530" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2550" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2560" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2590" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2600" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2800" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID2900" and    @variante in(    3,4      )
                                                                 and    @Is31_12 = 'Y'
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID3600" and    (@nb_NoEBS       > 0)           --[036] PHP0907
                                                                 and     @variante in(    3       )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID3700" and    (@nb_NoEBS       > 0)           --[036] PHP0907
                                                                 and     @variante in(    3       )
                                                                         -- @IsPOsocialEBS = 'Y' or lignes à supprimer
                                                                         -- @IsPOconsoEBS  = 'Y' )  lignes à supprimer
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID3800" and    @variante in(    3,4,5    )        --[031] ajout variante 5 [032] ajout 6
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID3810" and    @variante in(    3,4,5    )        --[086]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID3850"                                           --[044]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID3860" and    @variante in(    3,4,5,6  )        --[032]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID3900" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID7000" and    @variante in(        5,6  )        --[042]
                                                                 and    @p_ACCOUNT_D = @p_CRE_D
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID7050" and    @variante in(        5,6  )        --[032] [042]
                                                                 and    @p_ACCOUNT_D = @p_CRE_D
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8000" and    @variante in(    3        )
                                                                 and    @p_CLOTYP_CT = 'P'
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8040" and    @variante in(    3        )        --[057]
                                                                 and    (dateadd(dd, -15,@End_D) < @p_CRE_D                          --[065]
                                                                 and     @p_CRE_D < dateadd(dd,1,@p_SPCENDT_D ))                    --[065]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8050" and    @variante in(    3        )        --[056]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8100" and    @variante in(    3,4,6    )        --[058]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8120" and    @variante in(    3,4,6    )        --[062]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8530" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8600" and    @nb_NoEBS > 0                         --[050] PHP0907
                                                                 and    @variante in(    3        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8700" and    @variante in(    3,4,6    )        --[032]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8800" and    @variante in(    3,4,6    )        --[031] ajout variante 5 [032] Remplacement 5 par 6
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWED0010" and    @variante in(    3,4,  6  )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESID8900" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD1200" and    @variante in(    3,4    ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD1220" and    @variante in(          6  )
                                                                 and    @Is30_06 = 'Y'
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD1280" and    @variante in(    3,4    ,7)
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD1500" and    ((@variante in(  3,4    ,7) and   -- JR 05/04/2005 MOD09
                                                                          @Istrim = 'Y')
                                                                         or @Isplan = 1)                  --[029]
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD1530" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD1540" and    @variante in(    3,4      )       --[053]
    update #PLANNING set GONOGO="Y" where CHAINE =    "STAD1550" and    @variante in(    3,4    ,7)        -- JR 05/04/2005 MOD9
                                                                 and    @Istrim = 'Y'
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESRD0000" and    @variante in(    3        )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESRD0010" and    @variante in(    3,4      )
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESRD0020" and    @variante in(    3,4      )        -- OG 2001/06/12
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWUD0010" and    @variante in(    3,4      )        -- OG 06/05/2003 MOD01
                                                                 and    @p_BLCSHTMTH_NF in (3,6,9,12)      --MOD02
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWUD0030" and    @variante in(    3,4,6    )        -- OG 06/05/2003 MOD01 [032] ajout 6
                                                               --and    @p_BLCSHTMTH_NF in (3,6,9,12)      --MOD02

--- Top des conditions COND1 pour le plan 1 -----------------------------------------------------
    update #PLANNING set COND1="Y" where CHAINE =    "ESID0560" and     @variante in(      4)
    update #PLANNING set COND1="Y" where CHAINE =    "ESID1520" and     @variante in(      4)              --  MOD07
    update #PLANNING set COND1="Y" where CHAINE =    "ESID1550" and     @variante in(      4)              --  MOD07
    update #PLANNING set COND1="Y" where CHAINE =    "ESID1800" and     @variante in(      4)              --  MOD07
    update #PLANNING set COND1="Y" where CHAINE =    "ESID2000" and     @nb_NoEBS > 0                      -- [036]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID2010" and     @nb_NoEBS > 0                      -- [036]  provisoire pour controles
    update #PLANNING set COND1="Y" where CHAINE =    "ESID2050" and     @variante in(      4)
    update #PLANNING set COND1="Y" where CHAINE =    "ESID2060" and     (@IsSNEM = 'Y' or
                                                                         @variante in(     4      ))             -- MOD07
    update #PLANNING set COND1="Y" where CHAINE =    "ESID2500" and     @variante = 3
                                                                and     @p_CLOTYP_CT = 'P'
                                                                and     @Istrim = 'Y'                      -- [066]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID2550" and     @variante = 4
    update #PLANNING set COND1="Y" where CHAINE =    "ESID2560" and     (@IsSNEM = 'Y' or
                                                                         @variante in(     4      ))             -- MOD07
    update #PLANNING set COND1="Y" where CHAINE =    "ESID2800" and     @variante in(    3,4      )
                                                                and     @Is31_12 = 'Y'
    update #PLANNING set COND1="Y" where CHAINE =    "ESID3600" and     @nb_NoEBS > 0               -- [036] PHP0907
    --update #PLANNING set COND1="Y" where CHAINE =    "ESID3700" and     @nb_NoEBS > 0               -- [036] PHP0907 [058] plus d'EBS en variante 3
    update #PLANNING set COND1="Y" where CHAINE =    "ESID3800" and     @variante in(    3,4      )
                                                                and     @Is31_12= 'Y'
    update #PLANNING set COND1="Y" where CHAINE =    "ESID3810" and     @variante in(    3,4      )        --[086]
                                                                and     @Is31_12= 'Y'                      --[031]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID3850" and     @variante in(    3,4      )            --[031]
                                                                and     @Is31_12= 'Y'                      --[031]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID3860" and     @variante in(    3,4      )            --[032]
                                                                and     @Is31_12= 'Y'                      --[032]
    update #PLANNING set COND1="Y" where CHAINE =    "ESID8000" and     @variante = 3
                                                                and     (@Is31_12 = 'Y' or
                                                                         @nb_NoEBS > 0)                    -- [036]
    update #PLANNING set COND1="Y" where CHAINE =    "STAD1500" and     @variante in(          6  )        -- JR 05/04/2005 MOD09
                                                                and     @Istrim = 'Y'
    update #PLANNING set COND1="Y" where CHAINE =    "STAD1550" and     @variante in(    3,4      )

--- Top des conditions COND2 pour le plan 1 -----------------------------------------------------
    --update #PLANNING set COND2="Y" where CHAINE =    "ESID2060" and     @nb_NoEBS > 0                      -- [037] [058] plus d'EBS en variante 3
    update #PLANNING set COND2="Y" where CHAINE =    "ESID2500" and     (@Is31_12 = 'Y' or                 -- [048]
                                                                         @nb_NoEBS > 0 )
    --update #PLANNING set COND2="Y" where CHAINE =    "ESID2560" and     @nb_NoEBS > 0                      -- [037] [058] plus d'EBS en variante 3
    update #PLANNING set COND2="Y" where CHAINE =    "ESID3600" and     @TypePOST = 'CONSO '                -- [036] PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESID3700" and     @TypePOST = 'CONSO '                -- [036] PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESID3800" and     @variante = 4                      --  MOD07
    update #PLANNING set COND2="Y" where CHAINE =    "ESID3810" and     @variante = 4                      --[086]
    update #PLANNING set COND2="Y" where CHAINE =    "ESID3850" and     @variante = 4                      --[031]
    update #PLANNING set COND2="Y" where CHAINE =    "ESID3860" and     @variante = 4                      --[032]
    update #PLANNING set COND2="Y" where CHAINE =    "ESID3900" and     @variante = 4                      --  MOD07
    update #PLANNING set COND2="Y" where CHAINE =    "ESID8000" and     @variante = 3
                                                                and     @p_CLOTYP_CT = 'P'
                                                                and     @Istrim = 'Y'                      -- [066]
    update #PLANNING set COND2="Y" where CHAINE =    "STAD1500" and     @variante in(          6  )        -- JR 05/04/2005 MOD09
                                                                and     @Is31_12 = 'Y'

--- Top des conditions COND3 pour le plan 1 -----------------------------------------------------
    update #PLANNING set COND3="Y" where CHAINE =    "STAD1500" and     @variante in(    3,4,  6,7)
                                                                and     @Istrim = 'Y'
    update #PLANNING set COND3="Y" where CHAINE =    "ESID3800" and     @variante in(        5    )        --[031]
    update #PLANNING set COND3="Y" where CHAINE =    "ESID3810" and     @variante in(        5    )        --[086]
    update #PLANNING set COND3="Y" where CHAINE =    "ESID3850" and     @variante in(        5    )        --[031]
    update #PLANNING set COND3="Y" where CHAINE =    "ESID3860" and     @variante in(        5    )        --[032]

--- Top des conditions COND4 pour le plan 1 -----------------------------------------------------
    update #PLANNING set COND4="Y" where CHAINE =    "ESID3800" and     @variante in(     3       )        --[031]
                                                                and     @nb_NoEBS > 0

--- Top des conditions COND5 pour le plan 1 -----------------------------------------------------
-----------------------------------------------------------------------------------------------------------
END

-- ******
-- PLAN 2 Post-omega
-- ******
IF @p_CLONUM = 2
BEGIN
--- Top des GONOGO pour plan 2 -----------------------------------------------------------------
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWMD0000" and    @IsEpo =  'Y'                      -- JR 08/03/2007  MOD22
                                                                 and    @IsEpoComptaRequestF = 'Y'
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWPD0010" and    @IsEpo =  'Y'                      -- JR 01/07/2005  MOD10
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWPD0020" and    @IsEpo =  'Y'                      -- [051]
    update #PLANNING set GONOGO="Y" where CHAINE =    "DWPD1430" and    @IsEpo =  'Y'                      -- [051]

    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD0060" and    @IsEpo =  'Y'                      -- JR 01/07/2005  MOD10
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPJ0090" and    @IsEpo =  'Y'                      -- JR 01/07/2005  MOD10
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD1520" and    @IsEpo =  'Y'                      -- JR  28-09-2005 MOD013
                                                                 and    @ComptaSocialIFRSDone = 0              -- M.DJ 08/02/2006 MOD018
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD1800" and    @IsEpo =  'Y'                      -- JR 01/07/2005  MOD10
--    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD1900" and    @IsEpo =  'Y'                      -- JR 01/07/2005  MOD10 [063] retiré car existe plus
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD2000" and    @IsEpo =  'Y' and @nb_NoEBS > 0               -- [036] PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD2010" and    @IsEpo =  'Y' and @nb_NoEBS > 0               -- [036] PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD2050" and    @IsEpo =  'Y'               -- [058]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD2500" and    @IsEpo =  'Y'               -- [036] PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD2900" and    @IsEpo31_12 = 'Y'                  -- JR 01/07/2005  MOD10 [078]
                                                                 and    @IsEpoComptaRequestF  = 'Y'           -- MDJ 22/07/2005
                                                                 and    @TypePOST = "SOCIAL"
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD2550" and    @IsEpo =  'Y'         -- [036] PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD2570" and    @IsEpo =  'Y' and @nb_NoEBS > 0               -- [075]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD3700" and    @IsEpo =  'Y' and @nb_NoEBS > 0               -- [036] PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD3710" and    @IsEpo =  'Y' and @nb_NoEBS > 0               -- [073]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD8600" and    @IsEpo =  'Y' and @nb_NoEBS > 0               -- [036] PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD3800" and    (@IsEpo =  'Y' or                      -- JR 01/07/2005  MOD10 [078]
                                                                         (@IsEpoComptaRequestF = 'Y' and
                                                                          @TypePOST = "CONSO"))
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD3850"                                           --[044]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD3860" and    @TypePOST = "SOCIAL"               -- PHP 0907
                                                                 and    @nb_NoEBS = 0                           --[041]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD3900" and    @TypePOST = "SOCIAL"               -- PHP 0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD4000" and    @IsEpo =  'Y'         -- [036] PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD7000" and    @IsEpo =  'Y'                      -- JR 01/07/2005  MOD10
                                                                 and    @ComptaSocialIFRSDone = 0         -- M.DJ 08/02/2006 MOD018
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD8000" and    @IsEpo =  'Y'                      -- [078]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD8050" and    @IsEpo =  'Y' and @nb_NoEBS > 0        -- [056]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD8100" and    @IsEpo =  'Y'                      -- [058]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD8700" and    @TypePOST = "SOCIAL"               -- PHP 0907
                                                                 and    @nb_NoEBS = 0
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD8800" and    @TypePOST = "SOCIAL"               -- PHP 0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD8830" and    @IsEpoComptaRequestF = 'Y'            -- MDJ 22/07/2005
                                                                 and    @TypePOST = "SOCIAL"                  -- [063] pas en mode Conso [078]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD8900" and    @TypePOST = "SOCIAL"               -- PHP 0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPJ8990" and    @IsEpo =  'Y'                      -- MDJ 22-07-2005 MOD011
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESPD9990" and    @IsEpo =  'Y'                      -- JR 08-09-2005  MOD012
                                                                 and    @IsEpoComptaRequestF = 'Y'
                                                                 and    @ComptaSocialIFRSDone = 0         -- PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "STPD0020" and    @IsEpo =  'Y'                      -- JR 09/11/2005  MOD15
                                                                 and    @IsEpoComptaRequestF = 'Y'
                                                                 and    @ComptaSocialIFRSDone = 0         -- PHP0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "STPD1200" and    @TypePOST = "SOCIAL"               -- PHP 0907
                                                                 and    @ComptaSocialIFRSDone = 0          -- PHP 0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "STPD1280" and    @TypePOST = "SOCIAL"               -- PHP 0907
                                                                 and    @ComptaSocialIFRSDone = 0          -- PHP 0907
    update #PLANNING set GONOGO="Y" where CHAINE =    "STPD1500" and    @TypePOST = "SOCIAL"               -- PHP 0907
                                                                 and    @ComptaSocialIFRSDone = 0          -- PHP 0907

--- Top des conditions COND1 pour le plan 2 -----------------------------------------------------
    update #PLANNING set COND1="Y" where CHAINE =    "DWPD0010" and     @TypePOST = "CONSO "              -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESLD8830" and     @IsEpo =  'Y'                      -- [068]
                                                                and     @IsEpo31_12 = 'Y'
                                                                and     @IsEpoComptaRequestF = 'Y'
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD0060" and     @TypePOST = "SOCIAL"                -- PHP0907 [040]
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD1800" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD2000" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD2010" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD2500" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD2550" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD2900" and     @TypePOST = "SOCIAL"                -- [063]
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD3700" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD3800" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD3900" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD3850" and     @TypePOST = "SOCIAL"                 -- PHP 0907 [044]
                                                                and     @nb_NoEBS = 0                             -- [041]
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD3860" and     @IsEpo =  'Y'                             -- [050]
                                                                and     @IsEpoComptaRequestF = 'Y'
                                                                and     @nb_NoEBS = 0
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD4000" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD8100" and     @nb_NoEBS > 0                             -- [058]
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD8600" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD8800" and     @TypePOST = "SOCIAL"                -- PHP0907
    update #PLANNING set COND1="Y" where CHAINE =    "ESPD8830" and     @IsEpo31_12 = 'Y'                  -- JR 01/07/2005  MOD10
                                                                and     @IsEpoComptaRequestF = 'Y'            -- MDJ 22/07/2005

--- Top des conditions COND2 pour le plan 2 -----------------------------------------------------
    update #PLANNING set COND2="Y" where CHAINE =    "DWPD0010" and     @nb_NoEBS > 0                       -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD0060" and     @nb_NoEBS > 0                -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD1800" and     @nb_NoEBS > 0               -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD2000" and     @nb_NoEBS > 0                       -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD2010" and     @nb_NoEBS > 0                       -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD2500" and     @nb_NoEBS > 0                       -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD2550" and     @nb_NoEBS > 0                       -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD2900" and     @nb_NoEBS > 0
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD3700" and     @nb_NoEBS > 0                       -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD3800" and     @nb_NoEBS > 0                                 
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD3850" and     @TypePOST = 'CONSO '                -- [050]
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD3900" and     @nb_NoEBS > 0                       -- [036]
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD4000" and     @nb_NoEBS > 0                       -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD8100" and     @TypePOST = 'CONSO '                -- [058]
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD8600" and     @nb_NoEBS > 0                       -- PHP0907
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD8800" and     @nb_NoEBS > 0
    update #PLANNING set COND2="Y" where CHAINE =    "ESPD8830" and     @nb_NoEBS > 0

--- Top des conditions COND3 pour le plan 2 -----------------------------------------------------
    update #PLANNING set COND3="Y" where CHAINE =    "ESPD0060" and     @nb_NoEBS > 0                       -- [035] PHP
                                                                and     @ComptaSocialEBSDone = 0
                                                               and     @ComptaSocialIFRSDone = 1           -- [036]
    update #PLANNING set COND3="Y" where CHAINE =    "ESPD2000" and     @IsEpo31_12 = 'Y'                   -- PHP0907
    update #PLANNING set COND3="Y" where CHAINE =    "ESPD2010" and     @IsEpo31_12 = 'Y'                   -- PHP0907
    update #PLANNING set COND3="Y" where CHAINE =    "ESPD2550" and     @ComptaSocialLastDay  = 'N'         -- PHP0907 [046]
    update #PLANNING set COND3="Y" where CHAINE =    "ESPD3700" and     @IsEpo31_12 = 'Y'                   -- PHP0907
    update #PLANNING set COND3="Y" where CHAINE =    "ESPD3800" and     @ComptaSocialIFRSDone = 1           -- [036]

--- Top des conditions COND4 pour le plan 2 -----------------------------------------------------
    update #PLANNING set COND4="Y" where CHAINE =    "ESPD3800" and     @IsEpoComptaRequestF = 'Y'            -- [063]

--- Top des conditions COND5 pour le plan 2 -----------------------------------------------------
    update #PLANNING set COND5="Y" where CHAINE =    "ESPD3800" and     @ComptaSocialEBSDone = 1            -- [063]

-----------------------------------------------------------------------------------------------------------
END

IF @p_CLONUM = 3
BEGIN
--- Top des GONOGO pour plan 3 -----------------------------------------------------------------

    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD1800" and    @IsESLOC =  'Y'                    -- [068]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD1900" and    @IsESLOC =  'Y'                    -- [068]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD2900" and    @IsESLOC =  'Y'                    -- [068]
--                                                                 and    @IsEpo31_12 = 'Y'                  -- [068] [084]
--                                                                 and    @IsEpoComptaRequestF = 'Y'         -- [068] [084]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD3800" and    @IsESLOC =  'Y'                    -- [068]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD3850"                                           -- [068] [071]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD3860" and    @IsESLOC =  'Y'                    -- [068]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD8100" and    @IsESLOC =  'Y'                    -- [068]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD8700" and    @IsESLOC =  'Y'                    -- [068]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLD8830" and    @IsESLOC =  'Y'                    -- [068]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLJ0090" and    @IsESLOC =  'Y'                    -- [068]
    update #PLANNING set GONOGO="Y" where CHAINE =    "ESLJ8990" and    @IsESLOC =  'Y'                    -- [068]

--- Top des conditions COND1 pour le plan 3 -----------------------------------------------------

-----------------------------------------------------------------------------------------------------------
END

if (@IsESLOC = "Y")
begin
  Select @IsEpo = "Y"
end

select @Title="# Variant Number : " + convert(char,@variante)

if @Is31_12 = "Y"
    select @Title = @Title + "; 31/12=Y "
else
    select @Title = @Title + "; 31/12=N "

if @IsP31_12 = "Y"
    select @Title = @Title + "; Principal 31/12 "


select @Title

UNION ALL

select 'export EST_VARIANTE=' + convert(char,@variante)

UNION ALL        --[033]

select 'export EST_LASTPOBOOKING=' + @IsEpoComptaRequestF   --[033]


UNION ALL
select "# ---------------------------------------------------- ---------------   "
UNION ALL
select "#  "
select "# GONOGO CONDITIONS "
UNION ALL
select "# ------------------------------------------------------------------ "
UNION ALL
select 'export EST_' + CHAINE + '_GONOGO=' + '"' + GONOGO + '"'  from #PLANNING
UNION ALL
select ""

UNION ALL
select "# DELETE CONDITIONS  "
UNION ALL
select "# ------------------------------------------------------------------ "
UNION ALL
select 'export EST_' + CHAINE + '_DELETE=' + '"' + DEL+ '"'  from #PLANNING
UNION ALL
select ""

UNION ALL
select "# COND1 CONDITIONS "
UNION ALL
select "# ------------------------------------------------------------------ "
UNION ALL
select 'export EST_' + CHAINE + '_COND1=' + '"' +  COND1 + '"'  from #PLANNING
UNION ALL
select ""

UNION ALL
select "# COND2 CONDITIONS "
UNION ALL
select "# ------------------------------------------------------------------ "
UNION ALL
select 'export EST_' + CHAINE + '_COND2=' + '"' +  COND2 + '"'  from #PLANNING
UNION ALL
select ""

UNION ALL
select "# COND3 CONDITIONS "
UNION ALL
select "# ------------------------------------------------------------------ "
UNION ALL
select 'export EST_' + CHAINE + '_COND3=' + '"' +  COND3 + '"'  from #PLANNING
UNION ALL
-- [036]
select ""
UNION ALL
select "# COND4 CONDITIONS "
UNION ALL
select "# ------------------------------------------------------------------ "
UNION ALL
select 'export EST_' + CHAINE + '_COND4=' + '"' +  COND4 + '"'  from #PLANNING
UNION ALL
select ""
-- [063]
UNION ALL
select "# COND5 CONDITIONS "
UNION ALL
select "# ------------------------------------------------------------------ "
UNION ALL
select 'export EST_' + CHAINE + '_COND5=' + '"' +  COND5 + '"'  from #PLANNING
UNION ALL
select 'export p_CONSOMTH=' + convert(char(2),@p_CONSOMTH)
UNION ALL
select 'export p_CONSOYEA=' + convert(char(4),@p_CONSOYEA)
UNION ALL
select 'export ComptaSocialIFRSDone=' + convert(char,@ComptaSocialIFRSDone)
UNION ALL
select 'export ComptaSocialEBSDone=' + convert(char,@ComptaSocialEBSDone)
UNION ALL
select 'export IsEpo=' + @IsEpo
UNION ALL
select 'export TypePOST=' + @TotalPOST                -- [068]
UNION ALL
select 'export EBS  nb_NoEBS=' + convert(char,@nb_NoEBS)
UNION ALL
select 'export IsEpoComptaRequestF=' + @IsEpoComptaRequestF
UNION ALL
select ""

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end

drop table #PLANNING

return 0
go
EXEC sp_procxmode 'dbo.PsPlan_02', 'unchained'
go
IF OBJECT_ID('dbo.PsPlan_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPlan_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPlan_02 >>>'
go
GRANT EXECUTE ON dbo.PsPlan_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPlan_02 TO GDBBATCH
go
