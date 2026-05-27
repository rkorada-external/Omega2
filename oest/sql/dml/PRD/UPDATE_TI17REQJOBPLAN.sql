Use BEST
Go

if not exists ( select 1 from TI17REQ where REQCOD_CT = 'A')  insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('A', 'Life Plan')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'L') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('L', 'Stat/Reporting Life')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'Y') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('Y', 'Local IFRS4')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'Z') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('Z', 'Chargement Inv')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'V') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('V', 'Settlement Booking')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'M') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('M', 'Ultimates update on exchnge rate')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'R') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('R', 'Retro. Accounting Freeze')
go

if not exists ( select 1 from BEST..TI17REQJOBPLAN where REQCOD_CT in ('M','R','V','A','L','Y','Z') and balsheyea_nf > 2020)

BEGIN
    Declare @errnum    	Int,
            @errcau		Int

BEGIN TRAN		

INSERT into BEST..TI17REQJOBPLAN
		        (balsheyea_nf, balshtmth_nf, clodat_d, cre_d, reqcod_ct, ssd_cf, cloper_ls, dbclo_d, launch_d, updusr_cf, start_d, end_d, vrs_nf, site_Cf) 
                
                select 
 balsheyea_nf, 
 balshtmth_nf, 
 clodat_d, 
 cre_d, 
 reqcod_ct, 
 ssd_cf, 
 cloper_ls, 
 dbclo_d, 
 launch_d, 
 updusr_cf, 
 start_d, 
 end_d, 
 vrs_nf, 
 site_Cf 
from 
 BEST..TREQJOBPLAN 
where 
 REQCOD_CT in ('M','R','V','A','L','Y','Z') and balsheyea_nf > 2020

		Select @errnum = @@error
		If @errnum != 0
			Begin
				Select @errcau = 1
				Goto finano
			End
			
			
update  BEST..TREQJOBPLAN set updusr_cf = 'ESCJ' where REQCOD_CT in ('M','R','V','A','L','Y','Z')

		Select @errnum = @@error
		If @errnum != 0
			Begin
				Select @errcau = 2
				Goto finano
			End
			
    -- Fin normale
    Select "Fin Normale"

    COMMIT TRAN
    Goto fin

    finano:
    Select "ATTENTION ! FIN ANORMALE !!!"

    If @errcau = 1
        Select "Erreurs Insert TI17REQJOBPLAN : " + Convert(Varchar(10), @errnum)
    If @errcau = 2
        Select "Erreurs Update TREQJOBPLAN : " + Convert(Varchar(10), @errnum)
		
    ROLLBACK TRAN

    fin:        
END    
go
 
