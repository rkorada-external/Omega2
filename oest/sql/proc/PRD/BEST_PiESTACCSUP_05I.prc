USE BEST
go
IF OBJECT_ID('dbo.PiESTACCSUP_05I') IS NOT NULL
BEGIN
  DROP PROC dbo.PiESTACCSUP_05I
  PRINT '<<< DROPPED PROC dbo.PiESTACCSUP_05I >>>'
END
go

create procedure PiESTACCSUP_05I(
    @PARM_DATE_DEB datetime,             -- @p_BOOKING_D datetime
    @PARM_DATE_FIN datetime,             -- @p_ENDDATE_D datetime endconso_d pour ecriture conso et pstomgen_d pour sociale
    @p_NORM      varchar(4),
    @p_SPEENTNAT_CT varchar(10),	         -- 005
    @p_BALSHEYEA_NF smallint,        -- [007]
    @p_BALSHTMTH_NF tinyint          -- [007]   
) 





        
with execute as caller as
/***************************************************
Programme:               PiESTACCSUP_05I
Fichier script associ� : BEST_PiESTACCSUP_05I.prc
Domaine :               (ES) Estimation
Base principale :       BEST
Version:                1
Auteur:                 MZM
Date de creation:       03/02/2021
Description du programme:       
- s�lection des �critures de services post omega IFRS17

Parametres:
    - type ecritures I17 : 9, 10, 11
    - date cloture omega
    - date cloture people pour ecritures sociale ou fermeture conso pour ecritures conso

Conditions d'execution:
Commentaires:

-- BORNE DATE_DEB ===> PARM_BOOKING_D..........: -- INV IFRS17     : ${PARM_BOOKING_D} "              
-- BORNE DATE_DEB ===> PARM_BOOKING_D..........: -- POS IFRS17     : ${PARM_BOOKING_D} "              
-- BORNE DATE_DEB===>  PARM_PSTOMGEND17_D......: -- POC IFRS17     : ${PARM_PSTOMGEND17_D} "      
--                                                                                                    
-- BORNE DATE_FIN ===> PARM_BOOKINGNEXT_D......: -- INV IFRS17     : ${PARM_BOOKINGNEXT_D} "      
-- BORNE DATE_FIN ===> PARM_PSTOMGEND17_D......: -- POS IFRS17     : ${PARM_PSTOMGEND17_D} "      
-- BORNE DATE_FIN ===> PARM_PSTOMGCONEND17_D...: -- POC IFRS17     : ${PARM_PSTOMGCONEND17_D} "

_________________
MODIFICATIONS
001 03/03/2021 MZM       :spira:92592 Extraction des AE I17 :   V4 ; Ajout Param VNORM pour Dissocier EBS et I17
002 16/03/2021 MZM       :spira:92592 Extraction des AE I17 :   V4 ; Ne pas prendre les SPEENTTYP_CF 8, 9 (life) 
003 28/04/2021 MZM       :spira:90073 Extraction des AE I17 :   V5 ; TRNSCODIFICATIN DES Suffices des TRNCOD selon la Norme :G --> (�I�, �J�) ;  P --> ('K', 'L') ;  L --> ('M', 'N') 
004 17/08/2021 MZM       :spira:95950 Parametrage des bornes dates d'extraction  dans ESFD0062 en fonction du closing
005 14/12/2021 HR        :spira:99667 SPENTNAT added as parameter
006 01/04/2022 BRIK      :spira:101701 Update for CNV_PREPROD >> extract EBS AE on I17G closing
								- Business inserts AE EBS with EBS SPEENTNAT_CT 
								- Run a script behind to change the SPEENTNAT_CT to 10
[007] 19/04/2022 R. Cassis :spira:103840 Add Val Balance sheet Year and Month condition when extracting AEs and fix conditions 
[008] 24/11/2025 M. NAJI  :US 7605	User Story	SERQS - AE retro SERQS to be extracted by assumed site closing
****************************************************/
declare @erreur     int,
        @tran_imbr	bit,
        @usr char(4) 
          
select @usr=suser_name()


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



select @erreur      = 0
select @tran_imbr   = 1
-- ------------------------------
-- D�but de la transaction
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
  -- @PARM_DATE_FIN +  1day and 5h
  select @PARM_DATE_FIN=dateadd(hh,29,@PARM_DATE_FIN)
end else
begin
  -- @PARM_DATE_FIN +  1day
  select @PARM_DATE_FIN=dateadd(hh,24,@PARM_DATE_FIN)
end

-- --------------------------------
-- Descente de la table en fichiers
-- --------------------------------

select b.SSD_CF SSD_TRT,c.SSD_CF SSD_FAC,
       a.SSD_CF,
       a.ESB_CF,
       a.BALSHEY_NF,
       a.BALSHRMTH_NF,
       a.BALSHRDAY_NF,
--       TRNCOD_CF = case When (@p_NORM = 'I17G') THEN concat(substring(TRNCOD_CF,1,7), 'I')   
--                        when (@p_NORM = 'I17L') THEN concat(substring(TRNCOD_CF,1,7), 'M')   
--                        when (@p_NORM = 'I17P') THEN concat(substring(TRNCOD_CF,1,7), 'K')   
--                      else TRNCOD_CF end,
	   a.TRNCOD_CF,
       a.DBLTRNCOD_CF,
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
       a.RETRTY_NF,     --[001]
       a.RETUW_NT,
       a.RETOCCYEA_NF,
       a.RETACY_NF,
       a.RETSCOSTRMTH_NF,
       a.RETSCOENDMTH_NF,
       a.RCL_NF,
       a.RETCUR_CF,
       a.RETAMT_M,
       a.PLC_NT,
       a.RTO_NF,
       a.INT_NF,
       a.RETPAY_NF,
       a.RETKEY_CF,
       a.RETAUTGEN_B,
       a.ACCTYP_NF,
       a.TRN_NT,        --[001]
       ORICOD_LS=case When (SPEENTNAT_CT in (9,10,11) AND SPEENTTYP_CF is null OR SPEENTTYP_CF not in (8,9) ) THEN "IFRS17" else "EBS" end 
      ,RETROAUTO_B=case when ACCTYP_NF=0 then 1 else null end 
      ,a.SPEENTNAT_CT
      ,a.EVT_NF
      ,a.REVT_NF
      ,a.ACCTRN_NT
into #TACCSUP_035
from BEST..TACCSUP a                 --[001] 005
LEFT OUTER JOIN  btrt..tcontr b  on  a.ctr_nf = b.ctr_nf
              and   a.uw_nt  = b.uw_nt
              and   a.end_nt = b.end_nt
              and   a.uwy_nf = b.uwy_nf
              
LEFT OUTER JOIN bfac..tcontr c on a.ctr_nf = c.ctr_nf
              and   a.uw_nt  = c.uw_nt 
              and   a.end_nt = c.end_nt
              and   a.uwy_nf = c.uwy_nf
where  (
			a.SPEENTNAT_CT in (SELECT SPEENTNAT_CT FROM #TSPEENTNAT )
			AND 
				( substring(@p_NORM,1,3) = 'I17' 
					AND (   (substring(@p_NORM,4,4) = 'G' AND substring(a.TRNCOD_CF,8,8) IN ('I', 'J') )
							OR 
							(substring(@p_NORM,4,4) = 'P' AND substring(a.TRNCOD_CF,8,8) IN ('K', 'L') )
							OR 
							(substring(@p_NORM,4,4) = 'L' AND substring(a.TRNCOD_CF,8,8) IN ('M', 'N')) 
							-- 006 PrePROD change
							OR 
							(substring(@p_NORM,4,4) = 'G' AND a.TRNCOD_CF like ('_[AEJ]%') )
						)  
				) AND 
			(SPEENTTYP_CF is null OR SPEENTTYP_CF not in (8,9) ) 
		)
--  and CRE_D >= @PARM_DATE_DEB          --[001]
--  and CRE_D <  @PARM_DATE_FIN -- MODIF 5
and a.CRE_D > @PARM_DATE_DEB  -- [007]
and a.CRE_D <=  @PARM_DATE_FIN  -- [007]
and a.valpery_nf = @p_BALSHEYEA_NF  --[007]
and a.valpermth_nf = @p_BALSHTMTH_NF  --[007]
and a.ACCTYP_NF in (0,3,5)
and  ( ( b.ctr_nf != null and b.CTRLCK_B != 1 ) or ( c.ctr_nf != null and c.CTRLCK_B != 0 )) 


select a.SSD_CF,
       a.ESB_CF,
       a.BALSHEY_NF,
       a.BALSHRMTH_NF,
       a.BALSHRDAY_NF,
--       TRNCOD_CF = case When (@p_NORM = 'I17G') THEN concat(substring(TRNCOD_CF,1,7), 'I')   
--                        when (@p_NORM = 'I17L') THEN concat(substring(TRNCOD_CF,1,7), 'M')   
--                        when (@p_NORM = 'I17P') THEN concat(substring(TRNCOD_CF,1,7), 'K')   
--                      else TRNCOD_CF end,
	   a.TRNCOD_CF,
       a.DBLTRNCOD_CF,
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
       a.RETRTY_NF,     --[001]
       a.RETUW_NT,
       a.RETOCCYEA_NF,
       a.RETACY_NF,
       a.RETSCOSTRMTH_NF,
       a.RETSCOENDMTH_NF,
       a.RCL_NF,
       a.RETCUR_CF,
       a.RETAMT_M,
       a.PLC_NT,
       a.RTO_NF,
       a.INT_NF,
       a.RETPAY_NF,
       a.RETKEY_CF,
       a.RETAUTGEN_B,
       a.ACCTYP_NF,
       a.TRN_NT,        --[001]
       ORICOD_LS=case When (SPEENTNAT_CT in (9,10,11) AND SPEENTTYP_CF is null OR SPEENTTYP_CF not in (8,9) ) THEN "IFRS17" else "EBS" end 
      ,RETROAUTO_B=case when ACCTYP_NF=0 then 1 else null end 
      ,a.SPEENTNAT_CT
      ,a.EVT_NF
      ,a.REVT_NF
      ,a.ACCTRN_NT
into #TACCSUP_NOT_035
from BEST..TACCSUP a                 --[001] 005
JOIN BREF..TBATCHSSD s on a.SSD_CF=s.SSD_CF and s.BATCHUSER_CF= @usr 
LEFT OUTER JOIN  btrt..tcontr b  on  a.ctr_nf = b.ctr_nf
                  and   a.uw_nt  = b.uw_nt
                  and   a.end_nt = b.end_nt
                  and   a.uwy_nf = b.uwy_nf
                  --and   b.CTRLCK_B != 1 
LEFT OUTER JOIN bfac..tcontr c on a.ctr_nf = c.ctr_nf
                  and   a.uw_nt  = c.uw_nt 
                  and   a.end_nt = c.end_nt
                  and   a.uwy_nf = c.uwy_nf
                  --and   c.CTRLCK_B != 0 

where  (
			a.SPEENTNAT_CT in (SELECT SPEENTNAT_CT FROM #TSPEENTNAT )
			AND 
				( substring(@p_NORM,1,3) = 'I17' 
					AND (   (substring(@p_NORM,4,4) = 'G' AND substring(a.TRNCOD_CF,8,8) IN ('I', 'J') )
							OR 
							(substring(@p_NORM,4,4) = 'P' AND substring(a.TRNCOD_CF,8,8) IN ('K', 'L') )
							OR 
							(substring(@p_NORM,4,4) = 'L' AND substring(a.TRNCOD_CF,8,8) IN ('M', 'N')) 
							-- 006 PrePROD change
							OR 
							(substring(@p_NORM,4,4) = 'G' AND a.TRNCOD_CF like ('_[AEJ]%') )
						)  
				) AND 
			(SPEENTTYP_CF is null OR SPEENTTYP_CF not in (8,9) ) 
		)
--  and CRE_D >= @PARM_DATE_DEB          --[001]
--  and CRE_D <  @PARM_DATE_FIN -- MODIF 5
and a.CRE_D > @PARM_DATE_DEB  -- [007]
and a.CRE_D <=  @PARM_DATE_FIN  -- [007]
and a.valpery_nf = @p_BALSHEYEA_NF  --[007]
and a.valpermth_nf = @p_BALSHTMTH_NF  --[007]
and a.ACCTYP_NF not in (0,3,5)
and  ( a.ctr_nf = null  or ( b.ctr_nf != null and b.CTRLCK_B != 1 ) or ( c.ctr_nf != null and c.CTRLCK_B != 0 )) 

-- ************************************************************
-- -- ------------------------------
-- -- D�but de la transaction
-- ---------------------------------------------------------------
-- if @@trancount = 0
-- begin
--     select @tran_imbr = 0
--     BEGIN TRAN
-- end

select * 
from #TACCSUP_not_035
union 
select a.SSD_CF,
       a.ESB_CF,
       a.BALSHEY_NF,
       a.BALSHRMTH_NF,
       a.BALSHRDAY_NF,
--       TRNCOD_CF = case When (@p_NORM = 'I17G') THEN concat(substring(TRNCOD_CF,1,7), 'I')   
--                        when (@p_NORM = 'I17L') THEN concat(substring(TRNCOD_CF,1,7), 'M')   
--                        when (@p_NORM = 'I17P') THEN concat(substring(TRNCOD_CF,1,7), 'K')   
--                      else TRNCOD_CF end,
	   a.TRNCOD_CF,
       a.DBLTRNCOD_CF,
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
       a.RETRTY_NF,     --[001]
       a.RETUW_NT,
       a.RETOCCYEA_NF,
       a.RETACY_NF,
       a.RETSCOSTRMTH_NF,
       a.RETSCOENDMTH_NF,
       a.RCL_NF,
       a.RETCUR_CF,
       a.RETAMT_M,
       a.PLC_NT,
       a.RTO_NF,
       a.INT_NF,
       a.RETPAY_NF,
       a.RETKEY_CF,
       a.RETAUTGEN_B,
       a.ACCTYP_NF,
       a.TRN_NT,        --[001]
       a.ORICOD_LS
      ,a.RETROAUTO_B
      ,a.SPEENTNAT_CT
      ,a.EVT_NF
      ,a.REVT_NF
      ,a.ACCTRN_NT
from #TACCSUP_035 a
JOIN BREF..TBATCHSSD s on( SSD_TRT =s.SSD_CF  or  SSD_FAC =s.SSD_CF ) and s.BATCHUSER_CF= @usr 

-- ------------------------------------------------------------
-- Fin de la transaction
-- ------------------------------------------------------------
-- if @tran_imbr = 0
--     COMMIT TRAN

return 0

-- fin:
-- if @tran_imbr = 0
--     ROLLBACK TRAN

-- return 1
go
EXEC sp_procxmode 'dbo.PiESTACCSUP_05I', 'unchained'
go
IF OBJECT_ID('dbo.PiESTACCSUP_05I') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiESTACCSUP_05I >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiESTACCSUP_05I >>>'
go
GRANT EXECUTE ON dbo.PiESTACCSUP_05I TO GOMEGA
go
GRANT EXECUTE ON dbo.PiESTACCSUP_05I TO GDBBATCH
go
