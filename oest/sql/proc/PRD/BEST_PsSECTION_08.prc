USE BEST
go
IF OBJECT_ID('dbo.PsSECTION_08') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSECTION_08
    IF OBJECT_ID('dbo.PsSECTION_08') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSECTION_08 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSECTION_08 >>>'
END
go
create procedure PsSECTION_08
(
    @p_segtyp_ct char(1),
    @p_ssd_cf    USSD_CF,
    @p_clo_date       char(8) = '',
    @p_x_days         int = 0,
    @norme_cf         char(4) = 'I4I',
    @p_quarter_end    varchar(10) = 'NONE' --quarter end for dry run,
)
with execute as caller as
/***************************************************
Domaine : Estimations
Base principale : BEST
Version: 1
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: Descente du p�rim�tre r�trocession dommages au niveau CASEX
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: M.Ha-Thuc
Date: 12/03/98
Description: - recherche des zones SOB, TOP, territorialit�, type comptable et garantie et rajout de 2 champs suppl�mentaires au p�rim�tre
        - USRCRTCOD_CT ( code du crit�re utilisateur acceptation )
        - USRCRTVAL_LM ( valeur du crit�re utilisateur acceptation )
_________________
MODIFICATION 2
Auteur: M.Ha-Thuc
Date: 15/09/98
Description: - rajout de champs suppl�mentaires (non utilis�s) pour conserver une structure identique � tous les p�rim�tres.
_________________
MODIFICATION 3
Auteur: M.Bourdaillet
Date: 05/03/1999
Description: Rajout de six champs pour la segmentation client. Mais pour ce perimetre les champs n'ontpas besoin d'etre renseign�s; ils sont donc forces � null
_________________
MODIFICATION 8
Auteur: MONTAGNAC(ASCOTT)
Date: 25/08/1999
Description: Ajout de FACADMTYP_B � la fin du select mis � 0 pour les trait�s
_________________
MODIFICATION 9
Auteur: FCharles
Date: 06/05/2000
Description: Ajout de la date CRTVRSINC_D dans le select.
_________________
MODIFICATION 10
Auteur: O.Arik(AURA)
Date: 30/03/2001
Description: Ajout de RECBRK_B (Indic d'existance de courtage sur REC) et de RECBRK_R (taux de court. sur reconstitution) dans le select. on renseigne les champs CTRINC_D et CAN_DT dans le select.
_________________
MODIFICATION 11
Auteur:  D. Chetboul
Date: 16/08/2011
SPOT: 22459
Description: Ajout du champ filler (null) pour compl�ter le champ manquant lors de la fusion
_________________
11 11/01/2013 Roger Cassis :spot:24041 pour Livraison solvency 2
12                          Removed dbo and added with execute as caller as
13 20/11/2014 Florent      :spot:27747 Multi Currency - ajout colonnes sur le p�rim�tre
                           :spot:27748 Loss Corridor  - ajout colonnes sur le p�rim�tre

14 28/04/2015 S.ASKRI      :spot:28465 EST29a-R1
15 02/03/2015 P. Menant    :spot:28306 EST37
16 02/102/015 Florent      :spot:29641 gestion du cas devise cha�ne vide
[017] S.Behague     16/08/2016 :spot:31066 Spira 52504 - Prise en compte poste PMD
[018] MZM           26/06/2018 :spira52869 Exclure des Contrats Retro les Clos comptablement
[019] S.Behague     20/09/2019 :spira:60627 - PPrise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro
[020] MZM                                               08/01/2019 :spira:70671 : Ajout des Colonnes Montant Retro Net Premium et Retro pricing LR pour le Calcul des FUTURES RETRO PREMIUM et CLAIMS
[021] MZM                                               29/07/2019 :spira:80281 : add stop rule for retro future premium : Extration de la colonne Date d'expiration :
[022] NLD                                               24/01/2020 :spira:83120 : REQ10.7/REQ10.8 - Multiple currencies management
[023] BEL	22/01/2021 : spira-91085	Get ASSFINANCE_CT value 
[024] DaD        08/01/2022    spira : 94569 Condition on contract recognition date and inception dates in pericase extractions
[025] DaD        25/04/2022    spira : 94569 add parameter Quarter End
[026] DaD        23/01/2023    spira : 107224 not include contract recognized on cut off date
[027] HR         22/01/2024    spira : 111062 I17 - No retro link for LC assumed cession on onerous Q+1
*****************************************************/
declare @erreur int

-------------------------
-- P�rim�tre r�trocession
-------------------------

-- Cas multifiliale
-- La liste des filiales est dans la table BTRAV..TESTSSD
-- Le filtre est fait sur la date maximum du libelle d'inventaire passee en param�tre


if @p_ssd_cf = 0
begin

if object_id('#TABLE_TRFAMPRM') is not null drop Table #TABLE_TRFAMPRM

if object_id('#TABLE_TRFAMPRE') is not null drop Table #TABLE_TRFAMPRE

select  RETPCPCUR_CF=case when SEC.RETSPECUR_CF not in(null,'') then SEC.RETSPECUR_CF else CTR.RETPCPCUR_CF end, PRM.PRMDUECUR_CF, PRM.RETCTR_NF, PRM.RTY_NF, PRM.SSD_CF, PRM.PRMDUE_M, PRM.PRMDUE_M* cast(case when (CUR.EXC_R>0) then CUR2.EXC_R/CUR.EXC_R else 1.0 end AS NUMERIC(24,12)) as CUR_PRMDUE_M 
INTO #TABLE_TRFAMPRM
from BRET..TRFAMPRM PRM, BRET..TRETCTR CTR, 
--BRET..TRACCSEN ACC, 
BRET..TRETSEC SEC, BREF..TCURQUOT CUR, BREF..TCURQUOT CUR2
where 
PRM.RETCTR_NF = CTR.RETCTR_NF 
and PRM.RTY_NF = CTR.RTY_NF 
and PRM.SSD_CF = CTR.SSD_CF 
and PRM.RETCTR_NF = SEC.RETCTR_NF 
and PRM.RTY_NF = SEC.RTY_NF 
and PRM.SSD_CF = SEC.SSD_CF 
and SEC.RETSEC_NF =1
--and PRM.PRMDUE_M != 0
--and PRM.RETCTR_NF='RN0000078'
--and PRM.RETCTR_NF = ACC.RETCTR_NF 
--and PRM.RTY_NF = ACC.RTY_NF 
--and PRM.SSD_CF = ACC.SSD_CF 
--and PRM.RETACCSEN_NT = ACC.RETACCSEN_NT
and CUR.ssd_cf = PRM.ssd_cf
       and CUR.CUR_CF = case when SEC.RETSPECUR_CF not in(null,'') then SEC.RETSPECUR_CF else CTR.RETPCPCUR_CF end
       and CUR.EXC_D = (select max(C2.exc_d) from BREF..TCURQUOT C2 where C2.ssd_cf=PRM.ssd_cf and C2.cur_cf=case when SEC.RETSPECUR_CF not in(null,'') then SEC.RETSPECUR_CF else CTR.RETPCPCUR_CF end
                       and C2.exc_d <= convert(datetime,convert(char(10),PRM.RTY_NF) + "/12/31"))
and CUR2.ssd_cf = PRM.ssd_cf
       and CUR2.CUR_CF = PRM.PRMDUECUR_CF
       and CUR2.EXC_D = (select max(C2.exc_d) from BREF..TCURQUOT C2 where C2.ssd_cf=PRM.ssd_cf and C2.cur_cf=PRM.PRMDUECUR_CF
                       and C2.exc_d <= convert(datetime,convert(char(10),PRM.RTY_NF) + "/12/31"))

 
select PRM.RETCTR_NF, PRM.RTY_NF, PRM.RETPCPCUR_CF, PRM.SSD_CF,1 as  RETSEC_NF, cast(SUM(PRM.PRMDUE_M) AS decimal(18, 3)) AS PRMDUE_SUM, cast(SUM(CUR_PRMDUE_M) AS decimal(18, 3)) AS FLAPROPRM_M 
INTO #TABLE_TRFAMPRE
from #TABLE_TRFAMPRM PRM 
GROUP BY PRM.RETCTR_NF, PRM.RTY_NF, PRM.SSD_CF, PRM.RETPCPCUR_CF 

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
        SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * -1, @v_pos_booking_d)
    END
    ELSE 
    BEGIN
        SELECT @v_pos_booking_minus_days = convert(datetime, @p_quarter_end, 103)
    END
END


-- Affichage du p�rim�tre r�trocession non vie
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
    convert(char(8), RETCTR.CAN_DT, 112), -- ce champs est renseign� � partir de la modif(010) 30/03/2001
    null,
    null,
    null,
    null,
    null,
    RFAMMIS.CTBGENFEE_R,
    null,
    convert(char(8), CTRINC_D, 112), -- ce champs est renseign� � partir de la modif(010) 30/03/2001
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    convert(char(8), RETCTR.CTREXP_D, 112), -- ce champs est renseign� � partir de la modif(021) 29/07/2019 TRETCTR.CTREXP_D
    null,
    null,
    null,
    RETSEC.GAR_CF, -- recuperation du champs � partir de TRETSEC; modif du 12/03/98
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
    RETPCPCUR_CF=case when RETSEC.RETSPECUR_CF not in(null,'') then RETSEC.RETSPECUR_CF else RETCTR.RETPCPCUR_CF end, -- R�cuperer la devise du contrat si celle de la section n'existe pas, EST29a-R1
    RETSEC.PCPRSKTRY_CF, -- recuperation du champs � partir de TRETSEC; modif du 12/03/98
    null,
    null,
    PRFCOM_R = case when RETSEC.nat_cf in ('10','11','12','20','21','22','23') then RFAMMIS.PRFCOM_R else PNFAMPO.PRFCOM_R end,
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
    RETSEC.SOB_CF, -- recuperation du champs � partir de TRETSEC; modif du 12/03/98
    null,
    null,
    RETSEC.TOP_CF, -- recuperation du champs � partir de TRETSEC; modif du 12/03/98
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
    RETCTR.RETACCTYP_CT, -- recuperation du champs � partir de TRETCTR; modif du 12/03/98
    null,
    RETCTRSTS_CT,
    null,
    null,
    null,
    null,
    null,
    FAMPRE.BRK_R,
    null,
    RETCTRCAT_CF,
    CLECUTPER_B,
    CLECUTPER_NB,
    ORICUR_B,
    RETACCADM_B,
    RETCTR.SSDRTO_B,
    RETCTR.RAICOM_B,
    null,
    RETSEC.USRCRTCOD_CT,    -- Champ rajout� au perim�tre, modif du 12/03/98
    RETSEC.USRCRTVAL_LM,    -- Champ rajout� au perim�tre, modif du 12/03/98
    null,   -- Champ acceptation non utilis� en r�tro, modif du 26/03/98
    null,   -- Champ acceptation non utilis� en r�tro, modif du 26/03/98
    null,   -- Champ acceptation non utilis� en r�tro, modif du 26/05/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� en r�tro, modif du 15/09/98
    null,   -- Champ non utilis� (segmentation client), modif 007
    null,   -- Champ non utilis� (segmentation client), modif 007
    null,   -- Champ non utilis� (segmentation client), modif 007
    null,   -- Champ non utilis� (segmentation client), modif 007
    null,   -- Champ non utilis� (segmentation client), modif 007
    null,    -- Champ non utilis� (segmentation client), modif 007
    0,             --MODIF 008
    null,          --MODIF 009
    null,   -- Champ non utilis�, modif 010
    null,    -- Champ non utilis�, modif 010
    null    --   champ non utilis� , modif 011 Dch
   ,CLMCUTOFF_B=null
   ,PRMCUTOFF_B=null
   ,CLMRUNOFF_B=null
   ,PRMRUNOFF_B=null
   ,RETSEC.ASSFINANCE_CT --[023] 
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
   ,STLREQDEL_N                                                                  --MODIF 15
   ,"RET"                                                                        --MODIF 15
   ,convert(char(8), CTRINCUWY_D, 112)                                           --MODIF 15
   ,ESTV2C_COL_14=null
   ,ESTV2C_COL_15=null
   ,TERCTR_B                                                                      -- ESTV2C_COL_16=null [018]
   ,ESTV2C_COL_17=null
   ,RACCCOND.ACCFRQ_CT                                -- [017]
   ,convert ( char (8), FAMPRE.FIRPAYDUE_D, 112)      -- [017]
   ,RETCTR.CLOFAM_CT
   ,RETCTR.ACCFAM_CT
   ,ESTV2C_COL_22=null
   ,ESTV2C_COL_23=null
   ,ESTV2C_COL_24=null
   ,RETIFRS.PRICEDCTR_B                 --ESTV2C_COL_25=null [020]
   ,RETIFRS.PRICEDLR_R                  --ESTV2C_COL_26=null [020]
   ,TFAMPRE.FLAPROPRM_M                                                                  --ESTV2C_COL_27=null [020]
   ,ESTV2C_COL_28=null
   ,ESTV2C_COL_29=null
   ,ESTV2C_COL_30=null
from
	BRET..TRETSEC RETSEC, 
	BRET..TRETCTR RETCTR, 
	BTRAV..TESTSSD ESTSSD, 
	BRET..TRACCCOND RACCCOND,
	BRET..TRFAMPRE FAMPRE, 
	#TABLE_TRFAMPRE TFAMPRE, 
	BRET..TRETIFRS RETIFRS,
	BRET..TRFAMMIS RFAMMIS,
	BRET..TPNFAMPO PNFAMPO
where RETSEC.SSD_CF=ESTSSD.SSD_CF
	and (RETCTRSTS_CT=3 or RETCTRSTS_CT=19)
	and TERCTR_B <> 1                                                                                                                      -- [018]
	and LOB_CF<>'30' and LOB_CF<>'31'
	and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF and RETSEC.RTY_NF=RETCTR.RTY_NF
	and RETSEC.RETCTR_NF*=RACCCOND.RETCTR_NF
	and RETSEC.RETCTR_NF*=TFAMPRE.RETCTR_NF and RETSEC.RTY_NF*=TFAMPRE.RTY_NF and RETSEC.SSD_CF*=TFAMPRE.SSD_CF and RETSEC.RETSEC_NF*=TFAMPRE.RETSEC_NF
	and RETSEC.RETCTR_NF*=FAMPRE.RETCTR_NF and RETSEC.RTY_NF*=FAMPRE.RTY_NF and RETSEC.RETSEC_NF*=FAMPRE.RETSEC_NF
	and RETSEC.RETCTR_NF*=RETIFRS.RETCTR_NF and RETSEC.RTY_NF*=RETIFRS.RTY_NF   --[020]
	and RETSEC.RETCTR_NF*=RFAMMIS.RETCTR_NF and RETSEC.RTY_NF*=RFAMMIS.RTY_NF and RETSEC.RETSEC_NF*=RFAMMIS.RETSEC_NF
	and RETSEC.RETCTR_NF*=PNFAMPO.RETCTR_NF and RETSEC.RTY_NF*=PNFAMPO.RTY_NF and RETSEC.RETSEC_NF*=PNFAMPO.RETSEC_NF

    -- [024]
    and ( 
        ( ( @norme_cf = 'EBS' ) 
    --    and RETCTR.CTRINC_D <= @v_clo_date --[027)
        and RETIFRS.RETRECOD_D < @v_pos_booking_minus_days      --[026]
        ) 
        or ( @norme_cf != 'EBS' ) 
       )
	and ( --[027]
		      RETSEC.nat_cf IN ('10','11','12','20','21','22','23')
		  OR (RETSEC.nat_cf NOT IN ('10','11','12','20','21','22','23') AND CTRINCUWY_D <= @p_clo_date)
	    )

		 
end
   select @erreur = @@error
   if @erreur != 0
   begin
      return @erreur
   end
return 0
go
EXEC sp_procxmode 'dbo.PsSECTION_08', 'unchained'
go
IF OBJECT_ID('dbo.PsSECTION_08') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSECTION_08 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSECTION_08 >>>'
go
GRANT EXECUTE ON dbo.PsSECTION_08 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_08 TO GDBBATCH
go

