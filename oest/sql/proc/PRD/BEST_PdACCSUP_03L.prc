USE BEST
Go

/*
 * DROP PROC dbo.PdACCSUP_03L
 */
IF OBJECT_ID('dbo.PdACCSUP_03L') IS NOT NULL
BEGIN
    DROP PROC dbo.PdACCSUP_03L
    PRINT '<<< DROPPED PROC dbo.PdACCSUP_03L >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PdACCSUP_03L

with execute as caller as

/***************************************************

Programme: PdACCSUP_03L

Fichier script associé : ESDACC03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: J. Ribot
Date de creation: 24/06/2005

Description du programme:
    - suppression dans BEST..TACCSUP de lignes inserees dans
        BTRAV..TESTACCSUP
Parametres:

Conditions d'execution:
    - lancée par PiESTACCSUP_04 (ESPJ0091.cmd)

Commentaires:

_________________
MODIFICATION 1

Auteur:
Date:
Version:
Description:
[001] 18/10/2022 M.NAJI :spira 107371
*****************************************************/


declare     @erreur         int

select @erreur = 0


/* ------------------------------------------------------------------
   Mise à jour de la table des écritures de services BEST..TACCSUP
------------------------------------------------------------------ */

delete  BEST..TACCSUP
from    BEST..TACCSUP A, BTRAV..EST_ESLJ0090_TACCSUP B
where   B.TRN_NT = A.ACCTRN_NT

select @erreur = @@error

if @erreur != 0  goto fin


return 0

fin:
return 1

go

/*
 * fin de la procedure
 */

/*   Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDACC03', 'PdACCSUP_03L', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PdACCSUP_03L') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PdACCSUP_03L >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PdACCSUP_03L >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdACCSUP_03L
 */
GRANT EXECUTE ON dbo.PdACCSUP_03L TO GOMEGA
go
GRANT EXECUTE ON dbo.PdACCSUP_03L TO GDBBATCH
go

