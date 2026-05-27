/* ====================================================================================================
  -- Creation date	: 19/07/2017
  -- Author		: Clément Dufrenne
  -- Origin		: Spira [IN:063510]
  -- Description	: Update the estimates currency for treaties TR0023003 and 04T007309.
  -- Action		: UPDATE
  -- Impacted table(s)	: BEST..TLIFEST
  -- Impacted row(s)	: 22 rows + 779 rows
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
where ctr_nf = 'TR0023003'
go

select *
from BEST..TLIFEST
where ctr_nf = '04T007309'
go


/* ------------------------------------------------------
Update rows
--------------------------------------------------------- */
update BEST..TLIFEST
set cur_cf = 'USD'
where ctr_nf = 'TR0023003'
and sec_nf = 1
go

update BEST..TLIFEST
set cur_cf = 'CLP'
where ctr_nf = '04T007309'
and sec_nf = 1
go


/* ------------------------------------------------------
Select the existing rows to check the result before/after
--------------------------------------------------------- */
select *
from BEST..TLIFEST
where ctr_nf = 'TR0023003'
go

select *
from BEST..TLIFEST
where ctr_nf = '04T007309'
go


/* ------------------------------------------------------
Log the ending time.
--------------------------------------------------------- */
declare @msg char(150)
select  @msg=@@servername + ' => ' + host_name() + ', Ending the execution of the script: ' + convert(char(9),getdate(),6) + ' ' + convert(char(9),getdate(),8)
print   @msg
go 