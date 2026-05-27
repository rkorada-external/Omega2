Use BSAR
Go

IF OBJECT_ID('dbo.PsLIFSTAREP_RET01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFSTAREP_RET01
    IF OBJECT_ID('dbo.PsLIFSTAREP_RET01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFSTAREP_RET01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFSTAREP_RET01 >>>'
END
go
create procedure PsLIFSTAREP_RET01
(
    @clodat_d datetime,
    @clodat1_d datetime
)
as

declare @date_t       char(8),
         @clodat_year        int,
         @clodat_4           int

select @clodat_year  = convert (int, DatePart (yy, @clodat_d))
select @clodat_4 = (@clodat_year - 4)

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


 select
     clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     ACMTRS_NT=2010,     --ACMTRS_NT,
     CUR_CF,
     CBNMNT_M=(case when TYPMNT_CT = 'CBN' then WRTPRM_M else 0 end),    --CBNMNT_M,
     CBPMNT_M=(case when TYPMNT_CT = 'CBP' then WRTPRM_M else 0 end),    --CBPMNT_M,
     PCMNT_M=(case when TYPMNT_CT = 'PC'  then WRTPRM_M else 0 end),    --PCMNT_M,
     PAMNT_M=0,    --PAMNT_M,
     PRMNT_M=(case when TYPMNT_CT = 'PR'  then WRTPRM_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B,
     YNEWCTR_B=0,  --YNEWCTR_B,
     TNEWCTR_B=0,  --TNEWCTR_B,
     CLMCUTOFF_B=0,  --CLMCUTOFF_B,
     PRMCUTOFF_B=0,  --PRMCUTOFF_B,
     CLMRUNOFF_B=0,  --CLMRUNOFF_B,
     PRMRUNOFF_B=0,  --PRMRUNOFF_B,
     LSTUPD_D into #TLIFSTAREP

        from bsar..tlifprno where clodat_d = @clodat_d
                 and ACCRET_CF = 'R'
                   and WRTPRM_M <> 0



  union all

 ---WRTPRM_M 2010
select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2010,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     WRTPRM_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B,
     0,  --YNEWCTR_B,
     0,  --TNEWCTR_B,
     0,  --CLMCUTOFF_B,
     0,  --PRMCUTOFF_B,
     0,  --CLMRUNOFF_B,
     0,  --PRMRUNOFF_B,
     LSTUPD_D
     -- into #TLIFSTAREP

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat_d
               and ACCRET_CF = 'R' and WRTPRM_M <> 0
 --              and ctr_nf = '04T001473' and uwy_nf = 2000

-- PRMPORTIN_M 2022

union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2022,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PRMPORTIN_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PRMPORTIN_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PRMPORTIN_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PRMPORTIN_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and PRMPORTIN_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2022,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PRMPORTIN_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

         from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and PRMPORTIN_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001



-- PRMPORTOUT_M 2021


union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2021,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PRMPORTOUT_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PRMPORTOUT_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PRMPORTOUT_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PRMPORTOUT_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and PRMPORTOUT_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2021,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PRMPORTOUT_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and PRMPORTOUT_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001



-- PRMRESBEG_M 2064 ou 2504


union all


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 2064 else 2504 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PRMRESBEG_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PRMRESBEG_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PRMRESBEG_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PRMRESBEG_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                 and PRMRESBEG_M <> 0
                 --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 2064 else 2504 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PRMRESBEG_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and PRMRESBEG_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- PRMRESEND_M 2063 2503


union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 2063 else 2503 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PRMRESEND_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PRMRESEND_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PRMRESEND_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PRMRESEND_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
             and PRMRESEND_M <> 0
             --and ctr_nf = '14T000012' --and uwy_nf = 2001



union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 2063 else 2503 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PRMRESEND_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and PRMRESEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


 -- COM_M 2140


union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2140,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then COM_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then COM_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then COM_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then COM_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and COM_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2140,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     COM_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and COM_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001



-- CCOACT_M 2160

union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2160,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CCOACT_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CCOACT_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CCOACT_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CCOACT_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                  and CCOACT_M <> 0
                  --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2160,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CCOACT_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and CCOACT_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- PAIDL_M 2220


union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2220,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PAIDL_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PAIDL_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PAIDL_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PAIDL_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and PAIDL_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2220,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PAIDL_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and PAIDL_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- LOSPORTIN_M 2232
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2232,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then LOSPORTIN_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then LOSPORTIN_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then LOSPORTIN_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then LOSPORTIN_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                    and LOSPORTIN_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2232,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSPORTIN_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and LOSPORTIN_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001



-- LOSPORTOUT_M 2231
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2231,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then LOSPORTOUT_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then LOSPORTOUT_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then LOSPORTOUT_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then LOSPORTOUT_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                    and LOSPORTOUT_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2231,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSPORTOUT_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and LOSPORTOUT_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- LOSREGBEG_M 2244
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2244,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then LOSREGBEG_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then LOSREGBEG_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then LOSREGBEG_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then LOSREGBEG_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                   and LOSREGBEG_M <> 0
                   --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2244,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSREGBEG_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and LOSREGBEG_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001




-- LOSREGEND_M 2243
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2243,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then LOSREGEND_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then LOSREGEND_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then LOSREGEND_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then LOSREGEND_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                  and LOSREGEND_M <> 0
                  --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2243,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSREGEND_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and LOSREGEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- SURRENDER_M 2210
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2210,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then SURRENDER_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then SURRENDER_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then SURRENDER_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then SURRENDER_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                    and SURRENDER_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2210,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     SURRENDER_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and SURRENDER_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- MATURITIES_M 2200
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2200,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then MATURITIES_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then MATURITIES_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then MATURITIES_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then MATURITIES_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                    and MATURITIES_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2200,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     MATURITIES_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and MATURITIES_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- CHGFUNDS_M 2303
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D   )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2303,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CHGFUNDS_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CHGFUNDS_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CHGFUNDS_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CHGFUNDS_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                 and CHGFUNDS_M <> 0
                 --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2303,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CHGFUNDS_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and CHGFUNDS_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- creation liberation 1304 a partir CHGFUNDS_M 1303
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     2304,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CHGFUNDS_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CHGFUNDS_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CHGFUNDS_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CHGFUNDS_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                 and CHGFUNDS_M <> 0
                 --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF,  ACY_NF + 1,
     2304,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CHGFUNDS_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and CHGFUNDS_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- creation liberation 1304 a partir CHGFUNDS_M 1303 pour ACY < bilan -4

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     2304,     --ACMTRS_NT,
     CUR_CF,
     0,    --CBNMNT_M,
     0,    --CBPMNT_M,
     CHGFUNDS_M * -1,    --PCMNT_M,
     CHGFUNDS_M * -1,   --PAMNT_M,
     0,    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d
            and ACY_nf = @clodat_4
            and ACCRET_CF = 'R' and TYPMNT_CT = 'CBN'
                   and CHGFUNDS_M <> 0

-- CHGFUNEND_M 2323
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2323,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CHGFUNEND_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CHGFUNEND_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CHGFUNEND_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CHGFUNEND_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                    and CHGFUNEND_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2323,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CHGFUNEND_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and CHGFUNEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- creation liberation 2324 a partir CHGFUNEND_M 2323
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     2324,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CHGFUNEND_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CHGFUNEND_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CHGFUNEND_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CHGFUNEND_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                 and CHGFUNEND_M <> 0
                 --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- creation liberation 2324 a partir CHGFUNDS_M 2323 pour ACY < bilan -4

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     2324,     --ACMTRS_NT,
     CUR_CF,
     0,    --CBNMNT_M,
     0,    --CBPMNT_M,
     CHGFUNEND_M * -1,    --PCMNT_M,
     CHGFUNEND_M * -1,   --PAMNT_M,
     0,    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d
            and ACY_nf = @clodat_4
            and ACCRET_CF = 'R' and TYPMNT_CT = 'CBN'
                   and CHGFUNEND_M <> 0

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF,  ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     2324,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CHGFUNEND_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and CHGFUNEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- INT_M 2340
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2340,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then INT_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then INT_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then INT_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then INT_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and INT_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2340,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     INT_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and INT_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- ENDADDRES_M 2083 ou 2603
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 2083 else 2603 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDADDRES_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDADDRES_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDADDRES_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDADDRES_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and ENDADDRES_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 1084 ou 1604 a partir ENDADDRES_M 1083 ou 1603

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
 --  JR 25/04/2005  (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
       (case when ACCADMTYP_CT in (1,3) then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     (case when LOB_CF = '30' then 2084 else 2604 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDADDRES_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDADDRES_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDADDRES_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDADDRES_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and ENDADDRES_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 1084 ou 1604 a partir ENDADDRES_M 1083 ou 1603 pour ACY < bilan - 4
--  pour deduire ce montant du cumul 1084 ou 1604
--  On créé PC PA a partir CBN

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005   (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT = 1 then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     (case when LOB_CF = '30' then 2064 else 2504 end), -- ACMTRS_NT
     CUR_CF,
     0,    --CBNMNT_M,
     0,    --CBPMNT_M,
     ENDADDRES_M * -1,    --PCMNT_M,
     ENDADDRES_M * -1,    --PAMNT_M,
     0,    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d
            and ACY_nf = @clodat_4
            and ACCRET_CF = 'R' and TYPMNT_CT = 'CBN'
                   and ENDADDRES_M <> 0
              --     and ctr_nf = '04T000017' --and uwy_nf = 2001
-- FIN AJOUT JR 17/05/2005



-- Creation liberation 1063 ou 1503 a partir ENDADDRES_M 1083 ou 1603
--  pour deduire ce montant du cumul 1063 ou 1503

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 2063 else 2503 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDADDRES_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDADDRES_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDADDRES_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDADDRES_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and ENDADDRES_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 1064 ou 1504 a partir ENDADDRES_M 1083 ou 1603
--  pour deduire ce montant du cumul 1064 ou 1504

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005     (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT in (1, 3) then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     (case when LOB_CF = '30' then 2064 else 2504 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDADDRES_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDADDRES_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDADDRES_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDADDRES_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and ENDADDRES_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 1064 ou 1504 a partir ENDADDRES_M 1083 ou 1603 pour ACY < bilan - 4
--  pour deduire ce montant du cumul 1064 ou 1504
--  On créé PC PA a partir CBN

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005   (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT = 1 then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     (case when LOB_CF = '30' then 2064 else 2504 end), -- ACMTRS_NT
     CUR_CF,
     0,    --CBNMNT_M,
     0,    --CBPMNT_M,
     ENDADDRES_M,    --PCMNT_M,
     ENDADDRES_M,    --PAMNT_M,
     0,    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d
            and ACY_nf = @clodat_4
            and ACCRET_CF = 'R' and TYPMNT_CT = 'CBN'
                   and ENDADDRES_M <> 0
              --     and ctr_nf = '04T000017' --and uwy_nf = 2001
-- FIN AJOUT JR 17/05/2005

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 2083 else 2603 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDADDRES_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and ENDADDRES_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005    (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT in (1, 3) then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     (case when LOB_CF = '30' then 2084 else 2604 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDADDRES_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and ENDADDRES_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 2063 else 2503 end), -- ACMTRS_NT
      CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDADDRES_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and ENDADDRES_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005     (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT in (1, 3) then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     (case when LOB_CF = '30' then 2064 else 2504 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDADDRES_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and ENDADDRES_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- ENDSCOIBNR_M 1263
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2263,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDSCOIBNR_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDSCOIBNR_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDSCOIBNR_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDSCOIBNR_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                   and ENDSCOIBNR_M <> 0
                   --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2263,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDSCOIBNR_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 2264 a partir ENDSCOIBNR_M 2263

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005   (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT = 1 then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     2264,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDSCOIBNR_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDSCOIBNR_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDSCOIBNR_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDSCOIBNR_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d
            and ACCRET_CF = 'R'
                   and ENDSCOIBNR_M <> 0
                --   and ctr_nf = '14T000012' --and uwy_nf = 2001


INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005     (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT = 1 then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     2264,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDSCOIBNR_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- AJOUT JR 29/04/2005
-- Creation liberation 1264 a partir ENDSCOIBNR_M 1263 pour ACY < bilan - 4
--  On créé PC PA a partir CBN

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005   (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT = 1 then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     2264,     --ACMTRS_NT,
     CUR_CF,
     0,    --CBNMNT_M,
     0,    --CBPMNT_M,
     ENDSCOIBNR_M * -1,    --PCMNT_M,
     ENDSCOIBNR_M * -1,    --PAMNT_M,
     0,    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d
            and ACY_nf = @clodat_4
            and ACCRET_CF = 'R' and TYPMNT_CT = 'CBN'
                   and ENDSCOIBNR_M <> 0
              --     and ctr_nf = '04T000017' --and uwy_nf = 2001
-- FIN AJOUT JR 29/04/2005

-- generation 1243 a partir 1263

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


  select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2243, -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDSCOIBNR_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDSCOIBNR_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDSCOIBNR_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDSCOIBNR_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                    and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2243, -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSREGEND_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 2244 a partir ENDSCOIBNR_M 2263

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005 (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT = 1 then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     2244,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDSCOIBNR_M  else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDSCOIBNR_M  else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDSCOIBNR_M  else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDSCOIBNR_M  else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d
            and ACCRET_CF = 'R'
                   and ENDSCOIBNR_M <> 0
                --   and ctr_nf = '14T000012' --and uwy_nf = 2001


INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005 (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT = 1 then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     2244,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDSCOIBNR_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC'  and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 2244 a partir ENDSCOIBNR_M 2263 pour ACY < bilan - 4
--  On créé PC PA a partir CBN

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF,
-- JR 25/04/2005   (case when ACCADMTYP_CT = 2 then UWY_NF else UWY_NF + 1 end),  --UWY_NF,
     (case when ACCADMTYP_CT = 1 then UWY_NF + 1 else UWY_NF end),  --UWY_NF,
     UW_NT, PLC_NT, ACCRET_CF,
     ACY_NF + 1,
     2244,     --ACMTRS_NT,
     CUR_CF,
     0,    --CBNMNT_M,
     0,    --CBPMNT_M,
     ENDSCOIBNR_M,    --PCMNT_M,
     ENDSCOIBNR_M,    --PAMNT_M,
     0,    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d
            and ACY_nf = @clodat_4
            and ACCRET_CF = 'R' and TYPMNT_CT = 'CBN'
                   and ENDSCOIBNR_M <> 0
              --     and ctr_nf = '04T000017' --and uwy_nf = 2001
-- FIN AJOUT JR 17/05/2005

-- BRK_M 2100
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2100,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then BRK_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then BRK_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then BRK_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then BRK_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and BRK_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2100,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     BRK_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and BRK_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- FINREV_M 2350
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2350,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then FINREV_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then FINREV_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then FINREV_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then FINREV_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and FINREV_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     2350,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     FINREV_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and FINREV_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- DACBEG_M 2184 ou 2194

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when SSD_CF = 14 then 2184 else 2194 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then DACBEG_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then DACBEG_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then DACBEG_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then DACBEG_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                    and DACBEG_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when SSD_CF = 14 then 2184 else 2194 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     DACBEG_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and DACBEG_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- DACEND_M 2183 ou 2193
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when SSD_CF = 14 then 2183 else 2193 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then DACEND_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then DACEND_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then DACEND_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then DACEND_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'R'
                     and DACEND_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when SSD_CF = 14 then 2183 else 2193 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     DACEND_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'R' and DACEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


update #TLIFSTAREP
set  a.CLMCUTOFF_B = b.CLMCUTOFF_B,
     a.PRMCUTOFF_B = b.PRMCUTOFF_B,
     a.CLMRUNOFF_B = b.CLMRUNOFF_B,
     a.PRMRUNOFF_B = b.PRMRUNOFF_B
      from #TLIFSTAREP a, BTRT..TSECTION b
         where a.CTR_NF = b.CTR_NF
               and a.uwy_nf = b.uwy_nf
               and a.sec_nf = b.sec_nf

/*
select CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
     SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
     TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D
      from #TLIFSTAREP
        where Abs ( CBNMNT_M + CBPMNT_M + PCMNT_M + PAMNT_M + PRMNT_M ) > 0.000
          order by CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT,
                  ACCRET_CF, ACY_NF, ACMTRS_NT

*/

insert #TLIFPRNO
(
    CLODAT_D,
    CTR_NF,
    SEC_NF,
    UWY_NF,
    ACCRET_CF,
    TYPMNT_CT,
    CED_NF,
    ESTCRB_CF,
    COMMAC_B,
    SECSTS_CT,
    SECACCSTS_CT,
    ESTCTR_CF,
    ESTSEC_NF,
    ACCADMTYP_CT,
    AUTUPD_B
)

select  CLODAT_D, CTR_NF, SEC_NF, UWY_NF, ACCRET_CF, TYPMNT_CT, CED_NF, ESTCRB_CF, COMMAC_B, SECSTS_CT,
    SECACCSTS_CT, ESTCTR_CF, ESTSEC_NF, ACCADMTYP_CT, AUTUPD_B
    from BSAR..TLIFPRNO
      where    CLODAT_D  = @clodat_d
          and   typmnt_ct in  ('PC', 'CBN', 'PR', 'CBP')


--   execute BSAR..PsLIFSTAREP_02 with recompile

--mise a jour des données souscription a partir PC ou CBN ou PR ou CBP
/*
insert #CODEMVT (CTR_NF, SEC_NF, UWy_NF, CODEMVT_NF)
select CTR_NF, SEC_NF, UWy_NF, min(CODEMVT_NF)
                                    from #TLIFSTAREP

---
insert #TSOUSCRIPT
   (SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CED_NF, ACCRET_CF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B
    )
select a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CED_NF, a.ACCRET_CF, a.SECSTS_CT,
    a.SECACCSTS_CT, a.ACCADMTYP_CT, a.ESTCRB_CF, a.ESTCTR_CF, a.ESTSEC_NF, a.COMMAC_B, a.AUTUPD_B
    from #TLIFSTAREP a, #CODEMVT c
                         where a.CTR_NF = c.CTR_NF
                                    and    a.SEC_NF = c.SEC_NF
                                      and    a.UWY_NF = c.UWY_NF
                                      and a.CODEMVT_NF = c.CODEMVT_NF



update #TLIFSTAREP
set CED_NF = b.CED_NF,
    ACCRET_CF = b.ACCRET_CF,
    SECSTS_CT = b.SECSTS_CT,
    SECACCSTS_CT = b.SECACCSTS_CT,
    ACCADMTYP_CT = b.ACCADMTYP_CT,
    ESTCRB_CF = b.ESTCRB_CF,
    ESTCTR_CF = b.ESTCTR_CF,
    ESTSEC_NF = b.ESTSEC_NF,
    COMMAC_B  = b.COMMAC_B,
    AUTUPD_B  = b.AUTUPD_B
      from #TLIFSTAREP a, #TSOUSCRIPT b
      where a.CTR_NF = b.CTR_NF
           and    a.SEC_NF = b.SEC_NF
           and    a.UWY_NF = b.UWY_NF
*/
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
GRANT EXECUTE ON dbo.PsLIFSTAREP_RET01 TO GOMEGA
go
IF OBJECT_ID('dbo.PsLIFSTAREP_RET01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFSTAREP_RET01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFSTAREP_RET01 >>>'
go
EXEC sp_procxmode 'dbo.PsLIFSTAREP_RET01','unchained'
go



