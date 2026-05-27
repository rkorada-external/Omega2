USE BEST 
Go

-- Delete Requests with %

delete BEST..TI17REQFNC  where REQCOD_CT like '%[%]%'
delete BEST..TI17REQ  where REQCOD_CT like '%[%]%'

GO 