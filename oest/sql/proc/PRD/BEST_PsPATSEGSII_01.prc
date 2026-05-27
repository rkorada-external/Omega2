use BEST
go
CREATE TABLE #TCUR_PATSEGSII
(
CLODAT_D      datetime    NULL,
PER_CF        char(5)     NULL,
SSD_CF        USSD_CF     NULL,
SEG_NF        USEG_NF     NULL,
LOB_CF        char(2)     NULL,
RATING_CF     char(5)     NULL,
CUR_CF        UCUR_CF     NULL,
NORME_CF      char(5)     NULL,
SEGNAT_CT     char(1)     DEFAULT '' NULL,
PATCAT_CT     char(5)     NOT NULL,
PATTYP_CT     char(5)     NOT NULL,
PATTERN_ID    varchar(21) NOT NULL,
ORIPATCAT_CT  char(5)     NULL,
ORIPATTYP_CT  char(5)     NULL,
ORIPATTERN_ID varchar(21) NULL,
CREUSR_CF     UUPDUSR_CF  NOT NULL,
CRE_D         datetime    NOT NULL
)
go
if object_id('dbo.PsPATSEGSII_01') is not null
begin
  drop PROC dbo.PsPATSEGSII_01
  print '<<< DROPPED PROC dbo.PsPATSEGSII_01 >>>'
end
go
create procedure PsPATSEGSII_01
  (
  @p_SSD_CF    USSD_CF
 ,@p_CLODAT_D  datetime
 ,@p_PER_CF    char(5)
 ,@p_PATCAT_CT char(5)
 ,@p_SEG_NF    USEG_NF=null
 ,@p_LOB_CF    char(2)=null
 ,@p_CUR_CF    UCUR_CF=null
 ,@p_NORME_CF  char(5)=null
 ,@p_RATING_CF char(5)=null
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 11/07/2012
Description du programme: :spot:23390 (SOLVENCY)
Conditions d'execution: fenêtre de recherche w_recherche_es_sii_patseg
Commentaires:
_________________
MODIFICATIONS
*****************************************************/
insert #TCUR_PATSEGSII
select
  CLODAT_D
 ,PER_CF
 ,SSD_CF
 ,SEG_NF
 ,LOB_CF
 ,RATING_CF=null
 ,CUR_CF
 ,NORME_CF
 ,SEGNAT_CT
 ,PATCAT_CT
 ,PATTYP_CT
 ,PATTERN_ID
 ,ORIPATCAT_CT
 ,ORIPATTYP_CT
 ,ORIPATTERN_ID
 ,CREUSR_CF
 ,CRE_D
 from TPATSEGSII
  where (CLODAT_D=@p_CLODAT_D or @p_CLODAT_D=null)
    and (PER_CF=@p_PER_CF or @p_PER_CF in(null,''))
    and PATCAT_CT=@p_PATCAT_CT
    and (SSD_CF=@p_SSD_CF or @p_SSD_CF=null)
    and (SEG_NF like '%'+@p_SEG_NF+'%' or @p_SEG_NF in(null,''))
    and (LOB_CF=@p_LOB_CF or @p_LOB_CF in(null,''))
    and (CUR_CF=@p_CUR_CF or @p_CUR_CF in(null,''))
    and (NORME_CF=@p_NORME_CF or @p_NORME_CF in(null,''))
go
if object_id('dbo.PsPATSEGSII_01') is not null
  print '<<< CREATED PROC dbo.PsPATSEGSII_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsPATSEGSII_01 >>>'
go
grant execute on dbo.PsPATSEGSII_01 TO GOMEGA
go
