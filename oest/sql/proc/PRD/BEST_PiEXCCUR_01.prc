use BEST
go

USE BEST
Go

/*
 * DROP PROC PiEXCCUR_01
 */
IF OBJECT_ID('PiEXCCUR_01') IS NOT NULL
BEGIN
    DROP PROC PiEXCCUR_01
    PRINT '<<< DROPPED PROC PiEXCCUR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiEXCCUR_01
     
with execute as caller as

/***************************************************

Programme: PiEXCCUR_01

Fichier script associé : ESIEXC01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 18/06/97

Description du programme: 
     - Sélection des taux de conversion au 31/12 de chaque bilan ainsi que le dernier
taux de conversion connu pour les filiales dont au moins une affaire a été sélectionnée.

 

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
   Sélection des taux de conversions
 -------------------------------------------------------------- */

/* insert	into BTRAV..TESTEXCCUR 
	( SSD_CF, CUR_CF, EXCYEA_NF, EXC_R )
select SSD_CF, CUR_CF, EXC_y, EXC_R 
from	BTRAV..TSTASTAQUOT
where	exists (
	select A.SSD_CF
	from	BTRAV..TESTCTRLIS A, BTRAV..TSTASTAQUOT B
	where	A.SSD_CF = B.SSD_CF ) 


select @erreur = @@error

if @erreur != 0  goto fin */

/*
select SSD_CF, CUR_CF, EXCYEA_NF, EXC_R 
from	BTRAV..TESTEXCCUR 
order  by SSD_CF, CUR_CF, EXCYEA_NF

select @erreur = @@error

if @erreur != 0  goto fin */


select SSD_CF, CUR_CF, EXC_y, EXC_R 
from	BTRAV..TSTASTAQUOT

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

exec sp_SCOR_INSPRC 'ESIEXC01', 'PiEXCCUR_01', 'BEST', 'ME69'
go

IF OBJECT_ID('PiEXCCUR_01') IS NOT NULL
    PRINT '<<< CREATED PROC PiEXCCUR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PiEXCCUR_01 >>>'
go
/*
 * Granting/Revoking Permissions on PiEXCCUR_01
 */
GRANT EXECUTE ON PiEXCCUR_01 TO GOMEGA
go

