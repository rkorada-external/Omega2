--Script to add new profile function for local Assistance Entry (ES) and TFUNCTION
--Changes made for CR 61508
-- Author : Riyadh

-- Change function 32798 to 902103


USE BREF
GO


IF EXISTS( select 1 from BREF..TPROFILFUNC where FUNC_CF = 32798 and APP_CF = 'EST' and PRF_CF in( 'TRT02','ADMINIPC') )
BEGIN
exec(" DELETE  from BREF..TPROFILFUNC where FUNC_CF = 32798  ")
END
go

IF EXISTS( select 1 from BREF..TPROFILFUNC where FUNC_CF = 902103 and APP_CF = 'EST' and PRF_CF in( 'TRT02','ADMINIPC') )
BEGIN
exec(" DELETE  from BREF..TPROFILFUNC where FUNC_CF = 902103  ")
END
go



IF EXISTS( select 1 from BREF..TFUNCTION where FUNC_CF = 902103 and APP_CF = 'EST'  )
BEGIN
exec(" DELETE  from BREF..TFUNCTION where FUNC_CF = 902103   and APP_CF = 'EST' " )
END
go

INSERT INTO bref..TFUNCTION ( FUNC_CF, APP_CF, FUNC_LS, FUNC_LD, BATDEP_B, UPDATE_B, FNTYP_CT ) 
 VALUES ( 902103, 'EST     ', 'U Local AE', 'This function allows update an Local Assistance Entry.', 1, 1, 0 )
GO

IF EXISTS( select 1 from BREF..TFUNCTION where FUNC_CF = 32798 and APP_CF = 'EST' and FUNC_LS='U Local AE' )
BEGIN
update BREF..TFUNCTION set FUNC_LS='NOT USED', FUNC_LD='NOT USED' where FUNC_CF = 32798 and APP_CF = 'EST' and FUNC_LS='U Local AE' 
END
go






