use BEST
go
if object_id('dbo.PsSEGJOBHIST_01') is not null
begin
  drop PROC dbo.PsSEGJOBHIST_01
  print '<<< DROPPED PROC dbo.PsSEGJOBHIST_01 >>>'
end
go
create procedure PsSEGJOBHIST_01
  (
  @p_ssd_cf  USSD_CF
 ,@p_TYP_SEG USEGTYP_CT
  )
as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  : T. RIPERT
Date de creation        : 09/09/2010
Description du programme: Sélection d'enregistrement dans TSEGJOB_HIST
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  Florent   30/05/2012 :spot:23390 SOLVENCY II
*****************************************************/
declare @erreur int

select
  JOB_NAME
 ,JOB_LNCH_D
 ,JOB_USER
 ,SSD_CF
 ,TYP_SEG
 ,JOB_COMPLETED_D
 ,TASK_COMPLETED_D
 ,NCHAIN
 from TSEGJOB_HIST
 where SSD_CF=@p_ssd_cf
   and TYP_SEG=@p_TYP_SEG
   and datepart(YEAR,JOB_LNCH_D)=datepart(year,getdate())
order by JOB_LNCH_D, JOB_COMPLETED_D
select @erreur=@@error
if @erreur!=0
begin
  raiserror 20005 "APPLICATIF;TSEGPAR"
  return @erreur
end
return 0
go
if object_id('dbo.PsSEGJOBHIST_01') is not null
  print '<<< CREATED PROC dbo.PsSEGJOBHIST_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsSEGJOBHIST_01 >>>'
go
grant execute on dbo.PsSEGJOBHIST_01 TO PUBLIC
go
grant execute on dbo.PsSEGJOBHIST_01 TO GOMEGA
go
