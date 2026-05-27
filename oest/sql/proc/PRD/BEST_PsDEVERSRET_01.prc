use BEST
go
if object_id('dbo.PsDEVERSRET_01') is not null
begin
  drop PROC dbo.PsDEVERSRET_01
  print '<<< DROPPED PROC dbo.PsDEVERSRET_01 >>>'
end
go
create procedure PsDEVERSRET_01
  (
    @p_date_t UUPD_D
   ,@skip_last_qtr_day_by int = 0
  )
as
/***************************************************
Domaine :                 (EST) ESTIMATION
Base principale :         BEST
Auteur:                   Roger cassis
Date de creation:         26/05/2015
Description du programme: :spot:28811 Renvoie True ou False pour le déblocage ou non du déversement de la compta Rétro dans l'inventaire
Conditions d'execution:   La demande R doit être planifiée dans la Treqjob sinon pas de test de date et alors pas de blocage du déversement
Commentaires:             appelée par la fonction TP de modification du calendrier groupe.

Modifications :_________________
[001] 30/10/2015 R. Cassis  :spot:29489 La date fin du Freeze est prise dans treqjobplan.
[002] 12/05/2022 B. Lagha   :spot:94352 - kip the retro night batches freeze by the number of days in the variable @skip_last_qtr_day_by 
*****************************************************/

declare  @site_cf        varchar(10)
        ,@suser_Name     varchar(20)
        ,@erreur          Int
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
   return @erreur
end

if exists (select 1 from Best..treqjobplan job, Bref..tcalend cal  -- [001]
           Where job.REQCOD_CT = 'R' 
           and   job.BALSHEYEA_NF = cal.BLCSHTYEA_NF
           and   job.BALSHTMTH_NF = cal.BLCSHTMTH_NF
           and   job.SITE_CF = @site_cf
           and   @p_date_t >= (dateadd(dd , @skip_last_qtr_day_by , job.START_D))   -- [002]
           and   @p_date_t <= job.END_D)    -- [001]
	select 0  -- Pas de déversement
else
	select 1  -- Déversement

return @@error
go
if object_id('dbo.PsDEVERSRET_01') is not null
  print '<<< CREATED PROC dbo.PsDEVERSRET_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsDEVERSRET_01 >>>'
go
grant execute on dbo.PsDEVERSRET_01 TO GOMEGA
go
grant execute on dbo.PsDEVERSRET_01 TO GDBBATCH
go
