USE BEST
Go

 /* DROP PROC dbo.PsSEGMENT_11
*/
IF OBJECT_ID('dbo.PsSEGMENT_11') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSEGMENT_11
   PRINT '<<< DROPPED PROC dbo.PsSEGMENT_11 >>>'
END
go

/*
 * creation de la procedure */
create procedure PsSEGMENT_11
     (
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric,
       @p_lag_cf              ULAG_CF
     )
as

/***************************************************

Programme: PsSEGMENT_11

Fichier script associé : ESSSEG11.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Sélection d'enregistrement dans TSEGMENT

Parametres:
       @p_segtyp_ct           USEGTYP_CT, : Type segment
       @p_ssd_cf              USSD_CF,    : Filiale
       @p_vrs_nf              numeric,    : Version
       @p_lag_cf              ULAG_CF     : Langue

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

declare @erreur int
declare @ssd_ls    UL16,
        @segtyp_ls UL16,
        @vrs_lm    UL32

/*-------------------------------------------------------
 Recherche des libellés filiale, type de segment, version
-------------------------------------------------------*/
select @ssd_ls = ssd_ls
  from BREF..TSUBSID
 where ssd_cf = @p_ssd_cf

select @segtyp_ls = colval_ls
  from BREF..TBANTECL
 where lag_cf    = @p_lag_cf
   and col_ls    = "segtyp_ct"
   and colval_ct = @p_segtyp_ct
   and (codvalssd_cf= @p_ssd_cf OR codvalssd_cf is null)

select @vrs_lm = vrs_lm
  from BEST..TVERSION
 where  segtyp_ct  = @p_segtyp_ct
   and  ssd_cf     = @p_ssd_cf
   and  vrs_nf     = @p_vrs_nf

/*-----------------------------------------
 Select TSEGMENT/TCTRGRO
-----------------------------------------*/

 Select a.seg_nf,
        a.seg_ll,
	  count(b.ctr_nf) nb_ctr,
        a.cur_cf,
        a.ctrret_b,
        a.segnat_ct,
        a.ano_b,
        @ssd_ls,
        @segtyp_ls,
        @p_vrs_nf,
        @vrs_lm
   from TSEGMENT a, TCTRGRO b
  where a.seg_nf      *= b.seg_nf
    and a.segtyp_ct    = @p_segtyp_ct
    and a.ssd_cf       = @p_ssd_cf
    and a.vrs_nf       = @p_vrs_nf
    and b.segtyp_ct    = @p_segtyp_ct
    and b.ssd_cf       = @p_ssd_cf
    and b.vrs_nf       = @p_vrs_nf
 group by a.segtyp_ct, a.ssd_cf, a.vrs_nf, a.seg_nf
 order by a.segtyp_ct, a.ssd_cf, a.vrs_nf, a.seg_nf

 select @erreur = @@error
 if @erreur != 0 begin raiserror 20005 "APPLICATIF;TSEGMENT/TCTRGRO" goto fin end


fin:
return @erreur
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEG11', 'PsSEGMENT_11', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsSEGMENT_11') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSEGMENT_11 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSEGMENT_11 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSEGMENT_11
 */
GRANT EXECUTE ON dbo.PsSEGMENT_11 TO GOMEGA
go

