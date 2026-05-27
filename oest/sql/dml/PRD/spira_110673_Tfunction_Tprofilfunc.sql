--Changes made for 110673
-- Author : HR

USE BREF
GO

IF EXISTS( select 1 from BREF..TPROFILFUNC where FUNC_CF = 919554 and APP_CF = 'EST' and PRF_CF in( 'PUBLIC') )
BEGIN
exec(" DELETE  from BREF..TPROFILFUNC where FUNC_CF = 919554 and APP_CF = 'EST' and PRF_CF = 'PUBLIC'")
END
go

IF EXISTS( select 1 from BREF..TFUNCTION where FUNC_CF = 919554 and APP_CF = 'EST'  )
BEGIN
exec(" DELETE  from BREF..TFUNCTION where FUNC_CF = 919554   and APP_CF = 'EST' " )
END
go

INSERT INTO TFUNCTION (FUNC_CF, APP_CF, FUNC_LS, FUNC_LD, BATDEP_B, UPDATE_B, FNTYP_CT) VALUES (919554, 'EST', 'V Closing Search', 'This function controls access to Local Closing Entity Search Screens',0, 0, 0)
go

INSERT INTO TPROFILFUNC (FUNC_CF, APP_CF, PRF_CF) VALUES (919554, 'EST', 'PUBLIC')
go

IF EXISTS( select 1 from BREF..TPROFILFUNC where FUNC_CF = 919557 and APP_CF = 'EST' and PRF_CF in( 'PUBLIC') )
BEGIN
exec(" DELETE  from BREF..TPROFILFUNC where FUNC_CF = 919557 and APP_CF = 'EST' and PRF_CF = 'PUBLIC'")
END
go

IF EXISTS( select 1 from BREF..TFUNCTION where FUNC_CF = 919557 and APP_CF = 'EST'  )
BEGIN
exec(" DELETE  from BREF..TFUNCTION where FUNC_CF = 919557   and APP_CF = 'EST' " )
END
go

INSERT INTO TFUNCTION (FUNC_CF, APP_CF, FUNC_LS, FUNC_LD, BATDEP_B, UPDATE_B, FNTYP_CT) VALUES (919557, 'EST', 'U Closing Search', 'This function controls access to Local Closing Entity Search Screens in update mode',0, 0, 0)
go

INSERT INTO TPROFILFUNC (FUNC_CF, APP_CF, PRF_CF) VALUES (919557, 'EST', 'PUBLIC')
go
