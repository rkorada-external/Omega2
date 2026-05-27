USE BCTA
go
IF OBJECT_ID('PiCACOHRCHK_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PiCACOHRCHK_01
    IF OBJECT_ID('PiCACOHRCHK_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PiCACOHRCHK_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PiCACOHRCHK_01 >>>'
END
go

/*
* creation de la procedure
*/

CREATE PROCEDURE PiCACOHRCHK_01(
        @p_ssd_cf       USSD_CF,
		@p_esb_cf       UESB_CF,	
        @p_usr_cf       UUSR_CF,
		@p_mess_n   int=0,					 
		@p_numfic   int,
		@p_balsht_d datetime,
		@p_erreur     varchar(250) = NULL output		
)

with execute as caller as
       
/***************************************************

Programme: BEST_PiCACOHRCHK_01.prc

Domaine : Estimation

Base principale : BCTA
Version: 1
Auteur: KBagwe
Date de creation: 15/04/2019

Description du programme:
Control of consistency for complete account
 
MODIFICATION 
________________________________________________________________________________________________  
MOD01 - 22/05/2019 - Spira#78395 : Apolo - REQ.L.02.04: CA - Update of BR02-09 
MOD02 - 20/12/2021 - KBhimasen - Spira#95743 - APOLO - CA : Message d'anomalies erroné
MOD03 - 03/08/2022 - Amit      - Spira-96999 - LIFE: Complete account by uploading on treaty By section
*****************************************************************************************************************************************************/



CREATE TABLE #WORKFILE
(
    CTR_NF       		UCTR_NF       NULL,
    SEC_NF       		USEC_NF       NULL,
    ACY_NF       		smallint      NULL,
    SCOENDMTH_NF 		tinyint       NULL,
    SSD_CF        	USSD_CF        NULL,
    ESB_CF        	UESB_CF        NULL,
    CTRTYP_CT   char(1)   NULL,  -- A assume, R retro
    BALSHT_D   datetime  NULL,  
    BALSHT_Y   int  NULL,  
    BALSHT_M   int  NULL,  
    MAXQUAT_NF int NULL,
    NUMLIGNE_NT   	int           NULL,
	FRSUWY_NF    smallint      NULL, 
	FRSCTR_B	bit default 0
)

CREATE TABLE #ANO
(
    NUMLIGNE_NT   	int           NULL,
    MESS_N   	int           NULL    
)

create TABLE #monthNE(
    CTR_NF       		UCTR_NF       NULL,
    ACY_NF       		smallint      NULL,
    SCOENDMTH_NF 		tinyint       NULL,
	SEC_NF       		USEC_NF       NULL
)



create TABLE #SCOSTRMTH(
    SCOENDMTH_NF 		tinyint       NULL,
	SCOSTRMTH_NF        tinyint       NULL
)

 

insert into #SCOSTRMTH VALUES (3, 1)
insert into #SCOSTRMTH VALUES (6, 4)
insert into #SCOSTRMTH VALUES (9, 7)
insert into #SCOSTRMTH VALUES (12, 10)


DECLARE @erreur      int,
		@rowcount    int,
        @tran_imbr   bit,
	    @currentdate datetime,
		@V_NBANO_NT      int,
        @V_NBLGKO_NT     int,
		@V_NBLGTOT_NT   int
	 

        
select @erreur = 0

select @tran_imbr = 1
 
select @currentdate = getdate()

select @V_NBLGTOT_NT = (select count(1) from  BTRAV..CPTD0912_WORKFILE where GSSD_CF=@p_ssd_cf and GESB_CF=@p_esb_cf and USR_CF=@p_usr_cf and NUMFIC_NT = @p_numfic)


 
--MOD[001] Start   
if @p_mess_n > 0
begin
	INSERT #ANO (NUMLIGNE_NT, MESS_N)
	SELECT 0, @p_mess_n 
	 
    select @erreur = @@error
    if @erreur != 0  goto fin2
 
    goto fin
end   
 


INSERT INTO #WORKFILE (CTR_NF, SEC_NF, ACY_NF, SCOENDMTH_NF, NUMLIGNE_NT,BALSHT_D,BALSHT_Y, BALSHT_M)
SELECT CTR_NF, SEC_NF,  ACY_NF, SCOENDMTH_NF, NUMLIGNE_NT, BALSHT_D, year(BALSHT_D), month(BALSHT_D) FROM BTRAV..CPTD0912_WORKFILE 
where GSSD_CF=@p_ssd_cf and GESB_CF=@p_esb_cf and USR_CF=@p_usr_cf and NUMFIC_NT = @p_numfic
order by CTR_NF, SEC_NF,  ACY_NF, SCOENDMTH_NF

SELECT @erreur = @@error, @p_erreur="INSERT ERR #WORKFILE 01"
IF @erreur != 0  GOTO fin2

/*Treaty */
/* Update Ledger Details */

UPDATE #WORKFILE
SET CTRTYP_CT = 'A',  SSD_CF =  A.SSD_CF, ESB_CF =  A.ACCESB_CF, FRSUWY_NF = A.FRSUWY_NF
FROM #WORKFILE B, BTRT..TCONTR A
where A.CTR_NF = B.CTR_NF and A.LSTUWY_B = 1


SELECT @erreur = @@error, @p_erreur="INSERT ERR #WORKFILE 02"
IF @erreur != 0  GOTO fin2
 
 
 
/* Retro Type*/
/* Update Ledger Details */
UPDATE #WORKFILE
SET CTRTYP_CT = 'R', SSD_CF =  A.SSD_CF, ESB_CF =  A.ESB_CF
FROM #WORKFILE B, BRET..TRETCTR A
where A.RETCTR_NF = B.CTR_NF --and A.RTY_NF = B.ACY_NF
AND A.RTY_NF = (SELECT MAX(RTY_NF) FROM BRET..TRETCTR C WHERE A.RETCTR_NF = C.RETCTR_NF)
--and EXISTS (SELECT 1 FROM BRET..TRETSEC C WHERE B.CTR_NF = C.RETCTR_NF AND B.ACY_NF = C.RTY_NF AND B.SEC_NF = C.RETSEC_NF)

SELECT @erreur = @@error, @p_erreur="UPDATE ERR #WORKFILE 03"
IF @erreur != 0  GOTO fin2


UPDATE #WORKFILE
SET MAXQUAT_NF = (SELECT max(SCOENDMTH_NF)  FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND A.ACY_NF = B.ACY_NF GROUP BY ctr_nf, acy_nf)
FROM #WORKFILE A
WHERE CTRTYP_CT = 'A'

SELECT @erreur = @@error, @p_erreur="UPDATE ERR #WORKFILE 04"
IF @erreur != 0  GOTO fin2


UPDATE #WORKFILE
SET MAXQUAT_NF = (SELECT max(SCOENDMTH_NF)  FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND A.ACY_NF = B.ACY_NF AND A.SEC_NF = B.SEC_NF GROUP BY ctr_nf, sec_nf,  acy_nf)
FROM #WORKFILE A
WHERE CTRTYP_CT = 'R'

SELECT @erreur = @@error, @p_erreur="UPDATE ERR #WORKFILE 05"
IF @erreur != 0  GOTO fin2


/* Update Mew contract flag .Assume*/
UPDATE #WORKFILE
SET FRSCTR_B = 1
FROM #WORKFILE A, #WORKFILE B
WHERE A.CTRTYP_CT = 'A' AND A.CTRTYP_CT = B.CTRTYP_CT and A.CTR_NF = B.CTR_NF AND A.FRSUWY_NF = B.ACY_NF

/* Update Mew contract flag .Retro */
UPDATE #WORKFILE
SET FRSCTR_B = 1
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'R'  AND A.ACY_NF = (SELECT MIN(RTY_NF) FROM BRET..TRETCTR B WHERE A.CTR_NF = B.RETCTR_NF )

insert  #monthNE ( ctr_nf, acy_nf, SCOENDMTH_NF) 
SELECT distinct ctr_nf, acy_nf, b.SCOENDMTH_NF
FROM #WORKFILE A  ,#SCOSTRMTH b
WHERE CTRTYP_CT = 'A' 
--and  A.CTR_NF = b.CTR_NF AND A.ACY_NF = b.ACY_NF
AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B=1  )  
GROUP BY ctr_nf, acy_nf

insert  #monthNE ( ctr_nf, acy_nf, SCOENDMTH_NF, sec_nf) 
SELECT distinct ctr_nf, acy_nf, b.SCOENDMTH_NF,a.sec_nf
FROM #WORKFILE A  ,#SCOSTRMTH b
WHERE CTRTYP_CT = 'R' --and  A.CTR_NF = b.CTR_NF AND A.ACY_NF = b.ACY_NF  and A.SEC_NF = B.SEC_NF and 
GROUP BY ctr_nf, acy_nf





DELETE #monthNE FROM #monthNE A, #WORKFILE  B
WHERE  b.CTRTYP_CT = 'A' and  A.CTR_NF = b.CTR_NF AND A.ACY_NF = b.ACY_NF  and 
EXISTS  (SELECT 1 FROM #WORKFILE D WHERE A.CTR_NF = d.CTR_NF AND A.ACY_NF = d.ACY_NF and A.SCOENDMTH_NF =d.SCOENDMTH_NF )


DELETE #monthNE FROM #monthNE A, #WORKFILE  B
WHERE  b.CTRTYP_CT = 'R' and  A.CTR_NF = b.CTR_NF AND A.ACY_NF = b.ACY_NF  and A.SEC_NF = B.SEC_NF and 
EXISTS  (SELECT 1 FROM #WORKFILE D WHERE A.CTR_NF = d.CTR_NF AND A.ACY_NF = d.ACY_NF AND A.SEC_NF = d.SEC_NF and A.SCOENDMTH_NF =d.SCOENDMTH_NF )


DELETE #monthNE
FROM #WORKFILE A, #monthNE c
where CTRTYP_CT = 'A' and a.ctr_nf =c.ctr_nf  and  a.acy_nf = c.acy_nf
and  c.SCOENDMTH_NF > A.MAXQUAT_NF

DELETE #monthNE
FROM #WORKFILE A, #monthNE c
where CTRTYP_CT = 'R' and a.ctr_nf =c.ctr_nf  and  a.acy_nf = c.acy_nf and  a.SEC_NF = c.SEC_NF
and  c.SCOENDMTH_NF > A.MAXQUAT_NF
 

DELETE #monthNE FROM #monthNE A, #WORKFILE  B
WHERE  CTRTYP_CT = 'A' and A.CTR_NF = b.CTR_NF AND A.ACY_NF = b.ACY_NF  
AND EXISTS (SELECT 1 FROM BCTA..TCPLACC   C WHERE A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF and A.SCOENDMTH_NF =C.SCOENDMTH_NF  )


DELETE #monthNE FROM #monthNE A, #WORKFILE  B
WHERE  CTRTYP_CT = 'R' and A.CTR_NF = b.CTR_NF AND A.ACY_NF = b.ACY_NF and a.SEC_NF = b.SEC_NF 
AND EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF and a.SEC_NF = C.SEC_NF 
                        and A.SCOENDMTH_NF =C.ACM_NF  )






/* Check Ledger - 35111 */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT NUMLIGNE_NT, 35111 
FROM #WORKFILE A
WHERE EXISTS (SELECT 1 FROM BREF..TESB B
            WHERE A.SSD_CF = B.SSD_CF AND A.ESB_CF = B.ESB_CF AND B.LIFE_CF != 1)

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 01"
IF @erreur != 0  GOTO fin2



/* Check Input file columns - 35120 */
/*Assume 
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT NUMLIGNE_NT, 35120 
FROM #WORKFILE A
WHERE (CTRTYP_CT= NULL OR CTRTYP_CT = 'A' ) AND (A.CTR_NF = NULL OR SCOENDMTH_NF = NULL OR ACY_NF = NULL)

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 02"
IF @erreur != 0  GOTO fin2


 
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT NUMLIGNE_NT, 35120 
FROM #WORKFILE A
WHERE CTRTYP_CT = 'R' AND (A.CTR_NF = NULL OR SCOENDMTH_NF = NULL OR ACY_NF = NULL OR  SEC_NF = NULL )

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 03"
IF @erreur != 0  GOTO fin2
*/


--MOD02[START]
/* Check Input file columns Assume - 34999 */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT NUMLIGNE_NT, 34999 
FROM #WORKFILE A
WHERE CTRTYP_CT = 'A' AND SEC_NF != NULL
SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 02"
IF @erreur != 0  GOTO fin2
--MOD02[END]
/* Check contract details Assume - 35121 */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT NUMLIGNE_NT, 35121  
FROM #WORKFILE A
WHERE  CTRTYP_CT = NULL 

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 04"
IF @erreur != 0  GOTO fin2


/* Check contract details Retro - 35121 */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT NUMLIGNE_NT, 35121  
FROM #WORKFILE A
WHERE  CTRTYP_CT != NULL and (CTRTYP_CT = 'R' AND  SEC_NF = NULL ) 

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 04R"
IF @erreur != 0  GOTO fin2
  
 
 
 
/* Check Accounting Year details - 35122  */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT NUMLIGNE_NT, 35122   
FROM #WORKFILE A
WHERE ACY_NF = NULL  

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 05"
IF @erreur != 0  GOTO fin2




/* Check Accounting year must be greater than or equal to the BALSHT_Y- 35112  */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35112   
FROM #WORKFILE A, #WORKFILE B
WHERE  A.CTR_NF = B.CTR_NF AND A.CTRTYP_CT = 'A' AND A.CTRTYP_CT =  B.CTRTYP_CT  and A.SCOENDMTH_NF = b.SCOENDMTH_NF and A.ACY_NF = b.ACY_NF 
and (A.ACY_NF > B.BALSHT_Y OR  (A.SCOENDMTH_NF >= B.BALSHT_M AND A.ACY_NF = B.BALSHT_Y) )		--MOD01

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 06 assume"
IF @erreur != 0  GOTO fin2


INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35112   
FROM #WORKFILE A, #WORKFILE B
WHERE  A.CTR_NF = B.CTR_NF AND  A.CTRTYP_CT = 'R' AND A.CTRTYP_CT =  B.CTRTYP_CT AND A.SEC_NF = B.SEC_NF  and A.SCOENDMTH_NF = b.SCOENDMTH_NF and A.ACY_NF = b.ACY_NF 
and (A.ACY_NF > B.BALSHT_Y OR  (A.SCOENDMTH_NF >= B.BALSHT_M AND A.ACY_NF = B.BALSHT_Y) )		--MOD01

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 06 retro"
IF @erreur != 0  GOTO fin2


 /* Check SCOR end month - 35124  */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35124   
FROM #WORKFILE A
WHERE SCOENDMTH_NF = NULL OR (SCOENDMTH_NF != NULL AND (SCOENDMTH_NF NOT IN ( 3,6,9,12) )  )

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 07"
IF @erreur != 0  GOTO fin2




/* R02-01: Duplicate rows in file - 35109  */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35109   
FROM #WORKFILE A WHERE A.CTRTYP_CT = 'A' 
	group by CTR_NF , ACY_NF, SCOENDMTH_NF
	having count(*) > 1   
	
SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 08"
IF @erreur != 0  GOTO fin2





INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35109   
FROM #WORKFILE A WHERE A.CTRTYP_CT = 'R' 
	group by CTR_NF, SEC_NF, ACY_NF, SCOENDMTH_NF
	having count(*) > 1     
 
SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 09"
IF @erreur != 0  GOTO fin2




/*  R02-02:Check if complete account already done. 35110  */
/* Assume */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35110   
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'A' AND  EXISTS (SELECT 1 FROM BCTA..TCPLACC   C WHERE A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF and A.SCOENDMTH_NF =C.SCOENDMTH_NF  )


SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 10"
IF @erreur != 0  GOTO fin2


/* Assume */
/*
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35110   
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'A'  AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B = 1 ) 
AND EXISTS (SELECT 1 FROM BCTA..TCPLACC  C WHERE A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF  
                            AND A.SCOENDMTH_NF = C.SCOENDMTH_NF )
                            
SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 11"
IF @erreur != 0  GOTO fin2
*/ 
 
 
/* Retro */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35110   
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'R' 
AND  EXISTS (SELECT 1 FROM BEST..TLIFDRID  C WHERE A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND A.SEC_NF = C.SEC_NF  AND A.SCOENDMTH_NF = C.ACM_NF )

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 12"
IF @erreur != 0  GOTO fin2

--MOD03[START] Add Estimates type=By Section.
/*R02-03:Only Estimate Type "quarterly" contract are allowed. 35113   */
/*ASSUME*/
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35113   
FROM #WORKFILE A
WHERE CTRTYP_CT = 'A' AND EXISTS (SELECT 1 FROM BTRT..TCONTR b where a.ctr_nf =  b.ctr_nf and  b.ESTCRB_CT NOT IN ('O', 'T')  ) 

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 13"
IF @erreur != 0  GOTO fin2



/*RETRO*/
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35113   
FROM #WORKFILE A
WHERE CTRTYP_CT = 'R' AND EXISTS (SELECT 1 FROM BRET..TRETCTR b WHERE a.ctr_nf =  b.retctr_nf and  b.ESTCRB_CT NOT IN ('O', 'T')  ) 

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 14"
IF @erreur != 0  GOTO fin2



/*R02-04:Check of data is annually/quarterly defined in the file 35114 /35115  */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35114   
FROM #WORKFILE A, BTRT..TACCSEND B 
WHERE CTRTYP_CT = 'A' AND  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B=0 AND A.SCOENDMTH_NF != 12 


SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 15"
IF @erreur != 0  GOTO fin2


INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35115   
FROM #WORKFILE A, BTRT..TACCSEND B 
WHERE CTRTYP_CT = 'A' AND  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B=1 AND A.SCOENDMTH_NF NOT IN (3,6,9,12) 

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 16"
IF @erreur != 0  GOTO fin2


/*R02-05:Check quarterly data for an accounting year. Check for missinfg Quater */
/*Assume : */

 
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35115
FROM #WORKFILE A  ,   #monthNE D
WHERE CTRTYP_CT = 'A' AND A.CTR_NF = D.CTR_NF AND A.ACY_NF = D.ACY_NF AND A.SCOENDMTH_NF = (D.SCOENDMTH_NF+3)
AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B=1  ) 

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 17a"
IF @erreur != 0  GOTO fin2



INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35115
FROM #WORKFILE A  ,   #monthNE D
WHERE CTRTYP_CT = 'R' AND A.CTR_NF = D.CTR_NF AND A.ACY_NF = D.ACY_NF AND A.SEC_NF = D.SEC_NF AND A.SCOENDMTH_NF = (D.SCOENDMTH_NF+3)
 


SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 17b"
IF @erreur != 0  GOTO fin2



/*Retro : 
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35115   
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'R'  
GROUP BY ctr_nf, sec_nf , acy_nf
HAVING COUNT(CTR_NF) != (MAXQUAT_NF/3)
*/


/* R02-06:Check account register are booked or not . 35117 */
-- Annual
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35117   
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'A' AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B IN (0) ) 
AND NOT EXISTS (SELECT 1 FROM BCTA..TAPR C WHERE A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF  AND ETY_D != NULL  )

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 19"
IF @erreur != 0  GOTO fin2

-- Periodic
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35117   
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'A' AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B IN (1) ) 
AND NOT EXISTS (SELECT 1 FROM BCTA..TAPR C WHERE A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF  AND A.SCOENDMTH_NF <= C.SCOENDMTH_NF AND ETY_D != NULL  )

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 19a"
IF @erreur != 0  GOTO fin2

 
/*  R02-??:Check if complete account is done for previous year/quartor . 35116  */
/* Assume.  Not Quarterly. check last year 12 month */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35116   
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'A' AND FRSCTR_B=0 AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B = 0 ) 
AND NOT EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND C.ACY_NF = (A.ACY_NF-1) AND C.ACM_NF = 12  )
AND NOT EXISTS (SELECT 1 FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND B.ACY_NF = (A.ACY_NF-1)  and B.SCOENDMTH_NF= 12)



SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 20"
IF @erreur != 0  GOTO fin2


/* Assume. Quarterly. check last year and 4rd quater. BCTA..TCPLACC.SCOENDMTH_NF =12 */                         
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35116   
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'A' AND FRSCTR_B=0 AND   A.SCOENDMTH_NF = 3 AND
 EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B = 1 ) 
AND NOT EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND C.ACY_NF = (A.ACY_NF-1)  AND C.ACM_NF = 12  )
AND NOT EXISTS (SELECT 1 FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND B.ACY_NF = (A.ACY_NF-1)  and B.SCOENDMTH_NF= 12)


SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 22"
IF @erreur != 0  GOTO fin2
 

/* Assume. Quarterly. check last Quarter but should not be 3rd quater*/
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35116   
FROM #WORKFILE A  
WHERE CTRTYP_CT = 'A'  and A.SCOENDMTH_NF != 3 AND EXISTS (SELECT 1 FROM BTRT..TACCSEND B  WHERE  A.CTR_NF = B.CTR_NF  AND  B.PRVSNDTYP_B = 1 ) 
AND NOT EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF AND C.ACM_NF = (A.SCOENDMTH_NF-3) )
AND NOT EXISTS (SELECT 1 FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND A.ACY_NF = B.ACY_NF  and B.SCOENDMTH_NF=(A.SCOENDMTH_NF-3) )



SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 21"
IF @erreur != 0  GOTO fin2




/* Retro if  SCOENDMTH_NF in file = 3 then check for last year 4th quater. */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35116 
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'R' and A.SCOENDMTH_NF = 3 AND FRSCTR_B=0
AND NOT EXISTS (SELECT 1 FROM BEST..TLIFDRID C WHERE  A.CTR_NF = C.CTR_NF AND C.ACY_NF = (A.ACY_NF-1)  AND C.ACM_NF = 12
   and a.SEC_NF = C.SEC_NF )
AND NOT EXISTS (SELECT 1 FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND B.ACY_NF = (A.ACY_NF-1)  and B.SCOENDMTH_NF=12 
    and a.SEC_NF = B.SEC_NF)

SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 23"
IF @erreur != 0  GOTO fin2



/* Retro if  SCOENDMTH_NF in file != 3 then check for current acy_nf year previous quater. */
INSERT #ANO (NUMLIGNE_NT, MESS_N)
SELECT A.NUMLIGNE_NT, 35116  
FROM #WORKFILE A 
WHERE CTRTYP_CT = 'R' and A.SCOENDMTH_NF != 3 
AND NOT EXISTS (SELECT 1 FROM BEST..TLIFDRID  C WHERE A.CTR_NF = C.CTR_NF AND A.ACY_NF = C.ACY_NF and a.SEC_NF = C.SEC_NF and C.ACM_NF=(A.SCOENDMTH_NF-3))
AND NOT EXISTS (SELECT 1 FROM #WORKFILE B WHERE A.CTR_NF = B.CTR_NF AND A.SEC_NF = B.SEC_NF AND A.ACY_NF = B.ACY_NF  and B.SCOENDMTH_NF=(A.SCOENDMTH_NF-3))



SELECT @erreur = @@error, @p_erreur="INSERT ERR #ANO 24"
IF @erreur != 0  GOTO fin2





IF EXISTS( SELECT NULL FROM #ANO ) GOTO fin


/********************************************************************************/
/*                                                                              */
/*                  Fin normale de la proc                                      */
/*                                                                              */
/********************************************************************************/
SELECT 0
RETURN 0

fin2:
select @p_erreur = 'Erreur PiCACOHRCHK_01 -: ' + @p_erreur 
PRINT @p_erreur


select 1
return 1

fin:
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

 
INSERT BCTA..TANOINTACC
(
  NUMFIC_NT, SSD_CF, ESB_CF, NUMLIGNE_NT, MESS_N
)
SELECT distinct @p_numfic, @p_ssd_cf, @p_esb_cf, NUMLIGNE_NT, MESS_N
FROM #ANO

SELECT @erreur = @@error, @p_erreur="INSERT ERR TANOINTACC"
IF @erreur != 0  GOTO fin4


SELECT  @V_NBANO_NT = (SELECT COUNT(1) FROM  BCTA..TANOINTACC
        WHERE  SSD_CF = @p_ssd_cf AND ESB_CF =  @p_esb_cf AND NUMFIC_NT = @p_NUMFIC) 
        
SELECT @V_NBLGKO_NT = (SELECT COUNT (DISTINCT NUMLIGNE_NT) FROM  BCTA..TANOINTACC
        WHERE SSD_CF = @p_ssd_cf AND ESB_CF =  @p_esb_cf AND NUMFIC_NT = @p_NUMFIC)

UPDATE BCTA..TSUIVINTACC
	  SET FICSTS_CF  = 'KO'   ,
		  INTEG_D      = @currentdate,
		  LSTUPDUSR_CF = 'dbo',
		  LSTUPD_D     = @currentdate,
		  NBLGTOT_NT = @V_NBLGTOT_NT,
		  NBLGKO_NT  = @V_NBLGKO_NT,
		  NBANO_NT = @V_NBANO_NT
WHERE NUMFIC_NT = @p_numfic  AND FICSTS_CF    in ('EC','EN') 


SELECT @erreur = @@error, @p_erreur="UPDATE ERR TSUIVINTACC"
IF @erreur != 0  GOTO fin4
 
 
UPDATE BTRAV..CPTD0912_WORKFILE 
SET ERR_B = 1
FROM BTRAV..CPTD0912_WORKFILE A , #ANO B
WHERE A.NUMFIC_NT = @p_numfic AND A.NUMLIGNE_NT = B.NUMLIGNE_NT AND GSSD_CF=@p_ssd_cf and GESB_CF=@p_esb_cf and USR_CF=@p_usr_cf


SELECT @erreur = @@error, @p_erreur="UPDATE ERR CPTD0912_WORKFILE"
IF @erreur != 0  GOTO fin4


IF @tran_imbr = 0
         COMMIT TRAN


SELECT 1
RETURN 1

fin4:
IF @tran_imbr = 0
         ROLLBACK TRAN
select @p_erreur = 'Erreur PiCACOHRCHK_01 -: ' + @p_erreur 
PRINT @p_erreur

SELECT 1
RETURN 1

go
EXEC sp_procxmode 'PiCACOHRCHK_01', 'unchained'
go
IF OBJECT_ID('PiCACOHRCHK_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PiCACOHRCHK_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PiCACOHRCHK_01 >>>'
go
GRANT EXECUTE ON PiCACOHRCHK_01 TO GOMEGA
go
GRANT EXECUTE ON PiCACOHRCHK_01 TO GDBBATCH
go
