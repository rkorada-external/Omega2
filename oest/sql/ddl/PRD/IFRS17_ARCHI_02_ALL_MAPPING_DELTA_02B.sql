USE BEST
go

--[001] 11/12/2019 Roger     : SPIRA 81496 : Ajoute FTECLEDASO_EBS.dat pour ESPD8830 et EPO_OIADVPERICASE pour ESFD2220 ESPD3620 ESPD3640
-----------------------------------------------------------------------------------------------------------

print '------>>>>  [81496] ESPD8830 ESFD2220 ESPD3620 ESPD3640'

----------------------------------------------------------------------------------------------------------
--
-- CHAIN ESPD8830 	-- POSI
--
----------------------------------------------------------------------------------------------------------

update BEST..TI17PERMFIL
set pathpattrn_ll = '${DFILP}/${PCH}ESPD3800_FTECLEDASO_EBS.dat'
where pathpattrn_ll like '%ESPD3800_FTECLEDASO%'
and (IDF_CT like '%_POSE' OR IDF_CT like '%_POCE')

delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_FTECLEDASO_EBS'
and IDF_CT = 'ESPD8830'

delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_OIADVPERICASE'
and IDF_CT in ('ESFD2220_POSE','ESFD2220_POCE')

delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_OIADVPERICASE'
and IDF_CT in ('ESPD3620_POSE','ESPD3620_POCE')

delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_OIADVPERICASE'
and IDF_CT in ('ESPD3640_POSE','ESPD3640_POCE')

insert into BEST..TI17PERMFIL values('ESPD8830','EPO_FTECLEDASO_EBS','${DFILP}/${PCH}ESPD3800_FTECLEDASO_EBS.dat','O','')

insert into BEST..TI17PERMFIL values('ESFD2220_POSE','EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')
insert into BEST..TI17PERMFIL values('ESFD2220_POCE','EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')

insert into BEST..TI17PERMFIL values('ESPD3620_POSE','EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')
insert into BEST..TI17PERMFIL values('ESPD3620_POCE','EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')

insert into BEST..TI17PERMFIL values('ESPD3640_POSE','EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')
insert into BEST..TI17PERMFIL values('ESPD3640_POCE','EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')

print '------>>>>  [81496] End ESPD8830 ESFD2220 ESPD3620 ESPD3640'
go

