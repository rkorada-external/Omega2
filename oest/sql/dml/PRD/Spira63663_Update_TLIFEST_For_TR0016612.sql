/* ====================================================================================================
  -- Creation date	: 23/08/2017
  -- Author		: Clément Dufrenne
  -- Origin		: Spira [IN:063663]
  -- Description	: Estimates Grid - Modify the estimates currency for TR0016612 [IN:063663] 
  -- Action		: UPDATE
  -- Impacted table(s)	: BEST..TLIFEST
  -- Impacted row(s)	: 147 rows
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
where ctr_nf = 'TR0016612'
go


/* ------------------------------------------------------
Update rows
--------------------------------------------------------- */
update BEST..TLIFEST
set estmnt_m = round((estmnt_m / 24997),0), cur_cf = 'USD' 
where ctr_nf = 'TR0016612' and cur_cf = 'ECS' 
go

/* ------------------------------------------------------
Select the existing rows to check the result before/after
--------------------------------------------------------- */
select *
from BEST..TLIFEST
where ctr_nf = 'TR0016612'
go


/* ------------------------------------------------------
Log the ending time.
--------------------------------------------------------- */
declare @msg char(150)
select  @msg=@@servername + ' => ' + host_name() + ', Ending the execution of the script: ' + convert(char(9),getdate(),6) + ' ' + convert(char(9),getdate(),8)
print   @msg
go 