use BEST
go

/*
 * DROP PROC PsPFUNWIT_01
 */
IF OBJECT_ID('PsPFUNWIT_01') IS NOT NULL
BEGIN
    DROP PROC PsPFUNWIT_01
    PRINT '<<< DROPPED PROC PsPFUNWIT_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsPFUNWIT_01

with execute as caller as

/***************************************************

Programme: PsPFUNWIT_01

Fichier script associ_ : ESSPFN01.PRC

Domaine : (ES) Estimation

Base principale :BRET

Version: 1

Auteur: ME32 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Selection de tous les enregistrements dans TPFUNWIT

Parametres:


Conditions d'execution:


Commentaires:
_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description : Removed dbo and added ‘with execute as caller as’

*****************************************************/

declare @erreur int

Select B.RETCTR_NF, B.RTY_NF, B.PLC_NT, B.PLCVER_NT, B.SSD_CF, CLMFUNMOD_CT,
       CLMFUN_R, URRFUNMOD_CT, URRFUN_R, IBNFUNMOD_CT, IBNFUN_R,
       DEPADM_CT, DEPORI_B, CANDEP_B,
       convert (char(8), A.CRE_D, 112)
from	BRET..TPFUNWIT A, BRET..TPLACEMT B, BTRAV..TESTSSD C
where A.SSD_CF = C.SSD_CF
  AND  A.RETCTR_NF = B.RETCTR_NF
  AND  A.RTY_NF = B.RTY_NF
  and A.PLC_NT = B.PLC_NT
  and A.PLCVER_NT = B.PLCVER_NT
  AND  B.HIS_B = 0


/*
Select RETCTR_NF, RTY_NF, PLC_NT, PLCVER_NT, A.SSD_CF, CLMFUNMOD_CT,
       CLMFUN_R, URRFUNMOD_CT, URRFUN_R, IBNFUNMOD_CT, IBNFUN_R,
       DEPADM_CT, DEPORI_B, CANDEP_B,
       convert (char(8), CRE_D, 112)
from	BRET..TPFUNWIT A, BTRAV..TESTSSD B
where A.SSD_CF=B.SSD_CF
group by RETCTR_NF, RTY_NF, PLC_NT
having A.PLCVER_NT = max(A.PLCVER_NT)
order	by RETCTR_NF, RTY_NF, PLC_NT asc

*/

return 0
go
IF OBJECT_ID('PsPFUNWIT_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsPFUNWIT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PFUNWIT_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsPFUNWIT_01
 */
GRANT EXECUTE ON PsPFUNWIT_01 TO GOMEGA
go


