/** Alter Procedure Script **/

use BEST
go

drop procedure dbo.PsIfrs17Param_02
go

/*
 * creation de la procedure
*/

create procedure PsIfrs17Param_02
     (
       @p_CRE_D        date
     )
with execute as caller
as 
/***************************************************

Programme: PsIfrs17Param_02

Fichier script associé : BEST_PsIfrs17Param_02
Domaine : (ES) Estimation
Base principale : BEST
Version: 1 
Auteur: M. DJELLOULI 
Date de creation: 30-12-2020
 
Description du programme:
      Calcul des paramÃ?Â¨tres de l'inventaire

BEST..PsIfrs17Param_02 '20231127' 

select * from best..TI17REQJOBPLAN
Parametres:
       @p_cre_d        date
select * from best..TI17REQJOBPLAN where reqcod_ct like ('%INVB')
Conditions d'execution:

Commentaires:

_________________
MODIFICATION 1
[001] 10/03/2021 M.NAJI :Spira 91531 Modification de la requÃ?Âªte qui extrait les filiales
[002] 17/03/2021 M.NAJI :Spira 91531 Modification du calcul de PARM_BOOKING_D
[003] 06/04/2021 M.NAJI :Spira 91531 Correction AnnÃ©e/mois comptable prÃ?Â©cÃ?Â©dent 
[004] 20/05/2021 M.NAJI :Spira 91531 ajout des paramÃ¨tres PARM_ICLODAT_QTR et PARM_ICLODAT_YEA
[005] 18/06/2021 M.NAJI :Spira 91532 ajout du paramÃ¨tres PARM_FTECLEDA et PARM_TYPINV2
[006] 23/11/2021 M.NAJI :Spira 98294 ajout parmamÃ¨tres ID_NF,VERS_NF,ID_NF_AOC,VERS_NF_AOC,PARM_BOOKINGPREV_D  
[007] 27/12/2021 M.NAJI :Spira 98294 ajout parmamÃ¨tres fix calcul de @SPECEND_D 
[008] 28/12/2021 M.NAJI :Spira 101417 ajout parmamÃ¨tres @PARM_PSTOMGEN_PREV_D,@PARM_EBSPSTOMGEN_PREV_D ,@PARM_PSTOMGEND17_PREV_D , et correction du PERTYP
[009] 07/03/2022 M.NAJI :Spira 96729  modification du calcul de IS_SAP_POSTING
[010] 17/03/2022 Mbrik :Spira 102968  modification du calcul de booking tech par norme
[011] 07/04/2022 Mbrik/JYP/TD : revert part of spira 102968 : UAT date RA files on wrong quarter
[012] 15/06/2022 M.NAJI : SPIRA 104778 ajout de la norme I17S
[013] 10/10/2022 M.NAJI : SPIRA 999999 intialisation des paramètres à NULL à chaque itération de RECCOD_CT (NORME) 
[014] 04/O4/2023 M.NAJI : SPIRA 109446 fix norme I17S
[016] 03/05/2023 M.NAJI : SPIRA 109633 - Closing parameter : add I17 POS end date of current closing: @PARAM_CUR_PSTOMGEND17_D
[017] 03/05/2023 M.NAJI : SPIRA 110112 Issue with IFRS17 simulation on AZUAT
[018] 31/10/2023 M.Naji:  SPIRA 110113 TI17CLOPER historisation and copy from quarter to quarter
[019] 16/02/2024 M.NAJI:  SPIRA  111234 : I17P/I17L extended- AE not extracted in the closing , add PARM_PSTOMGEND17_POSX_D
[020] 19/04/2024 M.NAJI:  SPIRA  111511 Ajout du paramtre "NORME" pour corriger la bouclette
[021] 30/09/2024/M.NAJI:  SPIRA 111993 NTAP automation - Parameters management PARAMETER PARAM_CUR_BOOKING_D
[022] 12/02/2025 :M.NAJI SPIRA 112675 : Green IT- Improve closing files lifecycle
[023] 16/07/2025 :M.NAJI US 5559 SERQS - RA/SAP interface -Phase 1

*****************************************************/

declare @erreur int 

declare @site_cf  varchar(10)
declare @PARM_BATCHUSER varchar(20)
select @PARM_BATCHUSER = suser_Name()
Execute @erreur = BEST..PsSITE_01 @PARM_BATCHUSER,'0',@site_cf output


declare  @PARAM_IS_SAP_POSTING char(1),@PARM_IS_SAP_POSTING char(1)


-- récupérer  les paramètres de  la demande la plus récente IFRS4

Select top 1
        BALSHEYEA_NF,
		BALSHTMTH_NF,
        convert(char(8),dateadd(dd,-1,dateadd(mm,1,convert(char(6),BALSHEYEA_NF*100 + BALSHTMTH_NF) + '01')),112) CLODAT_D,
		CLODAT_D ICLODAT_D,
		CLOTYP_CT,
		NORME_CF,
        REQCOD_CT,
        DBCLO_D,
		convert(int,ID_NF ) ID_NF, 
		VRS_NF  
into #TREQJOBPLAN
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF = @site_cf  -- @site_cf  
and  NORME_CF ='I4I'
order by DBCLO_D desc

-- récupérer  les paramètres de  la demande la plus récente EBS
insert into #TREQJOBPLAN
Select top 1
        BALSHEYEA_NF,
		BALSHTMTH_NF,
        convert(char(8),dateadd(dd,-1,dateadd(mm,1,convert(char(6),BALSHEYEA_NF*100 + BALSHTMTH_NF) + '01')),112) CLODAT_D,
		CLODAT_D ICLODAT_D,
		CLOTYP_CT,
		NORME_CF,
        REQCOD_CT,
        DBCLO_D,
		convert(int,ID_NF ) ID_NF, 
		VRS_NF 
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF = @site_cf  -- @site_cf  
and  NORME_CF ='EBSE'
order by DBCLO_D desc

-- récupérer  les paramètres de  la demande la plus récente local
insert into #TREQJOBPLAN
Select top 1
        BALSHEYEA_NF,
		BALSHTMTH_NF,
        convert(char(8),dateadd(dd,-1,dateadd(mm,1,convert(char(6),BALSHEYEA_NF*100 + BALSHTMTH_NF) + '01')),112) CLODAT_D,
		CLODAT_D ICLODAT_D,
		CLOTYP_CT,
		NORME_CF,
        REQCOD_CT,
        DBCLO_D,
		convert(int,ID_NF ) ID_NF, 
		VRS_NF 
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF = @site_cf  -- @site_cf  
and  NORME_CF ='I4L'
order by DBCLO_D desc



-- récupérer  les paramètres de  la demande la plus récente IFRS17
insert into #TREQJOBPLAN
Select top 1
        BALSHEYEA_NF,
		BALSHTMTH_NF,
        convert(char(8),dateadd(dd,-1,dateadd(mm,1,convert(char(6),BALSHEYEA_NF*100 + BALSHTMTH_NF) + '01')),112) CLODAT_D,
		CLODAT_D ICLODAT_D,
		CLOTYP_CT,
		NORME_CF,
        REQCOD_CT, 
        DBCLO_D,
		convert(int,ID_NF ) ID_NF, 
		VRS_NF  
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF = @site_cf  -- @site_cf  
and  REQCOD_CT like  'I17G%'
order by DBCLO_D desc

--[012]
insert into #TREQJOBPLAN
Select top 1
        BALSHEYEA_NF,
		BALSHTMTH_NF,
        convert(char(8),dateadd(dd,-1,dateadd(mm,1,convert(char(6),BALSHEYEA_NF*100 + BALSHTMTH_NF) + '01')),112) CLODAT_D,
		CLODAT_D ICLODAT_D,
		CLOTYP_CT,
		NORME_CF,
        REQCOD_CT, 
        DBCLO_D,
		convert(int,ID_NF ) ID_NF, 
		VRS_NF  
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF = @site_cf  -- @site_cf  
and  REQCOD_CT like  'I17S%'
order by DBCLO_D desc

insert into #TREQJOBPLAN
Select top 1
        BALSHEYEA_NF,
		BALSHTMTH_NF,
        convert(char(8),dateadd(dd,-1,dateadd(mm,1,convert(char(6),BALSHEYEA_NF*100 + BALSHTMTH_NF) + '01')),112) CLODAT_D,
		CLODAT_D ICLODAT_D,
		CLOTYP_CT,
		NORME_CF,
        REQCOD_CT, 
        DBCLO_D,
		convert(int,ID_NF ) ID_NF, 
		VRS_NF  
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF = @site_cf  -- @site_cf  
and  REQCOD_CT like  'I17P%'
order by DBCLO_D desc


insert into #TREQJOBPLAN
Select top 1
        BALSHEYEA_NF,
		BALSHTMTH_NF,
        convert(char(8),dateadd(dd,-1,dateadd(mm,1,convert(char(6),BALSHEYEA_NF*100 + BALSHTMTH_NF) + '01')),112) CLODAT_D,
		CLODAT_D ICLODAT_D,
		CLOTYP_CT,
		NORME_CF,
        REQCOD_CT, 
        DBCLO_D,
		convert(int,ID_NF ) ID_NF, 
		VRS_NF  
FROM   best..ti17reqjobplan
Where  DBCLO_D <= @p_CRE_D -- @dbclo_d
And     LAUNCH_D Is NULL
and     SITE_CF = @site_cf  -- @site_cf  
and  REQCOD_CT like  'I17L%'
order by DBCLO_D desc

declare 
	@BALSHEYEA_NF smallint ,
	@BALSHTMTH_NF tinyint ,
	@ICLODAT_D datetime ,
	@CLODAT_D datetime ,
	@REQCOD_CT varchar(32) ,
	@CRE_D UUPD_D ,
	@DBCLO_D UUPD_D ,
	@LAUNCH_D UUPD_D ,
	@CLOTYP_CT char(5) ,
	@NORME_CF varchar(5) ,
    @PARM_I4I_ICLODAT_D datetime ,
    @PARM_EBS_ICLODAT_D datetime ,
    @PARM_DBCLO_MAX_D datetime , 
	@ID_NF  int, 
	@VRS_NF int, 
	@ID_NF_AOC  int, 
	@VRS_NF_AOC int ,
	@PARM_POSX char(5) 
	

declare  @PARM_BOOKINGPREV_D date
	
select @PARM_POSX=''	
	
select @PARM_DBCLO_MAX_D = max(DBCLO_D) 
FROM best..tI17reqjobplan 
where     REQCOD_CT like '%O' 
and DBCLO_D <= @p_CRE_D
and site_cf = @site_cf


select  @ID_NF_AOC=ID_NF , @VRS_NF_AOC=VRS_NF  
FROM best..tI17reqjobplan 
where   DBCLO_D = @PARM_DBCLO_MAX_D 
and site_cf =@site_cf
and REQCOD_CT like '%O'

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Declare curs_TREQJOBPLAN Cursor For Select 
                                            BALSHEYEA_NF,
                                            BALSHTMTH_NF,
                                            CLODAT_D,
                                            ICLODAT_D, 
                                            CLOTYP_CT,
                                            NORME_CF,
                                            REQCOD_CT,
											ID_NF , 
											VRS_NF 
                                    from #TREQJOBPLAN
									order by NORME_CF

Open curs_TREQJOBPLAN

declare @Last_BLCSHTYEA_NF smallint , @Last_BLCSHTMTH_NF  smallint
declare @PARM_BOOKING_D date, @SPECEND_D date,    @ACCOUNT_D  date,  @PARM_PSTOMGEN_D date, @PARM_EBSPSTOMGEN_D date, @PARM_DBCLO_D  date,@PARM_ENCONSO_D date ,
     @PARM_PSTOMGEND17_D   date,
     @PARAM_PSTOMGCONEND_D  date,
     @PARAM_EBSPSTOMGCONEND_D  date,
     @PARAM_PSTOMGCONEND17_D   date,
	 @PARM_PSTOMGEN_PREV_D   date,
	 @PARM_EBSPSTOMGEN_PREV_D date, 
	 @PARM_PSTOMGEND17_PREV_D date
declare @PARM_PERTYP_CT char(1) , @PARM_CLOTYP_CT  char(1) , @PARM_REQCOD_CT  varchar(20), @PARM_IS_COMPTA  char(1), @CLOPRD char(6)
declare  @PARM_BOOKINGNEXT_D datetime
declare @PARM_ISSDCLO_LL varchar(1000)


declare @PARAM_IS_TRIM char(1) , @PARAM_IS_YEARLY char(1)
declare @PARM_IS_TRIM char(1)  , @PARM_IS_YEARLY char(1), @PARM_IS_COMPTATEC_TRIM char(1) , @PARM_IS_COMPTATEC_YEARLY char(1), @PARM_IS_COMPTATEC_YEARLY_POS char(1)
declare @PARAM_CUR_PSTOMGEND17_D date
declare @PARAM_CUR_BOOKING_D   date


declare @PMAX_PARM5 int , @PARM_PSTOMGEND17_POSX_D  date 

select @PMAX_PARM5=max(convert(int,PARM5)) 
from BEST..TI17CLOPER


-- select @PARM_PSTOMGEND17_POSX_D


Create Table #PARAM ( norme varchar(10), parm varchar(64) , value  Varchar(4000)  NULL)

Fetch curs_TREQJOBPLAN Into @BALSHEYEA_NF,
							@BALSHTMTH_NF,
							@CLODAT_D,
							@ICLODAT_D,
							@CLOTYP_CT,
							@NORME_CF, 
							@REQCOD_CT,
							@ID_NF , 
							@VRS_NF 
While (@@sqlstatus = 0)
Begin


	select 
		 @PARM_PSTOMGEND17_D=NULL
		,@PARAM_PSTOMGCONEND_D=NULL
		,@PARAM_EBSPSTOMGCONEND_D=NULL
		,@PARAM_PSTOMGCONEND17_D=NULL
		,@PARM_PSTOMGEN_PREV_D=NULL
		,@PARM_EBSPSTOMGEN_PREV_D=NULL
		,@PARM_PSTOMGEND17_PREV_D=NULL
		,@PARM_BOOKINGNEXT_D=NULL
		,@PARM_IS_COMPTA=NULL
		,@Last_BLCSHTMTH_NF=NULL
		,@Last_BLCSHTYEA_NF=NULL
		--,@CLOPRD=NULL
		,@PARAM_IS_SAP_POSTING=NULL
		,@PARM_IS_SAP_POSTING=NULL
		,@PARM_BOOKING_D=NULL
		,@PARM_DBCLO_D		=NULL
		,@PARM_ENCONSO_D  	=NULL
		,@PARM_EBSPSTOMGEN_D 	=NULL
		,@PARM_PSTOMGEN_D		=NULL
		,@PARM_PERTYP_CT=NULL
		,@PARM_CLOTYP_CT=NULL
		,@PARM_EBS_ICLODAT_D=NULL
		,@PARM_BOOKINGPREV_D=NULL
		,@SPECEND_D=NULL
		,@ACCOUNT_D=NULL
		
	if ( @REQCOD_CT like "%POSX" )
		select @PARM_POSX='_POSX'

	--[016]
	Select  @PARAM_CUR_PSTOMGEND17_D = PSTOMGEND17_D,
			@PARAM_CUR_BOOKING_D=ACCOUNT_D  --[021]
	FROM BREF..TCALEND
	WHERE BLCSHTYEA_NF = datepart(yy,@ICLODAT_D)
	and BLCSHTMTH_NF = datepart(mm,@ICLODAT_D)

	-- [018]
	if @REQCOD_CT in ( "I17LQPOSB","I17LYPOSB","I17PQPOSB","I17PYPOSB") and not exists (select  1 from  BEST..TI17CLOPER_V  where  CLODAT_D= @ICLODAT_D) 
	BEGIN 
	
		-- copie de Q vers Q+1
		Insert into  BEST..TI17CLOPER_V  
		SELECT	SSD_CF,
			ESB_CF,
            @ICLODAT_D,
			PARM1,
			PARM2,
			PARM3,
			PARM4,
			PARM5,
			PARM6,
			PARM7,
			PARM8,
			PARM9,
			PARM10 
		FROM BEST..TI17CLOPER  

	END	
	--end [018]


	

	select @PARAM_IS_SAP_POSTING = "N",@PARM_IS_SAP_POSTING = "N"
	--select @PARAM_IS_SAP_POSTING = "Y",@PARM_IS_SAP_POSTING = "Y"
	--from BEST..TI17REQJOBplan
	--where LAUNCH_D = NULL
	--and ( ( REQCOD_CT like ('%B') and  CLOTYP_CT in ('POS', 'INV') and  NORME_CF = @NORME_CF )  or NORME_CF = 'SAP' ) 
	--and DBCLO_D <= @p_CRE_D
	--and SITE_CF = @site_cf
	-- [009]
	select @PARAM_IS_SAP_POSTING = "Y",@PARM_IS_SAP_POSTING = "Y"
	from BEST..TI17REQ 
	where reqcod_ct = @REQCOD_CT 
	and SAPOSTING_CT ='Y'

	if ( @NORME_CF = "I4I" )     select @PARM_I4I_ICLODAT_D=@ICLODAT_D
	if ( @NORME_CF = "EBSE" )     select @PARM_EBS_ICLODAT_D=@ICLODAT_D

	if ( @NORME_CF = "I4I" and @CLOTYP_CT ="INV" and @BALSHTMTH_NF in ( 3,6,9,12))
		select @PARM_CLOTYP_CT ="P"
	else
		select @PARM_CLOTYP_CT ="A"
		

	select 	@PARAM_IS_TRIM="N" , @PARAM_IS_YEARLY="N"
	select 	@PARM_IS_TRIM="N" , @PARM_IS_YEARLY="N",@PARM_IS_COMPTATEC_TRIM="N" , @PARM_IS_COMPTATEC_YEARLY="N",  @PARM_IS_COMPTATEC_YEARLY_POS ="N"

	if  @BALSHTMTH_NF in ( 3,6,9)
		select @PARAM_IS_TRIM ="Y", @PARM_IS_TRIM ="Y"
	if  @BALSHTMTH_NF = 12
		select @PARAM_IS_YEARLY ="Y", @PARM_IS_YEARLY ="Y"

	if @PARM_IS_TRIM ="Y" and @REQCOD_CT  like "%B" and @CLOTYP_CT ="INV"  
		select @PARM_IS_COMPTATEC_TRIM ="Y"

	if @PARM_IS_YEARLY ="Y" and @REQCOD_CT  like "%B" and @CLOTYP_CT ="INV"  
		select @PARM_IS_COMPTATEC_YEARLY ="Y"

	if @PARM_IS_YEARLY ="Y" and @REQCOD_CT  like "%B" and @CLOTYP_CT ="POS"  
		select @PARM_IS_COMPTATEC_YEARLY_POS ="Y"


	--- changer NORME_CF par une seule variable pour le I17* et AOC 
	--Select @Last_BLCSHTYEA_NF = Max(BALSHEYEA_NF )
	--FROM BEST..TI17REQJOBPLAN
	--WHERE REQCOD_CT      in(@NORME_CF+"QINVB" , @NORME_CF+"YINVB")
	--    and LAUNCH_D     <= @p_CRE_D
	--    and SITE_CF      = @site_cf

	-- [010]
	-- Calcul de la compta tech par Norme (compta trimestrielle et annuelle uniquement)
	select @PARM_BOOKING_D = Max(dbclo_d)                        
		FROM BEST..TI17REQJOBPLAN where REQCOD_CT in (@Norme_cf+'QINVB', @Norme_cf+'YINVB')
		and dbclo_D < @p_CRE_D
		and SITE_CF      = @site_cf
		
	/*--Parm Booking T-1
	select @PARM_BOOKING_D = Max(account_D)                        
		FROM BREF..TCALEND where 
		account_D < @p_CRE_D and Closing_B = 1*/

	--Parm Booking T-2
	select @PARM_BOOKINGPREV_D = Max(account_D)                         
		FROM BREF..TCALEND where 
		account_D < @PARM_BOOKING_D and Closing_B = 1

	--Parm last BLC month / year 
	select @Last_BLCSHTYEA_NF = BLCSHTYEA_NF, @Last_BLCSHTMTH_NF = BLCSHTMTH_NF
	FROM BREF..TCALEND 
	WHERE account_D = @PARM_BOOKING_D




	  
								
	Select @PARM_PSTOMGEN_D = PSTOMGEND_D,
		@PARM_EBSPSTOMGEN_D = EBSPSTOMGEND_D,     --[23390]
		@PARM_PSTOMGEND17_D = PSTOMGEND17_D,     --Nouveau  
		@PARAM_PSTOMGCONEND_D = PSTOMGCONEND_D,  --Nouveau
		@PARAM_EBSPSTOMGCONEND_D = EBSPSTOMGCONEND_D,  --Nouveau
		@PARAM_PSTOMGCONEND17_D = PSTOMGCONEND17_D,  --Nouveau
		@PARM_ENCONSO_D = 	case 
								 when @NORME_CF 	="I4I"  then PSTOMGCONEND_D
								 when @NORME_CF 	="EBSE" then EBSPSTOMGCONEND_D
								 when @NORME_CF 	like "I17%" then PSTOMGCONEND17_D
							end                          
	FROM BREF..TCALEND
	WHERE BLCSHTYEA_NF = @Last_BLCSHTYEA_NF
		and BLCSHTMTH_NF = @Last_BLCSHTMTH_NF
		and Closing_B = 1

	--[019]
	select @PARM_PSTOMGEND17_POSX_D= dateadd(day,@PMAX_PARM5,@PARM_PSTOMGEND17_D)

 
   --select @PARM_PSTOMGEND17_POSX_D

	--[008]
	Select 	@PARM_PSTOMGEN_PREV_D 	 = max(PSTOMGEND_D) 		FROM BREF..TCALEND WHERE PSTOMGEND_D 		< @PARM_PSTOMGEN_D
	Select 	@PARM_EBSPSTOMGEN_PREV_D = max(EBSPSTOMGEND_D) 		FROM BREF..TCALEND WHERE EBSPSTOMGEND_D < @PARM_EBSPSTOMGEN_D
	Select 	@PARM_PSTOMGEND17_PREV_D = max(PSTOMGEND17_D) 	FROM BREF..TCALEND WHERE PSTOMGEND17_D 		< @PARM_PSTOMGEND17_D

		
	--[007]
	Select 	@SPECEND_D = SPECEND_D,
			@ACCOUNT_D = ACCOUNT_D	
	FROM BREF..TCALEND
	WHERE BLCSHTYEA_NF = @BALSHEYEA_NF
		and BLCSHTMTH_NF = @BALSHTMTH_NF
		
	  
	select @PARM_PERTYP_CT = "H"
	select @PARM_DBCLO_D   = convert(char(8),@p_CRE_D,112) 

	if @PARM_DBCLO_D > @SPECEND_D
	begin
		select @PARM_PERTYP_CT = "S"
		select @PARM_DBCLO_D  = @SPECEND_D
	end


	declare @SeqMode  char(1) 
	select @SeqMode='0'
	if exists ( select 1 from best..TI17REQ where reqcod_ct = 'SequentialRun')   select @SeqMode='1'


	declare  curs_ssd cursor for
	--[001]
	select SSD_CF
	from   BREF..TBATCHSSD 
	where BATCHUSER_CF = @PARM_BATCHUSER

	declare @ssd tinyint , @user varchar(10) ,   @site varchar(32) , @PARAM_SSD_LIST varchar(1000),@EST_SORT_CONDITION varchar(1000)


	select @PARAM_SSD_LIST ='(1=1' 

	OPEN curs_ssd

	fetch curs_ssd into @ssd

	While (@@sqlstatus = 0)
	BEGIN
		select @PARAM_SSD_LIST = @PARAM_SSD_LIST + " OR SSD_CF=" + convert(varchar(2),@ssd)
		fetch curs_ssd into @ssd
	END

	CLOSE curs_ssd

	deallocate cursor curs_ssd

		------ [023]

	declare @EST_SORT_CONDITION_AS varchar(1000) ,
		 @EST_SORT_CONDITION_EU varchar(1000) ,
		 @EST_SORT_CONDITION_AM varchar(1000) 


	declare  curs_ssd_all cursor for
	
	select SSD_CF, BATCHUSER_CF
	from   BREF..TBATCHSSD 
	
	declare @PARM_BATCHUSER_ALL varchar(20)

	select 	@EST_SORT_CONDITION_AS ='(1=1' ,
			@EST_SORT_CONDITION_EU ='(1=1' ,
			@EST_SORT_CONDITION_AM ='(1=1' 
	
	OPEN curs_ssd_all

	fetch curs_ssd_all into @ssd,@PARM_BATCHUSER_ALL
	While (@@sqlstatus = 0)
	BEGIN
		
		if ( @PARM_BATCHUSER_ALL  = "UBAS" ) select @EST_SORT_CONDITION_AS = @EST_SORT_CONDITION_AS + " OR SSD_CF=" + convert(varchar(2),@ssd) 
		if ( @PARM_BATCHUSER_ALL  = "UBEU" ) select @EST_SORT_CONDITION_EU = @EST_SORT_CONDITION_EU + " OR SSD_CF=" + convert(varchar(2),@ssd) 
		if ( @PARM_BATCHUSER_ALL  = "UBAM" ) select @EST_SORT_CONDITION_AM = @EST_SORT_CONDITION_AM + " OR SSD_CF=" + convert(varchar(2),@ssd) 
		fetch curs_ssd_all into @ssd, @PARM_BATCHUSER_ALL
	END

	CLOSE curs_ssd_all



	deallocate cursor curs_ssd_all

	select 	@EST_SORT_CONDITION_AS = "'" + str_replace(@EST_SORT_CONDITION_AS,'(1=1 OR','(') + ")" +"'"
	select 	@EST_SORT_CONDITION_EU = "'" + str_replace(@EST_SORT_CONDITION_EU,'(1=1 OR','(') + ")" +"'"
	select 	@EST_SORT_CONDITION_AM = "'" + str_replace(@EST_SORT_CONDITION_AM,'(1=1 OR','(') + ")" +"'"


	------ end [023]



	select 	@PARAM_SSD_LIST = "'" + str_replace(@PARAM_SSD_LIST,'(1=1 OR','(') + ")" +"'"

	select @EST_SORT_CONDITION= @PARAM_SSD_LIST
	 
	-- remplacer 'OR par _
	select @PARM_ISSDCLO_LL = str_replace( @EST_SORT_CONDITION ,'(', '_')
	select @PARM_ISSDCLO_LL = str_replace( @PARM_ISSDCLO_LL ,')', '_') 
	select @PARM_ISSDCLO_LL = str_replace( @PARM_ISSDCLO_LL ,' OR SSD_CF=','_')
	select @PARM_ISSDCLO_LL = str_replace( @PARM_ISSDCLO_LL ,' SSD_CF=','')
	select @PARM_ISSDCLO_LL = str_replace( @PARM_ISSDCLO_LL ,'_ ','_')





	select @PARM_IS_COMPTA =substring(reverse(@REQCOD_CT),1,1)
	if  @PARM_IS_COMPTA  = "B"
		select @PARM_IS_COMPTA = "Y"
	else
		select @PARM_IS_COMPTA = "N" 




	--Parm Booking T 
	select @PARM_BOOKINGNEXT_D =  Min(account_D)                        
	FROM BREF..TCALEND where 
	account_D >= @p_CRE_D and Closing_B = 1


	-- calcul CLOPRD  
	select @CLOPRD=convert ( char(6),@BALSHEYEA_NF*100 + @BALSHTMTH_NF )
	if @NORME_CF = "EBSE"
		 select @CLOPRD=substring(convert(varchar(8),@ICLODAT_D,112),1,6) 


	--select @NORME_CF = str_replace (@NORME_CF,"I17G","I17" ) 


	insert into #PARAM values(@NORME_CF, "NORME",str_replace(@NORME_CF,"EBSE","EBS" ))
	

	insert into #PARAM values(@NORME_CF, "PARM_PSTOMGEND17_D",convert(varchar(8),@PARM_PSTOMGEND17_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_PSTOMGCONEND_D",convert(varchar(8),@PARAM_PSTOMGCONEND_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_EBSPSTOMGCONEND_D",convert(varchar(8),@PARAM_EBSPSTOMGCONEND_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_PSTOMGCONEND17_D",convert(varchar(8),@PARAM_PSTOMGCONEND17_D,112))

	insert into #PARAM values(@NORME_CF, "PARM_PSTOMGEN_PREV_D",convert(varchar(8),@PARM_PSTOMGEN_PREV_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_EBSPSTOMGEN_PREV_D",convert(varchar(8),@PARM_EBSPSTOMGEN_PREV_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_PSTOMGEND17_PREV_D",convert(varchar(8),@PARM_PSTOMGEND17_PREV_D,112))

	insert into #PARAM values(@NORME_CF, "PARM_BOOKINGNEXT_D",convert(varchar(8),@PARM_BOOKINGNEXT_D,112))

	insert into #PARAM values(@NORME_CF, "PARM_DBCLO_MAX_D",convert(varchar(8),@PARM_DBCLO_MAX_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_ID_NF",convert(varchar,@ID_NF) )
	insert into #PARAM values(@NORME_CF, "PARM_VRS_NF",convert(varchar,@VRS_NF))
	insert into #PARAM values(@NORME_CF, "PARM_ID_NF_AOC",convert(varchar,@ID_NF_AOC) )
	insert into #PARAM values(@NORME_CF, "PARM_VRS_NF_AOC",convert(varchar,@VRS_NF_AOC))

	insert into #PARAM values(@NORME_CF, "PARM_FTECLED",substring(@CLOTYP_CT,1,1) ) -- = "I" si INV , "P" si POS ou POC
	insert into #PARAM values(@NORME_CF, "PARM_REQCOD_CT",@REQCOD_CT)
	insert into #PARAM values(@NORME_CF, "PARM_IS_COMPTA",@PARM_IS_COMPTA) 

	if @CLOTYP_CT = "INV" 
		insert into #PARAM values(@NORME_CF, "PARM_TYPEINV2","INV")
	else
		insert into #PARAM values(@NORME_CF, "PARM_TYPEINV2","PO")
		
	 
	if ( (( @NORME_CF = "EBSE" OR @NORME_CF like "I17%" ) and @CLOTYP_CT ="INV" ) OR @NORME_CF = "I17S")
	BEGIN
	  insert into #PARAM values(@NORME_CF, "PARM_INVCONSO_D",convert(varchar(8),@ICLODAT_D,112))
	  insert into #PARAM values(@NORME_CF, "PARM_CONSOMTH",convert(varchar,datepart(MONTH,@ICLODAT_D)) )
	  insert into #PARAM values(@NORME_CF, "PARM_CONSOYEA",convert(varchar,datepart(YEAR,@ICLODAT_D)))
	END
	else
	BEGIN
	  insert into #PARAM values(@NORME_CF, "PARM_INVCONSO_D",convert(varchar(8),dateadd(day, -1, dateadd(month, 1,convert( datetime, ( convert(varchar, @Last_BLCSHTYEA_NF*10000+@Last_BLCSHTMTH_NF*100+1) )))),112)) -->20220331 
	  insert into #PARAM values(@NORME_CF, "PARM_CONSOMTH",convert(varchar,@Last_BLCSHTMTH_NF))
	  insert into #PARAM values(@NORME_CF, "PARM_CONSOYEA",convert(varchar,@Last_BLCSHTYEA_NF))
	END

	insert into #PARAM values(@NORME_CF, "PARM_SEGTYP_CT","A")
	 
	 

	insert into #PARAM values(@NORME_CF, "CLOPRD",@CLOPRD)
	insert into #PARAM values(@NORME_CF, "PARAM_IS_SAP_POSTING",@PARAM_IS_SAP_POSTING)
	insert into #PARAM values(@NORME_CF, "PARM_IS_SAP_POSTING",@PARM_IS_SAP_POSTING)
	insert into #PARAM values(@NORME_CF, "PARM_BALSHEYEA_NF",convert(varchar,@BALSHEYEA_NF))
	insert into #PARAM values(@NORME_CF, "PARM_BLCSHTYEA_NF",convert(varchar,@BALSHEYEA_NF))
	insert into #PARAM values(@NORME_CF, "PARM_BALSHTYEA_NF",convert(varchar,@BALSHEYEA_NF))
	insert into #PARAM values(@NORME_CF, "PARM_BALSHTMTH_NF",convert(varchar,@BALSHTMTH_NF))
	insert into #PARAM values(@NORME_CF, "PARM_BLCSHTMTH_NF",convert(varchar,@BALSHTMTH_NF))
	insert into #PARAM values(@NORME_CF, "PARM_CLODAT_D",convert(varchar(8),@CLODAT_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_NEXT_ICLODAT_D", convert(varchar(8),dateadd(day,-1,dateadd(month,3,dateadd(day,1,@ICLODAT_D))),112))
	insert into #PARAM values(@NORME_CF, "PARM_ICLODAT_D",convert(varchar(8),@ICLODAT_D,112))
	--[022]
	insert into #PARAM values(@NORME_CF, "PARM_ICLODAT_1_D",convert(varchar(8),dateadd(day,-1,dateadd(month,-3,dateadd(day,1,@ICLODAT_D))),112))
	insert into #PARAM values(@NORME_CF, "PARM_ICLODAT_2_D",convert(varchar(8),dateadd(day,-1,dateadd(month,-6,dateadd(day,1,@ICLODAT_D))),112))
	--[022] END 
	insert into #PARAM values(@NORME_CF, "PARM0_CLODAT_D",convert(varchar(8),@CLODAT_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_BOOKINGPREV_D",convert(varchar(8),@PARM_BOOKINGPREV_D,112))
	insert into #PARAM values(@NORME_CF, "PARM0_ICLODAT_D",convert(varchar(8),@ICLODAT_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_ICLODAT_QTR",convert(varchar,(datepart(mm,@ICLODAT_D) -1) /3 +1))
	insert into #PARAM values(@NORME_CF, "PARM_ICLODAT_YEA",convert(varchar,datepart(YY,@ICLODAT_D)))
	insert into #PARAM values(@NORME_CF, "TYPEINV",@CLOTYP_CT)
	insert into #PARAM values(@NORME_CF, "PARM_TYPEINV",@CLOTYP_CT)
	insert into #PARAM values(@NORME_CF, "PARM_CRE_D",convert(varchar(8),@p_CRE_D,112))
	insert into #PARAM values(@NORME_CF, "PARM0_CRE_D",convert(varchar(8),@p_CRE_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_PREV_ICLODAT_D",convert(varchar(8),dateadd(day,-1,dateadd(month,-3,dateadd(day,+1,@ICLODAT_D))),112))
	insert into #PARAM values(@NORME_CF, "PARM_BOOKING_D",convert(varchar(8),@PARM_BOOKING_D,112))
	--insert into #PARAM values(@NORME_CF, "PARM_INVCONSO_D",convert(varchar(8),dateadd(day, -1, dateadd(month, 1,convert( datetime, ( convert(varchar, @Last_BLCSHTYEA_NF*10000+@Last_BLCSHTMTH_NF*100+1) )))),112))
	insert into #PARAM values(@NORME_CF, "PARM_DBCLO_D",convert(varchar(8),@PARM_DBCLO_D		,112))
	insert into #PARAM values(@NORME_CF, "PARM_ENCONSO_D",convert(varchar(8),@PARM_ENCONSO_D  	,112))
	insert into #PARAM values(@NORME_CF, "PARM_EBSPSTOMGEN_D",convert(varchar(8),@PARM_EBSPSTOMGEN_D 	,112))
	insert into #PARAM values(@NORME_CF, "PARM_PSTOMGEN_D",convert(varchar(8),@PARM_PSTOMGEN_D		,112))
	--insert into #PARAM values(@NORME_CF, "PARM_CONSOMTH",convert(varchar,@Last_BLCSHTMTH_NF))
	--insert into #PARAM values(@NORME_CF, "PARM_CONSOYEA",convert(varchar,@Last_BLCSHTYEA_NF))
	insert into #PARAM values(@NORME_CF, "PARM_RETTHRESHOLD_R ","0.01" )
	insert into #PARAM values(@NORME_CF, "PARM_PERTYP_CT",@PARM_PERTYP_CT)
	insert into #PARAM values(@NORME_CF, "PARM_CLOTYP_CT",@PARM_CLOTYP_CT)
	insert into #PARAM values(@NORME_CF, "PARM_BATCHUSER",LOWER(@PARM_BATCHUSER))
	insert into #PARAM values(@NORME_CF, "PARM0_BATCHUSER",LOWER(@PARM_BATCHUSER))
	insert into #PARAM values(@NORME_CF, "Last_BLCSHTYEA_NF",convert(varchar,@Last_BLCSHTYEA_NF))
	insert into #PARAM values(@NORME_CF, "Last_BLCSHTMTH_NF",convert(varchar,@Last_BLCSHTMTH_NF))
	--Insert Into #PARAM Values(@NORME_CF, "PARAM_EU_SSD_LIST",@PARAM_EU_SSD_LIST                 )    
	--Insert Into #PARAM Values(@NORME_CF, "PARAM_AM_SSD_LIST",@PARAM_AM_SSD_LIST                 )    
	--Insert Into #PARAM Values(@NORME_CF, "PARAM_AS_SSD_LIST",@PARAM_AS_SSD_LIST                 )    
	Insert Into #PARAM Values(@NORME_CF, "EST_SORT_CONDITION",@EST_SORT_CONDITION                 ) 
	Insert Into #PARAM Values(@NORME_CF, "EST_SORT_CONDITION_AS",@EST_SORT_CONDITION_AS                 ) 
	Insert Into #PARAM Values(@NORME_CF, "EST_SORT_CONDITION_EU",@EST_SORT_CONDITION_EU                 ) 
	Insert Into #PARAM Values(@NORME_CF, "EST_SORT_CONDITION_AM",@EST_SORT_CONDITION_AM                 ) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_LSTCLODAT_LL",'_'                ) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_SSDVRS_LL",'_'                 ) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_SSDDEL_LL",'_'                 ) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_ISSDCLO_LL",@PARM_ISSDCLO_LL)
	Insert Into #PARAM Values(@NORME_CF, "PARM_SSDCLO_LL",@PARM_ISSDCLO_LL)
	Insert Into #PARAM Values(@NORME_CF, "PARM_SEQ_MODE",@SeqMode) 
	Insert Into #PARAM Values(@NORME_CF, "PARAM_IS_TRIM",@PARAM_IS_TRIM) 
	Insert Into #PARAM Values(@NORME_CF, "PARAM_IS_YEARLY",@PARAM_IS_YEARLY) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_IS_TRIM",@PARAM_IS_TRIM) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_IS_YEARLY",@PARM_IS_YEARLY) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_IS_COMPTATEC_TRIM",@PARM_IS_COMPTATEC_TRIM) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_IS_COMPTATEC_YEARLY",@PARM_IS_COMPTATEC_YEARLY) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_IS_COMPTATEC_YEARLY_POS",@PARM_IS_COMPTATEC_YEARLY_POS) 
	Insert Into #PARAM Values(@NORME_CF, "PARM_POSX",@PARM_POSX) 
	insert into #PARAM values(@NORME_CF, "PARAM_CUR_PSTOMGEND17_D",convert(varchar(8),@PARAM_CUR_PSTOMGEND17_D,112))
	insert into #PARAM values(@NORME_CF, "PARM_PSTOMGEND17_POSX_D",convert(varchar(8),@PARM_PSTOMGEND17_POSX_D,112))
	insert into #PARAM values(@NORME_CF, "PARAM_CUR_BOOKING_D",convert(varchar(8),@PARAM_CUR_BOOKING_D,112))
	  

    

	--Insert Into #PARAM Values("GLOBAL", "PARM_GLOB_"+@NORME_CF+"_ICLODAT_D ",convert(varchar(8),@ICLODAT_D,112)) 
	--Insert Into #PARAM Values("GLOBAL", "PARM_GLOB_"+@NORME_CF+"_TYPEINV ",@CLOTYP_CT) 



	Fetch curs_TREQJOBPLAN Into  	@BALSHEYEA_NF,
									@BALSHTMTH_NF,
									@CLODAT_D,
									@ICLODAT_D,
									@CLOTYP_CT,
									@NORME_CF,
									@REQCOD_CT,
									@ID_NF , 
									@VRS_NF 
End

-- 017
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_BOOKING_D'  ) where norme = "I17S" and parm = 'PARM_BOOKING_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_BOOKINGNEXT_D'  ) where norme = "I17S" and parm = 'PARM_BOOKINGNEXT_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_BOOKINGPREV_D'  ) where norme = "I17S" and parm = 'PARM_BOOKINGPREV_D' 

update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_EBSPSTOMGCONEND_D'  ) where norme = "I17S" and parm = 'PARM_EBSPSTOMGCONEND_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_EBSPSTOMGEN_D'  ) where norme = "I17S" and parm = 'PARM_EBSPSTOMGEN_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_EBSPSTOMGEN_PREV_D'  ) where norme = "I17S" and parm = 'PARM_EBSPSTOMGEN_PREV_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_ENCONSO_D'  ) where norme = "I17S" and parm = 'PARM_ENCONSO_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_PSTOMGCONEND_D'  ) where norme = "I17S" and parm = 'PARM_PSTOMGCONEND_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_PSTOMGCONEND17_D'  ) where norme = "I17S" and parm = 'PARM_PSTOMGCONEND17_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_PSTOMGEN_D'  ) where norme = "I17S" and parm = 'PARM_PSTOMGEN_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_PSTOMGEN_PREV_D'  ) where norme = "I17S" and parm = 'PARM_PSTOMGEN_PREV_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_PSTOMGEND17_D'  ) where norme = "I17S" and parm = 'PARM_PSTOMGEND17_D' 
update #PARAM set value = (select value from #PARAM    where norme = "I17G" and parm = 'PARM_PSTOMGEND17_PREV_D'  ) where norme = "I17S" and parm = 'PARM_PSTOMGEND17_PREV_D' 




-- 017 END  	  

Close curs_TREQJOBPLAN 
Deallocate Cursor curs_TREQJOBPLAN 

--insert into #PARAM values("GLOBAL", "PARM_CRE_D",convert(varchar(8),@p_CRE_D,112))
--insert into #PARAM values("GLOBAL", "PARM0_CRE_D",convert(varchar(8),@p_CRE_D,112))
insert into #PARAM Values("GLOBAL", "PARM_I4I_ICLODAT_D",convert(varchar(8),@PARM_I4I_ICLODAT_D,112)) 
insert into #PARAM values("GLOBAL", "PARM_EBS_ICLODAT_D",convert(varchar(8),@PARM_EBS_ICLODAT_D,112))

if @PARM_I4I_ICLODAT_D = NULL or  @PARM_EBS_ICLODAT_D = NULL 
	insert into #PARAM Values("GLOBAL", "PARM_IS_PARALLEL_RUN","N") 
else 
	if @PARM_I4I_ICLODAT_D  =  @PARM_EBS_ICLODAT_D  
		insert into #PARAM Values("GLOBAL", "PARM_IS_PARALLEL_RUN","Y") 
	else  
		insert into #PARAM Values("GLOBAL", "PARM_IS_PARALLEL_RUN","N")

select str_replace(norme,"EBSE","EBS" ), parm  , isnull(value,"?") from #PARAM order by 1,2

drop table #PARAM 

return 0
go
   

/*
 * fin de la procedure
 */


IF OBJECT_ID('dbo.PsIfrs17Param_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsIfrs17Param_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsIfrs17Param_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsIfrs17Param_02
 */
GRANT EXECUTE ON dbo.PsIfrs17Param_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsIfrs17Param_02 TO GDBBATCH
go 
