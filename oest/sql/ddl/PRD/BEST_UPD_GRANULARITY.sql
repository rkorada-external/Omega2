use BEST
GO

---- JYP SPIRA 91991 : 02/02/2021 : new rule for product codes

update  BEST..TI17PRODUCT set I17PRDCOD_CT = 'AMG' + substring(I17PRDCOD_CT,4,7)  where I17PRDCOD_CT like 'AM0%' and bchusr_cf = 'ubam'
go
update  BEST..TI17PRODUCT set I17PRDCOD_CT = 'ASG' + substring(I17PRDCOD_CT,4,7)  where I17PRDCOD_CT like 'AS0%' and bchusr_cf = 'ubas'
go
update  BEST..TI17PRODUCT set I17PRDCOD_CT = 'EUG' + substring(I17PRDCOD_CT,4,7)  where I17PRDCOD_CT like 'EU0%' and bchusr_cf = 'ubeu'

GO



