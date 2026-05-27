/* ====================================================================================================
  -- Creation date	: 19/10/2017
  -- Author		: Clément Dufrenne
  -- Origin		: Spira [IN:060691]
  -- Description	: Clean up de la grille estimations retro pour les UWY supérieurs à la résiliation des contrats suivants
  -- Action		: DELETE
  -- Impacted table(s)	: BEST..TLIFEST
  -- Impacted row(s)	: 
======================================================================================================= */

/* ------------------------------------------------------
Select the database
--------------------------------------------------------- */
use BEST
go


/* ------------------------------------------------------
Log the starting time.
--------------------------------------------------------- */
declare @msg char(150)
select  @msg=@@servername + ' => ' + host_name() + ', Starting the execution of the script: ' + convert(char(9),getdate(),6) + ' ' + convert(char(9),getdate(),8)
print   @msg
go


/* ------------------------------------------------------
Select the existing rows to check the result before/after
--------------------------------------------------------- */
select *
from BEST..TLIFEST
where CTR_NF in ('04P000096', '04P000097', '04P000098', '04P000099', '04P000100', '04W059125')
and UWY_NF > 2016
go

/* ------------------------------------------------------
Update rows
--------------------------------------------------------- */
update BEST..TLIFEST
set estmnt_m = 0
where CTR_NF = '04P000096'
and UWY_NF > 2016
go

update BEST..TLIFEST
set estmnt_m = 0
where CTR_NF = '04P000097'
and UWY_NF > 2016
go

update BEST..TLIFEST
set estmnt_m = 0
where CTR_NF = '04P000098'
and UWY_NF > 2016
go

update BEST..TLIFEST
set estmnt_m = 0
where CTR_NF = '04P000099'
and UWY_NF > 2016
go

update BEST..TLIFEST
set estmnt_m = 0
where CTR_NF = '04P000100'
and UWY_NF > 2016
go

update BEST..TLIFEST
set estmnt_m = 0
where CTR_NF = '04W059125'
and UWY_NF > 2016
go


/* ------------------------------------------------------
Select the existing rows to check the result before/after
--------------------------------------------------------- */
select *
from BEST..TLIFEST
where CTR_NF in ('04P000096', '04P000097', '04P000098', '04P000099', '04P000100', '04W059125')
and UWY_NF > 2016
go


/* ------------------------------------------------------
Log the ending time.
--------------------------------------------------------- */
declare @msg char(150)
select  @msg=@@servername + ' => ' + host_name() + ', Ending the execution of the script: ' + convert(char(9),getdate(),6) + ' ' + convert(char(9),getdate(),8)
print   @msg
go 