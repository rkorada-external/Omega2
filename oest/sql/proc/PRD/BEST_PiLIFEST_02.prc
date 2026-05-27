use BEST
go
create TABLE #contrat_depasse_seuil_tmp(CTR_NF UCTR_NF NOT null, SEC_NF USEC_NF NOT null,  ACY_NF Smallint NOT null)
go
if object_id('PiLIFEST_02') is not null
begin
    DROP PROCEDURE PiLIFEST_02
    IF OBJECT_ID('PiLIFEST_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PiLIFEST_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PiLIFEST_02 >>>'
end
go
create procedure PiLIFEST_02
  (
  @p_usr_cf   Char(5)
 ,@p_ssd_cf_c Char(2)
 ,@p_esb_cf_c Char(2)
  )
with execute as caller as
/***************************************************
Programme               : PiLIFEST_02
Fichier script associé  : iLIFEST_02.prc
Domaine                 : Estimations
Base principale         : BEST
Version                 : 1
Auteur                  : ME26 avec Infotool version 2.0 (AUTO)
Date de creation        :
Description du programme:
Parametres              :
_________________
MODIFICATIONS
1  G.FOUILLEUL 21/05/2003 mail PP : on avait anticipé un mode de fonctionnement dans le chargement des estimations pour les dépots. on a dit que qq
                          soit le type comptable du contrat on traitait les libérations de dépot que comme si on était sur un type 2 (c'est à dire
                          libération sur même exercice). on devait aussi modifier l'existant TP, batch, et faire une reprise. on a pas eu le temps.
                          ==> on revient en arrière et on traite les dépôts comme les autres provisions c'est à dire qu'il suivent le type
                          comptable du traité : les dépots prime (x303,x304) rentre dans la catégOrie des provisions primes (donc pour type 1 et 3
                          libération en exercice+1) les dépots sinistre (x323,x324) rentre dans la catégOrie des provisions sinistre (donc pour
                          type 1 libération en exercice +1)
2  G.FOUILLEUL 20/09/2003 Pour charger tlifdri, l'acy sert à alimenter l'acy et l'uwy
3  G.FOUILLEUL 20/09/2003 En cas d'ano blocante, le code-retour ne doit pas etre 1
4  G.FOUILLEUL 20/09/2003 Optimisation
5  G.FOUILLEUL 30/09/2003 on ne supprime plus les controles à 0
6  G.BUISSON   01/06/2005 :spot:10543 on ajoute l'EX et l'AC du mouvement dans les anomalies
7  G.BUISSON   21/06/2005 :spot:11083 Il ne faut pas génerer les libérations en AC=B + 2 sur les provisions non vie
8  G.FOUILLEUL 22/03/2006 :spot:12664 Affinage erreur 124 pour les postes rétro
9  G.BUISSON   04/09/2006 :spot:12720 Le code MAJ AUTO des traités acceptation (tlifdri) dépend de la rétro interne (0 si rétro interne, 1 sinon)
10 G.BUISSON   04/10/2006 :spot:12018 Les postes de libération des ventilations de provisions non vie ne doivent plus pouvoir être chargés (1504, 1524, 1534, 1604,
                          1624, 1634, 2504, 2524, 2534, 2604, 2624, 2634). Ils doivent entraîner l'anomalie 118
11 G.Fouilleul 13/12/2006 :spot:13545 Affinage du test pour ano 119.
12 D.Ourmiah   07/06/2007 :spot:13609 Autoriser le chargement de CNA avec MAJ auto et compte complet
13 G.BUISSON   21/11/2007 :spot:14688 Création des postes VOBA
14 G.BUISSON   21/11/2007 :spot:14161 Problème sur la ventilation des PTC non vie en rétro Réactivation des 2083/2603, 2623, 2633
15 J.Ribot     13/03/2008 Ajout d'un order by après le group by en respectant les mêmes champs
16 G.BUISSON   28/03/2008 :spot:14160 Il faut générer des postes à zéro pour compléter la ventilation Non Vie
17 G.BUISSON   29/04/2008 :spot:15357 La PCPCUR_CF doit se prendre systématiquement sur le dernier exercice en acceptation comme en rétro
18 G.BUISSON   07/05/2008 Mise au point : Quand on insère dans #regroup_last à partir de TLIFEST, il ne faut prendre que
                          les ventilations que l'on vient de créer (celles dont CRE_D > ESTCRELAST_D
19 G.BUISSON   04/06/2008 :spot:15357 Changement dans la récupération des postes ventilés : on ne fait plus appel à TLIFEST, on ne les prend qu'à partir du fichier chargé
20 G.BUISSON   05/12/2008 :spot:16565 Ajout d'un set ForcePlan on et off lors de la mise à jour du CLISSD_CF car le plan en production était mauvais et la proc durait 50 minutes
21 D.OURMIAH   18/05/2009 :spot:14878 Nouveau message d'erreur (133)  pour des postes groupés ne correspondant pas au type de contrats
22 D.OURMIAH   25/05/2009 :spot:17320 Nouveau message d'erreur (134)  Interdire chargement de contrats avec sections rétro non-comptables
23 D.GATIBELZA 12/08/2009 :spot:17147 Bloquer la possibilité de charger des estimations de CNA sur traités terminés
24 JF VDV      14/10/2009 :spot:18044 Adapter les messages d'erreur pour le chargement ESTIMATION RETRO (revoir sens des montants)
25 Tony RIPERT 25/08/2010 :spot:16259 Génération fiche mouvement
26 Tony RIPERT 04/10/2010 :spot:18235  sum at Risk
27 Tony RIPERT 04/10/2010 Ajout la VOBA
28 Tony RIPERT 20/10/2010 Interdire le 1011 pour les PROP
29 Tony RIPERT 07/12/2010 Interdire les 1543/1093 2543/2093 et idem finissant par 4
30 Tony RIPERT 25/01/2011 Interdire Retro Mise à jour automatique
31 Tony RIPERT 25/01/2011 Interdire CNA TYPE 47 ou VIDE
32 D.GATIBELZA 01/03/2011 :spot:21542 pb de chargement des estimations
33 T.RIPERT    23/03/2011 :spot:21699 pb de chargement des estimations à cause de multi devises dans le fichier de chargement
                          Ajout la section dans la #ref pour prendr en compte la devise par section optimisation requete summ risk + fiche mouvement
34 T.RIPERT    23/03/2011 :spot:21699 CNATYP_CT=3 pour filiale 14
35 Florent     19/01/2012 :spot:22135 gestion libérations => FtLiberationExeP1
36 Florent     07/03/2012 :spot:23503 Modification du chargement des estimations en type 3 et 5 pour harmoniser les contrôles avec ceux de la saisie (PB+dépôts sap+intérêts)
37 Florent     15/10/2013 :spot:25618 correction jointure section ano 105
38 Florent     15/10/2013 :spot:25802 ajout arrondi !
--------------------------------------------------- :spot:25897 ajout des modifs de la 2A - 9 janvier 2014 ---------------------------------------------------------
39 Kbagwe      16/04/2013 :Modification for obsolute table TACMTRSH -> TACMTRSL
40 abdulwsh    30/04/2013 :Substring removal. Replaced with SSD_CF. Prefix Modif 40
						   @ssd_nf should be replaced by @p_ssd_cf. Prefix Modif 40
						   @ssd_nf was used to compare Substring(ESID0811.CTR_NF, 1, 2) (char (2)). Prefix Modif 40
						   Now, we are comparing with TCONTR.SSD_CF which is an int: we dont need to convert this variable anymore. Prefix Modif 40	
41 ksugandh    16/10/2013 :Movied for EST55 EVOCARD. Retrieve records exceeding threshold						   
42 vinpawar	   25/07/2013 :Removed dbo and added 'with execute as caller as'

44 kbarnoin/pavisseau  20/02/2014:Add ssd_cf on #ESID0811 temptable + removing of useless join regarding SSL
*****************************************************/
create TABLE #ESID0811
  (
  CTR_NF       UCTR_NF    NOT null
 ,SEC_NF       USEC_NF    NOT null
 ,UWY_NF       UUWY_NF    NOT null
 ,ACY_NF       Smallint   NOT null
 ,CUR_CF       UCUR_CF    DEFAULT '' NOT null
 ,ACMTRS_NT    Smallint   NOT null
 ,ESTMNT_M     UAMT_M     NOT null
 ,CREUSR_CF    UUPDUSR_CF DEFAULT user NOT null
 ,SSD_CF        USSD_CF NOT null -- MODIF 44
 ,NEWUWY_NF    UUWY_NF    null
 ,ADMTYP_CT    Int        null
 ,LOB_CF       ULOB_CF    null
 ,REMARK_B     Int        null
 ,PCPCUR_CF    UCUR_CF    null
 ,COMMACC_B    Int        null
 ,AUTUPD_B     Int        null
 ,DRICRELAST_D Datetime   null
 ,ESTCRELAST_D Datetime   null
 ,ESTESTMNT_M  UAMT_M     null
 ,MAJAUTO      Bit        NOT null
 ,CLISSD_CF    USSD_CF    null
 ,NUMLINE_NT   Numeric(10,0) IDENTITY
  )
create index I_ESID0811 on #ESID0811(CTR_NF,UWY_NF,SEC_NF) -- 004 ajout

create TABLE #regroup_last
  (
  CTR_NF    UCTR_NF  NOT null
 ,SEC_NF    USEC_NF  NOT null
 ,UWY_NF    UUWY_NF  NOT null
 ,ACY_NF    smallint NOT null
 ,CUR_CF    UCUR_CF  DEFAULT '' NOT null
 ,ADMTYP_CT int      null
 ,ACMTRS_NT smallint NOT null
 ,CRE_D     datetime null
 ,ESTMNT_M  UAMT_M   null
  )

create TABLE #regroup_insert
  (
  CTR_NF    UCTR_NF  NOT null
 ,SEC_NF    USEC_NF  NOT null
 ,UWY_NF    UUWY_NF  NOT null
 ,ACY_NF    smallint NOT null
 ,CUR_CF    UCUR_CF  DEFAULT '' NOT null
 ,ADMTYP_CT int      null
 ,ACMTRS_NT smallint null
 ,ESTMNT_M  UAMT_M   NOT null
  )

create TABLE #doublons
  (
  CTR_NF    UCTR_NF  NOT null
 ,SEC_NF    USEC_NF  NOT null
 ,UWY_NF    UUWY_NF  NOT null
 ,ACY_NF    Smallint NOT null
 ,CUR_CF    UCUR_CF  DEFAULT '' NOT null
 ,ACMTRS_NT Smallint NOT null
  )

-- [16] Création de la table des écritures complémentaires
create TABLE #regroup_cpl
  (
  CTR_NF    UCTR_NF  NOT null
 ,SEC_NF    USEC_NF  NOT null
 ,UWY_NF    UUWY_NF  NOT null
 ,ACY_NF    Smallint NOT null
 ,CUR_CF    UCUR_CF  DEFAULT '' NOT null
 ,ADMTYP_CT Int      null
 ,ACMTRS_NT Smallint NOT null
 ,CRE_D     Datetime null
 ,ESTMNT_M  UAMT_M   null
  )

declare
  @erreur       Int
 ,@nb_ano       Int
 ,@nb_row       Int
 ,@rowcount     Int
 ,@transtate    Int
 ,@date_jour    Datetime
 ,@lag_cf       Char(1)
 ,@p_ssd_cf     Int
 ,@p_esb_cf     Int
 ,@debug        Char(1)
 ,@return_value Int
 ,@majauto      Bit
 ,@ced_nf       UCLI_NF
 ,@clissd_cf    USSD_CF
 ,@STAT_REP_D   datetime
 ,@SEUIL_M      UAMT_M
 ,@CURLIF_CF    UCUR_CF
 ,@CURCTR_CF    UCUR_CF
----------------------------------------------------------------------------------------------
-- select dans BREF..TCALEND
-- Recherche de la période 'année' et 'mois' en cours
-- (exceptionnelle à la date du jour )
----------------------------------------------------------------------------------------------
 ,@BLCSHTYEA_NF  Smallint
 ,@BLCSHTMTH_NF  Tinyint
 ,@BLCSHTYEAN_NF Smallint -- Période nOrmale - année
 ,@BLCSHTMTHN_NF Tinyint  -- Période nOrmale - mois
 ,@DATE          Datetime -- date de recherche
 ,@SPCEnd_D      Datetime
 ,@ACCOUNT_D     Datetime -- date de comptabilisation ( fin service )
 ,@CLOSING_B     Bit      -- top inventaire groupe
 ,@code_erreur   smallint

select
  @return_value=0 -- par defaut, le traitement est à 'Terminée', et pas en 'Echec'
 ,@p_ssd_cf    =convert(Int, @p_ssd_cf_c)
 ,@p_esb_cf    =convert(Int, @p_esb_cf_c)
 ,@DATE        =getdate()
-- ,@debug='D' -- D=débug, R=débug spécial regroupement

select @lag_cf=LAG_CF from BREF..TUSR where USR_CF=@p_usr_cf

-------------------
if @debug='D'
  select getdate(), 'execute BREF..PsCALEND_02 '
-------------------
execute @erreur=BREF..PsCALEND_02 @DATE,'C',@BLCSHTYEA_NF output,@BLCSHTMTH_NF output,@SPCEnd_D output,@ACCOUNT_D output,@CLOSING_B output
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;BREF..PsCALEnd_02;'
  goto plantage
end

-------------------
if @debug='D'
    select @BLCSHTYEA_NF, @BLCSHTMTH_NF
-------------------
if @debug='D'
	select getdate(), 'Table temporaire'
-------------------
if @debug='D'
begin
  select getdate(), 'Table temporaire'
    select count(*) from BTRAV..EST_ESID0811_ESTIMVIE
end
-------------------
-- Table temporaire
insert into #ESID0811
select
  *
 ,0 --SSD_CF -- MODIF 44
 ,null -- NEWUWY_NF
 ,null -- ADMTYP_CT
 ,null -- LOB_CF
 ,0    -- REMARK_B
 ,null -- PCPCUR_CF
 ,null -- COMMACC_B
 ,null -- AUTUPD_B
 ,null -- DRICRELAST_D
 ,null -- ESTCRELAST_D
 ,null -- ESTESTMNT_M
 ,0    -- MAJAUTO
 ,null -- CLISSD_CF
from BTRAV..EST_ESID0811_ESTIMVIE
where CREUSR_CF=@p_usr_cf
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;ESID0811;'
  goto plantage
end
select @nb_row=@rowcount

set ForcePlan on

update #ESID0811
   set CLISSD_CF=c.CLISSD_CF
from #ESID0811 a, BTRT..TCONTR b, BCLI..TCLIENT c
where a.CTR_NF=b.CTR_NF
  and b.UWY_NF=(select max(d.UWY_NF) from BTRT..TSECTION d where a.CTR_NF=d.CTR_NF and a.SEC_NF=d.SEC_NF and SECSTS_CT in(14,16,17,19))
  and b.CED_NF=c.CLI_NF

-- MODIF 44 START
-- Populate SSD_CF in #ESID0811
update #ESID0811
set SSD_CF = b.SSD_CF
from #ESID0811 a, BTRT..TCONTR b
where a.CTR_NF = b.CTR_NF
and b.UWY_NF = (select max(b.UWY_NF) from BTRT..TSECTION b where a.CTR_NF = b.CTR_NF and a.SEC_NF = b.SEC_NF and SECSTS_CT in(14,16,17,19))
-- MODIF 44 END


set ForcePlan off

update #ESID0811 set MAJAUTO=1 where CLISSD_CF Is null

-- on delete les anomalies du traitement précédent
delete TCTRANO where SEG_NF=@p_usr_cf and SSD_CF=@p_ssd_cf and SEGTYP_CT='L'

--======================================================
-- CONTROLES BLOQUANTS ET ELIMINATOIRES
--======================================================
if @debug='D'
  select getdate(), '127 - fichier vide'
-------------------
-- 127 - fichier vide
if @nb_row=0
begin
  insert into TCTRANO
  select '',0,0,1,@p_ssd_cf,'L',@p_usr_cf,127,0,null,null
  select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
  if @erreur!=0
  begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_1;'
  goto plantage
  end
  goto fin -- on ne continue pas les controles
end

-------------------
if @debug='D'
  select getdate(), '126 - detection des doublons'
-------------------

-- 126 - detection des doublons
insert into #doublons
select CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ACMTRS_NT
 from #ESID0811
  where CREUSR_CF=@p_usr_cf
group by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ACMTRS_NT
 Having Count(*) > 1
order by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ACMTRS_NT
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#doublons_1;'
  goto plantage
end

--NUMLINE_NT + 1 car la premiere ligne de l'xls contient le nom de colonne
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,126,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
from #ESID0811 e, #doublons d
 where e.CTR_NF=d.CTR_NF
   and e.UWY_NF=d.UWY_NF
   and e.SEC_NF=d.SEC_NF
   and e.ACY_NF=d.ACY_NF
   and e.CUR_CF=d.CUR_CF
   and e.ACMTRS_NT=d.ACMTRS_NT
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_3;'
  goto plantage
end
if @rowcount > 0 goto fin -- on ne continue pas les controles

-------------------
if @debug='D'
  select getdate(), '100 - filiale autre que la filiale du user'
-------------------
-- 100 - filiale autre que la filiale du user
-- INSERT in TCTRANO using BTRT..TCONTR
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,100,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TCONTR TCONTR -- substring removal Modif 40
  where TCONTR.SSD_CF!=@p_ssd_cf -- substring removal & @ssd_nf replaced with @p_ssd_cf Modif 40
  and TCONTR.CTR_NF = e.CTR_NF -- substring removal Modif 40
  and TCONTR.UWY_NF = e.UWY_NF -- substring removal Modif 40
-- INSERT in TCTRANO using BRET..TRETCTR
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,100,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BRET..TRETCTR TRETCTR-- substring removal Modif 40
  where TRETCTR.SSD_CF!=@p_ssd_cf -- substring removal & @ssd_nf replaced with @p_ssd_cf Modif 40
  and TRETCTR.RETCTR_NF = e.CTR_NF -- substring removal Modif 40
  and TRETCTR.RTY_NF = e.UWY_NF -- substring removal Modif 40
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_5;'
  goto plantage
end
if @rowcount > 0 goto fin -- on ne continue pas les contrôles

-------------------
if @debug='D'
  select getdate(), '116 : poste < 1000 ou >= 3000'
-------------------
-- 116 : poste < 1000 ou >= 3000
insert into TCTRANO
select CTR_NF,0,SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,116,NUMLINE_NT + 1,UWY_NF,ACY_NF
 from #ESID0811
  where ACMTRS_NT < 1000 or ACMTRS_NT >= 3000
select @rowcount=@@rowcount,@erreur=@@error,@transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_7;'
  goto plantage
end

-- [21]
-- 133 : Inadéquation entre poste et contrat (Contrat rétro avec poste acceptation ou Contrat acceptation avec poste rétro)
-------------------
if @debug='D'
  select getdate(), '133 : Inadéquation contrat poste'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,133,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TCONTR c
  where c.CTR_NF=e.CTR_NF
    and c.UWY_NF=e.UWY_NF
    and (e.ACMTRS_NT > 2000 and e.ACMTRS_NT < 3000) -- rétro
UNION
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,133,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BRET..TRETCTR r
  where r.RETCTR_NF=e.CTR_NF
    and r.RTY_NF=e.UWY_NF
    and e.ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_9;'
  goto plantage
end

-------------------------------------
-- Contrats des postes acceptation
-------------------------------------
if @debug='D'
  select getdate(), 'Par defaut, l''exercice-section de travail est l''exercice saisi s''il existe'
-------------------
-- Par defaut, l''exercice-section de travail est l''exercice saisi s''il existe
-- et s''il repond aux conditions
update #ESID0811
   set NEWUWY_NF=e.UWY_NF
from #ESID0811 e, BTRT..TSECTION s
where s.CTR_NF=e.CTR_NF
  and s.UWY_NF=e.UWY_NF
  and s.END_NT=0
  and s.UW_NT =1
  and s.SEC_NF=e.SEC_NF
  and s.SECSTS_CT in(14,16,17,19)
  and e.ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_1;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), 'Si l''exercice n''existe pas pour la section, on recherche le dernier exercice de la section'
-------------------
update #ESID0811
   set NEWUWY_NF=(select max(s.UWY_NF) from BTRT..TSECTION s where s.CTR_NF=e.CTR_NF and s.SEC_NF=e.SEC_NF and s.END_NT=0 and s.UW_NT=1 and s.SECSTS_CT in(14,16,17,19))
 from #ESID0811 e
  where NEWUWY_NF=null
    and (e.ACMTRS_NT >= 1000 and e.ACMTRS_NT < 2000) -- acceptation
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_3;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), '104 : sections qui n''ont aucun exercices'
-------------------
-- 104 : sections qui n''ont aucun exercices
insert into TCTRANO
select CTR_NF,0,SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,104,NUMLINE_NT + 1,UWY_NF,ACY_NF
 from #ESID0811
  where NEWUWY_NF=null
    and ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_11;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=104
end

-------------------
if @debug='D'
  select getdate(), '122 : exercice section calculé hors bornes'
-------------------

-- 122 : exercice section calculé hors bornes
insert into TCTRANO
select CTR_NF,0,SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,122,NUMLINE_NT + 1,UWY_NF,ACY_NF
 from #ESID0811
  where UWY_NF!=NEWUWY_NF -- annee redefinie
    and (UWY_NF > @BLCSHTYEA_NF + 2 or NEWUWY_NF > UWY_NF)
    and ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_12;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=122
end

-------------------
if @debug='D'
  select getdate(), '105 : exercice section calculé ne doit pas etre terminé'
-------------------
-- 105 : exercice section calculé ne doit pas etre terminé
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,105,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
from #ESID0811 e, BTRT..TSECTION s
where e.UWY_NF!=e.NEWUWY_NF -- annee redefinie
  and s.SECACCSTS_CT=9
  and s.CTR_NF=e.CTR_NF
  and s.UWY_NF=e.NEWUWY_NF
  and s.END_NT=0
  and s.UW_NT=1
  and s.SEC_NF=e.SEC_NF --modif 37
  and e.ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_14;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete  #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=105
end

-------------------
if @debug='D'
  select getdate(), '124 : exercice section calculé ne doit pas etre résilié'
-------------------
-- 124 : exercice section calculé ne doit pas etre résilié
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,124,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TSECTION s
where e.UWY_NF!=e.NEWUWY_NF -- annee redefinie
  and s.SECSTS_CT =19
  and s.CTR_NF=e.CTR_NF
  and s.UWY_NF=e.NEWUWY_NF
  and s.END_NT=0
  and s.UW_NT=1
  and s.SEC_NF=e.SEC_NF
  and e.ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_16;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=124
end

-------------------
if @debug='D'
  select getdate(), '101 : crible KO'
-------------------
-- 101 : crible KO
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,101,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TCONTR c
  where c.CTR_NF=e.CTR_NF
    and c.UWY_NF=e.NEWUWY_NF
    and c.END_NT=0
    and c.UW_NT=1
    and c.ESTCRB_CT='N'
    and e.ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_18;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=101
end

-------------------
if @debug='D'
  select getdate(),'125 : etablissement different'
-------------------
-- 125 : etablissement different
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,125,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TCONTR c
  where c.CTR_NF=e.CTR_NF
    and c.UWY_NF=e.NEWUWY_NF
    and c.END_NT=0
    and c.UW_NT=1
    and c.ACCESB_CF!=@p_esb_cf
    and e.ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_20;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=125
end

-------------------
if @debug='D'
  select getdate(), '102 : retro interne'
-------------------
-- 102 : retro interne
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,102,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TCONTR c, BCLI..TCLIENT n
  where c.CTR_NF=e.CTR_NF
    and c.UWY_NF=e.NEWUWY_NF
    and c.END_NT=0
    and c.UW_NT=1
    and n.CLI_NF=c.CED_NF
    and n.CLISSD_CF!=null
    and e.ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_22;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete  #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=102
end

-------------------
if @debug='D'
  select getdate(), '134 : Interdire chargement sections non-comptables'
-------------------
-- 134 : Interdire chargement sections non-comptables
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,134,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BRET..TRETCTR r, BRET..TRETSEC t
  where r.RETCTR_NF=e.CTR_NF
    and r.RTY_NF=e.UWY_NF
    and t.RETCTR_NF=e.CTR_NF
    and t.RTY_NF=e.UWY_NF
    and t.RETSEC_NF=e.SEC_NF
    and r.RETCTRCAT_CF='02' -- contrat NProp
    and t.PSESEC_B=1 -- section non comptable
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_24;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
    delete  #ESID0811
    from #ESID0811 e, TCTRANO a
    where a.SSD_CF     =@p_ssd_cf
      and a.SEG_NF     =@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT     =134
end

-------------------
if @debug='D'
  select getdate(), 'Alimentation des types comptables, des lob et des devises principales (accept)'
-------------------
update #ESID0811
   set ADMTYP_CT=s.ACCADMTYP_CT,
       LOB_CF=s.LOB_CF
 from #ESID0811 e, BTRT..tsection s
  where s.CTR_NF=e.CTR_NF
    and s.UWY_NF=e.NEWUWY_NF
    and s.END_NT=0
    and s.UW_NT=1
    and s.SEC_NF=e.SEC_NF
    and e.ACMTRS_NT between 1000 and 1999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_5;'
  goto plantage
end

-- [17] Nouveauté 2008 : La PCPCUR_CF doit se prendre systématiquement sur le dernier exercice
update #ESID0811
   set PCPCUR_CF=s.PCPCUR_CF
from #ESID0811 e, BTRT..tsection s
where s.CTR_NF=e.CTR_NF
  and s.END_NT=0
  and s.UW_NT=1
  and s.SEC_NF=e.SEC_NF
  and e.ACMTRS_NT between 1000 and 1999
  and s.UWY_NF=(select max(s2.UWY_NF) from BTRT..tsection s2 where s2.CTR_NF=e.CTR_NF and s2.SEC_NF=e.SEC_NF and s2.END_NT=0 and s2.UW_NT=1 and s2.SECSTS_CT in(14,16,17,19))

-------------------
if @debug='D'
  select getdate(), 'Alimentation de l''indicateur ''remark'''
-------------------
update #ESID0811
   set REMARK_B=1
from #ESID0811 e, BTRT..TCONTR c
where c.CTR_NF=e.CTR_NF
  and c.UWY_NF=e.NEWUWY_NF
  and c.END_NT=0
  and c.UW_NT=1
  and c.LiFTRTTYP_CF='A9'
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;ESID0811_7;'
  goto plantage
end

-------------------------------------
-- Contrats des postes retro
-------------------------------------
-------------------
if @debug='D'
  select getdate(), 'Par defaut, l''exercice-contrat de travail est l''exercice saisi si il existe'
-------------------
-- Par defaut, l''exercice-contrat de travail est l''exercice saisi si il existe et si il repond aux conditions
update #ESID0811
   set NEWUWY_NF=e.UWY_NF
from #ESID0811 e, BRET..TRETCTR r
where r.RETCTR_NF=e.CTR_NF
  and r.RTY_NF=e.UWY_NF
  and r.RETCTRSTS_CT in(3,19)
  and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;ESID0811_9;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), 'Si l''exercice n''existe pas, on recherche le dernier exercice'
-------------------
update #ESID0811
 set NEWUWY_NF=(select max(r.RTY_NF) from BRET..TRETCTR r where r.RETCTR_NF=e.CTR_NF and r.RETCTRSTS_CT in (3,19,9))
  from #ESID0811 e
   where e.NEWUWY_NF=null
     and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;ESID0811_11;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), '103 : contrats qui n''ont aucun exercices'
-------------------
-- 103 : contrats qui n''ont aucun exercices
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,103,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.NEWUWY_NF=null
    and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_26;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT ='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=103
end

-------------------
if @debug='D'
  select getdate(), '122 : exercice section calculé hOrs bOrnes'
-------------------
-- 122 : exercice section calculé hors bornes
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,122,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.UWY_NF!=e.NEWUWY_NF  -- annee redefinie
    and (e.UWY_NF > @BLCSHTYEA_NF + 2 or e.NEWUWY_NF > e.uwy_nf)
    and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_28;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=122
end

-------------------
if @debug='D'
  select getdate(), '124 : contrat résilié'
-------------------
-- 124 : contrat résilié
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,124,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BRET..TRETCTR r
  where e.UWY_NF !=e.NEWUWY_NF -- annee redefinie -- 002 : ajout
    and r.RETCTR_NF=e.CTR_NF
    and r.RTY_NF=e.NEWUWY_NF -- 008 : newuwy_nf ALD uwy_nf
    and r.RETCTRSTS_CT=19
    and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_29;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete  #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=124
end

-------------------
if @debug='D'
  select getdate(), '107 : retro particuliere'
-------------------
-- 107 : retro particuliere
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,107,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BRET..TRETCTR r
  where r.RETCTR_NF=e.CTR_NF
    and r.RTY_NF=e.UWY_NF
    and r.RETCTRCAT_CF='05'
    and r.CONRETCTR_B =1
    and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_31;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=107 --[023]122
end

-------------------
if @debug='D'
  select getdate(), '125 : etablissement différent'
-------------------
-- 125 : etablissement différent
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,125,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BRET..TRETCTR r
  where r.RETCTR_NF=e.CTR_NF
    and r.RTY_NF=e.UWY_NF
    and r.ESB_CF!=@p_esb_cf
    and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_33;'
  goto plantage
end
-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=125 --[023]122
end


--[023] debut------
if @debug='D'
  select getdate(), '135 : traités terminés'
-------------------
-- 107 : traité terminé
-- Impossible de charger des estimations sur des traités terminés
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,135,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TCONTR ctr, BTRT..TSECTION sec
  where ctr.CTR_NF   =e.CTR_NF
    and ctr.UWY_NF   =e.UWY_NF
  -- Traité terminé :
  and sec.CTR_NF=e.CTR_NF
  and sec.SEC_NF=e.SEC_NF
  -- Il faut regarder le dernier exercice
  and sec.UWY_NF in(select max(s.UWY_NF) from BTRT..tsection s where s.CTR_NF=sec.CTR_NF and s.SEC_NF=sec.SEC_NF and s.END_NT=sec.END_NT and s.SECSTS_CT in (14,16,17,18,19))
  and sec.SECACCSTS_CT=9 -- terminé
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_35;'
  goto plantage
end

--======================================================
-- CONTROLES BLOQUANTS MAIS PAS ELIMINATOIRES
--======================================================
-------------------
if @debug='D'
  select getdate(), 'Alimentation des types comptables, des lob et des devises principales (retro)'
-------------------
update #ESID0811
 set ADMTYP_CT=r.RETACCTYP_CT
    ,LOB_CF=t.LOB_CF
  from #ESID0811 e, BRET..TRETCTR r, BRET..TRETSEC t
  where r.RETCTR_NF=e.CTR_NF
    and r.RTY_NF=e.NEWUWY_NF
    and t.RETCTR_NF=e.CTR_NF
    and t.RTY_NF=e.NEWUWY_NF
    and t.RETSEC_NF=e.SEC_NF
    and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_6;'
  goto plantage
end

-- [17] Nouveauté 2008 : La PCPCUR est recherchée systématiquement sur le dernier exercice
update #ESID0811
 set PCPCUR_CF=r.RETPCPCUR_CF
  from #ESID0811 e, BRET..TRETCTR r, BRET..TRETSEC t
   where r.RETCTR_NF =e.CTR_NF
     and t.RETCTR_NF =e.CTR_NF
     and t.RTY_NF    =e.NEWUWY_NF
     and t.RETSEC_NF =e.SEC_NF
     and e.ACMTRS_NT between 2000 and 2999
     and r.RTY_NF=(select max(r2.RTY_NF) from BRET..TRETCTR r2 where r2.RETCTR_NF=e.CTR_NF and r2.RETCTRSTS_CT in(3,19,9))

-------------------
if @debug='D'
  select getdate(), '108 - année de compte >= exercice'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,108,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.ACY_NF < e.UWY_NF
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_37;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), '109 - type=1, acy=uwy'
-------------------
-- 109 - type=1, acy=uwy
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,109,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.ADMTYP_CT=1
    and e.ACY_NF!=e.UWY_NF
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_39;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), '110 - type=2, bilan-4 <= acy <= bilan+2'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,110,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.ADMTYP_CT=2
    and (e.ACY_NF < @BLCSHTYEA_NF - 4 or e.ACY_NF > @BLCSHTYEA_NF + 2)
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_41;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), '111 - type=3, postes primes/charges, acy=uwy'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,111,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.ADMTYP_CT=3
    and (e.ACMTRS_NT/100)-10 in(0,1,5,6) --modif 36 le 2ème chiffre est testé sachant qu'on 4 chiffres
    and e.ACMTRS_NT not in(1160,1323,1340,2160,2323,2340) --modif 36
    and ACY_NF!=UWY_NF
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_43;'
  goto plantage
end

-------------------
if @debug='D' select getdate(), '112 - type=3, postes sinistres, bilan-4 <= acy <= bilan+2'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,112,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.ADMTYP_CT=3
    and Substring(convert(char(6), e.ACMTRS_NT), 2, 1)='2'
    and (e.ACY_NF < @BLCSHTYEA_NF - 4 or e.ACY_NF > @BLCSHTYEA_NF + 2)
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_45;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), '113 - type=4 ou 5, uwy <= acy <= bilan+2'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,113,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.ADMTYP_CT in(5,4)
    and (e.ACY_NF < e.UWY_NF or e.ACY_NF > @BLCSHTYEA_NF + 2)
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_47;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), 'Alimentation du dernier cre_d'
-------------------
-- update in #ESID0811 using BTRT..TCONTR
update #ESID0811
  set ESTCRELAST_D=(select max(f.CRE_D) from #ESID0811 e, TLIFEST f -- MODIF 44
                       where f.CTR_NF=e.CTR_NF
                         and f.END_NT=0
                         and f.SEC_NF=e.SEC_NF
                         and f.UWY_NF=e.UWY_NF
                         and f.ACY_NF=e.ACY_NF
                         and f.ACMTRS_NT=e.ACMTRS_NT
                         and f.BALSHEY_NF=@BLCSHTYEA_NF
                         and f.SSD_CF=e.SSD_CF) -- substring removal Modif 40 -- MODIF 44
-- update in #ESID0811 using BRET..TRETCTR
update #ESID0811
  set ESTCRELAST_D=(select max(f.CRE_D) from #ESID0811 e, TLIFEST f -- MODIF 44
                       where f.CTR_NF=e.CTR_NF
                         and f.END_NT=0
                         and f.SEC_NF=e.SEC_NF
                         and f.UWY_NF=e.UWY_NF
                         and f.ACY_NF=e.ACY_NF
                         and f.ACMTRS_NT=e.ACMTRS_NT
                         and f.BALSHEY_NF=@BLCSHTYEA_NF
                         and f.SSD_CF=e.SSD_CF) -- substring removal Modif 40 -- MODIF 44
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_20;'
  goto plantage
end

-------------------
if @debug='D' select getdate(), 'Alimentation du dernier montant'
-------------------
-- update in #ESID0811 using BTRT..TCONTR
update #ESID0811
   set ESTESTMNT_M=f.ESTMNT_M
 from #ESID0811 e, TLIFEST f, BTRT..TCONTR TCONTR -- substring removal Modif 40
 where f.CTR_NF=e.CTR_NF
   and f.END_NT=0
   and f.SEC_NF=e.SEC_NF
   and f.UWY_NF=e.UWY_NF
   and f.ACY_NF=e.ACY_NF
   and f.ACMTRS_NT=e.ACMTRS_NT
   and f.BALSHEY_NF=@BLCSHTYEA_NF
   and f.CRE_D=e.ESTCRELAST_D
   and f.SSD_CF=e.SSD_CF -- substring removal Modif 40  -- MODIF 44
-- update in #ESID0811 using BRET..TRETCTR
update #ESID0811
   set ESTESTMNT_M=f.ESTMNT_M
 from #ESID0811 e, TLIFEST f, BRET..TRETCTR TRETCTR -- substring removal Modif 40
 where f.CTR_NF=e.CTR_NF
   and f.END_NT=0
   and f.SEC_NF=e.SEC_NF
   and f.UWY_NF=e.UWY_NF
   and f.ACY_NF=e.ACY_NF
   and f.ACMTRS_NT=e.ACMTRS_NT
   and f.BALSHEY_NF=@BLCSHTYEA_NF
   and f.CRE_D=e.ESTCRELAST_D
   and f.SSD_CF=e.SSD_CF -- substring removal Modif 40 -- MODIF 44
select @rowcount=@@rowcount, @erreur=@@error,@transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;ESID0811_22;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), 'Alimentation du dernier cre_d LIFDRI (du dernier mois d''inventaire)'
-------------------
-- update in #ESID0811 using BTRT..TCONTR
update #ESID0811
 set DRICRELAST_D=(select max(i.CRE_D) from TLIFDRI i, #ESID0811 e -- MODIF 44
                        where i.CTR_NF=e.CTR_NF
                          and i.END_NT=0
                          and i.SEC_NF=e.SEC_NF
                          and i.UWY_NF=e.ACY_NF -- 002 : au lieu de 'e.uwy_nf'
                          and i.ACY_NF=e.ACY_NF
                          and i.BALSHEY_NF=@BLCSHTYEA_NF
                          and i.SSD_CF=e.SSD_CF) -- substring removal Modif 40 --MODIF 44				  
-- update in #ESID0811 using BRET..TRETCTR
 update #ESID0811
 set DRICRELAST_D=(select max(i.CRE_D) from TLIFDRI i, #ESID0811 e -- MODIF 44
                        where i.CTR_NF=e.CTR_NF
                          and i.END_NT=0
                          and i.SEC_NF=e.SEC_NF
                          and i.UWY_NF=e.ACY_NF -- 002 : au lieu de 'e.uwy_nf'
                          and i.ACY_NF=e.ACY_NF
                          and i.BALSHEY_NF=@BLCSHTYEA_NF
                          and i.SSD_CF=e.SSD_CF) -- substring removal Modif 40  --MODIF 44
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;ESID0811_24;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), 'Alimentation des indicateurs LIfDRI'
-------------------
update #ESID0811
 set COMMACC_B=i.COMACC_B
    ,AUTUPD_B=i.AUTUPD_B
 from #ESID0811 e, TLIFDRI i
  where i.CTR_NF=e.CTR_NF
    and i.END_NT=0
    and i.SEC_NF=e.SEC_NF
    and i.UWY_NF=e.ACY_NF -- 002 : au lieu de 'e.UWY_NF'
    and i.ACY_NF=e.ACY_NF
    and i.BALSHEY_NF=@BLCSHTYEA_NF
    and i.CRE_D=e.DRICRELAST_D
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;ESID0811_26;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), '115 les statistiquées doivent etre en auto à non'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,115,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where e.COMMACC_B=1
    and e.AUTUPD_B =1
    and e.ACMTRS_NT not in(2183,2193,2163,1183,1193,1163) -- 00012 + [013] + [027] : Ajout du VOBA
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;1;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(),'116 - existence des postes comptables'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,116,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where (not exists(select 1 from BREF..TACMTRSL h where h.ACMTRS_NT=e.ACMTRS_NT and h.PRS_CF=500 and h.lag_CF='E')			--Modif 39
         or substring(convert(char(6),e.ACMTRS_NT),2,1)='4') -- spec PP du 12/5/03
    and not exists(select 1 from TCTRANO a where a.CTR_NF=e.CTR_NF and a.END_NT=0 and a.SEC_NF=e.SEC_NF and a.VRS_NF=1 and a.SSD_CF=@p_ssd_cf and a.SEGTYP_CT ='L' and a.SEG_NF=@p_usr_cf and a.ANO_CT=116 and a.NUMLINE_NT=e.numline_nt + 1)
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;3;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(), '117 - postes interdits'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,117,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where (e.LOB_CF='31' and e.ACMTRS_NT in(1063,1083,2063,2083,1200,1210, 2200, 2210))-- [014]
     or (e.LOB_CF='30' and e.ACMTRS_NT in(1503,1523,1533,1603,1623,1633,2503,2523,2533,2603,2623,2633)) -- [014]
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;5;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(),'117 - postes primes liées à la sinistralité'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,117,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TSECTION s
  where e.ctr_nf=s.ctr_nf
    and convert(int,s.NAT_CF) < 30 -- Contrats propres
    and e.ACMTRS_NT in(1011)
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;7;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(),'118 - postes de liberation interdits'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,118,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where (Substring(convert(char(4),e.ACMTRS_NT),4,1)='4' and e.ACY_NF!=@BLCSHTYEA_NF -4)
     or e.ACMTRS_NT in (1504,1524,1534,1604,1624,1634,2504,2524,2534,2604,2624,2634)
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;7;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(),'119 - ecart de montant (bloquant) PAS DE CONTROL (mail PP le 23 Mai 2011'
-------------------
--insert into TCTRANO
--select e.CTR_NF,
--       0,
--       e.SEC_NF,
--       1,
--       @p_ssd_cf,
--       'L',
--       @p_usr_cf,
--       119,
--       e.NUMLINE_NT + 1,
--       e.UWY_NF,
--       e.ACY_NF
--from #ESID0811 e
--where Substring(convert(Char(4),e.ACMTRS_NT),4,1) in ('3','4')
--  and e.ACMTRS_NT Not In (1183,1184,1193,1194,1163,1164,2183,2184,2193,2194,2163,2164, 1093, 2093, 1094, 2094 ) -- 011 + [013] + [029]
--  and e.ESTESTMNT_M!=null
--  and e.COMMACC_B   =1
--  and e.REMARK_B    =1
--  and e.AUTUPD_B    =0
--  and e.ESTESTMNT_M!=ESTMNT_M
--
--select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
--if @erreur!=0
--begin
--  Raiserror 20001 '20001 APPLICATIF;9;'
--  goto plantage
--end

-------------------
if @debug='D'
  select getdate(),'123 - ecart de montant (non bloquant)'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,123,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where substring(convert(Char(4),e.ACMTRS_NT),4,1) not in ('3','4')
    and e.COMMACC_B=1
    and e.REMARK_B=1
    and e.AUTUPD_B=0
    and e.ESTESTMNT_M!=null
    and e.ESTESTMNT_M!=ESTMNT_M
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;11;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(),'120 - monnaie'
-------------------
-- 120 - monnaie
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,120,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e
  where CUR_CF!=PCPCUR_CF
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;13;'
  goto plantage
end

-------------------
if @debug='D'
  select getdate(),'121 - sens des montants'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,121,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, TACCPAR p
  where p.ACMTRS_NT=e.ACMTRS_NT
    and p.PRS_CF=500
-- test du sens des montants pour l'acceptation   [18044]
  and (
       ( (p.ADJSIG_B=1 and e.ESTMNT_M < 0 and e.ACMTRS_NT between 1000 and 1999)
         or
         (p.ADJSIG_B=0 and e.ESTMNT_M > 0 and e.ACMTRS_NT between 1000 and 1999)
       )
-- test du sens des montants pour la retrocession [18044]
       or
       ( (p.ADJSIG_B=1 and e.ESTMNT_M > 0 and e.ACMTRS_NT between 2000 and 2999)
         or
         (p.ADJSIG_B=0 and e.ESTMNT_M < 0 and e.ACMTRS_NT between 2000 and 2999)
       )
      )
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;15;'
  goto plantage
end

-- Si il y a au moins une anomalie bloquante, on ne fait pas la màj
select @nb_ano=Count(*)
from TCTRANO a, BREF..TMESSAGE m
where a.SSD_CF=@p_ssd_cf
  and a.SEG_NF=@p_usr_cf
  and a.SEGTYP_CT='L'
  and m.MESS_N=a.ANO_CT
  and m.MESSTHM_C='ESTIMATION'
  and m.ICON_T=1 -- bloquante

if @nb_ano > 0
begin
    -------------------
    if @debug='D'
      select 'Anomalie bloquante, pas de chargement des tables'
    -------------------
  goto fin
end

--[030]
-------------------
if @debug='D'
  select getdate(), '136 : Retro - Mise à automatique'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,136,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BRET..TRETCTR r
  where r.RETCTR_NF   =e.CTR_NF
    and r.RTY_NF      =e.UWY_NF
    and r.CONRETCTR_B =1
    and e.ACMTRS_NT between 2000 and 2999
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_136;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
   from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=136
end

-- [031]
-------------------
if @debug='D'
  select getdate(), '137 : CNATYP 4 ou vide'
-------------------
insert into TCTRANO
select e.CTR_NF,0,e.SEC_NF,1,@p_ssd_cf,'L',@p_usr_cf,137,e.NUMLINE_NT + 1,e.UWY_NF,e.ACY_NF
 from #ESID0811 e, BTRT..TCONTR c
  where c.CTR_NF=e.CTR_NF
    and c.UWY_NF=e.UWY_NF
    and (c.CNATYP_CT='4' or c.CNATYP_CT=null)
    and e.ACMTRS_NT in (1183,1193) -- Accept CNA
    and c.ssd_cf!=14 --[034]
select @rowcount=@@rowcount, @erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TCTRANO_137;'
  goto plantage
end

-- Les lignes en ano ci-dessus ne sont plus a prendre en compte dans les contrôles suivants
if @rowcount > 0
begin
  delete #ESID0811
    from #ESID0811 e, TCTRANO a
    where a.SSD_CF=@p_ssd_cf
      and a.SEG_NF=@p_usr_cf
      and a.SEGTYP_CT='L'
      and e.NUMLINE_NT=a.NUMLINE_NT - 1
      and a.ANO_CT=137
end

-- [026]
--======================================================
--======================================================
-- GESTION sum AT RISK : 1900, 1901, 2900, 2901
--======================================================
--======================================================
-------------------
if @debug='D'
  select getdate(),'sum RISK'
-------------------
if @debug='D'
  select getdate(),'AJOUT POSTE MANQUANT'
-- Insertion des postes SR maanquants
-- 1900 si existe pas mais existe un 1901
insert into #ESID0811
select CTR_NF,
       SEC_NF,
       UWY_NF,
       ACY_NF,
       CUR_CF,
       1900,
       0,
       CREUSR_CF,
       SSD_CF, -- MODIF 44
       NEWUWY_NF,
       ADMTYP_CT,
       LOB_CF,
       REMARK_B,
       PCPCUR_CF,
       COMMACC_B,
       AUTUPD_B,
       DRICRELAST_D,
       ESTCRELAST_D,
       ESTESTMNT_M,
       MAJAUTO,
       CLISSD_CF
from #ESID0811 A
where not exists ( select 1
                   from #ESID0811 B
                   where A.CTR_NF   =B.CTR_NF
                     and A.SEC_NF   =B.SEC_NF
                     and A.UWY_NF   =B.UWY_NF
                     and A.ACY_NF   =B.ACY_NF
                     and B.ACMTRS_NT=1900 )
  and A.ACMTRS_NT=1901

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_1900;'
    select @code_erreur=1
  goto plantage
end

-- Poste 1901 si existe pas mais existe un 1900
insert into #ESID0811
select CTR_NF,
       SEC_NF,
       UWY_NF,
       ACY_NF,
       CUR_CF,
       1901,
       0,
       CREUSR_CF,
       SSD_CF,
       NEWUWY_NF,
       ADMTYP_CT,
       LOB_CF,
       REMARK_B,
       PCPCUR_CF,
       COMMACC_B,
       AUTUPD_B,
       DRICRELAST_D,
       ESTCRELAST_D,
       ESTESTMNT_M,
       MAJAUTO,
       CLISSD_CF
from #ESID0811 A
where not exists ( select 1
                   from #ESID0811 B
                   where A.CTR_NF   =B.CTR_NF
                     and A.SEC_NF   =B.SEC_NF
                     and A.UWY_NF   =B.UWY_NF
                     and A.ACY_NF   =B.ACY_NF
                     and B.ACMTRS_NT=1901 )
  and A.ACMTRS_NT=1900

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_1901;'
    select @code_erreur=2
  goto plantage
end

-- Poste 2900 si existe pas mais existe un 2901
insert into #ESID0811
select CTR_NF,
       SEC_NF,
       UWY_NF,
       ACY_NF,
       CUR_CF,
       2900,
       0,
       CREUSR_CF,
       SSD_CF,
       NEWUWY_NF,
       ADMTYP_CT,
       LOB_CF,
       REMARK_B,
       PCPCUR_CF,
       COMMACC_B,
       AUTUPD_B,
       DRICRELAST_D,
       ESTCRELAST_D,
       ESTESTMNT_M,
       MAJAUTO,
       CLISSD_CF
from #ESID0811 A
where not exists ( select 1
                   from #ESID0811 B
                   where A.CTR_NF   =B.CTR_NF
                     and A.SEC_NF   =B.SEC_NF
                     and A.UWY_NF   =B.UWY_NF
                     and A.ACY_NF   =B.ACY_NF
                     and B.ACMTRS_NT=2900 )
  and A.ACMTRS_NT=2901

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_2900;'
    select @code_erreur=3
  goto plantage
end


-- Poste 2901 si existe pas mais existe un 2900
insert into #ESID0811
select CTR_NF,
       SEC_NF,
       UWY_NF,
       ACY_NF,
       CUR_CF,
       2901,
       0,
       CREUSR_CF,
       SSD_CF,
       NEWUWY_NF,
       ADMTYP_CT,
       LOB_CF,
       REMARK_B,
       PCPCUR_CF,
       COMMACC_B,
       AUTUPD_B,
       DRICRELAST_D,
       ESTCRELAST_D,
       ESTESTMNT_M,
       MAJAUTO,
       CLISSD_CF
from #ESID0811 A
where not exists ( select 1
                   from #ESID0811 B
                   where A.CTR_NF  =B.CTR_NF
                     and A.SEC_NF  =B.SEC_NF
                     and A.UWY_NF  =B.UWY_NF
                     and A.ACY_NF  =B.ACY_NF
                     and B.ACMTRS_NT=2901 )
  and A.ACMTRS_NT=2900

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#ESID0811_2901;'
    select @code_erreur=4
  goto plantage
end

if @debug='D'
  select getdate(),'RECUPERER LES POSTES CONERNES DANS TACCPAR'

-- OPTIMISATION

---- Liste des postes pour le calcul SR
--select a.CTR_NF,
--       a.SEC_NF,
--       a.UWY_NF,
--       a.ACY_NF,
--       a.CUR_CF,
--       A.ACMTRS_NT,
--       A.ESTMNT_M
--into #TMP1
--from TLIFEST A, TACCPAR ACCPAR
--where A.ACMTRS_NT=ACCPAR.ACMTRS_NT
--  and A.CRE_D=( select max(CRE_D)
--                  from TLIFEST B
--                  where A.CTR_NF   =B.CTR_NF
--                    and A.SEC_NF   =B.SEC_NF
--                    and A.UWY_NF   =B.UWY_NF
--                    and A.ACY_NF   =B.ACY_NF
--                    and A.ACMTRS_NT=B.ACMTRS_NT )
--  and A.BALSHEY_NF=( select max(BALSHEY_NF)
--                       from TLIFEST B
--                       where A.CTR_NF	=	B.CTR_NF
--                         and A.SEC_NF	=	B.SEC_NF
--                         and A.UWY_NF	=	B.UWY_NF
--                         and A.ACY_NF	=	B.ACY_NF
--                         and A.ACMTRS_NT=B.ACMTRS_NT )
--  and ACCPAR.SUMRISK_B=1
--  and exists ( select 1
--               from #ESID0811 C
--               where A.CTR_NF=C.CTR_NF
--                 and A.SEC_NF=C.SEC_NF
--                 and A.UWY_NF=C.UWY_NF
--                 and A.ACY_NF=C.ACY_NF )
--

---- Mettre à jour les montants chargés qui sont dans #ESID0811
--update #TMP1
--   set ESTMNT_M=B.ESTMNT_M
--from #TMP1 A, #ESID0811 B
--where A.CTR_NF   =B.CTR_NF
--  and A.SEC_NF    =	B.SEC_NF
--  and A.UWY_NF    =	B.UWY_NF
--  and A.ACY_NF    =	B.ACY_NF
--  and A.ACMTRS_NT =	B.ACMTRS_NT
--

if @debug='D'
select getdate(), 'POSTE CHARGES'

-- Poste SR chargé
select a.CTR_NF,
       a.SEC_NF,
       a.UWY_NF,
       a.ACY_NF,
       a.CUR_CF,
       A.ACMTRS_NT,
       A.ESTMNT_M
into  #SUMRISK_CHARGE
from  #ESID0811 A , TACCPAR B
where a.acmtrs_nt=B.acmtrs_nt
  and B.SUMRISK_B=1

if @debug='D'
select getdate(), 'TLIFEST CONCERNE'

-- Poste SR LIFEST
select a.CTR_NF,
       a.SEC_NF,
       a.UWY_NF,
       a.ACY_NF,
       a.CUR_CF,
       A.ACMTRS_NT,
       A.ESTMNT_M
into   #LIFEST_CHARGE
from   TLIFEST A, #ESID0811 B
where A.CTR_NF=B.CTR_NF
and A.SEC_NF=B.SEC_NF
and A.UWY_NF=B.UWY_NF
and A.ACY_NF=B.ACY_NF
and A.ACMTRS_NT=B.ACMTRS_NT
and A.ESTMNT_M > 0
and A.CRE_D=( select max(CRE_D)
                  from TLIFEST B
                  where A.CTR_NF   =B.CTR_NF
                    and A.SEC_NF   =B.SEC_NF
                    and A.UWY_NF   =B.UWY_NF
                    and A.ACY_NF   =B.ACY_NF
                    and A.ACMTRS_NT=B.ACMTRS_NT )
  and A.BALSHEY_NF=( select max(BALSHEY_NF)
                       from TLIFEST B
                       where A.CTR_NF=B.CTR_NF
                         and A.SEC_NF=B.SEC_NF
                         and A.UWY_NF=B.UWY_NF
                         and A.ACY_NF=B.ACY_NF
                         and A.ACMTRS_NT=B.ACMTRS_NT )

if @debug='D'
select getdate(), 'Supprimer ceux qui ne font pas parti SR'

delete #LIFEST_CHARGE
where  ACMTRS_NT in (select ACMTRS_NT from taccpar where SUMRISK_B=0)

if @debug='D'
select getdate(), 'MAJ MONTANT DANS TEMPORAIRE'

update  #LIFEST_CHARGE
   set ESTMNT_M=B.ESTMNT_M
from #LIFEST_CHARGE A, #SUMRISK_CHARGE B
where A.CTR_NF   =B.CTR_NF
  and A.SEC_NF   =B.SEC_NF
  and A.UWY_NF   =B.UWY_NF
  and A.ACY_NF   =B.ACY_NF
  and A.ACMTRS_NT=B.ACMTRS_NT

if @debug='D'
  select getdate(),'MAJ MNT CHARGES DES POSTES'

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#LIFEST_CHARGE;'
  goto plantage
end


-- Calcul de la somme des postes
create TABLE #TMP2 (
    CTR_NF    UCTR_NF                     NOT null,
    SEC_NF    USEC_NF                     NOT null,
    UWY_NF    UUWY_NF                     NOT null,
    ACY_NF    Smallint                    NOT null,
    CUR_CF    UCUR_CF     DEFAULT ''      NOT null,
    ACMTRS_NT Smallint                    NOT null,
    ESTMNT_M  UAMT_M                      NOT null,
    SOMME     UAMT_M                      NOT null
)

if @debug='D'
  select getdate(),'SOMME DES POSTES'

insert into #TMP2
select CTR_NF,
       SEC_NF,
       UWY_NF,
       ACY_NF,
       CUR_CF,
       0 ACMTRS_NT,
       0 ESTMNT_M,
       sum(ESTMNT_M) SOMME
from #LIFEST_CHARGE
group by CTR_NF, SEC_NF, UWY_NF, ACY_NF, CUR_CF

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#TMP2_INSERT;'
    select @code_erreur=5
  goto plantage
end

if @debug='D'
  select getdate(),'CALCUL 1900,2900'

-- Calcul les postes 1900..2900, on prend par défaut les montants (1900 ou 2900)
update #TMP2
   set ACMTRS_NT=B.ACMTRS_NT,
       ESTMNT_M =B.ESTMNT_M
from #TMP2 A, #ESID0811 B
where A.CTR_NF =B.CTR_NF
  and A.SEC_NF =B.SEC_NF
  and A.UWY_NF =B.UWY_NF
  and A.ACY_NF =B.ACY_NF
  and B.ESTMNT_M > 0
  and B.ACMTRS_NT in (1900, 2900)

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#TMP2_1900_2900;'
    select @code_erreur=6
  goto plantage
end


-- puis les postes 1901 et 2901
update #TMP2
   set ACMTRS_NT=B.ACMTRS_NT,
       ESTMNT_M =B.ESTMNT_M
from #TMP2 A, #ESID0811 B
where A.CTR_NF =B.CTR_NF
  and A.SEC_NF =B.SEC_NF
  and A.UWY_NF =B.UWY_NF
  and A.ACY_NF =B.ACY_NF
  and B.ESTMNT_M > 0
  and B.ACMTRS_NT in (1901, 2901)
  and not exists ( select 1
                   from #TMP2 C
                   where A.CTR_NF   =C.CTR_NF
                     and A.SEC_NF   =C.SEC_NF
                     and A.UWY_NF   =C.UWY_NF
                     and A.ACY_NF   =C.ACY_NF
                     and C.ACMTRs_Nt in (1900, 2900) )

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#TMP2_1901_2901;'
    select @code_erreur=7
  goto plantage
end


-- Calcul 1900, 2900
update #TMP2
   set ACMTRS_NT=ACMTRS_NT,
       ESTMNT_M=round((SOMME * ESTMNT_M) / 1000,3) -- modif 38
where ACMTRS_NT in (1901, 2901)

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#TMP2_CAL_1901;'
    select @code_erreur=8
  goto plantage
end

if @debug='D'
  select getdate(),'CALCUL 1901, 2901'

-- Calcul 1901, 2901
update #TMP2
   set ACMTRS_NT=ACMTRS_NT + 2,
       ESTMNT_M=round((SOMME / ESTMNT_M) * 1000,3) -- modif 38
where ACMTRS_NT in (1900, 2900)
  and ESTMNT_M > 0

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#TMP2_CAL_1900;'
    select @code_erreur=9
  goto plantage
end


update #TMP2
   set ACMTRS_NT=ACMTRS_NT - 1

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;#TMP2_ACMTRS_NT;'
    select @code_erreur=10
  goto plantage
end

if @debug='D'
  select getdate(),'MAJ #ESID0811'

-- Remettre les montants SR calculés dans #ESID0811 avec un user SUSER_NAME()
-- afin de mettre ORICOD='CALC'
update #ESID0811
   set ESTMNT_M =case when B.ESTMNT_M > 0
                        then B.ESTMNT_M
                        else A.ESTMNT_M
                   end,
       CREUSR_CF=SUSER_NAME()
from #ESID0811 A, #TMP2 B
where A.CTR_NF   =B.CTR_NF
  and A.SEC_NF   =B.SEC_NF
  and A.UWY_NF   =B.UWY_NF
  and A.ACY_NF   =B.ACY_NF
  and A.ACMTRS_NT=B.ACMTRS_NT

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;UPDATE_#ESID0811;'
    select @code_erreur=11
  goto plantage
end


-- [025]
--======================================================
--======================================================
-- GENERATION DES FICHES MOUVEMENTS
-- TLIFMOD, TLIFMOD2, TLIFPEN
--======================================================
--======================================================

-------------------
if @debug='D'
  select getdate(),'GENERATION DES FICHES MOUVEMENTS'
-------------------

-- Sélection des données de référence pour les contrats concernés
-- Seuil + uwgrp_cf

-------------------
if @debug='D'
  select getdate(),'Table Référence'
-------------------

create TABLE #REF (
    CTR_NF      UCTR_NF                     null,
    accesb_cf   UESB_CF                     null,
    ssd_cf    smallint                    null,
    amt_m     UAMT_M     DEFAULT 0        null,
    PCPCUR_CF   UCUR_CF                     null,
    UWGRP_CF  smallint   DEFAULT 0        null,
    SEC_NF      USEC_NF                 NOT null  -- [033]
)


--[032]
-- Contrat traités # PhP
insert into #ref
select distinct a.ctr_nf, a.accesb_cf, a.ssd_cf, c.amt_m, d.PCPCUR_CF, a.uwgrp_cf, b.sec_nf -- [033]
from BTRT..tcontr a, #ESID0811 b, TLIFTHR  c, BTRT..tsection d
where a.ctr_nf  =b.ctr_nf
  and a.uwy_nf  =b.uwy_nf
  and a.ssd_cf  =c.ssd_cf
  and a.accesb_cf= c.esb_cf
  and a.SSD_CF  =@p_ssd_cf
  and b.ctr_nf  =d.ctr_nf
  and b.sec_nf  =d.sec_nf
  and d.UWY_NF   =( select max(s2.UWY_NF)
                      from BTRT..tsection s2
                      where s2.CTR_NF    =d.CTR_NF
                        and s2.SEC_NF    =d.SEC_NF
                        and s2.END_NT    =d.END_NT
                        and s2.UW_NT     =d.UW_NT
                        and s2.SECSTS_CT In (14, 16, 17, 19) )


-- Contrat FAC
insert into #ref
select distinct a.ctr_nf, a.accesb_cf, a.ssd_cf, c.amt_m, d.PCPCUR_CF, a.uwgrp_cf, b.sec_nf -- [033]

from bfac..tcontr a, #ESID0811 b, TLIFTHR  c, bfac..tsection d
where   a.ctr_nf  =b.ctr_nf
  and   a.uwy_nf  =b.uwy_nf
  and   a.ssd_cf  =c.ssd_cf
  and   a.accesb_cf= c.esb_cf
  and   a.SSD_CF  =@p_ssd_cf
  and   b.ctr_nf  =d.ctr_nf
  and   b.sec_nf  =d.sec_nf
  and   d.UWY_NF   =( select max(s2.UWY_NF)
                        from BTRT..tsection s2
                        where s2.CTR_NF    =d.CTR_NF
                          and s2.SEC_NF    =d.SEC_NF
                          and s2.END_NT    =d.END_NT
                          and s2.UW_NT     =d.UW_NT
                               and s2.SECSTS_CT In (14, 16, 17, 19) )

-- Contrat retro
insert into #ref
select distinct a.retctr_nf, a.esb_cf, a.ssd_cf, c.amt_m, a.RETPCPCUR_CF, 0, b.sec_nf -- [033]
from bret..tretctr  a, #ESID0811 b, TLIFTHR  c
where a.retctr_nf= b.ctr_nf
  and a.rty_nf  =b.uwy_nf
  and a.ssd_cf  =c.ssd_cf
  and a.esb_cf  =c.esb_cf
  and a.SSD_CF  =@p_ssd_cf
  and b.ctr_nf  =a.retctr_nf
  and a.RTY_NF   =( select max(r2.RTY_NF)
                      from BRET..TRETCTR r2
                      where r2.RETCTR_NF    =a.RETCTR_NF
                        and r2.RETCTRSTS_CT In (3, 19, 9) )


-- Mise à jour de la #ref pour les taux
update #ref
   set amt_m= round(amt_m / b.EXC_R / 1000,3)
  from #ref a, BREF..TCURQUOT b
where b.CUR_CF= a.PCPCUR_CF
  and b.SSD_CF= a.ssd_cf
  and b.EXC_D=( select max(x.EXC_D)
                    from BREF..TCURQUOT x
                    where x.CUR_CF=b.CUR_CF
                      and x.SSD_CF=b.SSD_CF )


-------------------
if @debug='D'
  select getdate(),'Récupérer la date du dernier as'
-------------------

-- Récupérer la dernier date as
select @STAT_REP_D=max(CRE_D)
from TREQJOB
where SSD_CF        =@p_ssd_cf
  and REQCOD_CT     ='L'
  and BALSHEYEA_NF  =1900
  and BALSHTMTH_NF  =1
  and CLODAT_D      ='19000101'

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;19;'
    select @code_erreur=14
  goto plantage
end


-------------------
if @debug='D'
  select getdate(),'La date du dernier as : ', convert(char(20),@STAT_REP_D)
-------------------

if @debug='D'
  select getdate(),'Table groupe'

-- Groupements
create Table #GROUPE(GP Tinyint, ACMTRS_NT Smallint)

--Primes
insert #GROUPE values(1,1010)
insert #GROUPE values(1,1011)

-- prime Rétro
insert #GROUPE values(1,2010)
insert #GROUPE values(1,2011)

--Résultat technique
insert into #groupe
select 2, ACMTRS_NT
from TACCPAR
where RESTEC_B=1
  and acmtrs_nt < 2000

--Résultat technique rétro
insert into #groupe
select 2, ACMTRS_NT
from TACCPAR
where RESTEC_B=1
  and acmtrs_nt >= 2000


--Résultat Tech. + Financier
--insert #GROUPE select 3, ACMTRS_NT from #GROUPE where GP=2
insert into #groupe
select 3, ACMTRS_NT
from TACCPAR
where RESFIN_B=1
  and acmtrs_nt < 2000


--Résultat Tech. + Financier rétro
insert into #groupe
select 3, ACMTRS_NT
from TACCPAR
where RESFIN_B=1
  and acmtrs_nt >= 2000


--Résultat Tech. + Financier + CNA + VOBA
--insert #GROUPE select 4, ACMTRS_NT from #GROUPE where GP=3
insert into  #groupe
select 4, ACMTRS_NT
from TACCPAR
where RESDAC_B=1
  and acmtrs_nt < 2000


--Résultat Tech. + Financier + CNA + VOBA rétro
insert into  #groupe
select 4, ACMTRS_NT
from TACCPAR
where RESDAC_B=1
  and acmtrs_nt >= 2000


create TABLE #contrat_depasse_seuil (
    CTR_NF        UCTR_NF                 NOT null,
    SEC_NF        USEC_NF                 NOT null,
    ACY_NF        Smallint                NOT null,
    PCPCUR_CF     UCUR_CF                     null,
    UWGRP_CF    smallint   DEFAULT 0        null
)

-- contrat dépassant le seuil
insert into #contrat_depasse_seuil
select distinct a.ctr_nf,
                a.sec_nf,
                a.acy_nf,
                b.PCPCUR_CF,
                b.UWGRP_CF
from #ESID0811 a, #ref b
where a.CTR_NF=b.ctr_nf
  and a.sec_nf=b.sec_nf -- [033]
  and a.estmnt_m > b.amt_m

-------------------
if @debug='D'
  select getdate(),'#LIFEST'
-------------------
-- Calcul
--[033]
---------------------------------------------------------------------------------------------
-- ANCIENNE METHODE
---------------------------------------------------------------------------------------------

-- Recherche les montants à la date d'arrete stat
-- LIFEST
--create TABLE #LIFEST (
--    CTR_NF    		UCTR_NF                 NOT null,
--    SEC_NF    		USEC_NF                 NOT null,
--    UWY_NF    		UUWY_NF                 NOT null,
--    ACY_NF    		Smallint                NOT null,
--    CUR_CF    		UCUR_CF    DEFAULT ''   NOT null,
--    ESTMNT_LIF      UAMT_M     DEFAULT 0    NOT null,
--    ESTMNT_CHG		UAMT_M     DEFAULT 0    NOT null,
--    ACMTRS_NT 		Smallint                NOT null,
--    UWGRP_CF 		smallint   DEFAULT 0    NOT null,
--    COMMACC_B		Int			                null
--)



--insert into #lifest
--select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ESTMNT_M, 0, a.acmtrs_nt, 0, 0
--from TLIFEST a
--where exists ( select 1 from #ESID0811 b
--               where a.CTR_NF     =b.CTR_NF
--                 and a.SEC_NF     =b.SEC_NF
--                 and a.ACY_NF     =b.ACY_NF
--                 and a.uwy_nf     =b.uwy_nf
--                 and a.CUR_CF     =b.cur_cf )
--  and a.CRE_D        <= @STAT_REP_D
--  and a.BALSHEY_NF =@BLCSHTYEA_NF
--  and a.BALSHTMTH_NF <= @BLCSHTMTH_NF
--  and a.estmnt_m > 0
--  and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFEST m
--                       where m.ACY_NF =a.ACY_NF
--                         and m.CTR_NF =a.CTR_NF
--                         and m.UWY_NF =a.UWY_NF
--                         and m.SEC_NF =a.SEC_NF
--                         and m.BALSHEY_NF=a.BALSHEY_NF
--                         and m.BALSHTMTH_NF<= @BLCSHTYEA_NF
--                         and m.PRS_CF    =a.PRS_CF
--                         and m.ACMTRS_NT =a.ACMTRS_NT
--                         and m.CRE_D       <= @STAT_REP_D)
--  and a.CRE_D=(select max(d.CRE_D) from TLIFEST d
--               where d.CTR_NF= a.CTR_NF
--                 and d.SEC_NF= a.SEC_NF
--                 and d.ACY_NF= a.ACY_NF
--                 and d.UWY_NF= a.UWY_NF
--                 and d.BALSHEY_NF =a.BALSHEY_NF
--                 and d.BALSHTMTH_NF= a.BALSHTMTH_NF
--                 and d.PRS_CF     =a.PRS_CF
--                 and d.ACMTRS_NT  =a.ACMTRS_NT
--                 and d.CRE_D        <= @STAT_REP_D)


---------------------------------------------------------------------------------------------
-- METHODE OPTIMISEE
---------------------------------------------------------------------------------------------

create TABLE #LIFEST_00 (
    CTR_NF        UCTR_NF                 NOT null,
    SEC_NF        USEC_NF                 NOT null,
    UWY_NF        UUWY_NF                 NOT null,
    ACY_NF        Smallint                NOT null,
    CUR_CF        UCUR_CF    DEFAULT ''   NOT null,
    ESTMNT_LIF      UAMT_M     DEFAULT 0    NOT null,
    ESTMNT_CHG    UAMT_M     DEFAULT 0    NOT null,
    ACMTRS_NT     Smallint                NOT null,
    UWGRP_CF    smallint   DEFAULT 0    NOT null,
    COMMACC_B   Int                     null,
    CRE_D           Datetime                NOT null
)

create index I_LIFEST_00 on #LIFEST_00 (CTR_NF, UWY_NF, SEC_NF, ACY_NF, CUR_CF )

create TABLE #LIFEST (
    CTR_NF        UCTR_NF                 NOT null,
    SEC_NF        USEC_NF                 NOT null,
    UWY_NF        UUWY_NF                 NOT null,
    ACY_NF        Smallint                NOT null,
    CUR_CF        UCUR_CF    DEFAULT ''   NOT null,
    ESTMNT_LIF      UAMT_M     DEFAULT 0    NOT null,
    ESTMNT_CHG    UAMT_M     DEFAULT 0    NOT null,
    ACMTRS_NT     Smallint                NOT null,
    UWGRP_CF    smallint   DEFAULT 0    NOT null,
    COMMACC_B   Int                     null,
    CRE_D           Datetime                NOT null
)

create index I_LIFEST on #LIFEST (CTR_NF, UWY_NF, SEC_NF, ACY_NF, CUR_CF )

-------------------
if @debug='D'
  select getdate(),'Les mouvements TFLIEST concernés #lifest_00'
-------------------

insert into #lifest_00
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ESTMNT_M, 0, a.acmtrs_nt, 0, 0, a.CRE_D
from TLIFEST a (index ILIFEST_00) , #ESID0811 b (index I_ESID0811)
where a.CTR_NF     =b.CTR_NF
  and a.SEC_NF     =b.SEC_NF
  and a.ACY_NF     =b.ACY_NF
  and a.uwy_nf     =b.uwy_nf
  and a.CUR_CF     =b.cur_cf
  and a.CRE_D        <= @STAT_REP_D
  and a.BALSHEY_NF =@BLCSHTYEA_NF
  and a.BALSHTMTH_NF <= @BLCSHTMTH_NF
  and a.estmnt_m     > 0
  and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFEST m (index ILIFEST_00)
                       where m.ACY_NF =a.ACY_NF
                         and m.CTR_NF =a.CTR_NF
                         and m.UWY_NF =a.UWY_NF
                         and m.SEC_NF =a.SEC_NF
                         and m.BALSHEY_NF=a.BALSHEY_NF
                         and m.BALSHTMTH_NF<= @BLCSHTYEA_NF
                         and m.PRS_CF    =a.PRS_CF
                         and m.ACMTRS_NT =a.ACMTRS_NT
                         and m.CRE_D       <= @STAT_REP_D)

  -------------------
if @debug='D'
  select getdate(),'Les derniers mouvements TFIFEST concernés #lifest_00'
-------------------

  insert into #lifest
  select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ESTMNT_LIF, 0, a.acmtrs_nt, 0, 0, a.CRE_D
  from #lifest_00 a (index I_LIFEST_00)
  where a.CRE_D=(select max(d.CRE_D) from #lifest_00 d (index I_LIFEST_00)
               where d.CTR_NF= a.CTR_NF
                 and d.SEC_NF= a.SEC_NF
                 and d.ACY_NF= a.ACY_NF
                 and d.UWY_NF= a.UWY_NF
                 and d.ACMTRS_NT  =a.ACMTRS_NT)

-- Fin [033]

-------------------
if @debug='D'
  select getdate(),'MAJ #LIFEST'
-------------------

-- Mise à jour les montants chargés
update #lifest
   set estmnt_chg=round(b.estmnt_m,3)
from #lifest a, #ESID0811 b
where a.ctr_nf=b.ctr_nf
  and a.sec_nf   =b.sec_nf
  and a.acy_nf   =b.acy_nf
  and a.uwy_nf   =b.uwy_nf
  and a.acmtrs_nt=b.acmtrs_nt

-- Remplacer les montants chargés 0 par montant tlifest
update #lifest
   set estmnt_chg=round(estmnt_lif,3)
where estmnt_chg=0


-- Mise à jour l'indicateur commacc_b
update #lifest
   set commacc_b=b.commacc_b
from #lifest a, #ESID0811 b
where a.ctr_nf=b.ctr_nf
  and a.sec_nf=b.sec_nf
  and a.acy_nf=b.acy_nf
  and a.uwy_nf=b.uwy_nf


-------------------
if @debug='D'
  select getdate(),'Création #lifmod2_tmp'
-------------------

create TABLE #lifmod2_tmp (
    CTR_NF      UCTR_NF                 NOT null,
    SEC_NF      USEC_NF                 NOT null,
    ACY_NF      Smallint                NOT null,
    GP          Tinyint                 NOT null,
    AVANT_M     UAMT_M  DEFAULT 0       NOT null,
    APRES_M     UAMT_M  DEFAULT 0       NOT null,
    COMMACC_B   Int                         null
)


-- Création #lifmod2_tmp
insert into #lifmod2_tmp
select distinct ctr_nf,
                sec_nf,
                acy_nf,
                g.gp,
                round(sum(a.estmnt_lif),3) avant_m,
                round(sum(a.ESTMNT_CHG), 3) apres_m,
                case when commacc_b is null
                     then 0
                     else commacc_b
                end
from #lifest a, #groupe g
where a.acmtrs_nt=g.acmtrs_nt
group by a.ctr_nf, a.sec_nf, a.acy_nf, g.GP
order by a.ctr_nf, a.sec_nf, acy_nf, g.gp


--tlifmod2 pour les contrats dépassant le seuil
select distinct a.ctr_nf,
               a.sec_nf,
               a.acy_nf,
               a.gp,
               a.avant_m,
               a.apres_m,
               a.commacc_b,
               b.PCPCUR_CF CUR_CF,
               b.UWGRP_CF
into #lifmod2
from #lifmod2_tmp a, #contrat_depasse_seuil b
where a.ctr_nf=b.ctr_nf
  and a.sec_nf=b.sec_nf
  and a.acy_nf=b.acy_nf

-------------------
if @debug='D'
  select getdate(),'insert TLIFPEN'
-------------------

-- Alimenter TLIFPEN, TLIFMOD et TLIFMOD2
-- Insertion TLIFPEN
insert into TLIFPEN
select distinct @p_usr_cf,
                CTR_NF,
                SEC_NF,
                getdate(),
                @BLCSHTYEA_NF,
                @BLCSHTMTH_NF,
                1,
                uwgrp_cf,
                @p_usr_cf,
                getdate(),
                @p_usr_cf,
                null
from #lifmod2

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;TLIFPEN;'
    select @code_erreur=14
  goto plantage
end

-------------------
if @debug='D'
  select getdate(),'insert TLIFMOD'
-------------------

-- Insertion lifmod
insert into tlifmod
select distinct ctr_nf,
                sec_nf,
                getdate(),
                @BLCSHTYEA_NF,
                @BLCSHTMTH_NF,
                @p_ssd_cf,
                1,
                null,
                cur_cf,
                null,
                null,
                'AUTO',
                @p_usr_cf,
                getdate(),
                @p_usr_cf,
                null
from #lifmod2

--modif 41 start
-- insert into tmp table
insert into #contrat_depasse_seuil_tmp
select distinct CTR_NF, 
                SEC_NF,
                @BLCSHTYEA_NF
from #lifmod2 

--modif 41 end

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;insert TLIFMOD;'
    select @code_erreur=15

  -------------------
  if @debug='D'
    select getdate(),'ERRGENERATION DES FICHES MOUVEMENTS'
    -------------------
    select distinct ctr_nf,
                    sec_nf,
                    getdate(),
                    @BLCSHTYEA_NF,
                    @BLCSHTMTH_NF,
                    @p_ssd_cf,
                    1,
                    null,
                    cur_cf,
                    null,
                    null,
                    'AUTO',
                    @p_usr_cf,
                    getdate(),
                    @p_usr_cf,
                    null
    from #lifmod2

  goto plantage
end


-------------------
if @debug='D'
  select getdate(),'#TLIFMOD2'
-------------------

-- Préparation de tlifmod2
create TABLE #tlifmod2 (
    CTR_NF          UCTR_NF                 NOT null,
    SEC_NF          USEC_NF                 NOT null,
    CRE_D           Datetime                NOT null,
    ACY_NF          Smallint                NOT null,
    BALSHEY_NF      smallint                NOT null,
    BALSHTMTH_NF    smallint                NOT null,
    COMMACC_B       smallInt          NOT null,
    AV_PRI          UAMT_M     DEFAULT 0    NOT null,
    AV_TEC          UAMT_M     DEFAULT 0    NOT null,
    AV_DAC          UAMT_M     DEFAULT 0    NOT null,
    AV_FIN          UAMT_M     DEFAULT 0    NOT null,
    APRES_PRI       UAMT_M     DEFAULT 0    NOT null,
    APRES_TEC       UAMT_M     DEFAULT 0    NOT null,
    APRES_DAC       UAMT_M     DEFAULT 0    NOT null,
    APRES_FIN       UAMT_M     DEFAULT 0    NOT null
)


insert into #tlifmod2
select distinct a.CTR_NF,
                a.sec_nf,
                getdate(),
                a.acy_nf,
                @BLCSHTYEA_NF   balshey,
                @BLCSHTMTH_NF   balmth,
                a.commacc_b,
                a.avant_m,
                0               av_tec,
                0               av_dac,
                0               av_fin,
                a.apres_m,
                0               ap_tec,
                0               ap_dac,
                0               ap_fin
from #lifmod2 a
where a.gp=1

-------------------
if @debug='D'
  select getdate(),'MAJ #TLIFMOD2'
-------------------

update #tlifmod2
   set apres_tec=b.apres_m,
       av_tec=b.avant_m
from #tlifmod2 a, #lifmod2 b
where a.ctr_nf= b.ctr_nf
  and a.sec_nf= b.sec_nf
  and a.acy_nf= b.acy_nf
  and b.gp    =2


update #tlifmod2
   set apres_dac=b.apres_m,
       av_dac=b.avant_m
from #tlifmod2 a, #lifmod2 b
where a.ctr_nf= b.ctr_nf
  and a.sec_nf= b.sec_nf
  and a.acy_nf= b.acy_nf
  and b.gp    =3

update #tlifmod2
   set apres_fin=b.apres_m,
       av_fin=b.avant_m
from #tlifmod2 a, #lifmod2    b
where a.ctr_nf= b.ctr_nf
  and a.sec_nf= b.sec_nf
  and a.acy_nf= b.acy_nf
  and b.gp    =4

-------------------
if @debug='D'
  select getdate(),'insert TLIFMOD2'
-------------------

-- Insertion dans TLIFMOD2 cuex qui n''existent pas
insert into TLIFMOD2
select distinct a.CTR_NF,a.sec_nf,getdate(),@BLCSHTYEA_NF,@BLCSHTMTH_NF,a.acy_nf,a.commacc_b,0,a.apres_pri,0,a.apres_tec,0,a.apres_dac,0,a.apres_fin,@p_usr_cf,getdate(),@p_usr_cf,null
 from #tlifmod2 a
  where not exists(select 1 from TLIFMOD2 a, #tlifmod2 b where a.CTR_NF=b.CTR_NF and a.SEC_NF=b.SEC_NF and a.BALSHEY_NF=@BLCSHTYEA_NF and a.BALSHTMTH_NF=@BLCSHTMTH_NF and a.acy_nf=b.acy_nf)
select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;INSERT_TLIFMOD2;'
  select @code_erreur=16
  goto plantage
end

-------------------
if @debug='D'
  select getdate(),'MAJ TLIFMOD2'
-------------------
-- Mise à jour des mouvements existants
update TLIFMOD2
   set aftprmamt_m  =b.apres_pri,
       aftrestecamt_m= b.apres_tec,
       aftresdacamt_m= b.apres_dac,
       aftresfinamt_m= b.apres_fin
from TLIFMOD2 a, #tlifmod2 b
where a.CTR_NF= b.CTR_NF
  and a.SEC_NF= b.SEC_NF
  and a.BALSHEY_NF  =@BLCSHTYEA_NF
  and a.BALSHTMTH_NF=@BLCSHTMTH_NF
  and a.acy_nf      =b.acy_nf
  and exists(select 1
             from TLIFMOD2 a, #lifmod2 b
             where a.CTR_NF    =b.CTR_NF
               and a.SEC_NF    =b.SEC_NF
               and a.BALSHEY_NF=@BLCSHTYEA_NF
               and BALSHTMTH_NF=@BLCSHTMTH_NF
               and a.acy_nf    =b.acy_nf )

select @erreur=@@error
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;UPDATE_TLIFMOD2;'
    select @code_erreur=17
  goto plantage
end

if @debug='D'
	select getdate(),'CHARGEMENT DES TABLES'

-------------------
if @debug='D'
  select getdate(),'CHARGEMENT DES TABLES'
-------------------

--======================================================
--======================================================
-- CHARGEMENT DES TABLES
--======================================================
--======================================================
-------------------
if @debug='D'
  select getdate(),'insert into	TLIFEST',getdate()
-------------------
insert into TLIFEST
 (CTR_NF
 ,END_NT
 ,SEC_NF
 ,UWY_NF
 ,UW_NT
 ,CRE_D
 ,BALSHEY_NF
 ,BALSHTMTH_NF
 ,ACY_NF
 ,PRS_CF
 ,ACMTRS_NT
 ,SSD_CF
 ,CUR_CF
 ,ESTMNT_M
 ,INDSUP_B
 ,ORICOD_LS
 ,CREUSR_CF
 ,LSTUPD_D
 ,LSTUPDUSR_CF
 )
select
  CTR_NF
 ,0
 ,SEC_NF
 ,UWY_NF
 ,1
 ,getdate()
 ,@BLCSHTYEA_NF
 ,@BLCSHTMTH_NF
 ,ACY_NF
 ,500
 ,ACMTRS_NT
 ,@p_ssd_cf
 ,CUR_CF
 ,ESTMNT_M
 ,0
 ,case when CREUSR_CF=SUSER_NAME() then 'CALC' else 'auto' end    -- [026]
 ,@p_usr_cf
 ,getdate()
 ,@p_usr_cf
from #ESID0811
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;30;'
  select @code_erreur=18
  goto plantage
end

-- TLIFDRI, acceptation
-------------------
if @debug='D'
  select getdate(),'tlifdri, acceptation',getdate()
-------------------
-- 002 : on mets l'anné de compte dans l'exe
insert into TLIFDRI(CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,SSD_CF,AUTUPD_B,COMACC_B,CMT_NT,CREUSR_CF,LSTUPD_D,LSTUPDUSR_CF)
select distinct e.CTR_NF,0,e.SEC_NF,e.ACY_NF,1,getdate(),@BLCSHTYEA_NF,@BLCSHTMTH_NF,e.ACY_NF,@p_ssd_cf,MAJAUTO,0,0,@p_usr_cf,getdate(),@p_usr_cf
 from #ESID0811 e
  where not exists(select 1 from TLIFDRI i where i.CTR_NF=e.CTR_NF and i.END_NT=0 and i.SEC_NF=e.SEC_NF and i.UWY_NF=e.ACY_NF and i.ACY_NF=e.ACY_NF and i.BALSHEY_NF=@BLCSHTYEA_NF and i.SSD_CF=@p_ssd_cf)
    and e.ACMTRS_NT < 2000
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;32;'
  select @code_erreur=19
  goto plantage
end

-- TLIFDRI, retro
-------------------
if @debug='D'
  select getdate(),'tlifdri, retro',getdate()
-------------------
insert into TLIFDRI ( CTR_NF,
                            END_NT,
                            SEC_NF,
                            UWY_NF,
                            UW_NT,
                            CRE_D,
                            BALSHEY_NF,
                            BALSHTMTH_NF,
                            ACY_NF,
                            SSD_CF,
                            AUTUPD_B,
                            COMACC_B,
                            CMT_NT,
                            CREUSR_CF,
                            LSTUPD_D,
                            LSTUPDUSR_CF )
select Distinct e.CTR_NF,
                0,
                e.SEC_NF,
                e.ACY_NF, -- 003 : au lieu de e.UWY_NF
                1,
                getdate(),
                @BLCSHTYEA_NF,
                @BLCSHTMTH_NF,
                e.ACY_NF,
                @p_ssd_cf,
                0,
                0,
                0,
                @p_usr_cf,
                getdate(),
                @p_usr_cf
from #ESID0811 e
where Not Exists ( select Distinct 1
                   from TLIFDRI i
                   where i.CTR_NF    =e.CTR_NF
                     and i.END_NT    =0
                     and i.SEC_NF    =e.SEC_NF
                     and i.UWY_NF    =e.ACY_NF -- 002 : au lieu de 'e.uwy_nf'
                     and i.ACY_NF    =e.ACY_NF
                     and i.BALSHEY_NF=@BLCSHTYEA_NF
                     and i.SSD_CF    =@p_ssd_cf )
  and e.ACMTRS_NT > 2000

select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;34;'
    select @code_erreur=20
  goto plantage
end

-- Libérations --modif 35
-------------------
if @debug='D'
  select getdate(),'Libérations #ESID0811',getdate()
-------------------
insert into TLIFEST
  (
  CTR_NF
 ,END_NT
 ,SEC_NF
 ,UWY_NF
 ,UW_NT
 ,CRE_D
 ,BALSHEY_NF
 ,BALSHTMTH_NF
 ,ACY_NF
 ,PRS_CF
 ,ACMTRS_NT
 ,SSD_CF
 ,CUR_CF
 ,ESTMNT_M
 ,INDSUP_B
 ,ORICOD_LS
 ,CREUSR_CF
 ,LSTUPD_D
 ,LSTUPDUSR_CF
  )
select
  CTR_NF
 ,0 --END_NT
 ,SEC_NF
 ,UWY_NF + dbo.FtLiberationExeP1(ADMTYP_CT,ACMTRS_NT)
 ,1 --UW_NT
 ,getdate() --CRE_D
 ,@BLCSHTYEA_NF
 ,@BLCSHTMTH_NF
 ,ACY_NF + 1
 ,500 --PRS_CF
 ,ACMTRS_NT + 1
 ,@p_ssd_cf
 ,CUR_CF
 ,ESTMNT_M * -1
 ,0 --INDSUP_B
 ,'auto' --ORICOD_LS
 ,@p_usr_cf
 ,getdate()
 ,@p_usr_cf
from #ESID0811
where ACY_NF < @BLCSHTYEA_NF + 2
  and ACMTRS_NT%10=3 -- postes à liberer
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;36;'
  select @code_erreur=21
  goto plantage
end

-- Regroupements
-- recherche des dernieres estimations (max(cre_d)
-------------------
if @debug='D' or @debug='R'
  select getdate(),'#regroup_last, initialisation'
-------------------
-- 003 debut debut
-- [19] Début
insert into #regroup_last (CTR_NF, SEC_NF, UWY_NF, ACY_NF, CUR_CF, ADMTYP_CT, ACMTRS_NT, ESTMNT_M)
select Distinct CTR_NF, SEC_NF, UWY_NF, ACY_NF, CUR_CF, ADMTYP_CT, ACMTRS_NT, ESTMNT_M
from #ESID0811
where LOB_CF='31'
  and ACMTRS_NT In (1503,1523,1533,1603,1623,1633,2503,2523,2533,2603,2623,2633)
-- [019] Fin

-- Cumul du regroupement 1063
-------------------
if @debug='D' or @debug='R'
  select getdate(),'Cumul du regroupement 1063'
-------------------
insert into #regroup_insert(CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT,ESTMNT_M)
select CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT,isnull(sum(ESTMNT_M),0)
 from #regroup_last
  where ACMTRS_NT in(1503,1523,1533)
group by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT
order by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;44;'
  goto plantage
end

update #regroup_insert set ACMTRS_NT=1063 where ACMTRS_NT=null
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;45;'
    select @code_erreur=25
  goto plantage
end

-- Cumul du regroupement 1083
-------------------
if @debug='D' or @debug='R'
  select getdate(),'Cumul du regroupement 1083'
-------------------
insert into #regroup_insert(CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT,ESTMNT_M)
select CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT,isnull(sum(ESTMNT_M),0)
 from #regroup_last
  where ACMTRS_NT in(1603,1623,1633)
group by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT
order by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;46;'
    select @code_erreur=26
  goto plantage
end

update #regroup_insert set ACMTRS_NT=1083 where ACMTRS_NT=null
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;47;'
    select @code_erreur=27
  goto plantage
end

-- Cumul du regroupement 2063
-------------------
if @debug='D' or @debug='R'
  select getdate(),'Cumul du regroupement 2063',getdate()
-------------------
insert into #regroup_insert(CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT,ESTMNT_M)
select CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT,isnull(sum(ESTMNT_M),0)
 from #regroup_last
  where ACMTRS_NT in (2503,2523,2533)
group by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT
order by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;48;'
    select @code_erreur=28
  goto plantage
end

update #regroup_insert set ACMTRS_NT=2063 where ACMTRS_NT=null
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;49;'
    select @code_erreur=29
  goto plantage
end

-- Cumul du regroupement 2083       [014]
-------------------
if @debug='D' or @debug='R'
  select getdate(),'Cumul du regroupement 2083',getdate()
-------------------
insert into #regroup_insert(CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT,ESTMNT_M)
select CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT,isnull(sum(ESTMNT_M),0)
 from #regroup_last
  where ACMTRS_NT in (2603,2623,2633)
group by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT
order by CTR_NF,SEC_NF,UWY_NF,ACY_NF,CUR_CF,ADMTYP_CT
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;50;'
    select @code_erreur=40
  goto plantage
end

update #regroup_insert set ACMTRS_NT=2083 where ACMTRS_NT=null
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;51;'
    select @code_erreur=41
  goto plantage
end

-------------------
if @debug='D' or @debug='R'
begin
  select getdate()
    select 'regroup_last',* from #regroup_last
    select 'regroup_insert',* from #regroup_insert
end
-------------------
-- [16] Il faut insérer des montants à zéro sur les postes de regroupement complémentaires
insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 1503, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=1063
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=1503)

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 1523, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=1063
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=1523)

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 1533, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=1063
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=1533 )

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 1603, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=1083
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=1603 )

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 1623, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=1083
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=1623 )

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 1633, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=1083
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=1633)

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 2503, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=2063
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                   and a.SEC_NF   =b.SEC_NF
                   and a.UWY_NF   =b.UWY_NF
                   and a.ACY_NF   =b.ACY_NF
                   and a.CUR_CF   =b.CUR_CF
                   and a.ADMTYP_CT=b.ADMTYP_CT
                   and b.ACMTRS_NT=2503 )

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 2523, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=2063
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF =b.CTR_NF
                   and a.SEC_NF   =b.SEC_NF
                   and a.UWY_NF   =b.UWY_NF
                   and a.ACY_NF   =b.ACY_NF
                   and a.CUR_CF   =b.CUR_CF
                   and a.ADMTYP_CT=b.ADMTYP_CT
                   and b.ACMTRS_NT=2523)

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 2533, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=2063
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=2533 )

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 2603, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=2083
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=2603 )

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 2623, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=2083
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=2623 )

insert into #regroup_cpl
select a.CTR_NF, a.SEC_NF, a.UWY_NF, a.ACY_NF, a.CUR_CF, a.ADMTYP_CT, 2633, getdate(), 0
from #regroup_insert a
where a.ACMTRS_NT=2083
  and Not Exists ( select 1
                   from #regroup_last b
                   where a.CTR_NF   =b.CTR_NF
                     and a.SEC_NF   =b.SEC_NF
                     and a.UWY_NF   =b.UWY_NF
                     and a.ACY_NF   =b.ACY_NF
                     and a.CUR_CF   =b.CUR_CF
                     and a.ADMTYP_CT=b.ADMTYP_CT
                     and b.ACMTRS_NT=2633 )

-- TLIFEST, constitutions
-------------------
if @debug='D'
  select getdate(),'TLIFEST, constitutions'
-------------------
insert into TLIFEST
(CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B,ORICOD_LS,CREUSR_CF,LSTUPD_D,LSTUPDUSR_CF)
select
 CTR_NF,0,SEC_NF,UWY_NF,1,getdate(),@BLCSHTYEA_NF,@BLCSHTMTH_NF,ACY_NF,500,ACMTRS_NT,@p_ssd_cf,CUR_CF,ESTMNT_M,0,'auto',@p_usr_cf,getdate(),@p_usr_cf
from #regroup_insert
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;52;'
  select @code_erreur=42
  goto plantage
end

-- Libérations --modif 35
-------------------
if @debug='D'
  select getdate(),'Libérations #regroup_insert'
-------------------
insert into TLIFEST
  (
  CTR_NF
 ,END_NT
 ,SEC_NF
 ,UWY_NF
 ,UW_NT
 ,CRE_D
 ,BALSHEY_NF
 ,BALSHTMTH_NF
 ,ACY_NF
 ,PRS_CF
 ,ACMTRS_NT
 ,SSD_CF
 ,CUR_CF
 ,ESTMNT_M
 ,INDSUP_B
 ,ORICOD_LS
 ,CREUSR_CF
 ,LSTUPD_D
 ,LSTUPDUSR_CF
  )
 select
  CTR_NF
 ,0 -- END_NT
 ,SEC_NF
 ,UWY_NF + dbo.FtLiberationExeP1(ADMTYP_CT,ACMTRS_NT)
 ,1 -- UW_NT
 ,getdate() -- CRE_D
 ,@BLCSHTYEA_NF
 ,@BLCSHTMTH_NF
 ,ACY_NF + 1
 ,500 -- PRS_CF
 ,ACMTRS_NT + 1
 ,@p_ssd_cf
 ,CUR_CF
 ,ESTMNT_M * -1
 ,0 -- INDSUP_B
 ,'auto' -- ORICOD_LS
 ,@p_usr_cf -- CREUSR_CF
 ,getdate() -- LSTUPD_D
 ,@p_usr_cf -- LSTUPDUSR_CF
from #regroup_insert
where ACY_NF < @BLCSHTYEA_NF + 2 -- modif 7
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;54;'
  select @code_erreur=43
  goto plantage
end

if @debug='D'
	select getdate(),'TLIFEST, complements'
	-- [16] TLIFEST, Compléments
-------------------
if @debug='D'
  select getdate(),'TLIFEST, complements'
-------------------
insert into TLIFEST
(CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B,ORICOD_LS,CREUSR_CF,LSTUPD_D,LSTUPDUSR_CF)
select
 CTR_NF,0,SEC_NF,UWY_NF,1,getdate(),@BLCSHTYEA_NF,@BLCSHTMTH_NF,ACY_NF,500,ACMTRS_NT,@p_ssd_cf,CUR_CF,ESTMNT_M,0,'auto',@p_usr_cf,getdate(),@p_usr_cf
 from #regroup_cpl
select @rowcount=@@rowcount,@erreur=@@error, @transtate=@@transtate
if @erreur!=0
begin
  Raiserror 20001 '20001 APPLICATIF;58;'
  select @code_erreur=45
  goto plantage
end

commit
return 0

fin:
-------------------
if @debug='D'
begin
  select 'fin',getdate()
  select 'fin: esid0811',* from #esid0811
end
-------------------
commit
return 0

plantage:
-------------------
if @debug='D'
begin
  select 'plantage',getdate()
  select 'plantage: esid0811',* from #esid0811
end
-------------------
if @debug='D'
	select getdate(),'rollback'
rollback
return 1
go
if object_id('PiLIFEST_02') is not null
    PRINT '<<< CREATED PROCEDURE PiLIFEST_02 >>>'
else
    PRINT '<<< FAILED CREATING PROCEDURE PiLIFEST_02 >>>'
go
grant execute on PiLIFEST_02 TO GOMEGA
go
grant execute on PiLIFEST_02 TO GDBBATCH
go
