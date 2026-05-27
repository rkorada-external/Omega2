use BEST
go
if object_id('PuRetPortfolioCalc') is not null
begin
  drop PROC PuRetPortfolioCalc
  print '<<< DROPPED PROC PuRetPortfolioCalc >>>'
end
go

create procedure PuRetPortfolioCalc
(
	@p_sgttyp_nt int,
	@p_erreur varchar(64)=null output
)
with execute as caller as

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : Bhimasen Karri
Date de creation        : 07/04/2021
Description du programme: Portfolio/Sub-Portfolio per norm to be stored on Life IFRS17 Retro subview.
Conditions d'execution  : ESEJ2091
Commentaires            :
_________________
MODIFICATIONS
MOD01 - 04/05/2021 - K Bhimasen - Spira#88570 - IFRS17: RETRO - Level of aggregation with Grouping of Internal Retro
MOD02 -	21/03/2022 - K Bhimasen - Spira#102714 - IFRS17 Retro Life Portfolio - New rules + Fix Parent & Local Norms
MOD03 -	06/07/2022 - Amit Bansal - Spira#105231 - IFRS17 Retro Life Portfolio - New rules + Fix Parent & Local Norms
MOD04 -	11/08/2022 - Amit Bansal - Spira#102712 - IFRS17 Retro Life Portfolio - Inception status at Pending and first closing date (Retro)
MOD05 - 03/03/2023 - K Bhimasen - Spira#108480 - IFRS17 - Omega Evolutions - Specific Segmentation for Local Korea and Parent Ireland Retro portfolio Sub-Portfolio
MOD06 - 06/03/2023 - K Bhimasen - Spira#107541 - IFRS 17 - Life - Retro - First closing date issue on specific calendar cases
MOD0  - 18/02/2026 - S.Behague - US7774 L&H- Retro portofolio review7
*****************************************************/

declare @err int, @rowcnt int, @labl char(40)
declare @temp char(4), @curdate char(10)

--MOD04 START
declare @site_cf char (4), 
 @suname char(4),
 @clo_D datetime 
 select @suname = suser_name()
 
Execute BEST..PsSITE_01 @suname,'0',@site_cf output

--MOD04 END

--GROUP
IF (@p_sgttyp_nt = 75)
BEGIN

BEGIN TRAN
	
	--Sub-Portfolio Code and Label for Internal & External
	
	--MOD04 START
	select @clo_D =  B.CLODAT_D FROM  BEST..TI17REQJOBPLAN B 	
	WHERE B.DBCLO_D = dateadd(day,0,convert(char(10), getdate(), 23))  and B.SITE_CF = @site_cf
	and norme_cf = 'I17G'
	--MOD04 END
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET PARSGMT_NF = B.PARSGMT_CF,
		GRPIFRSSEG1_CT=SGMT_LS,
		GRPIFRSSEG1_LL = SGMT_LL,
		GRPINISTS_CT = 1
	FROM BTRAV..ESEJ2090_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'R' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT AND ISNULL(GRPINISTS_CT,0) in (0,1)
		
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET GRPIFRSSEG1_CT = RETCTR_NF,
		GRPIFRSSEG1_LL = RETCTR_NF,
		GRPINISTS_CT = 1
	FROM BTRAV..ESEJ2090_TRESULT  
	WHERE  CTRTYP_CT = 'R' AND ISNULL(GRPINISTS_CT,0) in (0,1)
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	--MOD02[END]	

if @clo_D != null
begin
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET GRPFSTCLO_D = @clo_D	
	FROM BTRAV..ESEJ2090_TRESULT  
	WHERE  CTRTYP_CT = 'R' AND ISNULL(GRPINISTS_CT,0) in (0,1) 
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update GRPFSTCLO_D BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update GRPFSTCLO_D BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'GRPFSTCLO_D Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	
end
					
	-- Portfolio Code and Label for External Retro
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET GRPIFRSSEG_CT= A.RETCTR_NF,
		GRPIFRSSEG_LL = A.RETCTR_NF
	FROM BTRAV..ESEJ2090_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'R' AND 	A.PARSGMT_NF = B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT AND ISNULL(GRPINISTS_CT,0) in (0,1)
	 
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0: %1!' , @rowcnt
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET GRPIFRSSEG_CT= RETCTR_NF ,								--MOD02
		GRPIFRSSEG_LL = RETCTR_NF					--MOD02
	FROM BTRAV..ESEJ2090_TRESULT 
	WHERE CTRTYP_CT = 'R' AND ISNULL(GRPINISTS_CT,0) in (0,1) --AND CLISSD_CF = 0

	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0: %1!' , @rowcnt
	
	-- Portfolio Code and Label for Internal Retro
	--MOD01[START]
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET GRPIFRSSEG_CT= A.RETCTR_NF,							
		GRPIFRSSEG_LL = A.RETCTR_NF				
	FROM BTRAV..ESEJ2090_TRESULT A, BRET..TRETIFRS B, BEST..TSEGMT C 	
	WHERE A.RETCTR_NF = B.RETCTR_NF AND A.RTY_NF = B.RTY_NF AND A.CTRTYP_CT = 'R' AND ISNULL(A.GRPINISTS_CT,0) in (0,1) AND A.CLISSD_CF <> 0
	AND A.SGTTYP_NT = @p_sgttyp_nt AND 	A.PARSGMT_NF = C.SGMT_NF AND A.SGT_NT  = C.SGT_NT  AND  A.SGTVER_NT = C.SGTVER_NT 
	AND NOT EXISTS ( SELECT  1 FROM BTRAV..ESEJ2090_TRESULT C WHERE A.RETCTR_NF=C.RETCTR_NF AND 														--MOD02
					A.RTY_NF=C.RTY_NF AND CLISSD_CF = 0)																								--MOD02
 
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0: %1!' , @rowcnt
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET GRPIFRSSEG_CT= A.RETCTR_NF,							--MOD02
		GRPIFRSSEG_LL = A.RETCTR_NF			--MOD02
	FROM BTRAV..ESEJ2090_TRESULT A, BRET..TRETIFRS B 	--MOD02
	WHERE A.RETCTR_NF = B.RETCTR_NF AND A.RTY_NF = B.RTY_NF AND A.CTRTYP_CT = 'R' AND ISNULL(A.GRPINISTS_CT,0) in (0,1) AND A.CLISSD_CF <> 0			--MOD02
	AND NOT EXISTS ( SELECT  1 FROM BTRAV..ESEJ2090_TRESULT C WHERE A.RETCTR_NF=C.RETCTR_NF AND 														--MOD02
					A.RTY_NF=C.RTY_NF AND CLISSD_CF = 0)																								--MOD02
 
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0: %1!' , @rowcnt
	
	--MOD01[END]
	
COMMIT TRAN
print "commit done GROUP"

END

--PARENT
IF (@p_sgttyp_nt = 76)
BEGIN
BEGIN TRAN

	--Sub-Portfolio Code and Label for Internal & External
	--MOD04 START
	select @clo_D =  B.CLODAT_D FROM  BEST..TI17REQJOBPLAN B 	
	WHERE B.DBCLO_D = dateadd(day,0,convert(char(10), getdate(), 23))  and B.SITE_CF = @site_cf
	and norme_cf = 'I17P'
	--MOD04 END
		
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET PARSGMT_NF = B.PARSGMT_CF,
		PARIFRSSEG1_CT=SGMT_LS,
		PARIFRSSEG1_LL = SGMT_LL,
		PARINISTS_CT = 1
	FROM BTRAV..ESEJ2090_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'R' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT AND ISNULL(PARINISTS_CT,0) in (0,1)

	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET PARIFRSSEG1_CT = RETCTR_NF,
		PARIFRSSEG1_LL = RETCTR_NF,
		PARINISTS_CT = 1
	FROM BTRAV..ESEJ2090_TRESULT  
	WHERE CTRTYP_CT = 'R' AND ISNULL(PARINISTS_CT,0) in (0,1)	
		
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	--MOD02[END]
	
if @clo_D != null
begin
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET PARFSTCLO_D = @clo_D	
	FROM BTRAV..ESEJ2090_TRESULT  
	WHERE  CTRTYP_CT = 'R' AND ISNULL(PARINISTS_CT,0) in (0,1) 
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PARFSTCLO_D BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update PARFSTCLO_D BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'PARFSTCLO_D Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	
end
	
	-- Portfolio Code and Label for External Retro
		
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET PARIFRSSEG_CT= A.RETCTR_NF,
		PARIFRSSEG_LL = A.RETCTR_NF
	FROM BTRAV..ESEJ2090_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'R' AND 	A.PARSGMT_NF = B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT AND ISNULL(PARINISTS_CT,0) in (0,1)
 
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0: %1!' , @rowcnt
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET PARIFRSSEG_CT= RETCTR_NF ,							--MOD02
		PARIFRSSEG_LL = RETCTR_NF				--MOD02
	FROM BTRAV..ESEJ2090_TRESULT 
	WHERE CTRTYP_CT = 'R' AND ISNULL(PARINISTS_CT,0) in (0,1) --AND CLISSD_CF = 0

	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0: %1!' , @rowcnt
																								--MOD02
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0: %1!' , @rowcnt
	
	--MOD01[END]
	
COMMIT TRAN
print "commit done PARENT"

END


--LOCAL
IF (@p_sgttyp_nt = 77)
BEGIN
BEGIN TRAN
	
	--MOD02[START]
	--Sub-Portfolio Code and Label for Internal & External

	--MOD04 START
	select @clo_D =  B.CLODAT_D FROM  BEST..TI17REQJOBPLAN B 	
	WHERE B.DBCLO_D = dateadd(day,0,convert(char(10), getdate(), 23))  and B.SITE_CF = @site_cf
	and norme_cf = 'I17L'
	--MOD04 END
		
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET PARSGMT_NF = B.PARSGMT_CF,
		LOCIFRSSEG1_CT=SGMT_LS,
		LOCIFRSSEG1_LL = SGMT_LL,
		LOCINISTS_CT = 1	
	FROM BTRAV..ESEJ2090_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'R' AND 	A.SGMT_NF  =B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT AND ISNULL(LOCINISTS_CT,0) in (0,1)
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET LOCIFRSSEG1_CT = RETCTR_NF,
		LOCIFRSSEG1_LL = RETCTR_NF,
		LOCINISTS_CT = 1	
	FROM BTRAV..ESEJ2090_TRESULT 
	WHERE CTRTYP_CT = 'R' AND ISNULL(LOCINISTS_CT,0) in (0,1)	

	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update SUB PORTFOLIO BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'SUB PORTFOLIO Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	--MOD02[END]
	
if @clo_D != null
begin
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET LCLFSTCLO_D = @clo_D	
	FROM BTRAV..ESEJ2090_TRESULT  
	WHERE  CTRTYP_CT = 'R' AND ISNULL(LOCINISTS_CT,0) in (0,1) 
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update LCLFSTCLO_D BTRAV..ESEJ2090_TRESULT '
	  raiserror 20020 "20020 : Error on Update LCLFSTCLO_D BTRAV..ESEJ2090_TRESULT "
	  return 1
	end	
	print 'LCLFSTCLO_D Update BTRAV..ESEJ2090_TRESULT : %1!' , @rowcnt
	
end
	
	-- Portfolio Code and Label for External Retro
		
	UPDATE BTRAV..ESEJ2090_TRESULT
	SET LOCIFRSSEG_CT= A.RETCTR_NF,
		LOCIFRSSEG_LL = A.RETCTR_NF
	FROM BTRAV..ESEJ2090_TRESULT A, BEST..TSEGMT B 
	WHERE A.SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = 'R' AND 	A.PARSGMT_NF = B.SGMT_NF AND A.SGT_NT  = B.SGT_NT  AND  A.SGTVER_NT = B.SGTVER_NT AND ISNULL(LOCINISTS_CT,0) in (0,1)
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0: %1!' , @rowcnt

	UPDATE BTRAV..ESEJ2090_TRESULT
	SET LOCIFRSSEG_CT= RETCTR_NF ,							--MOD02
		LOCIFRSSEG_LL = RETCTR_NF				--MOD02
	FROM BTRAV..ESEJ2090_TRESULT
	WHERE CTRTYP_CT = 'R' AND ISNULL(LOCINISTS_CT,0) in (0,1) --AND CLISSD_CF = 0
 
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF = 0: %1!' , @rowcnt
	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  print '20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0'
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0"
	  return 1
	end	
	print 'PORTFOLIO Update BTRAV..ESEJ2090_TRESULT when CLISSD_CF <> 0: %1!' , @rowcnt
	
	--MOD01[END]

COMMIT TRAN 
print "commit done LOCAL"

END

return 0

go

if object_id('PuRetPortfolioCalc') is not null
  print '<<< CREATED PROC PuRetPortfolioCalc >>>'
else
  print '<<< FAILED CREATING PROC PuRetPortfolioCalc >>>'
go
grant execute on PuRetPortfolioCalc TO GOMEGA
go
grant execute on PuRetPortfolioCalc TO GDBBATCH
go