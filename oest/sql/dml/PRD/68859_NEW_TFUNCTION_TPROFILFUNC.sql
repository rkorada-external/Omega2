-- Script to add new profile function for Cash Flow Adj. 
-- Changes made for CR 68859
-- Author : Lilian

-- Add the rule 902606 

USE BREF
GO

----- INSERT TFUNCTION
IF EXISTS( select 1 from BREF..TFUNCTION where FUNC_CF = 902606 and APP_CF = 'EST'  )
BEGIN
exec(" DELETE from BREF..TFUNCTION where FUNC_CF = 902606 and APP_CF = 'EST' " )
END
go

INSERT into BREF..TFUNCTION (
   FUNC_CF
  ,APP_CF
  ,FUNC_LS
  ,FUNC_LD
  ,BATDEP_B
  ,UPDATE_B
  ,FNTYP_CT
) VALUES (
  902606
  ,'EST'
  ,'V Cash Flow Adj.'
  ,'This function allows screen access to Cash Flow Adjustments Search'
  ,0
  ,0
  ,0
)
go

IF EXISTS( select 1 from BREF..TPROFILFUNC where FUNC_CF = 902606 and APP_CF = 'EST' and PRF_CF in( 'LIFE01','LIFE02','LIFE03','LIFE04','LIFEALL') )
BEGIN
exec(" DELETE  from BREF..TPROFILFUNC where FUNC_CF = 902606")
END
go

----- INSERT TPROFILFUNC
insert into BREF..TPROFILFUNC (
	FUNC_CF
	,APP_CF
	,PRF_CF
)
values 
(902606, 'EST', 'LIFE01')
go

insert into BREF..TPROFILFUNC (
	FUNC_CF
	,APP_CF
	,PRF_CF
)
values 
(902606, 'EST', 'LIFE02')
go

insert into BREF..TPROFILFUNC (
	FUNC_CF
	,APP_CF
	,PRF_CF
)
values 
(902606, 'EST', 'LIFE03')
go

insert into BREF..TPROFILFUNC (
	FUNC_CF
	,APP_CF
	,PRF_CF
)
values 
(902606, 'EST', 'LIFE04')
go

insert into BREF..TPROFILFUNC (
	FUNC_CF
	,APP_CF
	,PRF_CF
)
values 
(902606, 'EST', 'LIFEALL')
go
