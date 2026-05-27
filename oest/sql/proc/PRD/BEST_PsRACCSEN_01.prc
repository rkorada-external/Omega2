USE BEST
go
/*
 * DROP PROC dbo.PsRACCSEN_01
 */
IF OBJECT_ID('dbo.PsRACCSEN_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsRACCSEN_01
    PRINT '<<< DROPPED PROC dbo.PsRACCSEN_01 >>>'
END
go

/*
 * creation de la procedure
 */

create procedure PsRACCSEN_01 (
	@SCOENDMTH_NF	tinyint	output,
	@PROPER_N		tinyint	output,
	@RETCTR_NF		char(9)
	)

as

/***************************************************

Programme: PsRACCSEN_01

Fichier script associé : ESSRAN01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME27 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Ramene le mois de la derniere periode d'envoi et la periodicite des
	provisions pour le programme ESTC2106.c

Parametres:


Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs

*****************************************************/

/* Mois de la derniere periode de compte */
SELECT @SCOENDMTH_NF=SCOENDMTH_NF
from BRET..TRACCSEN
group by RETCTR_NF
having RETCTR_NF=@RETCTR_NF
and	RETACCYER_NF = max(RETACCYER_NF)
order by RETCTR_NF

/* Periodicite */
select @PROPER_N=PROPER_N
from BRET..TRETCTR
group by RETCTR_NF
having RETCTR_NF=@RETCTR_NF
and	RTY_NF=max(RTY_NF)
order by RETCTR_NF

go


/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSRAN01', 'PsRACCSEN_01', 'BEST', 'ME27'
go


IF OBJECT_ID('dbo.PsRACCSEN_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsRACCSEN_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsRACCSEN_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRACCSEN_01
 */
GRANT EXECUTE ON dbo.PsRACCSEN_01 TO GOMEGA
go

