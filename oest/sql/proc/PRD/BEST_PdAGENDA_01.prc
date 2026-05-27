USE BEST
Go

/*
 * DROP PROC dbo.PdAGENDA
 */

IF OBJECT_ID('dbo.PdAGENDA_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PdAGENDA_01
    PRINT '<<< DROPPED PROC dbo.PdAGENDA_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PdAGENDA_01(@d_now datetime)
as

/***************************************************

Programme: PdAGENDA_01

Fichier script associé : ESAGEN01.PRC

Base principale : BREF

Version: 1

Auteur: Bruno Montagnac (ASCOTT)

Date de creation: 12/01/1999

Description du programme:

      Suppression des enregistrements insérés
      il y a plus d'un mois dans les tables de
      BREF: TREFCMT, TREMINDER et TREMINUSR

Parametres: 
	@d_now datetime

Conditions d'execution: 
	Procedure lancée par l'ESEJ1004 (ESEJ1000) avant l'appel
	de la procedure PuUNDSTA_01 (mise à jour de l'agenda)


Commentaires:
	Les tables TREMINDER et TREMINUSR sont alimentées par le
	contenu de BTRAV..TESTRMD.
	Cette table est elle-même alimentée par le step ESTC3206
	de la chaine ESEJ1000


_________________
MODIFICATION 1

Auteur: 

Date: 

Version:

Description: 

*****************************************************/

declare @erreur int,
	    @d_oldest datetime


/* -------------- Détermination de la date limite de conservation -------------- */
/* -------------- des données insérées pas l'ESTC3206 -------------- */
select @d_oldest=dateadd(mm,-1,@d_now)


/******************
** BREF..TREFCMT **
******************/

delete from bref..trefcmt
where CMT_NT in (
  select CMT_NT from bref..trefcmt
  where substring(CMT_T,1,19) < @d_oldest and
   (cmt_t like "Stat period%Stat premiums%Accounting premiums%Ultimates premiums%Stat claims%Accounting claims%Stat Loss Ratio%Ultimate Loss Ratio%" or
    cmt_t like "Accounting premiums%Retained ultimates premiums%Accounting claims%Complete account Loss Ratio%Retained ultimate Loss Ratio%" or
    cmt_t like "Periode stat%Primes stat%Primes comptables%Primes ultimes%Sinistres stat%Sinistres comptables%S/P stat%S/P ultime%" or
    cmt_t like "Primes comptabilisees%Primes ultimes retenues%Sinistres comptabilises%S/P compte complet%S/P ultime retenu%")
)

select @erreur = @@error
if @erreur != 0 goto fin


/********************
** BREF..TREMINDER **
********************/

delete from BREF..TREMINDER
where RMD_NF in (
  select RMD_NF from bref..treminder
  where RMDISS_D < @d_oldest and
   (rmdobj_ll="New accounting transaction" or
    rmdobj_ll="New technical accounting subject premium" or
    rmdobj_ll="New complete account" or
    rmdobj_ll="Saisie de compte" or
    rmdobj_ll="Modification de l'assiette comptable" or
    rmdobj_ll="Saisie de compte complet")
)

select @erreur = @@error
if @erreur != 0 goto fin


/********************
** BREF..TREMINUSR **
********************/

delete from bref..treminusr
where RMD_NF in (
  select RMD_NF from bref..treminusr
  where ACTDON_D < @d_oldest and ACTDON_D <> "" and
   (rmdaddusr_cf=rmdissusr_cf and actexp_b=0 and actdon_b=0)
)

select @erreur = @@error
if @erreur != 0 goto fin


/* -------------- Fin de la procedure -------------- */
fin:   
  if @erreur != 0
  begin
    return @erreur
  end

return 0
go

IF OBJECT_ID('dbo.PdAGENDA_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PdAGENDA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PdAGENDA_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdAGENDA_01
 */
GRANT EXECUTE ON dbo.PdAGENDA_01 TO GOMEGA
go

