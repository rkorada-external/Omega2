use BEST
go
IF OBJECT_ID('dbo.PsFPATTERNFWH_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFPATTERNFWH_01
    IF OBJECT_ID('dbo.PsFPATTERNFWH_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFPATTERNFWH_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFPATTERNFWH_01 >>>'
END
go

create procedure dbo.PsFPATTERNFWH_01
(
   @p_CRE_D      datetime,
   @p_PATCAT_CT  char(5),   -- CSF
   @p_BALSHEY_NF smallInt,
   @p_per_cf     char(3),
   @p_clodat_d   datetime
)
as

/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BTRT
Auteur                  : Quentin Desmettre
Date de creation        : 17/09/2018
Description du programme: Creation of the list of contract with signed fund held
Conditions d'execution  : chaine ESID0060
Commentaires            :
_________________
MODIFICATIONS
*****************************************************/

SELECT SSD_CF=isnull(convert(char(2),a.SSD_CF),'')
 ,a.PATCAT_CT
 ,a.PATTYP_CT
 ,SEG_NF=isnull(a.SEG_NF,'')
 ,UWY_NF=isnull(convert(char(4),a.UWY_NF),'')
 ,CUR_CF=isnull(a.CUR_CF,'')
 ,LOB_CF=isnull(a.LOB_CF,'')
 ,RATING_CF=isnull(a.RATING_CF,'')
 ,NORME_CF=isnull(a.NORME_CF,'')
 ,SEGNAT_CT=isnull(a.SEGNAT_CT,'')
 ,BALSHEY_NF=isnull(convert(char(4),a.BALSHEY_NF),'')
 ,a.PATTERN_ID
 ,CRE_D=convert(char(8),a.CRE_D,112)+' '+ convert(char(8),a.CRE_D,8)+ substring(convert(char(27),a.CRE_D,109),21,4)
 ,a.CREUSR_CF
 ,TOTAUX
 ,AN1,AN2,AN3,AN4,AN5,AN6,AN7,AN8,AN9,AN10,AN11,AN12,AN13,AN14,AN15,AN16,AN17,AN18,AN19,AN20
 ,AN21,AN22,AN23,AN24,AN25,AN26,AN27,AN28,AN29,AN30,AN31,AN32,AN33,AN34,AN35,AN36,AN37,AN38,AN39,AN40
 ,AN41,AN42,AN43,AN44,AN45,AN46,AN47,AN48,AN49,AN50,AN51,AN52,AN53,AN54,AN55,AN56,AN57,AN58,AN59,AN60
 ,AN61,AN62,AN63,AN64,AN65
 ,@p_PATCAT_CT
 ,@p_PATCAT_CT
 ,c.RATEINDEX_CT

FROM BEST..TPATTERNSII a, BEST..TPATSEGSII c
WHERE a.PATCAT_CT = @p_PATCAT_CT
  --  and a.BALSHEY_NF=@p_BALSHEY_NF		--070819 BALSHEY_NF is not required
    and a.PATTERN_ID = c.PATTERN_ID
    and a.PATCAT_CT  = c.PATCAT_CT
    and a.PATTYP_CT  = c.PATTYP_CT
    and a.PATTYP_CT  = 'FHNI'
    and c.CLODAT_D   = @p_clodat_d
    and c.PER_CF     = @p_per_cf
    and ( isnull(c.SSD_CF,0)=0 or (c.SSD_CF in (select ssd_cf from BREF..TBATCHSSD x where x.BATCHUSER_CF=suser_name())))
    and isnull(c.ORIPATTYP_CT,'')!='ILL'
    and isnull(c.SSD_CF,0)=isnull(a.SSD_CF,0)
    and ((c.PATCAT_CT='BDT' and isnull(c.SEG_NF,'')=isnull(a.RATING_CF,'')) or (c.PATCAT_CT!='BDT' and isnull(c.SEG_NF,'')=isnull(a.SEG_NF,'')))
    and isnull(c.LOB_CF,'')=isnull(a.LOB_CF,'')
    and isnull(c.CUR_CF,'')=isnull(a.CUR_CF,'')
    and isnull(c.NORME_CF,'')=isnull(a.NORME_CF,'')
    and isnull(c.SEGNAT_CT,'')=isnull(a.SEGNAT_CT,'')
ORDER BY c.RATEINDEX_CT, c.CUR_CF

go

if object_id('dbo.PsFPATTERNFWH_01') is not null
  print '<<< CREATED PROC dbo.PsFPATTERNFWH_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsFPATTERNFWH_01 >>>'
go
grant execute on dbo.PsFPATTERNFWH_01 TO GOMEGA
go
grant execute on dbo.PsFPATTERNFWH_01 TO GDBBATCH
go
