USE BEST
Go

/*
 * DROP PROC dbo.PiSEGEST_20
 */
IF OBJECT_ID('dbo.PiSEGEST_20') IS NOT NULL
BEGIN
    DROP PROC dbo.PiSEGEST_20
    PRINT '<<< DROPPED PROC dbo.PiSEGEST_20 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiSEGEST_20
     (
       @p_ssd_cf              USSD_CF,
       @p_segtyp_ct           USEGTYP_CT,     
       @p_vrs_nf              numeric(10,0),
       @p_lag_cf              ULAG_CF,
       @p_seg_nf              USEG_NF,
       @p_unixname            char(12)
     )
as

/***************************************************

Programme: PiSEGEST_20

Fichier script associé : ESISEG20.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1


Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
  

     - Insertion de certaine paramètre dans BTEC..PiJOBQUEUE_02 afin
       de lancer une procedure de batch asynchrone qui imprime la 
       "Liste des exercices" d'un ou de "TOUS" les segments.


Parametres:
 
       @p_ssd_cf              USSD_CF,        : Filiale
       @p_segtyp_ct           USEGTYP_CT,     : Type segment   
       @p_vrs_nf              numeric(10,0)   : Version
       @p_lag_cf              ULAG_CF         : Langue de l'utilisateur
       @p_seg_nf              USEG_NF         : Segment 
       @p_unixname            char(12)        : Imprimante à utiliser

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: JP BESSY

Date: 07/08/1997

Version:

Description: Contrôle préliminaire permettant de vérifier s'il y a au moins une ligne à éditer,
ou s'il y a trop de lignes et donc d'orienter vers une édition de nuit.

*****************************************************/


declare @erreur      int,
        @nbligne     smallint,
        @nbtime      smallint

declare @ssd_cf       varchar(30),
        @segtyp_ct    varchar(30),
        @vrs_nf       varchar(30),
        @lag_cf       varchar(30),
        @seg_nf       varchar(30),
        @date_t       char(8),
        @getdate      datetime,
        @user         UUPDUSR_CF

declare @nb_ligne	   int		/* Nombre de lignes à éditer */
declare @retour	   int		/* 0-> aucune ligne à éditer!!*/
					/* 1-> Ok, il y a asser et pas trop de lignes à éditer!!*/
					/* 2-> Trop de lignes à éditer!! */

select @getdate = GetDate()
select @user = user

select @erreur = 0

/*-----------------------------------------------------------------------------------
	Contrôle préliminaire sur le nombre de lignes à éditer.
------------------------------------------------------------------------------*/
IF @p_seg_nf = "TOUS"
   BEGIN
     Select @nb_ligne = Count(*)
       From BEST..TCTRGRO
      Where ssd_cf    = @p_ssd_cf
        and vrs_nf    = @p_vrs_nf
        and segtyp_ct = @p_segtyp_ct
   END
ELSE
   BEGIN
     Select @nb_ligne = Count(*)
       From BEST..TSEGEST
      Where ssd_cf    = @p_ssd_cf
        and vrs_nf    = @p_vrs_nf
        and segtyp_ct = @p_segtyp_ct
        and seg_nf    = @p_seg_nf

   END

IF @nb_ligne < 1 
   Select @retour = 0			/* 0-> aucune ligne à éditer!!*/
ELSE
   Begin
      IF @nb_ligne > 1251
          Select @retour = 2		/* 2-> Trop de lignes à éditer!! */
      ELSE
         Select @retour = 1		/* 1-> Ok, il y a asser et pas trop de lignes à éditer!!*/
   End

IF @retour = 1
 BEGIN

	/*-----------------------------------------------------------------------------
		Lancement procedure batch asynchrone qui Imprime "La liste des exercices"
	      d'un ou de "TOUS" les segments.
      			>>>>> Insert dans BTEC..PiJOBQUEUE_02 <<<<<
	------------------------------------------------------------------------------*/

	select @ssd_cf      = convert(varchar(30),@p_ssd_cf)
	select @segtyp_ct   = convert(varchar(30),@p_segtyp_ct)
	select @seg_nf      = convert(varchar(30),@p_seg_nf)
	select @vrs_nf      = convert(varchar(30),@p_vrs_nf)
	select @lag_cf      = convert(varchar(30),@p_lag_cf)
	select @date_t      = convert(char(8),@getdate,112)


     exec @erreur =  BTEC..PiJOBQUEUE_02 
                          "eest03a",
                          @user,
                          @getdate,
                          @seg_nf, 
                          @segtyp_ct, 
                          @ssd_cf,
                          @vrs_nf, 
                          @lag_cf,
                          @date_t,
                          "","","","","","","","","","","",
                          @p_unixname
 
	      if @erreur != 0 goto fin                   
	/**********************************************************************************/
 END

/*-----------------------------------------------------------------------------------
	SELECT Final: Retour du contrôle
------------------------------------------------------------------------------*/
Select @retour

return @erreur

fin:
return @erreur
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESISEG20', 'PiSEGEST_20', 'BEST', 'ME34'
go
IF OBJECT_ID('dbo.PiSEGEST_20') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiSEGEST_20 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiSEGEST_20 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiSEGEST_20
 */
GRANT EXECUTE ON dbo.PiSEGEST_20 TO GOMEGA
go

