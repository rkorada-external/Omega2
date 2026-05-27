use BEST
go
if object_id('dbo.PsFAMLIA_04') is not null
begin
  drop procedure dbo.PsFAMLIA_04
  if object_id('dbo.PsFAMLIA_04') is not null
    print '<<< FAILED DROPPING procedure dbo.PsFAMLIA_04 >>>'
  else
    print '<<< DROPPED procedure dbo.PsFAMLIA_04 >>>'
end
go
create procedure PsFAMLIA_04
as
/***************************************************
Programme:          PsFAMLIA_04
Base principale :   BEST
Version:            1
Auteur:             J.Ribot
Date de creation:   13/01/03
Description du programme:   Sélection d'enregistrement dans TFAMLIA et TSECTION sur ADMMODPRM_CT = A
_________________
MODIFICATION
Auteur:         J.Ribot
Date            30 06 2009
Version:
Description:    SPOT17640 dans le ESIJ1000, pas de redeclenchement de MAJ des utimes après mise à jour des taux de change
                ajout order by group by
_________________
MODIFICATION    [002]
Auteur:         D.GATIBELZA
Date:           09/02/2010
Version:        9.1
Description:    ESTVIE17640 pas de redeclenchement de MAJ des utimes après mise à jour des taux de change (ESIJ1000)
[003] 07/08/2013 Florent :spot:25427 Centralisation des bases (filiales)
*****************************************************/
select S.CTR_NF,
       S.UWY_NF,
       S.SEC_NF,
       S.END_NT,
       S.UW_NT,
       S.EGPCUR_CF
from BTRT..TFAMLIA S, BTRT..TSECTION SE, BREF..TBATCHSSD c
where S.CTR_NF = SE.CTR_NF
  and S.UWY_NF = SE.UWY_NF
  and S.SEC_NF  = SE.SEC_NF
  and S.END_NT = SE.END_NT
  and S.UW_NT = SE.UW_NT
  --and SE.ADMMODPRM_CT = 'A'   [002] on ne se limite plus aux automatiques.
  and SE.SSD_CF=c.SSD_CF
  and c.BATCHUSER_CF=suser_name()
group by S.CTR_NF,
         S.UWY_NF,
         S.SEC_NF,
         S.END_NT,       -- [002] changement de l'ordre
         S.UW_NT         -- [002] changement de l'ordre
order by S.CTR_NF,
         S.UWY_NF,
         S.SEC_NF,
         S.END_NT,       -- [002] changement de l'ordre
         S.UW_NT         -- [002] changement de l'ordre
if @@error!=0
begin
  raiserror 20003  "APPLICATIF;TFAMLIA;"
  return 1
end
return 0
go
if object_id('dbo.PsFAMLIA_04') is not null
  print '<<< CREATED procedure dbo.PsFAMLIA_04 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PsFAMLIA_04 >>>'
go
grant execute on dbo.PsFAMLIA_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFAMLIA_04 TO GDBBATCH
go
