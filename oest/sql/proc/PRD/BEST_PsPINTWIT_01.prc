use BEST
go

/*
 * DROP PROC PsPINTWIT_01
 */
IF OBJECT_ID('PsPINTWIT_01') IS NOT NULL
BEGIN
    DROP PROC PsPINTWIT_01
    PRINT '<<< DROPPED PROC PsPINTWIT_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsPINTWIT_01

with execute as caller as

/***************************************************

Programme: PsPINTWIT_01

Fichier script associ_ : ESSPIN01.PRC

Domaine : (ES) Estimation

Base principale :BRET

Version: 1

Auteur: ME32 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Selection de tous les enregistrements dans TPINTWIT

Parametres:


Conditions d'execution:


Commentaires:
_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description: : Removed dbo and added ‘with execute as caller as’

*****************************************************/

declare @erreur int

Select B.RETCTR_NF, B.RTY_NF, B.PLC_NT, B.PLCVER_NT,
       RETTRTCUR_CF,
       CLMFUNINT_R, URRFUNINT_R, IBNFUNINT_R, A.SSD_CF,
       convert (char(8), a.CRE_D, 112)
       from	BRET..TPINTWIT A, BRET..TPLACEMT B, BTRAV..TESTSSD C
where A.SSD_CF = C.SSD_CF
  AND  A.RETCTR_NF = B.RETCTR_NF
  AND  A.RTY_NF = B.RTY_NF
  and A.PLC_NT = B.PLC_NT
  and A.PLCVER_NT = B.PLCVER_NT
  AND  B.HIS_B = 0

/*
Select RETCTR_NF, RTY_NF, PLC_NT, PLCVER_NT,
       RETTRTCUR_CF,
       CLMFUNINT_R, URRFUNINT_R, IBNFUNINT_R, A.SSD_CF,
       convert (char(8), CRE_D, 112)
from	BRET..TPINTWIT A, BTRAV..TESTSSD B
where A.SSD_CF=B.SSD_CF
group by RETCTR_NF, RTY_NF, PLC_NT
having A.PLCVER_NT = max(A.PLCVER_NT)
order	by RETCTR_NF, RTY_NF, PLC_NT asc

*/

return 0
go
IF OBJECT_ID('PsPINTWIT_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsPINTWIT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PINTWIT_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsPINTWIT_01
 */
GRANT EXECUTE ON PsPINTWIT_01 TO GOMEGA
go


