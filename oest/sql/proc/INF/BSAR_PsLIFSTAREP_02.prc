Use BSAR
Go

create table #TLIFCONV (
     CLODAT_D             datetime not null,
     SSD_CF               USSD_CF  not null,
     CTR_NF               UCTR_NF  not null,
     END_NT               UEND_NT  not null,
     SEC_NF               USEC_NF  not null,
     UWY_NF               UUWY_NF  not null,
     UW_NT                UUW_NT  not null,
     PLC_NT               UPLC_NT  not null,
     ACCRET_CF            char(1) not null,
     ACY_NF               smallint not null,
     ACMTRS_NT            smallint not null,
     CURPR_CF             UCUR_CF  not null,
     PRMNT_M              UAMT_M  null,
     CURPC_CF             UCUR_CF  not null,
     EXC1_R               ULNGDEC    NOT NULL,
     EXC2_R               ULNGDEC    NOT NULL
     )

create table #TLIFSTAREP (
     CLODAT_D             datetime not null,
     SSD_CF               USSD_CF  not null,
     CTR_NF               UCTR_NF  not null,
     END_NT               UEND_NT  not null,
     SEC_NF               USEC_NF  not null,
     UWY_NF               UUWY_NF  not null,
     UW_NT                UUW_NT  not null,
     LOB_CF               ULOB_CF  null,
     PLC_NT               UPLC_NT  not null,
     ACCRET_CF            char(1) not null,
     ACY_NF               smallint not null,
     ACMTRS_NT            smallint not null,
     CUR_CF            UCUR_CF  not null,
     CBNMNT_M             UAMT_M  null,
     CBPMNT_M             UAMT_M  null,
     PCMNT_M              UAMT_M  null,
     PAMNT_M              UAMT_M  null,
     PRMNT_M              UAMT_M  null,
     CED_NF               UCLI_NF  null,
     SECSTS_CT            UCTRSTS_CT  not null,
     SECACCSTS_CT         UACCSTS_CT  null,
     ACCADMTYP_CT         UACCADMTYP_CT  null,
     ESTCRB_CF            char(1) null,
     ESTCTR_CF            UCTR_NF  null,
     ESTSEC_NF            USEC_NF  null,
     COMMAC_B             bit default 0 not null,
     AUTUPD_B             bit default 0 not null,
     YNEWCTR_B            bit default 0 not null,
     TNEWCTR_B            bit default 0 not null,
     CLMCUTOFF_B          bit default 0 not null,
     PRMCUTOFF_B          bit default 0 not null,
     CLMRUNOFF_B          bit default 0 not null,
     PRMRUNOFF_B          bit default 0 not null,
     LSTUPD_D             UUPD_D  not null
 )

CREATE TABLE #TLIFPRNO
(
    CLODAT_D     datetime      NOT NULL,
    CTR_NF       UCTR_NF       NOT NULL,
    SEC_NF       USEC_NF       NOT NULL,
    UWY_NF       UUWY_NF       NOT NULL,
    ACCRET_CF    char(1)       NOT NULL,
    TYPMNT_CT    char(3)       NOT NULL,
    CED_NF       UCLI_NF       NULL,
    ESTCRB_CF    char(1)       NULL,
    COMMAC_B     bit           NOT NULL,
    SECSTS_CT    UCTRSTS_CT    NOT NULL,
    SECACCSTS_CT UACCSTS_CT    NULL,
    ESTCTR_CF    UCTR_NF       NULL,
    ESTSEC_NF    USEC_NF       NULL,
    ACCADMTYP_CT UACCADMTYP_CT NULL,
    AUTUPD_B     bit           NOT NULL
)

CREATE TABLE #TLIFPRNO2
(
    CLODAT_D     datetime      NOT NULL,
    CTR_NF       UCTR_NF       NOT NULL,
    SEC_NF       USEC_NF       NOT NULL,
    TYPMNT_CT    char(3)       NOT NULL,
    SECACCSTS_CT UACCSTS_CT    NULL,
    ACCADMTYP_CT UACCADMTYP_CT NULL
)

CREATE TABLE #TLIFPRNO3
(
    CLODAT_D     datetime      NOT NULL,
    CTR_NF       UCTR_NF       NOT NULL,
    SEC_NF       USEC_NF       NOT NULL,
    ACY_NF       UUWY_NF       NOT NULL,
    TYPMNT_CT    char(3)       NOT NULL,
    COMMAC_B     bit           NOT NULL,
    AUTUPD_B     bit           NOT NULL
)

go

IF OBJECT_ID('dbo.PsLIFSTAREP_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFSTAREP_02
    IF OBJECT_ID('dbo.PsLIFSTAREP_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFSTAREP_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFSTAREP_02 >>>'
END
go

create procedure PsLIFSTAREP_02
as


--mise a jour des données souscription a partir PC ou CBN ou PR ou CBP

update #TLIFSTAREP
set CED_NF = b.CED_NF,
    ACCRET_CF = b.ACCRET_CF,
    SECSTS_CT = b.SECSTS_CT,
    SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT,
    ESTCRB_CF = b.ESTCRB_CF,
    ESTCTR_CF = b.ESTCTR_CF,
    ESTSEC_NF = b.ESTSEC_NF /*,
    COMMAC_B  = b.COMMAC_B,
    AUTUPD_B  = b.AUTUPD_B   */
      from #TLIFSTAREP a, #TLIFPRNO b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'PR'


update #TLIFSTAREP
set CED_NF = b.CED_NF,
    ACCRET_CF = b.ACCRET_CF,
    SECSTS_CT = b.SECSTS_CT,
    SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT,
    ESTCRB_CF = b.ESTCRB_CF,
    ESTCTR_CF = b.ESTCTR_CF,
    ESTSEC_NF = b.ESTSEC_NF /*,
    COMMAC_B  = b.COMMAC_B,
    AUTUPD_B  = b.AUTUPD_B  */
      from #TLIFSTAREP a, #TLIFPRNO b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'CBP'


update #TLIFSTAREP
set CED_NF = b.CED_NF,
    ACCRET_CF = b.ACCRET_CF,
    SECSTS_CT = b.SECSTS_CT,
    SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT,
    ESTCRB_CF = b.ESTCRB_CF,
    ESTCTR_CF = b.ESTCTR_CF,
    ESTSEC_NF = b.ESTSEC_NF /*,
    COMMAC_B  = b.COMMAC_B,
    AUTUPD_B  = b.AUTUPD_B  */
      from #TLIFSTAREP a, #TLIFPRNO b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'CBN'


update #TLIFSTAREP
set CED_NF = b.CED_NF,
    ACCRET_CF = b.ACCRET_CF,
    SECSTS_CT = b.SECSTS_CT,
    SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT,
    ESTCRB_CF = b.ESTCRB_CF,
    ESTCTR_CF = b.ESTCTR_CF,
    ESTSEC_NF = b.ESTSEC_NF /*,
    COMMAC_B  = b.COMMAC_B,
    AUTUPD_B  = b.AUTUPD_B  */
      from #TLIFSTAREP a, #TLIFPRNO b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'PC'

truncate table #TLIFPRNO

update #TLIFSTAREP
set SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT
      from #TLIFSTAREP a, #TLIFPRNO2 b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and   b.typmnt_ct = 'PR'

update #TLIFSTAREP
set SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT
      from #TLIFSTAREP a, #TLIFPRNO2 b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and   b.typmnt_ct = 'CBP'



update #TLIFSTAREP
set SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT
      from #TLIFSTAREP a, #TLIFPRNO2 b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and   b.typmnt_ct = 'CBN'

update #TLIFSTAREP
set SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT
      from #TLIFSTAREP a, #TLIFPRNO2 b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and   b.typmnt_ct = 'PC'

truncate table #TLIFPRNO2

update #TLIFSTAREP
set     COMMAC_B  = b.COMMAC_B,
        AUTUPD_B  = b.AUTUPD_B
      from #TLIFSTAREP a, #TLIFPRNO3 b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.ACY_NF = b.ACY_NF
           and   b.typmnt_ct = 'PR'

update #TLIFSTAREP
set     COMMAC_B  = b.COMMAC_B,
        AUTUPD_B  = b.AUTUPD_B
      from #TLIFSTAREP a, #TLIFPRNO3 b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.ACY_NF = b.ACY_NF
           and   b.typmnt_ct = 'CBP'

update #TLIFSTAREP
set     COMMAC_B  = b.COMMAC_B,
        AUTUPD_B  = b.AUTUPD_B
      from #TLIFSTAREP a, #TLIFPRNO3 b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.ACY_NF = b.ACY_NF
           and   b.typmnt_ct = 'CBN'

update #TLIFSTAREP
set     COMMAC_B  = b.COMMAC_B,
        AUTUPD_B  = b.AUTUPD_B
      from #TLIFSTAREP a, #TLIFPRNO3 b
      where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.ACY_NF = b.ACY_NF
           and   b.typmnt_ct = 'PC'


truncate table #TLIFPRNO3


INSERT #TLIFCONV
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CURPR_CF, PRMNT_M, CURPC_CF, EXC1_R, EXC2_R )
select a.clodat_d, a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.PLC_NT, a.ACCRET_CF,
       a.ACY_NF, a.ACMTRS_NT, a.CUR_CF, a.PRMNT_M, b.CUR_CF, 0, 0
         from #TLIFSTAREP a, BSAR..TLIFPRNO b
         where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'PC'
           and   a.CUR_CF <> b.CUR_CF

/* MIS en commentaire le 13/06/2005

INSERT #TLIFCONV
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CURPR_CF, PRMNT_M, CURPC_CF, EXC1_R, EXC2_R )
select a.clodat_d, a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.PLC_NT, a.ACCRET_CF,
       a.ACY_NF, a.ACMTRS_NT, a.CUR_CF, a.PRMNT_M, b.CUR_CF, 0, 0
         from #TLIFSTAREP a, BSAR..TLIFPRNO b
         where    a.CLODAT_D  = '20050331'
           and   a.CTR_NF = '04T000139'
           and   a.UWY_NF = 2000
           and    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'CBN'

INSERT #TLIFCONV
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CURPR_CF, PRMNT_M, CURPC_CF, EXC1_R, EXC2_R )
select a.clodat_d, a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.PLC_NT, a.ACCRET_CF,
       a.ACY_NF, a.ACMTRS_NT, a.CUR_CF, a.PRMNT_M, b.CUR_CF, 0, 0
         from #TLIFSTAREP a, BSAR..TLIFPRNO b
         where    a.CLODAT_D  = '20050331'
           and   a.CTR_NF = '04T000884'
           and   a.UWY_NF = 2000
           and    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'CBN'

INSERT #TLIFCONV
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CURPR_CF, PRMNT_M, CURPC_CF, EXC1_R, EXC2_R )
select a.clodat_d, a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.PLC_NT, a.ACCRET_CF,
       a.ACY_NF, a.ACMTRS_NT, a.CUR_CF, a.PRMNT_M, b.CUR_CF, 0, 0
         from #TLIFSTAREP a, BSAR..TLIFPRNO b
         where    a.CLODAT_D  = '20050331'
           and   a.CTR_NF = '04T001288'
           and   a.UWY_NF = 2000
           and    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'CBN'

INSERT #TLIFCONV
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CURPR_CF, PRMNT_M, CURPC_CF, EXC1_R, EXC2_R )
select a.clodat_d, a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.PLC_NT, a.ACCRET_CF,
       a.ACY_NF, a.ACMTRS_NT, a.CUR_CF, a.PRMNT_M, b.CUR_CF, 0, 0
         from #TLIFSTAREP a, BSAR..TLIFPRNO b
         where    a.CLODAT_D  = '20050331'
           and   a.CTR_NF = '04Z086220'
           and   a.UWY_NF = 2000
           and    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'CBN'

FIN MIS en commentaire le 13/06/2005 */



update #TLIFCONV
Set EXC1_R = (case when EXC_R > 0  then EXC_R else 1 end)
--Set EXC1_R = EXC_R
       from  #TLIFCONV a, BREF..TCURQUOT b
where a.SSD_CF = b.SSD_CF
and	a.CURPR_CF = b.CUR_CF
and	b.EXC_D = a.CLODAT_D
--and	b.EXC_D = a.CLODAT_D
and	b.ACTCOD_B	= 1
--and	a.EXC_D = (select max(B.EXC_D) from BREF..TCURQUOT B
--     			where B.SSD_CF = A.SSD_CF
--			and B.CUR_CF = A.CUR_CF
--	 		and B.EXC_D <= @d_fin
--	  		and B.EXC_D >= @d_debut
--			and B.ACTCOD_B = 1)

update #TLIFCONV
Set EXC2_R = (case when EXC_R > 0  then EXC_R else 1 end)
--Set EXC2_R = EXC_R
 from  #TLIFCONV a, BREF..TCURQUOT b
where a.SSD_CF = b.SSD_CF
and	a.CURPC_CF = b.CUR_CF
and	b.EXC_D = a.CLODAT_D
--and	b.EXC_D = a.CLODAT_D
and	b.ACTCOD_B	= 1

Set arithabort numeric_truncation off

update #TLIFCONV
Set PRMNT_M = (PRMNT_M * EXC1_R / EXC2_R)
   where EXC1_R <> 0 and EXC2_R <> 0

Set arithabort numeric_truncation on


update #TLIFSTAREP
set a.CUR_CF = b.CURPC_CF,
    a.PRMNT_M = b.PRMNT_M
      from #TLIFSTAREP a, #TLIFCONV b
      where    a.CLODAT_D  = b.CLODAT_D
         AND   a.SSD_CF    = b.SSD_CF
         AND   a.CTR_NF    = b.CTR_NF
         AND   a.END_NT    = b.END_NT
         AND   a.SEC_NF    = b.SEC_NF
         AND   a.UWY_NF    = b.UWY_NF
         AND   a.UW_NT     = b.UW_NT
         AND   a.PLC_NT    = b.PLC_NT
         AND   a.ACCRET_CF = b.ACCRET_CF
         AND   a.ACY_NF    = b.ACY_NF
         AND   a.ACMTRS_NT = b.ACMTRS_NT
         AND   a.CUR_CF    = b.CURPR_CF

truncate table #TLIFCONV

INSERT #TLIFCONV
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CURPR_CF, PRMNT_M, CURPC_CF, EXC1_R, EXC2_R )
select a.clodat_d, a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.PLC_NT, a.ACCRET_CF,
       a.ACY_NF, a.ACMTRS_NT, a.CUR_CF, a.PRMNT_M, b.CUR_CF, 0, 0
         from #TLIFSTAREP a, BSAR..TLIFPRNO b
         where    a.CLODAT_D  = b.CLODAT_D
           and   a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
           and   b.typmnt_ct = 'CBN'
           and   a.CUR_CF <> b.CUR_CF

update #TLIFCONV
Set EXC1_R = (case when EXC_R > 0  then EXC_R else 1 end)
      from  #TLIFCONV a, BREF..TCURQUOT b
where a.SSD_CF = b.SSD_CF
and	a.CURPR_CF = b.CUR_CF
and	b.EXC_D = a.CLODAT_D
and	b.ACTCOD_B	= 1

update #TLIFCONV
Set EXC2_R = (case when EXC_R > 0  then EXC_R else 1 end)
    from  #TLIFCONV a, BREF..TCURQUOT b
where a.SSD_CF = b.SSD_CF
and	a.CURPC_CF = b.CUR_CF
and	b.EXC_D = a.CLODAT_D
and	b.ACTCOD_B	= 1

Set arithabort numeric_truncation off

update #TLIFCONV
Set PRMNT_M = (PRMNT_M * EXC1_R / EXC2_R)
   where EXC1_R <> 0 and EXC2_R <> 0

Set arithabort numeric_truncation on


update #TLIFSTAREP
set a.CUR_CF = b.CURPC_CF,
    a.PRMNT_M = b.PRMNT_M
      from #TLIFSTAREP a, #TLIFCONV b
      where    a.CLODAT_D  = b.CLODAT_D
         AND   a.SSD_CF    = b.SSD_CF
         AND   a.CTR_NF    = b.CTR_NF
         AND   a.END_NT    = b.END_NT
         AND   a.SEC_NF    = b.SEC_NF
         AND   a.UWY_NF    = b.UWY_NF
         AND   a.UW_NT     = b.UW_NT
         AND   a.PLC_NT    = b.PLC_NT
         AND   a.ACCRET_CF = b.ACCRET_CF
         AND   a.ACY_NF    = b.ACY_NF
         AND   a.ACMTRS_NT = b.ACMTRS_NT
         AND   a.CUR_CF    = b.CURPR_CF



select CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
     SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
     TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D
      from #TLIFSTAREP
        where Abs ( CBNMNT_M + CBPMNT_M + PCMNT_M + PAMNT_M + PRMNT_M ) > 0.000
          order by CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT,
                  ACCRET_CF, ACY_NF, ACMTRS_NT


return 0
go
GRANT EXECUTE ON dbo.PsLIFSTAREP_02 TO GOMEGA
go
IF OBJECT_ID('dbo.PsLIFSTAREP_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFSTAREP_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFSTAREP_02 >>>'
go


