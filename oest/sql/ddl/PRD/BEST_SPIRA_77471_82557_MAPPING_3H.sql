USE BEST
go

-----------------------------------------------------------------------------------------------------------
--[001] 05/03/2020 Charles/Antoine request: SPIRA 77471_82557 : change mapping ESFD3750
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
print "------>>>> Charles/Antoine request: SPIRA 77471_82557 : change mapping ESFD3750"

DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSM_ALL_STD' and PERMFIL_CT in ('ESF_GTSII_CSESF_GTSII_CSMM','ESF_GTSII_CSM','ESF_CSM_PROF','ESF_FSEGPROF_STD')

insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD','ESF_GTSII_CSM','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD','ESF_CSM_PROF','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_PROF_BY_CTR_${PARM_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD','ESF_FSEGPROF_STD','${DFILP}/${PCH}ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')


DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_IEX_ALL_INI' and PERMFIL_CT in ('EST_FCURQUOT_TXT')
DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_IEX_ALL_STD' and PERMFIL_CT in ('EST_FCURQUOT_TXT')
DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT in ('EST_FCURQUOT_TXT')

insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','') 
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')

	
print "------>>>> End Charles/Antoine request: SPIRA 77471_82557 : change mapping ESFD3750"
GO
-----------------------------------------------------------------------------------------------------------

