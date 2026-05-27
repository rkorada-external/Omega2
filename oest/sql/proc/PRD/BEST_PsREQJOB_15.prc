USE BEST
go

IF OBJECT_ID('dbo.PsREQJOB_15') IS NOT NULL
BEGIN
    DROP PROC dbo.PsREQJOB_15
    PRINT '<<< DROPPED PROC dbo.PsREQJOB_15 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsREQJOB_15
     (
      @p_ssd_cf            smallint,
      @p_lstupd_d          datetime
     )
as

/***************************************************

Programme               : PsREQJOB_15

Fichier script associ‰  : BEST_PsREQJOB_15.prc

Domaine                 : (ES) Estimation

Base principale         : BEST

Version                 : 1

Auteur                  : T.RIPERT

Date de creation        : 13/08/2010

Description du programme:

      Selection la derniere date de création des demandes I ou L

Parametres              :

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare
   @erreur           int,
   @date_inventaire  date

-- Si date lstupd_d de TLIFMOD est < à la cre_d de treqjob (L - 1900)
-- Alors on prend le max CRE_D de la demnde I,L avec CRE_D < lstupd_d de TLIFMOD

if exists(select  1
            from  BEST..TREQJOB
           where  REQCOD_CT      =  'L'
             and  BALSHEYEA_NF   =  1900
             and  BALSHTMTH_NF   =  1
             and  CLODAT_D       =  '19000101'
             and  SSD_CF         =  @p_ssd_cf
             and  CRE_D          <  @p_lstupd_d)
   BEGIN
         SELECT   @date_inventaire = CRE_D
            from  BEST..TREQJOB
           where  REQCOD_CT      =  'L'
             and  ssd_cf         =  @p_ssd_cf
             and  BALSHEYEA_NF   =  1900
             and  BALSHTMTH_NF   =  1
             and  CLODAT_D       =  '19000101'
   END
ELSE
   BEGIN
      SELECT   @date_inventaire = MAX(CRE_D)
         from  BEST..TREQJOB
        where  REQCOD_CT   in ('L','I')
          and  CRE_D    <  @p_lstupd_d
          and  ssd_cf   =  @p_ssd_cf

   END

Select @erreur = @@error

if @erreur != 0
	begin
   	  raiserror 20005 "APPLICATIF;PsREQJOB_15"
        return @erreur
	end

select @date_inventaire

return 0
go

IF OBJECT_ID('dbo.PsREQJOB_15') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsREQJOB_15 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsREQJOB_15 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOB_13
 */
GRANT EXECUTE ON dbo.PsREQJOB_15 TO GOMEGA
go

