use BEST
go
if object_id('dbo.PsAUTPAR_02') is not null
begin
  drop PROC dbo.PsAUTPAR_02
  print '<<< DROPPED PROC dbo.PsAUTPAR_02 >>>'
end
go
create procedure PsAUTPAR_02
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation: 30/06/97
Description du programme:  - Sélection de toutes les lignes de la table de parametrage des automatismes TAUTPAR.
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
[01] 08/08/2013 Florent :spot:25427 Centralisation des bases (filiales)
*****************************************************/
declare @erreur    int,
        @tran_imbr bit

select @erreur=0, @tran_imbr=1

select a.SSD_CF, CTRNAT_CT, LOB_CF, PCPRSKTRY_CF, SOB_CF, LIMPER_R, QUANUM_NB
 from BEST..TAUTPAR a, BREF..TBATCHSSD c
  where a.SSD_CF=c.SSD_CF
    and c.BATCHUSER_CF=suser_name()
order by SSD_CF,CTRNAT_CT,LOB_CF,PCPRSKTRY_CF,SOB_CF
select @erreur=@@error
if @erreur!=0 goto fin

return 0

fin:
return 1
go
if object_id('dbo.PsAUTPAR_02') is not null
  print '<<< CREATED PROC dbo.PsAUTPAR_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsAUTPAR_02 >>>'
go
grant execute on dbo.PsAUTPAR_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsAUTPAR_02 TO GDBBATCH
go
