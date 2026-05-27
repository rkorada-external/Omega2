----------------------------------------------------------------------------------------------------------
--  AJOUT de l'IDF_CT I17G_ESFD2550_TC 20220928
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD2550
-------------------------------


delete   BTEC..TFILSUP where dom_cf in ('NIC_I17G')


insert into BTEC..TFILSUP values('NIC_I17G', 786,	'USA1') -- NTC_I17G USA1
insert into BTEC..TFILSUP values('NIC_I17G', 785,	'FRA1') -- NTC_I17G FRA1
insert into BTEC..TFILSUP values('NIC_I17G', 784,	'SGP1') -- NTC_I17G SGP1 

go
