USE BEST
go
IF OBJECT_ID('dbo.PsFPATTERNSII_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFPATTERNSII_02
    IF OBJECT_ID('dbo.PsFPATTERNSII_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFPATTERNSII_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFPATTERNSII_02 >>>'
END
go
create procedure dbo.PsFPATTERNSII_02
(
   @p_CRE_D      datetime,
   @p_PATCAT_CT  char(5),   -- DSC / CSF / BDT / INF
   @p_BALSHEY_NF smallInt,
   @p_per_cf     char(3),
   @p_clodat_d   datetime
)
as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Auteur                  : Roger Cassis
Date de creation        : 11/07/2012
Description du programme: :spot:23802 G�n�ration du fichier FPATTERNSII (SOLVENCY) pour les differents types de pattern
Conditions d'execution  : chaine ESID0060
Commentaires            :

 BEST..PsFPATTERNSII_02 '20251031', 'BDT', 2025, 'POS', '20251231'
_________________
MODIFICATIONS
1 27/07/2012 R. Cassis  :spot:24041 Solvency - gestion nulls - puis �volution par Philippe
2 12/08/2013 Florent    :spot:25427 Centralisation des bases (filiales)
3 13/11/2014 C. DESPRET :spot:26391 Patterns ICR traitees comme les CSF
4 16/06/2015 Florent    :spot:28941 gestion Inflated
5 09/05/2016 Florent    :spot:30543 on passe � 65 ann�es
6 18/06/2020 KBagwe	    :spira:62221 EBS - Quarterly Pattern
7 07/08/2025 M.NAJI 	:US5850 SERQS 
8 02/10/2025 M.NAJI 	:US6929 SERQS 
9 01/11/2025 M.NAJI 	:US7359 SERQS - Impact estimation IFRS17 – Closing
*****************************************************/
-- pour les CUM et ICV on a une ligne de ICR, CSF dans les traces pour n lignes correspondantes dans les courbes de taux, donc distinct

   select distinct
          SSD_CF=isnull(convert(char(2),a.SSD_CF),'')
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
         ,case when a.PATCAT_CT in ('CSF', 'ICR') then a.SEG_NF+isnull(convert(char(4),a.UWY_NF),'')
                   when a.PATCAT_CT='BDT' then isnull(a.RATING_CF,'')+isnull(a.NORME_CF,'')
          end col1 
         ,case when a.PATCAT_CT in ('CSF', 'ICR') then a.LOB_CF+isnull(convert(char(4),a.UWY_NF),'') end col2
          into  #FSEGPATTERN
         from BEST..TPATTERNSII a, BEST..TPATSEGSII c--, BREF..TBATCHSSD x
          where  ( 		( @p_PATCAT_CT = 'DSC'  and 
							a.NORME_CF in ('GIM','IFRSI','SII','EV')      and 
							(   	(   a.BALSHEY_NF=@p_BALSHEY_NF and 
										a.PATCAT_CT in('CSF','ICR')
									) 
								or a.PATCAT_CT not in('CSF','ICR')
							) 
						)
						or (@p_PATCAT_CT != 'DSC' and a.PATCAT_CT  = @p_PATCAT_CT )
                   )
                and a.PATTERN_ID = c.PATTERN_ID
                and a.PATCAT_CT  = c.PATCAT_CT
                and a.PATTYP_CT  = c.PATTYP_CT
                and c.CLODAT_D   = @p_clodat_d
                and c.PER_CF     = @p_per_cf
                --and (c.SSD_CF=null  -- or (c.SSD_CF=x.SSD_CF and x.BATCHUSER_CF=suser_name()))
                and isnull(c.ORIPATTYP_CT,'')!='ILL'
                and isnull(c.SSD_CF,0)=isnull(a.SSD_CF,0)
                and ((c.PATCAT_CT='BDT' and isnull(c.SEG_NF,'')=isnull(a.RATING_CF,'')) or (c.PATCAT_CT!='BDT' and isnull(c.SEG_NF,'')=isnull(a.SEG_NF,'')))
                and isnull(c.LOB_CF,'')=isnull(a.LOB_CF,'')
                and isnull(c.CUR_CF,'')=isnull(a.CUR_CF,'')
                and isnull(c.NORME_CF,'')=isnull(a.NORME_CF,'')
                and isnull(c.SEGNAT_CT,'')=isnull(a.SEGNAT_CT,'')
                
               
select distinct ssd_cf
into #SSD 
 from  BEST..TI17CLOPER
where PARM6 ='1'
if @p_PATCAT_CT  not in ( "ICR", "CSF")
    select * 
    from #FSEGPATTERN 
    
if @p_PATCAT_CT  =  "CSF"
    select * 
    from #FSEGPATTERN 
    UNION 
    select 
            SSD_CF=isnull(convert(char(2),s.SSD_CF),'')
            ,   a.PATCAT_CT
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
             ,AN61,AN62,AN63,AN64,AN65,
        col1,
        col2
    from #FSEGPATTERN a
    JOIN #SSD s on  1 = 1
    WHERE convert(int,a.SSD_CF) <> s.SSD_CF  
    and a.PATTYP_CT in ("CLRET","PRRET")
 

if @p_PATCAT_CT  =  "ICR"
    select * 
    from #FSEGPATTERN 
    UNION 
    select 
            SSD_CF=isnull(convert(char(2),s.SSD_CF),'')
            ,   a.PATCAT_CT
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
             ,AN61,AN62,AN63,AN64,AN65,
        col1,
        col2
	from #FSEGPATTERN a
    JOIN #SSD s on  1 = 1
    WHERE convert(int,a.SSD_CF)<> s.SSD_CF  
    and a.PATTYP_CT in ("CLRET","PRRET")
 
go
IF OBJECT_ID('dbo.PsFPATTERNSII_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsFPATTERNSII_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFPATTERNSII_02 >>>'
go
GRANT EXECUTE ON dbo.PsFPATTERNSII_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFPATTERNSII_02 TO GDBBATCH
go
