use BEST
go

/*
   DROP PROC dbo.PtREQJOBPLAN_01.prc */
IF OBJECT_ID('dbo.PtREQJOBPLAN_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PtREQJOBPLAN_01
    PRINT '<<< DROPPED PROC dbo.PtREQJOBPLAN_01 >>>'
END

go

/*
 * creation de la procedure */
create procedure PtREQJOBPLAN_01 (
    @p_date_t    UUPD_D
)

as
/***************************************************
Programme :                 PtREQJOBPLAN_01
Fichier script associé :    BEST_PtREQJOBPLAN_01.prc
Domaine :                   Estimation
Base principale :           BEST
Version :                   1
Auteur :                    D.GATIBELZA
Date de creation :          23/08/2010
Description du programme :  Deversement des demandes de TREQJOBPLAN dans TREQJOB 
                            Lorsque q'une prévision ( de la TREQJOBPLAN ) arrive à la date du jour, on copie la demande dans la TREQJOB pour qu'elle soit prise en compte.
_________________
MODIFICATION    [001]
Auteur         :  P.PEZOUT
Date           :  13/10/2010
Version        :
Description    :  SUPPRESSION DES DEMANDES DE LA VEILLE NON TERMINEES
[002] 07/05/2012 R. CASSIS     :spot:23802 - Ajout option E pour Solvency
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 25/03/2014 R. CASSIS   :spot:25427  - Correction sur gestion demandes Z (ajout lettre Z et ALL)
[102] 12/05/2014 R. CASSIS   :spot:25427  - test de non existence sur @site_cf
[103] 12/11/2014 C. DESPRET  :spot:27780  - Ajout des colonnes START_D et END_D a BEST..TREQJOB
[104] 26/05/2015 R. CASSIS   :spot:28811  - Gestion de la demande R pour le blocage du déversement Rétro
[105] 04/08/2017 R. Cassis   :spira:61508 Gestion plan2 pour le Post-omega des ES locales
[106] 17/05/2018 R. Cassis   :spira:68852 Suppression du contrôle des dates de comptabilisation Règlement car plus nécessaire et dangereux.
[107] 09/07/2019 R. Cassis   :spira:79708 Ajout de print pour tracer les lignes traitees pour debuguage
[108] 16/09/2019 R. Cassis   :spira:79154 Modification de la date affectée dans TREQJOBPLAN pour le retro Freeze @p_date_t au lieu de getdate()
*****************************************************/
declare @p_ACCOUNT_D    datetime
declare @p_PSTOMGEND_D  datetime
declare @p_BLCSHTYEA_NF int
declare @p_BLCSHTMTH_NF int
declare @p_CLODAT_D     datetime
declare @p_date         datetime

declare @erreur         int

select @erreur = 0
select @p_date = @p_date_t

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end


--BEGIN TRAN

-- Mise à jour des dates bilan dans la TREQJOBPLAN
Update BEST..TREQJOBPLAN
   set BALSHEYEA_NF = calend.BLCSHTYEA_NF,
       BALSHTMTH_NF = calend.BLCSHTMTH_NF,
       CLODAT_D     = dateadd( dd, -1, dateadd ( mm, 1, convert(datetime, convert(varchar, calendTrim.BLCSHTYEA_NF) + "/" + convert(varchar,calendTrim.BLCSHTMTH_NF) + "/01" ) ) )
from BEST..TREQJOBPLAN jobplan, BREF..TCALEND calend, BREF..TCALEND calendTrim
where jobplan.LAUNCH_D is NULL
  and jobplan.START_D is NULL
  and jobplan.REQCOD_CT in ('D','E','I','J','L','A','Z')  -- [002] [101]
  and calend.ACCOUNT_D = ( SELECT MIN(ACCOUNT_D)
                           FROM BREF..TCALEND cal
                           WHERE cal.ACCOUNT_D >= jobplan.DBCLO_D )
  and calendTrim.ACCOUNT_D = ( SELECT MIN(ACCOUNT_D)
                               FROM BREF..TCALEND cal2
                               WHERE cal2.ACCOUNT_D >= jobplan.DBCLO_D
                                 and cal2.CLOSING_B = 1 )
  and jobplan.SITE_CF in (@site_cf, 'ALL')                           -- PHP O21B ajout du controle sur le site [101] ajout ALL
  
select @erreur = @@error
--------------------------------------------------------------------
print '==> Lignes mises a jour dans TREQJOBPLAN a : rows = %1!', @@rowcount
--------------------------------------------------------------------
if @erreur != 0
begin
    select "Erreur :1: dans Update BEST..TREQJOBPLAN"
    goto fin
end

-- SUPPRESSION DES DEMANDES DE LA VEILLE NON TERMINEES
DELETE FROM BEST..TREQJOB
WHERE ( (BALSHEYEA_NF< @p_BLCSHTYEA_NF or BALSHTMTH_NF < @p_BLCSHTMTH_NF) or
        convert(char(8),DBCLO_D,112) <  convert(char(8),@p_date_t,112) )
  AND REQCOD_CT in ('D','E','I','J','L','A','T','Y','Z')  -- [002] [101] [102] [105]
  AND LAUNCH_D is null
  and SITE_CF  in (@site_cf, 'ALL')                                  -- PHP O21B ajout du controle sur le site [101]

select @erreur = @@error
--------------------------------------------------------------------
print '==> Lignes supprimees dans TREQJOB b : rows = %1!', @@rowcount
--------------------------------------------------------------------
if @erreur != 0
begin
    select "Erreur :3: dans Delete BEST..TREQJOB"
    goto fin
end

insert BEST..TREQJOB
select jobplan.SSD_CF,
       jobplan.BALSHEYEA_NF,
       jobplan.BALSHTMTH_NF,
       jobplan.CLODAT_D,
       jobplan.REQCOD_CT,
       jobplan.CRE_D,
       jobplan.DBCLO_D,
       null,                -- LAUNCH_D,
       jobplan.CLOPER_LS,
       jobplan.VRS_NF,
       jobplan.UPDUSR_CF,
       null, -- [103] START_D
       null, -- [103] END_D
       @site_cf SITE_CF,                                     -- PHP O21B ajout du site de la demande
       jobplan.ID_NF                                         -- PHP O21B ajout de l identifiant de la demande initiale
from BEST..TREQJOBPLAN jobplan
where convert(char(8), jobplan.DBCLO_D, 112) <= convert(char(8),@p_date_t,112)
  and jobplan.REQCOD_CT not in ('C', 'M', 'R')               -- [104] Ajout demande R
  and jobplan.LAUNCH_D is null
  and jobplan.SITE_CF in (@site_cf, 'ALL')                   -- PHP O21B ajout du site de la demande [101]
  and not exists ( select null
                   from BEST..TREQJOB job
                   where job.BALSHEYEA_NF = jobplan.BALSHEYEA_NF
                     and job.BALSHTMTH_NF = jobplan.BALSHTMTH_NF
                     and job.CLODAT_D     = jobplan.CLODAT_D
                     and job.REQCOD_CT    = jobplan.REQCOD_CT
                     and job.CRE_D        = jobplan.CRE_D     -- PHP O21B ajout de la date de creation de la demande
                     and job.SITE_CF      = jobplan.SITE_CF   --- PHP [003]
                     and job.ID_NF        = jobplan.ID_NF 
                     and job.DBCLO_D      = jobplan.DBCLO_D 
                     and job.SITE_CF      = @site_cf          -- [102] jobplan.SITE_CF   -- PHP O21B ajout de la date de creation de la demande                     
                  )
  
select @erreur = @@error
--------------------------------------------------------------------
print '==> Lignes inserees dans TREQJOB c : rows = %1!', @@rowcount
--------------------------------------------------------------------
if @erreur != 0
begin
    select "Erreur :4: dans Insert BEST..TREQJOB"
    goto fin
end

-- Pour les demandes D, on retope le launch_D à null pour regénérer les I, J
update BEST..TREQJOB
   set LAUNCH_D = null
from BEST..TREQJOB job, BEST..TREQJOBPLAN jobplan
where job.BALSHEYEA_NF = jobplan.BALSHEYEA_NF
  and job.BALSHTMTH_NF = jobplan.BALSHTMTH_NF
  and job.CLODAT_D     = jobplan.CLODAT_D
  and job.REQCOD_CT    = jobplan.REQCOD_CT
  and job.DBCLO_D      = jobplan.DBCLO_D
  and job.SITE_CF      = jobplan.SITE_CF   --- PHP [003]  
  and job.REQCOD_CT    in ('D', 'E', 'L', 'A')  -- [002]
  and jobplan.LAUNCH_D is null
  and jobplan.SITE_CF  = @site_cf                        -- PHP O21B ajout du controle sur le site 

select @erreur = @@error
--------------------------------------------------------------------
print '==> Lignes mises a jour dans TREQJOB d : rows = %1!', @@rowcount
--------------------------------------------------------------------
if @erreur != 0
begin
    select "Erreur :dans Update BEST..TREQJOB"
    goto fin
end

update BEST..TREQJOBPLAN
   set START_D = getdate(),
       END_D   = dateadd(HH, 20, getdate())
from BEST..TREQJOBPLAN jobplan
where convert(char(8), jobplan.DBCLO_D, 112) <= convert(char(8),@p_date_t,112)
  and jobplan.START_D is null
  and jobplan.REQCOD_CT not in ('C', 'M', 'R')   -- [104]
  and jobplan.SITE_CF = @site_cf                        -- PHP O21B ajout du controle sur le site 

select @erreur = @@error
--------------------------------------------------------------------
print '==> Lignes mises a jour dans TREQJOBPLAN e : rows = %1!', @@rowcount
--------------------------------------------------------------------
if @erreur != 0
begin
    select "Erreur :5: dans Update BEST..TREQJOBPLAN"
    goto fin
end

-- [104] Ajout gestion pour demande R
-- [108]
update BEST..TREQJOBPLAN
  set END_D = @p_date_t  -- [108] getdate()
from BEST..TREQJOBPLAN jobplan
    ,BREF..TCALEND calend
where jobplan.BALSHEYEA_NF = calend.BLCSHTYEA_NF
  and jobplan.BALSHTMTH_NF = calend.BLCSHTMTH_NF
  and convert(char(8), calend.ACCRETEND_D, 112) = convert(char(8),@p_date_t,112)
  and jobplan.REQCOD_CT in ('R')
  and jobplan.SITE_CF = @site_cf

select @erreur = @@error
--------------------------------------------------------------------
print '==> Lignes mises a jour dans TREQJOBPLAN f : rows = %1!', @@rowcount
--------------------------------------------------------------------
if @erreur != 0
begin
    select "Erreur :5: dans Update BEST..TREQJOBPLAN"
    goto fin
end

--[107]
select * from best..treqjob 
where SITE_CF = @site_cf
and   LAUNCH_D = null


/* [106]
-- ------------------------------------------------------------------------------------------
-- Contrôle sur les dates de comptabilisation des reglements.
-- ------------------------------------------------------------------------------------------
exec BEST..PuREQJOBPLANBLCSHTD_01 @p_date_t , @site_cf
select @erreur = @@error
if @erreur != 0
begin
    select "Erreur :appel: PuREQJOBPLANBLCSHTD_01"
    goto fin
end
*/



/* ------------------------------------------------------------
   Fin de la transaction
 -------------------------------------------------------------- */
--COMMIT TRAN
return 0

fin:
--ROLLBACK TRAN
return 1

GO


IF OBJECT_ID('dbo.PtREQJOBPLAN_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtREQJOBPLAN_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtREQJOBPLAN_01 >>>'
Go

/*
 Granting/Revoking Permissions on dbo.PtREQJOBPLAN_01 */
GRANT EXECUTE ON dbo.PtREQJOBPLAN_01 TO GOMEGA
Go
GRANT EXECUTE ON dbo.PtREQJOBPLAN_01 TO GDBBATCH
go


