use BEST
go
delete from best..TREQJOBplan where REQCOD_CT in ('T','D') and DBCLO_D in ('20260211', '20260210') LAUNCH_D is null
go
delete from best..TREQJOB where REQCOD_CT in ('T','D') and DBCLO_D in ('20260211', '20260210') LAUNCH_D is null
go
