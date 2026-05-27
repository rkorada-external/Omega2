USE BTEC
GO


IF EXISTS( select 1 from BTEC..tjob  where I_JOB = 'best24a')
BEGIN
exec(" DELETE from BTEC..tjob where I_JOB = 'best24a' ")
END
go

insert into BTEC..tjob 
VALUES ('best24a ', 'Chgt aj. Cash flow/Cash Flow Load  ', 'best24a ', 5, 'N', 'A', 'N', 'N', getdate(), getdate(), 'X', 'X', 5, getdate(), 'N')
GO

GO
IF EXISTS( select 1 from BTEC..tjobtaskxref  where I_JOB = 'best24a ' )
BEGIN
exec(" DELETE from BTEC..tjobtaskxref where I_JOB = 'best24a' " )
END
go

INSERT INTO BTEC..tjobtaskxref 
 VALUES ('best24a ', 1, 'best24a1', getdate(), '$DEST/$UTIDIR/ESID0891.cmd', ' ', ' ', ' ', ' ')
GO

GO
IF EXISTS( select 1 from BTEC..ttask  where I_TASK = 'best24a1 ' )
BEGIN
exec(" DELETE from BTEC..ttask where I_TASK = 'best24a1' " )
END
go

INSERT INTO BTEC..ttask 
 VALUES ('best24a1', 'Chgt aj. Cash flow/Cash Flow Load   ', 'R', 'Y', 'N', 'N', 1, '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', getdate(), 0, 0, 'as_process.exe', ' ', ' ', ' ')
GO
