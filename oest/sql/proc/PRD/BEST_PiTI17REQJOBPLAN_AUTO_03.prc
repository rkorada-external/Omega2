USE BEST
go

IF OBJECT_ID('dbo.PiTI17REQJOBPLAN_AUTO_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiTI17REQJOBPLAN_AUTO_03
   PRINT '<<< DROPPED PROC dbo.PiTI17REQJOBPLAN_AUTO_03 >>>'
END
go

/*
 * creation de la procedure  
*/
create procedure PiTI17REQJOBPLAN_AUTO_03
(
	@p_cre_d             UUPD_D ,
	@p_start_d           UUPD_D,
	@p_end_d             UUPD_D
)   
as

/***************************************************

Programme               : PiTI17REQJOBPLAN_AUTO_03

Fichier script associé  : BEST_PiTI17REQJOBPLAN_AUTO_03
Domaine                 : (ES) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  :  M.NAJI
Date de creation        :  02/12/2022
Description du programme:

      Insertion automatique d'enregistrement dans TI17REQJOBPLAN : check AOC

Parametres:
   
Conditions d'execution:
Commentaires:

Test:
BEST..PiTI17REQJOBPLAN_AUTO_03

_________________
MODIFICATION 2

[01] 02/12/2022 M.NAJI   :SPIRA 88053  création automatique request dans TI17REQJOBPLA : check AOC
*****************************************************/
declare @erreur      int

SET NOCOUNT ON 

select  @erreur   = 0 



declare  curs_ti17reqjobplan cursor for
select 
	  BALSHEYEA_NF 
	, BALSHTMTH_NF 
	, CLOTYP_CT 	
	, DBCLO_D 	
	, CLODAT_D 	
	, REQCOD_CT 	
	, NORME_CF  	
	, CLOPER_LS 
    , SITE_CF
	, SSD_CF 		
    , VRS_NF   
    , UPDUSR_CF
    , ID_NF
from  BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('POSO','INVO') 
and   DBCLO_D between @p_start_d  and @p_end_d 
and   DBCLO_D >= @p_cre_d 




OPEN curs_ti17reqjobplan

declare 
	 @SSD_CF       USSD_CF       	
    ,@BALSHEYEA_NF smallint      	
    ,@BALSHTMTH_NF tinyint       	
    ,@CLODAT_D     datetime      	
    ,@REQCOD_CT    varchar(32)   	
    ,@DBCLO_D      UUPD_D        	
    ,@CLOTYP_CT    char(5)       	
    ,@NORME_CF     char(5)       	
    ,@CLOPER_LS    UL64          	
    ,@SITE_CF      char(4)       	
    ,@VRS_NF       numeric(10,0) 	
    ,@ID_NF        int           
    ,@UPDUSR_CF    UUSR_CF   
	,@aSSD_CF       USSD_CF       	
    ,@aBALSHEYEA_NF smallint      	
    ,@aBALSHTMTH_NF tinyint       	
    ,@aCLODAT_D     datetime      	
    ,@aREQCOD_CT    varchar(32)   	
    ,@aDBCLO_D      UUPD_D        	
    ,@aCLOTYP_CT    char(5)       	
    ,@aNORME_CF     char(5)       	
    ,@aCLOPER_LS    UL64          	
    ,@aVRS_NF       numeric(10,0) 	
    ,@aSITE_CF      char(4)       	
    , @aUPDUSR_CF    UUSR_CF   
    , @aID_NF        int           


fetch curs_ti17reqjobplan into 		
	  @aBALSHEYEA_NF  
	, @aBALSHTMTH_NF 
	, @aCLOTYP_CT 	
	, @aDBCLO_D 		
	, @aCLODAT_D 	
	, @aREQCOD_CT 	  
	, @aNORME_CF  	
	, @aCLOPER_LS 	
    , @aSITE_CF
	, @aSSD_CF 		
    , @aVRS_NF        
    , @aUPDUSR_CF
    , @aID_NF

				 
While (@@sqlstatus = 0)
BEGIN

    select @ID_NF = NULL
	select 
	     @BALSHEYEA_NF =BALSHEYEA_NF   
        ,@BALSHTMTH_NF =BALSHTMTH_NF
        ,@CLODAT_D     =CLODAT_D
        ,@REQCOD_CT    =REQCOD_CT
        ,@DBCLO_D      = DBCLO_D
        ,@CLOTYP_CT    =CLOTYP_CT
        ,@NORME_CF     =NORME_CF
        ,@CLOPER_LS    =CLOPER_LS 
        ,@SITE_CF      =SITE_CF
		,@SSD_CF	   =SSD_CF
        ,@VRS_NF   	   = VRS_NF
        ,@UPDUSR_CF = UPDUSR_CF
        ,@ID_NF   	   = ID_NF
	from BEST..TI17REQJOBPLAN  
	where DBCLO_D = @aDBCLO_D 
	and SITE_CF =@aSITE_CF 
	and REQCOD_CT like "I17G%" 
        
		
	
	-- on trouve un I17G avec le même DBCLO_D que l'AOC
	if ( @ID_NF != NULL   )
    BEGIN
		-- le AOC n'a pas des infos cohérentes avec le I17G
        if (			
            @aBALSHEYEA_NF	!= @BALSHEYEA_NF OR
            @aBALSHTMTH_NF	!= @BALSHTMTH_NF OR
            @aCLOTYP_CT 	!= @CLOTYP_CT 	 OR
            @aCLODAT_D 		!= @CLODAT_D 	 OR
            @aREQCOD_CT 	!= @REQCOD_CT 	 OR
            @aNORME_CF  	!= @NORME_CF  	 OR
            @aCLOPER_LS 	!= @CLOPER_LS 	 OR
            @aVRS_NF      	!= @ID_NF        
            )        
        BEGIN 
         
			--- Correction de la ligne AOC
            UPDATE BEST..TI17REQJOBPLAN
            SET	  
                     BALSHEYEA_NF 	= @BALSHEYEA_NF
                    , BALSHTMTH_NF 	= @BALSHTMTH_NF
                    , CLODAT_D     	= @CLODAT_D
                    , REQCOD_CT    	= RTRIM(@CLOTYP_CT)+'O'
                    , CLOTYP_CT    	= @CLOTYP_CT
                    , UPDUSR_CF		= "INF1"
                    , VRS_NF		=   @ID_NF
            where ID_NF = @aID_NF
					 
			-- log ligne AOC après correction 
            insert into #TI17REQJOBPLAN_LOG(
					 SSD_CF       
					,BALSHEYEA_NF 
					,BALSHTMTH_NF 
					,CLODAT_D     
					,REQCOD_CT    
					,CRE_D        
					,DBCLO_D      
					,LAUNCH_D     
					,CLOTYP_CT    
					,NORME_CF     
					,CLOPER_LS    
					,VRS_NF       
					,UPDUSR_CF    
					,START_D      
					,END_D        
					,SITE_CF      
					,ID_NF        
					,CMT_NT       
					)	
			select 
				 SSD_CF       
				,BALSHEYEA_NF 
				,BALSHTMTH_NF 
				,CLODAT_D     
				,REQCOD_CT    
				,CRE_D        
				,DBCLO_D      
				,LAUNCH_D     
				,CLOTYP_CT    
				,NORME_CF     
				,CLOPER_LS    
				,VRS_NF       
				,UPDUSR_CF    
				,START_D      
				,END_D        
				,SITE_CF      
				,ID_NF        
				,CMT_NT       
			from BEST..TI17REQJOBPLAN             
			where ID_NF = @aID_NF
        END
	END
    -- on ne trouve pas de I17G avec avec le même DBCLO_D de AOC , on le supprime le l'AOC
	ELSE
    BEGIN
		-- on log l'AOC avec le user "INF2"
		insert into #TI17REQJOBPLAN_LOG(
			 SSD_CF       
			,BALSHEYEA_NF 
			,BALSHTMTH_NF 
			,CLODAT_D     
			,REQCOD_CT    
			,CRE_D        
			,DBCLO_D      
			,LAUNCH_D     
			,CLOTYP_CT    
			,NORME_CF     
			,CLOPER_LS    
			,VRS_NF       
			,UPDUSR_CF    
			,START_D      
			,END_D        
			,SITE_CF      
			,ID_NF        
			,CMT_NT       
			)	
		select 
			 SSD_CF       
			,BALSHEYEA_NF 
			,BALSHTMTH_NF 
			,CLODAT_D     
			,REQCOD_CT    
			,CRE_D        
			,DBCLO_D      
			,LAUNCH_D     
			,CLOTYP_CT    
			,NORME_CF     
			,CLOPER_LS    
			,VRS_NF       
			,"INF2"    
			,START_D      
			,END_D        
			,SITE_CF      
			,ID_NF        
			,CMT_NT       
		from BEST..TI17REQJOBPLAN             
		where ID_NF = @aID_NF
		-- on supprimme l'AOC
		DELETE BEST..TI17REQJOBPLAN
		where ID_NF = @aID_NF
    END 
              
    fetch curs_ti17reqjobplan into 		
	  @aBALSHEYEA_NF 
	, @aBALSHTMTH_NF 
	, @aCLOTYP_CT 	
	, @aDBCLO_D 	
	, @aCLODAT_D 	
	, @aREQCOD_CT 	  
	, @aNORME_CF  	
	, @aCLOPER_LS 	
    , @aSITE_CF	
    , @aSSD_CF 		
    , @aVRS_NF  
    , @aUPDUSR_CF
   ,  @aID_NF

END 

CLOSE curs_ti17reqjobplan


deallocate cursor curs_ti17reqjobplan

return @erreur
go


IF OBJECT_ID('dbo.PiTI17REQJOBPLAN_AUTO_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiTI17REQJOBPLAN_AUTO_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiTI17REQJOBPLAN_AUTO_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiREQJOB_01
 */
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_03 TO PUBLIC
go
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_03 TO GDBBATCH
go
