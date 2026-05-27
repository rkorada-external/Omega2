USE BEST
Go

/*
 * DROP PROC dbo.PdACCSUP_02
 */
IF OBJECT_ID('dbo.PdACCSUP_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PdACCSUP_02
    PRINT '<<< DROPPED PROC dbo.PdACCSUP_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdACCSUP_02

with execute as caller as

/***************************************************

Programme: PdACCSUP_02

Fichier script associé : ESDACC02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)

Date de creation: 05/07/99

Description du programme: 
    - suppression dans BEST..TACCSUP de lignes inserees dans
        BTRAV..TESTACCSUP
Parametres:

Conditions d'execution: 
    - lancée par PiESTACCSUP_01 (ESIJ0091.cmd)

Commentaires:

_________________
MODIFICATION 1

Auteur:    M. DJELLOULI 
Date:       27/04/2005
Version:    5.1
Description: SPOT 11445 - Renommage EST_ESIJ0090_TACCSUP remplace TESTACCSUP
[001] 10/01/2014 R. Cassis :spot:25427 Centralisation ajoute as caller
*****************************************************/


declare     @erreur         int

select @erreur = 0


/* ------------------------------------------------------------------
   Mise à jour de la table des écritures de services BEST..TACCSUP
------------------------------------------------------------------ */

delete  BEST..TACCSUP
from    BEST..TACCSUP A, BTRAV..EST_ESIJ0090_TACCSUP B
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

exec sp_SCOR_INSPRC 'ESDACC02', 'PdACCSUP_02', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PdACCSUP_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PdACCSUP_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PdACCSUP_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdACCSUP_02
 */
GRANT EXECUTE ON dbo.PdACCSUP_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PdACCSUP_02 TO GDBBATCH
go

