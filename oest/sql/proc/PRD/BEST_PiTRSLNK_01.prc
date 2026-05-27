USE BEST
Go

/*
 * DROP PROC PiTRSLNK_01
 */
IF OBJECT_ID('PiTRSLNK_01') IS NOT NULL
BEGIN
    DROP PROC PiTRSLNK_01
    PRINT '<<< DROPPED PROC PiTRSLNK_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiTRSLNK_01
     
with execute as caller as

/***************************************************

Programme: PiTRSLNK_01

Fichier script associé : ESITRS01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 18/06/97

Description du programme: 
     - Affectation aux 3 postes cumuls (primes, charges et sinistres), les postes comptables
associés. 
 

Parametres:
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:
_________________
MODIFICATION - Removed dbo and added ‘with execute as caller as’
*****************************************************/


declare @erreur      int,
        @tran_imbr	  bit
        

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


/* ------------------------------------------------------------
   Lecture des postes cumulés
 -------------------------------------------------------------- */

insert into BTRAV..TESTTRSLNK ( ACMTRS_NT, DETTRS_CF )
select ACMTRS_NT, DETTRS_CF
from	BREF..TTRSLNK
where	PRS_CF = 600

select @erreur = @@error

if @erreur != 0  goto fin


select * from	BTRAV..TESTTRSLNK
order	by  DETTRS_CF 

select @erreur = @@error

if @erreur != 0  goto fin


               
/**********************************************************************************/

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

exec sp_SCOR_INSPRC 'ESITRS01', 'PiTRSLNK_01', 'BEST', 'ME69'
go


IF OBJECT_ID('PiTRSLNK_01') IS NOT NULL
    PRINT '<<< CREATED PROC PiTRSLNK_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PiTRSLNK_01 >>>'
go
/*
 * Granting/Revoking Permissions on PiTRSLNK_01
 */
GRANT EXECUTE ON PiTRSLNK_01 TO GOMEGA
go

