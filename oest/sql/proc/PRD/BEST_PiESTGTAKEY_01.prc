USE BEST
Go

/*
 * DROP PROC PiESTGTAKEY_01
 */
IF OBJECT_ID('PiESTGTAKEY_01') IS NOT NULL
BEGIN
    DROP PROC PiESTGTAKEY_01
    PRINT '<<< DROPPED PROC PiESTGTAKEY_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiESTGTAKEY_01(
@p_clodat_d     datetime
)
     
with execute as caller as

/***************************************************

Programme: PiESTGTAKEY_01

Fichier script associé : BEST_PiESTGTAKEY_01

Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: O.GIRAUX
Date de creation: 09/08/2001

Description du programme: 
     - On complete la table TESTGTAKEY contenant les clés provenant du GTA 
       avec les comptes complets de date bilan > CLODAT_D
_________________
MODIFICATION 1

Auteur:     
Date:      
Description: 
_________________
Modification - Removed dbo and added ‘with execute as caller as’
*****************************************************/


declare @erreur      int       
select @erreur = 0

insert into BTRAV..TBESTGTAKEY
(
    CTR_NF,
    UWY_NF,
    UW_NT,
    END_NT,
    SEC_NF)
select distinct
    A.CTR_NF,
    A.UWY_NF,
    A.UW_NT,
    A.END_NT,
    A.SEC_NF
from    BTRAV..TESTCTRLIS A, BCTA..TCPLACC B
where   A.CTR_NF = B.CTR_NF
and B.BLCSHT_D > @p_clodat_d

/* Pour verifier que l'on n'a pas deja les memes cles dans la table */
and not exists ( select 1 from BTRAV..TBESTGTAKEY C    
                where
                C.CTR_NF = A.CTR_NF
                AND C.UWY_NF = A.UWY_NF
                AND C.UW_NT  = A.UW_NT
                AND C.END_NT = A.END_NT
                AND C.SEC_NF = A.SEC_NF)
                
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

exec sp_SCOR_INSPRC 'ESTGTAKEY', 'PiESTGTAKEY_01', 'BEST', 'ME69'
go

IF OBJECT_ID('PiESTGTAKEY_01') IS NOT NULL
    PRINT '<<< CREATED PROC PiESTGTAKEY_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PiESTGTAKEY_01 >>>'
go
/*
 * Granting/Revoking Permissions on PiESTGTAKEY_01
 */
GRANT EXECUTE ON PiESTGTAKEY_01 TO GOMEGA
go
