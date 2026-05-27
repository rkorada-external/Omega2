use BREF
go 

delete from bref..tbantecl where col_LS = 'ANO_CT' and COLVAL_CT in ('40001','40002','40003','40004','40005','40006')
go

delete from bref..tbantec where col_LS = 'ANO_CT' and COLVAL_CT in ('40001','40002','40003','40004','40005','40006')
go
