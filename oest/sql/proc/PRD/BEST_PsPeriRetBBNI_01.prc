USE BEST
go
IF OBJECT_ID('dbo.PsPeriRetBBNI_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPeriRetBBNI_01
    IF OBJECT_ID('dbo.PsPeriRetBBNI_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPeriRetBBNI_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPeriRetBBNI_01 >>>'
END
go
create procedure PsPeriRetBBNI_01
(
  @p_segtyp_ct      char(1), --type de segmentation ( 'A' ou 'E' )
  @p_clo_date       char(8),
  @p_x_days         int,
  @norme_cf         char(4),
  @p_quarter_end    varchar(10) --quarter end for dry run,
)
with execute as caller as
/***************************************************
Domaine : Estimations
Base principale : BEST
Version: 1
Date de creation: 25/02/2025
Description du programme: Descente du p�rim�tre r�trocessio BBNI   
Conditions d'execution:
Commentaires:
_________________

[001] MZM           28/07/2025 :US 6250  : 112796 Cut-off management : Contract recognized day of cut-off should be taken into account
*****************************************************/
declare @erreur int

-------------------------
-- P�rim�tre r�trocession
-------------------------

-- Cas multifiliale
-- La liste des filiales est dans la table BTRAV..TESTSSD
-- Le filtre est fait sur la date maximum du libelle d'inventaire passee en param�tre


if @norme_cf = 'EBS'
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
    SELECT @v_pos_booking_minus_days = dateadd(day,1,dateadd(day, @p_x_days * -1, @v_pos_booking_d) ) --001 dateadd(day, @p_x_days * -1, @v_pos_booking_d)
  END
  ELSE 
  BEGIN
    SELECT @v_pos_booking_minus_days = dateadd(day, 1, convert(datetime, @p_quarter_end, 103) ) -- 042 convert(datetime, @p_quarter_end, 103)
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
    RETSEC.USRCRTCOD_CT,   
    RETSEC.USRCRTVAL_LM,   
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
    0,      
    null,   
    null,   
    null,   
    null    
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
   ,STLREQDEL_N                                    
   ,"RET"                                          
   ,convert(char(8), CTRINCUWY_D, 112)             
   ,ESTV2C_COL_14=null
   ,ESTV2C_COL_15=null
   ,TERCTR_B                                       
   ,ESTV2C_COL_17=null
   ,RACCCOND.ACCFRQ_CT                             
   ,convert ( char (8), FAMPRE.FIRPAYDUE_D, 112)   
   ,RETCTR.CLOFAM_CT
   ,RETCTR.ACCFAM_CT
   ,ESTV2C_COL_22=null
   ,ESTV2C_COL_23=null
   ,ESTV2C_COL_24=null
   ,RETIFRS.PRICEDCTR_B                
   ,RETIFRS.PRICEDLR_R                 
   ,TFAMPRE.FLAPROPRM_M                
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
	and TERCTR_B <> 1                                                                                                                  
	and LOB_CF<>'30' and LOB_CF<>'31'
	and RETSEC.RETCTR_NF=RETCTR.RETCTR_NF and RETSEC.RTY_NF=RETCTR.RTY_NF
	and RETSEC.RETCTR_NF*=RACCCOND.RETCTR_NF
	and RETSEC.RETCTR_NF*=TFAMPRE.RETCTR_NF and RETSEC.RTY_NF*=TFAMPRE.RTY_NF and RETSEC.SSD_CF*=TFAMPRE.SSD_CF and RETSEC.RETSEC_NF*=TFAMPRE.RETSEC_NF
	and RETSEC.RETCTR_NF*=FAMPRE.RETCTR_NF and RETSEC.RTY_NF*=FAMPRE.RTY_NF and RETSEC.RETSEC_NF*=FAMPRE.RETSEC_NF
	and RETSEC.RETCTR_NF*=RETIFRS.RETCTR_NF and RETSEC.RTY_NF*=RETIFRS.RTY_NF   --[020]
	and RETSEC.RETCTR_NF*=RFAMMIS.RETCTR_NF and RETSEC.RTY_NF*=RFAMMIS.RTY_NF and RETSEC.RETSEC_NF*=RFAMMIS.RETSEC_NF
	and RETSEC.RETCTR_NF*=PNFAMPO.RETCTR_NF and RETSEC.RTY_NF*=PNFAMPO.RTY_NF and RETSEC.RETSEC_NF*=PNFAMPO.RETSEC_NF
       
  and ( ( @norme_cf = 'EBS' )  
  			and (  RETIFRS.RETRECOD_D < @v_pos_booking_minus_days  )
      )      
       
	and ( 
		      RETSEC.nat_cf IN ('10','11','12','20','21','22','23')
		  OR (RETSEC.nat_cf NOT IN ('10','11','12','20','21','22','23') AND CTRINCUWY_D >= dateadd(day, 1, @v_clo_date ) )  -- A VERIFIER
	    )

end


   select @erreur = @@error
   if @erreur != 0
   begin
      return @erreur
   end
return 0
go
EXEC sp_procxmode 'dbo.PsPeriRetBBNI_01', 'unchained'
go
IF OBJECT_ID('dbo.PsPeriRetBBNI_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPeriRetBBNI_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPeriRetBBNI_01 >>>'
go
GRANT EXECUTE ON dbo.PsPeriRetBBNI_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPeriRetBBNI_01 TO GDBBATCH
go

