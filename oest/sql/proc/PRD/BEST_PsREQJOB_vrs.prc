use BEST
go
if object_id('dbo.PsREQJOB_vrs') is not null
begin
  drop PROC dbo.PsREQJOB_vrs
  print '<<< DROPPED PROC dbo.PsREQJOB_vrs >>>'
end
go
create procedure PsREQJOB_vrs
  (
  @p_DBCLO_D datetime,
  @p_ssd_cf        USSD_CF
  )
as
/***************************************************
Domaine: (ES) Estimation
Base principale: BEST
Auteur: Florent
Date de creation: 08/06/2012
Description du programme: :spot:23390 liste des versions pour d_tb_sp_es2700_plan_vrs
_________________
MODIFICATIONS
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur         int,
        @site_cf        varchar(10)
Execute @erreur = BEST..PsSITE_01 @p_ssd_cf,'2',@site_cf output

select DISTINCT SSD_CF,VRS_NF
 from BEST..TREQJOB a, BREF..TBATCHSSD b
  where a.SSD_CF    =  b.SSD_CF
    and a.DBCLO_D   =  @p_DBCLO_D
    and a.REQCOD_CT in ('I','J')
    and a.VRS_NF    >  0
    and B.SITE_CF   =  @site_cf
    
go
if object_id('dbo.PsREQJOB_vrs') is not null
  print '<<< CREATED PROC dbo.PsREQJOB_vrs >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsREQJOB_vrs >>>'
go
grant execute on dbo.PsREQJOB_vrs TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_vrs TO GDBBATCH
go
