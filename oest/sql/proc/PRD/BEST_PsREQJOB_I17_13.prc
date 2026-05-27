USE BEST
go
IF OBJECT_ID('dbo.PsREQJOB_I17_13') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsREQJOB_I17_13
    IF OBJECT_ID('dbo.PsREQJOB_I17_13') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsREQJOB_I17_13 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsREQJOB_I17_13 >>>'
END
go


create procedure dbo.PsREQJOB_I17_13 (
	    @p_date_t               datetime,
		  @p_ssd_cf USSD_CF,
      @p_esb_cf UESB_CF = null
	  
	) 
as
/***************************************************
Programme: PsREQJOB_I17_13

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
select * from best..TI17CLOPER
BEST..PsREQJOB_I17_13 "20230419" , 4, 2

[007] 22/06/2022 M. NAJI   :spira 105194 modification des paramètres AE pour le décalfge inter norme PROD
[008] 06/07/2022 M. NAJI   :spira 105224 refonte AE 
[009] 10/08/2022 BRK   :spira 104929 block entry on Booking day POS
[010] 13/10/2022 BRK   :spira 106915 fix on POS Booking Day I17
[011] 13/10/2022 BRK   :spira 106720 block entry on Booking day POS IFRS4
[012] 07/10/2022 M.NAJI:spira 107589 Proc POC EBS problème de logique
[013] 08/08/2023 Riyadh : Spira 108958   : Adding new boolean fields for Extenstion period indicators
[014] 05/09/2023 Mariem : Spira 108959 : handle Upload screen
[015] 26/09/2023 Mariem : Spira 110584 : CHECK_40001 upload file >> * Chargement sur une filiale non eligible à la période étendue (PARM1/2 = 1 & PARM5=0)
[016] 26/09/2023 Mariem : Spira 110584 : CHECK_40001 upload file >> * Chargement sur une filiale non eligible à la période étendue (PARM1/2 = 1 & PARM5=0)
[017] 23/10/2023 M.NAJI :SPIRA 108958 P&C and Life – Create Assistance entries (AE) during Local/Parent extended period 
[018] 30/11/2023 Riyadh : Spira 110934 : @INV_Entry_I4I_D /@INV_Entry_EBS_D /@INV_Entry_I17_D   change to Char(12) to store complete date Leap year issue
[019] 10/01/2024 BRK : Spira 110934 Coorect date format 
*****************************************************/


declare
	--[019] Start  
	@Last_Booking_I4I_D     			  Char(8) ,              -- Last Booking IFRS4 Q-1	
	@Last_Booking_EBS_D     			 	Char(8) ,             -- Last Booking EBS Q-1 (New)
	@Last_Booking_17_D      				Char(8) ,			        	-- Last Booking IFRS 17 Q-1
	@End_POS_I4I_D          			 Char(8) ,               -- End date of POS IFRS4 Entry Q  
	@End_POS_EBS_D          			 Char(8) ,               -- End date of POS EBS Entry Q (New)
	@End_POS_I17_D		    			   Char(8) ,			          -- End date of POS IFRS17 Entry Q 
	@End_POC_I4I_D          			 Char(8) ,               -- End date of POC IFRS4 Entry Q-1	 
	@End_POC_EBS_D          			 Char(8) ,               -- End date of POC EBS Entry Q-1 (New)
	@End_POC_I17_D          			 Char(8) ,               -- End date of POC IFRS17 Entry Q-1 (New)
	@Post_Omega_Entry_I4I_D 			 Char(8) ,               -- Quarter post omega IFRS4 (New)
	@Post_Omega_Entry_EBS_D 			 Char(8) ,               -- Quarter post omega EBS (New)
	@Post_Omega_Entry_I17_D 			 Char(8) ,               -- Quarter post omega IFRS17 (New)
	--[019] End  
	@Post_Omega_Yea_I4I_D   			 numeric(4,0) ,          -- Year post omega IFRS4 (New)
	@Post_Omega_Yea_EBS_D   			 numeric(4,0) ,          -- Year post omega EBS (New)
	@Post_Omega_Yea_I17_D   			 numeric(4,0) ,          -- Year post omega IFRS17 (New)
	@Post_Omega_Mth_I4I_D   			 numeric(4,0) ,          -- Month post omega IFRS4 (New)
	@Post_Omega_Mth_EBS_D   			 numeric(4,0) ,          -- Month post omega EBS (New)
	@Post_Omega_Mth_I17_D   			 numeric(4,0) ,          -- Month post omega IFRS17 (New)
	--[019] Start  
	@INV_Entry_I4I_D        			 Char(8) ,               -- Quarter INV IFRS4 (New) --MOD18
	@INV_Entry_EBS_D        			 Char(8) ,               -- Quarter INV EBS (New) --MOD18
	@INV_Entry_I17_D        			 Char(8) ,               -- Quarter INV IFRS17 (New) --MOD18
	--[019] End 
	@INV_Mth_I4I_D          			 numeric(4,0) ,          -- Month INV IFRS4 (New)
	@INV_Mth_EBS_D          			 numeric(4,0) ,          -- Month INV EBS (New)
	@INV_Mth_I17_D          			 numeric(4,0) ,          -- Month INV IFRS17 (New)
	@INV_Yea_I4I_D          			 numeric(4,0) ,          -- Year INV IFRS4 (New)
	@INV_Yea_EBS_D          			 numeric(4,0) ,          -- Year INV EBS (New)
	@INV_Yea_I17_D          			 numeric(4,0) ,          -- Year INV IFRS17 (New)
	@isEnabledPOSocialEbs 		bit ,
	@isEnabledPOSocialIfrs17 	bit ,
	@isEnabledPOSocialIfrs 		bit ,
	@isEnabledPOConsoIfrs		 bit ,
	@isEnabledPOConsoEbs 		bit ,
	@isEnabledPOConsoIfrs17 		bit ,
	@isEnabledServiceIfrs 				bit ,
	@isEnabledServiceEbs 				bit ,
	@isEnabledServiceIfrs17 			bit ,
	@isEnabledServiceLocal 				bit ,
  @isExtended				            bit , --013
	@isExtended_POSP		            bit , --013
	@isExtended_POSL		            bit , --013
	@P_SuffixeTable         			char(1) ,               -- Nom de Suffixe de TABLE : '0' si Erreur
	@P_Erreur               			int     ,              -- CodeRetour Erreur pour Message Appli
	@PARM5_MAX   tinyint     --  count days of POSX
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
	@isEnabledServiceLocal 				=0,
	@isExtended				            =0 , --013
	@isExtended_POSP		            =0 , --013
	@isExtended_POSL		            =0   --013
	
declare @con_ssd_cf char(2)--004
declare @p_site_cf varchar(10)

select @con_ssd_cf= convert(char(2),@p_ssd_cf)--004
Execute @P_Erreur = BEST..PsSITE_01 @con_ssd_cf,'2',@p_site_cf output--004

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
		@Current_Booking_I4I_D 				Char(8),
		@Current_Booking_EBS_D 				Char(8),
		@Current_Booking_I17_D 				Char(12)

--------------------------------------------------------------------
print '==> @P_SuffixeTable = %1! ',  @P_SuffixeTable
--------------------------------------------------------------------  
      
-- Last Booking IFRS4 Q-1
Select @Last_Booking_I4I_D = Convert(char(8), max(dbclo_D),112)
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('I4IQINVB', 'I4IYINVB')
and dbclo_D <= @p_date_t
and SITE_CF   = @p_site_cf
and LAUNCH_D != null
--------------------------------------------------------------------
print '==> @Last_Booking_I4I_D = %1! ',  @Last_Booking_I4I_D
--------------------------------------------------------------------  


-- Last Booking EBS Q-1
Select @Last_Booking_EBS_D = Convert(char(8), max(dbclo_D),112)
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('EBSEQINVB', 'EBSEYINVB')
and dbclo_D <= @p_date_t
and SITE_CF   = @p_site_cf
and LAUNCH_D != null
--------------------------------------------------------------------
print '==> @Last_Booking_EBS_D = %1! ',  @Last_Booking_EBS_D
--------------------------------------------------------------------  

-- Last Booking IFRS 17 Q-1
Select @Last_Booking_17_D = Convert(char(8), Max(dbclo_d),112)
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('I17GQINVB', 'I17GYINVB')
and dbclo_D < @p_date_t
and SITE_CF      = @p_site_cf
and LAUNCH_D != null
--------------------------------------------------------------------
print '==> @Last_Booking_17_D = %1! ',  @Last_Booking_17_D
--------------------------------------------------------------------  

-- End date of POS IFRS4 Entry Q
Select @End_POS_I4I_D = Convert(char(8),min(PSTOMGEND_D),112)
FROM BREF..TCALEND
WHERE  PSTOMGEND_D >= @Last_Booking_I4I_D
--------------------------------------------------------------------
print '==> @End_POS_I4I_D = %1! ',  @End_POS_I4I_D
--------------------------------------------------------------------  


-- End date of POS EBS Entry Q
Select @End_POS_EBS_D = Convert(char(8),min(EBSPSTOMGEND_D),112)
FROM BREF..TCALEND
WHERE  EBSPSTOMGEND_D >=  @Last_Booking_EBS_D
--------------------------------------------------------------------
print '==> @End_POS_EBS_D = %1! ',  @End_POS_EBS_D
--------------------------------------------------------------------  

-- End date of POS IFRS17 Entry Q
Select @End_POS_I17_D = Convert(char(8),min(PSTOMGEND17_D),112)
FROM BREF..TCALEND
WHERE  PSTOMGEND17_D >=  @Last_Booking_17_D

--------------------------------------------------------------------
print '==> @End_POS_I17_D = %1! ',  @End_POS_I17_D
--------------------------------------------------------------------  

-- Extended period boolean
--[017] 
select  @PARM5_MAX=max(convert(int,PARM5)) from BEST..TI17CLOPER
if ( @p_date_t  between convert(date,@End_POS_I17_D) and  dateadd( day, @PARM5_MAX, convert(date,@End_POS_I17_D) )  ) 
	Select @isExtended = 1
--------------------------------------------------------------------
print '==> @isExtended = %1! ',  @isExtended
--------------------------------------------------------------------  

-- End date of POC IFRS4 Entry Q
select @End_POC_I4I_D = Convert(char(8),min(PSTOMGCONEND_D),112)
FROM BREF..TCALEND
WHERE  PSTOMGCONEND_D >=  @End_POS_I4I_D
--------------------------------------------------------------------
print '==> @End_POC_I4I_D = %1! ',  @End_POC_I4I_D
-------------------------------------------------------------------  

-- End date of POC EBS Entry Q
select @End_POC_EBS_D = Convert(char(8),min(EBSPSTOMGCONEND_D),112)
FROM BREF..TCALEND
WHERE  EBSPSTOMGCONEND_D >=  @End_POS_EBS_D
--------------------------------------------------------------------
print '==> @End_POC_EBS_D = %1! ',  @End_POC_EBS_D
--------------------------------------------------------------------  

-- End date of POC IFRS17 Entry Q
Select @End_POC_I17_D = Convert(char(8),min(PSTOMGCONEND17_D),112)
FROM BREF..TCALEND
WHERE  PSTOMGCONEND17_D >=  @End_POS_I17_D
--------------------------------------------------------------------
print '==> @End_POC_I17_D = %1! ',  @End_POC_I17_D
--------------------------------------------------------------------  

-- Entry quarter post omega IFRS4 
Select @Post_Omega_Entry_I4I_D =  Convert(char(8), Max(clodat_d),112)
FROM BEST..TI17REQJOBPLAN where REQCOD_CT in ('I4IQINVB', 'I4IYINVB')
and dbclo_D < @p_date_t
and SITE_CF = @p_site_cf
--------------------------------------------------------------------
print '==> @Post_Omega_Entry_I4I_D = %1! ',  @Post_Omega_Entry_I4I_D
--------------------------------------------------------------------  

-- Entry quarter post omega EBS 
Select @Post_Omega_Entry_EBS_D =  Convert(char(8), Max(clodat_d),112)
FROM BEST..TI17REQJOBPLAN where REQCOD_CT in ('EBSEQINVB', 'EBSEYINVB')
and dbclo_D < @p_date_t
and SITE_CF = @p_site_cf
--------------------------------------------------------------------
print '==> @Post_Omega_Entry_EBS_D = %1! ',  @Post_Omega_Entry_EBS_D
--------------------------------------------------------------------  

-- Entry quarter post omega IFRS17 
Select @Post_Omega_Entry_I17_D =  Convert(char(8), Max(clodat_d),112)
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
--[012]

select @Current_Booking_I4I_D =Convert(char(8),min(Account_D),112)
from bref..tcalend where BLCSHTYEA_NF = @INV_Yea_I4I_D and blcshtmth_nf = ((@INV_Mth_I4I_D +2)/3)*3



--------------------------------------------------------------------
print '==> @Current_Booking_I4I_D = %1! ',  @Current_Booking_I4I_D
--------------------------------------------------------------------  
--[012]
select @Current_Booking_EBS_D =Convert(char(8),min(Account_D),112)
from bref..tcalend where BLCSHTYEA_NF = @INV_Yea_EBS_D and blcshtmth_nf = ((@INV_Mth_EBS_D +2)/3)*3

--------------------------------------------------------------------
print '==> @Current_Booking_EBS_D = %1! ',  @Current_Booking_EBS_D
--------------------------------------------------------------------  
--[012]
select @Current_Booking_I17_D =Convert(char(8),min(Account_D),112)
from bref..tcalend where BLCSHTYEA_NF = @INV_Yea_I17_D and blcshtmth_nf = ((@INV_Mth_I17_D +2)/3)*3

--------------------------------------------------------------------
print '==> @Current_Booking_I17_D = %1! ',  @Current_Booking_I17_D
--------------------------------------------------------------------  
--[011] 
if ( @p_date_t = @End_POS_I4I_D )
  BEGIN
  select @isEnabledPOSocialIfrs = 0,
         @isEnabledPOConsoIfrs = 0, 
	     @isEnabledServiceIfrs  = 0
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
		  --[011] 
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
--[011] this part of code has been added to hamonize the algorithm (IFRS17 + IFRS4)
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
		 -- [009]
		--else  if ( @p_date_t <> @End_POS_EBS_D )
		--[011]
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
 -- If out of extended period : calculation doen't change
 if  ( @isExtended = 0 )
 BEGIN
    --[010]
    if ( @p_date_t = @End_POS_I17_D )
      BEGIN
      select @isEnabledServiceIfrs17 = 0,
             @isEnabledPOConsoIfrs17 = 0, 
    	       @isEnabledPOSocialIfrs17  = 0
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
    		  --[010]
    		--else if ( @p_date_t <> @End_POS_I17_D )
    		ELSE
    			BEGIN
    			  select 	@isEnabledServiceIfrs17 = 1
    			END		
    	END
END

-- If extended period : insert IFRS17 INV and POS Assistance entries
ELSE
	BEGIN
	  select 	@isEnabledServiceIfrs17 = 1

	   --[014]
	   --Upload Screen
	  if ( @p_esb_cf is null )
		  BEGIN
		  --[015] add condition parm1<>'0' or parm2<>'0'
			if exists ( SELECT 1 FROM BEST..TI17CLOPER  where  ( parm1<>'0' or parm2<>'0' or parm5<>'0') and SSD_CF = @p_ssd_cf) select @isEnabledPOSocialIfrs17  = 1
		  END  
	  ELSE
		BEGIN
			  -- Entry Screen
			  declare 	@limit     	Date
			  if exists ( SELECT 1 FROM BEST..TI17CLOPER  where parm5<>'0' and SSD_CF = @p_ssd_cf and esb_cf= @p_esb_cf )
			  BEGIN
				SELECT @limit = dateAdd( day, convert( int, parm5 ), @End_POS_I17_D ) FROM BEST..TI17CLOPER  where SSD_CF =  @p_ssd_cf and esb_cf= @p_esb_cf
				if ( @p_date_t <= @limit  )  select 	@isEnabledPOSocialIfrs17  = 1
				-- Flag to insert AE on Parent
				if exists ( SELECT 1 FROM BEST..TI17CLOPER where SSD_CF = @p_ssd_cf and esb_cf= @p_esb_cf and PARM1 = '1' ) SELECT @isExtended_POSP = 1
				-- Flag to insert AE on Parent
				if exists( SELECT 1 FROM BEST..TI17CLOPER where SSD_CF = @p_ssd_cf and esb_cf= @p_esb_cf and PARM2 = '1' ) SELECT @isExtended_POSL = 1  
			  END
		END  
END
--------------------------------------------------------------------
print '==> @isEnabledPOSocialIfrs17 = %1! ',  @isEnabledPOSocialIfrs17
print '==> @isEnabledServiceIfrs17 = %1! ',  @isEnabledServiceIfrs17
print '==> @isEnabledPOConsoIfrs17 = %1! ',  @isEnabledPOConsoIfrs17
print '==> @limit = %1! ',  @limit
print '==> @isEnabledPOConsoIfrs17 = %1! ',  @isEnabledPOConsoIfrs17
print '==> @isExtended_POSP = %1! ',  @isExtended_POSP
print '==> @isExtended_POSL = %1! ',  @isExtended_POSL
--------------------------------------------------------------------  



select 
	@Last_Booking_I4I_D     		as last_booking_i4i_d     			,
	@Last_Booking_EBS_D     		as last_booking_ebs_d     			,
	@Last_Booking_17_D      		as last_booking_i17_d     			,
	@End_POS_I4I_D          		as end_pos_i4i_d         			,
	@End_POS_EBS_D          		as end_pos_ebs_d          			,
	@End_POS_I17_D		    		  as end_pos_i17_d		    			,
	@End_POC_I4I_D          		as end_poc_i4i_d          			,
	@End_POC_EBS_D          		as end_poc_ebs_d          			,
	@End_POC_I17_D          		as end_poc_i17_d          			,
	@Post_Omega_Entry_I4I_D 		as pos_omega_entry_i4i_d 			,
	@Post_Omega_Entry_EBS_D 		as pos_omega_entry_ebs_d 			,
	@Post_Omega_Entry_I17_D 		as pos_omega_entry_i17_d			,
	@Post_Omega_Yea_I4I_D   		as pos_omega_yea_i4i_d   			,
	@Post_Omega_Yea_EBS_D   		as pos_omega_yea_ebs_d   			,
	@Post_Omega_Yea_I17_D   		as pos_omega_yea_i17_d   			,
	@Post_Omega_Mth_I4I_D   		as pos_omega_mth_i4i_d   			,
	@Post_Omega_Mth_EBS_D   		as pos_omega_mth_ebs_d   			,
	@Post_Omega_Mth_I17_D   		as pos_omega_mth_i17_d   			,
	--[019] Start
    convert( varchar, dateadd(day,-1,dateadd(month,1,convert(char(8),   @INV_Yea_I4I_D*10000+	@INV_Mth_I4I_D*100+1)	)  ), 112) as inv_entry_i4i		,
    convert( varchar, dateadd(day,-1,dateadd(month,1,convert(char(8),   @INV_Yea_EBS_D*10000+	@INV_Mth_EBS_D*100+1)	)  ), 112) as inv_entry_ebs		,
	convert( varchar, dateadd(day,-1,dateadd(month,1,convert(char(8),   @INV_Yea_I17_D*10000+	@INV_Mth_I17_D*100+1)	)  ), 112) as inv_entry_i17		,
	--[019] End
	@INV_Mth_I4I_D          		as inv_mth_i4i_d          			,
	@INV_Mth_EBS_D          		as inv_mth_ebs_d          			,
	@INV_Mth_I17_D          		as inv_mth_i17_d          			,
	@INV_Yea_I4I_D          		as inv_yea_i4i_d          			,
	@INV_Yea_EBS_D          		as inv_yea_ebs_d          			,
	@INV_Yea_I17_D          		as inv_yea_i17_d          			,
	@isEnabledPOSocialEbs 	as isenabledposocialebs 		,
	@isEnabledPOSocialIfrs17 as isenabledposocialifrs17 	,
	@isEnabledPOSocialIfrs 	as isenabledposocialifrs 		,
  @isEnabledPOConsoEbs 	as isenabledpoconsoebs 		,
  @isEnabledPOConsoIfrs17 	as isenabledpoconsoifrs17 		,
	@isEnabledPOConsoIfrs	as isenabledpoconsoifrs		,
	@isEnabledServiceEbs 			as isenabledserviceebs 				,
	@isEnabledServiceIfrs17 		as isenabledServiceifrs17 			,
	@isEnabledServiceIfrs 			as isenabledserviceifrs 				,
	@isEnabledServiceLocal 			as isenabledservicelocal 				,
  @isExtended				        as isExtended   , --013
	@isExtended_POSP		        as sExtended_POSP	 , --013
	@isExtended_POSL		        as isExtended_POSL, --013
	@P_SuffixeTable         		as p_suffixetable         			
	
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

EXEC sp_procxmode 'dbo.PsREQJOB_I17_13', 'unchained'
go
IF OBJECT_ID('dbo.PsREQJOB_I17_13') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsREQJOB_I17_13 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsREQJOB_I17_13 >>>'
go
GRANT EXECUTE ON dbo.PsREQJOB_I17_13 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_I17_13 TO GDBBATCH
go
