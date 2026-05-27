USE BEST
go

IF OBJECT_ID('dbo.PiREQJOBPLAN_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiREQJOBPLAN_01
   PRINT '<<< DROPPED PROC dbo.PiREQJOBPLAN_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiREQJOBPLAN_01
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_cloper_ls           UL64,
       @p_dbclo_d             UUPD_D,
       @p_launch_d            UUPD_D,
       @p_updusr_cf           UUSR_CF,
       @p_vrs_nf              numeric,
       @p_start_d             UUPD_D,
       @p_end_d               UUPD_D,
       @p_erreur	varchar(64)=NULL output
     )
as

/***************************************************

Programme               : PiREQJOBPLAN_01

Fichier script associé  : BEST_PiREQJOBPLAN_01
Domaine                 : (ES) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  : Tony RIPERT
Date de creation        : 06/09/2010
Description du programme:

      Insertion d'enregistrement dans TREQJOB_PLAN lors de la saisie de demandes de travaux
      ( w_feuille_es_2700 -> dw_maitre -> sqlpreview )

      Les types de demandes sont :
	   Comptabilisation C
	   Inventaire I
	   Inventaire + SNEM J
	   S/R Vie L
	   Prop Sin CE S
	   Chargemt Inventaire Z      -> maj TBOPAR avec les tables de l'inventaire à utiliser
	   Demande Inventaire D       -> création auto des demandes d'inventaire ( I ou J) pour les filiales
                                    saisies ds champ CLOPER_LS

Parametres:
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_cloper_ls           UL64,
       @p_dbclo_d             UUPD_D,
       @p_launch_d            UUPD_D,
       @p_plan_d              UUPD_D,
       @p_updusr_cf           UUSR_CF,
       @p_vrs_nf              numeric,
       @p_erreur	varchar(64)=NULL output

Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1
Auteur: O. Arik
Date: 06/08/2002
Description: CLOPER_LS passe de 16 caractères à 32 caractères

_________________
MODIFICATION 2

12/09/2008  JF. VDE SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 à 64 caractères
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur      int,
        @tran_imbr	bit

select @erreur = 0

declare @site_cf        varchar(10)
Execute @erreur = BEST..PsSITE_01 @p_ssd_cf,'2',@site_cf output

select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

insert into BEST..TREQJOBPLAN
      (
                balsheyea_nf,
                balshtmth_nf,
                clodat_d,
                cre_d,
                reqcod_ct,
                ssd_cf,
                cloper_ls,
                dbclo_d,
                launch_d,
                updusr_cf,
                start_d,
                end_d,
                vrs_nf,
                site_cf
      )
 values
      (
        @p_balsheyea_nf,
        @p_balshtmth_nf,
        @p_clodat_d,
        @p_cre_d,
        @p_reqcod_ct,
        @p_ssd_cf,
        @p_cloper_ls,
        @p_dbclo_d,
        @p_launch_d,
        @p_updusr_cf,
        @p_start_d,
        @p_end_d,
        @p_vrs_nf,
        @site_cf
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


IF OBJECT_ID('dbo.PiREQJOBPLAN_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiREQJOBPLAN_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiREQJOBPLAN_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiREQJOB_01
 */
GRANT EXECUTE ON dbo.PiREQJOBPLAN_01 TO PUBLIC
go
GRANT EXECUTE ON dbo.PiREQJOBPLAN_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiREQJOBPLAN_01 TO GDBBATCH
go
