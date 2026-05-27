USE BEST
GO

/*
 * DROP PROC dbo.PsTREQJOB_04
*/

IF OBJECT_ID('dbo.PsTREQJOB_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsTREQJOB_04
   PRINT '<<< DROPPED PROC dbo.PsTREQJOB_04 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsTREQJOB_04

as

/***************************************************

Programme: PsTREQJOB_04

Fichier script associé : BEST_PsTREQJOB_04.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME57

Date de creation:15/04/2004

Description du programme:

      Selection d'enregistrement dansTREQJOB


Conditions d'execution: Lancée par la fenêtre w_feuille_es2002


Commentaires:

_________________
MODIFICATION 1

    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
_________________
MODIFICATION    [002]
Auteur:         D.GATIBELZA
Date:           01/04/2010
Version:        10.1
Description:    SRVIE16960 Adaptation de TLIFSTAREP  création d'une version du plan vie à la demande + ES plan à intégrer
                Exercice plan = Année bilan +2 ( et non année Bilan )
*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @nbligne  smallint,
        @nbtime  smallint,
        @max_cre DateTime

select @max_cre = max(cre_d)
from BEST..TREQJOB
where ssd_cf = 99
and reqcod_ct = "A"

--[002] Ajout +2
Select balsheyea_nf+2, balshtmth_nf, clodat_d, cre_d
from BEST..TREQJOB
where ssd_cf = 99
and reqcod_ct = "A"
and cre_d = @max_cre

group by balsheyea_nf, balshtmth_nf, clodat_d, cre_d
order by balsheyea_nf, balshtmth_nf, clodat_d, cre_d

go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESUSUP04', 'PsTREQJOB_04', 'BEST', 'ME57'
go

IF OBJECT_ID('dbo.PsTREQJOB_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsTREQJOB_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsTREQJOB_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsTREQJOB_04
 */
GRANT EXECUTE ON dbo.PsTREQJOB_04 TO GOMEGA
go

