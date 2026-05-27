USE BEST
go

/*
 * DROP PROC PsVERSION_03
 */
IF OBJECT_ID('PsVERSION_03') IS NOT NULL
BEGIN
    DROP PROC PsVERSION_03
    PRINT '<<< DROPPED PROC PsVERSION_03 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsVERSION_03
	(
		@p_option 	char(1)
	)
     
with execute as caller as

/***************************************************

Programme: PsVERSION_03

Fichier script associé : ESSVER03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: M.HA-THUC 

Date de creation: 14/09/1998

Description du programme: 
     - Recherche des versions actives en Actuariat ou Estimation pour toutes 
les filiales. On alimente la table BTRAV..TESTSSDVRS. 


Parametres:
 	- @p_option : 'I' pour inventaire et 'Q' pour quotidien. En inventaire, on
restreint la selection des filiales à la table BTRAV..TESTSSD.

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: M. DJELLOULI
Date: 05/10/2004
Version: 
Description: Modification de Version par BTRAV..TESTSSD
             Option I : Toutes les Filiales qui ont demandées un Inventaire
             Option Q : Toutes les Filiales dont les Versions existent
                        dans TREQJOB s'il existe une demande d'inventaire
                        Sinon, toutes les Filiales de TVERPAR
_________________
Modification - Removed dbo and added ‘with execute as caller as’
*****************************************************/

declare @erreur      int
        
select @erreur = 0


/* --------------------------------
   Truncate de la table de travail
 ---------------------------------- */
truncate table BTRAV..TESTSSDVRS

select @erreur = @@error

if @erreur != 0  goto fin


/* -------------------------------------------
   Alimentation de la table BTRAV..TESTSSDVRS
 --------------------------------------------- */

/* en inventaire */
/*****************/

if ( @p_option = 'I' )
begin
-- Debut MOD01 - Plus de Jointure sur TVERPAR

-- 	insert into BTRAV..TESTSSDVRS
-- 		( SSD_CF, SEGTYP_CT, VRS_NF )
-- 	select A.SSD_CF, A.SEGTYP_CT, A.VRS_NF
-- 	from	BEST..TVERPAR A, BTRAV..TESTSSD C
-- 	where	A.SSD_CF = C.SSD_CF
-- 	and	A.PAR_D = ( select max( B.PAR_D )
-- 		from BEST..TVERPAR B
-- 		where 	A.SSD_CF = B.SSD_CF
-- 		and	A.SEGTYP_CT = B.SEGTYP_CT )

	insert into BTRAV..TESTSSDVRS
		( SSD_CF, SEGTYP_CT, VRS_NF )
	select SSD_CF, 'A' as SEGTYP_CT, VRS_NF
	from	BTRAV..TESTSSD C
-- FIN MOD01 - Plus de Jointure sur TVERPAR
end

/* en quotidien */
/****************/
else
        begin

        -- Debut MOD01 
        	insert into BTRAV..TESTSSDVRS
        		( SSD_CF, SEGTYP_CT, VRS_NF )
        	select SSD_CF, 'A' as SEGTYP_CT, VRS_NF
        	from	BTRAV..TESTSSD
            
        	insert into BTRAV..TESTSSDVRS
        		( SSD_CF, SEGTYP_CT, VRS_NF )
        	select A.SSD_CF, A.SEGTYP_CT, A.VRS_NF
        	from	BEST..TVERPAR A
            where A.SSD_CF NOT IN (SELECT DISTINCT SSD_CF 
                                   FROM BTRAV..TESTSSD)
              and A.VRS_NF IN (SELECT VRS_NF 
                               FROM BEST..TVERSION D
                               WHERE VRSSTS_CT <> 'AN'
                                 and VRSLOC_B <> 0
                          		 and A.SEGTYP_CT = D.SEGTYP_CT )
        	  and A.PAR_D = ( select max( B.PAR_D )
        		from BEST..TVERPAR B
        		where 	A.SSD_CF = B.SSD_CF
        		and	A.SEGTYP_CT = B.SEGTYP_CT )
        
        -- FIN MOD01 
        end
    
select @erreur = @@error

if @erreur != 0  goto fin


               
/**********************************************************************************/

return 0

fin:

return 1
go

/*
 * fin de la procedure 
 */

/*   Insertion dans la table des procedures
 *-------------------------------------------*/


IF OBJECT_ID('PsVERSION_03') IS NOT NULL
    PRINT '<<< CREATED PROC PsVERSION_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsVERSION_03 >>>'
go
/*
 * Granting/Revoking Permissions on PsVERSION_03
 */
GRANT EXECUTE ON PsVERSION_03 TO GOMEGA
go

