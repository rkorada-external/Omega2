USE BEST
go

IF OBJECT_ID('dbo.PuREQJOB_05') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuREQJOB_05
    IF OBJECT_ID('dbo.PuREQJOB_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuREQJOB_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuREQJOB_05 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure PuREQJOB_05
(
   @p_cre_d		    datetime,
   @p_balsheyea_nf	smallint,
   @p_balshtmth_nf	tinyint,
   @p_clodat_d	    datetime
)

as

/***************************************************

Programme: PuREQJOB_05

Fichier script associé : BEST_PuREQJOB_05.prc
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI
Date de creation: 26-03-2004
Description du programme:   Topage des demandes Z
	- Mise a jour de la date de traitement ( LAUNCH_D ) dans BEST..TREQJOB 
    pour les chargement d'Inventaire
    
Parametres: 
  - @p_cre_d : la date de traitement 
	- @p_balsheyea_nf : année ( période comptable )
	- @p_balshtmth_nf : mois ( période comptable )
	- @p_clodat_d : CLODAT
_________________
MODIFICATION    [001]
Auteur         :D.GATIBELZA
Date           :18/11/2010
Version        :10.1
Description    :ESTDOM19070 V10 scheduler pour le lancement des inventaires

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 25/03/2014 R. Cassis   :spot:25427  - Ajout controle sur cre_d
*****************************************************/
declare @erreur int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1


/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */
if @@trancount = 0
begin
    select @tran_imbr = 0
BEGIN TRAN
end


/*******************************************/
/* Mise à jour de BEST..TREQJOB */
/*******************************************/

/* 1er cas: si libellé d'inventaire = CLODAT1_D */

update BEST..TREQJOB
   set LAUNCH_D = Getdate()
from BEST..TREQJOB
where REQCOD_CT = "Z"
  and BALSHEYEA_NF = @p_balsheyea_nf
  and BALSHTMTH_NF = @p_balshtmth_nf
  and convert( char(8), CLODAT_D, 112 ) = @p_clodat_d
  and convert( char(8), dbclo_d, 112 ) <= @p_cre_d      -- [101]
  and LAUNCH_D =  NULL

select @erreur = @@error
if @erreur != 0  goto fin


--[001]
update BEST..TREQJOBPLAN
   set LAUNCH_D = Getdate(),
       START_D  = Getdate(),
       END_D    = Getdate()
where REQCOD_CT = "Z"
  and BALSHEYEA_NF = @p_balsheyea_nf
  and BALSHTMTH_NF = @p_balshtmth_nf
  and convert( char(8), CLODAT_D, 112 ) = @p_clodat_d
  and convert( char(8), dbclo_d, 112 ) <= @p_cre_d       -- [101]
  and LAUNCH_D =  NULL

select @erreur = @@error
if @erreur != 0  goto fin

/**********************************************************************************/
if @tran_imbr = 0
    COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go
IF OBJECT_ID('dbo.PuREQJOB_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuREQJOB_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuREQJOB_05 >>>'
go
GRANT EXECUTE ON dbo.PuREQJOB_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuREQJOB_05 TO GDBBATCH
go

