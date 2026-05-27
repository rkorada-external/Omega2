use BEST
go

USE BEST
Go

/*
 * DROP PROC dbo.PiPARSEG_10
 */
IF OBJECT_ID('dbo.PiPARSEG_10') IS NOT NULL
BEGIN
    DROP PROC dbo.PiPARSEG_10
    PRINT '<<< DROPPED PROC dbo.PiPARSEG_10 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiPARSEG_10
     (
       @p_ssd_cf              USSD_CF,
       @p_segtyp_ct           USEGTYP_CT,     
       @p_seg_d               datetime,
       @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiPARSEG_10

Fichier script associé : ESIPAR10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
  

     - Insertion de certaine paramètre dans BTEC..PiJOBQUEUE_02 afin
       de lancer une procedure de batch asynchrone qui créer un périmètre 
       de PARSEGation.


Parametres:
 
 	    @p_ssd_cf              USSD_CF,        : Filiale
       @p_segtyp_ct           USEGTYP_CT,     : Type PARSEG
       @p_seg_d               datetime,       : Date du PARSEG
       @p_erreur       varchar(64)=NULL output

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/


declare @erreur      int,
        @tran_imbr	  bit,
        @nbligne     smallint,
        @nbtime      smallint

declare @ssd_cf       varchar(30),
        @segtyp_ct    varchar(30),
        @seg_d        char(8),
        @getdate      datetime,
        @user         UUPDUSR_CF

select @getdate = GetDate()
select @user = user

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

/*-----------------------------------------------------------------------------
	Lancement procedure batch asynchrone qui créer un périmètre de PARSEG
      			>>>>> Insert dans BTEC..PiJOBQUEUE_04 <<<<<
------------------------------------------------------------------------------*/

select @ssd_cf      = convert(varchar(30),@p_ssd_cf)
select @segtyp_ct   = convert(varchar(30),@p_segtyp_ct)
select @seg_d       = convert(char(8),@p_seg_d,112)

     exec @erreur =  BTEC..PiJOBQUEUE_04 
                          "best01a",
                          @user,
                          @getdate,                       
                          @segtyp_ct,
                          @ssd_cf,
                          @seg_d,
                          "S","","","","","","","","","","","","","",""
 
      if @erreur != 0 goto fin                   
/**********************************************************************************/

if @tran_imbr = 0
	COMMIT TRAN

return @erreur

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESIPAR10', 'PiPARSEG_10', 'BEST', 'ME34'
go
IF OBJECT_ID('dbo.PiPARSEG_10') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiPARSEG_10 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiPARSEG_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiPARSEG_10
 */
GRANT EXECUTE ON dbo.PiPARSEG_10 TO GOMEGA
go

