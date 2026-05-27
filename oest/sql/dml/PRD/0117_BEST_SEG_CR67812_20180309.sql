/*==============================================================
Program: SPIRA #67812: SEG : Make SEG results available in BO
Version: 1
Author: M Jain
Date of creation: 09/03/2018
Description: Change Request #67812: SEG : Make SEG results available in BO 
          
==============================================================*/
use BEST
go

select * from BEST..TSEGUWTABLE where SGTUWTAB_CF='TUWSECRA'
select * from BEST..TSEGUWTABLE where SGTUWTAB_CF='TUWRETSECRA'

-- Non-Common/Distinct Columns of TUWSECRA with TUWSEC to be exported to TUWSECRA: PANELLOB_CF (372), PANELLOB_LL (373), PANELCOUNTRY_CF (374), PANELCOUNTRY_LL (375)
insert into BEST..TSEGUWTABLE (SGTUWTAB_CF, SGTRQST_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF) values ('TUWSECRA', '', getdate(), 'UBEU', getdate(), 'UBEU')

-- Non-Common/Distinct Columns of TUWRETSECRA with TUWRETSEC to be exported to TUWRETSECRA: LIFFINSOLR_CF (103), LIFFINSOLR_LL (104), PCRETPRGR_CF (105), PCRETPRGR_LL (106)
insert into BEST..TSEGUWTABLE (SGTUWTAB_CF, SGTRQST_T, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF) values ('TUWRETSECRA', '', getdate(), 'UBEU', getdate(), 'UBEU')

go
