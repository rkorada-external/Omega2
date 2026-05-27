use BEST
go


alter table BEST.dbo.TI17CLOPER replace PARM5 default 0
update BEST.dbo.TI17CLOPER SET PARM5 = '0' WHERE PARM5 IS NULL 

go