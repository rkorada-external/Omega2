USE BSEG
go
IF OBJECT_ID('dbo.PsTRARAT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTRARAT_01
    IF OBJECT_ID('dbo.PsTRARAT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTRARAT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTRARAT_01 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure dbo.PsTRARAT_01
(
    @p_norm_cf		char(5),
    @p_clodat_d		datetime,
    @p_per_cf		char(10)
)
as

/***************************************************

Procedure: PsTRARAT_01

Domaine : ESTIMATIONS - Risk Adjusment Ratios

Base principale : BSAR

Version: 1

Auteur: JYP - PERSEE

Date de creation: 09/07/2019
_______________
MODIFICATIONS
[001] 13/08/2019 JYP : SPIRA 70377 : extract SGTVER_NT 
[002] 19/08/2019 JYP : SPIRA 70377 : bugfix SGT_NT 
[003] 18/09/2019 JYP : SPIRA 70377 : bugfix SGTVER_NT
[004] 25/09/2019 JYP : SPIRA 70377 : remove space in NORME_CF
*****************************************************/

declare @erreur int



BEGIN


SELECT   a.SSD_CF, a.ESB_CF, a.SEG_NF, ltrim(rtrim(a.NORME_CF)), a.CTRNAT_CT, a.DOMAIN_CF, a.PRMRAT_R,  a.RSRVRAT_R  ,b.SGMT_LS,b.SGTVER_NT, a.RALIC_R, a.RALRC_R
FROM	 BEST..TRARAT  a, BEST..TSEGMT b
WHERE	 NORME_CF = @p_norm_cf
AND    convert(date, CLODAT_D) = @p_clodat_d
AND    PER_CF   = @p_per_cf
AND    SSD_CF <> NULL
AND    a.SEG_NF   = b.SGMT_NF 
AND  ( 
          ( a.DOMAIN_CF in ('Gross','RetroP')  
            AND b.SGT_NT  = 101 
            AND b.SGTVER_NT  in (select SGTVER_NT from BSEG..TSEGRUN where SGTRUN_NT = (select max(SGTRUN_NT) FROM BSEG..TSEGRUN  WHERE SGT_NT=101 and SGTRUNSTS_CT='5' and SGTEVAL_B=1 and SGTSIMU_B=0 )) 
          )
           OR
          ( a.DOMAIN_CF in ('RetroNP')  
            AND b.SGT_NT  = 131  
            AND b.SGTVER_NT in (select SGTVER_NT from BSEG..TSEGRUN where SGTRUN_NT = (select max(SGTRUN_NT) FROM BSEG..TSEGRUN  WHERE SGT_NT=131 and SGTRUNSTS_CT='5' and SGTEVAL_B=1 and SGTSIMU_B=0 )) 
           )
        ) 
  
END

select @erreur = @@error
if @erreur != 0
   return @erreur
   
return 0
go

IF OBJECT_ID('dbo.PsTRARAT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTRARAT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTRARAT_01 >>>'
go
GRANT EXECUTE ON dbo.PsTRARAT_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTRARAT_01 TO GDBBATCH
go
