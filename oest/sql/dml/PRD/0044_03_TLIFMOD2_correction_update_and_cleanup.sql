--
-- Update Creation date in TLIFMOD2 where applicable
--


update BEST..TLIFMOD2
   set CRE_D = T2.NEW_CRE_D
  from BEST..TLIFMOD2 T1, BTRAV..TLIFMOD2_CORRECTION T2
 where T1.CTR_NF = T2.CTR_NF
   and T1.SEC_NF = T2.SEC_NF
   and T1.CRE_D = T2.CRE_D
   and T1.BALSHEY_NF = T2.BALSHEY_NF
   and T1.BALSHTMTH_NF = T2.BALSHTMTH_NF
   and T2.NEW_CRE_D IS NOT NULL
   and T2.CRE_D > '2015-01-10 06:00:00'
   and T2.creusr_cf != 'dbo'	
	
go

delete BEST..TLIFMOD2
  from BEST..TLIFMOD2 T2
 where NOT EXISTS (select 1 from BEST..TLIFMOD T1
                           where T1.CTR_NF = T2.CTR_NF
                             and T1.SEC_NF = T2.SEC_NF
                             and T1.CRE_D = T2.CRE_D
                             and T1.BALSHEY_NF = T2.BALSHEY_NF
                             and T1.BALSHTMTH_NF = T2.BALSHTMTH_NF
			     )
and T2.creusr_cf != 'dbo'
and T2.CRE_D > '2015-01-10 06:00:00'

go
