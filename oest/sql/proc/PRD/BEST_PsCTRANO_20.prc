use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PsCTRANO_20
*/
IF OBJECT_ID('dbo.PsCTRANO_20') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCTRANO_20
   PRINT '<<< DROPPED PROC dbo.PsCTRANO_20 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCTRANO_20
     (
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric,
       @p_lag_cf              ULAG_CF
     )
as

/***************************************************

Programme: PsCTRANO_20

Fichier script associé : ESSCTR20.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TCTRANO

Parametres: 
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
				ctr_nf    UCTR_NF       NULL,
        			end_nt    UEND_NT       NULL,
        			div_nt    UDIV_NT       NULL,
        			sec_nf    USEC_NF       NULL,
        			seg_nf    char(10)      NULL,
                         ano_ct    tinyint       NULL,
        			ano_lm    UL32          NULL,
        			ssd_ls    UL16          NULL,
        			segtyp_ls UL16          NULL,
        			vrs_nf    numeric(10,0) NULL,
        			vrs_lm    UL32          NULL
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
 Select TCTRANO
-----------------------------------------*/
 
 Insert into #liste
 Select ctr_nf,
        end_nt,
        NULL, /*div_nt,*/
        sec_nf,
        seg_nf,
        ano_ct,
        NULL,
        @ssd_ls, 
        @segtyp_ls,
        @p_vrs_nf,
        @vrs_lm 
   from TCTRANO
  where segtyp_ct    = @p_segtyp_ct
    and ssd_cf       = @p_ssd_cf
    and vrs_nf       = @p_vrs_nf
    
    
 select @erreur = @@error
 if @erreur != 0 begin raiserror 20001 "APPLICATIF;TCTRANO --> #liste" goto fin end

/*----------------------------------
 Update de TCTRGRO->#liste 
-----------------------------------*/
update #liste
   set a.div_nt   = b.div_nt
  from #liste a, TCTRGRO b
 where b.ctr_nf    = a.ctr_nf 
   and b.end_nt    = a.end_nt 
   and b.sec_nf    = a.sec_nf
   and b.vrs_nf    = a.vrs_nf
   and b.segtyp_ct = @p_segtyp_ct
   and b.ssd_cf    = @p_ssd_cf

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;TCTRGRO->#liste;' goto fin end

/*----------------------------------
 Update de BREF..TBANTECL --> #liste 
-----------------------------------*/
update #liste
   set a.ano_lm   = b.colval_lm
  from #liste a, BREF..TBANTECL b
 where b.lag_cf    = @p_lag_cf 
   and b.col_ls    = "ano_ct" 
   and b.colval_ct = convert(char(5),a.ano_ct)
   and (b.codvalssd_cf= @p_ssd_cf OR codvalssd_cf is null)

select @erreur = @@error
if @erreur != 0 begin raiserror 20004 '20004 APPLICATIF;BREF..TBANTECL->#liste;' goto fin end


/*-----------------
 Select final
-----------------*/
select * from #liste 
order by ctr_nf, end_nt, div_nt, sec_nf, seg_nf

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

exec sp_SCOR_INSPRC 'ESSCTR20', 'PsCTRANO_20', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsCTRANO_20') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCTRANO_20 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCTRANO_20 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCTRANO_20
 */
GRANT EXECUTE ON dbo.PsCTRANO_20 TO GOMEGA
go

