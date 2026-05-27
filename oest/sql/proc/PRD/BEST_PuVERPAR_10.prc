use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PuVERPAR_10
*/
IF OBJECT_ID('dbo.PuVERPAR_10') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuVERPAR_10
   PRINT '<<< DROPPED PROC dbo.PuVERPAR_10 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuVERPAR_10
     (
       @p_ssd_cf              USSD_CF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_par_d               datetime,
       @p_vrs_nf              numeric,
       @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme: PuVERPAR_10

Fichier script associé : ESUVER10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Modification d'enregistrement dansTVERPAR 

Parametres: 
       @p_ssd_cf              USSD_CF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_par_d               datetime,
       @p_vrs_nf              numeric,
       

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @nbligne  smallint,
        @nbtime  smallint

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

update TVERPAR
    set  vrs_nf       = @p_vrs_nf,
         lstupd_d     = getdate(),
         lstupdusr_cf = user
   where ssd_cf       = @p_ssd_cf
     and segtyp_ct    = @p_segtyp_ct
     and par_d        = @p_par_d

select @erreur = @@error, @nbligne = @@rowcount

if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
   goto fin
  end
   

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

exec sp_SCOR_INSPRC 'ESUVER10', 'PuVERPAR_10', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PuVERPAR_10') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuVERPAR_10 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuVERPAR_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuVERPAR_10
 */
GRANT EXECUTE ON dbo.PuVERPAR_10 TO GOMEGA
go

