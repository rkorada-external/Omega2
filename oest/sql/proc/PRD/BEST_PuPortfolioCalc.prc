use BEST
go
if object_id('PuPortfolioCalc') is not null
begin
  drop PROC PuPortfolioCalc
  print '<<< DROPPED PROC PuPortfolioCalc >>>'
end
go

create procedure PuPortfolioCalc
(
	@p_sgttyp_nt int,
	@p_erreur varchar(64)=null output
)
with execute as caller as

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : KBagwe
Date de creation        : 13/03/2019
Description du programme: Fetching portfolio/sub portfolio details
Conditions d'execution  : ESEJ2061
Commentaires            :
_________________
MODIFICATIONS
MOD01 18/02/2021 - BKARRI - 92406 : I17: Management of Portoflio/subportfolio for Assumed involved in IO - Copy
MOD02 05/04/2021 - BKARRI - 93006 : I17: Assumed Local - Management of Portfolio / Subportfolio
*****************************************************/

declare @err int, @rowcnt int, @labl char(40)
declare @temp char(4), @curdate char(10)



--GROUP
IF (@p_sgttyp_nt = 64)
BEGIN

	UPDATE BTRAV..ESEJ2060_TRESULT
	SET PARSGMT_NF = B.PARSGMT_CF,
		GRPIFRSSEG1_CT=SGMT_LS,
		GRPIFRSSEG1_LL = SGMT_LL			
	FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT
			AND A.CLISSD_CF = 0		--MOD01
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT when CLISSD_CF = 0'
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT when CLISSD_CF = 0"
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2060_TRESULT when CLISSD_CF = 0 : %1!' , @rowcnt
	
	--MOD01[start]
	UPDATE BTRAV..ESEJ2060_TRESULT
	SET PARSGMT_NF = B.PARSGMT_CF,
		GRPIFRSSEG1_CT=CTR_NF,
		GRPIFRSSEG1_LL = CTR_NF			
	FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT
			AND A.CLISSD_CF <> 0

	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT when CLISSD_CF <> 0'
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT when CLISSD_CF <> 0"
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2060_TRESULT when CLISSD_CF <> 0 : %1!' , @rowcnt
	--MOD01[end]

	UPDATE BTRAV..ESEJ2060_TRESULT
	SET GRPIFRSSEG_CT=SGMT_LS,
		GRPIFRSSEG_LL = SGMT_LL
	FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.PARSGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT 
 
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2060_TRESULT'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2060_TRESULT"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2060_TRESULT : %1!' , @rowcnt

END


--PARENT
IF (@p_sgttyp_nt = 65)
BEGIN

	UPDATE BTRAV..ESEJ2060_TRESULT
	SET PARSGMT_NF = B.PARSGMT_CF,
		PARIFRSSEG1_CT=SGMT_LS,
		PARIFRSSEG1_LL = SGMT_LL
	FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT
			AND A.CLISSD_CF = 0		--MOD01
			
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT when CLISSD_CF = 0'
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT when CLISSD_CF = 0"
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2060_TRESULT when CLISSD_CF = 0 : %1!' , @rowcnt

	--MOD01[SATRT]
	UPDATE BTRAV..ESEJ2060_TRESULT
	SET PARSGMT_NF = B.PARSGMT_CF,
		PARIFRSSEG1_CT=CTR_NF,
		PARIFRSSEG1_LL = CTR_NF
	FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT
			AND A.CLISSD_CF <> 0

	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT when CLISSD_CF <> 0'
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT when CLISSD_CF <> 0"
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2060_TRESULT when CLISSD_CF <> 0 : %1!' , @rowcnt
	
	--MOD01[END]

	UPDATE BTRAV..ESEJ2060_TRESULT
	SET PARIFRSSEG_CT=SGMT_LS,
		PARIFRSSEG_LL = SGMT_LL		
	FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.PARSGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT 

	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2060_TRESULT'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2060_TRESULT"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2060_TRESULT : %1!' , @rowcnt

END


--LOCAL
IF (@p_sgttyp_nt = 66)
BEGIN

	UPDATE BTRAV..ESEJ2060_TRESULT
	SET PARSGMT_NF =B.PARSGMT_CF,
 		LOCIFRSSEG1_CT=SGMT_LS,
		LOCIFRSSEG1_LL = SGMT_LL		
	FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT
			
			
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT'
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2060_TRESULT"
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2060_TRESULT : %1!' , @rowcnt

	UPDATE BTRAV..ESEJ2060_TRESULT
	SET LOCIFRSSEG_CT=SGMT_LS,
		LOCIFRSSEG_LL = SGMT_LL
	FROM BTRAV..ESEJ2060_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'T' AND 	A.PARSGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT 

	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2060_TRESUL'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2060_TRESULT"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2060_TRESULT : %1!' , @rowcnt
	
END


return 0

go

if object_id('PuPortfolioCalc') is not null
  print '<<< CREATED PROC PuPortfolioCalc >>>'
else
  print '<<< FAILED CREATING PROC PuPortfolioCalc >>>'
go
grant execute on PuPortfolioCalc TO GOMEGA
go
grant execute on PuPortfolioCalc TO GDBBATCH
go
