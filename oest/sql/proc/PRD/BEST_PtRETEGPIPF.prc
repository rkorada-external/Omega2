use BEST
go
if object_id('PtRETEGPIPF') is not null
begin
  drop PROC PtRETEGPIPF
  print '<<< DROPPED PROC PtRETEGPIPF >>>'
end
go

create procedure PtRETEGPIPF
(
	@p_sgttyp_nt int,
	@p_erreur varchar(64)=null output
)
with execute as caller as

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BRET
Auteur                  : Bhimasen Karri
Date de creation        : 09/04/2021
Description du programme: Feeding of portfolio Retro Level
Conditions d'execution  : ESEJ2071
Commentaires            :
_________________
MODIFICATIONS
MOD01 -	25/03/2022 - K Bhimasen - Spira#102714 - IFRS17 Retro Life Portfolio - New rules + Fix Parent & Local Norms
MOD02 20/09/2022 - Amit Bansal - Spira#102712 - IFRS17 Retro Life Portfolio - Inception status at Pending and first closing date (Retro)
*****************************************************/

declare @err int, @rowcnt int, @labl char(40)

IF (@p_sgttyp_nt = 75)	--group
BEGIN

	UPDATE BRET..TRETIFRS
	SET  GRPIFRSSEG_CT = A.GRPIFRSSEG_CT, 
		 GRPIFRSSEG_LL = A.GRPIFRSSEG_LL,
		 GRPIFRSSEG1_CT = A.GRPIFRSSEG1_CT, 
		 GRPIFRSSEG1_LL = A.GRPIFRSSEG1_LL,
		 GRPINISTS_CT = A.GRPINISTS_CT,  --MOD02
		 GRPFSTCLO_D = A.GRPFSTCLO_D,    --MOD02 
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2090_TRESULT A, BRET..TRETIFRS B 
	WHERE b.RETCTR_NF = a.RETCTR_NF AND b.RTY_NF = a.RTY_NF 
 		 AND (isnull(B.GRPIFRSSEG_CT,"") <> isnull(A.GRPIFRSSEG_CT,"") OR isnull(B.GRPIFRSSEG_LL ,"") <> isnull(A.GRPIFRSSEG_LL,"") 
			OR	isnull(B.GRPIFRSSEG1_CT,"") <> isnull(A.GRPIFRSSEG1_CT,"") OR isnull(B.GRPIFRSSEG1_CT ,"") <> isnull(A.GRPIFRSSEG1_CT,"") OR isnull(CONVERT( VARCHAR,B.GRPINISTS_CT),"") <> isnull(CONVERT( VARCHAR,A.GRPINISTS_CT),"") OR isnull(B.GRPFSTCLO_D,"") <> isnull(A.GRPFSTCLO_D,"") 	)
		  AND A.CTRTYP_CT = 'R' AND ISNULL(A.GRPINISTS_CT,0) in (0,1)		--MOD01
		 
		 select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BRET..TRETIFRSS"
	  return 1
	end	
	print 'PORTFOLIO Update PBRET..TRETIFRS : %1!' , @rowcnt
	
END

IF (@p_sgttyp_nt = 76)	--parent
BEGIN

	UPDATE BRET..TRETIFRS
	SET  PARIFRSSEG_CT = A.PARIFRSSEG_CT, 
		 PARIFRSSEG_LL = A.PARIFRSSEG_LL,
		 PARIFRSSEG1_CT = A.PARIFRSSEG1_CT, 
		 PARIFRSSEG1_LL = A.PARIFRSSEG1_LL,
		 PARINISTS_CT = A.PARINISTS_CT,  --MOD02
		 PARFSTCLO_D = A.PARFSTCLO_D,    --MOD02
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2090_TRESULT A, BRET..TRETIFRS B 
	WHERE b.RETCTR_NF = a.RETCTR_NF AND b.RTY_NF = a.RTY_NF 
 		 AND (isnull(B.PARIFRSSEG_CT,"") <> isnull(A.PARIFRSSEG_CT,"") OR isnull(B.PARIFRSSEG_LL ,"") <> isnull(A.PARIFRSSEG_LL,"") 
			OR	isnull(B.PARIFRSSEG1_CT,"") <> isnull(A.PARIFRSSEG1_CT,"") OR isnull(B.PARIFRSSEG1_LL ,"") <> isnull(A.PARIFRSSEG1_LL,"")  OR isnull(CONVERT( VARCHAR,B.PARINISTS_CT),"") <> isnull(CONVERT( VARCHAR,A.PARINISTS_CT),"") OR isnull(B.PARFSTCLO_D,"") <> isnull(A.PARFSTCLO_D,"")	)
		 AND A.CTRTYP_CT = 'R' AND ISNULL(A.PARINISTS_CT,0) in (0,1)		--MOD01

	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BRET..TRETIFRS"
	  return 1
	end	
	print 'PORTFOLIO Update PBRET..TRETIFRS : %1!' , @rowcnt
	
END

IF (@p_sgttyp_nt = 77)	--local
BEGIN

	UPDATE BRET..TRETIFRS
	SET  LOCIFRSSEG_CT = A.LOCIFRSSEG_CT, 
		 LOCIFRSSEG_LL = A.LOCIFRSSEG_LL,
		 LOCIFRSSEG1_CT = A.LOCIFRSSEG1_CT, 
		 LOCIFRSSEG1_LL = A.LOCIFRSSEG1_LL,
		 LOCINISTS_CT = A.LOCINISTS_CT,    --MOD02
		 LCLFSTCLO_D = A.LCLFSTCLO_D,      --MOD02 
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2090_TRESULT A, BRET..TRETIFRS B 
	WHERE b.RETCTR_NF = a.RETCTR_NF AND b.RTY_NF = a.RTY_NF 
 		 AND (isnull(B.LOCIFRSSEG_CT,"") <> isnull(A.LOCIFRSSEG_CT,"") OR isnull(B.LOCIFRSSEG_LL ,"") <> isnull(A.LOCIFRSSEG_LL,"") 
			OR	isnull(B.LOCIFRSSEG1_CT,"") <> isnull(A.LOCIFRSSEG1_CT,"") OR isnull(B.LOCIFRSSEG1_LL ,"") <> isnull(A.LOCIFRSSEG1_LL,"")	   OR isnull(CONVERT( VARCHAR,B.LOCINISTS_CT),"") <> isnull(CONVERT( VARCHAR,A.LOCINISTS_CT),"")
            OR isnull(B.LCLFSTCLO_D,"") <> isnull(A.LCLFSTCLO_D,"") )
		 AND A.CTRTYP_CT = 'R' AND ISNULL(A.LOCINISTS_CT,0) in (0,1)			--MOD01

	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BRET..TRETIFRS"
	  return 1
	end	
	print 'PORTFOLIO Update PBRET..TRETIFRS : %1!' , @rowcnt
	
END

return 0

go

if object_id('PtRETEGPIPF') is not null
  print '<<< CREATED PROC PtRETEGPIPF >>>'
else
  print '<<< FAILED CREATING PROC PtRETEGPIPF >>>'
go
grant execute on PtRETEGPIPF TO GOMEGA
go
grant execute on PtRETEGPIPF TO GDBBATCH
go