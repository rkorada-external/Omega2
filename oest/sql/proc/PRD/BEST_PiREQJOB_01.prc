USE BEST
go

 /* DROP PROC dbo.PiREQJOB_01
*/
IF OBJECT_ID('dbo.PiREQJOB_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiREQJOB_01
   PRINT '<<< DROPPED PROC dbo.PiREQJOB_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiREQJOB_01
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            UUPD_D,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_cloper_ls           UL64,     -- [SPOT15758] vde
       @p_dbclo_d             UUPD_D,
       @p_launch_d            UUPD_D,
       @p_updusr_cf           UUSR_CF,
       @p_vrs_nf              numeric,
       @p_erreur	varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiREQJOB_01

Fichier script associé : BEST_PiREQJOB_01
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME24 avec Infotool version 2.0 (AUTO)
Date de creation:

Description du programme:

      Insertion d'enregistrement dans TREQJOB lors de la saisie de demandes de travaux
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
       @p_cloper_ls           UL64,        -- [SPOT15758] vde
       @p_dbclo_d             UUPD_D,
       @p_launch_d            UUPD_D,
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

MODIFICATION 2

12/09/2008  JF. VDE SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 à 64 caractères
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @erreur = 0

declare @site_cf        varchar(10)
declare @param1         varchar(20)
select  @param1 = convert(varchar,@p_ssd_cf)

Execute @erreur = BEST..PsSITE_01 @param1,'2',@site_cf output

--select @site_cf

select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

if not exists (select 1 from BEST..TREQJOB where 
               balsheyea_nf=@p_balsheyea_nf and balshtmth_nf=@p_balshtmth_nf and clodat_d=@p_clodat_d and cre_d=@p_cre_d and reqcod_ct=@p_reqcod_ct
               and ssd_cf=@p_ssd_cf and dbclo_d=@p_dbclo_d and site_cf=@site_cf)
begin
insert into BEST..TREQJOB
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
        @p_vrs_nf,
        @site_cf
      )
end

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

IF OBJECT_ID('dbo.PiREQJOB_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiREQJOB_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiREQJOB_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiREQJOB_01
 */
GRANT EXECUTE ON dbo.PiREQJOB_01 TO PUBLIC
go
GRANT EXECUTE ON dbo.PiREQJOB_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiREQJOB_01 TO GDBBATCH
go
