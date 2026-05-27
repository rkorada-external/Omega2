/* ====================================================================================================
  -- Creation date	: 29/06/2017
  -- Author		: Clément Dufrenne
  -- Origin		: Spira [IN:063625]
  -- Description	: Estimates Grid - Modify the estimates currency for TR0009874 [IN:063625]
  -- Action		: UPDATE
  -- Impacted table(s)	: BEST..TLIFEST
  -- Impacted row(s)	: around 100 rows
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
where ctr_nf = 'TR0009874'
go


/* ------------------------------------------------------
Update rows
--------------------------------------------------------- */
update BEST..TLIFEST
set estmnt_m = round((estmnt_m / 6.91),3), cur_cf = 'USD' 
where ctr_nf = 'TR0009874' and cur_cf = 'BOB' 
go

/* ------------------------------------------------------
Select the existing rows to check the result before/after
--------------------------------------------------------- */
select *
from BEST..TLIFEST
where ctr_nf = 'TR0009874'
go


/* ------------------------------------------------------
Log the ending time.
--------------------------------------------------------- */
declare @msg char(150)
select  @msg=@@servername + ' => ' + host_name() + ', Ending the execution of the script: ' + convert(char(9),getdate(),6) + ' ' + convert(char(9),getdate(),8)
print   @msg
go 