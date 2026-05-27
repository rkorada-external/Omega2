USE BEST
go
IF OBJECT_ID('PiESTACCSUP_05') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_05
  PRINT '<<< DROPPED PROC PiESTACCSUP_05 >>>'
END
go
create procedure PiESTACCSUP_05(
    @p_SPEENTNAT_CT varchar(10),        -- type ecritures 2 = sociale 3 = conso [08] tinyint old type
    @p_BOOKING_D datetime,
    @p_ENDDATE_D datetime,           -- endconso_d pour ecriture conso et pstomgen_d pour sociale
    @p_BALSHEYEA_NF smallint,        -- [09]
    @p_BALSHTMTH_NF tinyint          -- [09]   
)         
with execute as caller as
/***************************************************
Programme:               PiESTACCSUP_05
Fichier script associé : BEST_PiESTACCSUP_05.prc
Domaine :               (ES) Estimation
Base principale :       BEST
Version:                1
Auteur:                 J. Ribot
Date de creation:       27/06/2005
Description du programme:       
- sélection des écritures de services post omega

Parametres:
    - type ecritures sociale = 2 ou conso = 3
    - date cloture omega
    - date cloture people pour ecritures sociale ou fermeture conso pour ecritures conso

Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 14/04/2011 D.GATIBELZA ESTDOM21408 OneLedger
2 16/07/2012 R. Cassis   :spot:23802 Modification condition sur oricod_ls
                         - Removed dbo and added ‘with execute as caller as’
3 20/02/2015 R. cassis   :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
4 17/02/2016 Florent     :spot:29066 - pour le GLT à 71 colonnes, même format que PiESTACCSUP_02
5 29/01/2020 Belaid      :spot:83748 - Tike into account the time difference between US and EU.
[06] 03/01/2020 R. Cassis :spira:82010 Les contrats ayant un endorsment invalide (CTRLCK_B = 1) sont exclus de l'extraction pour être au niveau de la rétro
[07] 05/05/2020 R. Cassis :spira:82010 Les contrats ayant un endorsment invalide (CTRLCK_B = 1 trt, = 0 fac) sont exclus de l'extraction pour être au niveau de la rétro
[08] 25/11/2021 HR :spira:99667 EBS/IFRS17 AE extraction during INV and POS
[09] 19/04/2022 R. Cassis :spira:103840 Add Val Balance sheet Year and Month condition when extracting AEs and fix conditions 
[10] 24/11/2025 M. NAJI  :US 7605	User Story	SERQS - AE retro SERQS to be extracted by assumed site closing
****************************************************/
declare @erreur     int,
        @tran_imbr	bit

select @erreur      = 0
select @tran_imbr   = 1


/*****************************************************
split speennat list
*/
create TABLE #TSPEENTNAT (SPEENTNAT_CT tinyint not null)

declare @position int,
          @delim varchar(2),
          @speentnatlist varchar(10),
          @str varchar(10)

select @delim = ','

Select @speentnatlist = RTRIM(@p_SPEENTNAT_CT)+@delim
Select @position = CHARINDEX(@delim, @speentnatlist)

   WHILE @position > 0
   begin
       Select @str = RTRIM(LEFT(@speentnatlist, @position - 1))
       INSERT INTO #TSPEENTNAT (SPEENTNAT_CT)
       VALUES (convert(tinyint, @str))
       Select @speentnatlist = RIGHT(@speentnatlist, LEN(@speentnatlist) - @position)
       Select @position = CHARINDEX(@delim, @speentnatlist)
    end
/*****************************************************/

-- ------------------------------
-- Truncate des tables de travail
-- ------------------------------
truncate table BTRAV..EST_ESPJ0090_TACCSUP
-- ------------------------------------------------------------
-- Début de la transaction
---------------------------------------------------------------
-- if @@trancount = 0
-- begin
--     select @tran_imbr = 0
--     BEGIN TRAN
-- end

----------------------------------------------
------------------- MODIF 5 ------------------
---- deadline is 5 hours later for US SSDs ---
----------------------------------------------
if suser_name() = 'ubam'
begin
  -- @p_ENDDATE_D +  1day and 5h
  select @p_ENDDATE_D=dateadd(hh,29,@p_ENDDATE_D)
end else
begin
  -- @p_ENDDATE_D +  1day
  select @p_ENDDATE_D=dateadd(hh,24,@p_ENDDATE_D)
end


-- -----------------------------------------
-- Sélection des écritures de service
-- -----------------------------------------

select a.TRN_NT,
       a.ACCTYP_NF,
       a.SSD_CF,
       a.ESB_CF,
       a.ENTPERY_NF,
       a.ENTPERMTH_NF,
       a.BALSHEY_NF,
       a.BALSHRMTH_NF,
       a.BALSHRDAY_NF,
       a.VALPERY_NF,
       a.VALPERMTH_NF,
       a.TRNCOD_CF,
       a.DBLTRNCOD_CF,
       a.RETAUTGEN_B,
       a.CTR_NF,
       a.END_NT,
       a.SEC_NF,
       a.UWY_NF,
       a.UW_NT,
       a.OCCYEA_NF,
       a.ACY_NF,
       a.SCOSTRMTH_NF,
       a.SCOENDMTH_NF,
       a.CLM_NF,
       a.CUR_CF,
       a.AMT_M,
       a.CED_NF,
       a.BRK_NF,
       a.GEMPRMPAY_NF,
       a.GANPAYORD_NT,
       a.RETCTR_NF,
       a.RETEND_NT,
       a.RETSEC_NF,
       a.RETRTY_NF,
       a.RETUW_NT,
       a.PLC_NT,
       a.RETOCCYEA_NF,
       a.RETACY_NF,
       a.RETSCOSTRMTH_NF,
       a.RETSCOENDMTH_NF,
       a.RCL_NF,
       a.RETCUR_CF,
       a.RETAMT_M,
       a.RTO_NF,
       a.INT_NF,
       a.RETPAY_NF,
       a.RETKEY_CF,
       a.ACCTRN_NT,
       a.COMMAC_LL,
       a.CRE_D,
       a.CREUSR_CF,
       a.LSTUPD_D,
       a.LSTUPDUSR_CF,
       a.SPEENTTYP_CF,
       a.SPEENTNAT_CT,
       EVT_NF,   -- [002]
       REVT_NF   -- [002]
into #EST_ESPJ0090_TACCSUP
from BEST..TACCSUP a
LEFT OUTER JOIN  btrt..tcontr b  on  a.ctr_nf = b.ctr_nf
                  and   a.uw_nt  = b.uw_nt
                  and   a.end_nt = b.end_nt
                  and   a.uwy_nf = b.uwy_nf
                  
LEFT OUTER JOIN bfac..tcontr c on a.ctr_nf = c.ctr_nf
                  and   a.uw_nt  = c.uw_nt 
                  and   a.end_nt = c.end_nt
                  and   a.uwy_nf = c.uwy_nf
JOIN BREF..TBATCHSSD s on(  b.SSD_CF=s.SSD_CF  or  c.SSD_CF =s.SSD_CF ) and s.BATCHUSER_CF= suser_name()
where SPEENTNAT_CT in (SELECT SPEENTNAT_CT FROM #TSPEENTNAT ) -- [08] = @p_SPEENTNAT_CT
--  and CRE_D >= @p_BOOKING_D
--  and CRE_D <  @p_ENDDATE_D  -- MODIF 5 
and a.CRE_D > @p_BOOKING_D  -- [09]
and a.CRE_D <=  @p_ENDDATE_D  -- [09]
--  and convert(char(8), CRE_D, 112) <= @p_ENDDATE_D -- Before MODIF 5
and valpery_nf = @p_BALSHEYEA_NF  --[09]
and valpermth_nf = @p_BALSHTMTH_NF  --[09]
and a.ACCTYP_NF in (0,3,5)
and  ( ( b.ctr_nf != null and b.CTRLCK_B != 1 ) or ( c.ctr_nf != null and c.CTRLCK_B != 0 )) 

insert into  #EST_ESPJ0090_TACCSUP
select a.TRN_NT,
       a.ACCTYP_NF,
       a.SSD_CF,
       a.ESB_CF,
       a.ENTPERY_NF,
       a.ENTPERMTH_NF,
       a.BALSHEY_NF,
       a.BALSHRMTH_NF,
       a.BALSHRDAY_NF,
       a.VALPERY_NF,
       a.VALPERMTH_NF,
       a.TRNCOD_CF,
       a.DBLTRNCOD_CF,
       a.RETAUTGEN_B,
       a.CTR_NF,
       a.END_NT,
       a.SEC_NF,
       a.UWY_NF,
       a.UW_NT,
       a.OCCYEA_NF,
       a.ACY_NF,
       a.SCOSTRMTH_NF,
       a.SCOENDMTH_NF,
       a.CLM_NF,
       a.CUR_CF,
       a.AMT_M,
       a.CED_NF,
       a.BRK_NF,
       a.GEMPRMPAY_NF,
       a.GANPAYORD_NT,
       a.RETCTR_NF,
       a.RETEND_NT,
       a.RETSEC_NF,
       a.RETRTY_NF,
       a.RETUW_NT,
       a.PLC_NT,
       a.RETOCCYEA_NF,
       a.RETACY_NF,
       a.RETSCOSTRMTH_NF,
       a.RETSCOENDMTH_NF,
       a.RCL_NF,
       a.RETCUR_CF,
       a.RETAMT_M,
       a.RTO_NF,
       a.INT_NF,
       a.RETPAY_NF,
       a.RETKEY_CF,
       a.ACCTRN_NT,
       a.COMMAC_LL,
       a.CRE_D,
       a.CREUSR_CF,
       a.LSTUPD_D,
       a.LSTUPDUSR_CF,
       a.SPEENTTYP_CF,
       a.SPEENTNAT_CT,
       EVT_NF,   -- [002]
       REVT_NF   -- [002]
from BEST..TACCSUP a
LEFT OUTER JOIN  btrt..tcontr b  on  a.ctr_nf = b.ctr_nf
                  and   a.uw_nt  = b.uw_nt
                  and   a.end_nt = b.end_nt
                  and   a.uwy_nf = b.uwy_nf
                  
LEFT OUTER JOIN bfac..tcontr c on a.ctr_nf = c.ctr_nf
                  and   a.uw_nt  = c.uw_nt 
                  and   a.end_nt = c.end_nt
                  and   a.uwy_nf = c.uwy_nf
JOIN BREF..TBATCHSSD s  on a.SSD_CF=s.SSD_CF  and s.BATCHUSER_CF= suser_name()
where SPEENTNAT_CT in (SELECT SPEENTNAT_CT FROM #TSPEENTNAT ) -- [08] = @p_SPEENTNAT_CT
--  and CRE_D >= @p_BOOKING_D
--  and CRE_D <  @p_ENDDATE_D  -- MODIF 5 
and a.CRE_D > @p_BOOKING_D  -- [09]
and a.CRE_D <=  @p_ENDDATE_D  -- [09]
--  and convert(char(8), CRE_D, 112) <= @p_ENDDATE_D -- Before MODIF 5
and valpery_nf = @p_BALSHEYEA_NF  --[09]
and valpermth_nf = @p_BALSHTMTH_NF  --[09]
and a.ACCTYP_NF NOT in (0,3,5)
and  ( ( b.ctr_nf != null and b.CTRLCK_B != 1 ) or ( c.ctr_nf != null and c.CTRLCK_B != 0 )) 


select @erreur = @@error
if @erreur != 0
  goto fin

-- --------------------------------
-- Descente de la table en fichiers
-- --------------------------------
select SSD_CF,
       ESB_CF,
       BALSHEY_NF,
       BALSHRMTH_NF,
       BALSHRDAY_NF,
       TRNCOD_CF,
       DBLTRNCOD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       OCCYEA_NF,
       ACY_NF,
       SCOSTRMTH_NF,
       SCOENDMTH_NF,
       CLM_NF,
       CUR_CF,
       AMT_M,
       CED_NF,
       BRK_NF,
       GEMPRMPAY_NF,
       GANPAYORD_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RETRTY_NF,     --[001]
       RETUW_NT,
       RETOCCYEA_NF,
       RETACY_NF,
       RETSCOSTRMTH_NF,
       RETSCOENDMTH_NF,
       RCL_NF,
       RETCUR_CF,
       RETAMT_M,
       PLC_NT,
       RTO_NF,
       INT_NF,
       RETPAY_NF,
       RETKEY_CF,
       RETAUTGEN_B,
       ACCTYP_NF,
       TRN_NT,        --[001]
       ORICOD_LS=case When SPEENTNAT_CT <= 3 THEN "IFRS" else "EBSGTA" end  --[002]
      ,RETROAUTO_B=case when ACCTYP_NF=0 then 1 else null end 
      ,SPEENTNAT_CT
      ,EVT_NF
      ,REVT_NF
      ,ACCTRN_NT
from #EST_ESPJ0090_TACCSUP                 --[001]

-- ************************************************************

-- ------------------------------------------------------------
-- Fin de la transaction
-- ------------------------------------------------------------
-- if @tran_imbr = 0
--     COMMIT TRAN

return 0

fin:
-- if @tran_imbr = 0
--     ROLLBACK TRAN

return 1
go
IF OBJECT_ID('PiESTACCSUP_05') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTACCSUP_05 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTACCSUP_05 >>>'
go
GRANT EXECUTE ON PiESTACCSUP_05 TO GOMEGA
go
GRANT EXECUTE ON PiESTACCSUP_05 TO GDBBATCH
go

