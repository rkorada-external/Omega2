USE BEST
go
IF OBJECT_ID('dbo.PsSECTION_INI') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsSECTION_INI
    IF OBJECT_ID('dbo.PsSECTION_INI') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsSECTION_INI >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsSECTION_INI >>>'
END
go
create procedure PsSECTION_INI
(
-- @p_POS_BOOKING_X_DT date ,
 @p_NORME char(10)
)
with execute as caller as
/***************************************************
Domaine :   Estimations
Base principale : BEST
Version:    1
Auteur:     M.NAJI
Date de creation:
Description du programme:       Extract closing inception perimeter  EST_IRDPERICASE_INI 
Conditions d'execution:
Commentaires: REQ 11.7 SPIRA 82353

execute BEST..PsSECTION_INI '${POS_BOOKING_X_DT}' , '${NORME}'
execute BEST..PsSECTION_INI '20191130' , 'I17G'

_________________
[001] NLD	24/01/2020 : clonage de PsSECTION_08 afin de créér péricase retro non proprotionnel at inception
[002] NLD	20/11/2020 : spira 91302 - INI - Retro NP - booking status not taken into account
*****************************************************/
declare @erreur int

-------------------------
-- Périmètre rétrocession
-------------------------

-- Cas multifiliale
-- La liste des filiales est dans la table BTRAV..TESTSSD
-- Le filtre est fait sur la date maximum du libelle d'inventaire passee en paramètre



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


-- Affichage du périmètre rétrocession non vie
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
    convert(char(8), CAN_DT, 112), -- ce champs est renseigné à partir de la modif(010) 30/03/2001
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    convert(char(8), CTRINC_D, 112), -- ce champs est renseigné à partir de la modif(010) 30/03/2001
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    convert(char(8), RETCTR.CTREXP_D, 112), -- ce champs est renseigné à partir de la modif(021) 29/07/2019 TRETCTR.CTREXP_D
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
    RETPCPCUR_CF=case when RETSEC.RETSPECUR_CF not in(null,'') then RETSEC.RETSPECUR_CF else RETCTR.RETPCPCUR_CF end, -- Rècuperer la devise du contrat si celle de la section n'existe pas, EST29a-R1
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
    null,   -- Champ acceptation non utilisé en rétro, modif du 26/03/98
    null,   -- Champ acceptation non utilisé en rétro, modif du 26/03/98
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
    null,   -- Champ non utilisé (segmentation client), modif 007
    null,   -- Champ non utilisé (segmentation client), modif 007
    null,   -- Champ non utilisé (segmentation client), modif 007
    null,   -- Champ non utilisé (segmentation client), modif 007
    null,   -- Champ non utilisé (segmentation client), modif 007
    null,    -- Champ non utilisé (segmentation client), modif 007
    0,             --MODIF 008
    null,          --MODIF 009
    null,   -- Champ non utilisé, modif 010
    null,    -- Champ non utilisé, modif 010
    null    --   champ non utilisé , modif 011 Dch
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
   --, case when @p_NORME="I17G" then RETIFRS.GRPFSTCLO_D when @p_NORME="I17L" then RETIFRS.LCLFSTCLO_D else RETIFRS.PARFSTCLO_D end as FSTCLO_D
   --, case when @p_NORME="I17G" then RETIFRS.GRPINISTS_CT when @p_NORME="I17L" then RETIFRS.LOCINISTS_CT else RETIFRS.PARINISTS_CT end as INISTS_CT	  	
  from   BRET..TRETSEC RETSEC, 
  BRET..TRETCTR RETCTR, 
  BRET..TRACCCOND RACCCOND,
  BRET..TRFAMPRE FAMPRE, 
  #TABLE_TRFAMPRE TFAMPRE, 
  BRET..TRETIFRS RETIFRS,
  BREF..TBATCHSSD BATCHSSD
  where  RETSEC.SSD_CF=BATCHSSD.SSD_CF and BATCHSSD.BATCHUSER_CF=suser_name()
         and RETCTR.RETCTRSTS_CT in (3, 19)
         and RETCTR.TERCTR_B <> 1  -- [018]
         and LOB_CF<>'30' and LOB_CF<>'31' -- à vérifier at inception
         and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF and RETSEC.RTY_NF=RETCTR.RTY_NF
         and RETSEC.RETCTR_NF*=RACCCOND.RETCTR_NF
		 and RETSEC.RETCTR_NF*=TFAMPRE.RETCTR_NF and RETSEC.RTY_NF*=TFAMPRE.RTY_NF and RETSEC.SSD_CF*=TFAMPRE.SSD_CF and RETSEC.RETSEC_NF*=TFAMPRE.RETSEC_NF
         and RETSEC.RETCTR_NF*= FAMPRE.RETCTR_NF and RETSEC.RTY_NF*= FAMPRE.RTY_NF and RETSEC.RETSEC_NF*= FAMPRE.RETSEC_NF
         and RETSEC.RETCTR_NF=RETIFRS.RETCTR_NF and RETSEC.RTY_NF=RETIFRS.RTY_NF   --[020]
		 and (( @p_NORME="I17G" and ( RETIFRS.GRPFSTCLO_D  = NULL OR RETIFRS.GRPINISTS_CT <> 2 ) ) OR
        ( @p_NORME="I17L" and ( RETIFRS.LCLFSTCLO_D  = NULL OR RETIFRS.LOCINISTS_CT <> 2 ) ) OR
        ( @p_NORME="I17P" and ( RETIFRS.PARFSTCLO_D  = NULL OR RETIFRS.PARINISTS_CT <> 2 ) ) )
end
   select @erreur = @@error
   if @erreur != 0
   begin
      return @erreur
   end
return 0
go
EXEC sp_procxmode 'dbo.PsSECTION_INI', 'unchained'
go
IF OBJECT_ID('dbo.PsSECTION_INI') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsSECTION_INI >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsSECTION_INI >>>'
go
GRANT EXECUTE ON dbo.PsSECTION_INI TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_INI TO GDBBATCH
go


