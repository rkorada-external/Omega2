USE BSAR
go
IF OBJECT_ID('dbo.PsRISKMARGIN_SEG') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsRISKMARGIN_SEG
  IF OBJECT_ID('dbo.PsRISKMARGIN_SEG') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsRISKMARGIN_SEG >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsRISKMARGIN_SEG >>>'
END
go
create procedure dbo.PsRISKMARGIN_SEG
(
 @p_CLODAT_D datetime
,@p_PER_CF   char(3)
)
as
/***************************************************
Domaine : Estimations
Base principale : BSAR
Auteur: Florent
Date de creation: 20/07/2015
Description du programme: :spot:
Conditions d'execution: 
Commentaires: les type de segmentation utilisés sont: 114 LOB SII, 1244 Legal Entity SII
_________________
MODIFICATIONS
1 Florent 27/11/2015 :spot:29778 on reprend la sélection via la BSEG avec Legal Entity 1244 et pour LOB SII 1285 
*****************************************************/
declare
 @LOBSGT_NT          int           --LOB SII 
,@LOBSGTVER_NT       varchar(10)
,@LOBSGTRESTABNME_LL varchar(64)
,@LESGT_NT           int           --Legal Entity 
,@LESGTVER_NT        varchar(10)
,@LESGTRESTABNME_LL  varchar(64)
,@SQL_REF            varchar(3000)

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
-- pas de gestion du balai
select @SQL_REF="
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
 from "+@LESGTRESTABNME_LL+" s, BMIS..TSECTION p, BMIS..TCONTR c, "+@LOBSGTRESTABNME_LL+" v
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
--    and (   (c.CTRTYP_CT=1 and p.LOB_CF not in('30','31') and p.SECSTS_CT IN(14,16,17,19,23) and c.CTRSTS_CT IN(14,16,17,19,23))
--         or (c.CTRTYP_CT=2 and p.SECSTS_CT IN(16,18,19) and c.CTRSTS_CT IN(16,18,19)) -- p.LSTEND_B=1 ??
--        ) -- 1 TRT / 2 Facs
--    and p.SECACCSTS_CT!=9
"

exec (@SQL_REF)
if @@error!=0 select @SQL_REF
go
IF OBJECT_ID('dbo.PsRISKMARGIN_SEG') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsRISKMARGIN_SEG >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsRISKMARGIN_SEG >>>'
go
GRANT EXECUTE ON dbo.PsRISKMARGIN_SEG TO GOMEGA
go
GRANT EXECUTE ON dbo.PsRISKMARGIN_SEG TO GDBBATCH
go
