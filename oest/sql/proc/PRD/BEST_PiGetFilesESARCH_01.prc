USE BEST
go

IF OBJECT_ID('PiGetFilesESARCH_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PiGetFilesESARCH_01
    IF OBJECT_ID('PiGetFilesESARCH_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PiGetFilesESARCH_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PiGetFilesESARCH_01 >>>'
END
go

create procedure PiGetFilesESARCH_01
(
    @p_idf_ct varchar(30),
    @p_parm_reqcod_ct varchar(30)
)
as
/***************************************************
Domaine : (INF) Infrastructure
Base principale : BEST
Auteur: G.GRUDZINSKI
Date de creation: 16/04/2026
Description du programme: Get archive file paths for IDF_CT and PARAM_REQCOD_CT
Conditions d'execution: 
Commentaires: Extracted from ESARCH21.cmd, called by ESARCH21.cmd
_________________
MODIFICATIONS

*****************************************************/

declare @erreur int

SELECT  
CASE
    WHEN NQUATER_NT = 0 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_D'+char(125))
    WHEN NQUATER_NT = 1 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_1_D'+char(125))
    WHEN NQUATER_NT = 2 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_2_D'+char(125))
    WHEN NQUATER_NT = 3 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_3_D'+char(125))
    WHEN NQUATER_NT = 4 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_4_D'+char(125))
    WHEN NQUATER_NT = 5 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_5_D'+char(125))
    WHEN NQUATER_NT = 6 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_6_D'+char(125))
    WHEN NQUATER_NT = 7 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_7_D'+char(125))
    WHEN NQUATER_NT = 8 THEN     str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'PARM_ICLODAT_8_D'+char(125))
    ELSE str_replace(PATHPATTRN_LL,char(123)+'PARM_ICLODAT_D'+char(125),char(123)+'NOT_USED'+char(125))
END
FROM BEST.dbo.TI17PERMRUL2
WHERE IDF_CT = @p_idf_ct
and substring(@p_parm_reqcod_ct, 6, 4) = TRIGGER_CT

/* ------------------------------------------------------------------- */

if object_id('PiGetFilesESARCH_01') is not null
	print '<<< CREATED PROC PiGetFilesESARCH_01 >>>'
else
	print '<<< FAILED CREATING PROC PiGetFilesESARCH_01 >>>'
go

grant execute on PiGetFilesESARCH_01 TO GOMEGA
go

grant execute on PiGetFilesESARCH_01 TO GDBBATCH
go
