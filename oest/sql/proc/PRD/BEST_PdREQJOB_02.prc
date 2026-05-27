USE BEST
Go

/*
  DROP PROC dbo.PdREQJOB_02 */
IF OBJECT_ID('dbo.PdREQJOB_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PdREQJOB_02
    PRINT '<<< DROPPED PROC dbo.PdREQJOB_02 >>>'
END
go

/*
 * creation de la procedure */
create procedure PdREQJOB_02
    @p_cre_d    UUPD_D
as

/***************************************************
Programme:          PdREQJOB_02
Domaine :           Estimation
Base principale :   BEST
Auteur:             D.GATIBELZA
Date de creation:   28/09/2010
Description du programme:   suppression dans TREQJOB des demandes non traitees
_________________
[001] 07/05/2012 R. CASSIS     :spot:23802 - Ajout option E pour Solvency
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 04/11/2015 R. Cassis   :spot:29654 Gestion plan2 pour le Post-omega.
[102] 04/08/2017 R. Cassis  :spira:61508 Gestion plan2 pour le Post-omega des ES locales
*****************************************************/
declare @erreur int

select @erreur = 0

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end


delete BEST..TREQJOB
where LAUNCH_D in (null,'19001231')  --[101]
  and DBCLO_D <= @p_cre_d
  and REQCOD_CT in ('C', 'D', 'E', 'F', 'I', 'J', 'L', 'A', 'T', 'V', 'Y')  -- [001] [102]
  and SITE_CF = @site_cf                                                        -- PHP O21B ajout du controle sur le site 

--Suppression de toutes les demandes V et Z non exécutées sur TREQJOB           -- PHP O21B ajout du controle sur le site 
delete BEST..TREQJOB
where REQCOD_CT in ( 'Z' )
  and LAUNCH_D is null

select @erreur = @@error
if @erreur != 0
begin
    select "Erreur :3: dans Delete BEST..TREQJOB"
    goto fin
end

DELETE BEST..TREQJOB
from BEST..TREQJOB job, BEST..TREQJOBPLAN jobplan
where job.BALSHEYEA_NF = jobplan.BALSHEYEA_NF
  and job.BALSHTMTH_NF = jobplan.BALSHTMTH_NF
  and job.CLODAT_D     = jobplan.CLODAT_D
  and job.REQCOD_CT    = jobplan.REQCOD_CT
  and job.DBCLO_D      = jobplan.DBCLO_D
  and job.REQCOD_CT    in ('D', 'E', 'L', 'A', 'T', 'V', 'Y')  -- [002] [102]
  and jobplan.LAUNCH_D is null
  and job.SITE_CF      = jobplan.SITE_CF            -- PHP O21B ajout du controle sur le site 
  and job.ID_NF        = jobplan.ID_NF              -- PHP O21B ajout du controle sur le site 
  and job.SITE_CF      = jobplan.SITE_CF            -- PHP O21B ajout du controle sur le site 
  and jobplan.SITE_CF  = @site_cf                   -- PHP O21B ajout du controle sur le site 


select @erreur = @@error

fin:
return @erreur
go

/*
 * fin de la procedure  */

IF OBJECT_ID('dbo.PdREQJOB_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PdREQJOB_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PdREQJOB_02 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PdREQJOB_02 */
GRANT EXECUTE ON dbo.PdREQJOB_02 TO public
go
grant execute on dbo.PdREQJOB_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdREQJOB_02 TO GDBBATCH
go
