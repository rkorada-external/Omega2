USE BEST
go

IF OBJECT_ID('dbo.PiTI17REQJOBPLAN_AUTO_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiTI17REQJOBPLAN_AUTO_01
   PRINT '<<< DROPPED PROC dbo.PiTI17REQJOBPLAN_AUTO_01 >>>' 
END
go

/*
 * creation de la procedure
*/

create procedure PiTI17REQJOBPLAN_AUTO_01
     (
       @p_cre_d             UUPD_D,
       @p_start_d             UUPD_D,
       @p_end_d               UUPD_D,
	   @p_NORME_CF  		varchar(5),
	   @p_BALSHEYEA_NF       int, 
	   @p_BALSHTMTH_NF		 int,
	   @p_CLODAT_D			UUPD_D
     )
as

/***************************************************

Programme               : PiTI17REQJOBPLAN_AUTO_01

Fichier script associé  : BEST_PiTI17REQJOBPLAN_AUTO_01
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
	   @p_BALSHEYEA_NF       UUPD_D, 
	   @p_BALSHTMTH_NF		 UUPD_D,
	   @p_CLODAT_D			UUPD_D
Conditions d'execution:
Commentaires:

Test:
BEST..PiTI17REQJOBPLAN_AUTO_01
	   @p_cre_d    ='20220808' ,
       @p_start_d  ='20230610',
       @p_end_d    ='20220801' ,
	   @p_NORME_CF ='I17G',
	   @p_BALSHEYEA_NF  =2022,
	   @p_BALSHTMTH_NF=	7,
	   @p_CLODAT_D = "20220930"
_________________
MODIFICATION 2

[01] 02/12/2022 M.NAJI   :SPIRA 88053  création automatique request dans TI17REQJOBPLAN
[02] 02/10/2023 M.NAJI   :SPIRA 110595 I17P/I17L Pos booking request on extended period
[03] 06/11/2023 M.NAJI   :SPIRA 110802 I17P/I17L Pos booking request on extended period - Copy
[04] 17/06/2024 M.NAJI   :SPIRA 111451 correction du clean de la damnande V
*****************************************************/

declare @erreur      int

SET NOCOUNT ON 

declare 
	@FIRST_ACCOUNT_D date ,
	@LAST_ACCOUNT_D date


select @erreur = 0



-- on chercher le premier ACCOUNT_D trimestrielle avant la date paramètre  début @p_start_d 
select @FIRST_ACCOUNT_D=max(ACCOUNT_D) 
from  BREF..TCALEND 
where ACCOUNT_D <=  dateadd(day,  -1, @p_start_d) 
and CLOSING_B = 1
 
-- on chercher le premier ACCOUNT_D après la date paramètre fin @p_end_d 

select @Last_ACCOUNT_D=min(ACCOUNT_D) 
from  BREF..TCALEND 
where ACCOUNT_D >   @p_end_d 

if @Last_ACCOUNT_D = null
    select @Last_ACCOUNT_D=max(ACCOUNT_D)
    from  BREF..TCALEND 
    where ACCOUNT_D <   @p_end_d 
    

if @Last_ACCOUNT_D <= @p_end_d 
    select  @Last_ACCOUNT_D = @p_end_d  
	
--select 	FIRST_ACCOUNT_D=@FIRST_ACCOUNT_D , Last_ACCOUNT_D=@Last_ACCOUNT_D


select  
	  SSD_CF
    , BALSHEYEA_NF
    , BALSHTMTH_NF
    , CLODAT_D
    , REQCOD_CT
    , DBCLO_D
    , CLOTYP_CT
    , NORME_CF
    , SITE_CF
into #TI17REQJOBPLAN 
from  BEST..TI17REQJOBPLAN  
where 1=2


--- déclaration du curseur , dans un script il ne peut pas être déclaré avec autre chose 
declare  curs_calend cursor for
    --select	  BLCSHTYEA_NF , BLCSHTMTH_NF , ACCOUNT_D , CLOTYP_CT='INV',NORME_CF='I4I'
    select	  BLCSHTYEA_NF,BLCSHTMTH_NF,CLOSING_B,ACCOUNT_D, PSTOMGEND_D   , 	EBSPSTOMGEND_D ,		PSTOMGEND17_D ,		SACCOUNT_D 
    from  	BREF..TCALEND
    where 	ACCOUNT_D >=  @FIRST_ACCOUNT_D  
    AND 	ACCOUNT_D <=  @LAST_ACCOUNT_D  
	

declare 
	  @BLCSHTYEA_NF int , @BLCSHTMTH_NF int ,@ACCOUNT_D datetime  , @CLOTYP_CT varchar(10) ,  @PSTOMGEND_D  date , 	@EBSPSTOMGEND_D date, @PSTOMGEND17_D date,	@SACCOUNT_D date
	, @LAST_PSTOMGEND_D  date , 	@LAST_EBSPSTOMGEND_D date, @LAST_PSTOMGEND17_D date
	, @dbclo_d date
	, @CLODAT  date 
	, @REQCOD_CT varchar(10)   
    , @SITE_CF varchar(5)
	, @BOOKING varchar(1)
	, @MQY char(1)
	, @START_INV_EBS date
	, @START_INV_I4I date
	, @START_INV_I17G date
	, @START_INV_I17LP date
	, @NORME_CF  varchar(5)
    , @PARM5_LIMIT  smallint 
    , @PARM5_MAX   smallint
    , @PSTXOMGEND17_LIMIT_D  date 
    , @PSTXOMGEND17_D   date
	, @LAST_PSTXOMGEND17_D date
	, @PSTXOMGEND17_USER_D  date 
	, @OLD_PSTOMGEND17_D date
    , @USER_OLD_PSTOMGEND17_D char(4)
	, @CLOSING_B bit
   
    
select  @PARM5_MAX=max(convert(int,PARM5)) from BEST..TI17CLOPER
select @PARM5_LIMIT = convert(int,REQCOD_LL) from best..TI17REQ where reqcod_ct = 'I17P/L LIMIT'

-- on Traitre qu'un seul site , on fait des copier après
select @SITE_CF = 'FRA1'
OPEN curs_calend

fetch curs_calend into 	@BLCSHTYEA_NF,@BLCSHTMTH_NF,@CLOSING_B, @ACCOUNT_D, @PSTOMGEND_D   , 	@EBSPSTOMGEND_D ,		@PSTOMGEND17_D ,		@SACCOUNT_D 
select @CLODAT  = dateadd(day,-1,dateadd(month,1,convert(varchar,(@BLCSHTYEA_NF*100+(@BLCSHTMTH_NF+2)/3 * 3)*100 +1) ))



--- initialisation des dates des débuts des période INV 
select 
	  @START_INV_I4I = dateadd(day,  1, @PSTOMGEND_D )
	, @START_INV_EBS = dateadd(day,  1, @EBSPSTOMGEND_D )
	, @START_INV_I17G = dateadd(day,  1, @PSTOMGEND17_D )
    , @START_INV_I17LP = dateadd(day, 1, @PSTXOMGEND17_D )
    
					 
While (@@sqlstatus = 0)
BEGIN

	select @OLD_PSTOMGEND17_D= null
	
	
	-- traitement des période POS et Booking  
	select @MQY=  CASE WHEN @BLCSHTMTH_NF in(10,11,12) then 'Y' ELSE 'Q' END
	
	
	if  @CLOSING_B = 1
    BEGIN
	
		--  @PSTXOMGEND17_D = @PSTXOMGEND17_D + @PARM5_MAX
		select @PSTXOMGEND17_D  = dateadd(day,isnull(@PARM5_MAX,0),@PSTOMGEND17_D)
		if 	DATEPART(dw, @PSTXOMGEND17_D) = 6  select @PSTXOMGEND17_D  = dateadd(day,3,@PSTXOMGEND17_D) -- @PSTXOMGEND17_D est un vendredi on le pousse de 3 jour
		if 	DATEPART(dw, @PSTXOMGEND17_D) = 7  select @PSTXOMGEND17_D  = dateadd(day,2,@PSTXOMGEND17_D) -- @PSTXOMGEND17_D est un samedi on le pousse de 2 jour
		if 	DATEPART(dw, @PSTXOMGEND17_D) = 1  select @PSTXOMGEND17_D  = dateadd(day,1,@PSTXOMGEND17_D) -- @PSTXOMGEND17_D est un dimanche on le pousse de 1 jour

		-- s'il  existe un booking manuel avant la limite du POSX on le récupère pour le remètre  
		select @OLD_PSTOMGEND17_D=DBCLO_D , @USER_OLD_PSTOMGEND17_D =UPDUSR_CF
		from BEST..TI17REQJOBPLAN 
		where REQCOD_CT = 'I17P'+@MQY+'POSB' 
		and  DBCLO_D between dateadd(day,1,@PSTXOMGEND17_D)  and  dateadd(day,isnull(@PARM5_LIMIT,0),@PSTOMGEND17_D)
		and UPDUSR_CF not in ("INF0","INF1","INF2")
	
		-- insert requests of acoount booking  day INV quaterly or yearly 
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I4I'+@MQY+'INVB' ,  @ACCOUNT_D,'INV'       ,'I4I'  ,@SITE_CF) 
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'EBSE'+@MQY+'INVB' , @ACCOUNT_D,'INV'      ,'EBSE'  ,@SITE_CF)
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17G'+@MQY+'INVB' , @ACCOUNT_D,'INV'      ,'I17G'  ,@SITE_CF)
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17P'+@MQY+'INVB' , @ACCOUNT_D,'INV'      ,'I17P'  ,@SITE_CF)
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17L'+@MQY+'INVB' , @ACCOUNT_D,'INV'      ,'I17L'  ,@SITE_CF)

			
        -- insert requests of Settlement Accounting  
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'V' 				  , @SACCOUNT_D,NULL      ,NULL  ,@SITE_CF)
																																						
        -- insert requests of account booking  day  POS quaterly or yearly 
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I4I'+@MQY+'POSB' ,  @PSTOMGEND_D,'POS'   ,'I4I'    ,@SITE_CF) 
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'EBSE'+@MQY+'POSB' , @EBSPSTOMGEND_D,'POS' ,'EBSE'  ,@SITE_CF)
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17G'+@MQY+'POSB' , @PSTOMGEND17_D,'POS'  ,'I17G'  ,@SITE_CF) 
        
        -- s'il existe une période étendue on pousse le POS booking de I17P et L au maximum et on le remplacce par un posting 
        if ( isnull(@PARM5_MAX,0) > 0 ) 
        BEGIN
            insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17P'+@MQY+'POSP' , @PSTOMGEND17_D,'POS'  ,'I17P'  ,@SITE_CF) 
            insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17L'+@MQY+'POSP' , @PSTOMGEND17_D,'POS'  ,'I17L'  ,@SITE_CF) 
			if ( @OLD_PSTOMGEND17_D = null ) -- s'il n'existe pas une booking manuel valable 
			BEGIN
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17P'+@MQY+'POSB' , @PSTXOMGEND17_D,'POS'  ,'I17P'  ,@SITE_CF) 
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17L'+@MQY+'POSB' , @PSTXOMGEND17_D,'POS'  ,'I17L'  ,@SITE_CF) 
			END 
			ELSE
				delete BEST..TI17REQJOBPLAN
				where DBCLO_D  between @PSTOMGEND17_D and @OLD_PSTOMGEND17_D
				and REQCOD_CT like 'I17[PL]%'
        END
        ELSE
        BEGIN
            insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17P'+@MQY+'POSB' , @PSTOMGEND17_D,'POS'  ,'I17P'  ,@SITE_CF) 
            insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17L'+@MQY+'POSB' , @PSTOMGEND17_D,'POS'  ,'I17L'  ,@SITE_CF) 
        END

		-- insert POSI requests : @ACCOUNT_D + 1 ====> @PSTOMGEND_D -1
		select @dbclo_d = dateadd(day,  1, @ACCOUNT_D )
		while (@dbclo_d <  @PSTOMGEND_D  )
		BEGIN 
			if 	DATEPART(dw, @dbclo_d)  between 2 and 6 
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I4I'  +@MQY+'POS', @dbclo_d,'POS' ,'I4I'   ,@SITE_CF) 
			select @dbclo_d= dateadd(day,  1, @dbclo_d)  
		END

		-- insert POSE requests : @ACCOUNT_D + 1 ====> @EBSPSTOMGEND_D -1
		select @dbclo_d = dateadd(day,  1, @ACCOUNT_D )
		while (@dbclo_d <= dateadd(day,  -1, @EBSPSTOMGEND_D ))
		BEGIN 
			if 	DATEPART(dw, @dbclo_d)  between 2 and 6 
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'EBSE' +@MQY+'POS', @dbclo_d,'POS' ,'EBSE'  ,@SITE_CF)
			select @dbclo_d= dateadd(day,  1, @dbclo_d)  	 
		END

		-- insert POS 17G/L/P requests : @ACCOUNT_D + 1====> @PSTOMGEND17_D -1 
		select @dbclo_d = dateadd(day,  1, @ACCOUNT_D )
		while (@dbclo_d <@PSTOMGEND17_D)
		BEGIN 
			if 	DATEPART(dw, @dbclo_d)  between 2 and 6 
			BEGIN
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17G' +@MQY+'POS', @dbclo_d,'POS' ,'I17G'  ,@SITE_CF)
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17P' +@MQY+'POS', @dbclo_d,'POS' ,'I17P'  ,@SITE_CF)
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17L' +@MQY+'POS', @dbclo_d,'POS' ,'I17L'  ,@SITE_CF)
			END
			select @dbclo_d= dateadd(day,  1, @dbclo_d)  	 
		END
        
  
		-- insert POSX 17L/P requests : @ACCOUNT_D + 1====> @PSTXOMGEND17_D -1 
		select @dbclo_d = dateadd(day,  1, @PSTOMGEND17_D)  	
		while (@dbclo_d < @PSTXOMGEND17_D)
		BEGIN 
			if 	( DATEPART(dw, @dbclo_d)  between 2 and 6  )  and @dbclo_d not in ( select ACCOUNT_D FROM BREF..TCALEND )
			BEGIN
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17P' +@MQY+'POSX', @dbclo_d,'POS' ,'I17P'  ,@SITE_CF)
				insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17L' +@MQY+'POSX', @dbclo_d,'POS' ,'I17L'  ,@SITE_CF)
			END
			select @dbclo_d= dateadd(day,  1, @dbclo_d)  	 
		END
        
  
		select 	
			@LAST_PSTOMGEND_D   =@PSTOMGEND_D   , 	
			@LAST_EBSPSTOMGEND_D=@EBSPSTOMGEND_D,		
			@LAST_PSTOMGEND17_D =@PSTOMGEND17_D ,
			@LAST_PSTXOMGEND17_D =@PSTXOMGEND17_D 
		
    END
	ELSE
	BEGIN
		-- insert requests of booking account day  INV MONTHLY
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I4IMINVB' , @ACCOUNT_D ,'INV'      ,'I4I' ,@SITE_CF) --, @CLODAT ,  @REQCOD_CT,'POS','I4I','FRA1')
        -- insert requests of Settlement Accounting  
        insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'V' 		  , @SACCOUNT_D,NULL       ,NULL  ,@SITE_CF)
	
		-- clean old requests   [04]
		delete BEST..TI17REQJOBPLAN 
		where DBCLO_D  = @ACCOUNT_D 
		and REQCOD_CT != 'I4IMINVB' 
		and	dbclo_d  >= @p_start_d  
		and dbclo_d  >= @p_CRE_D 
		and dbclo_d  <= @p_end_d
		
		-- clean old requests 
		delete BEST..TI17REQJOBPLAN 
		where DBCLO_D  = @SACCOUNT_D 
		and REQCOD_CT != 'V' 
		and	dbclo_d  >= @p_start_d  
		and dbclo_d  >= @p_CRE_D 
		and dbclo_d  <= @p_end_d
		
		
	END
	
	
	select @MQY=  CASE 	WHEN @BLCSHTMTH_NF in(12) then 'Y' 
						WHEN @BLCSHTMTH_NF in(3,6,9) then 'Q' 
						ELSE 'M' 
				  END
	-------------------------------------------------------------------------------------------------------------------------------------			  
	-- Pour la première itération les variables START_INV_* sont > @ACCOUNT_D , donc on ne rentre dans occune boucle
	-------------------------------------------------------------------------------------------------------------------------------------			  

	-- insert INVI requests  between @START_INV_I4Iand  @ACCOUNT_D -1   
	select @dbclo_d =@START_INV_I4I
	while (@dbclo_d < @ACCOUNT_D )
	BEGIN 
		if 	DATEPART(dw, @dbclo_d)  between 2 and 6 
			insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I4I'  +@MQY+'INV', @dbclo_d,'INV' ,'I4I'   ,@SITE_CF) 
		select @dbclo_d= dateadd(day,  1, @dbclo_d)  
	END
	--- init next I4I INV period
	select 	@START_INV_I4I		= CASE WHEN @PSTOMGEND_D != NULL  THEN    dateadd(day,  1, @PSTOMGEND_D)  ELSE dateadd(day,  1, @ACCOUNT_D)  END
	
	
	-- insert INVE requests between START_INV_EBS and @ACCOUNT_D -1
	select @dbclo_d = @START_INV_EBS
	while ( @dbclo_d < @ACCOUNT_D )
	BEGIN 
		if 	DATEPART(dw, @dbclo_d)  between 2 and 6 
			insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'EBSE' +@MQY+'INV', @dbclo_d,'INV' ,'EBSE'  ,@SITE_CF)
		select @dbclo_d= dateadd(day,  1, @dbclo_d)   	 
	END
	--- init next EBS  INV period
	select @START_INV_EBS		= CASE WHEN @LAST_EBSPSTOMGEND_D  <= @ACCOUNT_D   THEN  dateadd(day,  1, @ACCOUNT_D) ELSE dateadd(day,  1, @LAST_EBSPSTOMGEND_D)END

	-- insert INVI17G requests between START_INV_I17G and @ACCOUNT_D -1
	select @dbclo_d = @START_INV_I17G	
	while (@dbclo_d < @ACCOUNT_D ) 
	BEGIN 
		if 	DATEPART(dw, @dbclo_d)  between 2 and 6 
		BEGIN
			insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17G' +@MQY+'INV', @dbclo_d,'INV' ,'I17G'  ,@SITE_CF)
		END
		select @dbclo_d= dateadd(day,  1, @dbclo_d)  	 
	END
	--- init next I17 INV period
	select @START_INV_I17G 	= CASE WHEN @LAST_PSTOMGEND17_D   <= @ACCOUNT_D   THEN  dateadd(day,  1, @ACCOUNT_D)  ELSE dateadd(day,  1, @LAST_PSTOMGEND17_D )END


	-- insert INVI17 requests between START_INV_I17LP and @ACCOUNT_D -1
	select @dbclo_d = @START_INV_I17LP	
	while (@dbclo_d < @ACCOUNT_D ) 
	BEGIN 
		if 	DATEPART(dw, @dbclo_d)  between 2 and 6 
		BEGIN
			insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17P' +@MQY+'INV', @dbclo_d,'INV' ,'I17P'  ,@SITE_CF)
			insert into #TI17REQJOBPLAN   values (99    , @BLCSHTYEA_NF , @BLCSHTMTH_NF, @CLODAT , 'I17L' +@MQY+'INV', @dbclo_d,'INV' ,'I17L'  ,@SITE_CF)
		END
		select @dbclo_d= dateadd(day,  1, @dbclo_d)  	 
	END
	

	--- init next I17 INV period
	select @START_INV_I17LP 	= CASE 	WHEN @OLD_PSTOMGEND17_D  != null  THEN  dateadd(day,  1, @OLD_PSTOMGEND17_D)   -- cas d'un booking manuel ancien valable
										WHEN @LAST_PSTXOMGEND17_D   <= @ACCOUNT_D   THEN  dateadd(day,  1, @ACCOUNT_D)  
										ELSE dateadd(day,  1, @LAST_PSTXOMGEND17_D )
								  END


	fetch curs_calend into 	@BLCSHTYEA_NF,@BLCSHTMTH_NF, @CLOSING_B,@ACCOUNT_D, @PSTOMGEND_D   , 	@EBSPSTOMGEND_D ,		@PSTOMGEND17_D ,		@SACCOUNT_D 
	
	select @CLODAT  = dateadd(day,-1,dateadd(month,1,convert(varchar,(@BLCSHTYEA_NF*100+(@BLCSHTMTH_NF+2)/3 * 3)*100 +1) ))
	


END

CLOSE curs_calend 




select * into #TI17REQJOBPLAN2  from #TI17REQJOBPLAN  where 1=2

--select * from #TI17REQJOBPLAN  order by  DBCLO_D

-- tranche demandée 
if  @p_NORME_CF in ("I17G","I17P","I17L")
	insert into #TI17REQJOBPLAN2
	select *   from #TI17REQJOBPLAN  
	where 	
	  	dbclo_d  >= @p_start_d  
	and dbclo_d  >= @p_CRE_D 
	and dbclo_d  <= @p_end_d
	and NORME_CF in ( @p_NORME_CF,"EBSE","I4I","I17G",NULL)

if  @p_NORME_CF = "EBSE"
	insert into #TI17REQJOBPLAN2
	select *  from #TI17REQJOBPLAN  
	where 	
	  	dbclo_d  >= @p_start_d  
	and dbclo_d  >= @p_CRE_D 
	and dbclo_d  <= @p_end_d
	and NORME_CF in ( "EBSE","I4I",NULL)

if  @p_NORME_CF = "I4I"
	insert into #TI17REQJOBPLAN2
	select *  from #TI17REQJOBPLAN 
	where 	
	  	dbclo_d  >= @p_start_d  
	and dbclo_d  >= @p_CRE_D 
	and dbclo_d  <= @p_end_d
	and NORME_CF in( "I4I",NULL)


-- insert local requests 
if  @p_NORME_CF = "Y"
BEGIN 
	select @dbclo_d =@p_start_d
	while (@dbclo_d <= @p_end_d )
	BEGIN 
		if 	DATEPART(dw, @dbclo_d)  between 2 and 6 and   @dbclo_d  >= @p_CRE_D 
			insert into #TI17REQJOBPLAN2   values (99    , @p_BALSHEYEA_NF , @p_BALSHTMTH_NF, @p_CLODAT_D , 'Y', @dbclo_d,NULL ,'Y'   ,@SITE_CF) 
		select @dbclo_d= dateadd(day,  1, @dbclo_d)  
	END
	
	-- le jour de l'ACCOUNT_D pas de local 
	
	-- on log les lignes compta qu'on va supprimer  s'il existe pour le local I4I
	INSERT INTO #TI17REQJOBPLAN_LOG ( SSD_CF, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, CRE_D    , DBCLO_D, CLOTYP_CT, NORME_CF, CLOPER_LS,    SITE_CF,UPDUSR_CF , ID_NF  ) 
                              select      99, BALSHEYEA_NF, BALSHTMTH_NF, CLODAT_D, REQCOD_CT, getdate(), DBCLO_D, CLOTYP_CT, NORME_CF, CLOPER_LS, SITE_CF, "INF2",ID_NF
	from BEST..TI17REQJOBPLAN  where DBCLO_D in 
	 (select ACCOUNT_D from BREF..TCALEND where ACCOUNT_D between @p_start_d and @p_end_d )
     and NORME_CF ='Y'
 
	-- on supprime les lignes local pendant la  compta de la table de travail #TI17REQJOBPLAN
	delete #TI17REQJOBPLAN2  where DBCLO_D in 
	 (select ACCOUNT_D from BREF..TCALEND where ACCOUNT_D between @p_start_d and @p_end_d )
    and NORME_CF ='Y'
    
	-- on supprime les lignes local pendant la  compta de la table TI17REQJOBPLAN
	delete BEST..TI17REQJOBPLAN  where DBCLO_D in 
	 (select ACCOUNT_D from BREF..TCALEND where ACCOUNT_D between @p_start_d and @p_end_d )
     and NORME_CF ='Y'
END
--tranche de travail avec toutes les normes 


--  tranche avec la norme demandée +  la propagation éventuelle aux autres normez  
insert   into #TI17REQJOBPLAN3
select i.* , r.REQCOD_LL as CLOPER_LS  
from #TI17REQJOBPLAN2 i
LEFT OUTER JOIN BEST..TI17REQ r on i.REQCOD_CT = r.REQCOD_CT 



insert   into #TI17REQJOBPLAN3
select   
	  i.SSD_CF
    , i.BALSHEYEA_NF
    , i.BALSHTMTH_NF
    , i.CLODAT_D
    , i.REQCOD_CT
    , i.DBCLO_D
    , i.CLOTYP_CT
    , i.NORME_CF
     , "SGP1"
     , r.REQCOD_LL 
from #TI17REQJOBPLAN2 i
LEFT OUTER JOIN BEST..TI17REQ r on i.REQCOD_CT = r.REQCOD_CT 




insert   into #TI17REQJOBPLAN3
select   
	  i.SSD_CF
    , i.BALSHEYEA_NF
    , i.BALSHTMTH_NF
    , i.CLODAT_D
    , i.REQCOD_CT
    , i.DBCLO_D
    , i.CLOTYP_CT
    , i.NORME_CF
     , "USA1"
     , r.REQCOD_LL 
from #TI17REQJOBPLAN2 i
LEFT OUTER JOIN BEST..TI17REQ r on i.REQCOD_CT = r.REQCOD_CT 


/*
select *  
from #TI17REQJOBPLAN3
order by DBCLO_D 
*/

deallocate cursor curs_calend
drop table #TI17REQJOBPLAN 
drop table #TI17REQJOBPLAN2

return @erreur
go


IF OBJECT_ID('dbo.PiTI17REQJOBPLAN_AUTO_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiTI17REQJOBPLAN_AUTO_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiTI17REQJOBPLAN_AUTO_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiREQJOB_01
 */
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_01 TO PUBLIC
go
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiTI17REQJOBPLAN_AUTO_01 TO GDBBATCH
go
