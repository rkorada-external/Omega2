USE BEST
Go

/*
 * DROP PROC PuVERSION_04
 */
IF OBJECT_ID('PuVERSION_04') IS NOT NULL
BEGIN
    DROP PROC PuVERSION_04
    PRINT '<<< DROPPED PROC PuVERSION_04 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuVERSION_04
     (
       @libelle_inventaire     datetime,
       @date_comptabilisation  datetime
     )

with execute as caller as

/***************************************************

Programme: PuVERSION_04

Fichier script associé : ESUVER04.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: 

Date de creation: 

Description du programme: 
	- Mise a jour de la table des versions TVERSION de la base BEST

Parametres: 
      - @libelle_inventaire
      - @date_comptabilisation

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:
_________________
Modification - Removed dbo and added ‘with execute as caller as’
*****************************************************/

declare @erreur    	int,
        @tran_imbr		bit

select @erreur = 0
select @tran_imbr = 1


/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_imbr= 0
  BEGIN TRAN
  end



/* ------------------------------------------------------------
   Mise a jour de la table des versions (TVERSION) 
 -------------------------------------------------------------- */

/* mise a jour du libelle d'inventaire, de la date de comptabilisation et
   de l'etat de la version pour la version active */
 

update BEST..tversion
set	A.vrsclo_d  = @libelle_inventaire,
	A.vrsacc_d  = @date_comptabilisation,
	A.vrssts_ct = "CO" 
from	BEST..tversion A, BTRAV..testssdtmp B
where	A.ssd_cf = B.ssd_cf
and   A.vrs_nf = B.vrs_nf
and	A.segtyp_ct = B.segtyp_ct
     	

select @erreur = @@error

if @erreur != 0  goto fin 



/**********************************************************************************/

   
if @tran_imbr = 0
	COMMIT TRAN


return @erreur

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go


/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESUVER04', 'PuVERSION_04', 'BEST', 'ME21'
go


IF OBJECT_ID('PuVERSION_04') IS NOT NULL
    PRINT '<<< CREATED PROC PuVERSION_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PuVERSION_04 >>>'
go
/*
 * Granting/Revoking Permissions on PuVERSION_04
 */
GRANT EXECUTE ON PuVERSION_04 TO GOMEGA
go

