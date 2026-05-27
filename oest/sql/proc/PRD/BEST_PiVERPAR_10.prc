USE BEST
Go

/* DROP PROC dbo.PiVERPAR_10
*/
IF OBJECT_ID('dbo.PiVERPAR_10') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiVERPAR_10
   PRINT '<<< DROPPED PROC dbo.PiVERPAR_10 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiVERPAR_10
     (
       @p_ssd_cf              USSD_CF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_par_d               datetime,
       @p_vrs_nf              numeric,
       @p_erreur	varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiVERPAR_10

Fichier script associé : ESIVER10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 17/04/1997

Description du programme:
	 - Contrôle si la dernière version de paramètrage inserer en base correspond
         aux données de la nouvelle version à inserer.
       - Insertion d'enregistrement dans TVERPAR

Parametres:
       @p_ssd_cf              USSD_CF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_par_d               datetime,
       @p_vrs_nf              numeric,
       @p_erreur	varchar(64)=NULL output

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
_________________
MODIFICATION    [002]
Auteur:         D.GATIBELZA
Date:           27/05/2008
Version:        8.1
Description:    EDI15180
*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

/* -------------------------------------------------------------------------
   Contrôle si la dernière version de paramètrage inserer en base correspond
   aux données de la nouvelle version à inserer.
   Si oui -> "insert" interdit et renvoi message d'erreur à l'application
---------------------------------------------------------------------*/
declare @vrs_nf numeric

 select @vrs_nf = vrs_nf
   from TVERPAR
  where segtyp_ct = @p_segtyp_ct
    and ssd_cf    = @p_ssd_cf
  group by segtyp_ct, ssd_cf
 having par_d = max(par_d)
 order by segtyp_ct, ssd_cf

if @vrs_nf = @p_vrs_nf begin	select @p_erreur="20003 ESTIMATION" goto fin end


/*--------------------
 Insert dans TVERPAR
--------------------*/
insert into TVERPAR
      (
                ssd_cf,
                segtyp_ct,
                par_d,
                vrs_nf,
                cre_d,
                creusr_cf,
                lstupd_d,
                lstupdusr_cf
      )
 values
      (
        @p_ssd_cf,
        @p_segtyp_ct,
        @p_par_d,
        @p_vrs_nf,
        getdate(),
        user,
        getdate(),
        user
      )

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   if @erreur = 2601
 	   select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliquée */
   else
 	   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

   goto fin
  end


if @tran_imbr = 0
   COMMIT TRAN

return 0

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

exec sp_SCOR_INSPRC 'ESIVER10', 'PiVERPAR_10', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PiVERPAR_10') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiVERPAR_10 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiVERPAR_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiVERPAR_10
 */
GRANT EXECUTE ON dbo.PiVERPAR_10 TO GOMEGA
go

