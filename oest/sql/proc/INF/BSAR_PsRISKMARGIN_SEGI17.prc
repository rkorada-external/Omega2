USE BSAR
go
IF OBJECT_ID('dbo.PsRISKMARGIN_SEGI17') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsRISKMARGIN_SEGI17
  IF OBJECT_ID('dbo.PsRISKMARGIN_SEGI17') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsRISKMARGIN_SEGI17 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsRISKMARGIN_SEGI17 >>>'
END
go
create procedure dbo.PsRISKMARGIN_SEGI17
(
 @p_CLODAT_D datetime,
	@p_PER_CF   char(3),
	@p_clo_date char(8),
	@p_x_days int,
	@norme_cf char(4),
	@p_quarter_end varchar(10), --quarter end for dry run,
	@p_is_transition varchar(3) = 'NO' --transition mode
)
as
/***************************************************
Domaine : Estimations
Base principale : BSAR
Auteur: Arnaud RUFFAULT
Date de creation: 08/06/2021
Description du programme: Cree a partir de la procedure PsRISKMARGIN_SEGI17 utilise dans IFRS4
Conditions d'execution: 
Commentaires: les type de segmentation utilisés sont: 114 LOB SII, 1244 Legal Entity SII
_________________
MODIFICATIONS
[001] ART spira 97478 IFRS17 DryRun- Recognition date test for pericase
[002] ART spira 100168 IFRS17 inception pericase- Extract Run-off if transition mode
[003] ART spira 999999 IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
[004] Suraj P    22/11/2022  :spira :106239 Pericase INI does not include contract recognized on cut off date
*
*****************************************************/

-------------------------
-- Recognition date - X days OR Dry run date retrieval [001]
-------------------------
DECLARE
@v_pos_booking_minus_days datetime

IF(@p_quarter_end = 'NONE')
BEGIN
	DECLARE
	@v_year_clo_date int,
	@v_month_clo_date int,
	@v_pos_booking_d datetime
	
	SELECT @v_year_clo_date = CONVERT(int, substring(@p_clo_date, 1, 4))
	SELECT @v_month_clo_date = CONVERT(int, substring(@p_clo_date, 5, 2))
	SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date --[003]
	SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * -1, @v_pos_booking_d)
END
ELSE 
BEGIN
	SELECT @v_pos_booking_minus_days = convert(datetime, @p_quarter_end, 103)
END


declare
 @LOBSGT_NT          int           --LOB SII 
,@LOBSGTVER_NT       varchar(10)
,@LOBSGTRESTABNME_LL varchar(64)
,@LESGT_NT           int           --Legal Entity 
,@LESGTVER_NT        varchar(10)
,@LESGTRESTABNME_LL  varchar(64)
,@SQL_REF            varchar(3000)


-- CREATION OF TEMPORARY TABLES
CREATE TABLE #TMP_RISKMARGIN_SEGI17
(
    CTR_NF 	    UCTR_NF not null,
    END_NT 	    UEND_NT not null,
    SEC_NF 	        USEC_NF not null,
    UWY_NF 	    UUWY_NF not null,
    UW_NT 	        UUW_NT not null,
    LESGTVER_NT	    int null,
    SSD_CF	USSD_CF null,
    LESGMT_LS 	        UL16 null,
    LOBSGMT_LS	    UL16 null,
    CLODAT_D 	    datetime null,
    PER_CF 	    varchar(3) null,
    CRE_D 	    datetime null
)    

select @LOBSGT_NT=1285, @LESGT_NT=1244

SELECT @LOBSGTVER_NT=convert(varchar(10),SGTVER_NT), @LOBSGTRESTABNME_LL=SGTRESTABNME_LL
 from BSEG..TSEGRUN                                                                                          -- fini
  where SGTRUN_NT=(select max(SGTRUN_NT) from BSEG..TSEGRUN where SGT_NT=@LOBSGT_NT and SGTRUNSTS_CT='5' and SGTEVAL_B=1 and SGTSIMU_B=0)
print 'LOB SII=%1! @LOBSGTVER_NT=%2!, @LOBSGTRESTABNME_LL=%3!',@LOBSGT_NT,@LOBSGTVER_NT,@LOBSGTRESTABNME_LL

SELECT @LESGTVER_NT=convert(varchar(10),SGTVER_NT), @LESGTRESTABNME_LL=SGTRESTABNME_LL
 from BSEG..TSEGRUN                                                                                          -- fini
  where SGTRUN_NT=(select max(SGTRUN_NT) from BSEG..TSEGRUN where SGT_NT=@LESGT_NT and SGTRUNSTS_CT='5' and SGTEVAL_B=1 and SGTSIMU_B=0)
print 'LEGAL ENTITY SII=%1! @LESGTVER_NT=%2!, @LESGTRESTABNME_LL=%3!',@LESGT_NT,@LESGTVER_NT,@LESGTRESTABNME_LL

if @LESGTRESTABNME_LL=null or @LOBSGTRESTABNME_LL=null
begin
  raiserror 20009, "Tables de segmentation pas trouvée" 
  return 20045
end
--insertion for fac at inception in #TMP_RISKMARGIN_SEGI17
select @SQL_REF="
INSERT INTO #TMP_RISKMARGIN_SEGI17
select distinct s.CTR_NF
 ,p.END_NT
 ,s.SEC_NF
 ,s.UWY_NF
 ,s.UW_NT
 ,LESGTVER_NT="+@LESGTVER_NT+"
 ,p.SSD_CF
 ,LESGMT_LS=(select SGMT_LS from BEST..TSEGMT b where s.SGMT_NF=b.SGMT_NF and b.SGTVER_NT="+@LESGTVER_NT+" and b.SGT_NT=1244)
-- ,LESGMT_NF=s.SGMT_NF
 ,LOBSGMT_LS=(select SGMT_LS from BEST..TSEGMT c where v.SGMT_NF=c.SGMT_NF and c.SGTVER_NT="+@LOBSGTVER_NT+" and c.SGT_NT=1285)
-- ,LOBSGMT_NF=v.SGMT_NF
 ,CLODAT_D=@p_CLODAT_D
 ,PER_CF=@p_PER_CF
 ,CRE_D=getdate()
 from "+@LESGTRESTABNME_LL+" s, BMIS..TSECTION p, BMIS..TCONTR c, "+@LOBSGTRESTABNME_LL+" v, BFAC..TSECIFRS SECIFRS
-- LEGAL ENTITY SII et LOB SII
  where s.SSD_CF=v.SSD_CF
    and s.CTR_NF=v.CTR_NF
    and s.SEC_NF=v.SEC_NF
    and s.UW_NT=v.UW_NT
    and s.UWY_NF=v.UWY_NF
-- LEGAL ENTITY SII et TSECTION
    and s.SGMT_NF > 0
    and s.SSD_CF=p.SSD_CF
    and s.CTR_NF=p.CTR_NF
    and s.SEC_NF=p.SEC_NF
    and s.UW_NT=p.UW_NT
    and s.UWY_NF=p.UWY_NF
-- LOB SII et TSECTION
    and v.SGMT_NF > 0
      and v.SSD_CF=p.SSD_CF
    and v.CTR_NF=p.CTR_NF
    and v.SEC_NF=p.SEC_NF
    and v.UW_NT=p.UW_NT
    and v.UWY_NF=p.UWY_NF
-- TSECTION et TCONTR
    and c.CTR_NF=p.CTR_NF
    and c.UWY_NF=p.UWY_NF
    and c.UW_NT=p.UW_NT
    and c.END_NT=p.END_NT
    and c.SSD_CF=p.SSD_CF
    and c.SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
    and p.LOB_CF not in('30','31')
-- TSECTION et TSECIFRS
    and p.CTR_NF = SECIFRS.CTR_NF
				and p.END_NT = SECIFRS.END_NT
				and p.SEC_NF = SECIFRS.SEC_NF
				and p.UWY_NF = SECIFRS.UWY_NF
				and p.UW_NT = SECIFRS.UW_NT			
				and SECIFRS.RECOD_D < @v_pos_booking_minus_days 		--MODIF[004]
				and((@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT  IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)))
	        or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT  IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9)))
		       or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT  IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9)))
    )
				
--    and (   (c.CTRTYP_CT=1 and p.LOB_CF not in('30','31') and p.SECSTS_CT IN(14,16,17,19,23) and c.CTRSTS_CT IN(14,16,17,19,23))
--         or (c.CTRTYP_CT=2 and p.SECSTS_CT IN(16,18,19) and c.CTRSTS_CT IN(16,18,19)) -- p.LSTEND_B=1 ??
--        ) -- 1 TRT / 2 Facs
--    and p.SECACCSTS_CT!=9
"
print 'LOB SII=%1! @LOBSGTVER_NT=%2!, @LOBSGTRESTABNME_LL=%3!',@LOBSGT_NT,@LOBSGTVER_NT,@LOBSGTRESTABNME_LL
EXECUTE (@SQL_REF)

--insertion for trt at inception in #TMP_RISKMARGIN_SEGI17
select @SQL_REF="
INSERT INTO #TMP_RISKMARGIN_SEGI17
select distinct s.CTR_NF
 ,p.END_NT
 ,s.SEC_NF
 ,s.UWY_NF
 ,s.UW_NT
 ,LESGTVER_NT="+@LESGTVER_NT+"
 ,p.SSD_CF
 ,LESGMT_LS=(select SGMT_LS from BEST..TSEGMT b where s.SGMT_NF=b.SGMT_NF and b.SGTVER_NT="+@LESGTVER_NT+" and b.SGT_NT=1244)
-- ,LESGMT_NF=s.SGMT_NF
 ,LOBSGMT_LS=(select SGMT_LS from BEST..TSEGMT c where v.SGMT_NF=c.SGMT_NF and c.SGTVER_NT="+@LOBSGTVER_NT+" and c.SGT_NT=1285)
-- ,LOBSGMT_NF=v.SGMT_NF
 ,CLODAT_D=@p_CLODAT_D
 ,PER_CF=@p_PER_CF
 ,CRE_D=getdate()
 from "+@LESGTRESTABNME_LL+" s, BMIS..TSECTION p, BMIS..TCONTR c, "+@LOBSGTRESTABNME_LL+" v, BTRT..TSECIFRS SECIFRS
-- LEGAL ENTITY SII et LOB SII
  where s.SSD_CF=v.SSD_CF
    and s.CTR_NF=v.CTR_NF
    and s.SEC_NF=v.SEC_NF
    and s.UW_NT=v.UW_NT
    and s.UWY_NF=v.UWY_NF
-- LEGAL ENTITY SII et TSECTION
    and s.SGMT_NF > 0
    and s.SSD_CF=p.SSD_CF
    and s.CTR_NF=p.CTR_NF
    and s.SEC_NF=p.SEC_NF
    and s.UW_NT=p.UW_NT
    and s.UWY_NF=p.UWY_NF
-- LOB SII et TSECTION
    and v.SGMT_NF > 0
      and v.SSD_CF=p.SSD_CF
    and v.CTR_NF=p.CTR_NF
    and v.SEC_NF=p.SEC_NF
    and v.UW_NT=p.UW_NT
    and v.UWY_NF=p.UWY_NF
-- TSECTION et TCONTR
    and c.CTR_NF=p.CTR_NF
    and c.UWY_NF=p.UWY_NF
    and c.UW_NT=p.UW_NT
    and c.END_NT=p.END_NT
    and c.SSD_CF=p.SSD_CF
    and c.SSD_CF in(select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF=suser_name())
    and p.LOB_CF not in('30','31')
-- TSECTION et TSECIFRS
    and p.CTR_NF = SECIFRS.CTR_NF
				and p.END_NT = SECIFRS.END_NT
				and p.SEC_NF = SECIFRS.SEC_NF
				and p.UWY_NF = SECIFRS.UWY_NF
				and p.UW_NT = SECIFRS.UW_NT			
				and SECIFRS.RECOD_D < @v_pos_booking_minus_days 			--MODIF[004]
				and((@norme_cf = 'I17G' and ( SECIFRS.GRPINISTS_CT  IS NULL OR SECIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.GRPINISTS_CT = 9)))
	        or (@norme_cf = 'I17P' and ( SECIFRS.PARINISTS_CT  IS NULL OR SECIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.PARINISTS_CT = 9)))
		       or (@norme_cf = 'I17L' and ( SECIFRS.LOCINISTS_CT  IS NULL OR SECIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and SECIFRS.LOCINISTS_CT = 9)))
    )
				
--    and (   (c.CTRTYP_CT=1 and p.LOB_CF not in('30','31') and p.SECSTS_CT IN(14,16,17,19,23) and c.CTRSTS_CT IN(14,16,17,19,23))
--         or (c.CTRTYP_CT=2 and p.SECSTS_CT IN(16,18,19) and c.CTRSTS_CT IN(16,18,19)) -- p.LSTEND_B=1 ??
--        ) -- 1 TRT / 2 Facs
--    and p.SECACCSTS_CT!=9
"
print 'LOB SII=%1! @LOBSGTVER_NT=%2!, @LOBSGTRESTABNME_LL=%3!',@LOBSGT_NT,@LOBSGTVER_NT,@LOBSGTRESTABNME_LL
EXECUTE (@SQL_REF)

BEGIN
  SELECT * FROM #TMP_RISKMARGIN_SEGI17
END
if @@error!=0 select @SQL_REF
go
IF OBJECT_ID('dbo.PsRISKMARGIN_SEGI17') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsRISKMARGIN_SEGI17 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsRISKMARGIN_SEGI17 >>>'
go
GRANT EXECUTE ON dbo.PsRISKMARGIN_SEGI17 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsRISKMARGIN_SEGI17 TO GDBBATCH
go
