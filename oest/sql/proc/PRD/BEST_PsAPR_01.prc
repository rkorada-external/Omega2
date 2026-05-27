use BEST
go

/* DROP PROC PsAPR_01
*/
IF OBJECT_ID('PsAPR_01') IS NOT NULL
   BEGIN
   DROP PROC PsAPR_01
   PRINT '<<< DROPPED PROC PsAPR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsAPR_01(
	@p_option         char(1) )
     
with execute as caller as

/***************************************************

Programme: PsAPR_01

Fichier script associé : ESSAPR01.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME69

Date de creation: 

Description du programme: 
	Descente des dernières periodes de compte reçues à partir de la table BCTA..TAPR 

Parametres: 
	- @p_option : I pour inventaire et Q pour Quotidien. En inventaire, on restreint 
la sélection sur les filiales de l'inventaire ( BTRAV..TESTSSD )

Conditions d'execution: 

Commentaires:

_________________
MODIFICATION 1

Auteur : MONTAGNAC

Date:	23-08-99

Version:

Description: Ajout de la filiale dans le select
_________________
MODIFICATION - Removed dbo and added ‘with execute as caller as’
*****************************************************/

declare @erreur int

select @erreur = 0


/***********************************/
/* Descente de la table BCTA..TAPR */
/***********************************/

/* en inventaire */
/*****************/

if ( @p_option = 'I' )
begin
	select distinct A.SSD_CF, CTR_NF, SCOENDMTH_NF, ACY_NF
	from   BCTA..TAPR A, BTRAV..TESTSSD C
	where 	A.SSD_CF = C.SSD_CF
	and	A.ETY_D != NULL
	and	( 100 * A.ACY_NF + A.SCOENDMTH_NF ) = ( select max( 100 * B.ACY_NF + B.SCOENDMTH_NF )
		from  BCTA..TAPR B
		where A.CTR_NF = B.CTR_NF
		and   B.ETY_D != NULL )
	order by CTR_NF
end


/* en quotidien */
/****************/

else
begin
	select distinct A.SSD_CF, CTR_NF, SCOENDMTH_NF, ACY_NF
	from   BCTA..TAPR A
	where 	A.ETY_D != NULL
	and	( 100 * A.ACY_NF + A.SCOENDMTH_NF ) = ( select max( 100 * B.ACY_NF + B.SCOENDMTH_NF )
		from  BCTA..TAPR B
		where A.CTR_NF = B.CTR_NF
		and 	B.ETY_D != NULL )
	order by CTR_NF
end
                  
select @erreur = @@error

if @erreur != 0
   begin
      return @erreur
   end

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

go

IF OBJECT_ID('PsAPR_01') IS NOT NULL
   PRINT '<<< CREATED PROC PsAPR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PsAPR_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsAPR_01
 */
GRANT EXECUTE ON PsAPR_01 TO GOMEGA
go

