use BEST
go
if object_id('PsSECTION_46') is not null
begin
  drop PROC PsSECTION_46
  print '<<< DROPPED PROC PsSECTION_46 >>>'
end
go
create procedure PsSECTION_46
(
@p_segtyp_ct char(1)
)
with execute as caller as
/***************************************************
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME67 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: Descente du périmètre rétrocession dommages au niveau CASEX des affaires non comptabilisables ( perimetre complementaire a celui descendu par la procedure PsSECTION_08 ).
Conditions d'execution:
Commentaires:
_______________
MODIFICATIONS
1  M.Ha-Thuc     15/09/1998 rajout de champs supplémentaires (non utilisés) pour conserver une structure identique à tous les périmètres.
2  M.Bourdaillet 05/03/1999 Rajout de six champs pour la segmentation client. Mais pour ce perimetre les champs n'ontpas besoin d'etre renseignés; ils sont donc forces à null
9  O.Arik(AURA)  30/03/2001 Ajout de RECBRK_B (Indic d'existance de courtage sur REC) et de RECBRK_R (taux de court. sur reconstitution) dans le select. on renseigne les champs CTRINC_D et CAN_DT dans le select.
10 D. Chetboul   16/08/2011 :spot:22459 Ajout du champ filler (null) pour compléter le champ manquant lors de la fusion
11 Roger Cassis  11/01/2013 :spot:24041 pour Livraison solvency 2
12                          MODIFICATION "Removed dbo and added 'with execute as caller as'"
13 Florent       20/11/2014 :spot:27747 Multi Currency - ajout colonnes sur le périmètre
                            :spot:27748 Loss Corridor  - ajout colonnes sur le périmètre

14 S.ASKRI       28/04/2015 :spot:28465 EST29a-R1
15 P. Menant     02/03/2015 :spot:28306 EST37
[016] S.Behague     16/08/2016 :spot:31066 Spira 52504 - Prise en compte poste PMD
[017] S.Behague     20/09/2019 :spira:60627 - PPrise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro
*****************************************************/
declare @erreur int

select  @erreur = 0
-- Périmètre rétrocession non vie
-- Affaires non comptabilisables
-- Cas multifiliale ( car on est dans l inventaire )
-- La liste des filiales est dans la table BTRAV..TESTSSD
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
  convert(char(8), CAN_DT, 112), -- ce champs est renseigné à partir de la modif(009) 30/03/2001
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  convert(char(8), CTRINC_D, 112), -- ce champs est renseigné à partir de la modif(009) 30/03/2001
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
  isnull(RETSPECUR_CF,RETPCPCUR_CF), --RETPCPCUR_CF, REcuperer la devise du contrat si celle de la section n'existe pas, EST29a-R1
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
  RETCTR.RETACCTYP_CT, -- recuperation du champs à partir de TRETCTR; modif du 12/03/98
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
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé, modif du 15/09/98
  null,   -- Champ non utilisé (segmentation client), modif 008
  null,   -- Champ non utilisé (segmentation client), modif 008
  null,   -- Champ non utilisé (segmentation client), modif 008
  null,   -- Champ non utilisé (segmentation client), modif 008
  null,   -- Champ non utilisé (segmentation client), modif 008
  null,    -- Champ non utilisé (segmentation client), modif 008
  0,
  null,
  null,   -- Champ non utilisé, modif 009
  null,    -- Champ non utilisé, modif 009
  null    --  champ non utilisé , modif 010 Dch
 ,CLMCUTOFF_B=null
 ,PRMCUTOFF_B=null
 ,CLMRUNOFF_B=null
 ,PRMRUNOFF_B=null
 ,ASSFINANCE_CT=null
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
 ,STLREQDEL_N                                                                  --MODIF 11
 ,"RET"                                                                        --MODIF 11
 ,convert(char(8), CTRINCUWY_D, 112)                                           --MODIF 11
 ,ESTV2C_COL_14=null
 ,ESTV2C_COL_15=null
 ,ESTV2C_COL_16=null
 ,ESTV2C_COL_17=null
   ,RACCCOND.ACCFRQ_CT                                -- [016]
   ,convert ( char (8), FAMPRE.FIRPAYDUE_D, 112)      -- [016]
 ,RETCTR.CLOFAM_CT
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
    and RETCTRSTS_CT not in ( 3, 19 ) -- on descend les affaires non comptabilisables
    and LOB_CF<>'30' and LOB_CF<>'31'
    and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF and RETSEC.RTY_NF=RETCTR.RTY_NF
    and RETSEC.RETCTR_NF*=RACCCOND.RETCTR_NF
    and RETSEC.RETCTR_NF*= FAMPRE.RETCTR_NF and RETSEC.RTY_NF*= FAMPRE.RTY_NF and RETSEC.RETSEC_NF*= FAMPRE.RETSEC_NF
select @erreur = @@error
if @erreur != 0
begin
  return @erreur
end
return 0
go
if object_id('PsSECTION_46') is not null
  print '<<< CREATED PROC PsSECTION_46 >>>'
else
  print '<<< FAILED CREATING PROC PsSECTION_46 >>>'
go
grant execute on PsSECTION_46 TO GOMEGA, GDBBATCH
go
