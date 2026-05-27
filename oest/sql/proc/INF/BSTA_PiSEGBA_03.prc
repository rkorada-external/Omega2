use BSTA
go
if object_id('dbo.PiSEGBA_03') is not null
begin
  drop PROC dbo.PiSEGBA_03
  print '<<< DROPPED PROC dbo.PiSEGBA_03 >>>'
end
go
create procedure PiSEGBA_03
(
  @ssd_cf   integer
 ,@segtyp_ct  char(1)  --type de segment (A ou E ou S)
)
as
/********************************************************************************
Domaine : (ES) Estimation
Base principale : BSAR
Description : Calqué sur BSTA_PiSEGBA_01.prc pour ESED0421.cmd
Conditions d'execution : Valeurs de retour 0:  OK -1: Echec
Commentaires :
_________________
MODIFICATIONS
1 M. DJELLOULI 07/10/2004
2  Florent   14/02/2012 :spot:23390 SOLVENCY II
3 Florent 16/10/2014 :spot:27466 on enlève les contrôles sur TCTRGRO, la gestion du segment balai
********************************************************************************/
begin TRANSACTION
--  MODIF DU 19/06 - DIVISION DES TAUX PAR 100
update BSAR..TSEGEST
 set LOSRAT_R=round(LOSRAT_R / 100,8)
  where SSD_CF=@ssd_cf
    and SEGTYP_CT=@segtyp_ct
    and AMORAT_CT='R'
if @@error!=0 goto ERREUR

commit TRANSACTION
return 0

ERREUR:
rollback TRANSACTION
return -1
go
if object_id('dbo.PiSEGBA_03') is not null
begin
  print '<<< CREATED PROC dbo.PiSEGBA_03 >>>'
end
else
  print '<<< FAILED CREATING PROC dbo.PiSEGBA_03 >>>'
go
grant execute on dbo.PiSEGBA_03 TO GOMEGA
go
