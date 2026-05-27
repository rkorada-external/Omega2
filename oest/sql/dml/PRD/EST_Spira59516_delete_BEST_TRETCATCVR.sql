/* ====================================================================================================
  -- Creation date	: 18/05/2017
  -- Author		: Clément Dufrenne
  -- Origin		: Spira #59516
  -- Description	: Delete an unexpected row displayed from CAT COVER grids
  -- Action		: DELETE
  -- Impacted table(s)	: BEST..TRETCATCVR
  -- Impacted row(s)	: 1 row
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
select  @msg=@@servername + ' => ' + host_name() + ', Starting the execution of the script : ' + convert(char(9),getdate(),6) + ' ' + convert(char(9),getdate(),8)
print   @msg
go


/* ------------------------------------------------------
Select the existing rows to check the result before/after
--------------------------------------------------------- */
select cvr.*
from BEST..TRETCATCVR cvr
where cvr.RCATCVR_NT = 16027
go

/* ------------------------------------------------------
Delete the expected rows
--------------------------------------------------------- */
delete from BEST..TRETCATCVR
where RCATCVR_NT = 16027
go


/* ------------------------------------------------------
Select the existing rows to check the result before/after
--------------------------------------------------------- */
select cvr.*
from BEST..TRETCATCVR cvr
where cvr.RCATCVR_NT = 16027
go


/* ------------------------------------------------------
Log the ending time.
--------------------------------------------------------- */
declare @msg char(150)
select  @msg=@@servername + ' => ' + host_name() + ', Ending the execution of the script : ' + convert(char(9),getdate(),6) + ' ' + convert(char(9),getdate(),8)
print   @msg
go