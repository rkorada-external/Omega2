use BEST
go
if object_id('dbo.PsINTWIT_01') is not null
begin
  drop PROC dbo.PsINTWIT_01
  print '<<< DROPPED PROC dbo.PsINTWIT_01 >>>'
end
go
create procedure PsINTWIT_01
as
/***************************************************
Domaine : (ES) Estimation
Base principale :BRET
Version: 1
Auteur: ME32 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: selection de tous les enregistrements dans TINTWIT
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
[01] 08/08/2013 Florent :spot:25427 Centralisation des bases (filiales)
*****************************************************/
select a.RETCTR_NF,a.RTY_NF,a.RETTRTCUR_CF,a.CLMFUNINT_R,a.URRFUNINT_R,a.IBNFUNINT_R,convert(char(8),a.CRE_D,112)
 from BRET..TINTWIT a, BRET..TRETCTR b, BREF..TBATCHSSD c
  where a.RETCTR_NF=b.RETCTR_NF
    and a.RTY_NF=b.RTY_NF
    and b.SSD_CF=c.SSD_CF
    and c.BATCHUSER_CF=suser_name()
order by a.RETCTR_NF, a.RTY_NF asc

return 0
go
if object_id('dbo.PsINTWIT_01') is not null
  print '<<< CREATED PROC dbo.PsINTWIT_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.INTWIT_01 >>>'
go
grant execute on dbo.PsINTWIT_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsINTWIT_01 TO GDBBATCH
go


