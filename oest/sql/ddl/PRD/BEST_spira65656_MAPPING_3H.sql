USE BEST
go

--[001] 12/02/2020 Roger : SPIRA 65656 : Nouveau mapping pour fichier EPO_FCTREST_LOADCTL


-----------------------------------------------------------------------------------------------------------
print '------>>>>  [65656] EPO_FCTREST_LOADCTL' 

delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_FCTREST_LOADCTL'
and IDF_CT in ('ESPD0060', 'ESPD8000_POSE', 'ESPD8000_POCE', 'ESPD8000_BookingPOSE', 'ESPD8000_BookingPOCE', 'ESPD8000_BookingPOSEAnnuel', 'ESPD8000_BookingPOCEAnnuel')

insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','O','')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')

print '------>>>>  [65656] End EPO_FCTREST_LOADCTL' 

go
----------------------------------------------------------------

