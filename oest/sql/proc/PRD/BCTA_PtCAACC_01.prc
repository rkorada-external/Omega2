USE BCTA
go
IF OBJECT_ID('PtCAACC_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PtCAACC_01
    IF OBJECT_ID('PtCAACC_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PtCAACC_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PtCAACC_01 >>>'
END
go

/*
* creation de la procedure
*/

CREATE PROCEDURE PtCAACC_01(
        @p_ssd_cf       USSD_CF,
		@p_esb_cf       UESB_CF,	
        @p_usr_cf       UUSR_CF,
		@p_numfic   int,
		@p_balsht_d datetime,
		@p_erreur     varchar(250) = NULL output		
)

with execute as caller as
       
  /***************************************************

Programme: BEST_PtCAACC_01.prc

Domaine : TAC

Base principale : BCTA
Version: 1
Auteur: KBagwe
Date de creation: 15/04/2019

Description du programme:
Complete account : Spira#70043
 
MODIFICATION 
_______________________________________________________________________________________________________________  
*****************************************************************************************************************************************************/

DECLARE @erreur      int,
        @tran_imbr   bit,
	    @currentdate datetime,
		@V_NBANO_NT      int,
        @V_NBLGKO_NT     int,
		@V_NBLGTOT_NT   int
	 

     
select @erreur = 0

select @currentdate = getdate()


IF EXISTS(SELECT COUNT(1) FROM  BTRAV..CPTD0912_WORKFILE where NUMFIC_NT = @p_numfic AND ERR_B = 1 AND GSSD_CF=@p_ssd_cf and GESB_CF=@p_esb_cf and USR_CF=@p_usr_cf)
BEGIN
    SELECT @p_erreur  = "ANAMOLY EXISTS IN BTRAV..CPTD0912_WORKFILE"
	print "ANAMOLY EXISTS IN BTRAV..CPTD0912_WORKFILE"
	select @erreur = @@error
    if @erreur != 0  goto fin

END



CREATE TABLE #WORKFILE
(
    CTR_NF       		UCTR_NF       NULL,
    SEC_NF       		USEC_NF       NULL,
    ACY_NF       		smallint      NULL,
    SCOENDMTH_NF 		tinyint       NULL,
	SCOSTRMTH_NF        tinyint       NULL,
    SSD_CF        	USSD_CF        NULL,
    ESB_CF        	UESB_CF        NULL,
    CTRTYP_CT   char(1)   NULL,  -- A assume, R retro
    BALSHT_D   datetime  NULL,  
    BALSHT_Y   int  NULL,  
    BALSHT_M   int  NULL,  
    MAXQUAT_NF int NULL,
    NUMLIGNE_NT   	int           NULL, 
	CED_NF	int null,
	ANNUAL_NF bit default 0
)


create TABLE #SCOSTRMTH(
    SCOENDMTH_NF 		tinyint       NULL,
	SCOSTRMTH_NF        tinyint       NULL
)

SELECT @V_NBLGTOT_NT = (SELECT COUNT(1) FROM  BTRAV..CPTD0912_WORKFILE where NUMFIC_NT = @p_numfic AND ERR_B = 0 AND GSSD_CF=@p_ssd_cf and GESB_CF=@p_esb_cf and USR_CF=@p_usr_cf)

select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

insert into #SCOSTRMTH VALUES (3, 1)
insert into #SCOSTRMTH VALUES (6, 4)
insert into #SCOSTRMTH VALUES (9, 7)
insert into #SCOSTRMTH VALUES (12, 10)



INSERT INTO #WORKFILE (CTR_NF, SEC_NF, ACY_NF, SCOENDMTH_NF, NUMLIGNE_NT,BALSHT_D,BALSHT_Y, BALSHT_M)
SELECT CTR_NF, SEC_NF,  ACY_NF, SCOENDMTH_NF, NUMLIGNE_NT, BALSHT_D, year(BALSHT_D), month(BALSHT_D) 
FROM BTRAV..CPTD0912_WORKFILE WHERE NUMFIC_NT = @p_numfic  AND ERR_B = 0 AND GSSD_CF=@p_ssd_cf and GESB_CF=@p_esb_cf and USR_CF=@p_usr_cf
order by CTR_NF, SEC_NF,  ACY_NF, SCOENDMTH_NF


UPDATE #WORKFILE
SET CTRTYP_CT = 'A',  SSD_CF =  A.SSD_CF, ESB_CF =  A.ACCESB_CF, CED_NF = A.CED_NF
FROM #WORKFILE B, BTRT..TCONTR A
where A.CTR_NF = B.CTR_NF


UPDATE #WORKFILE
SET CTRTYP_CT = 'R', SSD_CF =  A.SSD_CF, ESB_CF =  A.ESB_CF
FROM #WORKFILE B, BRET..TRETCTR A
where A.RETCTR_NF = B.CTR_NF



UPDATE #WORKFILE
SET MAXQUAT_NF = (SELECT max(SCOENDMTH_NF)  FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND A.ACY_NF = B.ACY_NF GROUP BY ctr_nf, acy_nf)
FROM #WORKFILE A
WHERE CTRTYP_CT = 'A'


UPDATE #WORKFILE
SET MAXQUAT_NF = (SELECT max(SCOENDMTH_NF)  FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND A.ACY_NF = B.ACY_NF AND A.SEC_NF = B.SEC_NF GROUP BY ctr_nf, sec_nf,  acy_nf)
FROM #WORKFILE A
WHERE CTRTYP_CT = 'R'


UPDATE #WORKFILE
SET SCOSTRMTH_NF = 1 ,ANNUAL_NF =1  -- Annual
FROM #WORKFILE A , #SCOSTRMTH B
WHERE A.SCOENDMTH_NF = B.SCOENDMTH_NF AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B=0 )  AND  CTRTYP_CT = 'A'


UPDATE #WORKFILE
SET SCOSTRMTH_NF = B.SCOSTRMTH_NF, ANNUAL_NF =0
FROM #WORKFILE A , #SCOSTRMTH B
WHERE A.SCOENDMTH_NF = B.SCOENDMTH_NF AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B=1 )  AND  CTRTYP_CT = 'A'


UPDATE #WORKFILE
SET SCOSTRMTH_NF = B.SCOSTRMTH_NF
FROM #WORKFILE A , #SCOSTRMTH B
WHERE A.SCOENDMTH_NF = B.SCOENDMTH_NF AND  CTRTYP_CT = 'R'
 



INSERT INTO BCTA..TCPLACC ( CTR_NF, SCOENDMTH_NF, SCOSTRMTH_NF, ACY_NF, SSD_CF, ESB_CF, BLCSHT_D, CED_NF, LSTUPD_D, LSTUPDUSR_CF, PRNSTS_B, RESPROPAG_B ) 
	SELECT CTR_NF, SCOENDMTH_NF, SCOSTRMTH_NF, ACY_NF, SSD_CF, ESB_CF, BALSHT_D, CED_NF, @currentdate, @p_usr_cf, 1, 0 

	FROM #WORKFILE A where CTRTYP_CT = 'A' and not exists (select 1 from BCTA..TCPLACC c where A.CTR_NF = C.CTR_NF and a.SCOSTRMTH_NF = c.SCOSTRMTH_NF 
    and a.SCOENDMTH_NF = c.SCOENDMTH_NF  and a.ACY_NF = c.ACY_NF and a.SSD_CF=c.SSD_CF AND  A.ESB_CF= C.ESB_CF)

SELECT @erreur = @@error, @p_erreur="ERR INSERT INTO BCTA..TCPLACC"
IF @erreur != 0  GOTO fin


        
INSERT INTO BEST..TLIFDRID ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, ACM_NF, SSD_CF, AUTUPD_B, COMACC_B, CMT_NT, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, RESPROPAG_B, SEGUPD_B ) 
SELECT A.CTR_NF, 0, B.SEC_NF, A.ACY_NF, 1, @currentdate, A.BALSHT_Y, A.BALSHT_M, A.ACY_NF, E.SCOENDMTH_NF, A.SSD_CF, 1, 1, 0, @p_usr_cf, @currentdate, @p_usr_cf, 0, 0

FROM #WORKFILE A, BTRT..TSECTION B,  #SCOSTRMTH E
where CTRTYP_CT = 'A'  AND A.CTR_NF = B.CTR_NF AND B.UWY_NF = A.ACY_NF AND ANNUAL_NF = 1 AND
NOT EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND C.END_NT= 0 AND B.SEC_NF = C.SEC_NF AND  C.UWY_NF = B.UWY_NF AND C.UW_NT = 1 AND  A.BALSHT_Y = C.BALSHEY_NF AND A.BALSHT_M = C.BALSHTMTH_NF AND 
			A.ACY_NF = C.ACY_NF AND A.SCOENDMTH_NF = C.ACM_NF )

        
INSERT INTO BEST..TLIFDRID ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, ACM_NF, SSD_CF, AUTUPD_B, COMACC_B, CMT_NT, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, RESPROPAG_B, SEGUPD_B ) 
SELECT A.CTR_NF, 0, B.SEC_NF, A.ACY_NF, 1, @currentdate, A.BALSHT_Y, A.BALSHT_M, A.ACY_NF, A.SCOENDMTH_NF, A.SSD_CF, 1, 1, 0, @p_usr_cf, @currentdate, @p_usr_cf, 0, 0

FROM #WORKFILE A, BTRT..TSECTION B 
where CTRTYP_CT = 'A'  AND A.CTR_NF = B.CTR_NF AND B.UWY_NF = A.ACY_NF AND ANNUAL_NF = 0 AND
NOT EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND C.END_NT= 0 AND B.SEC_NF = C.SEC_NF AND  C.UWY_NF = B.UWY_NF AND C.UW_NT = 1 AND  A.BALSHT_Y = C.BALSHEY_NF AND A.BALSHT_M = C.BALSHTMTH_NF AND 
			A.ACY_NF = C.ACY_NF AND A.SCOENDMTH_NF = C.ACM_NF )


SELECT @erreur = @@error, @p_erreur="ERR INSERT INTO BCTA..TLIFDRID for assume"
IF @erreur != 0  GOTO fin

            
INSERT INTO BEST..TLIFDRID ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, ACM_NF, SSD_CF, AUTUPD_B, COMACC_B, CMT_NT, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, RESPROPAG_B, SEGUPD_B ) 
SELECT A.CTR_NF, 0, A.SEC_NF, A.ACY_NF, 1, @currentdate, A.BALSHT_Y, A.BALSHT_M, A.ACY_NF, A.SCOENDMTH_NF, A.SSD_CF, 1, 0, 0, @p_usr_cf, @currentdate, @p_usr_cf, 0, 0

FROM #WORKFILE A
where CTRTYP_CT = 'R'  AND
NOT EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND C.END_NT= 0 AND A.SEC_NF = C.SEC_NF AND  C.UWY_NF = A.ACY_NF AND C.UW_NT = 1 AND  A.BALSHT_Y = C.BALSHEY_NF AND A.BALSHT_M = C.BALSHTMTH_NF AND 
			A.ACY_NF = C.ACY_NF AND A.SCOENDMTH_NF = C.ACM_NF) 

SELECT @erreur = @@error, @p_erreur="ERR INSERT INTO BCTA..TLIFDRID for retro"
IF @erreur != 0  GOTO fin


INSERT INTO BEST..TLIFDRI ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, SSD_CF, AUTUPD_B, COMACC_B, CMT_NT, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, RESPROPAG_B, SEGUPD_B ) 
SELECT DISTINCT A.CTR_NF, 0, B.SEC_NF, B.UWY_NF, 1, @currentdate, A.BALSHT_Y, A.BALSHT_M, A.ACY_NF, A.SSD_CF, 1, 0, 0,  @p_usr_cf, @currentdate, @p_usr_cf, 0, 0
FROM #WORKFILE A, BTRT..TSECTION B 
where CTRTYP_CT = 'A'  AND A.CTR_NF = B.CTR_NF AND B.UWY_NF = A.ACY_NF AND 
NOT EXISTS (SELECT 1 FROM BEST..TLIFDRI C WHERE  A.CTR_NF = C.CTR_NF AND C.END_NT= 0 AND B.SEC_NF = C.SEC_NF AND  C.UWY_NF = B.UWY_NF AND C.UW_NT = 1 AND  A.BALSHT_Y = C.BALSHEY_NF AND A.BALSHT_M = C.BALSHTMTH_NF AND 
			A.ACY_NF = C.ACY_NF)

SELECT @erreur = @@error, @p_erreur="ERR INSERT INTO BCTA..TLIFDRI for assume"
IF @erreur != 0  GOTO fin


INSERT INTO BEST..TLIFDRI ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, SSD_CF, AUTUPD_B, COMACC_B, CMT_NT, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, RESPROPAG_B, SEGUPD_B ) 
SELECT DISTINCT A.CTR_NF, 0, B.RETSEC_NF, B.RTY_NF, 1, @currentdate, A.BALSHT_Y, A.BALSHT_M, A.ACY_NF, A.SSD_CF, 0, 0, 0,  @p_usr_cf, @currentdate, @p_usr_cf, 0, 0
FROM #WORKFILE A,  BRET..TRETSEC B 
where CTRTYP_CT = 'R'  AND  A.CTR_NF = B.RETCTR_NF AND B.RTY_NF = A.ACY_NF AND
NOT EXISTS (SELECT 1 FROM BEST..TLIFDRI C WHERE  A.CTR_NF = C.CTR_NF AND C.END_NT= 0 AND B.RETSEC_NF = C.SEC_NF AND  C.UWY_NF = B.RTY_NF AND C.UW_NT = 1 AND  A.BALSHT_Y = C.BALSHEY_NF AND A.BALSHT_M = C.BALSHTMTH_NF AND 
			A.ACY_NF = C.ACY_NF)

SELECT @erreur = @@error, @p_erreur="ERR INSERT INTO BCTA..TLIFDRI for retro"
IF @erreur != 0  GOTO fin

--Assume
UPDATE BEST..TLIFDRI 
SET COMACC_B = 1
FROM BEST..TLIFDRI A, #WORKFILE B
WHERE A.CTR_NF = B.CTR_NF AND A.ACY_NF = B.ACY_NF  AND B.CTRTYP_CT = 'A' 
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = 3 and a.SEC_NF = c.SEC_NF)
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = 6 and a.SEC_NF = c.SEC_NF)
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = 9 and a.SEC_NF = c.SEC_NF)
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = 12 and a.SEC_NF = c.SEC_NF)

SELECT @erreur = @@error, @p_erreur="ERR Update INTO BCTA..TLIFDRI for assume"
IF @erreur != 0  GOTO fin


--Retro
UPDATE BEST..TLIFDRI 
SET  AUTUPD_B  = 1 
FROM BEST..TLIFDRI A, #WORKFILE B
WHERE A.CTR_NF = B.CTR_NF AND A.ACY_NF = B.ACY_NF  AND B.CTRTYP_CT = 'R'
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = 3 and a.SEC_NF = c.SEC_NF)
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = 6 and a.SEC_NF = c.SEC_NF)
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = 9 and a.SEC_NF = c.SEC_NF)
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = 12 and a.SEC_NF = c.SEC_NF)

SELECT @erreur = @@error, @p_erreur="ERR Update INTO BCTA..TLIFDRI for retro"
IF @erreur != 0  GOTO fin



/*
UPDATE BEST..TLIFDRID
SET COMACC_B = 1 
FROM BEST..TLIFDRID A, #WORKFILE B
WHERE A.CTR_NF = B.CTR_NF AND A.ACY_NF = B.ACY_NF 
AND EXISTS (SELECT 1 FROM BEST..TLIFDRI C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.BALSHTMTH_NF =B.BALSHT_M and a.SEC_NF = c.SEC_NF)
*/


UPDATE TSUIVINTACC
      SET FICSTS_CF  = 'OK'   ,
          INTEG_D      = @currentdate,
          LSTUPDUSR_CF = @p_usr_cf,
          LSTUPD_D     = @currentdate,
		  NBLGTOT_NT = @V_NBLGTOT_NT,
          NBLGKO_NT  = 0,
		  NBANO_NT = 0

WHERE NUMFIC_NT = @p_numfic  AND FICSTS_CF    in ('EC','EN') 
 
 SELECT @erreur = @@error, @p_erreur="ERR Update INTO TSUIVINTACC "
IF @erreur != 0  GOTO fin
 


 
IF @tran_imbr = 0
         commit TRAN  

/********************************************************************************/
/*                                                                              */
/*                  Fin normale de la proc                                      */
/*                                                                              */
/********************************************************************************/
SELECT 0
RETURN 0

fin:
select @p_erreur = 'Erreur PtCAACC_01 -: ' + @p_erreur 
PRINT @p_erreur

IF @tran_imbr = 0
         ROLLBACK TRAN 


select 1
return 1

 
go
EXEC sp_procxmode 'PtCAACC_01', 'unchained'
go
IF OBJECT_ID('PtCAACC_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PtCAACC_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PtCAACC_01 >>>'
go
GRANT EXECUTE ON PtCAACC_01 TO GOMEGA
go
GRANT EXECUTE ON PtCAACC_01 TO GDBBATCH
go