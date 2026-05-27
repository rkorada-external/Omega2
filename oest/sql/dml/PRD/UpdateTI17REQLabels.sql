USE BEST
GO
update BEST..TI17REQ set REQCOD_LL = 'Monthly INV IFRS 17 Group booking' where REQCOD_CT = 'I17GMINVB'
GO
update BEST..TI17REQ set REQCOD_LL = 'Quarterly INV IFRS 17 Group booking' where REQCOD_CT = 'I17GQINVB'
GO
update BEST..TI17REQ set REQCOD_LL = 'Yearly INV IFRS 17 Group booking' where REQCOD_CT = 'I17GYINVB'
GO
update BEST..TI17REQ set REQCOD_LL = 'Monthly INV IFRS 17 Local booking' where REQCOD_CT = 'I17LMINVB'
GO
update BEST..TI17REQ set REQCOD_LL = 'Quarterly INV IFRS 17 Local booking' where REQCOD_CT = 'I17LQINVB'
GO
update BEST..TI17REQ set REQCOD_LL = 'Yearly INV IFRS 17 Local booking' where REQCOD_CT = 'I17LYINVB'
GO
update BEST..TI17REQ set REQCOD_LL = 'Monthly INV IFRS 17 Parent booking' where REQCOD_CT = 'I17PMINVB'
GO
update BEST..TI17REQ set REQCOD_LL = 'Quarterly INV IFRS 17 Parent booking' where REQCOD_CT = 'I17PQINVB'
GO
update BEST..TI17REQ set REQCOD_LL = 'Yearly INV IFRS 17 Parent booking' where REQCOD_CT = 'I17PYINVB'
GO
