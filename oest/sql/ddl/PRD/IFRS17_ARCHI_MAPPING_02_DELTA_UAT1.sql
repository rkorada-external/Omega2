
USE BEST
go


-----------------------------------------------------------------------------------------------------------
--[001] 12/12/2019 JYP/Lahcen/Arnaud : SPIRA 77477/82888  : new chain ESFD3770 bugfix ESFD3630 EST_FSEGPATTERN_CSF
--[002] 17/12/2019 Belaid/JYP : SPIRA 80491: new mapping ESID8700 EST_IADVPERICASE
--[003] 20/12/2019 Arnaud/Maxence/JYP: SPIRA 77477 : corrections mapping ESFD3770  
--[004] 10/01/2020 Belaid/Lahcen/JYP : SPIRA 80491 82884 81645: add ESPD8700/EPO_OIADVPERICASE , SPIRA 82884 81645 EPO_FTECLEDA 
--[005] 14/01/2020 spira 83904 : mehdi ask to replace  param_Context_id by TYPINV
--[006] 14/01/2020 Lilian/JYP : SPIRA 81788: add closings BookingPOSE/POCE 
--[007] 14/01/2020 CAP Cyril/JYP: SPIRA 77472 new mapping ESFD3790
--[008] 21/01/2020 Martin/JYP: SPIRA 71539 : add mapping FUTURE Retro OVERRIDE 
--[009] 29/01/2020 Linh request : SPIRA 79100 ESFD3730 : add EST_IADPERICASE_DUMMY variable
--[010] 31/01/2020 Charles request : SPIRA 82557 add I17G_CSF_ALL_INI EST_FCURQUOT_TXT et EST_FCURQUOT_TXT
--[011] 04/02/2020 Roger: SPIRA 65656 et [81496] : add ESFD2220/EPO_FCTREST/I17G_CSF_ALL_INI et I17G_FUT_ALL_INI
-----------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------
print '------>>>>  ESFD3770 '

delete BEST..TI17PERMFIL where IDF_CT = 'I17G_CSM_AMR_STD'
delete BEST..TI17REQCHN where IDF_CT = 'I17G_CSM_AMR_STD'
delete BEST..TI17FNC where IDF_CT = 'I17G_CSM_AMR_STD'
delete BEST..TI17CHN where CHAIN_CT = 'ESFD3770'


insert into BEST..TI17FNC values ('I17G_CSM_AMR_STD','IFRS17 - CSM/LC pattern calculation')

insert into BEST..TI17CHN values ('ESFD3770','IFRS17 - CSM/LC pattern calculation')

insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_FPRMLOA','${DFILP}/${PCH}ESID2210_FPRMLOA_EBSSO.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_DLDGTAA','${DFILP}/${PCH}ESID2220_DLDGTAASIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')

insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','ESF_CSM_LC_AMORT_PATTERN','${DFILP}/${ENV_PREFIX}_ESFD3770_I17G_CSM_AMR_STD_CSM_LC_AMORT_PATTERN_${PARM_ICLODAT_D}.dat','O','')


insert into BEST..TI17REQCHN values ('I17GMINV','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMINVB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOS','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOSB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOC','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOCB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQINV','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQINVB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOS','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOSB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOC','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOCB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYINV','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYINVB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOS','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOSB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOC','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOCB','ESFD3770','I17G_CSM_AMR_STD','')

GO

print '------>>>>  end ESFD3770 OK '
-----------------------------------------------------------------------------------------------------------


print '------>>>>  bugfix I17G_IEX_ALL_INI  EST_FSEGPATTERN_CSF '

UPDATE BEST..TI17PERMFIL 
SET PATHPATTRN_LL= '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF.dat' 
WHERE PERMFIL_CT = 'EST_FSEGPATTERN_CSF'
AND IDF_CT = 'I17G_IEX_ALL_INI'
go

print '------>>>>  end  I17G_IEX_ALL_INI  EST_FSEGPATTERN_CSF OK '

-----------------------------------------------------------------------------------------------------------

---------------------------------------------------------------
print '------>>>>  new mapping ESID8700 EST_IADVPERICASE '

delete BEST..TI17PERMFIL where IDF_CT = 'ESID8700' and  permfil_ct = 'EST_IADVPERICASE'
INSERT INTO BEST..TI17PERMFIL values ('ESID8700','EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')

GO
print '------>>>>  end mapping ESID8700 EST_IADVPERICASE OK '
---------------------------------------------------------------


---------------------------------------------------------------
print '------>>>>  bugfix ESF_GTSII_CSM_CASHFLOW '
delete BEST..TI17PERMFIL where IDF_CT='I17G_SII_ALL_STD' and PERMFIL_CT='ESF_GTSII_CSM_CASHFLOW'

insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_CSM_CASHFLOW','${DFILP}/${PCH}ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')

GO
print '------>>>>  end bugfix ESF_GTSII_CSM_CASHFLOW OK '
---------------------------------------------------------------


---------------------------------------------------------------
print '------>>>>  add ESPD8700/EPO_OIADVPERICASE '
delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_OIADVPERICASE'
and IDF_CT = 'ESPD8700'

insert into BEST..TI17PERMFIL values ('ESPD8700',  'EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')
go
print '------>>>>  end ESPD8700/EPO_OIADVPERICASE '
----------------------------------------------------------------

---------------------------------------------------------------
print '------>>>>  spira SPIRA : 82884 81645 EPO_FTECLEDA '

delete from BEST..TI17PERMFIL where idf_ct in ('I17G_IEX_ALL_STD', 'I17G_IEX_ALL_INI') and PERMFIL_CT='EPO_DLDGTAAPNAE' 

delete from BEST..TI17PERMFIL where idf_ct in ('I17G_IEX_ALL_STD', 'I17G_IEX_ALL_INI') and PERMFIL_CT='EPO_FTECLEDA' 
 
insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_STD', 'EPO_FTECLEDA', '${DFILP}/${PCH}ESPD3800_FTECLEDA${TYPEINV0}.dat', 'I') 

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_INI', 'EPO_FTECLEDA', '${DFILP}/empty.dat', 'I')

go
print '------>>>> end spira SPIRA : 82884 81645 EPO_FTECLEDA '
---------------------------------------------------------------


print '------>>>> spira 83904 : mehdi ask to replace  param_Context_id'

update  BEST..TI17PERMFIL 
set PATHPATTRN_LL = str_replace(PATHPATTRN_LL,'param_Context_id', 'TYPEINV' )
where   pathpattrn_ll like '%param_Context_id%'
and permfil_ct in (
'EPO_DLEIFTECLEDSIIEI_POOL',
'EPO_GTEP_POOL',
'EPO_DLEIFTECLEDSIIEI',
'ESF_FEXPRAT',
'ESF_FRARAT' ,
'ESF_FEXPRAT_PREVQ')


update  BEST..TI17PERMFIL set PATHPATTRN_LL = '${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POC.dat'
where permfil_ct = 'EPO_DLEIFTECLEDSIIEI' and idf_ct = 'ESPD2050_POCE'

update  BEST..TI17PERMFIL set PATHPATTRN_LL = '${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POS.dat'
where permfil_ct = 'EPO_DLEIFTECLEDSIIEI' and idf_ct = 'ESPD2050_POSE'

GO
print '------>>>> end spira 83904 : mehdi ask to replace  param_Context_id'
---------------------------------------------------------------




print '------>>>> delete BookingPOSE '

delete from BEST..TIfrs17Plan
where requestId = 'BookingPOSE'

delete from BEST..TIfrs17ContextRequest
where requestId = 'BookingPOSE'

delete from BEST..TIfrs17Request
where requestId = 'BookingPOSE'

delete BEST..TI17REQCHN
where reqcod_ct = 'BookingPOSE'

delete BEST..TI17PERMFIL
where IDF_CT like '%_BookingPOSE'

delete from BEST..TI17FNC 
where IDF_CT like '%_BookingPOSE'

GO

print '------>>>> End delete BookingPOSE '


print '------>>>> Insert BookingPOSE part 1'

/*** BEST..TIfrs17Request ***/
INSERT INTO BEST..TIfrs17Request
SELECT 
	str_replace (requestId, 'POSE', 'BookingPOSE') AS requestId,
 'Comptabilisation Post-omega Social EBS4' AS comment
FROM 
	BEST..TIfrs17Request
WHERE 
	requestId = 'POSE'
	
	
/*** BEST..TIfrs17ContextRequest ***/
INSERT INTO BEST..TIfrs17ContextRequest
SELECT 
	str_replace(requestId, 'POSE', 'BookingPOSE') AS requestId,
  contextId,
  'Comptabilisation Post-omega Social EBS4' AS comment
FROM 
	BEST..TIfrs17ContextRequest
WHERE 
	requestId = 'POSE'


insert into [BEST..TI17FNC]([IDF_CT],[IDF_LL]) 
select str_replace(idf_ct,'POSE','BookingPOSE') , idf_ll  from  BEST..TI17FNC
where 
(	IDF_CT  = 'ESID2210_POSE' or
	IDF_CT  = 'ESID2220_POSE' or
	IDF_CT  = 'ESFD2220_POSE' or
	IDF_CT  = 'ESPD2570_POSE' or
	IDF_CT  = 'ESPD3610_POSE' or
	IDF_CT  = 'ESPD3620_POSE' or
	IDF_CT  = 'ESPD3630_POSE' or
	IDF_CT  = 'ESPD3640_POSE' or
  IDF_CT  = 'ESPD8000_POSE' or
	IDF_CT  = 'ESPD2050_POSE' 
 )

GO

insert into [BEST..TIfrs17Plan]([requestId],[chain],[planId],[comment]) 
select 'BookingPOSE' , chain,planId , 'Booking POSE'  from BEST..TIfrs17Plan
where requestId = 'POSE'
and chain in ('ESID2210',
              'ESID2220',
              'ESPD2570',
              'ESPD3610',
              'ESPD3620',
              'ESPD3630',
              'ESPD3640' )



insert into BEST..TI17REQCHN
select 'BookingPOSE',chain_ct,str_replace(idf_ct,'POSE','BookingPOSE'),'BookingPOSE' from BEST..TI17REQCHN
where reqcod_ct = 'POSE'
and chain_ct in ('ESID2210',
              'ESID2220',
              'ESPD2570',
              'ESPD3610',
              'ESPD3620',
              'ESPD3630',
              'ESPD3640',
              'ESFD2220',
              'ESPD2220',
              'ESPD2050',
              'ESPD8000')

GO

print '------>>>> End BookingPOSE part 1'


print '------>>>> Insert BookingPOSE part 2 perm files '

insert into BEST..TI17PERMFIL
select str_replace(idf_ct,'POSE','BookingPOSE') , PERMFIL_CT , pathpattrn_ll,IO,perm_ll from  BEST..TI17PERMFIL
where 
(	IDF_CT  = 'ESID2210_POSE' or
	IDF_CT  = 'ESID2220_POSE' or
	IDF_CT  = 'ESPD2570_POSE' or
	IDF_CT  = 'ESPD3610_POSE' or
	IDF_CT  = 'ESPD3620_POSE' or
	IDF_CT  = 'ESPD3630_POSE' or
	IDF_CT  = 'ESPD3640_POSE' or
	IDF_CT  = 'ESPD8000_POSE' or
	IDF_CT  = 'ESPD2050_POSE' 	
 )



GO

print '------>>>> End  BookingPOSE part 2 perm files '



print '------>>>> delete BookingPOCE '

delete from BEST..TIfrs17Plan
where requestId = 'BookingPOCE'

delete from BEST..TIfrs17ContextRequest
where requestId = 'BookingPOCE'

delete from BEST..TIfrs17Request
where requestId = 'BookingPOCE'

delete BEST..TI17REQCHN
where reqcod_ct = 'BookingPOCE'

delete BEST..TI17PERMFIL
where IDF_CT like '%_BookingPOCE'

delete from BEST..TI17FNC 
where IDF_CT like '%_BookingPOCE'

GO

print '------>>>> End delete BookingPOCE '


print '------>>>> Insert BookingPOCE part 1'

/*** BEST..TIfrs17Request ***/
INSERT INTO BEST..TIfrs17Request
SELECT 
	str_replace (requestId, 'POCE', 'BookingPOCE') AS requestId,
 'Comptabilisation Post-omega Conso EBS4' AS comment
FROM 
	BEST..TIfrs17Request
WHERE 
	requestId = 'POCE'
	
	
/*** BEST..TIfrs17ContextRequest ***/
INSERT INTO BEST..TIfrs17ContextRequest
SELECT 
	str_replace(requestId, 'POCE', 'BookingPOCE') AS requestId,
  contextId,
  'Comptabilisation Post-omega Conso EBS4' AS comment
FROM 
	BEST..TIfrs17ContextRequest
WHERE 
	requestId = 'POCE'

insert into [BEST..TI17FNC]([IDF_CT],[IDF_LL]) 
select str_replace(idf_ct,'POCE','BookingPOCE') , idf_ll  from  BEST..TI17FNC
where 
(	IDF_CT  = 'ESID2210_POCE' or
	IDF_CT  = 'ESID2220_POCE' or
	IDF_CT  = 'ESFD2220_POCE' or
	IDF_CT  = 'ESPD2570_POCE' or
	IDF_CT  = 'ESPD3610_POCE' or
	IDF_CT  = 'ESPD3620_POCE' or
	IDF_CT  = 'ESPD3630_POCE' or
	IDF_CT  = 'ESPD3640_POCE' or
  IDF_CT  = 'ESPD8000_POCE' or
	IDF_CT  = 'ESPD2050_POCE' 
 )

GO

insert into [BEST..TIfrs17Plan]([requestId],[chain],[planId],[comment]) 
select 'BookingPOCE' , chain,planId , 'Booking POCE'  from BEST..TIfrs17Plan
where requestId = 'POCE'
and chain in ('ESID2210',
              'ESID2220',
              'ESPD2570',
              'ESPD3610',
              'ESPD3620',
              'ESPD3630',
              'ESPD3640' )



insert into BEST..TI17REQCHN
select 'BookingPOCE',chain_ct,str_replace(idf_ct,'POCE','BookingPOCE'),'BookingPOCE' from BEST..TI17REQCHN
where reqcod_ct = 'POCE'
and chain_ct in ('ESID2210',
              'ESID2220',
              'ESPD2570',
              'ESPD3610',
              'ESPD3620',
              'ESPD3630',
              'ESPD3640',
              'ESFD2220',
              'ESPD2220',
              'ESPD2050',
              'ESPD8000')

GO

print '------>>>> End BookingPOCE part 1'


print '------>>>> Insert BookingPOCE part 2 perm files '

insert into BEST..TI17PERMFIL
select str_replace(idf_ct,'POCE','BookingPOCE') , PERMFIL_CT , pathpattrn_ll,IO,perm_ll from  BEST..TI17PERMFIL
where 
(	IDF_CT  = 'ESID2210_POCE' or
	IDF_CT  = 'ESID2220_POCE' or
	IDF_CT  = 'ESPD2570_POCE' or
	IDF_CT  = 'ESPD3610_POCE' or
	IDF_CT  = 'ESPD3620_POCE' or
	IDF_CT  = 'ESPD3630_POCE' or
	IDF_CT  = 'ESPD3640_POCE' or
	IDF_CT  = 'ESPD8000_POCE' or
	IDF_CT  = 'ESPD2050_POCE' 	
 )

GO

print '------>>>> End  BookingPOCE part 2 perm files '



print '------>>>> delete BookingPOSEAnnuel '

delete from BEST..TIfrs17Plan
where requestId = 'BookingPOSEAnnuel'

delete from BEST..TIfrs17ContextRequest
where requestId = 'BookingPOSEAnnuel'

delete from BEST..TIfrs17Request
where requestId = 'BookingPOSEAnnuel'

delete BEST..TI17REQCHN
where reqcod_ct = 'BookingPOSEAnnuel'

delete BEST..TI17PERMFIL
where IDF_CT like '%_BookingPOSEAnnuel'

delete from BEST..TI17FNC 
where IDF_CT like '%_BookingPOSEAnnuel'

GO

print '------>>>> End delete BookingPOSEAnnuel '


print '------>>>> Insert BookingPOSEAnnuel part 1'

/*** BEST..TIfrs17Request ***/
INSERT INTO BEST..TIfrs17Request
SELECT 
	str_replace (requestId, 'POSE', 'BookingPOSEAnnuel') AS requestId,
 'Compta technique annuelle' AS comment
FROM 
	BEST..TIfrs17Request
WHERE 
	requestId = 'POSE'
	
	
/*** BEST..TIfrs17ContextRequest ***/
INSERT INTO BEST..TIfrs17ContextRequest
SELECT 
	str_replace(requestId, 'POSE', 'BookingPOSEAnnuel') AS requestId,
  contextId,
  'Compta technique annuelle' AS comment
FROM 
	BEST..TIfrs17ContextRequest
WHERE 
	requestId = 'POSE'
	
	
insert into [BEST..TI17FNC]([IDF_CT],[IDF_LL]) 
select str_replace(idf_ct,'POSE','BookingPOSEAnnuel') , idf_ll  from  BEST..TI17FNC
where 
(	IDF_CT  = 'ESID2210_POSE' or
	IDF_CT  = 'ESID2220_POSE' or
	IDF_CT  = 'ESFD2220_POSE' or
	IDF_CT  = 'ESPD2570_POSE' or
	IDF_CT  = 'ESPD3610_POSE' or
	IDF_CT  = 'ESPD3620_POSE' or
	IDF_CT  = 'ESPD3630_POSE' or
	IDF_CT  = 'ESPD3640_POSE' or
  IDF_CT  = 'ESPD8000_POSE' or
	IDF_CT  = 'ESPD2050_POSE' 
 )

GO

insert into [BEST..TIfrs17Plan]([requestId],[chain],[planId],[comment]) 
select 'BookingPOSEAnnuel' , chain,planId , 'Booking POSE Annuel'  from BEST..TIfrs17Plan
where requestId = 'POSE'
and chain in ('ESID2210',
              'ESID2220',
              'ESPD2570',
              'ESPD3610',
              'ESPD3620',
              'ESPD3630',
              'ESPD3640' )



insert into BEST..TI17REQCHN
select 'BookingPOSEAnnuel',chain_ct,str_replace(idf_ct,'POSE','BookingPOSEAnnuel'),'BookingPOSEAnnuel' from BEST..TI17REQCHN
where reqcod_ct = 'POSE'
and chain_ct in ('ESID2210',
              'ESID2220',
              'ESPD2570',
              'ESPD3610',
              'ESPD3620',
              'ESPD3630',
              'ESPD3640',
              'ESFD2220',
              'ESPD2220',
              'ESPD2050',
              'ESPD8000')

GO

print '------>>>> End BookingPOSEAnnuel part 1'


print '------>>>> Insert BookingPOSEAnnuel part 2 perm files '

insert into BEST..TI17PERMFIL
select str_replace(idf_ct,'POSE','BookingPOSEAnnuel') , PERMFIL_CT , pathpattrn_ll,IO,perm_ll from  BEST..TI17PERMFIL
where 
(	IDF_CT  = 'ESID2210_POSE' or
	IDF_CT  = 'ESID2220_POSE' or
	IDF_CT  = 'ESPD2570_POSE' or
	IDF_CT  = 'ESPD3610_POSE' or
	IDF_CT  = 'ESPD3620_POSE' or
	IDF_CT  = 'ESPD3630_POSE' or
	IDF_CT  = 'ESPD3640_POSE' or
	IDF_CT  = 'ESPD8000_POSE' or
	IDF_CT  = 'ESPD2050_POSE' 	
 )



GO

print '------>>>> End  BookingPOSEAnnuel part 2 perm files '


print '------>>>> delete BookingPOCEAnnuel '

delete from BEST..TIfrs17Plan
where requestId = 'BookingPOCEAnnuel'

delete from BEST..TIfrs17ContextRequest
where requestId = 'BookingPOCEAnnuel'

delete from BEST..TIfrs17Request
where requestId = 'BookingPOCEAnnuel'

delete BEST..TI17REQCHN
where reqcod_ct = 'BookingPOCEAnnuel'

delete BEST..TI17PERMFIL
where IDF_CT like '%_BookingPOCEAnnuel'

delete from BEST..TI17FNC 
where IDF_CT like '%_BookingPOCEAnnuel'

GO

print '------>>>> End delete BookingPOCEAnnuel '


print '------>>>> Insert BookingPOCEAnnuel part 1'

/*** BEST..TIfrs17Request ***/
INSERT INTO BEST..TIfrs17Request
SELECT 
	str_replace (requestId, 'POCE', 'BookingPOCEAnnuel') AS requestId,
 'Comptabilisation Post-omega Conso EBS4 Annuelle' AS comment
FROM 
	BEST..TIfrs17Request
WHERE 
	requestId = 'POCE'
	
	
/*** BEST..TIfrs17ContextRequest ***/
INSERT INTO BEST..TIfrs17ContextRequest
SELECT 
	str_replace(requestId, 'POCE', 'BookingPOCEAnnuel') AS requestId,
  contextId,
  'Comptabilisation Post-omega Conso EBS4 Annuelle' AS comment
FROM 
	BEST..TIfrs17ContextRequest
WHERE 
	requestId = 'POCE'
	

insert into [BEST..TI17FNC]([IDF_CT],[IDF_LL]) 
select str_replace(idf_ct,'POCE','BookingPOCEAnnuel') , idf_ll  from  BEST..TI17FNC
where 
(	IDF_CT  = 'ESID2210_POCE' or
	IDF_CT  = 'ESID2220_POCE' or
	IDF_CT  = 'ESFD2220_POCE' or
	IDF_CT  = 'ESPD2570_POCE' or
	IDF_CT  = 'ESPD3610_POCE' or
	IDF_CT  = 'ESPD3620_POCE' or
	IDF_CT  = 'ESPD3630_POCE' or
	IDF_CT  = 'ESPD3640_POCE' or
  IDF_CT  = 'ESPD8000_POCE' or
	IDF_CT  = 'ESPD2050_POCE' 
 )

GO

insert into [BEST..TIfrs17Plan]([requestId],[chain],[planId],[comment]) 
select 'BookingPOCEAnnuel' , chain,planId , 'Booking POCE Annuel'  from BEST..TIfrs17Plan
where requestId = 'POCE'
and chain in ('ESID2210',
              'ESID2220',
              'ESPD2570',
              'ESPD3610',
              'ESPD3620',
              'ESPD3630',
              'ESPD3640' )



insert into BEST..TI17REQCHN
select 'BookingPOCEAnnuel',chain_ct,str_replace(idf_ct,'POCE','BookingPOCEAnnuel'),'BookingPOCEAnnuel' from BEST..TI17REQCHN
where reqcod_ct = 'POCE'
and chain_ct in ('ESID2210',
              'ESID2220',
              'ESPD2570',
              'ESPD3610',
              'ESPD3620',
              'ESPD3630',
              'ESPD3640',
              'ESFD2220',
              'ESPD2220',
              'ESPD2050',
              'ESPD8000')

GO

print '------>>>> End BookingPOCEAnnuel part 1'


print '------>>>> Insert BookingPOCEAnnuel part 2 perm files '

insert into BEST..TI17PERMFIL
select str_replace(idf_ct,'POCE','BookingPOCEAnnuel') , PERMFIL_CT , pathpattrn_ll,IO,perm_ll from  BEST..TI17PERMFIL
where 
(	IDF_CT  = 'ESID2210_POCE' or
	IDF_CT  = 'ESID2220_POCE' or
	IDF_CT  = 'ESPD2570_POCE' or
	IDF_CT  = 'ESPD3610_POCE' or
	IDF_CT  = 'ESPD3620_POCE' or
	IDF_CT  = 'ESPD3630_POCE' or
	IDF_CT  = 'ESPD3640_POCE' or
	IDF_CT  = 'ESPD8000_POCE' or
	IDF_CT  = 'ESPD2050_POCE' 	
 )



GO

print '------>>>> End  BookingPOCEAnnuel part 2 perm files '



---------------------------------------------------------------
print '------>>>> new chain ESFD3790 '

delete BEST..TI17REQCHN where IDF_CT = 'I17G_SEG_PRO_STD'
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_SEG_PRO_STD'
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_OMG_TP_STD' and PERMFIL_CT = 'ESF_FSEGPROF_SEG_STD'
delete BEST..TI17CHN where CHAIN_CT = 'ESFD3790'
delete BEST..TI17FNC where IDF_CT = 'I17G_SEG_PRO_STD'

insert into BEST..TI17FNC values ('I17G_SEG_PRO_STD','IFRS17 - IFRS 17 segment net position indicator')

insert into BEST..TI17CHN values ('ESFD3790','IFRS17 - IFRS 17 segment net position indicator')

insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${PCH}ESFD3620_I17G_DSC_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${PCH}ESFD3620_I17G_RAD_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','ESF_FSEGPROF_SEG_STD','${DFILP}/${PCH}ESFD3790_I17G_SEG_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','O','')

insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD','ESF_FSEGPROF_SEG_STD','${DFILP}/${PCH}ESFD3790_I17G_SEG_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')

insert into BEST..TI17REQCHN values ('I17GMINV','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMINVB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOS','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOSB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOC','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOCB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQINV','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQINVB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOS','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOSB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOC','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOCB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYINV','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYINVB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOS','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOSB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOC','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOCB','ESFD3790','I17G_SEG_PRO_STD','')

print '------>>>> end new chain ESFD3790 '
GO
---------------------------------------------------------------

---------------------------------------------------------------
print '------>>>>  SPIRA 71539 : add mapping FUTURE Retro OVERRIDE '
delete from BEST..TI17PERMFIL  where idf_ct = 'ESPD2550' 
and PERMFIL_CT in (
'EPO_DLREGTR_OVRCO',		
'EPO_DLREGTR_OVRSIICO',		
'EPO_DLREGTR_OVRSIISO',		
'EPO_DLREGTR_OVRSO',	
'EPO_DLREGTAR_OVRCO',		
'EPO_DLREGTAR_OVRSIICO',	
'EPO_DLREGTAR_OVRSIISO',	
'EPO_DLREGTAR_OVRSO'	
)


delete from BEST..TI17PERMFIL  where idf_ct = 'ESPD3800' 
and PERMFIL_CT in (
'EPO_DLREGTR_OVRCO',		
'EPO_DLREGTR_OVRSIICO',		
'EPO_DLREGTR_OVRSIISO',		
'EPO_DLREGTR_OVRSO',	
'EPO_DLREGTAR_OVRSIICO',
'EPO_DLREGTAR_OVRSIISO',	
'EPO_DLREGTAR_OVRSO',
'EPO_DLREGTAR_OVRCO')

insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTR_OVRCO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRCO.dat',	    'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTR_OVRSIICO',			'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSIICO.dat',	  'O', '')
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTR_OVRSIISO',			'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSIISO.dat',	  'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTR_OVRSO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSO.dat',	    'O', '')	  
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTR_OVRCO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRCO.dat',	    'I', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTR_OVRSIICO',			'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSIICO.dat',	  'I', '')
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTR_OVRSIISO',			'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSIISO.dat',	  'I', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTR_OVRSO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSO.dat',	    'I', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTAR_OVRCO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRCO.dat',	    'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTAR_OVRSIICO',		'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSIICO.dat',	'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTAR_OVRSIISO',		'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSIISO.dat',	'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTAR_OVRSO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSO.dat',	    'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTAR_OVRSIICO',		'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSIICO.dat',	'I', '') 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTAR_OVRSIISO',		'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSIISO.dat',	'I', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTAR_OVRSO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSO.dat',	    'I', '')	
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTAR_OVRCO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRCO.dat',	    'I', '')


print '------>>>>  SPIRA 71539 : add mapping FUTURE Retro OVERRIDE '
GO
---------------------------------------------------------------



---------------------------------------------------------------
print '------>>>>  ESFD3730 : add EST_IADPERICASE_DUMMY variable  spira 79100  '

DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_SII_ALL_STD' and PERMFIL_CT='EST_IADPERICASE_DUMMY'
INSERT INTO BEST..TI17PERMFIL VALUES('I17G_SII_ALL_STD', 'EST_IADPERICASE_DUMMY', '${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_DUMMY.dat', 'I', '')


print '------>>>>  End ESFD3730 : add EST_IADPERICASE_DUMMY variable  spira 79100  '
GO
---------------------------------------------------------------


---------------------------------------------------------------
print '------>>>>  SPIRA 82557 add I17G_CSF_ALL_INI EST_FCURQUOT_TXT  '

DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT in ('EST_FCURQUOT_TXT','EPO_FCURQUOT_TXT')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')


DELETE FROM BEST..TI17PERMFIL  where IDF_CT in ('I17G_IEX_ALL_INI', 'I17G_IEX_ALL_STD') and PERMFIL_CT = 'EST_FCURQUOT_TXT'
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')



print '------>>>>  End SPIRA 82557 add I17G_CSF_ALL_INI EST_FCURQUOT_TXT  '
GO
---------------------------------------------------------------

---------------------------------------------------------------
print '------>>>>  new variable ESFD2220/EPO_FCTREST/I17G_CSF_ALL_INI '
DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT='EPO_FCTREST'

INSERT INTO BEST..TI17PERMFIL VALUES('I17G_CSF_ALL_INI', 'EPO_FCTREST', '${DFILP}/${PCH}ESPD0060_FCTRESTSIISO.dat', 'I', '')

print '------>>>>  new variable ESFD2220/EPO_FCTREST/I17G_CSF_ALL_INI OK '
GO

----------------------------------------------------------------------------------------------------------
--
-- CHAIN ESFD2220 	-- I17G_FUT_ALL_INI
--
----------------------------------------------------------------------------------------------------------
delete BEST..TI17PERMFIL where   IDF_CT = 'I17G_FUT_ALL_INI'

insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERICASE','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FWHGTA','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FWHGTR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FPRMLOA','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAAPA','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLCUMGTAA','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAAPRE','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FTECLEDASO','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_ARCSTATGTA','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAAPNAE','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLCUMGTAATOT','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FTECLEDASIISO','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_CTRESTLOSPBPAP','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLDGTAA_CUMULS_COUR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCLIENT','${DFILP}/${PCH}ESPT0000_FCLIENT.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCPLACC','${DFILP}/${PCH}ESPT0000_FCPLACC.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCTRFWH','${DFILP}/${PCH}ESPD0060_FCTRFWH.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERIFR','${DFILP}/${PCH}ESPT0000_IADPERIFR.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FTHRHLDUWY','${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERIFCI','${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERIFCT','${DFILP}/${PCH}ESPT0000_IADPERIFCT.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FDETTRS_TXT','${DFILP}/${PCH}ESPT0000_FDETTRS_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FTRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FSEGEST_SOLVENCY','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCY${TYPEINV0}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FLOARAT','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_IFRS_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_OIADVPERICASE','${DFILP}/${PCH}ESPT0000_OIADVPERICASE.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FUTURE_EBS','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_FUTURE_${TYPEINV}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAUPUC','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLGTAUPUC_${TYPEINV}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLDGTAA_E_TRNCODEBS','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLDGTAASII${TYPEINV0}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FCTREST','${DFILP}/${PCH}ESPD0060_FCTRESTSIISO.dat',' ','')

print '------>>>>  [81496] ESFD2220 End'
go










