USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_02_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_02_O2
    IF OBJECT_ID('PsEST_IFRS17_02_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_02_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_02_O2 >>>'
END
go
create procedure PsEST_IFRS17_02_O2 
AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Riyadh
Creation date     : 02/07/2018

Description       : 
_________________
Modification: MOD1 
Author: Riyadh  
Date: 07/03/2019 
Description: Spira 75669 update estcrb_cf for all uwy in TCONTR and TSECTION
_________________

_________________
Modification: MOD2
Author: Riyadh  
Date: 07/08/2019 
Description: Spira 80589 Control Complete ccount for treaty never CC done
_________________
Modification: MOD3
Author: S.Behague
Date: 23/03/2021
Description: Spira 93292 Apolo QE - Management of Transaction Codes Automatic Update - Script part
_________________
Modification: MOD4
Author: S.Behague
Date: 05/05/2021
Description: Spira 93292 Apolo QE - Management of Transaction Codes Automatic Update - Script part - reopen pour prendr en compte toutes les sections de l'exercices
_________________
Modification: MOD5
Author: S.Behague
Date: 30/11/2021
Description: Spira 98335 Script to move to quaterly estimates - Remaining issues
_________________
*/


declare
        @error_type   int,
        @MsgAnomalie    varchar(120),
        @MsgAnomalie1    varchar(120),
        @MsgAnomalie2    varchar(120),
        @MsgAssumed    varchar(10),
        @MsgRetro    varchar(10),
        @AnomalieCode    varchar(120),
    @nbligne_ESTIFRS17 int,    /* nbre lignes de la table utilisateurs en entrée */
    @nbligne_TLOADING int,    /* nbre lignes en sortie de traitement */
    @nbligne_TANO int    /* nbre lignes avec error */
    
    
  select @MsgAssumed    = 'assumed'
  select @MsgRetro     = 'retro'

CREATE TABLE #TLOADING
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
	ESTCRB_CT char     NOT NULL
)

CREATE TABLE #TLOADING1
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
	OLD_ESTCRB_CT char    NULL,
  NEW_ESTCRB_CT char     NOT NULL
)


CREATE TABLE #TLOADING2
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
MINRTY_NF	UUWY_NF				NULL,
  MAXRTY_NF	UUWY_NF				NULL,
	ESTCRB_CT char     NOT NULL

)

CREATE TABLE #TLOADING_CONTROL3 
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
  MINRTY_NF	UUWY_NF				NULL,
  MAXRTY_NF	UUWY_NF				NULL,
  RETCTRSTS_CT int           NULL,
  MINUWY_NF	UUWY_NF				NULL,
  MAXUWY_NF	UUWY_NF				NULL,
  CTRSTS_CT int           NULL,
 	ESTCRB_CT char     NOT NULL
  
)


CREATE TABLE #TLOADING_LEDGER
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
	ESTCRB_CT char     NOT NULL,
  RETSSD_CF  USSD_CF    NOT NULL,
  RETESB_CF UESB_CF  NOT NULL,
  CTRSSD_CF  USSD_CF    NOT NULL,
  CTRESB_CF UESB_CF  NOT NULL
)


CREATE TABLE #TANO_TMP2
(
    CTR_NF       UCTR_NF        NULL,
    UWY_NF	     UUWY_NF        NULL,
    ANO_CT       int            NULL,
    ANOCODE_LL   varchar(32)    NULL,
    ANO_LL       varchar(128)   NULL,
    MAXUWY_NF	UUWY_NF				NULL
)  



select @nbligne_ESTIFRS17 = count(*) FROM btrav..EST_IFRS17_PERIMETER

/*****************
-- Control 1: Check Existance of Contract in DB 
******************/



Insert into  #TLOADING
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER
where RETCTR_NF != null
and CTR_NF  != null
and RETCTR_NF  in (select RETCTR_NF from BRET..TRETCTR ) 
and CTR_NF in (Select CTR_NF from BTRT..TCONTR)
union
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER
where RETCTR_NF  in (select RETCTR_NF from BRET..TRETCTR ) 
and CTR_NF = null 
UNION
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER
where CTR_NF  in (Select CTR_NF from BTRT..TCONTR ) 
and RETCTR_NF = null



--Compare Number of contract in Temp Table and Table  
select @nbligne_TLOADING = count(*) FROM #TLOADING

if ( @nbligne_ESTIFRS17 != @nbligne_TLOADING )
  begin
    
  select @error_type = 1
  select @MsgAnomalie = 'Treaty '
  select @MsgAnomalie1 =  ' does not exists in ' 
  select @MsgAnomalie2 =  ' database' 

  

  Select @AnomalieCode = 'check contract exists'
    INSERT INTO #TANO_TMP (CTR_NF, UWY_NF , ANO_CT ,ANOCODE_LL, ANO_LL)  
    SELECT a.CTR_NF , A.UWY_nf , @error_type, @AnomalieCode, @MsgAnomalie + a.CTR_NF + @MsgAnomalie1 + @MsgAssumed + @MsgAnomalie2
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.CTR_NF = B.CTR_NF
    WHERE B.CTR_NF IS NULL and A.RETCTR_NF =null and A.CTR_NF is not null
    UNION
    SELECT a.RETCTR_NF, a.RTY_NF ,@error_type, @AnomalieCode, @MsgAnomalie + a.RETCTR_NF + @MsgAnomalie1 + @MsgRetro + @MsgAnomalie2
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.RETCTR_NF = B.RETCTR_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF =null and A.RETCTR_NF is not null
    UNION
    SELECT a.CTR_NF , A.UWY_nf ,@error_type,@AnomalieCode, @MsgAnomalie + a.CTR_NF + @MsgAnomalie1 + @MsgAssumed + @MsgAnomalie2
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN BTRT..TCONTR B ON A.CTR_NF = B.CTR_NF
    WHERE B.CTR_NF IS NULL and A.CTR_NF is not null and A.RETCTR_NF is not null
    UNION
    SELECT a.RETCTR_NF, a.RTY_NF ,@error_type, @AnomalieCode, @MsgAnomalie + a.RETCTR_NF + @MsgAnomalie1 + @MsgRetro + @MsgAnomalie2
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN BRET..TRETCTR B ON A.RETCTR_NF = B.RETCTR_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF is not null and A.RETCTR_NF is not null
    
  end

/****************/

/*****************
-- Control 2: Check Existance of exercise for Contract in DB 
******************/
Delete from #TLOADING  -- Clean TMP table for Reuse 

Insert into  #TLOADING
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER est
where RTY_NF  in (select max(RTY_NF) from BRET..TRETCTR  r where r.RETCTR_NF = est.RETCTR_NF  ) 
and CTR_NF = null
union
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER est
where UWY_NF  in (select max(UWY_NF) from BTRT..TCONTR c  where c.CTR_NF = est.CTR_NF  ) 
and RETCTR_NF = null
UNION
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER est
where UWY_NF  in (select max(UWY_NF) from BTRT..TCONTR c  where c.CTR_NF = est.CTR_NF  ) 
and   RTY_NF  in (select max(RTY_NF) from BRET..TRETCTR  r where r.RETCTR_NF = est.RETCTR_NF)
and RETCTR_NF != null
and CTR_NF != null


--Compare Number of contract in Temp Table and Table  
select @nbligne_TLOADING = count(*) FROM #TLOADING
if ( @nbligne_ESTIFRS17 != @nbligne_TLOADING )
  begin
  

    
  select @error_type = 2
  select @MsgAnomalie = 'The Estimate type can be only changed on the last UWY : '
  
  Select @AnomalieCode = '	Check contract validity on UWY'
    INSERT INTO #TANO_TMP2 (CTR_NF, UWY_NF , ANO_CT ,ANOCODE_LL, ANO_LL)  
    SELECT distinct a.CTR_NF , A.UWY_nf , @error_type, @AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.CTR_NF = B.CTR_NF and A.UWY_NF = B.UWY_NF
    WHERE B.CTR_NF IS NULL and A.RETCTR_NF =null and A.CTR_NF is not null and a.CTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.CTR_NF and c.UWY_nf= A.UWY_NF ) 
    UNION
    SELECT distinct a.RETCTR_NF, a.RTY_NF ,@error_type, @AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.RETCTR_NF = B.RETCTR_NF and A.RTY_NF = B.RTY_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF =null and A.RETCTR_NF is not null and a.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.RETCTR_NF and c.UWY_nf= A.RTY_NF ) 
    UNION
    SELECT distinct a.CTR_NF , A.UWY_nf ,@error_type,  @AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN BTRT..TCONTR B ON A.CTR_NF = B.CTR_NF and A.UWY_NF = B.UWY_NF
    WHERE B.CTR_NF IS NULL and A.CTR_NF is not null and A.RETCTR_NF is not null and a.CTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.CTR_NF and c.UWY_nf= A.UWY_NF )
    UNION
    SELECT distinct a.RETCTR_NF, a.RTY_NF ,@error_type, @AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN BRET..TRETCTR B ON A.RETCTR_NF = B.RETCTR_NF and A.RTY_NF = B.RTY_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF is not null and A.RETCTR_NF is not null and a.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.RETCTR_NF and c.UWY_nf= A.RTY_NF )
    
  
    
    UPDATE #TANO_TMP2  SET MAXUWY_NF = (SELECT MAX(UWY_NF) FROM BTRT..TCONTR C where C.CTR_NF = #TANO_TMP2.CTR_NF  ) WHERE CTR_NF IS NOT NULL
    UPDATE #TANO_TMP2  SET MAXUWY_NF = (SELECT MAX(RTY_NF) FROM BRET..TRETCTR C where C.RETCTR_NF = #TANO_TMP2.CTR_NF  ) WHERE CTR_NF IS NOT NULL and MAXUWY_NF is  null
    
    INSERT INTO #TANO_TMP (CTR_NF, UWY_NF , ANO_CT ,ANOCODE_LL, ANO_LL) 
     SELECT distinct a.CTR_NF , A.UWY_nf , @error_type, @AnomalieCode , @MsgAnomalie + CAST(A.MAXUWY_NF AS varchar(4))
     from #TANO_TMP2 a
  end 
/****************/

/*****************
-- Control 3: Check if status of treaty is valid or not and Check if ledger is 
******************/
DELETE FROM #TLOADING
Delete from #TLOADING_CONTROL3  -- Clean TMP table for Reuse 

Insert into  #TLOADING_CONTROL3
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	0,
  0,
	0,
  0,
  0,
	0,
	ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER P

UPDATE #TLOADING_CONTROL3  SET MINUWY_NF = (SELECT MIN(UWY_NF) FROM BTRT..TCONTR C where C.CTR_NF = #TLOADING_CONTROL3.CTR_NF  ),MAXUWY_NF = (SELECT MAX(UWY_NF) FROM BTRT..TCONTR C where C.CTR_NF = #TLOADING_CONTROL3.CTR_NF  ) WHERE CTR_NF IS NOT NULL
UPDATE #TLOADING_CONTROL3  SET MINRTY_NF = (SELECT MIN(RTY_NF) FROM BRET..TRETCTR C where C.RETCTR_NF = #TLOADING_CONTROL3.RETCTR_NF  ),MAXRTY_NF = (SELECT MAX(RTY_NF) FROM BRET..TRETCTR C where C.RETCTR_NF = #TLOADING_CONTROL3.RETCTR_NF  ) WHERE RETCTR_NF IS NOT NULL
UPDATE #TLOADING_CONTROL3 SET CTRSTS_CT = (SELECT CTRSTS_CT FROM BTRT..TCONTR C where C.CTR_NF = #TLOADING_CONTROL3.CTR_NF AND C.UWY_NF = #TLOADING_CONTROL3.UWY_NF ) WHERE CTR_NF IS NOT NULL
UPDATE #TLOADING_CONTROL3 SET RETCTRSTS_CT = (SELECT RETCTRSTS_CT FROM BRET..TRETCTR C where C.RETCTR_NF = #TLOADING_CONTROL3.RETCTR_NF AND C.RTY_NF = #TLOADING_CONTROL3.RTY_NF ) WHERE RETCTR_NF IS NOT NULL



INSERT INTO #TLOADING
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3
WHERE L3.RETCTR_NF IS NULL
  and L3.CTRSTS_CT in (14,16,19) 
  AND L3.MINUWY_NF = L3.UWY_NF
UNION  
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3
WHERE L3.RETCTR_NF IS NULL
  and L3.CTRSTS_CT in (3,14,16,19)  
  AND L3.MINUWY_NF != L3.UWY_NF 
  and L3.MAXUWY_NF = L3.UWY_NF  
UNION   
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3
WHERE L3.CTR_NF IS NULL
  and L3.RETCTRSTS_CT in (1,3) 
  AND L3.MINRTY_NF = L3.RTY_NF
UNION   
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3
WHERE L3.CTR_NF IS NULL
  and L3.RETCTRSTS_CT in (1,3)  
  AND L3.MINRTY_NF != L3.RTY_NF 
  and L3.MAXRTY_NF = L3.RTY_NF    
 UNION  
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3  
WHERE L3.CTR_NF IS NOT NULL
  AND L3.RETCTR_NF IS NOT NULL 
  AND L3.RETCTRSTS_CT in (1,2) 
  AND L3.CTRSTS_CT in (3,14,16) 
  AND L3.MINUWY_NF != L3.UWY_NF 
  and L3.MAXUWY_NF = L3.UWY_NF  
  UNION  
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3  
WHERE L3.CTR_NF IS NOT NULL
  AND L3.RETCTR_NF IS NOT NULL 
  AND L3.MINUWY_NF = L3.UWY_NF
  AND L3.RETCTRSTS_CT in (3) 
  AND L3.CTRSTS_CT in (16,14,19) 
UNION  
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3  
WHERE L3.CTR_NF IS NOT NULL
  AND L3.RETCTR_NF IS NOT NULL 
  AND L3.RETCTRSTS_CT in (3) 
  AND L3.CTRSTS_CT in (3,14,16,19) 
  AND L3.MINUWY_NF != L3.UWY_NF 
  and L3.MAXUWY_NF = L3.UWY_NF   
-- spira 98335
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3  
WHERE L3.CTR_NF IS NOT NULL
  AND L3.RETCTR_NF IS NOT NULL 
  AND L3.MINUWY_NF = L3.UWY_NF
  AND L3.RETCTRSTS_CT in (19) 
  AND L3.CTRSTS_CT in (16,14,19) 
UNION  
SELECT RETCTR_NF, RTY_NF, CTR_NF, UWY_NF, ESTCRB_CT 
FROM #TLOADING_CONTROL3 L3  
WHERE L3.CTR_NF IS NOT NULL
  AND L3.RETCTR_NF IS NOT NULL 
  AND L3.RETCTRSTS_CT in (19) 
  AND L3.CTRSTS_CT in (3,14,16,19) 
  AND L3.MINUWY_NF != L3.UWY_NF 
  and L3.MAXUWY_NF = L3.UWY_NF    
  


--Compare Number of contract in Temp Table and Table  
select @nbligne_TLOADING = count(*) FROM #TLOADING
if ( @nbligne_ESTIFRS17 != @nbligne_TLOADING )
  begin
    
  select @error_type = 3
  select @MsgAnomalie = 'Forbidden to change estimate type due to the Contract Status – Check Status Matrix '
  
  Select @AnomalieCode =  'Check contract status matrix'        
    INSERT INTO #TANO_TMP (CTR_NF, UWY_NF , ANO_CT ,ANOCODE_LL, ANO_LL)  
    SELECT distinct a.CTR_NF , A.UWY_nf , @error_type, @AnomalieCode , @MsgAnomalie  
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.CTR_NF = B.CTR_NF and A.UWY_NF = B.UWY_NF
    WHERE B.CTR_NF IS NULL and A.RETCTR_NF =null and A.CTR_NF is not null and a.CTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.CTR_NF and c.UWY_nf= A.UWY_NF ) 
    UNION
    SELECT distinct a.RETCTR_NF, a.RTY_NF ,@error_type, @AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.RETCTR_NF = B.RETCTR_NF and A.RTY_NF = B.RTY_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF =null and A.RETCTR_NF is not null and a.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.RETCTR_NF and c.UWY_nf= A.RTY_NF ) 
    UNION
    SELECT distinct a.CTR_NF , A.UWY_nf , @error_type, @AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.CTR_NF = B.CTR_NF and A.UWY_NF = B.UWY_NF and A.RETCTR_NF = B.RETCTR_NF and A.RTY_NF = B.RTY_NF
    WHERE B.CTR_NF IS NULL and A.RETCTR_NF is not null and A.CTR_NF is not null and a.CTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.CTR_NF and c.UWY_nf= A.UWY_NF ) 
    UNION
    SELECT distinct a.RETCTR_NF, a.RTY_NF ,@error_type, @AnomalieCode , @MsgAnomalie
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.RETCTR_NF = B.RETCTR_NF and A.RTY_NF = B.RTY_NF and A.CTR_NF = B.CTR_NF and A.UWY_NF = B.UWY_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF is not null and A.RETCTR_NF is not null and a.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.RETCTR_NF and c.UWY_nf= A.RTY_NF ) 
       
    
  end

/******************/

/*****************
-- Control 4: Check if Treaty LOB is LIFE or NOT  and Check if ledger is LIFE Ledger
******************/

Delete from #TLOADING  -- Clean TMP table for Reuse 
Delete from #TLOADING_LEDGER

Insert into  #TLOADING_LEDGER
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT, 
  0,0,0,0
from BTRAV..EST_IFRS17_PERIMETER p 
where p.RETCTR_NF != null
and p.CTR_NF  != null
and p.RETCTR_NF  in (select RETCTR_NF from BRET..TRETSEC rsec where rsec.RETCTR_NF = p.RETCTR_NF and rsec.RTY_NF = p.RTY_NF and rsec.LOB_CF in ('30','31') ) 
and p.CTR_NF in (Select CTR_NF from BTRT..TSECTION s where s.CTR_NF = p.CTR_NF and s.UWY_NF = p.UWY_NF and s.LOB_CF in ('30','31')   )
UNION
select 
  p.RETCTR_NF ,
  p.RTY_NF	,
	p.CTR_NF	,
	p.UWY_NF	,
	p.ESTCRB_CT, 
  0,0,0,0
from BTRAV..EST_IFRS17_PERIMETER p
where p.RETCTR_NF  in (select RETCTR_NF from BRET..TRETSEC rsec where rsec.RETCTR_NF = p.RETCTR_NF and rsec.RTY_NF = p.RTY_NF and  rsec.LOB_CF in ('30','31') ) 
and p.CTR_NF = null 
UNION
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT, 
  0,0,0,0
from BTRAV..EST_IFRS17_PERIMETER p
where p.CTR_NF  in (Select s.CTR_NF from BTRT..TSECTION s where s.CTR_NF = p.CTR_NF and s.UWY_NF = p.UWY_NF and s.LOB_CF in ('30','31') ) 
and p.RETCTR_NF = null 

Update #TLOADING_LEDGER SET CTRSSD_CF = ( SELECT SSD_CF FROM BTRT..TCONTR C where C.CTR_NF = #TLOADING_LEDGER.CTR_NF and C.UWY_NF = #TLOADING_LEDGER.UWY_NF ) where CTR_NF is not  null 
Update #TLOADING_LEDGER SET CTRESB_CF = ( SELECT ACCESB_CF FROM BTRT..TCONTR C where C.CTR_NF = #TLOADING_LEDGER.CTR_NF and C.UWY_NF = #TLOADING_LEDGER.UWY_NF ) where CTR_NF is not null 
Update #TLOADING_LEDGER SET RETSSD_CF = ( SELECT SSD_CF from BRET..TRETCTR R where R.RETCTR_NF = #TLOADING_LEDGER.RETCTR_NF and R.RTY_NF = #TLOADING_LEDGER.RTY_NF ) where RETCTR_NF is not null 
Update #TLOADING_LEDGER SET RETESB_CF = ( SELECT ESB_CF from BRET..TRETCTR R where R.RETCTR_NF = #TLOADING_LEDGER.RETCTR_NF and R.RTY_NF = #TLOADING_LEDGER.RTY_NF ) where RETCTR_NF is not null 

Insert into  #TLOADING
select 
RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT
  FROM #TLOADING_LEDGER L, BREF..TESB B
  where L.CTRSSD_CF = B.SSD_CF
  and L.CTRESB_CF = B.ESB_CF
  and L.RETSSD_CF = B.SSD_CF
  and L.RETESB_CF = B.ESB_CF
  and B.LIFE_CF = 1
UNION  
select 
RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT
  FROM #TLOADING_LEDGER L, BREF..TESB B
  where L.CTRSSD_CF = B.SSD_CF
  and L.CTRESB_CF = B.ESB_CF
  and L.RETSSD_CF = 0
  and B.LIFE_CF = 1
 UNION
 select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
	ESTCRB_CT
  FROM #TLOADING_LEDGER L, BREF..TESB B
  where L.CTRSSD_CF = 0
  and L.RETSSD_CF = B.SSD_CF
  and L.RETESB_CF = B.ESB_CF
  and B.LIFE_CF = 1
  


--Compare Number of contract in Temp Table and Table  
select @nbligne_TLOADING = count(*) FROM #TLOADING
if ( @nbligne_ESTIFRS17 != @nbligne_TLOADING )
  begin
    
  select @error_type = 4
  select @MsgAnomalie = '	Forbidden to change estimate type for non Life Treaty '
  
  Select @AnomalieCode =   'check contract in life domain'       
   INSERT INTO #TANO_TMP (CTR_NF, UWY_NF , ANO_CT ,ANOCODE_LL, ANO_LL)  
    SELECT distinct a.CTR_NF , A.UWY_nf , @error_type,@AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.CTR_NF = B.CTR_NF
    WHERE B.CTR_NF IS NULL and A.RETCTR_NF =null and A.CTR_NF is not null and a.CTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.CTR_NF and c.UWY_nf= A.UWY_NF ) 
   UNION
    SELECT distinct a.RETCTR_NF, a.RTY_NF ,@error_type,@AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.RETCTR_NF = B.RETCTR_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF =null and A.RETCTR_NF is not null and a.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.RETCTR_NF and c.UWY_nf= A.RTY_NF ) 
   UNION
    SELECT distinct a.CTR_NF , A.UWY_nf ,@error_type,@AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN BTRT..TSECTION S ON A.CTR_NF = S.CTR_NF and A.UWY_NF = S.UWY_NF
    WHERE  A.CTR_NF is not null and A.RETCTR_NF is not null and a.CTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.CTR_NF and c.UWY_nf= A.UWY_NF ) and S.LOB_CF not in ('30','31')
  UNION
    SELECT distinct a.RETCTR_NF, a.RTY_NF ,@error_type,@AnomalieCode , @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN BRET..TRETSEC RS ON A.RETCTR_NF = RS.RETCTR_NF and A.RTY_NF = RS.RTY_NF
    WHERE  A.CTR_NF is not null and A.RETCTR_NF is not null and a.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.RETCTR_NF and c.UWY_nf= A.RTY_NF ) and RS.LOB_CF not in ('30','31')
  end
/******************/

/*****************
-- Control 5 : Check if compatible with requested EST Type change  
******************/
Delete from #TLOADING
Delete from #TLOADING1
-- Loading Temp table with RETRO/ASSUME Treaty which exist in DB and LOB is 30,31 and New Estimate Type is (T,O,U,S)
Insert into #TLOADING1
select 
  P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	,
  '',
	P.ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER p , BTRT..TSECTION C
Where P.RETCTR_NF is null 
and P.CTR_NF = C.CTR_NF and p.UWY_NF = C.UWY_NF
and C.LOB_CF in ('30','31') and P.ESTCRB_CT in ('T','U','O','S')
Union
select 
  P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	,
  '',
	P.ESTCRB_CT  
from BTRAV..EST_IFRS17_PERIMETER p , BRET..TRETSEC C
Where P.CTR_NF is null 
and P.RETCTR_NF = C.RETCTR_NF and p.RTY_NF = C.RTY_NF
and C.LOB_CF in ('30','31') and P.ESTCRB_CT in ('T','U','O','S')
UNION
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
  '',
	ESTCRB_CT
from BTRAV..EST_IFRS17_PERIMETER p
where p.RETCTR_NF != null
and p.CTR_NF  != null
and p.RETCTR_NF  in (select RETCTR_NF from BRET..TRETSEC rsec where rsec.RETCTR_NF = p.RETCTR_NF and rsec.RTY_NF = p.RTY_NF and rsec.LOB_CF in ('30','31') ) 
and p.CTR_NF in (Select CTR_NF from BTRT..TSECTION s where s.CTR_NF = p.CTR_NF and s.UWY_NF = p.UWY_NF and s.LOB_CF in ('30','31')   ) and P.ESTCRB_CT in ('T','U','O','S')

--Update Temp table with present ESTCRB type
    
Update #TLOADING1  set OLD_ESTCRB_CT = (SELECT ESTCRB_CT from BTRT..TCONTR C where C.CTR_NF = #TLOADING1.CTR_NF and C.UWY_NF = #TLOADING1.UWY_NF ) where RETCTR_NF is  null 
Update #TLOADING1  set OLD_ESTCRB_CT = (SELECT ESTCRB_CT from BRET..TRETCTR R where R.RETCTR_NF = #TLOADING1.RETCTR_NF and R.RTY_NF = #TLOADING1.RTY_NF ) where RETCTR_NF is not null

  

--Removing contacts where ESTCRB type is not V,O,S,T,U
    -- Only Contract with type (V,O,S,T,U) can be update using this script
Delete from   #TLOADING1  where  OLD_ESTCRB_CT not in ('T','U','O','S','V')

--Copying  #TLOADING1 to new Temp Table #TLOADING after checking if the new ESTCRB_CT is allowed for the existing  ESTCRB_CT

Insert INTO #TLOADING
Select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	,
  NEW_ESTCRB_CT
From #TLOADING1
Where NEW_ESTCRB_CT = CASE OLD_ESTCRB_CT When 'V' Then 'T'
                                         When 'O' Then 'T'
                                         When 'S' Then 'U'
                                         When 'T' Then 'O'
                                         When 'U' Then 'S' END
                                         
                                         
  
--Compare Number of contract in Temp Table and Table  
select @nbligne_TLOADING = count(*) FROM #TLOADING
if ( @nbligne_ESTIFRS17 != @nbligne_TLOADING )
  begin
    
  select @error_type = 5
  select @MsgAnomalie = 'Forbidden to change estimate type from '
   Select @AnomalieCode ='check use case matrix'
            
           
            
            
   INSERT INTO #TANO_TMP (CTR_NF, UWY_NF , ANO_CT ,ANOCODE_LL, ANO_LL)  
    SELECT distinct a.CTR_NF , A.UWY_nf , @error_type,@AnomalieCode , ''
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.CTR_NF = B.CTR_NF and A.UWY_nf = B.UWY_nf
    WHERE B.CTR_NF IS NULL and A.RETCTR_NF =null and A.CTR_NF is not null and a.CTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.CTR_NF and c.UWY_nf= A.UWY_NF ) 
   UNION
    SELECT distinct a.RETCTR_NF, a.RTY_NF ,@error_type,@AnomalieCode , ''
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.RETCTR_NF = B.RETCTR_NF and A.RTY_NF = B.RTY_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF =null and A.RETCTR_NF is not null and a.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.RETCTR_NF and c.UWY_nf= A.RTY_NF ) 
   UNION
    SELECT distinct a.RETCTR_NF, a.RTY_NF ,@error_type,@AnomalieCode , ''
    FROM BTRAV..EST_IFRS17_PERIMETER A,
    BRET..TRETCTR T WHERE A.RETCTR_NF = T.RETCTR_NF and A.RTY_NF = T.RTY_NF
    AND A.CTR_NF is not null and A.RETCTR_NF is not null and  (T.ESTCRB_CT not in ('T','U','O','S','V') OR A.ESTCRB_CT not in ('T','U','O','S') OR  A.ESTCRB_CT != CASE T.ESTCRB_CT When 'V' Then 'T'
                                         When 'O' Then 'T'
                                         When 'S' Then 'U'
                                         When 'T' Then 'O'
                                         When 'U' Then 'S' END)
    UNION
    SELECT distinct a.CTR_NF, a.UWY_NF ,@error_type,@AnomalieCode , ''
    FROM BTRAV..EST_IFRS17_PERIMETER A,
    BTRT..TCONTR T WHERE A.CTR_NF = T.CTR_NF and A.UWY_NF = T.UWY_NF
    AND A.CTR_NF is not null and A.RETCTR_NF is not null and  (T.ESTCRB_CT not in ('T','U','O','S','V') OR A.ESTCRB_CT not in ('T','U','O','S') OR  A.ESTCRB_CT != CASE T.ESTCRB_CT When 'V' Then 'T'
                                         When 'O' Then 'T'
                                         When 'S' Then 'U'
                                         When 'T' Then 'O'
                                         When 'U' Then 'S' END)
    
    Update #TANO_TMP SET ANO_LL  = (@MsgAnomalie + ( SELECT Distinct ESTCRB_CT from BTRT..TCONTR T where T.CTR_NF = #TANO_TMP.CTR_NF and T.UWY_NF = #TANO_TMP.UWY_NF  ) + ' to '  + (SELECT Distinct ESTCRB_CT from BTRAV..EST_IFRS17_PERIMETER T where T.CTR_NF = #TANO_TMP.CTR_NF and T.UWY_NF = #TANO_TMP.UWY_NF ) ) where ctr_nf in (Select Distinct CTR_NF from BTRT..TCONTR C where C.CTR_NF = #TANO_TMP.CTR_NF and C.UWY_NF = #TANO_TMP.UWY_NF  ) and ANO_CT = 5
    Update #TANO_TMP SET ANO_LL  = (@MsgAnomalie + ( SELECT Distinct ESTCRB_CT from BRET..TRETCTR T where T.RETCTR_NF = #TANO_TMP.CTR_NF and T.RTY_NF = #TANO_TMP.UWY_NF  ) + ' to '  + (SELECT Distinct ESTCRB_CT from BTRAV..EST_IFRS17_PERIMETER T where T.RETCTR_NF = #TANO_TMP.CTR_NF and T.RTY_NF = #TANO_TMP.UWY_NF ) ) where ctr_nf in (Select Distinct RETCTR_NF from BRET..TRETCTR C where C.RETCTR_NF = #TANO_TMP.CTR_NF and C.RTY_NF = #TANO_TMP.UWY_NF  ) and ANO_CT = 5
  end
/*****************/
/*****************
-- Control 6 : Check Complete account for treaty 
******************/
-- spira 98335 - Control 6 removed
/******************/

/*****************
-- Control 7 : Test account frequency and estimate type quarterly 
******************/

Delete from #TLOADING

Insert into #TLOADING
select 
  P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	,
	P.ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER P, BTRT..TACCSEND C
Where P.RETCTR_NF is null 
and P.CTR_NF = C.CTR_NF 
AND C.ACCFRQ_CT  in (1,2)
UNION
select 
  P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	,
	P.ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER P,BRET..TRACCCOND R
Where P.CTR_NF is null 
and P.RETCTR_NF = R.RETCTR_NF 
AND R.ACCFRQ_CT  in (0,1,2)
UNION
select 
  P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	,
	P.ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER P,BRET..TRACCCOND R, BTRT..TACCSEND C
Where P.CTR_NF is not null
  and P.RETCTR_NF is not null
  and P.CTR_NF = C.CTR_NF 
  and P.RETCTR_NF = R.RETCTR_NF 
  AND C.ACCFRQ_CT  in (1,2)
  AND R.ACCFRQ_CT  in (0,1,2)

 --Compare Number of contract in Temp Table and Table  
select @nbligne_TLOADING = count(*) FROM #TLOADING
  
  if ( @nbligne_ESTIFRS17 != @nbligne_TLOADING )
  begin
    
  select @error_type = 7
  select @MsgAnomalie = 'Forbidden to change the estimates type because the account frequency is not Monthly or Quarterly  '
  
  Select @AnomalieCode = 'Test account frequency' 
    INSERT INTO #TANO_TMP (CTR_NF, UWY_NF , ANO_CT ,ANOCODE_LL, ANO_LL)  
    SELECT a.CTR_NF , A.UWY_nf , @error_type, @AnomalieCode, @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.CTR_NF = B.CTR_NF
    WHERE B.CTR_NF IS NULL and A.RETCTR_NF =null and A.CTR_NF is not null
    and a.CTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.CTR_NF and c.UWY_nf= A.UWY_NF )
    UNION
    SELECT a.RETCTR_NF, a.RTY_NF ,@error_type, @AnomalieCode, @MsgAnomalie  
    FROM BTRAV..EST_IFRS17_PERIMETER A
    LEFT JOIN #TLOADING B ON A.RETCTR_NF = B.RETCTR_NF
    WHERE B.RETCTR_NF IS NULL and A.CTR_NF =null and A.RETCTR_NF is not null
    and a.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = A.RETCTR_NF and c.UWY_nf= A.RTY_NF )
    UNION
    SELECT P.CTR_NF , P.UWY_nf ,@error_type,@AnomalieCode, @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER P,BTRT..TACCSEND C
    Where  P.CTR_NF = C.CTR_NF 
      AND  P.CTR_NF is not null and P.RETCTR_NF is not null
      AND C.ACCFRQ_CT not in (1,2)
      and P.CTR_NF not in (select CTR_NF from #TANO_TMP A where A.CTR_NF = P.CTR_NF and A.UWY_nf= P.UWY_NF )
    UNION
    SELECT P.RETCTR_NF, P.RTY_NF ,@error_type, @AnomalieCode, @MsgAnomalie  
    FROM BTRAV..EST_IFRS17_PERIMETER P,BRET..TRACCCOND R
    WHERE  P.CTR_NF is not null and P.RETCTR_NF is not null
      and P.RETCTR_NF = R.RETCTR_NF 
      AND R.ACCFRQ_CT not in (0,1,2)
      and P.RETCTR_NF not in (select CTR_NF from #TANO_TMP c where c.CTR_NF = P.RETCTR_NF and c.UWY_nf= P.RTY_NF )
  end
/***************************/

/*****************
-- Control 8 : Test complete account and automatic update
******************/
select l.*  into #TLIFDRI from best..tlifdri l, btrav..EST_IFRS17_PERIMETER p
where l.ctr_nf = p.ctr_nf
group by l.ctr_nf, l.sec_nf, l.uwy_nf
having l.lstupd_d = max (l.lstupd_d) 
union
select l.*  from best..tlifdri l, btrav..EST_IFRS17_PERIMETER p
where l.ctr_nf = p.retctr_nf
group by l.ctr_nf, l.sec_nf, l.uwy_nf
having l.lstupd_d = max (l.lstupd_d) 

Delete from #TLOADING

Insert into #TLOADING
select 
  P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	,
	P.ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER P
Where P.RETCTR_NF is null and not exists ( select 1 from #TLIFDRI where p.ctr_nf = ctr_nf  and autupd_b = 0 and comacc_b = 1)
UNION
select 
  P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	,
	P.ESTCRB_CT 
from BTRAV..EST_IFRS17_PERIMETER P
Where P.RETCTR_NF is not null -- spira 98335 control on retro is removed and not exists ( select 1 from #TLIFDRI where p.retctr_nf = ctr_nf  and autupd_b = 0 and comacc_b = 1)

 --Compare Number of contract in Temp Table and Table  
select @nbligne_TLOADING = count(*) FROM #TLOADING

  if ( @nbligne_ESTIFRS17 != @nbligne_TLOADING )
  begin
  select @error_type = 8
  select @MsgAnomalie = 'Forbidden to change the estimates type because the Automatic update is not ticked'
  
  Select @AnomalieCode = 'Test complete account and automatic update' 
    INSERT INTO #TANO_TMP (CTR_NF, UWY_NF , ANO_CT ,ANOCODE_LL, ANO_LL)  

    SELECT distinct P.CTR_NF , P.UWY_nf ,@error_type,@AnomalieCode, @MsgAnomalie 
    FROM BTRAV..EST_IFRS17_PERIMETER P,#TLIFDRI L
		Where P.CTR_NF = L.CTR_NF 
		--AND   P.UWY_NF = L.UWY_NF
		AND   L.COMACC_B = 1
		AND   L.AUTUPD_B = 0
    UNION
    SELECT distinct P.RETCTR_NF, P.RTY_NF ,@error_type, @AnomalieCode, @MsgAnomalie
    FROM BTRAV..EST_IFRS17_PERIMETER P,#TLIFDRI L
		Where P.RETCTR_NF = L.CTR_NF 
		--AND   P.RTY_NF = L.UWY_NF
		AND   L.COMACC_B = 1
		AND   L.AUTUPD_B = 0
  end
  
/***************************/

select @nbligne_TANO = count(*) FROM #TANO_TMP
if (@nbligne_TANO != 0)
 Begin 
--Delete from  BTRAV..EST_IFRS17_PERIMETER
 select 
    CTR_NF  ,
    UWY_NF	,
    2 as STEP,
    ANOCODE_LL,
    ANO_LL
 from #TANO_TMP
 
 END
 


if object_id('#TLOADING') is not null drop Table #TLOADING 
if object_id('#TLOADING1') is not null drop Table #TLOADING1




go 
EXEC sp_procxmode 'PsEST_IFRS17_02_O2', 'unchained'
go

IF OBJECT_ID('PsEST_IFRS17_02_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_02_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_02_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_02_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_02_O2 TO GDBBATCH
go
