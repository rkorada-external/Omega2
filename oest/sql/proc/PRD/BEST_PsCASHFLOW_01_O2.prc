USE BEST
go
IF OBJECT_ID('PsCASHFLOW_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsCASHFLOW_01_O2
    IF OBJECT_ID('PsCASHFLOW_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsCASHFLOW_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsCASHFLOW_01_O2 >>>'
END
go
create procedure PsCASHFLOW_01_O2 (
@p_ssd_cf USSD_CF,
@p_esb_cf UESB_CF,
@p_usr_cf UUSR_CF
)
WITH EXECUTE AS CALLER AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : MZM
Creation date     : 05/04/2018

Description       : Checks for treaty-level errors on Cash flow upload
_________________
Modification: MOD1 
Author: Lilian Wernert
Date: 22/05/2018
Description: Spira 68864
_________________
Modification: MOD2 
Author: Lilian Wernert
Date: 22/05/2018
Description: Spira 68868
_________________
Modification: MOD3 
Author: Lilian Wernert
Date: 23/05/2018
Description: Spira 68866 
_________________
Modification: MOD4 
Author: Lilian Wernert
Date: 06/06/2018
Description: Spira 69187 - Management of the last upload Flag 
_________________
Modification: MOD5
Author: Lilian Wernert
Date: 23/07/2018
Description: Spira 68866 
_________________
Modification  - Quarterly Upload 
Author: TDE
Date: 29/10/2018
Description: Prevent loading on No Estimate contract and Quarterly Contract
_________________
Modification : [007] - SPIRA 076191 - correction bug of clodat year control  
Author: B.LAGHA
Date: 22/03/2019
Description: Prevent loading on No Estimate contract and Quarterly Contract
_________________
Modification : [008] - SPIRA 90421 - Change the controle applied on the Cash Flow adjustments.
Author: B.LAGHA
Date: 30/09/2020
Description: Add control to allow loading of future UWYs and future quarters
_________________
Modification : [009] - Spira:93181
Author: B.LAGHA
Date: 10/09/2021
Description: Filling of new columns added in EST_ESID0891_PERIMETER (UWYPLAN_NF and VRSPLAN_NF)
_________________
Modification : [010] - SPIRA 90849 
Author: B.LAGHA
Date: 12/08/2021
Description: Change the UWY and ACY controls applied on the Cash Flow adjustments

*****************************************************/
declare
	@p_terctrB bit, 
	@p_uwyplan_nf UUWY_NF,  -- [009]
	@p_vrsplan_nf smallint  -- [009]
	
-- [009] START 
-- Set UWYPLAN_NF and VRSPLAN_NF from the last 'LIFE PLAN'
SELECT @p_uwyplan_nf = convert(int,substring(convert(varchar(10),VRS_NF), 1,4)),
       @p_vrsplan_nf = convert(int,substring(convert(varchar(10),VRS_NF), 5,2)) 
FROM   best..TREQJOBPLAN
WHERE  reqcod_ct = 'A'
AND    end_d != null
HAVING cre_d  = MAX(CRE_D)

UPDATE BTRAV..EST_ESID0891_PERIMETER
SET
	UWYPLAN_NF = @p_uwyplan_nf,
	VRSPLAN_NF = @p_vrsplan_nf 
WHERE ADJTYP_CF = 'Plan'
 AND  SSD_CF = @p_ssd_cf
 AND  ESB_CF = @p_esb_cf
 AND  USR_CF = @p_usr_cf
-- [009] END


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
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TSECTION s
WHERE	s.SEC_NF	= t.SEC_NF 
	AND s.CTR_NF	= t.CTR_NF 
	AND s.END_NT	= 0 /* Endorsement number */
	AND s.UW_NT		= 1 /* Underwriting order */
	AND s.SECSTS_CT IN (14,16,17,19,25)/* Section has the rights to have estimations */ /* MOD5 */
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
FROM	BTRAV..EST_ESID0891_PERIMETER t, 
		BRET..TRETCTR c
WHERE	t.CTR_NF		= c.RETCTR_NF 
	AND c.RETCTRSTS_CT in (3,19)
	AND t.SSD_CF		= @p_ssd_cf
	AND t.ESB_CF		= @p_esb_cf
	AND t.USR_CF		= @p_usr_cf
GROUP BY t.CTR_NF, t.SEC_NF, RETRO_B

/* 1.a.3 update the perimter with the max uwy */

UPDATE BTRAV..EST_ESID0891_PERIMETER
SET RETRO_B		= b.RETRO_B,
	MAXUWY_NF	= b.MAXUWY_NF
FROM #maxuwy b,
	BTRAV..EST_ESID0891_PERIMETER a
	WHERE a.CTR_NF = b.CTR_NF
		AND a.SEC_NF = b.SEC_NF
		AND a.SSD_CF = @p_ssd_cf
		AND a.ESB_CF = @p_esb_cf
		AND a.USR_CF = @p_usr_cf

/* 1.a.4 when no max uwy is found, assume it is null for further purposes */

UPDATE BTRAV..EST_ESID0891_PERIMETER
SET RETRO_B		= 0,
	MAXUWY_NF	= NULL
FROM BTRAV..EST_ESID0891_PERIMETER a
	WHERE NOT EXISTS (SELECT 1 FROM #maxuwy b
		WHERE	a.CTR_NF = b.CTR_NF
		AND		a.SEC_NF = b.SEC_NF
		AND		a.SSD_CF = @p_ssd_cf
		AND		a.ESB_CF = @p_esb_cf
		AND		a.USR_CF = @p_usr_cf
		)


/* 1.b.1 set infos from MAXUWY when UWY do not exists from BTRT for assumed contracts */
/* Note any change in step 1 should be changed here too */

update BTRAV..EST_ESID0891_PERIMETER 
SET	SECTIONSSD_CF = s.SSD_CF,
	SECTIONESB_CF = c.ACCESB_CF
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TSECTION s, BTRT..TCONTR c
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

update BTRAV..EST_ESID0891_PERIMETER
SET SECTIONSSD_CF = s.SSD_CF,
	SECTIONESB_CF = c.ESB_CF
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETSEC s, BRET..TRETCTR c
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

update BTRAV..EST_ESID0891_PERIMETER
SET ERRORCODE_CT = NULL
 
 
 /* Step 2 : set the error code for each row of BTRAV..EST_ESID0891_PERIMETER  */
/* * Some contract have no uwy, or no uwy in the DB, we need to find the last UWY (max(UWY)) of the DB TRT..TSECTION for each of those contract */

-- [008] START OF MODIFICATIONS --
declare @BLCSHTYEA_NF  Smallint,
		@TYPPER        Char(1),  -- type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)
		@DATE          Datetime,
		@CANCELATION_D Datetime
select @DATE = getdate(), @TYPPER = 'C'
-- fetch current BLCSHTYEA_NF from calendar
execute BREF..PsCALEND_02 @DATE ,@TYPPER,@BLCSHTYEA_NF output

-- [008] END OF MODIFICATIONS   --
--===================================================================
/* 100 not good ledger and 104 : not exists in the DB */
update BTRAV..EST_ESID0891_PERIMETER
 SET 
	ERRORCODE_CT = CASE
    /* 100 : not good subsidiary SECTIONSSD_CF != SSD_CF */
		WHEN t.SECTIONSSD_CF != t.SSD_CF and t.SECTIONSSD_CF !=0
	THEN 100
    /* 125 : not good establishment SECTIONESB_CF != ESB_CF */
		WHEN t.SECTIONESB_CF != t.ESB_CF  and t.SECTIONESB_CF !=0
	THEN 125
		ELSE NULL
	END
FROM BTRAV..EST_ESID0891_PERIMETER t
WHERE
	t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf
-- MOD[010] START --
--===================================================================
/* 104 : no UWY or future UWY in the DB <=> EXISTSINDB_CT = 0 - Assumed/Retro */
UPDATE BTRAV..EST_ESID0891_PERIMETER
 SET ERRORCODE_CT = 104
FROM BTRAV..EST_ESID0891_PERIMETER t
WHERE t.MAXUWY_NF IS NULL -- For retro case, only MAXUWY is enough to know if exists in DB 
 AND  NOT EXISTS (select 1 from BTRT..TCONTR tc where tc.CTR_NF = t.CTR_NF)
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 104 : UWY and section out of bounds - Assumed Contract*/
UPDATE BTRAV..EST_ESID0891_PERIMETER
 SET ERRORCODE_CT = 104
FROM BTRAV..EST_ESID0891_PERIMETER t
WHERE t.RETRO_B = 0
AND   t.SEC_NF not in ( select s.SEC_NF from BTRT..TSECTION s 
						where  t.CTR_NF = s.CTR_NF and t.UWY_NF = s.UWY_NF ) 
 -- Pas de uwy avant le 1er uwy du contrat et apres l'annee bilan + 4
 AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF)
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 104 : UWY and section out of bounds - retro Contract*/
UPDATE BTRAV..EST_ESID0891_PERIMETER
 SET ERRORCODE_CT = 104
FROM BTRAV..EST_ESID0891_PERIMETER t
WHERE t.RETRO_B = 1
AND   t.SEC_NF not in ( select s.RETSEC_NF from BRET..TRETSEC s 
						where  t.CTR_NF = s.RETCTR_NF and t.UWY_NF = s.RTY_NF )
 -- Pas de uwy avant le 1er uwy du contrat et apres l'annee bilan + 4
 AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF)
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
-- MOD[010] END --
--===================================================================
/* 101 Estimate type Assume */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
 SET ERRORCODE_CT = 101
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TCONTR c
WHERE c.CTR_NF=t.CTR_NF
 AND  t.MAXUWY_NF = c.UWY_NF --- DIFF ICI 1
 AND  c.END_NT=0
 AND  c.UW_NT=1
 AND  c.ESTCRB_CT='N'
 AND  t.RETRO_B = 0
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
 /* 134 : non accounting section */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
 SET ERRORCODE_CT = 134
FROM BTRAV..EST_ESID0891_PERIMETER e, BTRT..TSECTION t
WHERE t.CTR_NF = e.CTR_NF
 AND  t.UWY_NF = e.MAXUWY_NF
 AND  t.SEC_NF = e.SEC_NF
 AND  t.PARSEC_NF <> null /* non-accounting section */ /* MOD5 */
 AND  e.SSD_CF = @p_ssd_cf
 AND  e.ESB_CF = @p_esb_cf
 AND  e.USR_CF = @p_usr_cf
--===================================================================
/* MOD3 - START */
/* 138 : no existing section */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
 SET ERRORCODE_CT = 138
FROM BTRAV..EST_ESID0891_PERIMETER e  			/* MOD4 - START */
WHERE e.SEC_NF not in (select SEC_NF  
					  from BTRT..TSECTION ts
					  where e.CTR_NF = ts.CTR_NF
					  --and e.UWY_NF = ts.UWY_NF -- [008] 
					  and e.END_NT = ts.END_NT
					  and e.SSD_CF = ts.SSD_CF)
 AND e.RETRO_B = 0									/* MOD4 - END */
 AND e.SSD_CF = @p_ssd_cf
 AND e.ESB_CF = @p_esb_cf
 AND e.USR_CF = @p_usr_cf
/* MOD3 - END */  
--===================================================================
/* 107 : particular retro */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 107 
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETCTR s
WHERE t.CTR_NF = s.RETCTR_NF 
 AND t.MAXUWY_NF = s.RTY_NF
 AND s.RETCTRSTS_CT in (3,19)
 AND s.RETCTRCAT_CF = '05' 
 AND s.CONRETCTR_B = 1 /* particular retro */
 AND t.RETRO_B = 1  
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
--===================================================================
/* 124 : 19 - Canceled - Retro contracts */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 124
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETCTR s
WHERE t.CTR_NF = s.RETCTR_NF  
 AND t.MAXUWY_NF = s.RTY_NF
 AND s.RETCTRSTS_CT in (3,19)
 AND s.RETCTRCAT_CF = '05' 
 AND t.RETRO_B = 1  
 AND s.CONRETCTR_B = 1 /* particular retro */
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
--===================================================================
/* 135 : Closed Treaty */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 135
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TSECTION s
WHERE  t.CTR_NF = s.CTR_NF 
 AND t.SEC_NF = s.SEC_NF 
 AND t.MAXUWY_NF = s.UWY_NF
 AND s.SECACCSTS_CT = 9 /* maxuwy section is closed */
 AND t.RETRO_B = 0
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf
--===================================================================
/* 24 : bad currency */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 24
FROM BTRAV..EST_ESID0891_PERIMETER t, BREF..TCUR s
WHERE  
NOT EXISTS (SELECT 1 FROM BREF..TCUR WHERE CUR_CF = t.CUR_CF)
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf
--===================================================================
/* 139 : bad cfquarter / clodat */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 139
FROM BTRAV..EST_ESID0891_PERIMETER
WHERE -- Modification [007] START -- 
(
  CFQUARTER_CF <= CLODAT_D
 OR
 /* [008] : allow loading future quarters */
  (YEAR(CLODAT_D) < (YEAR(CFQUARTER_CF) - 4))
 /*
 OR
  (YEAR(CLODAT_D) = (YEAR(CFQUARTER_CF) - 1) AND MONTH(CLODAT_D) != 12)
 */
) -- Modification [007] END   -- 
AND SSD_CF = @p_ssd_cf
AND ESB_CF = @p_esb_cf
AND USR_CF = @p_usr_cf

-- [008] START OF MODIFICATIONS --
--===================================================================
/* 103 : bad UWY_NF - Assumed */ -- MOD[010]
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 103 
FROM BTRAV..EST_ESID0891_PERIMETER t 
WHERE 
	 t.MAXUWY_NF != NULL -- The contract/section exists
AND	 t.RETRO_B = 0
AND  t.CTR_NF not in (select S.CTR_NF from BTRT..TSECTION S 
					  where S.CTR_NF = t.CTR_NF 
					  and   S.SEC_NF = t.SEC_NF 
					  and   S.UWY_NF = t.UWY_NF
					  group by S.CTR_NF )
-- Fictive UWY_NF are only possible in the future
AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF) 
AND  t.SSD_CF = @p_ssd_cf
AND  t.ESB_CF = @p_esb_cf
AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 103 : bad UWY_NF - Retro */ -- MOD[010]
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 103 
FROM BTRAV..EST_ESID0891_PERIMETER t 
WHERE 
	 t.MAXUWY_NF != NULL -- The contract/section exists
AND  t.RETRO_B = 1
AND  t.CTR_NF not in (select R.RETCTR_NF from BRET..TRETCTR  R 
					  where R.RETCTR_NF = t.CTR_NF 
					  and   R.RTY_NF = t.UWY_NF 
					  and   R.CONRETCTR_B != 1
					  group by R.RETCTR_NF )
-- Fictive UWY_NF are only possible in the future
AND (t.UWY_NF > @BLCSHTYEA_NF + 4 or t.MAXUWY_NF > t.UWY_NF) 
AND  t.SSD_CF = @p_ssd_cf
AND  t.ESB_CF = @p_esb_cf
AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 124 : bad UWY_NF because the contract is already canceled 
-- Assumed/retro [010] */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 124 
FROM BTRAV..EST_ESID0891_PERIMETER t 
WHERE
-- not allow loading when ctr is canceled and UWY > cancelation date
    t.UWY_NF > t.MAXUWY_NF
AND 19 = case when t.RETRO_B = 0 then
				  (select S.SECSTS_CT from BTRT..TSECTION S 
				   where S.CTR_NF = t.CTR_NF 
				   and   S.SEC_NF = t.SEC_NF 
				   and   S.UWY_NF = t.MAXUWY_NF )
				else
				  (select C.RETCTRSTS_CT from BRET..TRETCTR  C 
				   where C.RETCTR_NF = t.CTR_NF and C.RTY_NF = t.MAXUWY_NF )
				end
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf
-- [008] END OF MODIFICATIONS   --
--===================================================================
/* 551 : Acc Type 5 -> Premium / charge T. Code :Exercice invalide. Accepte */
-- No UWY after the concelled UWY 
-- MOD[010] - add this control
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 551
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 -- We look for Acc Type of MAXUWY because in case of uwy > maxuwy --> uwy not exists
 AND  t.MAXUWY_NF = s.UWY_NF 
 AND  s.ACCADMTYP_CT = 5
 AND  t.UWY_NF > t.MAXUWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  (select BLOCK_NF from BREF..TSUBTRSBLOCKLIFEST
			where PCPTRS_CF = substring(t.TRNCOD_CF,1,2)
			 and  TRS_CF    = substring(t.TRNCOD_CF,3,1)
			 and  SUBTRS_CF = substring(t.TRNCOD_CF,4,2)) in (1,2)
--===================================================================
/* 551 : Acc Type 5 -> Premium / charge T. Code :Exercice invalide. Retro */
-- No UWY after the concelled UWY 
-- MOD[010] - add this control
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 551
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETCTR s
WHERE t.CTR_NF = s.RETCTR_NF
 -- We look for Acc Type of MAXUWY because in case of uwy > maxuwy --> uwy not exists
 AND  t.MAXUWY_NF = s.RTY_NF 
 AND  s.RETACCTYP_CT = 5
 AND  t.UWY_NF > t.MAXUWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  (select BLOCK_NF from BREF..TSUBTRSBLOCKLIFEST
			where PCPTRS_CF = substring(t.TRNCOD_CF,1,2)
			 and  TRS_CF    = substring(t.TRNCOD_CF,3,1)
			 and  SUBTRS_CF = substring(t.TRNCOD_CF,4,2)) in (1,2)
--===================================================================
/* 551 :  Acc Type 4 : Exercice invalide. Accepte */
-- No UWY after the concelled UWY 
-- MOD[010] - add this control
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 551
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TSECTION s
WHERE t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 -- We look for Acc Type of MAXUWY because in case of uwy > maxuwy --> uwy not exists
 AND  t.MAXUWY_NF = s.UWY_NF 
 AND  s.ACCADMTYP_CT = 4
 AND  t.UWY_NF > t.MAXUWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 551 :  Acc Type 4 : Exercice invalide. Retro */
-- No UWY after the concelled UWY 
-- MOD[010] - add this control
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 551
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETCTR s
WHERE t.CTR_NF = s.RETCTR_NF
 -- We look for Acc Type of MAXUWY because in case of uwy > maxuwy --> uwy not exists
 AND  t.MAXUWY_NF = s.RTY_NF 
 AND  s.RETACCTYP_CT = 4
 AND  t.UWY_NF > t.MAXUWY_NF
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 109 : Acc type 1: AcYear must be equal to UWYear - Assumed */
-- MOD[010] - add this control
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 109
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TSECTION s
WHERE t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.RETRO_B = 0
-- MOD[010] - When UWY exists in db then Accounting type of uwy
--            else Accounting type of max(uwy)
 AND case when exists ( select 1 from BTRT..TSECTION S2
						where S2.CTR_NF = t.CTR_NF 
						and   S2.SEC_NF = t.SEC_NF
						and   S2.UWY_NF = t.UWY_NF )
		  then t.UWY_NF
		  else t.MAXUWY_NF
	 end = s.UWY_NF 
 AND  t.ACY_NT != t.UWY_NF
 AND  s.ACCADMTYP_CT = 1
--===================================================================
/* 109 : Acc type 1: AcYear must be equal to UWYear - Retro */
-- MOD[010] - add this control
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 109
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETCTR s
WHERE t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.CTR_NF = s.RETCTR_NF
 AND  t.RETRO_B = 1
-- MOD[010] - When UWY exists in db then Accounting type of uwy 
--            else Accounting type of max(uwy)
 AND case when exists ( select 1 from BRET..TRETCTR S2 
						where S2.RETCTR_NF = t.CTR_NF
						and   S2.RTY_NF = t.UWY_NF )
		  then t.UWY_NF
		  else t.MAXUWY_NF
	 end = s.RTY_NF 
 AND  t.ACY_NT != t.UWY_NF
 AND  s.RETACCTYP_CT = 1
--===================================================================
/* 111 : Acc type 3: for premium / charge T. Code 
-- the AcYear must be equal to UWYear - Assumed */
-- MOD[010] - add this control
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 111
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TSECTION s
WHERE t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.CTR_NF = s.CTR_NF
 AND  t.SEC_NF = s.SEC_NF
 AND  t.RETRO_B = 0
-- MOD[010] - When UWY exists in db then Accounting type of uwy
--            else Accounting type of max(uwy)
 AND case when exists ( select 1 from BTRT..TSECTION S2
						where S2.CTR_NF = t.CTR_NF 
						and   S2.SEC_NF = t.SEC_NF
						and   S2.UWY_NF = t.UWY_NF )
		  then t.UWY_NF
		  else t.MAXUWY_NF
	 end = s.UWY_NF 
 AND  t.ACY_NT != t.UWY_NF
 AND  s.ACCADMTYP_CT = 3
 AND  (select BLOCK_NF from BREF..TSUBTRSBLOCKLIFEST
			where PCPTRS_CF = substring(t.TRNCOD_CF,1,2)
			 and  TRS_CF    = substring(t.TRNCOD_CF,3,1)
			 and  SUBTRS_CF = substring(t.TRNCOD_CF,4,2)) in (1,2)
--===================================================================
/* 111 : Acc type 3: for premium / charge T. Code 
-- the AcYear must be equal to UWYear - Retro */
-- MOD[010] - add this control
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 111
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETCTR s
WHERE t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.CTR_NF = s.RETCTR_NF
 AND  t.RETRO_B = 1
-- MOD[010] - When UWY exists in db then Accounting type of uwy 
--            else Accounting type of max(uwy)
 AND case when exists ( select 1 from BRET..TRETCTR S2 
						where S2.RETCTR_NF = t.CTR_NF
						and   S2.RTY_NF = t.UWY_NF )
		  then t.UWY_NF
		  else t.MAXUWY_NF
	 end = s.RTY_NF 
 AND  t.ACY_NT != t.UWY_NF
 AND  s.RETACCTYP_CT = 3
 AND  (select BLOCK_NF from BREF..TSUBTRSBLOCKLIFEST
			where PCPTRS_CF = substring(t.TRNCOD_CF,1,2)
			 and  TRS_CF    = substring(t.TRNCOD_CF,3,1)
			 and  SUBTRS_CF = substring(t.TRNCOD_CF,4,2)) in (1,2)
--===================================================================
/* 531 : invalid accountig year (out of bounds) 
-- Assumed/retro */ -- MOD[010]
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 531 
FROM BTRAV..EST_ESID0891_PERIMETER t 
WHERE (t.ACY_NT < (@BLCSHTYEA_NF - 4) or t.ACY_NT > (@BLCSHTYEA_NF + 4))
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 551 : invalid UWYear (out of bounds) 
-- Assumed/retro */ -- MOD[010]
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 551 
FROM BTRAV..EST_ESID0891_PERIMETER t 
WHERE (t.UWY_NF < (@BLCSHTYEA_NF - 4) or t.UWY_NF > (@BLCSHTYEA_NF + 4))
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 135 : Unable to load estimates on treaties closed, Provisional/study and NTU */
-- MOD[010] - add this control - Assumed
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 135
FROM BTRAV..EST_ESID0891_PERIMETER t
WHERE t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.RETRO_B = 0
 AND  t.CTR_NF not in ( select CTR_NF from BTRT..TSECTION S1
						where S1.CTR_NF = t.CTR_NF
						and   S1.SEC_NF = t.SEC_NF
						and   S1.SECSTS_CT  in (14,16,17,19)
						group by CTR_NF )
--===================================================================
/* 135 : Unable to load estimates on treaties closed, Provisional/study and NTU */
-- MOD[010] - add this control - Retro
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 135
FROM BTRAV..EST_ESID0891_PERIMETER t
WHERE t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
 AND  t.RETRO_B = 1
 AND  t.CTR_NF not in ( select RETCTR_NF from BRET..TRETCTR S1
						where S1.RETCTR_NF = t.CTR_NF
						and   S1.RETCTRSTS_CT in (3,19)
						group by RETCTR_NF ) 
--===================================================================
/* 116 : invalid transaction code*/ 
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 116 /* MOD1 */
FROM BTRAV..EST_ESID0891_PERIMETER t, BREF..TSUBTRS s
WHERE  
NOT EXISTS (SELECT 1 FROM BREF..TSUBTRS WHERE PCPTRS_CF+TRS_CF+SUBTRS_CF = t.TRNCOD_CF)
AND t.SSD_CF = @p_ssd_cf
AND t.ESB_CF = @p_esb_cf
AND t.USR_CF = @p_usr_cf
--===================================================================
/*30002 : to check if the selected contract is a model contract - ASSUME */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 30002
FROM BTRAV..EST_ESID0891_PERIMETER t, BTRT..TCONTR c
where c.CTR_NF=t.CTR_NF
 AND  t.MAXUWY_NF = c.UWY_NF
 AND  c.ESTCRB_CT='D'
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
/*30002 : to check if the selected contract is a model contract - RETRO */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 30002
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETCTR s 
WHERE s.RETCTR_NF=t.CTR_NF
 AND t.MAXUWY_NF = s.RTY_NF
 AND S.ESTCRB_CT='D'
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
--===================================================================
/*30014: to check if retro contracts are terminated */
UPDATE BTRAV..EST_ESID0891_PERIMETER
SET ERRORCODE_CT = 30014
FROM BTRAV..EST_ESID0891_PERIMETER t, BRET..TRETCTR c
WHERE t.CTR_NF = c.RETCTR_NF  
 AND  t.MAXUWY_NF = c.RTY_NF
 AND  t.RETRO_B = 1  
 AND  c.TERCTR_B = 1 /* Terminated retro contract */
 AND  t.SSD_CF = @p_ssd_cf
 AND  t.ESB_CF = @p_esb_cf
 AND  t.USR_CF = @p_usr_cf
--===================================================================
/* 138: check if New Business is available for this contract*/
UPDATE BTRAV..EST_ESID0891_PERIMETER
SET MAXUWY_NF = 0
FROM BTRAV..EST_ESID0891_PERIMETER a
WHERE a.SSD_CF  = @p_ssd_cf
 AND  a.ESB_CF  = @p_esb_cf
 AND  a.USR_CF  = @p_usr_cf
 AND  a.MAXUWY_NF = NULL
--===================================================================
/* 5035: to check if a contract is "No Estimates" (ESTCRB_CT = V)  */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 5035
FROM BTRAV..EST_ESID0891_PERIMETER t
LEFT OUTER JOIN BTRT..TCONTR tcontr ON t.CTR_NF = tcontr.CTR_NF AND t.UWY_NF=tcontr.UWY_NF
LEFT OUTER JOIN BRET..TRETCTR tret ON t.CTR_NF = tret.RETCTR_NF AND t.UWY_NF=tret.RTY_NF
WHERE CASE 
    WHEN tcontr.CTR_NF IS NOT NULL 
    THEN tcontr.ESTCRB_CT 
    ELSE tret.ESTCRB_CT END = 'V'
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
--===================================================================
/* 5036: to check if a contract is "No Estimates" (ESTCRB_CT in T or U)  */
UPDATE BTRAV..EST_ESID0891_PERIMETER 
SET ERRORCODE_CT = 5036
FROM BTRAV..EST_ESID0891_PERIMETER t
LEFT OUTER JOIN BTRT..TCONTR tcontr ON t.CTR_NF = tcontr.CTR_NF AND t.UWY_NF=tcontr.UWY_NF
LEFT OUTER JOIN BRET..TRETCTR tret ON t.CTR_NF = tret.RETCTR_NF AND t.UWY_NF=tret.RTY_NF
WHERE CASE 
    WHEN tcontr.CTR_NF IS NOT NULL 
    THEN tcontr.ESTCRB_CT 
    ELSE tret.ESTCRB_CT END in ('T','U')
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf
--===================================================================

DELETE BTRAV..EST_ESID0891_TCTRANO 
FROM BTRAV..EST_ESID0891_TCTRANO 
WHERE SSD_CF = @p_ssd_cf
 AND  ESB_CF = @p_esb_cf
 AND  SEG_NF = @p_usr_cf

INSERT INTO BTRAV..EST_ESID0891_TCTRANO(
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
 'F',
 @p_usr_cf,
 t.ERRORCODE_CT,
 t.NUMLINE_NT,
 1,
 @p_esb_cf,
 UWY_NF,
 ACY_NT
FROM BTRAV..EST_ESID0891_PERIMETER t
 WHERE t.ERRORCODE_CT != NULL
 AND t.SSD_CF = @p_ssd_cf
 AND t.ESB_CF = @p_esb_cf
 AND t.USR_CF = @p_usr_cf

if object_id('#maxuwy') is not null drop Table #maxuwy  

go 
EXEC sp_procxmode 'PsCASHFLOW_01_O2', 'unchained'
go

IF OBJECT_ID('PsCASHFLOW_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsCASHFLOW_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsCASHFLOW_01_O2 >>>'
go
GRANT EXECUTE ON PsCASHFLOW_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PsCASHFLOW_01_O2 TO GDBBATCH
go
