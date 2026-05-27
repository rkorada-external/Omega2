
-- Spira 91531 : change BEST..TI17PERMFIL column PATHPATTRN_LL from varchar(128) to varchar(512)

use BEST
go

alter table TI17PERMFIL  modify PATHPATTRN_LL varchar(512)

go
