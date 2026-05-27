USE BEST
go
IF OBJECT_ID('dbo.PuULR_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuULR_01
    IF OBJECT_ID('dbo.PuULR_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuULR_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuULR_01 >>>'
END
go
create procedure dbo.PuULR_01 (
  @p_cre_d      datetime,
  @p_typeinv_cf char(3),
  @p_batch_user char(25)
  )
as
/***************************************************
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     C.SOCIE
Description du programme: 
    - This Store procedure will be inserting in the table BEST..TSEGEST line which are already present in it following some criteria
Parametres:     - @p_cre_d : la date de traitement
                - @p_typeinv_cf : type inventaire
				- @p_batch_user 
_________________
MODIFICATIONS
[1] FCI 2023/2024 spira#91951 EST - ULR copy
*****************************************************/
declare
 @erreur int
,@tran_imbr  bit
,@lignes int
,@pos_exist int

declare @errno    int
declare @errmsg   varchar(255)

select @erreur=0, @tran_imbr=1


-- Version maximale pour chaque SSD (ctx INV) 
create table #PuULR_01_mxVers_INV(
	SSD_CF 	USSD_CF
	,VRS_NF		numeric(10,0)
)

-- Version maximale pour chaque SSD (ctx INV)
create table #PuULR_01_mxVers_POS(
	SSD_CF 	USSD_CF
	,VRS_NF		numeric(10,0) 
)

-- Table temporaire mirroir avant insertion TSEGEST
create table #PuULR_01_tmp(
	VRS_NF		numeric(10,0) 
	,SSD_CF 	USSD_CF       
	,SEGTYP_CT	USEGTYP_CT	  
	,SEG_NF		USEG_NF
	,UWY_NF		UUWY_NF
	,CRE_D		UUPD_D
	,CUR_CF		UCUR_CF
	,PRMAMT_M	UAMT_M NULL
	,CLMAMT_M	UAMT_M NULL
	,LOSRAT_R	USHORAT_R NULL
	,AMORAT_CT	char(1)
	,ACY_NF		UUWY_NF
	)

if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end


------------------------------------------
-- Cloture de type INV
------------------------------------------
if @p_typeinv_cf='INV'
begin
	
	INSERT into #PuULR_01_mxVers_INV
	SELECT v.SSD_CF, MAX(VRS_NF) AS VRS_NF
    FROM BEST..TVERSION v, BREF..TBATCHSSD bs
    WHERE VRSSTS_CT = 'CO' AND SEGTYP_CT in ('A','V') 
    AND v.SSD_CF = bs.SSD_CF AND bs.BATCHUSER_CF = @p_batch_user
    GROUP BY v.SSD_CF ORDER BY VRS_NF DESC
	
	select @erreur=@@error, @lignes=@@rowcount
	  if @erreur != 0 
	  begin
			select @errno  = 20010
			select @errmsg = 'Erreur INSERT into PuULR_01_mxVers_INV'
			goto ERREUR
	  end
	  print 'insert into Temp Table PuULR_01_mxVers_INV  lignes %1!',@lignes

 -- copy elements from TSEGEST into PuULR_01_tmp
 -- matching VRS_NF/SSD_CF from PuULR_01_mxVers_INV + SEGTYP_CT in A,V
 INSERT into #PuULR_01_tmp
  SELECT a.VRS_NF, a.SSD_CF, a.SEGTYP_CT, a.SEG_NF, a.UWY_NF, a.CRE_D, a.CUR_CF, a.PRMAMT_M, a.CLMAMT_M, a.LOSRAT_R, a.AMORAT_CT, a.ACY_NF 
  FROM BEST..TSEGEST a, #PuULR_01_mxVers_INV b
	WHERE a.VRS_NF = b.VRS_NF
	AND a.SSD_CF = b.SSD_CF
	AND a.SEGTYP_CT in ('A','V')
	
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur != 0 
  begin
        select @errno  = 20011
        select @errmsg = 'Erreur INSERT into PuULR_01_tmp [1]'
        goto ERREUR
  end
  print 'insert into Temp Table PuULR_01_tmp lignes %1!',@lignes
  
  UPDATE #PuULR_01_tmp
  SET SEGTYP_CT = 'T', CRE_D = @p_cre_d
  WHERE SEGTYP_CT = 'A'
  
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur != 0 
  begin
        select @errno  = 20012
        select @errmsg = 'Erreur UPDATE PuULR_01_tmp [1]'
        goto ERREUR
  end
  print 'UPDATE SEGTYP_CT from A to T on PuULR_01_tmp lignes %1!',@lignes
  
  UPDATE #PuULR_01_tmp
  SET SEGTYP_CT = 'W', CRE_D = @p_cre_d
  WHERE SEGTYP_CT = 'V'
  
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur != 0 
  begin
        select @errno  = 20013
        select @errmsg = 'Erreur UPDATE PuULR_01_tmp [2]'
        goto ERREUR
  end
  print 'UPDATE SEGTYP_CT from V to W on PuULR_01_tmp lignes %1!',@lignes
  
  -- insert NEW lines from PuULR_01_tmp into TSEGEST  with SEGTYP_CT = W or T
 INSERT into BEST..TSEGEST
  SELECT * from  #PuULR_01_tmp
	
	
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur != 0 
  begin
        select @errno  = 20014
        select @errmsg = 'Erreur INSERT into BEST..TSEGEST [1]'
        goto ERREUR
  end
  print 'insert into BEST..TSEGEST lignes %1!',@lignes

end
 

------------------------------------------
-- Cloture de type POS (Post Omega Social)
------------------------------------------
if @p_typeinv_cf='POS'
begin

	INSERT into #PuULR_01_mxVers_POS
	SELECT v.SSD_CF, MAX(VRS_NF) AS VRS_NF
    FROM BEST..TVERSION v, BREF..TBATCHSSD bs
    WHERE VRSSTS_CT = 'CO' AND SEGTYP_CT in ('T','W') 
    AND v.SSD_CF = bs.SSD_CF AND bs.BATCHUSER_CF = @p_batch_user
    GROUP BY v.SSD_CF ORDER BY VRS_NF DESC
	
	
	select @erreur=@@error, @lignes=@@rowcount
	  if @erreur != 0 
	  begin
			select @errno  = 20010
			select @errmsg = 'Erreur INSERT into PuULR_01_mxVers_POS'
			goto ERREUR
	  end
	  print 'insert into Temp Table PuULR_01_mxVers_POS  lignes %1!',@lignes
	  
 -- copy elements from TSEGEST into PuULR_01_tmp
 -- matching VRS_NF/SSD_CF from PuULR_01_mxVers_POS + SEGTYP_CT in T,W
 INSERT into #PuULR_01_tmp
  SELECT a.VRS_NF, a.SSD_CF, a.SEGTYP_CT, a.SEG_NF, a.UWY_NF, a.CRE_D, a.CUR_CF, a.PRMAMT_M, a.CLMAMT_M, a.LOSRAT_R, a.AMORAT_CT, a.ACY_NF 
  FROM BEST..TSEGEST a, #PuULR_01_mxVers_POS b
	WHERE a.VRS_NF = b.VRS_NF
	AND a.SSD_CF = b.SSD_CF
	AND a.SEGTYP_CT in ('T','W')
	
  select @erreur=@@error,@lignes=@@rowcount
  if @erreur != 0 
  begin
        select @errno  = 20015
        select @errmsg = 'Erreur INSERT into PuULR_01_tmp [2]'
        goto ERREUR
  end
  print 'insert into Temp Table PuULR_01_tmp lignes %1!',@lignes
  
   -- control = no new lines if VRS_NF/SSD_CF/'U' already exists
  set @pos_exist = (select count(*) from BEST..TSEGEST a, #PuULR_01_mxVers_POS b WHERE a.VRS_NF = b.VRS_NF AND a.SSD_CF = b.SSD_CF and SEGTYP_CT = 'U')
  UPDATE #PuULR_01_tmp
  SET SEGTYP_CT = 'U', CRE_D = @p_cre_d
  WHERE SEGTYP_CT = 'T' and @pos_exist = 0
  
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur != 0 
  begin
        select @errno  = 20016
        select @errmsg = 'Erreur UPDATE PuULR_01_tmp [3]'
        goto ERREUR
  end
  print 'UPDATE SEGTYP_CT from T to U on PuULR_01_tmp lignes %1!',@lignes
  
  -- control = no new lines if VRS_NF/SSD_CF/'X' already exists
  set @pos_exist = (select count(*) from BEST..TSEGEST a, #PuULR_01_mxVers_POS b WHERE a.VRS_NF = b.VRS_NF AND a.SSD_CF = b.SSD_CF and SEGTYP_CT = 'X')
  UPDATE #PuULR_01_tmp
  SET SEGTYP_CT = 'X', CRE_D = @p_cre_d
  WHERE SEGTYP_CT = 'W' and @pos_exist = 0
  
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur != 0 
  begin
        select @errno  = 20017
        select @errmsg = 'Erreur UPDATE PuULR_01_tmp [4]'
        goto ERREUR
  end
  print 'UPDATE SEGTYP_CT from W to X on PuULR_01_tmp lignes %1!',@lignes
  
  -- insert NEW lines from PuULR_01_tmp into TSEGEST with SEGTYP_CT = U or X
 INSERT into BEST..TSEGEST
  SELECT * from  #PuULR_01_tmp
	
	
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur != 0 
  begin
        select @errno  = 20018
        select @errmsg = 'Erreur INSERT into BEST..TSEGEST [2]'
        goto ERREUR
  end
  print 'insert into BEST..TSEGEST lignes %1!',@lignes


end

/* ----------------------------------------------------------------------
   suppression des tables temporaires #TREFCMT, #TREMINDER et #TREMINUSR
   ---------------------------------------------------------------------- */
   
if @tran_imbr=0 commit tran
return 0



ERREUR:
  raiserror @errno @errmsg
  rollback transaction
  return @erreur
go


EXEC sp_procxmode 'dbo.PuULR_01', 'unchained'
go

IF OBJECT_ID('dbo.PuULR_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuULR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuULR_01 >>>'
go

GRANT EXECUTE ON dbo.PuULR_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuULR_01 TO GDBBATCH
go
