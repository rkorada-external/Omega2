use BEST
go
if object_id('PtEGPIPFOLIO') is not null
begin
  drop PROC PtEGPIPFOLIO
  print '<<< DROPPED PROC PtEGPIPFOLIO >>>'
end
go

create procedure PtEGPIPFOLIO
(
	@p_sgttyp_nt int,
	@p_ctrtyp_ct char(1),
	@p_erreur varchar(64)=null output
)
with execute as caller as

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BTRT
Auteur                  : Charles SOCIE
Date de creation        : 08/10/2020
Description du programme: Feeding of main lob EGPI and portfolio
Conditions d'execution  : ESEJ2071
Commentaires            :
_________________
MODIFICATIONS
001 K Bhimasen	18/06/2021	:	Spira -96951 : PROD - ESEJ2070 crash on Asie
002 K Bhimasen	08/08/2022	:	Spira -105698: I17P- Issue with I17P segment label
*****************************************************/

declare @err int, @rowcnt int, @labl char(40)



IF (@p_sgttyp_nt = 64)
BEGIN

BEGIN TRAN

	/* ************ Treaty table insert/updates **************** */
	UPDATE BTRT..TCR
	SET GRPIFRSLOB_CF = B.GRPIFRSLOB_CF,
		GRPIFRSLOBEGP_R = B.GRPIFRSLOBEGP_R,
		GRPIFRSLOB_LL = B.GRPIFRSLOB_LL,
		LSTUPD_D = getdate(),
		LSTUPDUSR_CF =  suser_name()
	FROM  BTRAV..ESEJ2050_TSEGRUNRES B , BTRT..TCR C  
	WHERE B.CR_NF = C.CR_NF AND B.CRUWY_NF = C.CRUWY_NF AND B.CRUW_NT = C.CRUW_NT
	AND (isnull(C.GRPIFRSLOB_CF,"") <> isnull(B.GRPIFRSLOB_CF,"") OR isnull(C.GRPIFRSLOBEGP_R ,0) <> isnull(B.GRPIFRSLOBEGP_R,0) OR isnull(C.GRPIFRSLOB_LL ,"") <> isnull(B.GRPIFRSLOB_LL,""))
	AND SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'
	
    select @err = @@error, @rowcnt = @@rowcount	
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TCR"
	  return 1
	end
	print 'Update BTRT..TCR : %1!' , @rowcnt


	UPDATE BTRT..TSECIFRS
	SET  GRPIFRSSEG_CT = A.GRPIFRSSEG_CT, 
		 GRPIFRSSEG_LL = A.GRPIFRSSEG_LL,
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2050_TSEGRUNRES A, BTRT..TSECIFRS B, BTRT..TCR C 
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF 
	 	 AND A.CR_NF = C.CR_NF AND A.CRUWY_NF = C.CRUWY_NF AND A.CRUW_NT = C.CRUW_NT
		AND (isnull(B.GRPIFRSSEG_CT,"") <> isnull(A.GRPIFRSSEG_CT,"") OR isnull(B.GRPIFRSSEG_LL ,"") <> isnull(A.GRPIFRSSEG_LL,"") )
     	AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TSECIFRS"
	  return 1
	end	
	print 'Update BTRT..TSECIFRS : %1!' , @rowcnt

	INSERT INTO BTRT..TSECIFRS ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, PRISRC_CT, CTRPRI_B, PRILR_R , LSTUPD_D, LSTUPDUSR_CF ) 
    SELECT DISTINCT CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, '1',0,NULL,getdate(), suser_name()
	FROM BTRAV..ESEJ2050_TSEGRUNRES A
	WHERE NOT EXISTS ( SELECT 1 FROM BTRT..TSECIFRS B WHERE 
		 b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF ) AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

    select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN
	  raiserror 20020 "20020 : Error on Insert BTRT..TSECIFRS"
	  return 1
	end	
	print 'Insert BTRT..TSECIFRS : %1!' , @rowcnt
	
	UPDATE BTRT..TSECIFRS
	SET  GRPIFRSSEG_CT = A.GRPIFRSSEG_CT, 
		 GRPIFRSSEG_LL = A.GRPIFRSSEG_LL,
		 GRPIFRSSEG1_CT = A.GRPIFRSSEG1_CT, 
		 GRPIFRSSEG1_LL = A.GRPIFRSSEG1_LL,
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2060_TRESULT A, BTRT..TSECIFRS B 
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF 
 		 AND (isnull(B.GRPIFRSSEG_CT,"") <> isnull(A.GRPIFRSSEG_CT,"") OR isnull(B.GRPIFRSSEG_LL ,"") <> isnull(A.GRPIFRSSEG_LL,"") 
			OR	isnull(B.GRPIFRSSEG1_CT,"") <> isnull(A.GRPIFRSSEG1_CT,"") OR isnull(B.GRPIFRSSEG1_CT ,"") <> isnull(A.GRPIFRSSEG1_CT,"")	)
		 AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRT..TSECIFRS"
	  return 1
	end	
	print 'PORTFOLIO Update PBTRT..TSECIFRS : %1!' , @rowcnt

	/* ************ Treaty table insert/updates end**************** */



    /* ************ FAC table insert/updates**************** */
	
	
	UPDATE BFAC..TSECIFRS
	SET  GRPIFRSSEG_CT = A.GRPIFRSSEG_CT, 
		 GRPIFRSSEG_LL = A.GRPIFRSSEG_LL,
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	
	FROM BTRAV..ESEJ2050_TSEGRUNRES A, BFAC..TSECIFRS B, BFAC..TCR C 
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.UWY_NF = a.UWY_NF AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF 
	 	 AND A.CR_NF = C.CR_NF AND A.CRUWY_NF = C.CRUWY_NF AND A.CRUW_NT = C.CRUW_NT
		AND (isnull(B.GRPIFRSSEG_CT,"") <> isnull(A.GRPIFRSSEG_CT,"") OR isnull(B.GRPIFRSSEG_LL ,"") <> isnull(A.GRPIFRSSEG_LL,"") )
		AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'F'
			
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BFAC..TSECIFRS"
	  return 1
	end	
	print 'Update BFAC..TSECIFRS : %1!' , @rowcnt
	
	INSERT INTO BFAC..TSECIFRS ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF,DIV_NT, PRISRC_CT, CTRPRI_B, PRILR_R , LSTUPD_D, LSTUPDUSR_CF ) 
    SELECT DISTINCT CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF,DIV_NT, '1',0,NULL,getdate(), suser_name()
	from BTRAV..ESEJ2050_TSEGRUNRES A
	WHERE NOT EXISTS ( SELECT 1 From BFAC..TSECIFRS B where 
	 b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.UWY_NF = a.UWY_NF AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF)
	  AND EXISTS ( SELECT 1 From BFAC..TCONTR C where 
	 c.CTR_NF = a.CTR_NF AND c.UWY_NF = a.UWY_NF AND c.UW_NT = a.UW_NT AND c.END_NT = a.END_NT )		-- mod 001
	  AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'F'

    select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN 	
	  raiserror 20020 "20020 : Error on Insert BFAC..TSECIFRS"
	  return 1
	end	
	print 'Insert BFAC..TSECIFRS : %1!' , @rowcnt


	/* ************ FAC table insert/updates end**************** */

COMMIT TRAN
print "commit done GROUP"

END



IF (@p_sgttyp_nt = 65) 	--Parent
BEGIN

BEGIN TRAN

	/* ************ Treaty table insert/updates **************** */
	UPDATE BTRT..TCR
	SET PARIFRSLOB_CF = B.PARIFRSLOB_CF,
		PARIFRSLOBEGP_R = B.PARIFRSLOBEGP_R,
		PARIFRSLOB_LL = B.PARIFRSLOB_LL,
		LSTUPD_D = getdate(),
		LSTUPDUSR_CF =  suser_name()
	FROM  BTRAV..ESEJ2050_TSEGRUNRES B , BTRT..TCR C  
	WHERE B.CR_NF = C.CR_NF AND B.CRUWY_NF = C.CRUWY_NF AND B.CRUW_NT = C.CRUW_NT
	AND (isnull(C.PARIFRSLOB_CF,"") <> isnull(B.PARIFRSLOB_CF,"") OR isnull(C.PARIFRSLOBEGP_R ,0) <> isnull(B.PARIFRSLOBEGP_R,0) OR isnull(C.PARIFRSLOB_LL ,"") <> isnull(B.PARIFRSLOB_LL,"") )
	AND SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'
	
		
    select @err = @@error, @rowcnt = @@rowcount	
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TCR"
	  return 1
	end
	print 'Update BTRT..TCR : %1!' , @rowcnt

	UPDATE BTRT..TSECIFRS
	SET  PARIFRSSEG_CT = A.PARIFRSSEG_CT, 
		 PARIFRSSEG_LL = A.PARIFRSSEG_LL,
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2050_TSEGRUNRES A, BTRT..TSECIFRS B, BTRT..TCR C 
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF 
	 	 AND A.CR_NF = C.CR_NF AND A.CRUWY_NF = C.CRUWY_NF AND A.CRUW_NT = C.CRUW_NT
		 AND (isnull(B.PARIFRSSEG_CT,"") <> isnull(A.PARIFRSSEG_CT,"") OR isnull(B.PARIFRSSEG_LL ,"") <> isnull(A.PARIFRSSEG_LL,"") )
		 AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TSECIFRS"
	  return 1
	end	
	print 'Update BTRT..TSECIFRS : %1!' , @rowcnt
	
	INSERT INTO BTRT..TSECIFRS ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, PRISRC_CT, CTRPRI_B, PRILR_R , LSTUPD_D, LSTUPDUSR_CF ) 
    SELECT DISTINCT CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, '1',0,NULL,getdate(), suser_name()
	FROM BTRAV..ESEJ2050_TSEGRUNRES A
	WHERE NOT EXISTS ( SELECT 1 FROM BTRT..TSECIFRS B WHERE 
		 b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF ) AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

    select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN
	  raiserror 20020 "20020 : Error on Insert BTRT..TSECIFRS"
	  return 1
	end	
	print 'Insert BTRT..TSECIFRS : %1!' , @rowcnt

   UPDATE BTRT..TSECIFRS
	SET  PARIFRSSEG_CT = A.PARIFRSSEG_CT, 
		 PARIFRSSEG_LL = A.PARIFRSSEG_LL,
		 PARIFRSSEG1_CT = A.PARIFRSSEG1_CT, 
		 PARIFRSSEG1_LL = A.PARIFRSSEG1_LL,
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2060_TRESULT A, BTRT..TSECIFRS B 
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF 
 		 AND (isnull(B.PARIFRSSEG_CT,"") <> isnull(A.PARIFRSSEG_CT,"") OR isnull(B.PARIFRSSEG_LL ,"") <> isnull(A.PARIFRSSEG_LL,"") 
			OR	isnull(B.PARIFRSSEG1_CT,"") <> isnull(A.PARIFRSSEG1_CT,"") OR isnull(B.PARIFRSSEG1_LL ,"") <> isnull(A.PARIFRSSEG1_LL,"")	)
		 AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRT..TSECIFRS"
	  return 1
	end	
	print 'PORTFOLIO Update PBTRT..TSECIFRS : %1!' , @rowcnt

	
	/* ************ Treaty table insert/updates end**************** */
	
	
	/* ************ FAC table insert/updates**************** */
	
	UPDATE BFAC..TSECIFRS
	SET  PARIFRSSEG_CT = A.PARIFRSSEG_CT, 
		 PARIFRSSEG_LL = A.PARIFRSSEG_LL,					-- MOD002
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2050_TSEGRUNRES A, BFAC..TSECIFRS B,  BFAC..TCR C
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.UWY_NF = a.UWY_NF AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF  
	  AND A.CR_NF = C.CR_NF AND A.CRUWY_NF = C.CRUWY_NF AND A.CRUW_NT = C.CRUW_NT
 	  AND (isnull(B.PARIFRSSEG_CT,"") <> isnull(A.PARIFRSSEG_CT,"") OR isnull(B.PARIFRSSEG_LL ,"") <> isnull(A.PARIFRSSEG_LL,"") )
	  AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'F'
		
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BFAC..TSECIFRS"
	  return 1
	end	
	print 'Update BFAC..TSECIFRS : %1!' , @rowcnt
	
	INSERT INTO BFAC..TSECIFRS ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF,DIV_NT, PRISRC_CT, CTRPRI_B, PRILR_R , LSTUPD_D, LSTUPDUSR_CF ) 
    SELECT DISTINCT CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF,DIV_NT, '1',0,NULL,getdate(), suser_name()
	from BTRAV..ESEJ2050_TSEGRUNRES A
	WHERE NOT EXISTS ( SELECT 1 From BFAC..TSECIFRS B where 
	 b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF)
	  AND EXISTS ( SELECT 1 From BFAC..TCONTR C where 
	 c.CTR_NF = a.CTR_NF AND c.UWY_NF = a.UWY_NF AND c.UW_NT = a.UW_NT AND c.END_NT = a.END_NT )	--mod 001
	  AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'F'

 
    select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN 	
	  raiserror 20020 "20020 : Error on Insert BFAC..TSECIFRS"
	  return 1
	end	
	print 'Insert BFAC..TSECIFRS : %1!' , @rowcnt



	/* ************ FAC table insert/updates end**************** */


COMMIT TRAN
print "commit done PARENT"

END



IF (@p_sgttyp_nt = 66)	--LOCAL
BEGIN

BEGIN TRAN

	/* ************ Treaty table insert/updates **************** */
	UPDATE BTRT..TCR
	SET LOCIFRSLOB_CF = B.LOCIFRSLOB_CF,
		LOCIFRSLOBEGP_R = B.LOCIFRSLOBEGP_R,
		LOCIFRSLOB_LL = B.LOCIFRSLOB_LL,
		LSTUPD_D = getdate(),
		LSTUPDUSR_CF =  suser_name()
	FROM  BTRAV..ESEJ2050_TSEGRUNRES B , BTRT..TCR C  
	WHERE B.CR_NF = C.CR_NF AND B.CRUWY_NF = C.CRUWY_NF AND B.CRUW_NT = C.CRUW_NT
	AND (isnull(C.LOCIFRSLOB_CF,"") <> isnull(B.LOCIFRSLOB_CF,"") OR isnull(C.LOCIFRSLOBEGP_R ,0) <> isnull(B.LOCIFRSLOBEGP_R,0) OR isnull(C.LOCIFRSLOB_LL ,"") <> isnull(B.LOCIFRSLOB_LL,"") )
	AND SGTTYP_NT = @p_sgttyp_nt AND B.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'
	
		
    select @err = @@error, @rowcnt = @@rowcount	
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TCR"
	  return 1
	end
	print 'Update BTRT..TCR : %1!' , @rowcnt

	UPDATE BTRT..TSECIFRS
	SET  LOCIFRSSEG_CT = A.LOCIFRSSEG_CT, 
		 LOCIFRSSEG_LL = A.LOCIFRSSEG_LL,
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2050_TSEGRUNRES A, BTRT..TSECIFRS B, BTRT..TCR C 
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF 
	 	 AND A.CR_NF = C.CR_NF AND A.CRUWY_NF = C.CRUWY_NF AND A.CRUW_NT = C.CRUW_NT
		 AND (isnull(B.LOCIFRSSEG_CT,"") <> isnull(A.LOCIFRSSEG_CT,"") OR isnull(B.LOCIFRSSEG_LL ,"") <> isnull(A.LOCIFRSSEG_LL,"") )
		 AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BTRT..TSECIFRS"
	  return 1
	end	
	print 'Update BTRT..TSECIFRS : %1!' , @rowcnt
	
	INSERT INTO BTRT..TSECIFRS ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, PRISRC_CT, CTRPRI_B, PRILR_R , LSTUPD_D, LSTUPDUSR_CF ) 
    SELECT DISTINCT CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, '1',0,NULL,getdate(), suser_name()
	FROM BTRAV..ESEJ2050_TSEGRUNRES  A
	WHERE NOT EXISTS ( SELECT 1 FROM BTRT..TSECIFRS B WHERE 
		 b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF ) AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

    select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN
	  raiserror 20020 "20020 : Error on Insert BTRT..TSECIFRS"
	  return 1
	end	
	print 'Insert BTRT..TSECIFRS : %1!' , @rowcnt



	UPDATE BTRT..TSECIFRS
	SET  LOCIFRSSEG_CT = A.LOCIFRSSEG_CT, 
		 LOCIFRSSEG_LL = A.LOCIFRSSEG_LL,
		 LOCIFRSSEG1_CT = A.LOCIFRSSEG1_CT, 
		 LOCIFRSSEG1_LL = A.LOCIFRSSEG1_LL,
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2060_TRESULT A, BTRT..TSECIFRS B 
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  
		 AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF 
 		 AND (isnull(B.LOCIFRSSEG_CT,"") <> isnull(A.LOCIFRSSEG_CT,"") OR isnull(B.LOCIFRSSEG_LL ,"") <> isnull(A.LOCIFRSSEG_LL,"") 
			OR	isnull(B.LOCIFRSSEG1_CT,"") <> isnull(A.LOCIFRSSEG1_CT,"") OR isnull(B.LOCIFRSSEG1_LL ,"") <> isnull(A.LOCIFRSSEG1_LL,"")	)
		 AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'T'

	
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update PORTFOLIO BTRT..TSECIFRS"
	  return 1
	end	
	print 'PORTFOLIO Update PBTRT..TSECIFRS : %1!' , @rowcnt
	
	/* ************ Treaty table insert/updates end**************** */
	
	
	/* ************ FAC table insert/updates**************** */
	
	UPDATE BFAC..TSECIFRS
	SET  LOCIFRSSEG_CT = A.LOCIFRSSEG_CT, 
		 LOCIFRSSEG_LL = A.LOCIFRSSEG_LL,
		 LSTUPD_D = getdate(),
		 LSTUPDUSR_CF =  suser_name()
	FROM BTRAV..ESEJ2050_TSEGRUNRES A, BFAC..TSECIFRS B,  BFAC..TCR C
	WHERE b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.UWY_NF = a.UWY_NF AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF  
	  AND A.CR_NF = C.CR_NF AND A.CRUWY_NF = C.CRUWY_NF AND A.CRUW_NT = C.CRUW_NT
 	  AND (isnull(B.LOCIFRSSEG_CT,"") <> isnull(A.LOCIFRSSEG_CT,"") OR isnull(B.LOCIFRSSEG_LL ,"") <> isnull(A.LOCIFRSSEG_LL,"") )
	  AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'F'
		
	select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN	
	  raiserror 20020 "20020 : Error on Update BFAC..TSECIFRS"
	  return 1
	end	
	print 'Update BFAC..TSECIFRS : %1!' , @rowcnt
	
	INSERT INTO BFAC..TSECIFRS ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF,DIV_NT, PRISRC_CT, CTRPRI_B, PRILR_R , LSTUPD_D, LSTUPDUSR_CF ) 
    SELECT DISTINCT CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF,DIV_NT, '1',0,NULL,getdate(), suser_name()
	from BTRAV..ESEJ2050_TSEGRUNRES A
	WHERE NOT EXISTS ( SELECT 1 From BFAC..TSECIFRS B where 
	 b.CTR_NF = a.CTR_NF AND b.UWY_NF = a.UWY_NF AND b.UW_NT = a.UW_NT  AND b.UWY_NF = a.UWY_NF AND b.END_NT = a.END_NT 
	  AND b.DIV_NT = a.DIV_NT AND b.END_NT = a.END_NT AND b.SEC_NF = a.SEC_NF)
	  AND EXISTS ( SELECT 1 From BFAC..TCONTR C where 
	 c.CTR_NF = a.CTR_NF AND c.UWY_NF = a.UWY_NF AND c.UW_NT = a.UW_NT AND c.END_NT = a.END_NT )		--mod 001
	  AND SGTTYP_NT = @p_sgttyp_nt AND A.CTRTYP_CT = @p_ctrtyp_ct AND @p_ctrtyp_ct = 'F'
 
    select @err = @@error, @rowcnt = @@rowcount		
	if @err != 0
	begin
	  rollback TRAN 	
	  raiserror 20020 "20020 : Error on Insert BFAC..TSECIFRS"
	  return 1
	end	
	print 'Insert BFAC..TSECIFRS : %1!' , @rowcnt



	/* ************ FAC table insert/updates end**************** */



COMMIT TRAN
print "commit done LOCAL"

END


return 0

go

if object_id('PtEGPIPFOLIO') is not null
  print '<<< CREATED PROC PtEGPIPFOLIO >>>'
else
  print '<<< FAILED CREATING PROC PtEGPIPFOLIO >>>'
go
grant execute on PtEGPIPFOLIO TO GOMEGA
go
grant execute on PtEGPIPFOLIO TO GDBBATCH
go
