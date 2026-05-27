Use BSAR
Go

IF OBJECT_ID('dbo.PsLIFSTAREP_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFSTAREP_01
    IF OBJECT_ID('dbo.PsLIFSTAREP_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFSTAREP_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFSTAREP_01 >>>'
END
go
create procedure PsLIFSTAREP_01
(
    @clodat_d datetime,
    @clodat1_d datetime
)
as

/* modification 1

      13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
*/


declare @date_t       char(8),
         @clodat_year        int,
         @clodat_4           int,
         @acy                int


select @clodat_year  = convert (int, DatePart (yy, @clodat_d))
select @clodat_4 = (@clodat_year - 4)
select @acy = convert(int,convert(char(4), @clodat_d,112))+2

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
     ACMTRS_NT=1010,     --ACMTRS_NT,
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
                 and ACCRET_CF = 'A'
                   and WRTPRM_M <> 0



  union all

 ---WRTPRM_M 1010
select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1010,     --ACMTRS_NT,
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
               and ACCRET_CF = 'A' and WRTPRM_M <> 0
 --              and ctr_nf = '04T001473' and uwy_nf = 2000

-- PRMPORTIN_M 1022

union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1022,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PRMPORTIN_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PRMPORTIN_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PRMPORTIN_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PRMPORTIN_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                     and PRMPORTIN_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1022,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PRMPORTIN_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

         from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and PRMPORTIN_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001



-- PRMPORTOUT_M 1021


union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1021,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PRMPORTOUT_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PRMPORTOUT_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PRMPORTOUT_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PRMPORTOUT_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                     and PRMPORTOUT_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1021,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PRMPORTOUT_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and PRMPORTOUT_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001



-- PRMRESBEG_M 1064 ou 1504


union all


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 1064 else 1504 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PRMRESBEG_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PRMRESBEG_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PRMRESBEG_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PRMRESBEG_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                 and PRMRESBEG_M <> 0
                 --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 1064 else 1504 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PRMRESBEG_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and PRMRESBEG_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- PRMRESEND_M 1063 1503


union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 1063 else 1503 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PRMRESEND_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PRMRESEND_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PRMRESEND_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PRMRESEND_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
             and PRMRESEND_M <> 0
             --and ctr_nf = '14T000012' --and uwy_nf = 2001



union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 1063 else 1503 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PRMRESEND_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and PRMRESEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


 -- COM_M 1140


union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1140,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then COM_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then COM_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then COM_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then COM_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                     and COM_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1140,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     COM_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and COM_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001



-- CCOACT_M 1160

union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1160,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CCOACT_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CCOACT_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CCOACT_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CCOACT_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                  and CCOACT_M <> 0
                  --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1160,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CCOACT_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and CCOACT_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- PAIDL_M 1220


union all

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1220,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then PAIDL_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then PAIDL_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then PAIDL_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then PAIDL_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D
        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                     and PAIDL_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001


union all

select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1220,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     PAIDL_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and PAIDL_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- LOSPORTIN_M 1232
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1232,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then LOSPORTIN_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then LOSPORTIN_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then LOSPORTIN_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then LOSPORTIN_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                    and LOSPORTIN_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1232,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSPORTIN_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and LOSPORTIN_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001



-- LOSPORTOUT_M 1231
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1231,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then LOSPORTOUT_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then LOSPORTOUT_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then LOSPORTOUT_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then LOSPORTOUT_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                    and LOSPORTOUT_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1231,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSPORTOUT_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and LOSPORTOUT_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- LOSREGBEG_M 1244
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1244,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then LOSREGBEG_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then LOSREGBEG_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then LOSREGBEG_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then LOSREGBEG_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                   and LOSREGBEG_M <> 0
                   --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1244,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSREGBEG_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and LOSREGBEG_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001




-- LOSREGEND_M 1243
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1243,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then LOSREGEND_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then LOSREGEND_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then LOSREGEND_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then LOSREGEND_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                  and LOSREGEND_M <> 0
                  --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1243,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSREGEND_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and LOSREGEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- SURRENDER_M 1210
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1210,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then SURRENDER_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then SURRENDER_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then SURRENDER_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then SURRENDER_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                    and SURRENDER_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1210,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     SURRENDER_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and SURRENDER_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- MATURITIES_M 1200
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1200,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then MATURITIES_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then MATURITIES_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then MATURITIES_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then MATURITIES_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                    and MATURITIES_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1200,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     MATURITIES_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and MATURITIES_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- CHGFUNDS_M 1303
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D   )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1303,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CHGFUNDS_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CHGFUNDS_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CHGFUNDS_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CHGFUNDS_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                 and CHGFUNDS_M <> 0
                 --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1303,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CHGFUNDS_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and CHGFUNDS_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- creation liberation 1304 a partir CHGFUNDS_M 1303
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     1304,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CHGFUNDS_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CHGFUNDS_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CHGFUNDS_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CHGFUNDS_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                 and CHGFUNDS_M <> 0
                 --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF,  ACY_NF + 1,
     1304,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CHGFUNDS_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and CHGFUNDS_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- creation liberation 1304 a partir CHGFUNDS_M 1303 pour ACY < bilan -4

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     1304,     --ACMTRS_NT,
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
            and ACCRET_CF = 'A' and TYPMNT_CT = 'CBN'
                   and CHGFUNDS_M <> 0

-- CHGFUNEND_M 1323
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1323,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CHGFUNEND_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CHGFUNEND_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CHGFUNEND_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CHGFUNEND_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                    and CHGFUNEND_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1323,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CHGFUNEND_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and CHGFUNEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- creation liberation 1324 a partir CHGFUNEND_M 1323
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     1324,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then CHGFUNEND_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then CHGFUNEND_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then CHGFUNEND_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then CHGFUNEND_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                 and CHGFUNEND_M <> 0
                 --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- creation liberation 1324 a partir CHGFUNDS_M 1323 pour ACY < bilan -4

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )

 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     1324,     --ACMTRS_NT,
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
            and ACCRET_CF = 'A' and TYPMNT_CT = 'CBN'
                   and CHGFUNEND_M <> 0

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF,  ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF + 1,
     1324,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     CHGFUNEND_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and CHGFUNEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- INT_M 1340
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1340,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then INT_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then INT_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then INT_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then INT_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                     and INT_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1340,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     INT_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and INT_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- ENDADDRES_M 1083 ou 1603
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 1083 else 1603 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDADDRES_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDADDRES_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDADDRES_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDADDRES_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
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
     (case when LOB_CF = '30' then 1084 else 1604 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDADDRES_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDADDRES_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDADDRES_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDADDRES_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
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
     (case when LOB_CF = '30' then 1064 else 1504 end), -- ACMTRS_NT
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
            and ACCRET_CF = 'A' and TYPMNT_CT = 'CBN'
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
     (case when LOB_CF = '30' then 1063 else 1503 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDADDRES_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDADDRES_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDADDRES_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDADDRES_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
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
     (case when LOB_CF = '30' then 1064 else 1504 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDADDRES_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDADDRES_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDADDRES_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDADDRES_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
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
     (case when LOB_CF = '30' then 1064 else 1504 end), -- ACMTRS_NT
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
            and ACCRET_CF = 'A' and TYPMNT_CT = 'CBN'
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
     (case when LOB_CF = '30' then 1083 else 1603 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDADDRES_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and ENDADDRES_M <> 0
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
     (case when LOB_CF = '30' then 1084 else 1604 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDADDRES_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and ENDADDRES_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when LOB_CF = '30' then 1063 else 1503 end), -- ACMTRS_NT
      CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDADDRES_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and ENDADDRES_M <> 0
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
     (case when LOB_CF = '30' then 1064 else 1504 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDADDRES_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and ENDADDRES_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- ENDSCOIBNR_M 1263
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1263,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDSCOIBNR_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDSCOIBNR_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDSCOIBNR_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDSCOIBNR_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                   and ENDSCOIBNR_M <> 0
                   --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1263,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDSCOIBNR_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 1264 a partir ENDSCOIBNR_M 1263

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
     1264,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDSCOIBNR_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDSCOIBNR_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDSCOIBNR_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDSCOIBNR_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d
            and ACCRET_CF = 'A'
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
     1264,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDSCOIBNR_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and ENDSCOIBNR_M <> 0
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
     1264,     --ACMTRS_NT,
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
            and ACCRET_CF = 'A' and TYPMNT_CT = 'CBN'
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
     1243, -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDSCOIBNR_M * -1 else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDSCOIBNR_M * -1 else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDSCOIBNR_M * -1 else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDSCOIBNR_M * -1 else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                    and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1243, -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     LOSREGEND_M * -1,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 1244 a partir ENDSCOIBNR_M 1263

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
     1244,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then ENDSCOIBNR_M  else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then ENDSCOIBNR_M  else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then ENDSCOIBNR_M  else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then ENDSCOIBNR_M  else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d
            and ACCRET_CF = 'A'
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
     1244,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     ENDSCOIBNR_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC'  and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and ENDSCOIBNR_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- Creation liberation 1244 a partir ENDSCOIBNR_M 1263 pour ACY < bilan - 4
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
     1244,     --ACMTRS_NT,
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
            and ACCRET_CF = 'A' and TYPMNT_CT = 'CBN'
                   and ENDSCOIBNR_M <> 0
              --     and ctr_nf = '04T000017' --and uwy_nf = 2001
-- FIN AJOUT JR 17/05/2005

-- BRK_M 1100
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1100,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then BRK_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then BRK_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then BRK_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then BRK_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                     and BRK_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1100,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     BRK_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and BRK_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- FINREV_M 1350
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1350,     --ACMTRS_NT,
     CUR_CF,
     (case when TYPMNT_CT = 'CBN' then FINREV_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then FINREV_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then FINREV_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then FINREV_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                     and FINREV_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     1350,     --ACMTRS_NT,
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     FINREV_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

      from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and FINREV_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

-- DACBEG_M 1184 ou 1194

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when SSD_CF = 14 then 1184 else 1194 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then DACBEG_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then DACBEG_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then DACBEG_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then DACBEG_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                    and DACBEG_M <> 0
                    --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when SSD_CF = 14 then 1184 else 1194 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     DACBEG_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and DACBEG_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001


-- DACEND_M 1183 ou 1193
INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


 select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when SSD_CF = 14 then 1183 else 1193 end), -- ACMTRS_NT
      CUR_CF,
     (case when TYPMNT_CT = 'CBN' then DACEND_M else 0 end),    --CBNMNT_M,
     (case when TYPMNT_CT = 'CBP' then DACEND_M else 0 end),    --CBPMNT_M,
     (case when TYPMNT_CT = 'PC'  then DACEND_M else 0 end),    --PCMNT_M,
     0,    --PAMNT_M,
     (case when TYPMNT_CT = 'PR'  then DACEND_M else 0 end),    --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D


        from bsar..tlifprno where clodat_d = @clodat_d and ACCRET_CF = 'A'
                     and DACEND_M <> 0
                     --and ctr_nf = '14T000012' --and uwy_nf = 2001

INSERT #TLIFSTAREP
    (CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
    ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
    TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D  )


select
     @clodat_d, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
     (case when SSD_CF = 14 then 1183 else 1193 end), -- ACMTRS_NT
     CUR_CF,
     0,  --CBNMNT_M,
     0,  --CBPMNT_M,
     0,  --PCMNT_M,
     DACEND_M,    --PAMNT_M,
     0,   --PRMNT_M,
     CED_NF, SECSTS_CT, SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B,
     AUTUPD_B, 0, 0, 0, 0, 0, 0, LSTUPD_D

              from bsar..tlifprno where TYPMNT_CT = 'PC' and CLODAT_D = @clodat1_d
               and ACCRET_CF = 'A' and DACEND_M <> 0
               --and ctr_nf = '14T000012' --and uwy_nf = 2001

delete #TLIFSTAREP              -- suppression acy generees > bilan + 2
         where ACY_NF > @acy


update #TLIFSTAREP
set  a.CLMCUTOFF_B = b.CLMCUTOFF_B,
     a.PRMCUTOFF_B = b.PRMCUTOFF_B,
     a.CLMRUNOFF_B = b.CLMRUNOFF_B,
     a.PRMRUNOFF_B = b.PRMRUNOFF_B
      from #TLIFSTAREP a, BTRT..TSECTION b
         where a.CTR_NF = b.CTR_NF
               and a.uwy_nf = b.uwy_nf
               and a.sec_nf = b.sec_nf


update #TLIFSTAREP
set  ESTCRB_CF = 'S'
from #TLIFSTAREP where ESTCRB_CF = ' '
and ctr_nf in ('04T000289', '04T000291', '04T000826', '04T002304')



update #TLIFSTAREP
set  ESTCRB_CF = 'O'
from #TLIFSTAREP where ESTCRB_CF = ' '
and ctr_nf in ('04T000814', '04T000843', '04T001383', '04T001985', '04T002964', '04U003055',
               '04U003575', '04Z086579', '04ZC01617', '05T000973', '06T002243')

update #TLIFSTAREP
set  COMMAC_B = 1
from #TLIFSTAREP where clodat_d in ('20031231', '20040331')
and ctr_nf = '04Z032195'
and acy_nf = 2003
and COMMAC_B = 0

update #TLIFSTAREP
set  AUTUPD_B = 1
from #TLIFSTAREP where clodat_d = '20040331'
and ctr_nf = '04T002228'
and acy_nf = 2004
and AUTUPD_B = 0

update #TLIFSTAREP
set  AUTUPD_B = 1
from #TLIFSTAREP where clodat_d = '20021231'
and ctr_nf in ('04T000098', '04T000151', '04T000568', '04T000684', '04T000731', '04T000732', '04T000783', '04T000786',
              '04T000807', '04T000856', '04T000886', '04T001011', '04T001015', '04T001144', '04T001219', '04T001248', '04T001462',
              '04T001499', '04T001500', '04T001728', '04T001817', '04T002061', '04T002087', '04W000363', '04W000373',
              '04Z085222', '04Z085612', '04Z085635', '04Z085944', '04Z086390', '04Z086466', '04Z086692', '04Z086698', '04Z0N0152', '04Z0N0222',
              '04Z0N0391', '04Z0N0435', '04Z0N0494', '04Z0N0703', '04T000784', '04Z086390')
and acy_nf = 2003
and AUTUPD_B = 0

update #TLIFSTAREP
set  AUTUPD_B = 1
from #TLIFSTAREP where clodat_d = '20021231'
and ctr_nf = '04ZC00232'
and acy_nf = 2002
and AUTUPD_B = 0

update #TLIFSTAREP
set  AUTUPD_B = 1
from #TLIFSTAREP where clodat_d = '20031231'
and ctr_nf = '04Z0N0189'
and acy_nf = 2002
and AUTUPD_B = 0

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
          and   typmnt_ct in  ('PC', 'CBN', 'PR', 'CBP') and accret_cf = 'A'

insert #TLIFPRNO2
(
    CLODAT_D,
    CTR_NF,
    SEC_NF,
    TYPMNT_CT,
    SECACCSTS_CT,
    ACCADMTYP_CT
)
select distinct clodat_d, ctr_nf, sec_nf, typmnt_ct, secaccsts_ct, accadmtyp_ct
from   bsar..tlifprno
where clodat_d = @clodat_d
          and   typmnt_ct in  ('PC', 'CBN', 'PR', 'CBP') and accret_cf = 'A'

insert #TLIFPRNO3
(
    CLODAT_D,
    CTR_NF,
    SEC_NF,
    ACY_NF,
    TYPMNT_CT,
    COMMAC_B,
    AUTUPD_B
)

select  distinct CLODAT_D, CTR_NF, SEC_NF, ACY_NF, TYPMNT_CT,
   COMMAC_B =  max (convert( int,COMMAC_B)),
   AUTUPD_B =  max (convert( int,AUTUPD_B))
from BSAR..TLIFPRNO
      where    CLODAT_D  = @clodat_d
          and   typmnt_ct in  ('PC', 'CBN', 'PR', 'CBP') and accret_cf = 'A'

      group by CLODAT_D, CTR_NF, SEC_NF, ACY_NF, TYPMNT_CT
      order by CLODAT_D, CTR_NF, SEC_NF, ACY_NF, TYPMNT_CT

   execute BSAR..PsLIFSTAREP_02 with recompile

--mise a jour des données souscription a partir PC ou CBN ou PR ou CBP

--insert #CODEMVT (CTR_NF, SEC_NF, UWy_NF, CODEMVT_NF)
--select CTR_NF, SEC_NF, UWy_NF, min(CODEMVT_NF)
--                                    from #TLIFSTAREP

---
---insert #TSOUSCRIPT
---   (SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CED_NF, ACCRET_CF, SECSTS_CT,
---    SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B
---    )
---select a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CED_NF, a.ACCRET_CF, a.SECSTS_CT,
---    a.SECACCSTS_CT, a.ACCADMTYP_CT, a.ESTCRB_CF, a.ESTCTR_CF, a.ESTSEC_NF, a.COMMAC_B, a.AUTUPD_B
---     from #TLIFSTAREP a, #CODEMVT c
---                          where a.CTR_NF = c.CTR_NF
---                                     and    a.SEC_NF = c.SEC_NF
---                                      and    a.UWY_NF = c.UWY_NF
---                                      and a.CODEMVT_NF = c.CODEMVT_NF
---
---
---
---update #TLIFSTAREP
---set CED_NF = b.CED_NF,
---    ACCRET_CF = b.ACCRET_CF,
---    SECSTS_CT = b.SECSTS_CT,
---    SECACCSTS_CT = b.SECACCSTS_CT,
---    ACCADMTYP_CT = b.ACCADMTYP_CT,
---    ESTCRB_CF = b.ESTCRB_CF,
---    ESTCTR_CF = b.ESTCTR_CF,
---    ESTSEC_NF = b.ESTSEC_NF,
---    COMMAC_B  = b.COMMAC_B,
---    AUTUPD_B  = b.AUTUPD_B
---      from #TLIFSTAREP a, #TSOUSCRIPT b
---      where a.CTR_NF = b.CTR_NF
---           and    a.SEC_NF = b.SEC_NF
---           and    a.UWY_NF = b.UWY_NF
---
---select CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF,
---     ACMTRS_NT, CUR_CF, CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M, CED_NF, SECSTS_CT,
---     SECACCSTS_CT, ACCADMTYP_CT, ESTCRB_CF, ESTCTR_CF, ESTSEC_NF, COMMAC_B, AUTUPD_B, YNEWCTR_B,
---     TNEWCTR_B, CLMCUTOFF_B, PRMCUTOFF_B, CLMRUNOFF_B, PRMRUNOFF_B, LSTUPD_D
---      from #TLIFSTAREP
---        where Abs ( CBNMNT_M + CBPMNT_M + PCMNT_M + PAMNT_M + PRMNT_M ) > 0.000
---          order by CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT,
---                  ACCRET_CF, ACY_NF, ACMTRS_NT
---

return 0
go
GRANT EXECUTE ON dbo.PsLIFSTAREP_01 TO GOMEGA
go
IF OBJECT_ID('dbo.PsLIFSTAREP_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFSTAREP_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFSTAREP_01 >>>'
go
EXEC sp_procxmode 'dbo.PsLIFSTAREP_01','unchained'
go












































