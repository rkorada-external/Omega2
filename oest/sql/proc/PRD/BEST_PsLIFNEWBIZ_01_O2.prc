use BEST
go

IF OBJECT_ID ('dbo.PsLIFNEWBIZ_01_O2') IS NOT NULL
   BEGIN
      DROP PROCEDURE dbo.PsLIFNEWBIZ_01_O2

      IF OBJECT_ID ('dbo.PsLIFNEWBIZ_01_O2') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFNEWBIZ_01_O2 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE dbo.PsLIFNEWBIZ_01_O2 >>>'
   END
go

/***** create procedure dbo.PsLIFNEWBIZ_01_O2 *****/
create procedure dbo.PsLIFNEWBIZ_01_O2
  (
  @p_CTR_NF		UCTR_NF
 ,@p_END_NT		UEND_NT
 ,@p_SEC_NF		USEC_NF
 ,@p_RETRO_B	bit
 ,@p_LAG_CF		ULAG_CF
 ,@p_SSD_CF		USSD_CF
 ,@p_ESB_CF		UESB_CF
 ,@p_USR_CF		UUSR_CF
 ,@p_loading_b	bit
  )
as
/***************************************************
Domaine                   : Estimation Vie
Base principale           : BEST
Auteur                    : Florent
Date de crï¿½ation          : 21/12/2009
Description du programme  : :spot:17932 gestion affaires nouvelles
Conditions d'ï¿½xï¿½cution    : par la dw d_tb_sp_newbiz
Commentaires              : on peut ne pas avoir de lignes prï¿½sentes dans TLIFNEWBIZ
_________________
MODIFICATIONS
M  Auteur        Date         Description

1. A.Deshpande   27/02/2014  Added two more years for SGLA06 evo card
2. A.Deshpande   08/05/2014 Removed hardcoding of LAG_CF
*****************************************************/
declare
  @erreur integer
 ,@LOB_CF ULOB_CF
 ,@taux   decimal(9,6) --USHA_R * 100

if object_id('#TLOADING') IS not null
	drop TABLE #TLOADING
if object_id('#refLIFNEWBIZ') IS not null
	drop TABLE #refLIFNEWBIZ
if object_id('#LIFNEWBIZ') IS not null
	drop TABLE #LIFNEWBIZ

Create table #TLOADING (
    CTR_NF	UCTR_NF				NOT NULL,
    SEC_NF	USEC_NF				NOT NULL,
    END_NT	UEND_NT				NOT NULL,
    SSD_CF	USSD_CF				NOT NULL,
    ESB_CF	UESB_CF				NOT NULL,
    USR_CF	UUSR_CF				NOT NULL,
    RETRO_B	bit	DEFAULT 0		NOT NULL,
	LOB_CF	ULOB_CF	DEFAULT ''	NOT NULL
)

Create table #LIFNEWBIZ (
    CTR_NF		UCTR_NF			NOT NULL,
    END_NT		UEND_NT			NOT NULL,
    SEC_NF		USEC_NF			NOT NULL,
	ACMTRS_NT	smallint		NOT NULL,
	NEWBIZ0_R	decimal(9,6)	NOT NULL,
	NEWBIZ1_R	decimal(9,6)	NOT NULL,
	NEWBIZ2_R	decimal(9,6)	NOT NULL,
	NEWBIZ3_R	decimal(9,6)	NOT NULL,
	NEWBIZ4_R	decimal(9,6)	NOT NULL
)

Create table #refLIFNEWBIZ (
    CTR_NF		UCTR_NF			NOT NULL,
    END_NT		UEND_NT			NOT NULL,
    SEC_NF		USEC_NF			NOT NULL,
	ACMTRS_LM	UL32			NOT NULL,
	ACMTRS_NT	smallint		NOT NULL,
	ORDRE_NT	smallint		NULL,
	CALC_NT		tinyint			NULL,
	GROUPE_NT	tinyint			NULL,
	ADJSIG_B	bit	default 1	NOT NULL,
	NEWBIZ0_R	decimal(9,6)	NOT NULL,
	NEWBIZ1_R	decimal(9,6)	NOT NULL,
	NEWBIZ2_R	decimal(9,6)	NOT NULL,
	NEWBIZ3_R	decimal(9,6)	NOT NULL,
	NEWBIZ4_R	decimal(9,6)	NOT NULL
)

IF (@p_loading_b = 1)
	begin
		Insert into #TLOADING
		Select	DISTINCT CTR_NF,
						SEC_NF,
						END_NT,
						SSD_CF,
						ESB_CF,
						USR_CF,
						RETRO_B,
						''
		FROM BTRAV..EST_ESID0881_PERIMETER
		WHERE 
			USR_CF = @p_usr_cf AND
			SSD_CF = @p_ssd_cf AND
			ESB_CF = @p_esb_cf AND
			ERRORCODE_CT = null

		select @erreur = @@error
		if @erreur != 0
			begin
				raiserror 20001 "APPLICATIF;#TLOADING"
				return @erreur
				goto fin
			end
	end
ELSE
	Begin
		Insert into #TLOADING (CTR_NF, SEC_NF, END_NT, SSD_CF, ESB_CF, USR_CF, RETRO_B, LOB_CF)
			VALUES (@p_CTR_NF, @p_SEC_NF, @p_END_NT, @p_SSD_CF, @p_ESB_CF, @p_USR_CF, @p_RETRO_B, '')
	End

select @taux=0

UPDATE #TLOADING
SET LOB_CF = t.LOB_CF
FROM #TLOADING a, BTRT..TSECTION t
WHERE a.RETRO_B = 0
AND a.CTR_NF = t.CTR_NF
AND a.SEC_NF = t.SEC_NF
AND t.UWY_NF=(select max(c.UWY_NF) from BTRT..TSECTION c where c.CTR_NF=t.CTR_NF and SEC_NF=t.SEC_NF and SECSTS_CT in(14,16,17,19))

UPDATE #TLOADING
SET LOB_CF = t.LOB_CF
FROM #TLOADING a, BRET..TRETSEC t
WHERE a.RETRO_B = 1
AND a.CTR_NF = t.RETCTR_NF
AND a.SEC_NF = t.RETSEC_NF
AND t.RTY_NF=(select max(c.RTY_NF) from BRET..TRETCTR c where c.RETCTR_NF=t.RETCTR_NF and c.RETCTRSTS_CT in(14,16,17,19))

if EXISTS(SELECT 1 from #TLOADING where LOB_CF=null)
raiserror 20005 "APPLICATIF;LOB_CF %1!/%2!",@p_CTR_NF,@p_SEC_NF

INSERT into #LIFNEWBIZ
select
   b.CTR_NF
  ,b.END_NT
  ,b.SEC_NF
  ,b.ACMTRS_NT
  ,NEWBIZ0_R=sum(case when b.ACY_NF=0 then b.NEWBIZ_R else 0 end) * 100
  ,NEWBIZ1_R=sum(case when b.ACY_NF=1 then b.NEWBIZ_R else 0 end) * 100
  ,NEWBIZ2_R=sum(case when b.ACY_NF=2 then b.NEWBIZ_R else 0 end) * 100
  ,NEWBIZ3_R=sum(case when b.ACY_NF=3 then b.NEWBIZ_R else 0 end) * 100
  ,NEWBIZ4_R=sum(case when b.ACY_NF=4 then b.NEWBIZ_R else 0 end) * 100
 from TLIFNEWBIZ b, #TLOADING l
  where b.CTR_NF=l.CTR_NF
    and b.END_NT=l.END_NT
    and b.SEC_NF=l.SEC_NF
    and b.CRE_D=(select max(z.CRE_D) from TLIFNEWBIZ z where z.CTR_NF=b.CTR_NF and z.END_NT=b.END_NT and z.SEC_NF=b.SEC_NF and z.ACMTRS_NT=b.ACMTRS_NT and z.ACY_NF=b.ACY_NF)
group by l.CTR_NF,l.END_NT,l.SEC_NF,b.ACMTRS_NT
order by l.CTR_NF,l.END_NT,l.SEC_NF,b.ACMTRS_NT

INSERT into #refLIFNEWBIZ
select
   CTR_NF=l.CTR_NF
  ,END_NT=l.END_NT
  ,SEC_NF=l.SEC_NF
  ,ACMTRS_LM=COLVAL_LM
  ,ACMTRS_NT=convert(smallint,COLVAL_CT)
  ,ORDRE_NT=convert(smallint,substring(COLVAL_LS,1,2))
  ,CALC_NT=convert(tinyint,substring(COLVAL_LS,4,1))
  ,GROUPE_NT=convert(tinyint,substring(COLVAL_LS,9,1))
  ,ADJSIG_B=isnull((select ADJSIG_B from TACCPAR where ACMTRS_NT=convert(smallint,a.COLVAL_CT)),0)
  ,NEWBIZ0_R=@taux
  ,NEWBIZ1_R=@taux
  ,NEWBIZ2_R=@taux
  ,NEWBIZ3_R=@taux
  ,NEWBIZ4_R=@taux
 from BREF..TBANTECL a, #TLOADING l
   where COL_LS='NEWBIZ_CT'
     and LAG_CF=@p_LAG_CF
     and substring(COLVAL_LS,6,2) in(l.LOB_CF,'99')
     and COLVAL_CT like case when l.RETRO_B=1 then '2%' else '1%' end

update #refLIFNEWBIZ
 set NEWBIZ0_R=b.NEWBIZ0_R
    ,NEWBIZ1_R=b.NEWBIZ1_R
    ,NEWBIZ2_R=b.NEWBIZ2_R
    ,NEWBIZ3_R=b.NEWBIZ3_R
	,NEWBIZ4_R=b.NEWBIZ4_R
  from #refLIFNEWBIZ a, #LIFNEWBIZ b
   where a.CTR_NF=b.CTR_NF
     and a.END_NT=b.END_NT
     and a.SEC_NF=b.SEC_NF
     and a.ACMTRS_NT=b.ACMTRS_NT

select #refLIFNEWBIZ.CTR_NF, #refLIFNEWBIZ.END_NT, #refLIFNEWBIZ.SEC_NF, #refLIFNEWBIZ.ACMTRS_LM, #refLIFNEWBIZ.ACMTRS_NT, #refLIFNEWBIZ.ORDRE_NT, #refLIFNEWBIZ.CALC_NT, #refLIFNEWBIZ.GROUPE_NT, #refLIFNEWBIZ.ADJSIG_B, #refLIFNEWBIZ.NEWBIZ0_R, #refLIFNEWBIZ.NEWBIZ1_R, #refLIFNEWBIZ.NEWBIZ2_R, #refLIFNEWBIZ.NEWBIZ3_R, #refLIFNEWBIZ.NEWBIZ4_R from #refLIFNEWBIZ order by ORDRE_NT

fin:
if object_id('#refLIFNEWBIZ') IS not null
  drop TABLE #refLIFNEWBIZ
if object_id('#LIFNEWBIZ') IS not null
  drop TABLE #LIFNEWBIZ
return 0





EXEC sp_procxmode 'dbo.PsLIFNEWBIZ_01_O2', 'unchained'
go

IF OBJECT_ID ('dbo.PsLIFNEWBIZ_01_O2') IS NOT NULL
   PRINT '<<< CREATED PROCEDURE dbo.PsLIFNEWBIZ_01_O2 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFNEWBIZ_01_O2 >>>'
go

GRANT EXECUTE ON dbo.PsLIFNEWBIZ_01_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFNEWBIZ_01_O2 TO GDBBATCH
go
