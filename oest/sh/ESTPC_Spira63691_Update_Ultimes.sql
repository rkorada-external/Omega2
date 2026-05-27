/* ====================================================================================================
  -- Creation date     : 28/08/2017
  -- Author            : Clément Dufrenne
  -- Origin            : Spira [IN:063663]
  -- Description       : EST P&C - Ultimes - Inserer une ligne en mode EGPI =M dans la grille des Ultimes 
  -- Action            : INSERT        / UPDATE
  -- Impacted table(s) : BEST..TCTRULT / BTRT..TSECTION
  -- Impacted row(s)   : 
======================================================================================================= */

/* --
database selection 
   -- */
use BTRAV
go

/* --
log starting time
   -- */
set nocount on
declare @msg char(255)
select  @msg=@@servername + ' => ' + host_name() + ', Starting the execution of the script: ' + convert(char(9), getdate(), 6) + ' ' + convert(char(9), getdate(), 8)
print   @msg
go

/* --
creation of variable(s) and temporary table(s)
   -- */
create table #trtult
(
  CTR_NF UCTR_NF NOT NULL,
  SEC_NF USEC_NF NOT NULL,
  UWY_NF UUWY_NF NOT NULL
)
go
insert #trtult values('02T021778',1,2015)
insert #trtult values('02T026496',1,2015)
insert #trtult values('02T025553',1,2015)
set nocount off
go

/* --
check data BEFORE data processing
   -- */
select ADMMODPRM_CT, a.*
from BTRT..TSECTION a, #trtult b
where a.CTR_NF = b.CTR_NF 
  and a.SEC_NF = b.SEC_NF 
  and a.UWY_NF = b.UWY_NF
go
select a.*
from BEST..TCTRULT a, #trtult b
where a.CTR_NF = b.CTR_NF 
  and a.SEC_NF = b.SEC_NF 
  and a.UWY_NF = b.UWY_NF
go

/* --
data processing :
pour les traités 02T021778/1/2015, 02T026496/1/2015 et 02T025553/1/2015
inserer une ligne dans la grille des ultimes dont le mode de gestion EGPI = M 
   -- */

update BTRT..TSECTION
 set ADMMODPRM_CT='M'
  from BTRT..TSECTION a, #trtult b
  where a.CTR_NF = b.CTR_NF 
    and a.SEC_NF = b.SEC_NF 
    and a.UWY_NF = b.UWY_NF
go

insert best..TCTRULT
select a.CTR_NF,END_NT,a.SEC_NF,a.UWY_NF,UW_NT,CRE_D=getdate(),SSD_CF,DIV_NT,CUR_CF,CALAMTPRM_M,ENTAMTPRM_M,RETAMTPRM_M,ADMMODPRM_CT='M',RESPRM_M,CALAMTCLM_M,ENTAMTCLM_M,RETAMTCLM_M,ADMMODCLM_CT,ORICOD_LS,UPDUSR_CF='dbo',CREUSR_CF='dbo',LSTUPD_D=getdate(),LSTUPDUSR_CF='dbo',EGPILRMODIF_CF,CMTLR_NT,CMTWP_NT
from BEST..TCTRULT a, #trtult b
  where a.CTR_NF = b.CTR_NF 
    and a.SEC_NF = b.SEC_NF 
    and a.UWY_NF = b.UWY_NF
    and CRE_d=(select max(CRE_D) from BEST..TCTRULT x where a.CTR_NF=x.CTR_NF and a.SEC_NF=x.SEC_NF and a.UWY_NF=x.UWY_NF)
go

/* --
check data AFTER data processing
   -- */
select ADMMODPRM_CT, a.*
from BTRT..TSECTION a, #trtult b
where a.CTR_NF = b.CTR_NF 
  and a.SEC_NF = b.SEC_NF 
  and a.UWY_NF = b.UWY_NF
go
select a.*
from BEST..TCTRULT a, #trtult b
where a.CTR_NF = b.CTR_NF 
  and a.SEC_NF = b.SEC_NF 
  and a.UWY_NF = b.UWY_NF
go
   
/* --
log ending time
   -- */
set nocount on
declare @msg char(255)
select  @msg=@@servername + ' => ' + host_name() + ', Ending the execution of the script: ' + convert(char(9), getdate(), 6) + ' ' + convert(char(9), getdate(), 8)
print   @msg
set nocount off
go