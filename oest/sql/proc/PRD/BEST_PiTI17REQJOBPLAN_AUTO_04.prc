USE BEST
go

IF OBJECT_ID('dbo.PiTI17REQJOBPLAN_AUTO_04') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiTI17REQJOBPLAN_AUTO_04
   PRINT '<<< DROPPED PROC dbo.PiTI17REQJOBPLAN_AUTO_04 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiTI17REQJOBPLAN_AUTO_04
(
       @p_cre_d             UUPD_D
)
   
as 

/***************************************************

Programme               : PiTI17REQJOBPLAN_AUTO_04

Fichier script associé  : BEST_PiTI17REQJOBPLAN_AUTO_04
Domaine                 : (ES) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  :  M.NAJI
Date de creation        :  02/12/2022
Description du programme:

      Insertion automatique d'enregistrement dans TI17REQJOBPLAN 

Parametres:
   
Conditions d'execution:
Commentaires:

Test:
BEST..PiTI17REQJOBPLAN_AUTO_04

_________________
MODIFICATION 2

[01] 02/12/2022 M.NAJI   :SPIRA 88053  création automatique request dans TI17REQJOBPLA
*****************************************************/
declare @erreur      int

SET NOCOUNT ON 

select  @erreur   = 0 


CREATE TABLE #TI17REQJOBPLAN_LOG
(
    SSD_CF       USSD_CF       NOT NULL,
    BALSHEYEA_NF smallint      NOT NULL,
    BALSHTMTH_NF tinyint       NOT NULL,
    CLODAT_D     datetime      NOT NULL,
    REQCOD_CT    varchar(32)   NOT NULL,
    CRE_D        UUPD_D        NOT NULL,
    DBCLO_D      UUPD_D        NULL,
    LAUNCH_D     UUPD_D        NULL,
    CLOTYP_CT    char(5)       NULL,
    NORME_CF     char(5)       NULL,
    CLOPER_LS    UL64          NULL,
    VRS_NF       numeric(10,0) NULL,
    UPDUSR_CF    UUSR_CF       NULL,
    START_D      UUPD_D        NULL,
    END_D        UUPD_D        NULL,
    SITE_CF      char(4)       NOT NULL,
    ID_NF        int      	   NULL     ,
    CMT_NT       UCMT_NT       NULL,
    num        	 int  IDENTITY
)



select  
	  SSD_CF
    , BALSHEYEA_NF
    , BALSHTMTH_NF
    , CLODAT_D
    , REQCOD_CT
    --, CRE_D
    , DBCLO_D
    --, LAUNCH_D
    , CLOTYP_CT
    , NORME_CF
    --, VRS_NF
    --, UPDUSR_CF
    --, START_D
    --, END_D
     , SITE_CF
    --, CMT_NT 
   , CLOPER_LS 
 into #TI17REQJOBPLAN3
from  BEST..TI17REQJOBPLAN  
where 1=2

declare  curs_normes cursor for
select  
      BALSHEYEA_NF
    , BALSHTMTH_NF
    , CLODAT_D
    , DBCLO_D
    , NORME_CF
	, START_D
	, END_D
 from  BEST..TI17REQJOBPLAN
 WHERE REQCOD_CT ="AUTO"
 
 



declare 
	  @BALSHEYEA_NF int 
	, @BALSHTMTH_NF int 
	, @DBCLO_D date
	, @CLODAT_D  date 
	, @NORME_CF  varchar(5)
	, @START_D date
	, @END_D date
	
OPEN curs_normes

fetch curs_normes into 	
      @BALSHEYEA_NF
    , @BALSHTMTH_NF
    , @CLODAT_D
    , @DBCLO_D
    , @NORME_CF
	, @START_D
	, @END_D
					 
While (@@sqlstatus = 0)
BEGIN


	delete #TI17REQJOBPLAN3
	exec BEST..PiTI17REQJOBPLAN_AUTO_01 	   @p_cre_d     ,        @START_D  ,        @END_D    , 	   @NORME_CF ,@BALSHEYEA_NF, @BALSHTMTH_NF,@CLODAT_D
	exec BEST..PiTI17REQJOBPLAN_AUTO_02
	exec BEST..PiTI17REQJOBPLAN_AUTO_03			@p_cre_d     ,        @START_D  ,        @END_D

    --select * from  #TI17REQJOBPLAN3
	fetch curs_normes into 	
		  @BALSHEYEA_NF
		, @BALSHTMTH_NF
		, @CLODAT_D
		, @DBCLO_D
		, @NORME_CF
		, @START_D
		, @END_D
			
        
END


CLOSE curs_normes 

deallocate cursor curs_normes

-- récupérer que les demandes supprimées et modifiées
select "MAIL",
	L.SSD_CF       ,
    L.BALSHEYEA_NF ,
    L.BALSHTMTH_NF ,
    convert(varchar(10),L.CLODAT_D  ,111) ,
    L.REQCOD_CT  + " (" + R.REC_CF + ")"  ,
    convert(varchar(10),L.CRE_D     ,111) ,
    convert(varchar(10),L.DBCLO_D   ,111) ,
    convert(varchar(20),L.LAUNCH_D  ,23) ,
    L.CLOTYP_CT    ,
    L.NORME_CF     ,
    L.CLOPER_LS    ,
    L.VRS_NF       ,
    L.UPDUSR_CF    ,
    convert(varchar(20),L.START_D  ,23)  ,
    convert(varchar(20),L.END_D    ,23)  ,
    L.SITE_CF      ,
    L.ID_NF        ,
    L.CMT_NT         
from #TI17REQJOBPLAN_LOG L
LEFT OUTER JOIN BEST..TI17REQ R on L.REQCOD_CT = R.REQCOD_CT
where  UPDUSR_CF in ("INF2","INF1")
UNION 
select "LOG",
	L.SSD_CF       ,
    L.BALSHEYEA_NF ,
    L.BALSHTMTH_NF ,
    convert(varchar(10),L.CLODAT_D  ,111) ,
    L.REQCOD_CT   ,
    convert(varchar(10),L.CRE_D     ,111) ,
    convert(varchar(10),L.DBCLO_D   ,111) ,
    convert(varchar(20),L.LAUNCH_D  ,23) ,
    L.CLOTYP_CT    ,
    L.NORME_CF     ,
    L.CLOPER_LS    ,
    L.VRS_NF       ,
    L.UPDUSR_CF    ,
    convert(varchar(20),L.START_D  ,23)  ,
    convert(varchar(20),L.END_D    ,23)  ,
    L.SITE_CF      ,
    L.ID_NF        ,
    L.CMT_NT         
from #TI17REQJOBPLAN_LOG L
order by 1,8

drop table #TI17REQJOBPLAN_LOG

return @erreur
go


IF OBJECT_ID('dbo.PiTI17REQJOBPLAN_AUTO_04') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiTI17REQJOBPLAN_AUTO_04 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiTI17REQJOBPLAN_AUTO_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiREQJOB_01
 */
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_04 TO PUBLIC
go
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_04 TO GDBBATCH
go
