--
-- Fill in the temporary tables
--

DELETE BTRAV..TLIFMOD2
go

INSERT INTO BTRAV..TLIFMOD2 (CTR_NF,SEC_NF,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,COMACC_B,PRIPRMAMT_M,AFTPRMAMT_M,PRIRESTECAMT_M,AFTRESTECAMT_M,PRIRESDACAMT_M,AFTRESDACAMT_M,PRIRESFINAMT_M,AFTRESFINAMT_M,CREUSR_CF,LSTUPD_D,LSTUPDUSR_CF,GAAP_NT)
SELECT CTR_NF,SEC_NF,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,COMACC_B,PRIPRMAMT_M,AFTPRMAMT_M,PRIRESTECAMT_M,AFTRESTECAMT_M,PRIRESDACAMT_M,AFTRESDACAMT_M,PRIRESFINAMT_M,AFTRESFINAMT_M,CREUSR_CF,LSTUPD_D,LSTUPDUSR_CF,GAAP_NT
FROM BEST..TLIFMOD2
go

DELETE BTRAV..TLIFMOD2_CORRECTION
go

INSERT INTO BTRAV..TLIFMOD2_CORRECTION (CTR_NF,SEC_NF,CRE_D,BALSHEY_NF,BALSHTMTH_NF,CREUSR_CF,NEW_CRE_D)
SELECT DISTINCT CTR_NF,SEC_NF,CRE_D,BALSHEY_NF,BALSHTMTH_NF,CREUSR_CF,null
FROM BEST..TLIFMOD2
GROUP BY CTR_NF,SEC_NF,CRE_D,BALSHEY_NF,BALSHTMTH_NF
go

--
-- 12h vs 24h format correction
--

update BTRAV..TLIFMOD2_CORRECTION
   set NEW_CRE_D = T1.CRE_D
  from BTRAV..TLIFMOD2_CORRECTION T2, BEST..TLIFMOD T1
 where T1.CTR_NF = T2.CTR_NF
   and T1.SEC_NF = T2.SEC_NF
   and T1.CRE_D = DATEADD(HOUR, 12, T2.CRE_D)
   and T1.BALSHEY_NF = T2.BALSHEY_NF
   and T1.BALSHTMTH_NF = T2.BALSHTMTH_NF
   and T2.CRE_D > '2015-01-10 06:00:00'
   and T2.creusr_cf != 'dbo'
   and NOT EXISTS (select 1 from BEST..TLIFMOD2 T3 where T1.CTR_NF = T3.CTR_NF
                                                     and T1.SEC_NF = T3.SEC_NF
                                                     and T1.CRE_D = T3.CRE_D
                                                     and T1.BALSHEY_NF = T3.BALSHEY_NF
                                                     and T1.BALSHTMTH_NF = T3.BALSHTMTH_NF
                        )

go

--
-- Erroneous minutes values on TLIFMOD2 correction
--

update BTRAV..TLIFMOD2_CORRECTION
   set NEW_CRE_D = T1.CRE_D
  from BTRAV..TLIFMOD2_CORRECTION T2, BEST..TLIFMOD T1
 where T1.CTR_NF = T2.CTR_NF
   and T1.SEC_NF = T2.SEC_NF
   and T1.CRE_D != T2.CRE_D
   and T1.CRE_D BETWEEN T2.CRE_D AND DATEADD(MINUTE, 15, T2.CRE_D)
   and T1.BALSHEY_NF = T2.BALSHEY_NF
   and T1.BALSHTMTH_NF = T2.BALSHTMTH_NF
   and NOT EXISTS (select 1 from BEST..TLIFMOD2 T3 where T1.CTR_NF = T3.CTR_NF
                                                     and T1.SEC_NF = T3.SEC_NF
                                                     and T1.CRE_D = T3.CRE_D
                                                     and T1.BALSHEY_NF = T3.BALSHEY_NF
                                                     and T1.BALSHTMTH_NF = T3.BALSHTMTH_NF
				)
   and NOT EXISTS (select 1 from BTRAV..TLIFMOD2_CORRECTION T4 where T1.CTR_NF = T4.CTR_NF
																 and T1.SEC_NF = T4.SEC_NF
																 and T1.CRE_D = T4.NEW_CRE_D
																 and T1.BALSHEY_NF = T4.BALSHEY_NF
																 and T1.BALSHTMTH_NF = T4.BALSHTMTH_NF
				)
   and T2.CRE_D > '2015-01-10 06:00:00'
   and T2.creusr_cf != 'dbo'

go
