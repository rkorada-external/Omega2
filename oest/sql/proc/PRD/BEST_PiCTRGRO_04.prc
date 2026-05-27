USE BEST
Go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */

 /* DROP PROC dbo.PiCTRGRO_04
*/
IF OBJECT_ID('dbo.PiCTRGRO_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiCTRGRO_04
   PRINT '<<< DROPPED PROC dbo.PiCTRGRO_04 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiCTRGRO_04
     (
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric(10,0),
       @p_segtyp_ct           char(1),
       @p_option              tinyint,
       @p_err_ano             tinyint
     )
as

/***************************************************

Programme: PiCTRGRO_04

Fichier script associé : ESICTR03.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: M. DJELLOULI - 22/08/2004 

Date de creation: 

Description du programme: 

      Suppression totale d'une version
      PGM Calqué sur PiCTRGRO_03

Parametres: 

Conditions d'execution: 

Commentaires:
_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:

*****************************************************/

declare @erreur     int
declare @tran_on    smallint

select @erreur  = 0
select @tran_on = 0


begin tran
select @tran_on = 1

-- Suppression totale version et rechargement total

IF (@p_option=1) or (@p_option=3)
BEGIN
   if @tran_on = 1
      commit tran

   select @tran_on = 0

   begin tran
   select @tran_on = 1

   EXECUTE @erreur = BEST..PuVERSION_06 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct, @p_err_ano with recompile
   if @erreur != 0
      goto fin
END

-- Suppression partielle version et rechargement partiel

ELSE IF (@p_option=2)
BEGIN

   EXECUTE @erreur = BEST..PuVERSION_07 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct, @p_err_ano with recompile
   if @erreur != 0
      goto fin
END

if @tran_on = 1
   commit tran
return 0
  

fin:
   if @erreur != 0
      begin
        if @tran_on = 1
        begin
           rollback tran
           IF (@p_option=1)
           BEGIN
              DELETE BEST..TCTRANO
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TSEGANO
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TSEGEST
	       WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TLABOCY
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TSEGMENT
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TCTRGRO
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
           END
           IF (@p_option=2)
           BEGIN
              DELETE BEST..TSEGANO
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TSEGEST
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TLABOCY
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
           END
           IF (@p_option=3)
           BEGIN
              DELETE BEST..TCTRANO
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TSEGANO
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
              DELETE BEST..TCTRGRO
               WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
           END
        end   -- fin du RollBack
        raiserror 20005 "FAILED: PiCTRGRO_04 " 
        return @erreur
   end
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDCTR01', 'PiCTRGRO_04', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PiCTRGRO_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiCTRGRO_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiCTRGRO_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiCTRGRO_04
 */
GRANT EXECUTE ON dbo.PiCTRGRO_04 TO GOMEGA
go

