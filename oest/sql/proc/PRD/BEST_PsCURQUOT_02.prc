USE BEST
go

IF OBJECT_ID('dbo.PsCURQUOT_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsCURQUOT_02
    IF OBJECT_ID('dbo.PsCURQUOT_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCURQUOT_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsCURQUOT_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCURQUOT_02

as

/***************************************************

Programme: PsCURQUOT_02

Fichier script associé : BEST_PsCURQUOT_02

Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI
Date de creation: 10-03-2004

Description du programme: 
      Les calculs de ESIJ1000.cmd ne sont executés que si le cours de change a évolué depuis la dernière
      execution du JOB.
      
      Mise a jour de la Date LAUNCH_D de TREQJOB (REQCOD_CT = 'M') par la date de dernière mise à jour 
      des cours de change MAX(LSTUPD_D) contenue dans la TABLE BREF..TCURQUOT (SSD_CF = 99).

      Le traitement ESIJ1000.cmd est conditionné de la manière suivante :
            - SI                      [Max(LSTUPD_D) de BREF..TCURQUOT (SSD_CF = 99)]    
                 est différente de   [LAUNCH_D de BEST..TREQJOB (REQCOD_CT = 'M')]
             ALORS [EXECUTION DU TRAITEMENT ESIJ1000] et [Nouvelle MAJ de LAUNCH_D]
            - SINON [RIEN]


Parametres: 
Conditions d'execution: 
Commentaires:
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur int

declare	@RetourProc     int

declare @v_reqcod_ct           char(1),
        @v_ssd_cf              USSD_CF

declare @v_maj_datecours       UUPD_D
declare @v_maj_traitement      UUPD_D

declare @p_maj_ligne int

select @erreur = 0

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

select @RetourProc = 0

select @v_reqcod_ct = 'M'
select @v_ssd_cf = 99

/* Recuperation de la DAte du Cours de CHANGE */
SELECT DISTINCT @v_maj_datecours = MAX(lstupd_d)
FROM BREF..TCURQUOT
WHERE ssd_cf = @v_ssd_cf

select @erreur = @@error
 if @erreur != 0
   begin
      goto fin 
   end


/* Verification si Mise à Jour de Ligne dans TREQJOB */ 
select distinct @v_maj_traitement = max(launch_d)
from   BEST..TREQJOB
WHERE  reqcod_ct = @v_reqcod_ct and ssd_cf = @v_ssd_cf and SITE_CF=@site_cf

select @erreur = @@error
 if @erreur != 0
   begin
      goto fin 
   end


IF @v_maj_traitement = @v_maj_datecours
    BEGIN
        select @RetourProc = 1
    END

fin:
select @RetourProc
-- Select "Date MAJ Date de Cours de Change    : " 
-- Select @v_maj_datecours 
-- Select "Date MAJ Date de dernier Traitement : " 
-- Select @v_maj_traitement
return 0
go

IF OBJECT_ID('dbo.PsCURQUOT_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCURQUOT_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCURQUOT_02 >>>'
go
GRANT EXECUTE ON dbo.PsCURQUOT_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsCURQUOT_02 TO GDBBATCH
go
