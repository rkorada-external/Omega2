USE BEST
go

--[001] 20/04/2020 Roger : SPIRA 84281 : Nouveau mapping pour ESPD2900

-----------------------------------------------------------------------------------------------------------
print '------>>>>  [84281] ESPD2900' 

delete BEST..TI17PERMFIL
where PERMFIL_CT in ('EPO_FTECLEDASO_EBS','EPO_FTECLEDRSO')
and IDF_CT in ('ESPD2900')

insert into BEST..TI17PERMFIL values ('ESPD2900', 'EPO_FTECLEDASO_EBS','${DFILP}/${PCH}ESPD3800_FTECLEDASO_EBS.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD2900', 'EPO_FTECLEDRSO','${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat','I','')

print '------>>>>  [84281] End ESPD2900'

go
----------------------------------------------------------------

