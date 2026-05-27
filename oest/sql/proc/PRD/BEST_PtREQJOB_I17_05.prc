USE BEST
go
IF OBJECT_ID('dbo.PtREQJOB_I17_05') IS NOT NULL 
BEGIN
    DROP PROCEDURE dbo.PtREQJOB_I17_05
    IF OBJECT_ID('dbo.PtREQJOB_I17_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtREQJOB_I17_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtREQJOB_I17_05 >>>'
END
go
create procedure dbo.PtREQJOB_I17_05 (
	@p_date_t               datetime,
	@p_site_cf              varchar(10),
	--[015] Start
	@Last_Booking_I4I_D     			 Char(8) output ,              -- Last Booking IFRS4 Q-1	
	@Last_Booking_EBS_D     			 Char(8) output ,             -- Last Booking EBS Q-1 (New)
	@Last_Booking_17_D      			 Char(8) output ,			        	-- Last Booking IFRS 17 Q-1
	@End_POS_I4I_D          			 Char(8) output ,               -- End date of POS IFRS4 Entry Q  
	@End_POS_EBS_D          			 Char(8) output ,               -- End date of POS EBS Entry Q (New)
	@End_POS_I17_D		    			 Char(8) output ,			          -- End date of POS IFRS17 Entry Q 
	@End_POC_I4I_D          			 Char(8) output ,               -- End date of POC IFRS4 Entry Q-1	 
	@End_POC_EBS_D          			 Char(8) output ,               -- End date of POC EBS Entry Q-1 (New)
	@End_POC_I17_D          			 Char(8) output ,               -- End date of POC IFRS17 Entry Q-1 (New)
	@Post_Omega_Entry_I4I_D 			 Char(8) output ,               -- Quarter post omega IFRS4 (New)
	@Post_Omega_Entry_EBS_D 			 Char(8) output ,               -- Quarter post omega EBS (New)
	@Post_Omega_Entry_I17_D 			 Char(8) output ,               -- Quarter post omega IFRS17 (New)
	-- [015] End
	@Post_Omega_Yea_I4I_D   			 numeric(4,0) output   ,   -- Year post omega IFRS4 (New)
	@Post_Omega_Yea_EBS_D   			 numeric(4,0) output   ,   -- Year post omega EBS (New)
	@Post_Omega_Yea_I17_D   			 numeric(4,0) output   ,   -- Year post omega IFRS17 (New)
	@Post_Omega_Mth_I4I_D   			 numeric(4,0) output    ,  -- Month post omega IFRS4 (New)
	@Post_Omega_Mth_EBS_D   			 numeric(4,0) output  ,    -- Month post omega EBS (New)
	@Post_Omega_Mth_I17_D   			 numeric(4,0) output   ,   -- Month post omega IFRS17 (New)
	--[015] Start
	@INV_Entry_I4I_D        			 Char(8) output ,             -- Quarter INV IFRS4 (New)  --MOD14
	@INV_Entry_EBS_D        			 Char(8) output ,               -- Quarter INV EBS (New)       --MOD14
	@INV_Entry_I17_D        			 Char(8) output ,               -- Quarter INV IFRS17 (New)    --MOD14
	-- [015] End
	@INV_Mth_I4I_D          			 numeric(4,0) output   ,  -- Month INV IFRS4 (New)
	@INV_Mth_EBS_D          			 numeric(4,0) output  ,   -- Month INV EBS (New)
	@INV_Mth_I17_D          			 numeric(4,0) output  ,   -- Month INV IFRS17 (New)
	@INV_Yea_I4I_D          			 numeric(4,0) output  ,   -- Year INV IFRS4 (New)
	@INV_Yea_EBS_D          			 numeric(4,0) output  ,   -- Year INV EBS (New)
	@INV_Yea_I17_D          			 numeric(4,0) output   ,  -- Year INV IFRS17 (New)
	@isEnabledPOSocialEbs 		bit output ,
	@isEnabledPOSocialIfrs17 	bit output ,
	@isEnabledPOSocialIfrs 		bit output ,
	@isEnabledPOConsoIfrs		 bit output ,
	@isEnabledPOConsoEbs 		bit output ,
	@isEnabledPOConsoIfrs17 		bit output ,
	@isEnabledServiceIfrs 				bit output ,
	@isEnabledServiceEbs 				bit output ,
	@isEnabledServiceIfrs17 			bit output ,
	@isEnabledServiceLocal 				bit output ,
	@P_SuffixeTable         			char(1) output ,               -- Nom de Suffixe de TABLE : '0' si Erreur
	@P_Erreur               			int   output          -- CodeRetour Erreur pour Message Appli
	  
	  
	) 
as
/***************************************************
Programme: PtREQJOB_I17_05

Fichier script associé :
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI
Date de creation: 27/04/2005
Description: Lecture des demandes B et Sélection des Périodes d'Ecritures Services, Conso, People pour Inventaire
Parametres:
	- Date de traitement

Conditions d'execution:
Commentaires:

BEST..PtREQJOB_I17_05 "20220706" ,"FRA1"

[007] 22/06/2022 M. NAJI   :spira 105194 modification des paramètres AE pour le décalfge inter norme PROD
[008] 06/07/2022 M. NAJI   :spira 105224 refonte AE 
[009] 10/08/2022 BRK   :spira 104929 block entry on Booking day POS
[010] 23/08/2022 BRK   :spira 105224 INV_Entry_I4I_D INV_Entry_EBS_D INV_Entry_I17_D are not calculated
[011] 13/10/2022 BRK   :spira 106915 fix on POS Booking Day I17
[012] 13/10/2022 BRK   :spira 106720 block entry on Booking day POS IFRS4
[013] 07/10/2022 M.NAJI:spira 107589 Proc POC EBS problème de logique
[014] 07/10/2022 Riyadh : Spira 110934 : @INV_Entry_I4I_D /@INV_Entry_EBS_D /@INV_Entry_I17_D   change to Char(12) to store complete date () Leap year issue
[015] 10/01/2024 BRK : Spira 111108 Coorect date format 
*****************************************************/
                                     

select 	
	@isEnabledPOSocialEbs 		=0,
	@isEnabledPOSocialIfrs17 	=0,
	@isEnabledPOSocialIfrs 		=0,
	@isEnabledPOConsoIfrs		=0 ,
	@isEnabledPOConsoEbs 		=0,
	@isEnabledPOConsoIfrs17 		=0,
	@isEnabledServiceIfrs 				=0,
	@isEnabledServiceEbs 				=0,
	@isEnabledServiceIfrs17 			=0,
	@isEnabledServiceLocal 				=0
	

--[007]
Select top 1 @P_SuffixeTable = CLOPER_LS
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('Z')
and dbclo_D <= @p_date_t
--[007] pas de site pour la demande Z
--and SITE_CF   = @p_site_cf
and LAUNCH_D != null
order by dbclo_D desc 

declare 	@erreur     	int ,
		@Current_Booking_I4I_D 				Char(12),
		@Current_Booking_EBS_D 				Char(12),
		@Current_Booking_I17_D 				Char(12)

--------------------------------------------------------------------
print '==> @P_SuffixeTable = %1! ',  @P_SuffixeTable
--------------------------------------------------------------------  
      
-- Last Booking IFRS4 Q-1
Select @Last_Booking_I4I_D = Convert(Char(12), max(dbclo_D),112)
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('I4IQINVB', 'I4IYINVB')
and dbclo_D <= @p_date_t
and SITE_CF   = @p_site_cf
and LAUNCH_D != null
--------------------------------------------------------------------
print '==> @Last_Booking_I4I_D = %1! ',  @Last_Booking_I4I_D
--------------------------------------------------------------------  


-- Last Booking EBS Q-1
Select @Last_Booking_EBS_D = Convert(Char(12), max(dbclo_D),112)
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('EBSEQINVB', 'EBSEYINVB')
and dbclo_D <= @p_date_t
and SITE_CF   = @p_site_cf
and LAUNCH_D != null
--------------------------------------------------------------------
print '==> @Last_Booking_EBS_D = %1! ',  @Last_Booking_EBS_D
--------------------------------------------------------------------  

-- Last Booking IFRS 17 Q-1
Select @Last_Booking_17_D = Convert(Char(12), Max(dbclo_d),112)
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('I17GQINVB', 'I17GYINVB')
and dbclo_D < @p_date_t
and SITE_CF      = @p_site_cf
and LAUNCH_D != null
--------------------------------------------------------------------
print '==> @Last_Booking_17_D = %1! ',  @Last_Booking_17_D
--------------------------------------------------------------------  

-- End date of POS IFRS4 Entry Q
Select @End_POS_I4I_D = Convert(Char(12),min(PSTOMGEND_D),112)
FROM BREF..TCALEND
WHERE  PSTOMGEND_D >= @Last_Booking_I4I_D
--------------------------------------------------------------------
print '==> @End_POS_I4I_D = %1! ',  @End_POS_I4I_D
--------------------------------------------------------------------  


-- End date of POS EBS Entry Q
Select @End_POS_EBS_D = Convert(Char(12),min(EBSPSTOMGEND_D),112)
FROM BREF..TCALEND
WHERE  EBSPSTOMGEND_D >=  @Last_Booking_EBS_D
--------------------------------------------------------------------
print '==> @End_POS_EBS_D = %1! ',  @End_POS_EBS_D
--------------------------------------------------------------------  

-- End date of POS IFRS17 Entry Q
Select @End_POS_I17_D = Convert(Char(12),min(PSTOMGEND17_D),112)
FROM BREF..TCALEND
WHERE  PSTOMGEND17_D >=  @Last_Booking_17_D

--------------------------------------------------------------------
print '==> @End_POS_I17_D = %1! ',  @End_POS_I17_D
--------------------------------------------------------------------  
-- End date of POC IFRS4 Entry Q
select @End_POC_I4I_D = Convert(Char(12),min(PSTOMGCONEND_D),112)
FROM BREF..TCALEND
WHERE  PSTOMGCONEND_D >=  @End_POS_I4I_D
--------------------------------------------------------------------
print '==> @End_POC_I4I_D = %1! ',  @End_POC_I4I_D
-------------------------------------------------------------------  

-- End date of POC EBS Entry Q
select @End_POC_EBS_D = Convert(Char(12),min(EBSPSTOMGCONEND_D),112)
FROM BREF..TCALEND
WHERE  EBSPSTOMGCONEND_D >=  @End_POS_EBS_D
--------------------------------------------------------------------
print '==> @End_POC_EBS_D = %1! ',  @End_POC_EBS_D
--------------------------------------------------------------------  

-- End date of POC IFRS17 Entry Q
Select @End_POC_I17_D = Convert(Char(12),min(PSTOMGCONEND17_D),112)
FROM BREF..TCALEND
WHERE  PSTOMGCONEND17_D >=  @End_POS_I17_D
--------------------------------------------------------------------
print '==> @End_POC_I17_D = %1! ',  @End_POC_I17_D
--------------------------------------------------------------------  

-- Entry quarter post omega IFRS4 
Select @Post_Omega_Entry_I4I_D =  Convert(Char(12), Max(clodat_d),112)
FROM BEST..TI17REQJOBPLAN where REQCOD_CT in ('I4IQINVB', 'I4IYINVB')
and dbclo_D < @p_date_t
and SITE_CF = @p_site_cf
--------------------------------------------------------------------
print '==> @Post_Omega_Entry_I4I_D = %1! ',  @Post_Omega_Entry_I4I_D
--------------------------------------------------------------------  

-- Entry quarter post omega EBS 
Select @Post_Omega_Entry_EBS_D =  Convert(Char(12), Max(clodat_d),112)
FROM BEST..TI17REQJOBPLAN where REQCOD_CT in ('EBSEQINVB', 'EBSEYINVB')
and dbclo_D < @p_date_t
and SITE_CF = @p_site_cf
--------------------------------------------------------------------
print '==> @Post_Omega_Entry_EBS_D = %1! ',  @Post_Omega_Entry_EBS_D
--------------------------------------------------------------------  

-- Entry quarter post omega IFRS17 
Select @Post_Omega_Entry_I17_D =  Convert(Char(12), Max(clodat_d),112)
FROM BEST..TI17REQJOBPLAN where REQCOD_CT in ('I17GQINVB', 'I17GYINVB')
and dbclo_D < @p_date_t
and SITE_CF = @p_site_cf
--------------------------------------------------------------------
print '==> @Post_Omega_Entry_I17_D = %1! ',  @Post_Omega_Entry_I17_D
--------------------------------------------------------------------  

-- Entry Yea/Month on Post Omega period for all norms
Select @Post_Omega_Yea_I4I_D = convert( numeric(4,0), substring(@Post_Omega_Entry_I4I_D,1,4) )
Select @Post_Omega_Yea_EBS_D = convert( numeric(4,0), substring(@Post_Omega_Entry_EBS_D,1,4) )
Select @Post_Omega_Yea_I17_D = convert( numeric(4,0), substring(@Post_Omega_Entry_I17_D,1,4) ) 
Select @Post_Omega_Mth_I4I_D = convert( numeric(4,0), substring(@Post_Omega_Entry_I4I_D,5,2) )
Select @Post_Omega_Mth_EBS_D = convert( numeric(4,0), substring(@Post_Omega_Entry_EBS_D,5,2) )
Select @Post_Omega_Mth_I17_D = convert( numeric(4,0), substring(@Post_Omega_Entry_I17_D,5,2) )
--------------------------------------------------------------------
print '==> @Post_Omega_Yea_I4I_D = %1! ',  @Post_Omega_Yea_I4I_D
print '==> @Post_Omega_Yea_EBS_D = %1! ',  @Post_Omega_Yea_EBS_D
print '==> @Post_Omega_Yea_I17_D = %1! ',  @Post_Omega_Yea_I17_D
print '==> @Post_Omega_Mth_I4I_D = %1! ',  @Post_Omega_Mth_I4I_D
print '==> @Post_Omega_Mth_EBS_D = %1! ',  @Post_Omega_Mth_EBS_D
print '==> @Post_Omega_Mth_I17_D = %1! ',  @Post_Omega_Mth_I17_D
--------------------------------------------------------------------  

-- Entry Yea/Month on INV period for all norms
select @INV_Mth_I4I_D = blcshtmth_nf, 
       @INV_Mth_EBS_D = blcshtmth_nf, 
       @INV_Mth_I17_D = blcshtmth_nf,
       @INV_Yea_I4I_D = blcshtyea_nf,
       @INV_Yea_EBS_D = blcshtyea_nf,
       @INV_Yea_I17_D = blcshtyea_nf
FROM BREF..TCALEND
WHERE  ACCOUNT_D =  ( select min(ACCOUNT_D) FROM BREF..TCALEND where ACCOUNT_D >=  @p_date_t )
--------------------------------------------------------------------
print '==> @INV_Mth_I4I_D = %1! ',  @INV_Mth_I4I_D
print '==> @INV_Mth_EBS_D = %1! ',  @INV_Mth_EBS_D
print '==> @INV_Mth_I17_D = %1! ',  @INV_Mth_I17_D
print '==> @INV_Yea_I4I_D = %1! ',  @INV_Yea_I4I_D
print '==> @INV_Yea_EBS_D = %1! ',  @INV_Yea_EBS_D
print '==> @INV_Yea_I17_D = %1! ',  @INV_Yea_I17_D
--------------------------------------------------------------------  

--[013]
select @Current_Booking_I4I_D =Convert(Char(12),min(Account_D),112)
from bref..tcalend where BLCSHTYEA_NF = @INV_Yea_I4I_D and blcshtmth_nf = ((@INV_Mth_I4I_D +2)/3)*3



--------------------------------------------------------------------
print '==> @Current_Booking_I4I_D = %1! ',  @Current_Booking_I4I_D
--------------------------------------------------------------------  


--[013]
select @Current_Booking_EBS_D =Convert(Char(12),min(Account_D),112)
from bref..tcalend where BLCSHTYEA_NF = @INV_Yea_EBS_D and blcshtmth_nf = ((@INV_Mth_EBS_D +2)/3)*3

--------------------------------------------------------------------
print '==> @Current_Booking_EBS_D = %1! ',  @Current_Booking_EBS_D
--------------------------------------------------------------------  

--[013]
select @Current_Booking_I17_D =Convert(Char(12),min(Account_D),112)
from bref..tcalend where BLCSHTYEA_NF = @INV_Yea_I17_D and blcshtmth_nf = ((@INV_Mth_I17_D +2)/3)*3

--------------------------------------------------------------------
print '==> @Current_Booking_I17_D = %1! ',  @Current_Booking_I17_D
--------------------------------------------------------------------  
--[012]
if ( @p_date_t = @End_POS_I4I_D )
  BEGIN
  select @isEnabledServiceIfrs = 0,
         @isEnabledPOConsoIfrs = 0, 
	     @isEnabledPOSocialIfrs  = 0

  END
  
ELSE
	BEGIN
		if (@p_date_t < @End_POC_I4I_D and @p_date_t > @Last_Booking_I4I_D and @End_POC_I4I_D < @Current_Booking_I4I_D )
		  BEGIN
			  select @isEnabledPOConsoIfrs = 1 
		  END
		  
		if (@p_date_t > @Last_Booking_I4I_D and @p_date_t < @End_POS_I4I_D)
		  BEGIN
			select 	@isEnabledPOSocialIfrs = 1, @isEnabledPOConsoIfrs = 0
		  END
		  --[012]
		  --[009]
		--else if ( @p_date_t <> @End_POS_I4I_D )
		ELSE
		  BEGIN
			select 	@isEnabledServiceIfrs = 1
		  END			
	END
--------------------------------------------------------------------
print '==> @isEnabledPOSocialIfrs = %1! ',  @isEnabledPOSocialIfrs
print '==> @isEnabledServiceIfrs = %1! ',  @isEnabledServiceIfrs
print '==> @isEnabledPOConsoIfrs = %1! ',  @isEnabledPOConsoIfrs
--------------------------------------------------------------------  
--[012] this part of code has been added to hamonize the algorithm (IFRS17 + IFRS4)
if ( @p_date_t = @End_POS_EBS_D )
  BEGIN
  select @isEnabledServiceEbs = 0,
         @isEnabledPOConsoEbs = 0, 
	     @isEnabledPOSocialEbs  = 0

  END
  
 ELSE 
	BEGIN 
		if (@p_date_t < @End_POC_EBS_D and @p_date_t > @Last_Booking_EBS_D and @End_POC_EBS_D < @Current_Booking_EBS_D  )
		  BEGIN
			  select @isEnabledPOConsoEbs = 1 
		  END
		  
		if (@p_date_t > @Last_Booking_EBS_D and @p_date_t < @End_POS_EBS_D)
		  BEGIN
			  select 	@isEnabledPOSocialEbs = 1, @isEnabledPOConsoEbs = 0
			
		  END
		  --[012]
		 -- [009]
		--else  if ( @p_date_t <> @End_POS_EBS_D )
		ELSE
		  BEGIN
			  select 	@isEnabledServiceEbs = 1
		  END		
	END
--------------------------------------------------------------------
print '==> @isEnabledPOSocialEbs = %1! ',  @isEnabledPOSocialEbs
print '==> @isEnabledServiceEbs = %1! ',  @isEnabledServiceEbs
print '==> @isEnabledPOConsoEbs = %1! ',  @isEnabledPOConsoEbs
--------------------------------------------------------------------  
--[011] 
if ( @p_date_t = @End_POS_I17_D )
  BEGIN
  select @isEnabledServiceIfrs17 = 0,
         @isEnabledPOConsoIfrs17 = 0, 
	       @isEnabledPOSocialIfrs  = 0

  END

ELSE 
	BEGIN
		if (@p_date_t < @End_POC_I17_D and @p_date_t > @Last_Booking_17_D and @End_POC_I17_D < @Current_Booking_I17_D )
		  BEGIN
			  select @isEnabledPOConsoIfrs17 = 1 
		  END
		if (@p_date_t > @Last_Booking_17_D and @p_date_t < @End_POS_I17_D)
		  BEGIN
			  select 	@isEnabledPOSocialIfrs17 = 1, @isEnabledPOConsoIfrs17 = 0
		  END
		  --[009]
		--else if ( @p_date_t <> @End_POS_I17_D )
		--[011]
		ELSE
			BEGIN
			  select 	@isEnabledServiceIfrs17 = 1
			END		
	END
--------------------------------------------------------------------
print '==> @isEnabledPOSocialIfrs17 = %1! ',  @isEnabledPOSocialIfrs17
print '==> @isEnabledServiceIfrs17 = %1! ',  @isEnabledServiceIfrs17
print '==> @isEnabledPOConsoIfrs17 = %1! ',  @isEnabledPOConsoIfrs17
--------------------------------------------------------------------  

--[010] Start
-- [015] Start
select @INV_Entry_I4I_D = convert( varchar, dateadd(day,-1,dateadd(month,1,convert(Char(12),   @INV_Yea_I4I_D*10000+	@INV_Mth_I4I_D*100+1)	)  ), 112)			 
select @INV_Entry_EBS_D = convert( varchar, dateadd(day,-1,dateadd(month,1,convert(Char(12),   @INV_Yea_EBS_D*10000+	@INV_Mth_EBS_D*100+1)	)  ), 112)      			 
select @INV_Entry_I17_D = convert( varchar, dateadd(day,-1,dateadd(month,1,convert(Char(12),   @INV_Yea_I17_D*10000+	@INV_Mth_I17_D*100+1)	)  ), 112)     			 
	
--------------------------------------------------------------------
print '==> @INV_Entry_I4I_D = %1! ',  @INV_Entry_I4I_D
print '==> @INV_Entry_EBS_D = %1! ',  @INV_Entry_EBS_D
print '==> @INV_Entry_I17_D = %1! ',  @INV_Entry_I17_D
--------------------------------------------------------------------  
-- [015] End
--[010] End


Select @erreur = @@error
if @erreur != 0  goto fin




ErreurNom:
      -- Select @P_SuffixeTable = '0'
       --if (@tran_imbr = 0) ROLLBACK TRAN
	 return 0

fin:
--if @tran_imbr = 0
--	 ROLLBACK TRAN

return 1
go

EXEC sp_procxmode 'dbo.PtREQJOB_I17_05', 'unchained'
go
IF OBJECT_ID('dbo.PtREQJOB_I17_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtREQJOB_I17_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtREQJOB_I17_05 >>>'
go
GRANT EXECUTE ON dbo.PtREQJOB_I17_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtREQJOB_I17_05 TO GDBBATCH
go
