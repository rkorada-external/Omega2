USE BEST
Go

/*
 * DROP PROC PsESTSSD_01
 */
IF OBJECT_ID('PsESTSSD_01') IS NOT NULL
BEGIN
    DROP PROC PsESTSSD_01
    PRINT '<<< DROPPED PROC PsESTSSD_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsESTSSD_01
     
with execute as caller as

/***************************************************

Programme: PsESTSSD_01

Fichier script associé : ESSSSD02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 01/10/97

Description du programme: 
	- selection des filiales des inventaires annexes, des libellés correspondants
	- pour chaque filiale sélectionnée, on recherchera dans la table BTRAV..TCPTCONTR1
les établissements concernés par le module de calcul des PNA FAC.
	

Parametres:
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: 	

Date:		

Version:	

Description: Removed dbo and added ‘with execute as caller as’
[00x] 30/12/2013 R. Cassis :spot:25427 - Ajout grant to gdbbatch
*****************************************************/


declare 	@erreur     	int,
        	@tran_imbr	bit


select @erreur = 0
select @tran_imbr = 1


/* ------------------------------------------------------------
   Création des tables temporaires
 -------------------------------------------------------------- */

create table #LISTESSD1 (
	SSD_CF		USSD_CF	NOT NULL,
	CLODAT_D	datetime	NOT NULL )


create table #LISTESSD2 (
	SSD_CF		USSD_CF	NOT NULL,
	CLODAT_D	datetime	NOT NULL,
	ESB_CF		UESB_CF	NOT NULL )


/* ------------------------------------------------------------
   Début de la transaction
 -------------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


/* -------------------------------------------------------------------------------
   Selection des filiales des inventaires annexes présentes dans BTRAV..TESTSSD
------------------------------------------------------------------------------- */

/* 1er cas : la filiale a demandé un inventaire principal ou CLOTYP_B = 1 */

insert into #LISTESSD1
	( SSD_CF, CLODAT_D )
select SSD_CF, CLODAT2_D
from 	BTRAV..TESTSSD
where	CLOTYP_B = 1
and 	CLODAT2_D != NULL
union	
select SSD_CF, CLODAT3_D
from 	BTRAV..TESTSSD
where	CLOTYP_B = 1
and 	CLODAT3_D != NULL
union
select SSD_CF, CLODAT4_D
from 	BTRAV..TESTSSD
where	CLOTYP_B = 1
and 	CLODAT4_D != NULL
union
select SSD_CF, CLODAT1_D
from 	BTRAV..TESTSSD
where	CLOTYP_B = 1
and 	CLODAT1_D != NULL


select @erreur = @@error

if @erreur != 0  goto fin


/* 2ème cas : la filiale n'a pas demandé un inventaire principal ou CLOTYP_B = 0 */

insert into #LISTESSD1
	( SSD_CF, CLODAT_D )
select SSD_CF, CLODAT1_D
from 	BTRAV..TESTSSD
where	CLOTYP_B = 0
and 	CLODAT1_D != NULL
union	
select SSD_CF, CLODAT2_D
from 	BTRAV..TESTSSD
where	CLOTYP_B = 0
and 	CLODAT2_D != NULL
union	
select SSD_CF, CLODAT3_D
from 	BTRAV..TESTSSD
where	CLOTYP_B = 0
and 	CLODAT3_D != NULL
union
select SSD_CF, CLODAT4_D
from 	BTRAV..TESTSSD
where	CLOTYP_B = 0
and 	CLODAT4_D != NULL

select @erreur = @@error

if @erreur != 0  goto fin


/* ----------------------------------------------------------------------------
   Recherche des établissements des filiales par accès à la table BREF..TESB
---------------------------------------------------------------------------- */

insert into #LISTESSD2
	( SSD_CF, CLODAT_D, ESB_CF )
select distinct A.SSD_CF, A.CLODAT_D, B.ESB_CF
from 	#LISTESSD1 A, BREF..TESB B
where	A.SSD_CF = B.SSD_CF

select @erreur = @@error

if @erreur != 0  goto fin


/* -----------------------------------------------
   Descente de la table en fichier EST_PNAPARAM
----------------------------------------------- */

select convert( char(8), CLODAT_D, 112 ), SSD_CF, ESB_CF
from	#LISTESSD2
order	by CLODAT_D, SSD_CF, ESB_CF

                 
/**********************************************************************************/


/* ------------------------------------------------------------
   Fin de la transaction
 -------------------------------------------------------------- */

if @tran_imbr = 0
	 COMMIT TRAN

return 0


fin:
if @tran_imbr = 0
	 ROLLBACK TRAN

return 1

go

/*
 * fin de la procedure 
 */


/*   Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSSD02', 'PsESTSSD_01', 'BEST', 'ME69'
go

IF OBJECT_ID('PsESTSSD_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsESTSSD_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsESTSSD_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsESTSSD_01
 */
GRANT EXECUTE ON PsESTSSD_01 TO GOMEGA
go
GRANT EXECUTE ON PsESTSSD_01 TO GDBBATCH
go

