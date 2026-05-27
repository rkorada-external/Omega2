use BEST
go
if object_id('dbo.PsLIFNEWBIZ_01') is not null
begin
  drop procedure dbo.PsLIFNEWBIZ_01
  if object_id('dbo.PsLIFNEWBIZ_01') is not null
    print '<<< FAILED DROPPING procedure dbo.PsLIFNEWBIZ_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLIFNEWBIZ_01 >>>'
end
go
create procedure PsLIFNEWBIZ_01
  (
  @p_CTR_NF  UCTR_NF
 ,@p_END_NT  UEND_NT
 ,@p_SEC_NF  USEC_NF
 ,@p_RETRO_B bit
 ,@p_LAG_CF  char(1)='F'
  )
as
/***************************************************
Domaine                   : Estimation Vie
Base principale           : BEST
Auteur                    : Florent
Date de création          : 21/12/2009
Description du programme  : :spot:17932 gestion affaires nouvelles
Conditions d'éxécution    : par la dw d_tb_sp_newbiz
Commentaires              : on peut ne pas avoir de lignes présentes dans TLIFNEWBIZ
_________________
MODIFICATIONS
M  Auteur      Date       Description
*****************************************************/
declare
  @erreur integer
 ,@LOB_CF ULOB_CF
 ,@taux   decimal(9,6) --USHA_R * 100

select @taux=0
if @p_RETRO_B=1
begin
  select @LOB_CF=LOB_CF
    from BRET..TRETSEC
     where RETCTR_NF=@p_ctr_nf
       and RETSEC_NF=@p_SEC_NF
       and RTY_NF=(select max(RTY_NF) from BRET..TRETCTR c where c.RETCTR_NF=@p_ctr_nf and RETCTRSTS_CT in(3,19))
end
else
begin
  select @LOB_CF=LOB_CF
   from BTRT..TSECTION
    where CTR_NF=@p_CTR_NF
      and SEC_NF=@p_SEC_NF
      and UWY_NF=(select max(UWY_NF) from BTRT..TSECTION c where c.CTR_NF=@p_ctr_nf and SEC_NF=@p_SEC_NF and SECSTS_CT in(14,16,17,19))
end

if @LOB_CF=null raiserror 20005 "APPLICATIF;LOB_CF %1!/%2!",@p_CTR_NF,@p_SEC_NF

select
   CTR_NF
  ,END_NT
  ,SEC_NF
  ,ACMTRS_NT
  ,NEWBIZ0_R=sum(case when ACY_NF=0 then NEWBIZ_R else 0 end) * 100
  ,NEWBIZ1_R=sum(case when ACY_NF=1 then NEWBIZ_R else 0 end) * 100
  ,NEWBIZ2_R=sum(case when ACY_NF=2 then NEWBIZ_R else 0 end) * 100
into #LIFNEWBIZ
 from TLIFNEWBIZ b
  where CTR_NF=@p_CTR_NF
    and END_NT=@p_END_NT
    and SEC_NF=@p_SEC_NF
    and CRE_D=(select max(CRE_D) from TLIFNEWBIZ z where z.CTR_NF=b.CTR_NF and z.END_NT=b.END_NT and z.SEC_NF=b.SEC_NF and z.ACMTRS_NT=b.ACMTRS_NT and z.ACY_NF=b.ACY_NF)
group by CTR_NF,END_NT,SEC_NF,ACMTRS_NT
order by CTR_NF,END_NT,SEC_NF,ACMTRS_NT

select
   CTR_NF=@p_CTR_NF
  ,END_NT=@p_END_NT
  ,SEC_NF=@p_SEC_NF
  ,ACMTRS_LM=COLVAL_LM
  ,ACMTRS_NT=convert(smallint,COLVAL_CT)
  ,ORDRE_NT=convert(smallint,substring(COLVAL_LS,1,2))
  ,CALC_NT=convert(tinyint,substring(COLVAL_LS,4,1))
  ,GROUPE_NT=convert(tinyint,substring(COLVAL_LS,9,1))
  ,ADJSIG_B=isnull((select ADJSIG_B from TACCPAR where ACMTRS_NT=convert(smallint,a.COLVAL_CT)),0)
  ,NEWBIZ0_R=@taux
  ,NEWBIZ1_R=@taux
  ,NEWBIZ2_R=@taux
into #refLIFNEWBIZ
 from BREF..TBANTECL a
   where COL_LS='NEWBIZ_CT'
     and LAG_CF=@p_LAG_CF
     and substring(COLVAL_LS,6,2) in(@LOB_CF,'99')
     and COLVAL_CT like case when @p_RETRO_B=1 then '2%' else '1%' end

update #refLIFNEWBIZ
 set NEWBIZ0_R=b.NEWBIZ0_R
    ,NEWBIZ1_R=b.NEWBIZ1_R
    ,NEWBIZ2_R=b.NEWBIZ2_R
  from #refLIFNEWBIZ a, #LIFNEWBIZ b
   where a.CTR_NF=b.CTR_NF
     and a.END_NT=b.END_NT
     and a.SEC_NF=b.SEC_NF
     and a.ACMTRS_NT=b.ACMTRS_NT

select * from #refLIFNEWBIZ order by ORDRE_NT

fin:
if object_id('#refLIFNEWBIZ') IS not null
  drop TABLE #refLIFNEWBIZ
if object_id('#LIFNEWBIZ') IS not null
  drop TABLE #LIFNEWBIZ
return 0
go
if object_id('dbo.PsLIFNEWBIZ_01') is not null
  print '<<< CREATED procedure dbo.PsLIFNEWBIZ_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLIFNEWBIZ_01 >>>'
go
grant execute on dbo.PsLIFNEWBIZ_01 To GOMEGA
go
