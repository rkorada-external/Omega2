USE BEST
go

IF OBJECT_ID('dbo.PiTI17REQJOBPLAN_AUTO_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiTI17REQJOBPLAN_AUTO_02
   PRINT '<<< DROPPED PROC dbo.PiTI17REQJOBPLAN_AUTO_02 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiTI17REQJOBPLAN_AUTO_02
   
as

/***************************************************

Programme               : PiTI17REQJOBPLAN_AUTO_02

Fichier script associé  : BEST_PiTI17REQJOBPLAN_AUTO_02
Domaine                 : (ES) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  :  M.NAJI
Date de creation        :  02/12/2022
Description du programme:

      Insertion automatique d'enregistrement dans TI17REQJOBPLAN 

Parametres:
       @p_cre_d             UUPD_D,
       @p_start_d             UUPD_D,
       @p_end_d               UUPD_D,
	   @p_NORME_CF  		varchar(5)

Conditions d'execution:
Commentaires:

Test:
BEST..PiTI17REQJOBPLAN_AUTO_02

_________________
MODIFICATION 2

[01] 02/12/2022 M.NAJI   :SPIRA 88053  création automatique request dans TI17REQJOBPLAN
[01] 12/04/2023 M.NAJI   :SPIRA 88053  fix POSX
[02] 02/10/2023 M.NAJI   :SPIRA 110595  I17P/I17L Pos booking request on extended period
*****************************************************/
declare @erreur      int

SET NOCOUNT ON 

select  @erreur   = 0 


declare  curs_ti17reqjobplan3 cursor for
select  distinct 
	  SSD_CF
    , BALSHEYEA_NF
    , BALSHTMTH_NF
    , CLODAT_D
    , REQCOD_CT
    , DBCLO_D
    , CLOTYP_CT
    , NORME_CF
    , CLOPER_LS 
    , SITE_CF
 from  #TI17REQJOBPLAN3
 order by DBCLO_D



declare 
	  @BALSHEYEA_NF int 
	, @BALSHTMTH_NF int 
	, @CLOTYP_CT varchar(10) 
	, @DBCLO_D date
	, @CLODAT_D  date 
	, @REQCOD_CT varchar(10)   
    , @SITE_CF varchar(5)
	, @NORME_CF  varchar(5)
	, @CLOPER_LS varchar(64)
	, @SSD_CF Tinyint 
	, @ID_NF  int
    , @CRE_D datetime
	, @VRS_NF int
	
declare 
	  @oBALSHEYEA_NF int 
	, @oBALSHTMTH_NF int 
	, @oCLOTYP_CT 	varchar(10) 
	, @oDBCLO_D 		date
	, @oCLODAT_D 	date 
	, @oREQCOD_CT 	varchar(10)   
    , @oSITE_CF 		varchar(5)
	, @oNORME_CF  		varchar(5)
	, @oCLOPER_LS 		varchar(64)
	, @oSSD_CF 		Tinyint 
    , @oID_NF         int 

OPEN curs_ti17reqjobplan3

fetch curs_ti17reqjobplan3 into 	
	 @SSD_CF
    ,@BALSHEYEA_NF
    ,@BALSHTMTH_NF
    ,@CLODAT_D
    ,@REQCOD_CT
    ,@DBCLO_D
    ,@CLOTYP_CT
    ,@NORME_CF
    ,@CLOPER_LS 
    ,@SITE_CF


--select @CRE_D=  max(@CRE_D) 

select @CRE_D=  getdate()
					 
While (@@sqlstatus = 0)
BEGIN

	if ( @NORME_CF = "EBSE"  )
		select @VRS_NF = 1 
	ELSE
		select @VRS_NF = 0
		
	select @oREQCOD_CT = NULL
	select 
	     @oBALSHEYEA_NF =BALSHEYEA_NF
        ,@oBALSHTMTH_NF =BALSHTMTH_NF
        ,@oCLODAT_D     =CLODAT_D
        ,@oREQCOD_CT    =REQCOD_CT
        ,@oDBCLO_D      =DBCLO_D
        ,@oCLOTYP_CT    =CLOTYP_CT
        ,@oNORME_CF     =NORME_CF
        ,@oCLOPER_LS    =CLOPER_LS 
        ,@oSITE_CF      =SITE_CF
        ,@oID_NF   		= ID_NF
	from BEST..TI17REQJOBPLAN  
	WHERE DBCLO_D = @DBCLO_D and NORME_CF=@NORME_CF  and SITE_CF = @SITE_CF and REQCOD_CT  not like '%O'
    
	
     
    --insert into  #TI17REQJOBPLAN_LOG(SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOTYP_CT,NORME_CF,CLOPER_LS,VRS_NF,UPDUSR_CF,START_D,END_D,SITE_CF,ID_NF,CMT_NT)
    --select SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOTYP_CT,NORME_CF,CLOPER_LS,VRS_NF,UPDUSR_CF,START_D,END_D,SITE_CF,ID_NF,CMT_NT
    --from BEST..TI17REQJOBPLAN  
	--WHERE DBCLO_D = @DBCLO_D and NORME_CF=@NORME_CF  and SITE_CF = @SITE_CF
    
    if  @oREQCOD_CT = NULL AND @REQCOD_CT != "CLEAN"
    BEGIN
        INSERT INTO BEST..TI17REQJOBPLAN(SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D, DBCLO_D, CLOTYP_CT, NORME_CF, CLOPER_LS,    SITE_CF ,UPDUSR_CF ,VRS_NF ) 
				VALUES ( @SSD_CF, @BALSHEYEA_NF, @BALSHTMTH_NF, @CLODAT_D, @REQCOD_CT, getdate(), @DBCLO_D, @CLOTYP_CT, @NORME_CF, @CLOPER_LS, @SITE_CF,"INF0" ,@VRS_NF)
    
        insert into  #TI17REQJOBPLAN_LOG(SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOTYP_CT,NORME_CF,CLOPER_LS,VRS_NF,UPDUSR_CF,START_D,END_D,SITE_CF,ID_NF,CMT_NT)
        select SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOTYP_CT,NORME_CF,CLOPER_LS,VRS_NF,UPDUSR_CF,START_D,END_D,SITE_CF,ID_NF,CMT_NT
        from BEST..TI17REQJOBPLAN  
        WHERE DBCLO_D = @DBCLO_D and NORME_CF=@NORME_CF  and SITE_CF = @SITE_CF
    END
    ELSE
         if (@REQCOD_CT != "CLEAN") 
			-- si on trouve un posting cohérent on le laisse 
			if  @oREQCOD_CT  != @REQCOD_CT +"P"  or  @oBALSHEYEA_NF   != @BALSHEYEA_NF or @oBALSHTMTH_NF   != @BALSHTMTH_NF  or @oCLODAT_D   != @CLODAT_D
				if  (   @oBALSHEYEA_NF   != @BALSHEYEA_NF
						or @oBALSHTMTH_NF   != @BALSHTMTH_NF
						or @oCLODAT_D       != @CLODAT_D
						or @oREQCOD_CT      != @REQCOD_CT 
						or @oCLOTYP_CT      != @CLOTYP_CT 
						or @oCLOPER_LS      != @CLOPER_LS 
					) AND  @oCLOTYP_CT  not in  ("POC","POSX")
					
				BEGIN
					
					UPDATE BEST..TI17REQJOBPLAN
					SET	  BALSHEYEA_NF = @BALSHEYEA_NF
						, BALSHTMTH_NF = @BALSHTMTH_NF
						, CLODAT_D     = @CLODAT_D
						, REQCOD_CT    = @REQCOD_CT
						, CLOTYP_CT    = @CLOTYP_CT
						, CLOPER_LS    = @CLOPER_LS 
						, CRE_D		   = getdate()
						,UPDUSR_CF="INF1"
					where ID_NF = @oID_NF
					
					insert into  #TI17REQJOBPLAN_LOG(SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOTYP_CT,NORME_CF,CLOPER_LS,VRS_NF,UPDUSR_CF,START_D,END_D,SITE_CF,ID_NF,CMT_NT)
					select SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOTYP_CT,NORME_CF,CLOPER_LS,VRS_NF,UPDUSR_CF,START_D,END_D,SITE_CF,ID_NF,CMT_NT
					from BEST..TI17REQJOBPLAN  
					WHERE ID_NF = @oID_NF
				END 
		--else 
        --    delete from BEST..TI17REQJOBPLAN  WHERE DBCLO_D = @DBCLO_D and NORME_CF = @NORME_CF and	SITE_CF = @SITE_CF 

            
    fetch curs_ti17reqjobplan3 into 	
         @SSD_CF
        ,@BALSHEYEA_NF
        ,@BALSHTMTH_NF
        ,@CLODAT_D
        ,@REQCOD_CT
        ,@DBCLO_D
        ,@CLOTYP_CT
        ,@NORME_CF
        ,@CLOPER_LS 
        ,@SITE_CF
	
    select @CRE_D=  dateadd(ms,  1, @CRE_D) 
        
END

 

CLOSE curs_ti17reqjobplan3 

deallocate cursor curs_ti17reqjobplan3

 
 
return @erreur
go


IF OBJECT_ID('dbo.PiTI17REQJOBPLAN_AUTO_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiTI17REQJOBPLAN_AUTO_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiTI17REQJOBPLAN_AUTO_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiREQJOB_01
 */
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_02 TO PUBLIC
go
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_02 TO GDBBATCH
go
