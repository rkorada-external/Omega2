USE BEST 
Go

--delete TI17REQ  where REQCOD_CT in ('A', 'L', 'Y', 'Z', 'V')
-- delete not possible BEST..TI17REQFNC constraint  FK_REQST_REQST_FNC
---GO

if not exists ( select 1 from TI17REQ where REQCOD_CT = 'A')  insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('A', 'Life Plan')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'L') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('L', 'Stat/Reporting Life')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'Y') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('Y', 'Local IFRS4')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'Z') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('Z', 'Chargement Inv')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'V') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('V', 'Settlement Booking')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'M') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('M', 'Ultimates update on exchnge rate')
if not exists ( select 1 from TI17REQ where REQCOD_CT = 'R') insert into TI17REQ (REQCOD_CT, REQCOD_LL) values ('R', 'Retro. Accounting Freeze')
GO 