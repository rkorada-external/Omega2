USE BEST
Go

IF OBJECT_ID('dbo.PuREQJOBPLAN_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuREQJOBPLAN_01
   PRINT '<<< DROPPED PROC dbo.PuREQJOBPLAN_01 >>>'
END
go


create procedure PuREQJOBPLAN_01
     (
       @p_balsheyea_nf_i      smallint,
       @p_balshtmth_nf_i      tinyint,
       @p_clodat_d_i          datetime,
       @p_cre_d_i             UUPD_D,
       @p_reqcod_ct_i         char(1),
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_cloper_ls           UL64,           -- [SPOT15758] vde
       @p_dbclo_d             UUPD_D,
       @p_launch_d            UUPD_D,
       @p_updusr_cf           UUSR_CF,
       @p_vrs_nf              numeric,
       @p_start_d             UUPD_D,
       @p_end_d               UUPD_D,
       @p_erreur              varchar(64)=NULL output,
	    @p_ret                 varchar(64)=NULL output
     )
as

/***************************************************

Programme: PuREQJOBPLAN_01

Fichier script associé : BEST_PuREQJOBPLAN_01.prc
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: JP BESSY
Date de creation:

Description du programme:

      Pour modifier une demande de travaux dans la fenêtre ES2700, étant donné qu'on peut mettre
      à jour des zones correspondant à la clé, on réalise une insertion suivie d'une suppression
      dans la table TREQJOB.

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
       @p_balsheyea_nf_i      smallint,
       @p_balshtmth_nf_i      tinyint,
       @p_clodat_d_i          datetime,
       @p_cre_d_i             UUPD_D,
       @p_reqcod_ct_i         char(1),
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_cloper_ls           UL64,               -- [SPOT15758] vde
       @p_dbclo_d             UUPD_D,
       @p_launch_d            UUPD_D,
       @p_plan_d              UUPD_D,
       @p_updusr_cf           UUSR_CF,
       @p_vrs_nf              numeric,
      @p_erreur       varchar(64)=NULL output,

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1
Auteur: O. Arik
Date: 06/08/2002
Description: CLOPER_LS passe de 16 caract\350res \340 32 caract\350res

_________________
MODIFICATION 2

12/09/2008  JF. VDE SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 à 64 caractères
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
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

Exec PiREQJOBPLAN_01
         @p_balsheyea_nf ,
         @p_balshtmth_nf ,
         @p_clodat_d     ,
         @p_cre_d        ,
         @p_reqcod_ct    ,
         @p_ssd_cf       ,
         @p_cloper_ls    ,
         @p_dbclo_d      ,
         @p_launch_d     ,
         @p_updusr_cf    ,
         @p_vrs_nf       ,
         @p_start_d      ,
         @p_end_d        ,
         @p_erreur	 output

select @erreur = @@error
if IsNull(@p_erreur,"") != ""
  begin
   goto fin
  end

Exec PdREQJOBPLAN_01
         @p_balsheyea_nf_i ,
         @p_balshtmth_nf_i ,
         @p_clodat_d_i     ,
         @p_cre_d_i        ,
         @p_reqcod_ct_i    ,
         @p_ssd_cf        ,
         @p_erreur output

select @erreur = @@error
if IsNull(@p_erreur,"") != ""
  begin
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

IF OBJECT_ID('dbo.PuREQJOBPLAN_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuREQJOBPLAN_01>>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuREQJOBPLAN_01>>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuREQJOBPLAN_01
 */
GRANT EXECUTE ON dbo.PuREQJOBPLAN_01 TO PUBLIC
go
GRANT EXECUTE ON dbo.PuREQJOBPLAN_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuREQJOBPLAN_01 TO GDBBATCH
go
