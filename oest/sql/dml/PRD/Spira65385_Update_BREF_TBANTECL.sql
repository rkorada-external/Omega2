use BREF
go

update bref..tbantecl
set COLVAL_LM = "Incurred",
COLVAL_LS = "Incurred"
where colval_ct = "ICR"
go
