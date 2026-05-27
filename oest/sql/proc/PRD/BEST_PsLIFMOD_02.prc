use BEST
go
if object_id('dbo.PsLIFMOD_02') IS NOT null
begin
  drop procedure dbo.PsLIFMOD_02
  if object_id('dbo.PsLIFMOD_02') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PsLIFMOD_02 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLIFMOD_02 >>>'
end
go
create procedure PsLIFMOD_02(@p_CTR_NF UCTR_NF)
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 25/08/2004
Description du programme: estimation Vie, historique dépassement du seuil
Conditions d'execution: par la dw d_seuil_histo
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare @LAG_CF char(1)

select @LAG_CF=isnull(LAG_CF,'E') from BREF..TUSR where USR_CF=suser_name()
if @LAG_CF=null select @LAG_CF='E'

select a.CTR_NF
      ,a.SEC_NF
      ,a.CRE_D
      ,a.BALSHEY_NF
      ,a.BALSHTMTH_NF
      ,a.CMT_NT
      ,a.SENMAI_D
      ,a.TYPMOD1_CT
      ,TYPMOD1_LM=(select COLVAL_LM from BREF..TBANTECL where LAG_CF=@LAG_CF and COL_LS='TYPMOD1_CT' and COLVAL_CT=convert(char(3),a.TYPMOD1_CT) and CODVALSSD_CF=null)
      ,a.CREUSR_CF
      ,b.PENSTS_CT
      ,PENSTS_LM=(select COLVAL_LM from BREF..TBANTECL where LAG_CF=@LAG_CF and COL_LS='PENSTS_CT' and COLVAL_CT=convert(char(3),b.PENSTS_CT) and CODVALSSD_CF=null)
      ,a.LSTUPD_D
      ,a.LSTUPDUSR_CF
 from TLIFMOD a, TLIFPEN b
  where a.CTR_NF=@p_CTR_NF
    and a.CTR_NF*=b.CTR_NF
    and a.SEC_NF*=b.SEC_NF
    and a.BALSHEY_NF*=b.BALSHEY_NF
    and a.BALSHTMTH_NF*=b.BALSHTMTH_NF
    and a.CRE_D*=b.CRE_D
order by a.cre_d desc
go
if object_id('dbo.PsLIFMOD_02') IS NOT null
  print '<<< CREATED procedure dbo.PsLIFMOD_02 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsLIFMOD_02 >>>'
go
grant execute on dbo.PsLIFMOD_02 TO GOMEGA
go
