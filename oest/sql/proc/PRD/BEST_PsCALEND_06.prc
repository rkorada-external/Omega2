USE BEST
Go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsCALEND_06
*/


IF OBJECT_ID('dbo.PsCALEND_06') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCALEND_06
   PRINT '<<< DROPPED PROC dbo.PsCALEND_06 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCALEND_06
     (
	@p_typper	char(1)
     )
as

/***************************************************

Programme: PsCALEND_06

Fichier script associé : ESSCAL06.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 13/08/1998

Description du programme: 

      Recherche de la période comptable (de service) dans TCALEND (BREF) 
	+ Est on en période de service, cad; la date du jour est elle comprise entre la 
	date de fin de période exceptionnelle (borne exclue) et la date 
	de comptabilisation (borne incluse) ?

Parametres: 

 	@p_typper  char(1)  /* type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)    */ 
	

Conditions d'execution: 


Commentaires:


*****************************************************/

declare @erreur int,
	 @ligne int,


	@BLCSHTYEA_NF smallint,		
      @BLCSHTMTH_NF tinyint,	
 	@DATE		datetime,   	/* date de recherche */
      @SPCEND_D     datetime,  /* fin de période exceptionnelle   */
 	@ACCOUNT_D	datetime,  	/* date de comptabilisation ( fin service )  */
 	@CLOSING_B	bit,          /* top inventaire groupe */

      @END_D     datetime, 
 	@COUNT_D	datetime,  	

	@retour     char(2)      /* 'O' => On est en période de service */
					/* 'N' => On n'est pas en période de service */


/**********************************************************************************************/
/* Select dans BREF..TCALEND                                                                  */ 
/* Recherche de la période de service                                                         */
/**********************************************************************************************/

select @DATE = getdate() 

Execute @erreur = BREF..PsCALEND_02 
			@DATE ,          
			@p_typper,
			@BLCSHTYEA_NF output,
        		@BLCSHTMTH_NF output,
			@SPCEND_D output,
			@ACCOUNT_D output,
			@CLOSING_B output


if @erreur != 0 
	begin
   		raiserror 20005 "APPLICATIF;TCALEND" /* erreur de lecture */
        	return @erreur
	end



/********************************************************************************************/
/* Est on en période de service ?                                                           */
/********************************************************************************************/

Select  @END_D = @SPCEND_D
Select  @COUNT_D = @ACCOUNT_D

select @retour = 'N'

If convert(Char(10), getdate(),112) > convert(Char(10), @END_D,112)
and convert(Char(10), getdate(),112) <= convert(Char(10), @COUNT_D,112) 
Begin
	select @retour = 'O'
End


Select @retour



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCAL06', 'PsCALEND_06', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsCALEND_06') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCALEND_06 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCALEND_06 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCALEND_06
 */
GRANT EXECUTE ON dbo.PsCALEND_06 TO GOMEGA
go

