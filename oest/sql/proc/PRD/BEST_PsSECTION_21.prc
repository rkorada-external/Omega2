USE BEST
go
IF OBJECT_ID('dbo.PsSECTION_21') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSECTION_21
    IF OBJECT_ID('dbo.PsSECTION_21') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSECTION_21 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSECTION_21 >>>'
END
go
create procedure PsSECTION_21
(
@p_segtyp_ct char(1),
@p_ssd_cf    USSD_CF
)
with execute as caller as
/***************************************************
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: Descente du périmètre rétrocession vie au niveau CASEX
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: M.Ha-Thuc
Date: 12/03/98
Description: - recherche des zones SOB, TOP, territorialité, type comptable et garantie et rajout de 2 champs supplémentaires au périmètre
        - USRCRTCOD_CT ( code du critère utilisateur acceptation )
        - USRCRTVAL_LM ( valeur du critère utilisateur acceptation )
_________________
MODIFICATION 2
Auteur: M.Ha-Thuc
Date: 15/09/98
Description: - rajout de champs supplémentaires (non utilisés) pour conserver une structure identique à tous les périmètres.
_________________
MODIFICATION 3
Auteur: M.Bourdaillet
Date: 05/03/1999
Description: Rajout de six champs pour la segmentation client. Mais pour ce perimetre les champs n'ontpas besoin d'etre renseignés; ils sont donc forces à null
_________________
MODIFICATION 4
Auteur: O.Arik(AURA)
Date: 30/03/2001
Description: Ajout de RECBRK_B (Indic d'existance de courtage sur REC) et de RECBRK_R (taux de court. sur reconstitution) dans le select. on renseigne les champs CTRINC_D et CAN_DT dans le select.
_________________
MODIFICATION 5
Auteur:  J. Ribot
Date: 01/07/2003
Description: Ajout de null pour CNATYP_CT  modif 005
_________________
MODIFICATION 6
Auteur:  J. Ribot
Date: 07/04/2005
Description: Ajout de 4 champs a zero pour new infocentre vie  TLIFSTAREP   modif 006 (CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B)
_________________
MODIFICATION 7
Auteur:  D. Chetboul
Date: 16/08/2011
Description: :spot:22459 Ajout du champ filler (null) pour compléter le champ manquant lors de la fusion
_________________
7  11/01/2013 Roger Cassis :spot:24041 pour Livraison solvency 2
8                          Removed dbo and added 'with execute as caller as'
9  03/04/2014 R.BEN EZZINE Ajout du code crible dans le IARPERICASE
10 20/11/2014 Florent      :spot:27747 Multi Currency - ajout colonnes sur le périmètre
                           :spot:27748 Loss Corridor  - ajout colonnes sur le périmètre
11 25/03/2015 spot:28465 S.ASKRI Est29a, devise au niveau de la section
12 P. Menant     02/03/2015 :spot:28306 EST37
[13] R. BEN EZZINE :spot 29380 : Ajouter l'indicateur des terminés comptable Retro
[014] S.Behague     16/08/2016 :spot:31066 Spira 52504 - Prise en compte poste PMD
[019] S.Behague     20/09/2019 :spira:60627 - PPrise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro
[020] B.LAGHA   08/10/2020     :spira:84688 - ajout du champ CTREXP_D dans l'extraction afin de faire la difference entre les contrats time-shifted et autre.
[021] B.LAGHA   22/01/2021     :spira:91085 - Get ASSFINANCE_CT value 
*****************************************************/
declare @erreur int

----------------------------------------------
-- Périmètre de souscription rétrocession vie
---------------------------------------------
-- Affichage
-- Cas multifiliale
-- La liste des filiales est dans la table BTRAV..TESTSSD
-- Le filtre est fait sur la date maximum du libelle d'inventaire passee en paramètre
if @p_ssd_cf = 00
begin
-- Affichage du périmètre rétrocession vie
select
    RETSEC.SSD_CF,
    null,
    RETSEC.RETCTR_NF,
    0,
    RETSEC.RETSEC_NF,
    RETSEC.RTY_NF,
    1,
    ESB_CF,
    null,
    null,
    convert(char(8), CAN_DT, 112), -- ce champs est renseigné à partir de la modif(004) 30/03/2001
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    convert(char(8), CTRINC_D, 112), -- ce champs est renseigné à partir de la modif(004) 30/03/2001
    null,
    null,
    null,
    null,
    RETCTR.ESTCRB_CT,  -- [009]  --convert(char(1), " "),
    null,
    null,
    null,
    convert(char(8), RETCTR.CTREXP_D, 112), -- [020]
    null,
    null,
    null,
    RETSEC.GAR_CF, -- recuperation du champs à partir de TRETSEC; modif du 12/03/98
    null,
    null,
    null,
    null,
    null,
    LOB_CF,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    NAT_CF,
    null,
    case when ( RETSPECUR_CF is null or RETSPECUR_CF = ' ' ) then RETPCPCUR_CF
     else RETSPECUR_CF
     end,
    --RETPCPCUR_CF, REcuperer la devise du contrat si celle de la section n'existe pas, EST29a-R1
    RETSEC.PCPRSKTRY_CF, -- recuperation du champs à partir de TRETSEC; modif du 12/03/98
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETSEC.SOB_CF, -- recuperation du champs à partir de TRETSEC; modif du 12/03/98
    null,
    null,
    RETSEC.TOP_CF, -- recuperation du champs à partir de TRETSEC; modif du 12/03/98
    CTRNAT_CF = case when RETSEC.nat_cf in ('10','11','12','20','21','22','23') then 'P' else  'N' end,  --null, -- SBE A ajouter CTRNAT
    null,
    PROPER_N,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETACCTYP_CT,
    null,
    RETCTRSTS_CT,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    RETCTRCAT_CF,
    CLECUTPER_B,
    CLECUTPER_NB,
    ORICUR_B,
    RETACCADM_B,
    SSDRTO_B,
    RAICOM_B,
    null,
    RETSEC.USRCRTCOD_CT,    -- Champ rajouté au perimètre, modif du 12/03/98
    RETSEC.USRCRTVAL_LM,    -- Champ rajouté au perimètre, modif du 12/03/98
    null,   -- Champs acceptation non utilisé en rétro, modif du 26/03/98
    null,   -- Champs acceptation non utilisé en rétro, modif du 26/03/98
    null,   -- Champ acceptation non utilisé en rétro, modif du 26/05/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé en rétro, modif du 15/09/98
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,   -- Champ non utilisé (segmentation client), modif 003
    null,    -- Champ non utilisé (segmentation client), modif 003
    0,             --MODIF 008
    null,          --MODIF 009
    null,   -- Champ non utilisé, modif 004
    null,    -- Champ non utilisé, modif 004
    null,    -- Champ pour CNATYP_CT , modif 005 JR
    0,       -- CLMCUTOFF_B,         MODIF 006 JR
    0,       -- PRMCUTOFF_B,         MODIF 006 JR
    0,       -- CLMRUNOFF_B,         MODIF 006 JR
    0       -- PRMRUNOFF_B          MODIF 006 JR
   ,RETSEC.ASSFINANCE_CT --[021] --MODIF 007 Dch
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
   ,STLREQDEL_N                                                                  --MODIF 12
   ,"RET"                                                                        --MODIF 12
   ,convert(char(8), CTRINCUWY_D, 112)                                           --MODIF 12
   ,ESTV2C_COL_14=null
   ,ESTV2C_COL_15=null
   ,TERCTR_B  -- ESTV2C_COL_16=null [13]
   ,ESTV2C_COL_17=null
   ,RACCCOND.ACCFRQ_CT                                -- [014]
   ,convert ( char (8), FAMPRE.FIRPAYDUE_D, 112)      -- [014]
   ,case when ( RETCTR.CLOFAM_CT = 'null' ) then null else RETCTR.CLOFAM_CT end
   ,RETCTR.ACCFAM_CT
   ,ESTV2C_COL_22=null
   ,ESTV2C_COL_23=null
   ,ESTV2C_COL_24=null
   ,ESTV2C_COL_25=null
   ,ESTV2C_COL_26=null
   ,ESTV2C_COL_27=null
   ,ESTV2C_COL_28=null
   ,ESTV2C_COL_29=null
   ,ESTV2C_COL_30=null
   from BRET..TRETSEC RETSEC, BRET..TRETCTR RETCTR, BTRAV..TESTSSD ESTSSD, BRET..TRACCCOND RACCCOND, BRET..TRFAMPRE FAMPRE
    where RETSEC.SSD_CF=ESTSSD.SSD_CF
      and (RETCTRSTS_CT=3 or RETCTRSTS_CT=19)
      and (LOB_CF='30' or LOB_CF='31')
      and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF and RETSEC.RTY_NF=RETCTR.RTY_NF
      and RETSEC.RETCTR_NF*=RACCCOND.RETCTR_NF
      and RETSEC.RETCTR_NF*= FAMPRE.RETCTR_NF and RETSEC.RTY_NF*= FAMPRE.RTY_NF and RETSEC.RETSEC_NF*= FAMPRE.RETSEC_NF
end
select @erreur = @@error
if @erreur != 0
begin
  return @erreur
end
return 0
go
EXEC sp_procxmode 'dbo.PsSECTION_21', 'unchained'
go
IF OBJECT_ID('dbo.PsSECTION_21') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSECTION_21 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSECTION_21 >>>'
go
GRANT EXECUTE ON dbo.PsSECTION_21 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_21 TO GDBBATCH
go
