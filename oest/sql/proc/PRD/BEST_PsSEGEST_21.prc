use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PsSEGEST_21
*/
IF OBJECT_ID('dbo.PsSEGEST_21') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSEGEST_21
   PRINT '<<< DROPPED PROC dbo.PsSEGEST_21 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSEGEST_21
     (
       @p_seg_nf              USEG_NF,
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric,
       @p_lag_cf              ULAG_CF
     )
as

/***************************************************

Programme: PsSEGEST_21

Fichier script associé : ESSSEG21.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TSEGEST

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

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int
declare @ssd_ls    UL16,
        @segtyp_ls UL16,
        @vrs_lm    UL32


/*---------------------------------------
Création de la table temporaire #liste
---------------------------------------*/
create table #liste (
       			seg_nf    char(10)      NULL,
				seg_ll    UL64          NULL,
				cur_cf    UCUR_CF       NULL,
             		uwy_nf    smallint      NULL,
              		clmamt_m  UAMT_M        NULL,
              		prmamt_m  UAMT_M        NULL,
              		losrat_r  USHORAT_R     NULL,
        			ssd_ls    UL16          NULL,
        			segtyp_ls UL16          NULL,
        			vrs_nf    numeric(10,0) NULL,
        			vrs_lm    UL32          NULL,
                         flag1     int           NULL,
                         flag2     int           NULL
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
 Select TSEGEST
-----------------------------------------*/
 if @p_seg_nf = "TOUS" 
    
    begin
	/*-------------------------
	On prend tous les segments
	-------------------------*/
      Insert into #liste
 	Select seg_nf,
		  NULL,
		  cur_cf,
        	  uwy_nf,
	        clmamt_m,
	        prmamt_m,
	        losrat_r, /* en % */
	        @ssd_ls, 
	        @segtyp_ls,
	        @p_vrs_nf,
	        @vrs_lm,
              0,
              0
	   from TSEGEST
	  where segtyp_ct    = @p_segtyp_ct
	    and ssd_cf       = @p_ssd_cf
	    and vrs_nf       = @p_vrs_nf

    end 
    else
    begin
	/*-------------------------
      On prend que sur un segment
      --------------------------*/
 	Insert into #liste
 	Select seg_nf,
		  NULL,
		  cur_cf,
        	  uwy_nf,
	        clmamt_m,
	        prmamt_m,
	        losrat_r, /* en % */
	        @ssd_ls, 
	        @segtyp_ls,
	        @p_vrs_nf,
	        @vrs_lm,
              0,
              0
	   from TSEGEST
	  where segtyp_ct    = @p_segtyp_ct
	    and ssd_cf       = @p_ssd_cf
	    and vrs_nf       = @p_vrs_nf
	    and seg_nf       = @p_seg_nf

    end 
    
 select @erreur = @@error
 if @erreur != 0 begin raiserror 20001 "APPLICATIF;TSEGEST --> #liste" goto fin end

/*----------------------------------
 Update de TSEGMENT -> #liste 
-----------------------------------*/
update #liste
   set a.seg_ll   = b.seg_ll
  from #liste a, TSEGMENT b
 where b.vrs_nf    = a.vrs_nf
   and b.seg_nf    = a.seg_nf
   and b.segtyp_ct = @p_segtyp_ct
   and b.ssd_cf    = @p_ssd_cf
 
   
select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;TSEGMENT->#liste;' goto fin end

/*----------------------------------
 Update du Flag
-----------------------------------*/
update #liste
   set flag1   = 1
  from #liste
 where clmamt_m = NULL
 
select @erreur = @@error
if @erreur != 0 begin raiserror 20005 '20005 APPLICATIF;Flag;' goto fin end

update #liste
   set flag2   = 1
  from #liste
 where prmamt_m = NULL
   
select @erreur = @@error
if @erreur != 0 begin raiserror 20006 '20006 APPLICATIF;Flag;' goto fin end

/*-----------------
 Select final
-----------------*/
select seg_nf,
	 seg_ll,
	 cur_cf,
       uwy_nf,
       clmamt_m,
       prmamt_m,
       losrat_r*100 losrat_r, /* en % */ 
       ssd_ls,
       segtyp_ls,
       vrs_nf,
       vrs_lm,
       flag1,
       flag2
  from #liste 
  order by seg_nf, uwy_nf


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

exec sp_SCOR_INSPRC 'ESSSEG21', 'PsSEGEST_21', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsSEGEST_21') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSEGEST_21 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSEGEST_21 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSEGEST_21
 */
GRANT EXECUTE ON dbo.PsSEGEST_21 TO GOMEGA
go

