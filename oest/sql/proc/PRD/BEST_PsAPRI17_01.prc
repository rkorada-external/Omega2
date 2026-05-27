use BEST
go

/* DROP PROC PsAPRI17_01
*/
IF OBJECT_ID('PsAPRI17_01') IS NOT NULL
   BEGIN
   DROP PROC PsAPRI17_01
   PRINT '<<< DROPPED PROC PsAPRI17_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsAPRI17_01
     
with execute as caller as

/***************************************************

Programme: PsAPRI17_01

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: Arnaud RUFFAULT

Date de creation: 08/06/2021

Description du programme: 
	Cree a partir de la procedure PsAPR_01 utilise dans IFRS4
	Descente des dernières periodes de compte reçues à partir de la table BCTA..TAPR 

Conditions d'execution: 

Commentaires:

*****************************************************/

declare @erreur int

select @erreur = 0


/***********************************/
/* Descente de la table BCTA..TAPR */
/***********************************/


	select distinct A.SSD_CF, CTR_NF, SCOENDMTH_NF, ACY_NF
	from   BCTA..TAPR A
	where 	A.ETY_D != NULL
	and	( 100 * A.ACY_NF + A.SCOENDMTH_NF ) = ( select max( 100 * B.ACY_NF + B.SCOENDMTH_NF )
		from  BCTA..TAPR B
		where A.CTR_NF = B.CTR_NF
		and 	B.ETY_D != NULL )
	order by CTR_NF
                  
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

IF OBJECT_ID('PsAPRI17_01') IS NOT NULL
   PRINT '<<< CREATED PROC PsAPRI17_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PsAPRI17_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsAPRI17_01
 */
GRANT EXECUTE ON dbo.PsAPRI17_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsAPRI17_01 TO GDBBATCH
go
