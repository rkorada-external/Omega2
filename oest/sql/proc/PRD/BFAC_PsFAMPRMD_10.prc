use BFAC
go
IF OBJECT_ID('dbo.PsFAMPRMD_10') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFAMPRMD_10
    IF OBJECT_ID('dbo.PsFAMPRMD_10') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFAMPRMD_10 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFAMPRMD_10 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure dbo.PsFAMPRMD_10
     (
    @p_BLCSHTYEA_NF smallint,
    @p_BLCSHTMTH_NF tinyint
)
as
/***************************************************
Domaine :                 (ES) Estimation
Base principale :         BFAC
Version:                  1
Auteur:                   R. Cassis
Date de creation:         16/02/2021
Description du programme: SPIRA : 92356 Extraction des écritures avec date < Date End_cedante pour l'auto-booking des facs
-----------------------------------------------------
[01] JJ/MM/AAAA Name SPIRA : xxxxx  Comment
*****************************************************/

Select  f.CTR_NF
       ,f.END_NT
       ,f.SEC_NF
       ,f.UWY_NF
       ,f.UW_NT
       ,f2.EGPCUR_CF
       ,sum(convert(decimal(18,3),round(f.PRMDUE_M*i.EXC_R/o.EXC_R,3)))
from BFAC..TFAMPRMD f
    ,BFAC..TFAMLIA f2
    ,BREF..TCALEND c
    ,BREF..TBATCHSSD x
    ,BREF..TCURQUOT i
    ,BREF..TCURQUOT o
where c.BLCSHTYEA_NF = @p_BLCSHTYEA_NF
  and c.BLCSHTMTH_NF = @p_BLCSHTMTH_NF
  and f.PRMDUE_D    <= c.END_D
  and f.SSD_CF       = x.SSD_CF
  and x.BATCHUSER_CF = suser_name()
  and f.CTR_NF = f2.CTR_NF
  and f.UWY_NF = f2.UWY_NF
  and f.UW_NT  = f2.UW_NT
  and f.END_NT = f2.END_NT
  and f.SEC_NF = f2.SEC_NF
  and i.SSD_CF   = 2
  and i.CUR_CF   = f.PRMDUECUR_CF
  and o.SSD_CF   = 2
  and o.CUR_CF   = f2.EGPCUR_CF
  and i.EXC_D = (select max(EXC_D) from BREF..TCURQUOT
                 where SSD_CF   = 2
                   and CUR_CF = 'EUR'
                   and ACTCOD_B = 1)
  and o.EXC_D = (select max(EXC_D) from BREF..TCURQUOT
                 where SSD_CF   = 2
                   and CUR_CF = 'EUR'
                   and ACTCOD_B = 1)
group by f.CTR_NF,f.END_NT,f.SEC_NF,f.UWY_NF,f.UW_NT,f2.EGPCUR_CF
having sum(convert(decimal(18,3),f.PRMDUE_M*i.EXC_R/o.EXC_R)) != 0
order by f.CTR_NF,f.END_NT,f.SEC_NF,f.UWY_NF,f.UW_NT,f2.EGPCUR_CF

if @@error != 0
begin
   raiserror 20005 "APPLICATIF;TFAMPRMD" /* erreur de modification */
   return -100
end

return 0
go
IF OBJECT_ID('dbo.PsFAMPRMD_10') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsFAMPRMD_10 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFAMPRMD_10 >>>'
go
GRANT EXECUTE ON dbo.PsFAMPRMD_10 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFAMPRMD_10 TO GDBBATCH
go