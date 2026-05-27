use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PSSEGANO_30
*/
IF OBJECT_ID('dbo.PSSEGANO_30') IS NOT NULL
   BEGIN
   DROP PROC dbo.PSSEGANO_30
   PRINT '<<< DROPPED PROC dbo.PSSEGANO_30 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PSSEGANO_30
     (
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric,
       @p_lag_cf              ULAG_CF
     )
as

/***************************************************

Programme: PSSEGANO_30

Fichier script associé : ESSSEG30.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TSEGANO

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
       			seg_nf    char(10)      NULL,
				seg_ll    UL64          NULL,
                         ano_ct    tinyint       NULL,
        			ano_lm    UL32          NULL,
                         uwy_nf    smallint      NULL,
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
 Select TSEGANO
-----------------------------------------*/
 
 Insert into #liste
 Select seg_nf,
        NULL,
        ano_ct,
        NULL,
        uwy_nf,
        @ssd_ls, 
        @segtyp_ls,
        @p_vrs_nf,
        @vrs_lm 
   from TSEGANO
  where segtyp_ct    = @p_segtyp_ct
    and ssd_cf       = @p_ssd_cf
    and vrs_nf       = @p_vrs_nf
   
    
 select @erreur = @@error
 if @erreur != 0 begin raiserror 20001 "APPLICATIF;TSEGANO --> #liste" goto fin end

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
order by seg_nf, seg_ll, ano_lm

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

exec sp_SCOR_INSPRC 'ESSSEG30', 'PSSEGANO_30', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PSSEGANO_30') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PSSEGANO_30 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PSSEGANO_30 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PSSEGANO_30
 */
GRANT EXECUTE ON dbo.PSSEGANO_30 TO GOMEGA
go

