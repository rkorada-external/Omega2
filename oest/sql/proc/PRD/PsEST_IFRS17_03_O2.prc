USE BEST
go
IF OBJECT_ID('PsEST_IFRS17_03_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsEST_IFRS17_03_O2
    IF OBJECT_ID('PsEST_IFRS17_03_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsEST_IFRS17_03_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsEST_IFRS17_03_O2 >>>'
END
go
create procedure PsEST_IFRS17_03_O2 
AS
/***************************************************
Domain            : Estimate
Base              : BEST
Version           : 1
Author            : Riyadh
Creation date     : 09/07/2018

Description       : 
_________________
Modification: MOD1 
Author: 
Date: 
Description: 
_________________
*/


declare
        @error_type   int,
        @MsgAnomalie    varchar(120),
        @MsgAnomalie1    varchar(120),
        @AnomalieCode    varchar(120),
    @nbligne_ESTIFRS17 int,    /* nbre lignes de la table utilisateurs en entrée */
    @nbligne_TLOADING int,    /* nbre lignes en sortie de traitement */
    @nbligne_TANO int    /* nbre lignes avec error */

CREATE TABLE #TLOADING
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
	OLD_ESTCRB_CT char     NOT NULL,
  New_ESTCRB_CT char     NOT NULL
)

CREATE TABLE #TLOADING1
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
  OLD_ESTCRB_CT char     NOT NULL,
	NEW_ESTCRB_CT char     NOT NULL
)

CREATE TABLE #TLOADING2
(
  RETCTR_NF UCTR_NF			NULL,
  RTY_NF	UUWY_NF				NULL,
	CTR_NF		UCTR_NF			NULL,
	UWY_NF	UUWY_NF				NULL,
  OLD_ESTCRB_CT char     NOT NULL,
	NEW_ESTCRB_CT char     NOT NULL
)

--Case 1 : When Retro Contract is given
-- Step 1 : Search the list of Assumed treaties linked to a Retrocession Treaty for internal and automatic Retrocession, excepted for Life Plan contracts
 
Insert into #TLOADING
select 
P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	,
	R.ESTCRB_CT,
  P.ESTCRB_CT
from BTRAV..EST_IFRS17_PERIMETER  P, BRET..TRETCTR R
where P.RETCTR_NF = R.RETCTR_NF and P.RTY_NF  = R.RTY_NF 
  and P.RETCTR_NF is not null 
  and R.ESTCRB_CT !='S'  
  and (P.RETCTR_NF in (select RETCTR_NF from BRET..TSSDACTR S where S.RETCTR_NF = P.RETCTR_NF and S.RTY_NF = P.RTY_NF)
  or P.RETCTR_NF in (select RETCTR_NF from BRET..TCESSION S where S.RETCTR_NF = P.RETCTR_NF and S.RTY_NF = P.RTY_NF))
  
Insert into #TLOADING1
Select 
Distinct S.RETCTR_NF,  
S.RTY_NF	,
S.CTR_NF	,
S.UWY_NF	,
L.OLD_ESTCRB_CT,
L.NEW_ESTCRB_CT
From BRET..TSSDACTR S , #TLOADING L
where S.RETCTR_NF = L.RETCTR_NF 
  and S.RTY_NF = L.RTY_NF 
  GROUP BY S.RETCTR_NF, S.RTY_NF	

Insert into #TLOADING1
Select 
Distinct S.RETCTR_NF,  
S.RTY_NF	,
S.CTR_NF	,
S.UWY_NF	,
L.OLD_ESTCRB_CT,
L.NEW_ESTCRB_CT
From BRET..TCESSION S , #TLOADING L
where S.RETCTR_NF = L.RETCTR_NF 
  and S.RTY_NF = L.RTY_NF 
  and S.CESSTS_CF = '01'
  GROUP BY S.RETCTR_NF, S.RTY_NF

--LeveL 0 

Insert into #TLOADING1
Select
Distinct C.RETCTR_NF,  
C.RTY_NF	,
C.CTR_NF	,
C.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT
from BRET..TCESSION C,  #TLOADING1 L1 
where C.CTR_NF = L1.CTR_NF 
  and C.UWY_NF = L1.UWY_NF 
  

  
--Level 1

Insert into #TLOADING1 
Select C.RETCTR_NF,  
C.RTY_NF	,
C.CTR_NF	,
C.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TCESSION C, #TLOADING1 L1 
where C.RETCTR_NF = L1.RETCTR_NF and c.RTY_NF = L1.RTY_NF
      and  C.CESSTS_CF = '01'  
      and C.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = C.RETCTR_NF and T.RTY_NF = C.RTY_NF and T.CTR_NF = C.CTR_NF and T.UWY_NF = C.UWY_NF )
UNION
Select C.RETCTR_NF,  
C.RTY_NF	,
C.CTR_NF	,
C.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TCESSION C, #TLOADING1 L1 where C.CTR_NF = L1.CTR_NF and C.UWY_NF = L1.UWY_NF  
and  C.CESSTS_CF = '01'  
and C.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = C.RETCTR_NF and T.RTY_NF = C.RTY_NF and T.CTR_NF = C.CTR_NF and T.UWY_NF = C.UWY_NF )
UNION
Select S.RETCTR_NF,  
S.RTY_NF	,
S.CTR_NF	,
S.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TSSDACTR S, #TLOADING1 L1 where S.RETCTR_NF = L1.RETCTR_NF and S.RTY_NF = L1.RTY_NF
and S.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = S.RETCTR_NF and T.RTY_NF = S.RTY_NF and T.CTR_NF = s.CTR_NF and T.UWY_NF = S.UWY_NF )
UNION
Select S.RETCTR_NF,  
S.RTY_NF	,
S.CTR_NF	,
S.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TSSDACTR S, #TLOADING1 L1 where S.CTR_NF = L1.CTR_NF and S.UWY_NF = L1.UWY_NF 
and S.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = S.RETCTR_NF and T.RTY_NF = S.RTY_NF and T.CTR_NF = s.CTR_NF and T.UWY_NF = S.UWY_NF )
 

--Level 2

Insert into #TLOADING1 
Select C.RETCTR_NF,  
C.RTY_NF	,
C.CTR_NF	,
C.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TCESSION C, #TLOADING1 L1 
where C.RETCTR_NF = L1.RETCTR_NF and c.RTY_NF = L1.RTY_NF
      and  C.CESSTS_CF = '01'  
      and C.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = C.RETCTR_NF and T.RTY_NF = C.RTY_NF and T.CTR_NF = C.CTR_NF and T.UWY_NF = C.UWY_NF )
UNION
Select C.RETCTR_NF,  
C.RTY_NF	,
C.CTR_NF	,
C.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TCESSION C, #TLOADING1 L1 where C.CTR_NF = L1.CTR_NF and C.UWY_NF = L1.UWY_NF  
    and  C.CESSTS_CF = '01'  
and C.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = C.RETCTR_NF and T.RTY_NF = C.RTY_NF and T.CTR_NF = C.CTR_NF and T.UWY_NF = C.UWY_NF )
UNION
Select S.RETCTR_NF,  
S.RTY_NF	,
S.CTR_NF	,
S.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TSSDACTR S, #TLOADING1 L1 where S.RETCTR_NF = L1.RETCTR_NF and S.RTY_NF = L1.RTY_NF
and S.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = S.RETCTR_NF and T.RTY_NF = S.RTY_NF and T.CTR_NF = s.CTR_NF and T.UWY_NF = S.UWY_NF )
UNION
Select S.RETCTR_NF,  
S.RTY_NF	,
S.CTR_NF	,
S.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TSSDACTR S, #TLOADING1 L1 where S.CTR_NF = L1.CTR_NF and S.UWY_NF = L1.UWY_NF 
and S.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = S.RETCTR_NF and T.RTY_NF = S.RTY_NF and T.CTR_NF = s.CTR_NF and T.UWY_NF = S.UWY_NF )


--Level 3

Insert into #TLOADING1 
Select C.RETCTR_NF,  
C.RTY_NF	,
C.CTR_NF	,
C.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TCESSION C, #TLOADING1 L1 
where C.RETCTR_NF = L1.RETCTR_NF and c.RTY_NF = L1.RTY_NF
      and  C.CESSTS_CF = '01'    
      and C.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = C.RETCTR_NF and T.RTY_NF = C.RTY_NF and T.CTR_NF = C.CTR_NF and T.UWY_NF = C.UWY_NF )
UNION
Select C.RETCTR_NF,  
C.RTY_NF	,
C.CTR_NF	,
C.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TCESSION C, #TLOADING1 L1 where C.CTR_NF = L1.CTR_NF and C.UWY_NF = L1.UWY_NF  
and  C.CESSTS_CF = '01'  
and C.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = C.RETCTR_NF and T.RTY_NF = C.RTY_NF and T.CTR_NF = C.CTR_NF and T.UWY_NF = C.UWY_NF )
UNION
Select S.RETCTR_NF,  
S.RTY_NF	,
S.CTR_NF	,
S.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TSSDACTR S, #TLOADING1 L1 where S.RETCTR_NF = L1.RETCTR_NF and S.RTY_NF = L1.RTY_NF
and S.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = S.RETCTR_NF and T.RTY_NF = S.RTY_NF and T.CTR_NF = s.CTR_NF and T.UWY_NF = S.UWY_NF )
UNION
Select S.RETCTR_NF,  
S.RTY_NF	,
S.CTR_NF	,
S.UWY_NF	,
L1.OLD_ESTCRB_CT,
L1.NEW_ESTCRB_CT from  BRET..TSSDACTR S, #TLOADING1 L1 where S.CTR_NF = L1.CTR_NF and S.UWY_NF = L1.UWY_NF 
and S.RETCTR_NF not in (select RETCTR_NF from #TLOADING1 T  where T.RETCTR_NF = S.RETCTR_NF and T.RTY_NF = S.RTY_NF and T.CTR_NF = s.CTR_NF and T.UWY_NF = S.UWY_NF )

-- Adding Assumed Treaty to RETRO CHAIN TREATIES
Insert into #TLOADING_STEP3
select 
P.RETCTR_NF ,
  P.RTY_NF	,
	P.CTR_NF	,
	P.UWY_NF	
from BTRAV..EST_IFRS17_PERIMETER  P
where P.RETCTR_NF is null
UNION
select 
  RETCTR_NF ,
  RTY_NF	,
	CTR_NF	,
	UWY_NF	
from #TLOADING1



if object_id('#TLOADING') is not null drop Table #TLOADING 


go 
EXEC sp_procxmode 'PsEST_IFRS17_03_O2', 'unchained'
go

IF OBJECT_ID('PsEST_IFRS17_03_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsEST_IFRS17_03_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsEST_IFRS17_03_O2 >>>'
go
GRANT EXECUTE ON PsEST_IFRS17_03_O2 TO GOMEGA
go
GRANT EXECUTE ON PsEST_IFRS17_03_O2 TO GDBBATCH
go


