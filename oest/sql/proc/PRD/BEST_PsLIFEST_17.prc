use BEST
go

IF OBJECT_ID ('dbo.PsLIFEST_17') IS NOT NULL
   BEGIN
      DROP PROCEDURE dbo.PsLIFEST_17

      IF OBJECT_ID ('dbo.PsLIFEST_17') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFEST_17 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE dbo.PsLIFEST_17 >>>'
   END
go

/***** create procedure dbo.PsLIFEST_17 *****/
create procedure dbo.PsLIFEST_17 (
  @p_ssd_cf		USSD_CF,
  @p_esb_cf		UESB_CF,
  @p_usr_cf		UUSR_CF
)
as
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : P.-E. Marx
Creation date     : 10/12/2015

Description       :  checks for treaty-level errors on New Business upload 
_________________
Modification  - Quarterly Upload 
Author: TDE
Date: 29/10/2018
Description: Prevent loading on No Estimate contract and Quarterly Contract
*****************************************************/
declare		@p_terctrB		bit

/* Step 1 : We set the maximum UWY which will be used for all checks */
/* 1.a fill MAXUWY */

/* we use a temporary table to get the maxuwy for each contract*/

CREATE TABLE #maxuwy
(
	CTR_NF		UCTR_NF				NOT NULL,
	SEC_NF		USEC_NF				NOT NULL,
	MAXUWY_NF	UUWY_NF				NULL,
	RETRO_B		bit		DEFAULT 0	NOT NULL
)

/* 1.a.1 fill MAXUWY from BTRT for assumed contracts */

INSERT into #maxuwy
SELECT
	s.CTR_NF as CTR_NF, 
	s.SEC_NF as SEC_NF,
	MAXUWY_NF = MAX(s.UWY_NF), 
	RETRO_B = 0
FROM BTRAV..EST_ESID0881_PERIMETER t, BTRT..TSECTION s
WHERE	s.SEC_NF	= t.SEC_NF 
	AND s.CTR_NF	= t.CTR_NF 
	AND s.END_NT	= 0 /* Endorsement number */
	AND s.UW_NT		= 1 /* Underwriting order */
	AND s.SECSTS_CT IN (14,16,17,19)/* Section has the rights to have estimations */
	AND t.SSD_CF	= @p_ssd_cf
	AND t.ESB_CF	= @p_esb_cf
	AND t.USR_CF	= @p_usr_cf
GROUP BY s.SEC_NF, s.CTR_NF, RETRO_B

/* 1.a.2 fill MAXUWY from BRET for retro contracts */

INSERT into #maxuwy
SELECT 
	c.RETCTR_NF as CTR_NF, 
	t.SEC_NF, /* 0 because check on sections is not necessary for retro contracts */
	MAXUWY_NF = MAX(c.RTY_NF),
	RETRO_B = 1
FROM	BTRAV..EST_ESID0881_PERIMETER t, 
		BRET..TRETCTR c
WHERE	t.CTR_NF		= c.RETCTR_NF 
	AND c.RETCTRSTS_CT in (3,19)
	AND t.SSD_CF		= @p_ssd_cf
	AND t.ESB_CF		= @p_esb_cf
	AND t.USR_CF		= @p_usr_cf
GROUP BY t.CTR_NF, t.SEC_NF, RETRO_B

/* 1.a.3 update the perimter with the max uwy */

UPDATE BTRAV..EST_ESID0881_PERIMETER
SET RETRO_B		= b.RETRO_B,
	MAXUWY_NF	= b.MAXUWY_NF
FROM #maxuwy b,
	BTRAV..EST_ESID0881_PERIMETER a
	WHERE a.CTR_NF = b.CTR_NF
		AND a.SEC_NF = b.SEC_NF
		AND a.SSD_CF = @p_ssd_cf
		AND a.ESB_CF = @p_esb_cf
		AND a.USR_CF = @p_usr_cf

/* 1.a.4 when no max uwy is found, assume it is null for further purposes */

UPDATE BTRAV..EST_ESID0881_PERIMETER
SET RETRO_B		= 0,
	MAXUWY_NF	= NULL
FROM BTRAV..EST_ESID0881_PERIMETER a
	WHERE NOT EXISTS (SELECT 1 FROM #maxuwy b
		WHERE	a.CTR_NF = b.CTR_NF
		AND		a.SEC_NF = b.SEC_NF
		AND		a.SSD_CF = @p_ssd_cf
		AND		a.ESB_CF = @p_esb_cf
		AND		a.USR_CF = @p_usr_cf
		)


/* 1.b.1 set infos from MAXUWY when UWY do not exists from BTRT for assumed contracts */
/* Note any change in step 1 should be changed here too */

update BTRAV..EST_ESID0881_PERIMETER 
SET	SECTIONSSD_CF = s.SSD_CF,
	SECTIONESB_CF = c.ACCESB_CF
FROM BTRAV..EST_ESID0881_PERIMETER t, BTRT..TSECTION s, BTRT..TCONTR c
WHERE	t.CTR_NF		= s.CTR_NF 
	AND t.CTR_NF		= c.CTR_NF
	AND t.SEC_NF		= s.SEC_NF 
	AND t.MAXUWY_NF		= s.UWY_NF
	AND t.MAXUWY_NF		= c.UWY_NF
	AND t.RETRO_B		= 0
	AND s.SECSTS_CT in (14,16,17,19) /* Section has the rights to have estimations */
	AND t.SSD_CF		= @p_ssd_cf
	AND t.ESB_CF		= @p_esb_cf
	AND t.USR_CF		= @p_usr_cf

/* 1.b.2 set infos when UWY do not exists from TRETCTR for retro contracts */

update BTRAV..EST_ESID0881_PERIMETER
SET SECTIONSSD_CF = s.SSD_CF,
	SECTIONESB_CF = c.ESB_CF
FROM BTRAV..EST_ESID0881_PERIMETER t, BRET..TRETSEC s, BRET..TRETCTR c
WHERE	t.CTR_NF	= s.RETCTR_NF 
	AND t.CTR_NF	= c.RETCTR_NF
	AND t.MAXUWY_NF	= s.RTY_NF
	AND t.MAXUWY_NF	= c.RTY_NF
	AND t.RETRO_B	= 1
	AND c.RETCTRSTS_CT in (3,19)
	AND t.SSD_CF	= @p_ssd_cf
	AND t.ESB_CF	= @p_esb_cf
	AND t.USR_CF	= @p_usr_cf

/* 1.b.3 All error codes reset to begin with */

update BTRAV..EST_ESID0881_PERIMETER
SET ERRORCODE_CT = NULL
 
 
 /* Step 2 : set the error code for each row of BTRAV..EST_ESID0881_PERIMETER  */
/* * Some contract have no uwy, or no uwy in the DB, we need to find the last UWY (max(UWY)) of the DB TRT..TSECTION for each of those contract */

/* 100 not good ledger and 104 : not exists in the DB */
update BTRAV..EST_ESID0881_PERIMETER
 SET 
	ERRORCODE_CT = CASE
    /* 100 : not good subsidiary SECTIONSSD_CF != SSD_CF */
		WHEN t.SECTIONSSD_CF != t.SSD_CF and t.SECTIONSSD_CF !=0
	THEN 100
    /* 125 : not good establishment SECTIONESB_CF != ESB_CF */
		WHEN t.SECTIONESB_CF != t.ESB_CF  and t.SECTIONESB_CF !=0
	THEN 125
    /* 104 : no UWY or future UWY in the DB <=> EXISTSINDB_CT = 0 */
		WHEN t.MAXUWY_NF IS NULL
	THEN 104
		ELSE NULL
	END
FROM BTRAV..EST_ESID0881_PERIMETER t
WHERE
	t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf

 /* 101 Estimate type Assume */

update BTRAV..EST_ESID0881_PERIMETER 
 SET ERRORCODE_CT = 101
 from BTRAV..EST_ESID0881_PERIMETER t, BTRT..TCONTR c
  where c.CTR_NF=t.CTR_NF
    AND t.MAXUWY_NF = c.UWY_NF
    and c.END_NT=0
    and c.UW_NT=1
    and c.ESTCRB_CT='N'
 and t.RETRO_B = 0
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf

 /* 134 : non accounting section */
update BTRAV..EST_ESID0881_PERIMETER 
 SET ERRORCODE_CT = 134
  from BTRAV..EST_ESID0881_PERIMETER e, BRET..TRETCTR r, BRET..TRETSEC t
  where r.RETCTR_NF = e.CTR_NF
    and r.RTY_NF = e.MAXUWY_NF
    and t.RETCTR_NF = e.CTR_NF
    and t.RTY_NF = e.MAXUWY_NF
    and t.RETSEC_NF = e.SEC_NF
    and r.RETCTRCAT_CF = '02' /* NProp contract */
    and t.PSESEC_B = 1 /* non-accounting section */
	and e.RETRO_B = 1
 AND e.SSD_CF = @p_ssd_cf
 AND e.ESB_CF = @p_esb_cf
 AND e.USR_CF = @p_usr_cf

 /* 107 : particular retro */
update BTRAV..EST_ESID0881_PERIMETER 
SET ERRORCODE_CT = 107 
FROM BTRAV..EST_ESID0881_PERIMETER t, BRET..TRETCTR s
WHERE  t.CTR_NF = s.RETCTR_NF 
 AND t.MAXUWY_NF = s.RTY_NF
 AND s.RETCTRSTS_CT in (3,19)
 AND s.RETCTRCAT_CF = '05' 
 AND s.CONRETCTR_B = 1 /* particular retro */
 AND t.RETRO_B = 1  
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf

/* 124 : 19 - Canceled*/
update BTRAV..EST_ESID0881_PERIMETER 
SET ERRORCODE_CT = 124
FROM BTRAV..EST_ESID0881_PERIMETER t, BRET..TRETCTR s
WHERE  t.CTR_NF = s.RETCTR_NF  
 AND t.MAXUWY_NF = s.RTY_NF
 AND s.RETCTRSTS_CT in (3,19)
 AND s.RETCTRCAT_CF = '05' 
 AND t.RETRO_B = 1  
 AND s.CONRETCTR_B = 1 /* particular retro */
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf

/* 135 : Closed Treaty */
update BTRAV..EST_ESID0881_PERIMETER 
SET ERRORCODE_CT = 135
FROM BTRAV..EST_ESID0881_PERIMETER t, BTRT..TSECTION s
WHERE  t.CTR_NF = s.CTR_NF 
 AND t.SEC_NF = s.SEC_NF 
 AND t.MAXUWY_NF = s.UWY_NF
 AND s.SECACCSTS_CT = 9 /* maxuwy section is closed */
 AND t.RETRO_B = 0
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf
 
 /*30002 : to check if the selected contract is a model contract - ASSUME */
update BTRAV..EST_ESID0881_PERIMETER 
SET ERRORCODE_CT = 30002
FROM BTRAV..EST_ESID0881_PERIMETER t, BTRT..TCONTR c
where c.CTR_NF=t.CTR_NF
 AND t.MAXUWY_NF = c.UWY_NF
 AND c.ESTCRB_CT='D'
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf

 /*30002 : to check if the selected contract is a model contract - RETRO */
update BTRAV..EST_ESID0881_PERIMETER 
SET ERRORCODE_CT = 30002
FROM BTRAV..EST_ESID0881_PERIMETER t, BRET..TRETCTR s 
where s.RETCTR_NF=t.CTR_NF
 AND t.MAXUWY_NF = s.RTY_NF
 and S.ESTCRB_CT='D'
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf

 /*30014: to check if retro contracts are terminated */
update BTRAV..EST_ESID0881_PERIMETER
SET ERRORCODE_CT = 30014
FROM BTRAV..EST_ESID0881_PERIMETER t, BRET..TRETCTR c
WHERE  t.CTR_NF = c.RETCTR_NF  
 AND t.MAXUWY_NF = c.RTY_NF
 AND t.RETRO_B = 1  
 AND c.TERCTR_B = 1 /* Terminated retro contract */
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf

/* 5035: to check if a contract is "No Estimates" (ESTCRB_CT = V)  */
UPDATE BTRAV..EST_ESID0881_PERIMETER 
SET ERRORCODE_CT = 5035
FROM BTRAV..EST_ESID0881_PERIMETER t
LEFT OUTER JOIN BTRT..TCONTR tcontr ON t.CTR_NF = tcontr.CTR_NF AND t.MAXUWY_NF=tcontr.UWY_NF
LEFT OUTER JOIN BRET..TRETCTR tret ON t.CTR_NF = tret.RETCTR_NF AND t.MAXUWY_NF=tret.RTY_NF
WHERE CASE 
    WHEN tcontr.CTR_NF IS NOT NULL 
    THEN tcontr.ESTCRB_CT 
    ELSE tret.ESTCRB_CT END = 'V'
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf

/* 5036: to check if a contract is "No Estimates" (ESTCRB_CT in T or U)  */
UPDATE BTRAV..EST_ESID0881_PERIMETER 
SET ERRORCODE_CT = 5036
FROM BTRAV..EST_ESID0881_PERIMETER t
LEFT OUTER JOIN BTRT..TCONTR tcontr ON t.CTR_NF = tcontr.CTR_NF AND t.MAXUWY_NF=tcontr.UWY_NF
LEFT OUTER JOIN BRET..TRETCTR tret ON t.CTR_NF = tret.RETCTR_NF AND t.MAXUWY_NF=tret.RTY_NF
WHERE CASE 
    WHEN tcontr.CTR_NF IS NOT NULL 
    THEN tcontr.ESTCRB_CT 
    ELSE tret.ESTCRB_CT END in ('T','U')
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf


 /*138: check if New Business is available for this contract*/

delete BTRAV..EST_ESID0881_TCTRANO from BTRAV..EST_ESID0881_TCTRANO where SSD_CF = @p_ssd_cf AND ESB_CF = @p_esb_cf AND SEG_NF = @p_usr_cf

UPDATE BTRAV..EST_ESID0881_PERIMETER
SET MAXUWY_NF = 0
FROM BTRAV..EST_ESID0881_PERIMETER a
WHERE     a.SSD_CF  = @p_ssd_cf
     AND  a.ESB_CF  = @p_esb_cf
     AND  a.USR_CF  = @p_usr_cf
     AND a.MAXUWY_NF = NULL


INSERT INTO BTRAV..EST_ESID0881_TCTRANO(
 CTR_NF,
 END_NT,
 SEC_NF,
 VRS_NF,
 SSD_CF,
 SEGTYP_CT,
 SEG_NF,
 ANO_CT,
 NUMLINE_NT,
 BLOCKING_B,
 ESB_CF,
 UWY_NF,
 ACY_NF
)
SELECT 
 t.CTR_NF,
 t.END_NT,
 t.SEC_NF,
 1,
 @p_ssd_cf,
 'N',
 @p_usr_cf,
 t.ERRORCODE_CT,
 t.NUMLINE_NT,
 1,
 @p_esb_cf,
 MAXUWY_NF,
 0
FROM BTRAV..EST_ESID0881_PERIMETER t
 WHERE t.ERRORCODE_CT != NULL
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf

if object_id('#maxuwy') is not null drop Table #maxuwy  

 
EXEC sp_procxmode 'dbo.PsLIFEST_17', 'unchained'
go

IF OBJECT_ID ('dbo.PsLIFEST_17') IS NOT NULL
   PRINT '<<< CREATED PROCEDURE dbo.PsLIFEST_17 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFEST_17 >>>'
go

GRANT EXECUTE ON dbo.PsLIFEST_17 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFEST_17 TO GDBBATCH
go
