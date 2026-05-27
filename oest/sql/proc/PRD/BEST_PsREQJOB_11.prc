USE BEST
Go
 /* DROP PROC dbo.PsREQJOB_11
*/
IF OBJECT_ID('dbo.PsREQJOB_11') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsREQJOB_11
   PRINT '<<< DROPPED PROC dbo.PsREQJOB_11 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsREQJOB_11
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsREQJOB_11

Fichier script associé : ESSREQ08.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME24 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Sélection d'enregistrement dans TREQJOB + Libellé de la version dans TVERSION
                                              + Période exceptionnelle

Parametres:
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: M. DJELLOULI
Date: 07/07/2004
Version:
Description: SPOT 10420 - Lorsqu'une demande d'inventaire est faite, on va chercher la version de Segmentation


_________________
MODIFICATION 1
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs


*****************************************************/


-- Début MOD01 : Sélection de Versions

declare @erreur int, @v_segtyp_ct  USEGTYP_CT

declare @v_VRS_NF   numeric(10,0)
declare @v_VRS_LM  UL32

select @v_segtyp_ct = ''

/*Proposition de sinistralité */
If @p_reqcod_ct = 'S' select @v_segtyp_ct = 'E'

/*Demande d'inventaire */
If @p_reqcod_ct = 'I' select @v_segtyp_ct = 'A'

declare  @zz_ssd_cf              USSD_CF

    select distinct @zz_ssd_cf = b.ssd_cf, @v_VRS_NF = max(B.vrs_nf)
    from BEST..TVERSION B, BEST..TVERPAR C
    where VRSSTS_CT <> 'AN' and VRSLOC_B = 0
      and C.SEGTYP_CT = @v_segtyp_ct
      and b.ssd_cf = @p_ssd_cf
      and b.ssd_cf = c.ssd_cf
      and b.vrs_nf = c.vrs_nf
    group by b.ssd_cf
    having C.PAR_D = max( C.PAR_D )
    order by b.ssd_cf

    select distinct @v_VRS_LM = VRS_LM
    from BEST..TVERSION
    where ssd_cf = @p_ssd_cf
    and vrs_nf = @v_VRS_NF
    and SEGTYP_CT = @v_segtyp_ct

 Select TR.balsheyea_nf,
        TR.balshtmth_nf,
        TR.clodat_d,
        TR.cre_d,
        TR.reqcod_ct,
        TR.ssd_cf,
        TR.cloper_ls,
        TR.dbclo_d,
        TR.launch_d,
        TR.updusr_cf,
        @v_VRS_NF,
        @v_VRS_LM,
        TC.specend_d,
        TC.account_d
   from BEST..TREQJOB  TR, BEST..TVERSION  TV, BREF..TCALEND  TC
  where TR.balsheyea_nf = @p_balsheyea_nf
    and TR.balshtmth_nf = @p_balshtmth_nf
    and TR.clodat_d = @p_clodat_d
    and TR.cre_d = @p_cre_d
    and TR.reqcod_ct = @p_reqcod_ct
    and TR.ssd_cf = @p_ssd_cf
    and TV.ssd_cf = @p_ssd_cf
    and TR.vrs_nf *= TV.vrs_nf
    and TV.segtyp_ct = @v_segtyp_ct
    and TC.blcshtyea_nf = @p_balsheyea_nf
    and TR.balshtmth_nf *= TC.blcshtmth_nf


   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "Erreur Selection TREQJOB" /* erreur de modification */
      return @erreur
   end


return 0
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSREQ11', 'PsREQJOB_11', 'BEST', 'ME24'
go

IF OBJECT_ID('dbo.PsREQJOB_11') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsREQJOB_11 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsREQJOB_11 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOB_11
 */
GRANT EXECUTE ON dbo.PsREQJOB_11 TO GOMEGA
go

