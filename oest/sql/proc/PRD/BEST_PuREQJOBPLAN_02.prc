USE BEST
Go

/* 
 * DROP PROC dbo.PuREQJOBPLAN_02 */
IF OBJECT_ID('dbo.PuREQJOBPLAN_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PuREQJOBPLAN_02
    PRINT '<<< DROPPED PROC dbo.PuREQJOBPLAN_02 >>>'
END
go

/*
 * creation de la procedure */
create procedure PuREQJOBPLAN_02 (
    @p_cre_d        UUPD_D
)

as
/***************************************************
Programme:                  PuREQJOBPLAN_02
Domaine :                   (ES) Estimation
Base principale :           BEST
Auteur:                     D.GATIBELZA
Date:                       23/08/2010
Description du programme:   Même mise à jour que la PuREQJOB_02, mais sur la table TREQJOBPLAN
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 25/03/2014 R. CASSIS   :spot:25427 - Correction sur gestion demandes M
[102] 23/12/2014 R. CASSIS   :spot:27975 - Update run date into treqjobplan table from Id record
[103] 01/12/2015 R. cassis   :spot:29553 - Gestion du site dans les mises à jour de Treqjobplan
*****************************************************/
declare @erreur    int,
        @tran_imbr bit
declare @date_fin  datetime

select @erreur    = 0
select @tran_imbr = 1


/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */
if @@trancount = 0
begin
    select @tran_imbr = 0
    BEGIN TRAN
end

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

select @date_fin = getdate()

/* maj quand demande dans TREQJOBPLAN */
update BEST..TREQJOBPLAN
   set LAUNCH_D = @date_fin,
       END_D    = @date_fin
from BEST..TREQJOBPLAN jobplan, BEST..TREQJOB job
where jobplan.START_D  is not null
  and jobplan.LAUNCH_D is null
  and job.LAUNCH_D     is not null
  --and job.SSD_CF       = jobplan.SSD_CF
  --and job.BALSHEYEA_NF = jobplan.BALSHEYEA_NF
  --and job.BALSHTMTH_NF = jobplan.BALSHTMTH_NF
  --and job.CLODAT_D     = jobplan.CLODAT_D
  --and job.REQCOD_CT    = jobplan.REQCOD_CT
  --and job.CRE_D        = jobplan.CRE_D
  and jobplan.SITE_CF  = job.SITE_CF
  and job.SITE_CF      = @site_cf
  and job.ID_NF        = jobplan.ID_NF  -- [102]


select @erreur = @@error
if @erreur != 0
    goto fin



/* maj des demandes C et M */
update BEST..TREQJOBPLAN
   set LAUNCH_D = @date_fin,
       END_D    = @date_fin
from BEST..TREQJOBPLAN jobplan
where REQCOD_CT in ('C','M')      --[101]   
  and LAUNCH_D is null
  --and END_D    is null          --[101]
  --and START_D  is not null      --[101]
  and DBCLO_D <= @p_cre_d
  and SITE_CF  = @site_cf         --(103]

select @erreur = @@error
if @erreur != 0
    goto fin



/* maj des demandes V */
update BEST..TREQJOBPLAN
   set LAUNCH_D = @date_fin,
       END_D    = @date_fin
from BEST..TREQJOBPLAN jobplan
where REQCOD_CT = 'V'
  and LAUNCH_D is null
  and END_D    is not null
  and START_D  is not null
  and DBCLO_D <= @p_cre_d
  and SITE_CF  = @site_cf

select @erreur = @@error
if @erreur != 0
    goto fin


/**********************************************************************************/
if @tran_imbr = 0
    COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
    ROLLBACK TRAN

return @erreur
go

/*
 * fin de la procedure  */

IF OBJECT_ID('dbo.PuREQJOBPLAN_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuREQJOBPLAN_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuREQJOBPLAN_02 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PuREQJOBPLAN_02 */
GRANT EXECUTE ON dbo.PuREQJOBPLAN_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuREQJOBPLAN_02 TO GDBBATCH
go
