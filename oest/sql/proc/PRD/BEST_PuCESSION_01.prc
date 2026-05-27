use BEST
go

/*
 * DROP PROC PuCESSION_01
 */
IF OBJECT_ID('PuCESSION_01') IS NOT NULL
BEGIN
    DROP PROC PuCESSION_01
    PRINT '<<< DROPPED PROC PuCESSION_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuCESSION_01
     (
       @libelle_inventaire datetime
     )

with execute as caller as

/***************************************************

Programme: PuCESSION_01

Fichier script associé : ESUCES01.PRC

Domaine : (ES) Estimation

Base principale : BEST, BRET

Version: 1

Auteur: 

Date de creation: 

Description du programme: 
	- Mise a jour de la table des versions TCESSION de la base BRET

Parametres: 
      - @libelle_inventaire

Conditions d'execution: 


Commentaires:

_________________
MOD0IFICATION 1

Auteur:

Date:

Version:

Description:
_________________
Modification - Removed dbo and added ‘with execute as caller as’ 
*****************************************************/

declare @erreur 	int,
        @tran_imbr bit

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
   Mise a jour de la table des versements base retrocession (TCESSION) 
 -------------------------------------------------------------- */

/* mise a jour de la part placee au dernier inventaire pour tous les 
   contrats/sections/exercices Acceptation (TCESSION dans BRET) 
   correspondant au contrat/section/exercice Retrocession 
  (TCESSION dans BEST)
   mise a jour de la date du dernier inventaire avec le libelle d'inventaire
   passe en parametre*/

update BRET..tcession
set	 A.balshepla_r = B.balshepla_r,        -- maj part placee au dernier inventaire
       A.lasbalshe_d = @libelle_inventaire   -- maj date du dernier inventaire
from   BRET..tcession A,
       BEST..tcession B,
       BTRAV..testssdtmp C
where	 A.retctr_nf     = B.retctr_nf         -- jointure sur contrat/exercice/section
       and A.rty_nf    = B.rty_nf
       and A.retsec_nf = B.retsec_nf       
	 and (    ( A.cesupdtyp_cf = ' '         --    versement non modifie
                  and A.cessts_cf = '01')      --    et statut du versement valide et actif
             or ( A.cesupdtyp_cf = 'S'         -- ou versement modifie
                  and A.cessts_cf = '03')      --    et statut du versement historise
            )
       and A.ssd_cf = C.ssd_cf

select @erreur = @@error

if @erreur != 0  goto fin 



/**********************************************************************************/

   
if @tran_imbr = 0
	COMMIT TRAN


/* ---------------------------------------------------------------
   reinitialisation des tables de travail
   --------------------------------------------------------------- */
truncate table BEST..tcession

return @erreur

fin:
if @tran_imbr =0
	ROLLBACK TRAN

return @erreur
go


/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESUCES01', 'PuCESSION_01', 'BEST', 'ME21'
go


IF OBJECT_ID('PuCESSION_01') IS NOT NULL
    PRINT '<<< CREATED PROC PuCESSION_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PuCESSION_01 >>>'
go
/*
 * Granting/Revoking Permissions on PuCESSION_01
 */
GRANT EXECUTE ON PuCESSION_01 TO GOMEGA
go

