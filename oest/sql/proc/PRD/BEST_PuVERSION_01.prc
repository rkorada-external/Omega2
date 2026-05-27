use BEST
go


USE BEST
Go

/* DROP PROC dbo.PuVERSION_01
*/
IF OBJECT_ID('dbo.PuVERSION_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuVERSION_01
   PRINT '<<< DROPPED PROC dbo.PuVERSION_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuVERSION_01
     (
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric,
       @p_vrs_lm              UL32,
       @p_cmt_nt              UCMT_NT = NULL,
       @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme: PuVERSION_01

Fichier script associé : ESUVER01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
      - Contrôle si la version n'est pas vérouillée
      - Modification d'enregistrement dansTVERSION 

Parametres: 
       @p_segtyp_ct           USEGTYP_CT, : Type segment
       @p_ssd_cf              USSD_CF,    : Filiale
       @p_vrs_lm              UL32,       : Nom de la version
       @p_vrs_nf              numeric,    : Code de la version
       @p_cmt_nt              UCMT_NT = NULL, : Commentaire
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

declare @erreur    int,
        @tran_imbr	bit,
        @nbligne   smallint,
        @nbtime    smallint,
        @vrsloc_b  bit

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

/* -------------------------------------------------------------------
   Contrôle si "vrsloc_b" est égal à 1 alors
   update interdit et renvoi message d'erreur à l'application 
---------------------------------------------------------------------*/
select @vrsloc_b = vrsloc_b 
  from TVERSION 
 where segtyp_ct = @p_segtyp_ct
   and ssd_cf = @p_ssd_cf
   and vrs_nf = @p_vrs_nf

if @vrsloc_b = 1  begin	select @p_erreur="20000 ESTIMATION" goto fin end


/*------------
    Update
-------------*/
update TVERSION
    set vrs_lm = @p_vrs_lm,
        cmt_nt = @p_cmt_nt,
        lstupd_d     = getdate(),
        lstupdusr_cf = user
   where segtyp_ct = @p_segtyp_ct
     and ssd_cf = @p_ssd_cf
     and vrs_nf = @p_vrs_nf

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

exec sp_SCOR_INSPRC 'ESUVER01', 'PuVERSION_01', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PuVERSION_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuVERSION_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuVERSION_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuVERSION_01
 */
GRANT EXECUTE ON dbo.PuVERSION_01 TO GOMEGA
go

