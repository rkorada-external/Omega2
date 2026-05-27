USE BEST
go

--[001] 22/04/2020 Roger : SPIRA 86503-86536 : Nouveau mapping pour fichier EPO_FCTRESTF


----------------------------------------------------------------
print '------>>>>  [86503] EST_FCTRESTF - EST_FCTRESTA' 

-- Supprime ancien mapping plus valable
delete BEST..TI17PERMFIL
where PERMFIL_CT in ('EST_FCTREST','EST_FCTREST1_IFRS')

-- Supprime mapping
delete BEST..TI17PERMFIL
where PERMFIL_CT in ('EST_FCTRESTF','EST_FCTRESTF0','EST_FCTRESTA')
and IDF_CT in ('ESID0560', 'ESID2000', 'ESID8000')

insert into BEST..TI17PERMFIL values ('ESID0560', 'EST_FCTRESTF','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRESTF','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8000', 'EST_FCTRESTF','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID0560', 'EST_FCTRESTA','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRESTA','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8000', 'EST_FCTRESTA','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID0560', 'EST_FCTRESTF0','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF0_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID8000', 'EST_FCTRESTF0','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF0_${ICLODAT}.dat','I','')

print '------>>>>  [86503] End EST_FCTRESTF - EST_FCTRESTF0 - EST_FCTRESTA' 

go
----------------------------------------------------------------



