USE BEST
Go

 /* DROP PROC dbo.PsCTRGRO_30
*/
IF OBJECT_ID('dbo.PsCTRGRO_30') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCTRGRO_30
   PRINT '<<< DROPPED PROC dbo.PsCTRGRO_30 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsCTRGRO_30
     (
       @p_seg_nf              USEG_NF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric,
       @p_lag_cf              ULAG_CF
     )
as

/***************************************************

Programme: PsCTRGRO_30

Fichier script associé : ESSCTR30.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation:

Description du programme:

      Sélection d'enregistrement dans TCTRGRO
      (liste des contrats-sections par segment)

Parametres:
       @p_seg_nf              USEG_NF NULL: Segment
       @p_segtyp_ct           USEGTYP_CT, : Type segment
       @p_ssd_cf              USSD_CF,    : Filiale
       @p_vrs_nf              numeric,    : Version
       @p_lag_cf              ULAG_CF     : Langue

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: ap

Date: 24/07/97

Version:

Description: modification du comptage du nombre d'affaire par segment : utilisation d'une table temporaire

_________________
MODIFICATION 2
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
_________________
MODIFICATION    [003]
Auteur:         D.GATIBELZA
Date:           27/05/2008
Version:        8.1
Description:    EDI15180
*****************************************************/

declare @erreur int
declare @ssd_ls    UL16,
        @segtyp_ls UL16,
        @vrs_lm    UL32


/*---------------------------------------
Création de la table temporaire #liste
---------------------------------------*/
create table #liste (
				seg_nf       char(10)      NULL,
				seg_ll       UL64          NULL,
				ctrret_b     bit           default 0,
				ctr_sec_tot  int      NULL,
				ctr_nf       UCTR_NF       NULL,
				end_nt       UEND_NT       NULL,
				div_nt       UDIV_NT       NULL,
				sec_nf       USEC_NF       NULL,
				grp_ls       UL16          NULL,
				ced_ls       UL16          NULL,
				lob_hs       UL16          NULL,
				top_hs       UL16          NULL,
				sob_hs       UL16          NULL,
				ctrnatmne_hd char(4)       NULL,
				ctrsnamne_ld char(4)       NULL,
				ctysup_ls    UL16          NULL,
				seccan_d     char(8)       NULL,
				uwgrp_cf     UGRP_CF       NULL,
				ced_nf       UCLI_NF       NULL,
				lob_cf       ULOB_CF       NULL,
				sob_cf       USOB_CF       NULL,
				top_cf       UTOP_CF       NULL,
				nat_cf       UCTRNAT_CF    NULL,
				subnat_cf    UCTRSUBNAT_CF NULL,
				pcprsktry_cf UCTY_CF       NULL,
				ssd_ls       UL16          NULL,
        			segtyp_ls    UL16          NULL,
        			vrs_nf       numeric(10,0) NULL,
        			vrs_lm       UL32          NULL
			)

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
 Select TCTRGRO
-----------------------------------------*/
if @p_seg_nf = "TOUS"

    begin
	/*-------------------------
	On prend tous les segments
	-------------------------*/

	/* comptage du nombre d'affaire par segment */
	Select		seg_nf,
			count(*) cpt
	into #tcounta
	from TCTRGRO
	where 	segtyp_ct = @p_segtyp_ct
		and ssd_cf = @p_ssd_cf
		and vrs_nf = @p_vrs_nf
	group by seg_nf
  order by seg_nf


      Insert into #liste
 	Select  a.seg_nf,
              NULL,
              ctrret_b,
              cpt,
              ctr_nf,
              end_nt,
              div_nt,
              sec_nf,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              convert(char(8),seccan_d,112) seccan_d,
              uwgrp_cf,
              ced_nf,
              lob_cf,
              sob_cf,
              top_cf,
              nat_cf,
              subnat_cf,
              pcprsktry_cf,
	        @ssd_ls,
	        @segtyp_ls,
	        @p_vrs_nf,
	        @vrs_lm
	   from TCTRGRO a, #tcounta b
	  where segtyp_ct = @p_segtyp_ct
	    and ssd_cf = @p_ssd_cf
	    and vrs_nf= @p_vrs_nf
	    and a.seg_nf = b.seg_nf

	drop table #tcounta

    end
    else
    begin
	/*-------------------------
      On prend que sur un segment
      --------------------------*/

	/* comptage du nombre d'affaire par segment */
	Select		seg_nf,
			count(*) cpt
	into #tt
	from TCTRGRO
	where 	segtyp_ct = @p_segtyp_ct
		and ssd_cf = @p_ssd_cf
		and vrs_nf = @p_vrs_nf
		and seg_nf = @p_seg_nf
	group by seg_nf
  order by seg_nf


	Insert into #liste
 	Select  a.seg_nf,
              NULL,
              ctrret_b,
              cpt,
              ctr_nf,
              end_nt,
              div_nt,
              sec_nf,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              convert(char(8),seccan_d,112) seccan_d,
              uwgrp_cf,
              ced_nf,
              lob_cf,
              sob_cf,
              top_cf,
              nat_cf,
              subnat_cf,
              pcprsktry_cf,
	        @ssd_ls,
	        @segtyp_ls,
	        @p_vrs_nf,
	        @vrs_lm
	   from TCTRGRO a, #tt b
	  where segtyp_ct    = @p_segtyp_ct
	    and ssd_cf       = @p_ssd_cf
	    and vrs_nf       = @p_vrs_nf
          and a.seg_nf     = @p_seg_nf
	    and a.seg_nf 	  = b.seg_nf

	drop table #tt

    end

 select @erreur = @@error
 if @erreur != 0 begin raiserror 20001 "APPLICATIF;TCTRGRO --> #liste" goto fin end


/*----------------------------------------------
 Recherche du libellé segment (seg_ll)
 Update de TSEGMENT -> #liste
-----------------------------------------------*/
update #liste
   set a.seg_ll   = b.seg_ll
  from #liste a, TSEGMENT b
 where b.vrs_nf    = a.vrs_nf
   and b.seg_nf    = a.seg_nf
   and b.segtyp_ct = @p_segtyp_ct
   and b.ssd_cf    = @p_ssd_cf


select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;TSEGMENT->#liste;' goto fin end

/*----------------------------------------------
 Recherche du Dpt souscripteur (grp_ls)
 Update de BREF..TGRP -> #liste
-----------------------------------------------*/
update #liste
   set a.grp_ls   = b.grp_ls
  from #liste a, BREF..TGRP b
 where b.grp_cf    = a.uwgrp_cf
   and b.ssd_cf    = @p_ssd_cf


select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BREF..TGRP->#liste;' goto fin end

/*----------------------------------------------
 Recherche de la cédante (ced_ls)
 Update de BCLI..TCLIENT -> #liste
-----------------------------------------------*/
update #liste
   set a.ced_ls   = b.clishonam_ld
  from #liste a, BCLI..TCLIENT b
 where b.cli_nf    = a.ced_nf

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BCLI..TCLIENT->#liste;' goto fin end


/*----------------------------------------------
 Recherche de la LOB (lob_hs)
 Update de BREF..TLOBH -> #liste
-----------------------------------------------*/
update #liste
   set a.lob_hs   = b.lob_hs
  from #liste a, BREF..TLOBH b
 where b.lob_cf    = a.lob_cf
   and b.ssd_cf    = @p_ssd_cf


select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BREF..TLOBH->#liste;' goto fin end


/*----------------------------------------------
 Recherche de la TOP (top_hs)
 Update de BREF..TTOPH -> #liste
-----------------------------------------------*/
update #liste
   set a.top_hs   = b.top_hs
  from #liste a, BREF..TTOPH b
 where b.top_cf    = a.top_cf
   and b.ssd_cf    = @p_ssd_cf


select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BREF..TTOPH->#liste;' goto fin end


/*----------------------------------------------
 Recherche de la SOB (sob_hs)
 Update de BREF..TSOBH -> #liste
-----------------------------------------------*/
update #liste
   set a.sob_hs   = b.sob_hs
  from #liste a, BREF..TSOBH b
 where b.sob_cf    = a.sob_cf
   and b.ssd_cf    = @p_ssd_cf


select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BREF..TSOBH->#liste;' goto fin end

/*--------------------------------------------------
 Recherche du mnémonique de la nature (ctrnatmne_hd)
 Update de BREF..TCTRNATH -> #liste
----------------------------------------------------*/
update #liste
   set a.ctrnatmne_hd   = b.ctrnatmne_hd
  from #liste a, BREF..TCTRNATH b
 where b.ctrnat_cf    = a.nat_cf
   and b.ssd_cf       = @p_ssd_cf


select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BREF..TCTRNATH->#liste;' goto fin end

/*--------------------------------------------------
 Recherche du mnémonique de la sous-nature (ctrsnamne_ld)
 Update de BREF..TCTRSNL -> #liste
----------------------------------------------------*/
update #liste
   set a.ctrsnamne_ld   = b.ctrsnamne_ld
  from #liste a, BREF..TCTRSNL b
 where b.ctrsubnat_cf    = a.subnat_cf
   and b.lag_cf          = @p_lag_cf

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BREF..TCTRSNL->#liste;' goto fin end

/*--------------------------------------------------
 Recherche de la territorialité (ctysup_ls)
 Update de BREF..TCTYSUPL -> #liste
----------------------------------------------------*/
update #liste
   set a.ctysup_ls   = b.ctysup_ls
  from #liste a, BREF..TCTYSUPL b
 where b.ctysup_cf    = a.pcprsktry_cf
   and b.lag_cf       = @p_lag_cf

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BREF..TCTYSUPL->#liste;' goto fin end

/*-----------------
 Select final
-----------------*/
select *  from #liste
order by seg_nf, ctr_nf, end_nt, div_nt, sec_nf, uwgrp_cf

select @erreur = @@error
if @erreur != 0 begin raiserror 20005 '20005 APPLICATIF;#liste;' goto fin end

/* --------------------------------
Suppression des tables temporaires
----------------------------------*/
fin:
drop table #liste


return @erreur
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCTR21', 'PsCTRGRO_30', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsCTRGRO_30') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCTRGRO_30 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCTRGRO_30 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCTRGRO_30
 */
GRANT EXECUTE ON dbo.PsCTRGRO_30 TO GOMEGA
go

