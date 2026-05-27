USE BEST
go
/*
 * Création de la Procédure */
IF OBJECT_ID('dbo.PsIfrs17Param_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsIfrs17Param_01
    IF OBJECT_ID('dbo.PsIfrs17Param_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsIfrs17Param_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsIfrs17Param_01 >>>'
END
go 
Create Procedure PsIfrs17Param_01 ( @p_CRE_D                 UUPD_D)
with execute as caller as




/***************************************************
Programme                : PsIfrs17Param_01
Fichier script associé   : BEST_PsIfrs17Param_01.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : M.NAJI 
Date de creation         : 29/01/2019
Description du programme : Extraction des paramètres pour les chaines 
Parametres               : @p_CRE_D                 UUPD_D,
                          
BEST.. PsIfrs17Param_01 '20190123'
_____________________________________________________
[001] 27/08/2019 R. Cassis  :Spira:80734 Mise à niveau des ICLODAT pour éviter les confusions
[002] 07/01/2020 M. NAJI  	:Spira:83904 Générer les PARM même sans EBS
[003] 11/05/2020 M.NAJI		:Spira:83904 correction specend_d par account_d 

*****************************************************/
Declare @erreur          Int,
        @CLODAT0         Char(8),
        @SSD_CF          Tinyint,
        @REQCOD_CT       Char(1),
        @CLODATPRE_D     Datetime,
        @CLODATPRE       Char(8),
        @VRS_NF          Numeric(10),
        @ISSDCLO_LL      Varchar(50),
        @SSDVRS_LL       Varchar(50),
        @ICLODAT_D       Char(8),
        @CLOTYP_B        Bit,
        @CLOTYP_CT       Char(1),
        @i               Tinyint,
        @CLOEXIST_CT     Bit,
        @SSDPLAN_LL      Varchar(50),        -- MOD001--
        @CLOPER_LS       Varchar(64),        -- MOD001, MOD002,  [SPOT15758]
        @LAUNCH_D        Datetime,           -- MOD004
        @EPOPEOP         Bit,                -- MOD005
        @p_SSDESPLAN_LL  Varchar(50),        -- [014]
        @p_EXEPLAN       int,            -- [101] EXE Year Number
        @p_VSRPLAN       int,            -- [101] Plan Number
        @p_COMPTA_MENS   BIT,                 -- [015]
        @SETTLEMENT_cf   Char(4),
        @TECHNICAL_cf    Char(4),
        @BLCSHTYEALOC_NF Smallint,      -- [104]
        @BLCSHTMTHLOC_NF tinyint,       -- [104]
        @LOCALTYPE_CF    char(3)        -- [104]
		
declare   @p_BLCSHTYEA_NF          Smallint ,
		@p_BLCSHTMTH_NF          Tinyint,
		@p_SPCEND_D              Char(8),
		@p_ACCOUNT_D             Char(8),
		@p_CLODAT_D              Char(8),
		@p_DBCLO_D               Char(8),
		@p_PERTYP_CT             Char(1),
		@p_CLODATMAX_D           Char(8),
		@p_SSDACC_LL             Varchar(50),
		@p_SSDULT_LL             Varchar(50),
		@p_SSDDEL_LL             Varchar(50),
		@p_LSTCLODAT_LL          Varchar(150),
		@p_VRSULT_LL             Varchar(50),
		@p_SSDCLO_LL             Varchar(50),
		@p_SSDPEOP_LL            Varchar(50),
		@p_BOOKING_D             Char(8),        
		@p_PSTOMGEN_D            Char(8),      
		@p_ENCONSO_D             Char(8),       
		@P_DateInventaireConso   char(8),       
		@P_PeriodeConsoAA        Numeric(4,0), 
		@P_PeriodeConsoMM        Numeric(2,0),
		@P_DateInventaireService Char(8),        
		@P_PeriodeServiceAA      Numeric(4,0), 
		@P_PeriodeServiceMM      Numeric(2,0),
		@P_SuffixeTable          Char(1),
		@P_EBSPSTOMGEN_D 		char(08),
		@P_LSTPSTOMGEN_D 		char(08),		
		@P_Booking17_D           Char(8),
		@P_PsTomGen17_D          Char(8),
		@P_EnConso17_D           Char(8)
Declare  @Last_BLCSHTYEA_NF  int,            -- Dernière Comptabilisation : Année
            @Last_BLCSHTMTH_NF  int  ,         -- Dernière Comptabilisation : Mois
             @Last_PSTOMGEND_D   DateTime,       -- Dernière Comptabilisation : Date Fin Saisie Post Omega Social
            @Last_EBSPSTOMGEND_D   DateTime,     -- Dernière Comptabilisation : Date Fin Saisie Post Omega Social EBS	[23390]
			@Last_PSTOMGEND17_D		DateTime,
			@Last_PSTOMGCONEND17_D		DateTime
            	
   
select 		
		@p_BLCSHTYEA_NF       = 0    ,
		@p_BLCSHTMTH_NF       = 0    ,
		@p_SPCEND_D            = '?'  ,
		@p_ACCOUNT_D          = '?'  ,
		@p_CLODAT_D            = '?'  ,
		@p_DBCLO_D              = '?'  ,
		@p_PERTYP_CT             ='?'  ,
		@p_CLODATMAX_D        = '?'  ,
		@p_SSDACC_LL             = '?'  ,
		@p_SSDULT_LL            = '?'  ,
		@p_SSDDEL_LL            = '?'  ,
		@p_LSTCLODAT_LL       = '?'  ,
		@p_VRSULT_LL            = '?'  ,
		@p_SSDCLO_LL             = '?'  ,
		@p_SSDPEOP_LL            = '?'  ,
		@p_BOOKING_D          = '?'  ,
		@p_PSTOMGEN_D         = '?'  ,
		@p_ENCONSO_D           = '?'  ,
		@P_DateInventaireConso  = '?'  ,
		@P_PeriodeConsoAA        = 0    ,
		@P_PeriodeConsoMM      = 0    ,
		@P_DateInventaireService  = '?'  ,
		@P_PeriodeServiceAA       = 0    ,
		@P_PeriodeServiceMM     = 0    ,
		@P_SuffixeTable          = '?'  ,
		@P_EBSPSTOMGEN_D 	     = '?'	,
		@P_LSTPSTOMGEN_D 		 = '?'	,
		@P_Booking17_D           = '?'	,
		@P_PsTomGen17_D            = '?'	,
		@P_EnConso17_D            = '?'	
		
declare   @Booking_D DateTime,               -- Date de Booking T-1
         	@PsTomGen_D DateTime,              -- Date de Fin de Saisie Post Omega Social (Periode T)
         	@EnConso_D DateTime,                -- Date de Fin de Saisie Ecritures Conso (Periode T)
         	@EBSPsTomGen_D DateTime,   			  -- Date de Fin de Saisie Post Omega Social (Periode T) [23390]
			@PsTomGen17_D DateTime,
			@EnConso17_D DateTime

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output
if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end


/*****************************************************************************************
    Extraction des paramêtres fixes pour tous les inventaires
*******************************************************************************************/
/*Execute PsREQJOB_03 @p_CRE_D,@site_cf,
                    @p_BLCSHTYEA_NF     OUTPUT,
                    @p_BLCSHTMTH_NF     OUTPUT,
                    @p_SPCEND_D         OUTPUT,
                    @p_ACCOUNT_D        OUTPUT,
                    @p_CLODAT_D         OUTPUT,
                    @p_DBCLO_D          OUTPUT,
                    @p_PERTYP_CT        OUTPUT,
                    @p_CLODATMAX_D      OUTPUT

Select @erreur= @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End
*/

	Select
	 @p_BLCSHTYEA_NF = A.blcshtyea_nf
	,@p_BLCSHTMTH_NF = A.blcshtmth_nf
	,@p_SPCEND_D = convert(char(8),A.specend_d,112)
	,@p_ACCOUNT_D = A.account_d
	--,@p_closing_b = A.closing_b
	from BREF..TCALEND A
	where ((A.blcshtyea_nf * 100) + A.blcshtmth_nf)=(select min((B.blcshtyea_nf * 100) + B.blcshtmth_nf)
												from BREF..TCALEND B where convert(Char(10),B.account_d,112) >= convert(Char(10),@p_CRE_D,112)) -- [003]

	select @p_CLODAT_D = convert(char(6),@p_BLCSHTYEA_NF*100 +  @p_BLCSHTMTH_NF) + '01'
	select @p_CLODAT_D = convert(char(8),dateadd(dd,-1,dateadd(mm,1,@p_CLODAT_D)),112)


	select @p_PERTYP_CT = "H"
	select @p_DBCLO_D   = convert(char(8),@p_CRE_D,112)

	if @p_DBCLO_D > @p_SPCEND_D
	begin
		select @p_PERTYP_CT = "S"
		select @p_DBCLO_D  = @p_SPCEND_D
	end


	select
		@p_CLODATMAX_D = convert(char(8),max(CLODAT_D),112)
	from  BEST..TREQJOBPLAN
	where CLODAT_D >= @p_CLODAT_D
	and   BALSHTMTH_NF = @p_BLCSHTMTH_NF
	and   LAUNCH_D is null
	and   reqcod_ct in ('I','J','L','D','E','T','Y')  -- [005] [102]
	and   SITE_CF = @site_cf
	--------------------------------------------------------------------
	print '==> @p_CLODATMAX_D 1 = %1!', @p_CLODATMAX_D
	--------------------------------------------------------------------

	-- [006]
	if @p_CLODATMAX_D = null
	Begin
	   select
	   @p_CLODATMAX_D = convert(char(8),max(CLODAT_D),112)
	  from BEST..TREQJOB
	   where CLODAT_D >= @p_CLODAT_D and LAUNCH_D is null and reqcod_ct in ('I','J','L', 'T','Y')          -- Ajout Demande Type T [102]
	  and SITE_CF = @site_cf
	END  
	--------------------------------------------------------------------
	print '==> @p_CLODATMAX_D 2 = %1!', @p_CLODATMAX_D
	--------------------------------------------------------------------


/*****************************************************************************************
    Extraction des parametres fixes pour tous les inventaires (post omega)
*******************************************************************************************/
/*Declare  @P_Erreur   int        -- CodeRetour Erreur pour Message Appli

print '====> Avant  PtREQJOB_05 => @P_Booking_D = %1!', @P_Booking_D

Execute PtREQJOB_05 @p_CRE_D,@site_cf,
                    @P_Booking_D             OUTPUT,      -- Date de Booking T-1
                    @P_PsTomGen_D            OUTPUT,      -- Date de Fin de Saisie Post Omega Social (Periode T)
                    @P_EnConso_D             OUTPUT,      -- Date de Fin de Saisie Ecritures Conso (Periode T)
                    @P_DateInventaireConso   OUTPUT,      -- Periode AAAAMM Pour Saisie Ecriture Conso & Social (Periode T-1)
                    @P_PeriodeConsoAA        OUTPUT,      -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
                    @P_PeriodeConsoMM        OUTPUT,      -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
                    @P_DateInventaireService OUTPUT,      -- Periode AAAAMM Pour Saisie Ecriture Services (Periode T)
                    @P_PeriodeServiceAA      OUTPUT,      -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
                    @P_PeriodeServiceMM      OUTPUT,      -- Periode MM Pour Saisie Ecriture Services (Periode T)
                    @P_SuffixeTable          OUTPUT,
                    @P_Erreur                OUTPUT,       -- CodeRetour Erreur pour Message Appli
                    @P_EBSPsTomGen_D         OUTPUT,       -- Date de Fin de Saisie Post Omega Social EBS (Periode T) [23390]
					@P_Booking17_D	         OUTPUT,       
					@P_PsTomGen17_D          OUTPUT,
					@P_EnConso17_D           OUTPUT
print '====> Après PtREQJOB_05 => @P_Booking_D = %1!', @P_Booking_D
Select @erreur= @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End
*/



Select @Last_PSTOMGEND_D = Null
-- Selection Dates du Dernier Closing
Select --@Last_SPECEND_D = SPECEND_D,
         --@Last_ACCOUNT_D = ACCOUNT_D,
         @Last_PSTOMGEND_D = PSTOMGEND_D
         ,@Last_EBSPSTOMGEND_D = EBSPSTOMGEND_D	 --[23390]
		 ,@Last_PSTOMGEND17_D = PSTOMGEND17_D
		 ,@Last_PSTOMGCONEND17_D = PSTOMGCONEND17_D
FROM BREF..TCALEND
WHERE BLCSHTYEA_NF = @Last_BLCSHTYEA_NF
    and BLCSHTMTH_NF = @Last_BLCSHTMTH_NF
    and Closing_B = 1

Select @Last_BLCSHTYEA_NF = Max(BALSHEYEA_NF)      -- MOD002 @Last_BLCSHTYEA_NF = Max(BALSHEYEA_NF),
FROM BEST..TREQJOB
WHERE REQCOD_CT   = 'B'
    and LAUNCH_D <= @p_CRE_D
    and SSD_CF    = 99
    and SITE_CF   = @site_cf

Select @Last_BLCSHTMTH_NF = Max(BALSHTMTH_NF)
FROM BEST..TREQJOB
WHERE REQCOD_CT      = 'B'
    and LAUNCH_D     <= @p_CRE_D
    and SSD_CF       = 99
    and BALSHEYEA_NF = @Last_BLCSHTYEA_NF
    and SITE_CF      = @site_cf

Select  @Booking_D  = @p_CRE_D
--Select @PsTomGen_D

Select @Booking_D = LAUNCH_D,
          @P_SuffixeTable = LEFT(CLOPER_LS, 1),
          @p_DateInventaireConso  = Convert(char(8), VRS_NF)
FROM BEST..TREQJOB
WHERE REQCOD_CT            = 'B'
    and LAUNCH_D          <= @p_CRE_D
    and SSD_CF             = 99
    and @Last_BLCSHTYEA_NF = BALSHEYEA_NF
    and @Last_BLCSHTMTH_NF = BALSHTMTH_NF
    and SITE_CF            = @site_cf

-- ==========================================================
-- Pour La Récupération de la Date de Fin de Saisie Post Omega Social   - PSTOMGEND_D
-- ==========================================================
-- Si la Date au niveau du Dernier Booking est Correctement Défini, on prend cette Date (PSTOMGEND_D Last)
-- Autrement, on Prend (Période Exceptionnel Date Dernier Booking + 3 Mois)
If (@Last_PSTOMGEND_D != Null)
	begin
         Select @PsTomGen_D = @Last_PSTOMGEND_D
         Select @EBSPsTomGen_D = @Last_EBSPSTOMGEND_D	--[23390]
         Select @PsTomGen17_D = @Last_PSTOMGEND17_D
         Select @EnConso17_D = @Last_PSTOMGCONEND17_D
    end
Else
    Begin
        Select @erreur = 2105             -- Periode PostOmega Social non Défini dans TCALEND
  --    Goto ErreurNom
    End




Select @P_Booking_D = Convert(Char(8), @Booking_D, 112)
Select @P_PsTomGen_D = Convert(Char(8), @PsTomGen_D, 112)
Select @P_EnConso_D  = Convert(Char(8), @EnConso_D, 112)
Select @P_EBSPsTomGen_D = Convert(Char(8), @EBSPsTomGen_D, 112) --[23390]
Select @P_Booking17_D = Convert(Char(8), @Booking_D, 112)
Select @P_PsTomGen17_D = Convert(Char(8), @PsTomGen17_D, 112)
Select @P_EnConso17_D  = Convert(Char(8), @EnConso17_D, 112)

-- ===================================================
-- Récupération de la Periode PostOmega Social/Conso
-- ===================================================
-- Cette Période Correspond à la Dernière Période de Comptabilisation
Select @p_PeriodeConsoAA = @Last_BLCSHTYEA_NF               -- Periode T-1
Select @p_PeriodeConsoMM =@Last_BLCSHTMTH_NF               -- Periode T-1

Declare @V_PeriodeService numeric(6,0)
Declare @Diff_Day int, @TmpDay int

-- Détermination Dernier Date du Mois pour @DateInventaireService
Select @p_PeriodeServiceAA = @p_blcshtyea_nf               -- Periode T-1
Select @p_PeriodeServiceMM = @p_blcshtmth_nf               -- Periode T-1
Select @V_PeriodeService = (@p_PeriodeServiceAA * 100 ) + @p_PeriodeServiceMM               -- Periode T-1
Select @TmpDay = (case when @p_blcshtmth_nf IN (1, 3, 5, 7, 8, 10, 12) then 31 
                       when @p_blcshtmth_nf IN (4, 6, 9, 11) then 30  
                       when @p_blcshtmth_nf IN (2) then 28 + @Diff_Day 
                       else 0 end)

Select @p_DateInventaireService = Convert(char(6), @V_PeriodeService)  + Convert(char(2), @TmpDay)


Select @EPOPEOP = 0

Select @EPOPEOP = 1
From BEST..TREQJOB
Where LAUNCH_D Is Null
  And REQCOD_CT in ('T','Y')  --[104]
  and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site 

--------------------------------------------------------------------
print '==> @EPOPEOP = %1!', @EPOPEOP
--------------------------------------------------------------------  

-- [014] Ecritures service PLAN
/*****************************************************************************************
 Calcul de @p_SSDESPLAN_LL
 ****************************************************************************************/
Declare cur_esplan Cursor For Select Distinct SSD_CF
                              From BEST..TREQJOB
                              Where REQCOD_CT = 'A'
                                And LAUNCH_D Is NULL
                                and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site
                              Order By SSD_CF

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End

Select @p_SSDESPLAN_LL = '_'


-- [101] Start ----------------------------


select @p_EXEPLAN = YEAR(getdate()) -- Pour eviter l'absence de valeur
select @p_VSRPLAN = MONTH(getdate()) -- Pour eviter l'absence de valeur
select @p_EXEPLAN = convert(int,isnull(substring(convert(char(6),VRS_NF),1,4), convert(char(4),BALSHEYEA_NF))), 
       @p_VSRPLAN = convert(int,isnull(substring(convert(char(6),VRS_NF),5,2), convert(char(2),BALSHTMTH_NF)))
                              From BEST..TREQJOB
                              Where REQCOD_CT = 'A'
                                and convert(char(8),DBCLO_D, 112) <= convert(char(8),@p_CRE_D, 112)
                                and convert(char(8),DBCLO_D, 112) = (select max(DBCLO_D) from BEST..TREQJOB
                                                                     where REQCOD_CT = 'A'
                                                                     and convert(char(8),DBCLO_D, 112) <= convert(char(8),@p_CRE_D , 112)
                                                                     and SITE_CF = @site_cf)

-- [101] End -----------------------------

--------------------------------------------------------------------
print '==> @p_EXEPLAN = %1!', @p_EXEPLAN
print '==> @p_VSRPLAN = %1!', @p_VSRPLAN
--------------------------------------------------------------------  

OPEN cur_esplan
Fetch cur_esplan Into @SSD_CF

    While (@@sqlstatus = 0)
    Begin
        Select @p_SSDESPLAN_LL = @p_SSDESPLAN_LL + Convert(Varchar, @SSD_CF) + '_'

Fetch cur_esplan Into @SSD_CF
End
Close cur_esplan
Deallocate Cursor cur_esplan

--------------------------------------------------------------------
print '==> @p_SSDESPLAN_LL = %1!', @p_SSDESPLAN_LL
--------------------------------------------------------------------  

--[015] Indicateur Comptabilisation mensuelle
select @p_COMPTA_MENS = 0

select @p_COMPTA_MENS = 1
from BREF..TCALEND
where @p_CRE_D = ACCOUNT_D
  and CLOSING_B = 0

-- [012]
if @p_COMPTA_MENS = 1
   insert BTRAV..TESTSSD ( SSD_CF )
   select distinct a.ssd_cf
   from  bref..tprintb a,
         bref..tsubsid b,
         bref..TBATCHSSD c
   where a.ssd_cf = b.ssd_cf
   and   a.CRTTYP_CT = 99
   and   a.CRTVAL_LS='ESB_CF'
   and   a.SSD_CF       = c.ssd_cf
   and   c.BATCHUSER_CF = @suser_Name   -- PHP O21B ajout du controle sur le site 
   and   not exists (select 1 from BTRAV..TESTSSD t
                     where a.ssd_cf = t.ssd_cf)  -- [103]
   
--[015]									
select top 1
       @ICLODAT_D=convert(char(8), dateadd(day, -1, dateadd(month, 1, convert( datetime, ( convert(varchar, a.BLCSHTMTH_NF) +
                                                             '/01/' + convert(varchar,(a.BLCSHTYEA_NF)) ) ) ) ), 112 )
from BREF..TCALEND a
where a.ACCOUNT_D > @p_CRE_D
  and a.CLOSING_B = 1
order by a.BLCSHTYEA_NF, a.BLCSHTMTH_NF
--       @ICLODAT_D=convert(char(8), dateadd(month, 1, dateadd(day, -1, convert( datetime, ( convert(varchar, a.BLCSHTMTH_NF) +
--                                                             "/01/" +
--
select @P_LSTPSTOMGEN_D = convert(char(8),dateadd(QQ,-1,@ICLODAT_D), 112)

--------------------------------------------------------------------
print '==> @P_LSTPSTOMGEN_D = %1! @ICLODAT_D = %2!', @P_LSTPSTOMGEN_D, @ICLODAT_D
--------------------------------------------------------------------  

/*****************************************************************************************
 Calcul de @SETTLEMENT_cf
 ****************************************************************************************/
 --[102]
select @SETTLEMENT_cf = 'SIMU'
if exists ( select 1 from BEST..TREQJOBPLAN a, BREF..TCALEND b
            where a.REQCOD_CT    = 'V'
              and a.LAUNCH_D     = NULL
              and a.DBCLO_D      = @p_CRE_D
              and a.DBCLO_D      = b.SACCOUNT_D
              and a.BALSHEYEA_NF = b.BLCSHTYEA_NF
              and a.BALSHTMTH_NF = b.BLCSHTMTH_NF
              and a.SITE_CF      = @site_cf    -- PHP O21B ajout du controle sur le site 
          )
begin
    select @SETTLEMENT_cf = 'BOOK'      
end

/*****************************************************************************************
 Calcul de @TECHNICAL_cf
 ****************************************************************************************/
select @TECHNICAL_cf = 'SIMU'
-- [102]
if exists ( select 1 from BREF..TCALEND
            where ACCOUNT_D    = @p_CRE_D
              and BLCSHTYEA_NF = @p_BLCSHTYEA_NF
              and BLCSHTMTH_NF = @p_BLCSHTMTH_NF 
          )
begin
    select @TECHNICAL_cf = 'BOOK'      
end
/*
if exists ( select 1 from BEST..TREQJOBPLAN, BREF..TCALEND
            where REQCOD_CT    = 'D'
              and LAUNCH_D     = NULL
              and DBCLO_D      = @p_CRE_D
              and ACCOUNT_D    = @p_CRE_D
              and BALSHEYEA_NF = @p_BLCSHTYEA_NF
              and BALSHTMTH_NF = @p_BLCSHTMTH_NF 
              and BLCSHTYEA_NF = @p_BLCSHTYEA_NF
              and BLCSHTMTH_NF = @p_BLCSHTMTH_NF 
              and SITE_CF      = @site_cf    -- PHP O21B ajout du controle sur le site 
              )
begin
    select @TECHNICAL_cf = 'BOOK'      
end
*/

/*****************************************************************************************
 Calcul de @SSDULT_CF
 ****************************************************************************************/
Declare cur_treqjob Cursor For Select Distinct SSD_CF, VRS_NF
                               From BEST..TREQJOB
                               Where REQCOD_CT = 'S'
                                 And LAUNCH_D Is NULL
                                 and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site 
                               Order By SSD_CF

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End

Select @p_SSDULT_LL = '_0_',
       @p_VRSULT_LL = '_0_'

OPEN cur_treqjob
Fetch cur_treqjob Into @SSD_CF, @VRS_NF

While (@@sqlstatus = 0)
Begin
    Select @p_SSDULT_LL = @p_SSDULT_LL + Convert(Varchar, @SSD_CF) + '_'
    Select @p_VRSULT_LL = @p_VRSULT_LL + Convert(Varchar, @VRS_NF) + '_'

Fetch cur_treqjob Into @SSD_CF, @VRS_NF
End

Close cur_treqjob
Deallocate Cursor cur_treqjob

--------------------------------------------------------------------
print '==> @p_SSDULT_LL = %1! @p_VRSULT_LL = %2!', @p_SSDULT_LL, @p_VRSULT_LL
--------------------------------------------------------------------  


/*****************************************************************************************
   Calcul de @SSDACC_CF , @SSDPEOP_ll              MOD004
 ****************************************************************************************/
Declare curs_ssdpeop Cursor For Select Distinct SSD_CF, LAUNCH_D
                               From BEST..TREQJOB
                               Where REQCOD_CT = 'C'
                                 And CLODAT_D >= @p_CLODAT_D
                               Order By SSD_CF

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End

Select @p_SSDACC_LL = '_',
       @p_SSDPEOP_LL = '_'


Open curs_ssdpeop
Fetch curs_ssdpeop Into @SSD_CF, @LAUNCH_D

While (@@sqlstatus = 0)
Begin
    If @launch_d = NULL
    Begin
        Select @p_SSDACC_LL = @p_SSDACC_LL + Convert(Varchar, @SSD_CF) + '_'
    End

    If @launch_d Is Not Null
    Begin
        Select @p_SSDPEOP_LL = @p_SSDPEOP_LL + Convert(Varchar, @SSD_CF) + '_'
    End

Fetch curs_ssdpeop Into @SSD_CF, @LAUNCH_D
End
Close curs_ssdpeop
Deallocate Cursor curs_ssdpeop

--------------------------------------------------------------------
print '==> @p_SSDPEOP_LL = %1!', @p_SSDPEOP_LL
--------------------------------------------------------------------  

/*  fin MOD004 */
/*****************************************************************************************
 Chaine de la liste des filiales en 1er inventaire
 *****************************************************************************************/
Declare curs_ssd Cursor For Select SSD_CF
                           From BTRAV..TESTSSD
                           Order By SSD_CF
Open curs_ssd

Select @p_SSDDEL_LL    = "_",
       @p_LSTCLODAT_LL = "_"

Fetch curs_ssd Into  @SSD_CF
While (@@sqlstatus = 0)
Begin
    /* recherche de l'inventaire principal précédent l'inventaire   en cours de la filiale en 1er  */
    /* passage d'inventaire   */
    Select @CLODATPRE_D = Max(CLODAT_D)
    From BEST..TREQJOB
    Where BALSHEYEA_NF = Convert(Smallint, Substring(Convert(Char(8), CLODAT_D, 112), 1, 4))
      And BALSHTMTH_NF = Convert(Smallint, Substring(Convert(Char(8), CLODAT_D, 112), 5, 2))
      And SSD_CF = @SSD_CF
      And LAUNCH_D Is Not null
      And REQCOD_CT In ('I','J','L')
      and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site 
      
    Select @CLODATPRE = Convert(Char(8), @CLODATPRE_D, 112)
    If @CLODATPRE < @p_CLODAT_D
    Begin
        Select @p_LSTCLODAT_LL = @p_LSTCLODAT_LL  + @CLODATPRE + '_'
        Select @p_SSDDEL_LL    = @p_SSDDEL_LL     + Convert(Varchar, @SSD_CF) + '_'
    End

Fetch curs_ssd Into  @SSD_CF
End
Close curs_ssd
Deallocate Cursor curs_ssd

--------------------------------------------------------------------
print '==> @p_LSTCLODAT_LL = %1! @p_SSDDEL_LL = %2!', @p_LSTCLODAT_LL, @p_SSDDEL_LL
--------------------------------------------------------------------  


/*****************************************************************************************
 Chaine de la liste des filiales en inventaire
 *****************************************************************************************/
Declare curs_ssd Cursor For Select Distinct SSD_CF
                           From BTRAV..TESTSSD
                           Order By SSD_CF

Open curs_ssd

Select @p_SSDCLO_LL = "_",
       @CLOEXIST_CT = 0

Fetch curs_ssd into  @SSD_CF
While (@@sqlstatus = 0)
Begin
    if @p_COMPTA_MENS != 1 Select @CLOEXIST_CT = 1
    Select @p_SSDCLO_LL = @p_SSDCLO_LL + Convert(Varchar, @SSD_CF) + '_'

Fetch curs_ssd Into  @SSD_CF
End
Close curs_ssd
Deallocate Cursor curs_ssd


-- 20050901- Modif Insertion Liste des Filliales ayant demandé Inventaire
If (@EPOPEOP = 1)
Begin
    Select @p_SSDCLO_LL = Right(CLOPER_LS, DATALENGTH(CLOPER_LS) - 1)
    From BEST..TREQJOB
    Where REQCOD_CT = 'B'
      And BALSHEYEA_NF = @P_PeriodeConsoAA
      And BALSHTMTH_NF = @P_PeriodeConsoMM
      And CLODAT_D     = @P_DateInventaireConso
      and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site 
end




/*****************************************************************************************
 sélection des inventaires et fililale de TREQJOB
 *****************************************************************************************/
/*Create Table #PARAM ( lig Tinyint,
                      lib Char(20) NULL,
                      val Varchar(150) NULL )
*/
Create Table #PARAM ( var Varchar(1000) NULL )

Select @ISSDCLO_LL = '_',
       @SSDVRS_LL  = '_',
       @SSDPLAN_LL = '_'

If (Convert(Char(8), @p_CRE_D, 112) < @p_SPCEND_D)
    Select @p_DBCLO_D = Convert(Char(8), @p_CRE_D, 112)
Else
    Select @p_DBCLO_D = @p_SPCEND_D

/*****************************************************************************************
is lat day of  social compta
 *****************************************************************************************/
declare 	@ComptaSocialLastDay char(1)

Select @ComptaSocialLastDay = 'N'     -- dernier jour inventaire postomega social positionné à N par défaut [046]
If Exists ( SELECT 1 FROM BEST..TREQJOB, bref..tcalend 
            WHERE REQCOD_CT = 'T'
              and LAUNCH_D = Null
              and SITE_CF = @site_cf
              and BALSHEYEA_NF = @P_PeriodeConsoAA 
              and BALSHTMTH_NF =@P_PeriodeConsoMM
              and BALSHEYEA_NF = BLCSHTYEA_NF
              and BALSHTMTH_NF = BLCSHTMTH_NF
              and ( DBCLO_D = isnull(EBSPSTOMGEND_D,getdate()) or DBCLO_D = isnull(PSTOMGEND_D,getdate()) ) )
Begin
    Select @ComptaSocialLastDay = 'Y'     -- dernier jour inventaire postomega social [046]
End

--------------------------------------------------------------------
print '==> @PARAM_IS_LAST_DAY_COMPTA_SOCIAL = %1! ', @ComptaSocialLastDay
--------------------------------------------------------------------  
	
	
/*
If  @p_CLONUM = 0
Begin
   Insert Into #PARAM Values (1, "SSDCLO_LL",    @p_SSDCLO_LL)
    Insert Into #PARAM Values (2, "BLCSHTYEA_NF", Convert(Varchar, @p_BLCSHTYEA_NF))
    Insert Into #PARAM Values (3, "BLCSHTMTH_NF", Convert(Varchar, @p_BLCSHTMTH_NF))
    Insert Into #PARAM Values (4, "CRE_D",        Convert(Char(8), @p_CRE_D, 112))
    Insert Into #PARAM Values (5, "DBCLO_D",      @p_DBCLO_D)
    Insert Into #PARAM Values (6, "CLODAT_D",     @p_CLODAT_D)
    Insert Into #PARAM Values (7, "SPCEND_D",     @p_SPCEND_D)
    Insert Into #PARAM Values (8, "SEGTYPCLO_CT", 'A')
    Insert Into #PARAM Values (9, "PERTYP_CT",    @p_PERTYP_CT)
    Insert Into #PARAM Values (10,"ACCOUNT_D",    @p_ACCOUNT_D)

    Select @i = 11
    While (@i <= 105)		--[23390]
    Begin
        Insert Into #PARAM Values (@i, "---" + Convert(Varchar(3), @i) + "---","----")   -- [014]
        Select @i = @i + 1
    End

    Update #PARAM Set lib = "RETTHRESHOLD_R", val = '0.01'                                             where lig = 15
    Update #PARAM Set lib = "SEGTYP_CT",      val = 'A'                                                where lig = 20
    Update #PARAM Set lib = "CLOEXIST_CT",    val = IsNull(convert(char(3),@CLOEXIST_CT)  ,'---')      where lig = 21
    Update #PARAM Set lib = "CLODATMAX_D",    val = IsNull(@p_CLODATMAX_D,'---')                       where lig = 22
    Update #PARAM Set lib = "BOOKING_D",      val = IsNull(@p_BOOKING_D,'---')                         where lig = 30   --MOD05
    Update #PARAM Set lib = "PSTOMGEN_D",     val = IsNull(@p_PSTOMGEN_D,'---')                        where lig = 31   --MOD05
    Update #PARAM Set lib = "ENCONSO_D",      val = IsNull(@p_ENCONSO_D,'---')                         where lig = 32   --MOD05
    Update #PARAM Set lib = "INVCONSO_D",     val = IsNull(@P_DateInventaireConso,'---')               where lig = 33   --MOD05
    Update #PARAM Set lib = "CONSOYEA",       val = IsNull(convert(char(4),@P_PeriodeConsoAA),'---')   where lig = 34   --MOD05
    Update #PARAM Set lib = "CONSOMTH",       val = IsNull(convert(char(2),@P_PeriodeConsoMM),'---')   where lig = 35   --MOD05
    Update #PARAM Set lib = "INVSERV_D",      val = IsNull(@P_DateInventaireService,'---')             where lig = 36   --MOD05
    Update #PARAM Set lib = "SERVYEA",        val = IsNull(convert(char(4),@P_PeriodeServiceAA),'---') where lig = 37   --MOD05
    Update #PARAM Set lib = "SERVMTH",        val = IsNull(convert(char(2),@P_PeriodeServiceMM),'---') where lig = 38   --MOD05
    Update #PARAM Set lib = "SUFFTABLE",      val = IsNull(@P_SuffixeTable,'---')                      where lig = 39   --MOD05
    Update #PARAM Set lib = "UPDULTTYP_CT",   val = 'Q'                                                where lig = 40
    Update #PARAM Set lib = "SSDACC_LL",      val = IsNull(@p_SSDACC_LL ,'---')                        where lig = 60
    Update #PARAM Set lib = "SSDPEOP_LL",     val = IsNull(@p_SSDPEOP_LL ,'---')                       where lig = 70   --MOD04
    Update #PARAM Set lib = "EPOPEOP",        val = IsNull(convert(char(1), @EPOPEOP),'---')           where lig = 71   --MOD05
    Update #PARAM Set lib = "SEGTYPULT_CT",   val = 'E'                                                where lig = 80
    Update #PARAM Set lib = "SSDULT_LL",      val = IsNull(@p_SSDULT_LL  ,'---')                       where lig = 81
    Update #PARAM Set lib = "VRSULT_LL",      val = IsNull(@p_VRSULT_LL   ,'---')                      where lig = 82
    Update #PARAM Set lib = "ALLSSD_CF",      val = '99'                                               where lig = 99
    Update #PARAM Set lib = "EBSPSTOMGEN_D",  val = IsNull(@P_EBSPSTOMGEN_D,'---')                     where lig = 100	--[23390]
    Update #PARAM Set lib = "LSTPSTOMGEN_D",  val = IsNull(@P_LSTPSTOMGEN_D,'---')                     where lig = 101	--[23390]
    Update #PARAM Set lib = "ICLODAT_D",      val = IsNull(@ICLODAT_D,'---')                           where lig = 102	--[23390]
    Update #PARAM Set lib = "BATCHUSER",      val = IsNull(suser_Name(),'---')                         where lig = 103	--
    Update #PARAM Set lib = "SETTLEMENT",     val = IsNull(@SETTLEMENT_cf,'---')                       where lig = 104	--
    Update #PARAM Set lib = "TECHNICAL",      val = IsNull(@TECHNICAL_cf,'---')                        where lig = 105	--
*/
	
	insert into #PARAM values ( "export  PARM0_CRE_D="+Convert(Char(8), @p_CRE_D, 112)                                                                  )
	insert into #PARAM values ( "export  PARM0_RETTHRESHOLD_R="+'0.01'                                                                                  )
	insert into #PARAM values ( "export  PARM0_SEGTYP_CT="			 +'A'                                                                                    )
	insert into #PARAM values ( "export  PARM0_CLOEXIST_CT="		 +IsNull(convert(char(3),@CLOEXIST_CT)  ,'---')                            )
	insert into #PARAM values ( "export  PARM0_CLODATMAX_D="	 +IsNull(@p_CLODATMAX_D,'---')                                               )
	insert into #PARAM values ( "export  PARM0_BOOKING_D="		 +IsNull(@p_BOOKING_D,'---')                                                   )
	insert into #PARAM values ( "export  PARM0_PSTOMGEN_D="		 +IsNull(@p_PSTOMGEN_D,'---')                                            )
	insert into #PARAM values ( "export  PARM0_ENCONSO_D="		 +IsNull(@p_ENCONSO_D,'---')                                                  )
	insert into #PARAM values ( "export  PARM0_INVCONSO_D="		 +IsNull(@P_DateInventaireConso,'---')                                   )
	insert into #PARAM values ( "export  PARM0_CONSOYEA="			 +IsNull(convert(char(4),@P_PeriodeConsoAA),'---')                 )
	insert into #PARAM values ( "export  PARM0_CONSOMTH="		 +IsNull(convert(char(2),@P_PeriodeConsoMM),'---')                   )
	insert into #PARAM values ( "export  PARM0_INVSERV_D="			 +IsNull(@P_DateInventaireService,'---')                                  )
	insert into #PARAM values ( "export  PARM0_SERVYEA="			 	 +IsNull(convert(char(4),@P_PeriodeServiceAA),'---')                )
	insert into #PARAM values ( "export  PARM0_SERVMTH="			 +IsNull(convert(char(2),@P_PeriodeServiceMM),'---')                  )
	insert into #PARAM values ( "export  PARM0_SUFFTABLE="			 +IsNull(@P_SuffixeTable,'---' )                                                )
	insert into #PARAM values ( "export  PARM0_UPDULTTYP_CT="	 +'Q'                                                                                       )
	insert into #PARAM values ( "export  PARM0_SSDACC_LL="			 +IsNull(@p_SSDACC_LL ,'---')                                                )
	insert into #PARAM values ( "export  PARM0_SSDPEOP_LL="		 +IsNull(@p_SSDPEOP_LL ,'---')                                                  )
	insert into #PARAM values ( "export  PARM0_EPOPEOP="			 +IsNull(convert(char(1), @EPOPEOP),'---')                                  )
	insert into #PARAM values ( "export  PARM0_SEGTYPULT_CT="	 +'E'                                                                                        )
	insert into #PARAM values ( "export  PARM0_SSDULT_LL="			 +IsNull(@p_SSDULT_LL  ,'---')                                                )
	insert into #PARAM values ( "export  PARM0_VRSULT_LL="			 +IsNull(@p_VRSULT_LL   ,'---')                                               )
	insert into #PARAM values ( "export  PARM0_ALLSSD_CF="			 +'99'                                                                                  )
	insert into #PARAM values ( "export  PARM0_EBSPSTOMGEN_D=" +IsNull(@P_EBSPSTOMGEN_D,'---')                                         )
	insert into #PARAM values ( "export  PARM0_LSTPSTOMGEN_D=" +IsNull(@P_LSTPSTOMGEN_D,'---')                                          )
	insert into #PARAM values ( "export  PARM0_ICLODAT_D="			 +IsNull(@ICLODAT_D,'---')                                                    )
	insert into #PARAM values ( "export  PARM0_BATCHUSER="		 +IsNull(suser_Name(),'---')                                                        )
	insert into #PARAM values ( "export  PARM0_SETTLEMENT="		 +IsNull(@SETTLEMENT_cf,'---')                                             )
	insert into #PARAM values ( "export  PARM0_TECHNICAL="			 +IsNull(@TECHNICAL_cf,'---')                                                )
	insert into #PARAM values ( "export  PARAM_IS_LAST_DAY_COMPTA_SOCIAL="			 +IsNull(@ComptaSocialLastDay,'---')                                                )

	--End


/*If  @p_CLONUM = 1
Begin
    Declare cur_inventaire Cursor For Select SSD_CF, VRS_NF, Convert(Char(8), CLODAT1_D, 112), CLOTYP_B,
                                             Upper(CLOPER1_LS)                                      --MOD001--
                                      From BTRAV..TESTSSD
                                      Where CLODAT1_D Is Not Null
                                      Order By SSD_CF
End


If  @p_CLONUM = 2
Begin
    Declare cur_inventaire Cursor For Select SSD_CF, VRS_NF, Convert(Char(8), CLODAT2_D, 112), CLOTYP_B,
                                             Upper(CLOPER2_LS)                                      --MOD001--
                                      From BTRAV..TESTSSD
                                      Where CLODAT2_D Is Not Null
                                      Order By SSD_CF
End


If  @p_CLONUM = 3
Begin
    Declare cur_inventaire cursor for Select SSD_CF, VRS_NF, Convert(Char(8), CLODAT3_D, 112), CLOTYP_B,
                                             Upper(CLOPER3_LS)                                      --MOD001--
                                      From BTRAV..TESTSSD
                                      Where CLODAT3_D Is Not Null
                                      Order By SSD_CF
End


If  @p_CLONUM = 4
Begin
    Declare cur_inventaire Cursor For Select  SSD_CF, VRS_NF, Convert(Char(8), CLODAT4_D, 112), CLOTYP_B,
                                              Upper(CLOPER4_LS)                                     --MOD001--
                                      From BTRAV..TESTSSD
                                      Where CLODAT4_D Is Not Null
                                      Order By SSD_CF
End
*/

Declare cur_inventaire Cursor For Select  SSD_CF, VRS_NF, CLOTYP_B, Upper(CLOPER1_LS)                                     --MOD001--
                                  From BTRAV..TESTSSD
                                  Where CLODAT1_D Is Not Null
                                  Order By SSD_CF

/*
If  @p_CLONUM != 0
Begin*/
Open cur_inventaire
Fetch cur_inventaire Into @SSD_CF, @VRS_NF, @CLOTYP_B, @CLOPER_LS                   --MOD001--

If @CLOTYP_B = 1
    Select @CLOTYP_CT = 'P'
Else
    Select  @CLOTYP_CT = 'A'

While (@@sqlstatus = 0)
Begin
    Select @ISSDCLO_LL = @ISSDCLO_LL + Convert(varchar, @SSD_CF) + '_'
    Select @SSDVRS_LL  = @SSDVRS_LL  + Convert(varchar, @VRS_NF) + '_'
    If (Charindex("PLAN", @CLOPER_LS) != 0)                                                     --MOD001--
        Select @SSDPLAN_LL = @SSDPLAN_LL + Convert(Varchar,@SSD_CF) + '_'                       --MOD001--

    Fetch cur_inventaire Into @SSD_CF, @VRS_NF, @CLOTYP_B, @CLOPER_LS                   --MOD001--
End
Close cur_inventaire

if (@p_SSDCLO_LL = '_' and @p_SSDESPLAN_LL != '_') 
   select @p_SSDCLO_LL = @p_SSDESPLAN_LL

if (@ISSDCLO_LL = '_' and @p_SSDESPLAN_LL != '_') 
   select @ISSDCLO_LL = @p_SSDESPLAN_LL

--------------------------------------------------------------------
print '==> @p_SSDCLO_LL = %1! @p_SSDESPLAN_LL = %2!', @p_SSDCLO_LL, @p_SSDESPLAN_LL
--------------------------------------------------------------------  

-- [104]
Select @BLCSHTYEALOC_NF = (SELECT distinct a.BALSHEYEA_NF FROM BEST..TREQJOBPLAN a, bref..tcalend b
                             WHERE a.REQCOD_CT = 'Y'
                               and a.LAUNCH_D = Null
                               and isnull(a.VRS_Nf,0) = 0
                               and a.SITE_CF = @site_cf
                               and a.CLODAT_D = @P_DateInventaireConso
                               and datepart(yy,a.CLODAT_D) = b.BLCSHTYEA_NF
                               and datepart(mm,a.CLODAT_D) = b.BLCSHTMTH_NF
                               and DBCLO_D <= @p_CRE_D
                               and DBCLO_D <= (select min(SPECEND_D) from BREF..TCALEND c 
                                               where CLOSING_B = 1
                                               and   ACCOUNT_D > a.DBCLO_D
                                               and   ACCOUNT_D > (select max(DBCLO_D) from BEST..TREQJOB r
                                                                  where r.REQCOD_CT = 'B'
                                                                  and   a.DBCLO_D > r.DBCLO_D
                                                                  and   r.SITE_CF = @site_cf)
                                              )
                            )

--------------------------------------------------------------------
print '==> @BLCSHTYEALOC_NF = %1!', @BLCSHTYEALOC_NF
--------------------------------------------------------------------  
-- [104]
Select @BLCSHTMTHLOC_NF = (SELECT distinct a.BALSHTMTH_NF FROM BEST..TREQJOBPLAN a, bref..tcalend b
                             WHERE a.REQCOD_CT = 'Y'
                               and a.LAUNCH_D = Null
                               and isnull(a.VRS_Nf,0) = 0
                               and a.SITE_CF = @site_cf
                               and a.CLODAT_D = @P_DateInventaireConso
                               and datepart(yy,a.CLODAT_D) = b.BLCSHTYEA_NF
                               and datepart(mm,a.CLODAT_D) = b.BLCSHTMTH_NF
                               and DBCLO_D <= @p_CRE_D
                               and DBCLO_D <= (select min(SPECEND_D) from BREF..TCALEND c 
                                               where CLOSING_B = 1
                                               and   ACCOUNT_D > a.DBCLO_D
                                               and   ACCOUNT_D > (select max(DBCLO_D) from BEST..TREQJOB r
                                                                  where r.REQCOD_CT = 'B'
                                                                  and   a.DBCLO_D > r.DBCLO_D
                                                                  and   r.SITE_CF = @site_cf)
                                              )
                            )
--------------------------------------------------------------------
print '==> @BLCSHTMTHLOC_NF = %1!', @BLCSHTMTHLOC_NF
--------------------------------------------------------------------  

-- [104]
if (@BLCSHTYEALOC_NF is not null and @BLCSHTMTHLOC_NF is not null)
begin                                
	if (@BLCSHTYEALOC_NF*100+@BLCSHTMTHLOC_NF) > (@P_PeriodeConsoAA*100+@P_PeriodeConsoMM)
	   select @LOCALTYPE_CF = 'MTH'
	else
	   select @LOCALTYPE_CF = 'QTR'
end

--------------------------------------------------------------------
--- constructions des listes des filiales  pour chaque site
-------------------------------------------------------------------- 


declare  curs_ssd cursor for
select distinct  A.ssd_cf, B.BATCHUSER_CF, A.repname_cf 
from  BREF..TFTPB A, BREF..TBATCHNIGHT B
where A.PRDSIT_CF = B.PRDSIT_CF
and   B.BATCHUSER_CF in ( 'ubeu','ubam','ubas')
and   A.repname_cf in('new-york','singapore','local')

declare @ssd tinyint , @user varchar(10) ,   @site varchar(32) , @PARAM_EU_SSD_LIST varchar(1000) 
declare @PARAM_AM_SSD_LIST varchar(1000) , @PARAM_AS_SSD_LIST varchar(1000) 

select @PARAM_EU_SSD_LIST ='(1=1' ,@PARAM_AM_SSD_LIST = '(1=1' , @PARAM_AS_SSD_LIST =  '(1=1'

OPEN curs_ssd

fetch curs_ssd into @ssd, @user, @site

While (@@sqlstatus = 0)
BEGIN
    if @user = @suser_Name
    BEGIN
       if (@site = 'paris' and @suser_Name <> 'ubeu' ) or (@site = 'local' and @suser_Name = 'ubeu' )
       BEGIN
        select @PARAM_EU_SSD_LIST = @PARAM_EU_SSD_LIST + " OR SSD_CF=" + convert(varchar(2),@ssd)
       END
       if (@site = 'new-york' and @suser_Name <> 'ubam' ) or (@site = 'local' and @suser_Name = 'ubam' )
       BEGIN
        select @PARAM_AM_SSD_LIST = @PARAM_AM_SSD_LIST + " OR SSD_CF="  + convert(varchar(2),@ssd)
       END
       if (@site = 'singapore' and @suser_Name <> 'ubas' ) or (@site = 'local' and @suser_Name = 'ubas' )
       BEGIN
        select @PARAM_AS_SSD_LIST = @PARAM_AS_SSD_LIST + " OR SSD_CF="  + convert(varchar(2),@ssd)
       END
       
      
    END 
    
    fetch curs_ssd into @ssd, @user, @site
END


CLOSE curs_ssd

deallocate cursor curs_ssd

 select @PARAM_EU_SSD_LIST = str_replace(@PARAM_EU_SSD_LIST,'(1=1 OR','(') + ")" ,
			@PARAM_AM_SSD_LIST =str_replace( @PARAM_AM_SSD_LIST,'(1=1 OR','(')  + ")" ,
			@PARAM_AS_SSD_LIST = str_replace(@PARAM_AS_SSD_LIST ,'(1=1 OR','(') + ")" 
			
	Insert Into #PARAM Values ( 'export PARAM_EU_SSD_LIST=" '		+@PARAM_EU_SSD_LIST       + '"'                )      -- [104]
	Insert Into #PARAM Values ( 'export PARAM_AM_SSD_LIST="' 	+@PARAM_AM_SSD_LIST     + '"'                  )      -- [104]
	Insert Into #PARAM Values ( 'export PARAM_AS_SSD_LIST=" '		+@PARAM_AS_SSD_LIST       + '"'                )      -- [104]
			
			
--------------------------------------------------------------------
print  '==> @PARAM_EU_SSD_LIST : %1!', @PARAM_EU_SSD_LIST  
print  '==> @PARAM_AM_SSD_LIST : %1!', @PARAM_AM_SSD_LIST
print  '==> @PARAM_AS_SSD_LIST : %1!', @PARAM_AS_SSD_LIST
--------------------------------------------------------------------

--------- --------------------------------------------------------------------------------------------------------------------------------------
   
    -- [002] généré les¨PARM même sans EBS
    --If( @ISSDCLO_LL != '_' or @p_SSDESPLAN_LL != "_" or @p_COMPTA_MENS = 1 ) -- au moins une filiale a demandé un inventaire         --[014] ou demande PLAN --[015] ou comptabilisation mensuelle
    --Begin
    	Insert Into #PARAM Values ("export PARM_SSDCLO_LL=" 			+@p_SSDCLO_LL)
		Insert Into #PARAM Values ("export PARM_ISSDCLO_LL=" 			+@ISSDCLO_LL)
		Insert Into #PARAM Values ("export PARM_BLCSHTYEA_NF="		+Convert(Varchar, @p_BLCSHTYEA_NF))
		Insert Into #PARAM Values ("export PARM_BLCSHTMTH_NF=" 		+Convert(Varchar, @p_BLCSHTMTH_NF))
		Insert Into #PARAM Values ("export PARM_CRE_D=" 					+Convert(Char(8), @p_CRE_D, 112))
		Insert Into #PARAM Values ("export PARM_DBCLO_D=" 				+@p_DBCLO_D)
		Insert Into #PARAM Values ("export PARM_CLODAT_D=" 				+@p_CLODAT_D)
--		Insert Into #PARAM Values ("export PARM_ICLODAT_D=" 			+@ICLODAT_D)
		Insert Into #PARAM Values ("export PARM_ICLODAT_D=" 	+convert(varchar(8),dateadd(day,-1,dateadd(month,-3,dateadd(day,+1,@ICLODAT_D))),112))
		Insert Into #PARAM Values ("export PARM_PREV_ICLODAT_D=" 	+convert(varchar(8),dateadd(day,-1,dateadd(month,-6,dateadd(day,+1,@ICLODAT_D))),112))
		Insert Into #PARAM Values ("export PARM_SPCEND_D=" 				+@p_SPCEND_D)
		Insert Into #PARAM Values ( "export PARM_CLOTYP_CT=" 			+@CLOTYP_CT)
		Insert Into #PARAM Values ( "export PARM_SEGTYP_CT=" 			+'A'    )
		Insert Into #PARAM Values ( "export PARM_SSDDEL_LL=" 			+@p_SSDDEL_LL)
		Insert Into #PARAM Values ( "export PARM_LSTCLODAT_LL=" 	+@p_LSTCLODAT_LL)
		Insert Into #PARAM Values ( "export PARM_SSDVRS_LL=" 			+@SSDVRS_LL)
		Insert Into #PARAM Values ( "export PARM_RETTHRESHOLD_R=" 	+'0.01')
		Insert Into #PARAM Values ( "export PARM_PERTYP_CT=" 			+@p_PERTYP_CT)
		Insert Into #PARAM Values ( "export PARM_SSDPLAN_LL=" 			+@SSDPLAN_LL)                               -- MOD001
		Insert Into #PARAM Values ( "export PARM_BOOKING_D=" 			+@p_BOOKING_D)                              -- MOD05
		Insert Into #PARAM Values ( "export PARM_PSTOMGEN_D=" 		+@p_PSTOMGEN_D)                             -- MOD05
		Insert Into #PARAM Values ( "export PARM_ENCONSO_D=" 			+@p_ENCONSO_D)                              -- MOD05
		Insert Into #PARAM Values ( "export PARM_INVCONSO_D=" 		+@P_DateInventaireConso)                    -- MOD05
		Insert Into #PARAM Values ( "export PARM_CONSOYEA=" 			+convert(char(4),@P_PeriodeConsoAA))        -- MOD05
		Insert Into #PARAM Values ( "export PARM_CONSOMTH=" 			+convert(char(2),@P_PeriodeConsoMM))        -- MOD05
		Insert Into #PARAM Values ( "export PARM_INVSERV_D=" 			+@P_DateInventaireService)                  -- MOD05
		Insert Into #PARAM Values ( "export PARM_SERVYEA=" 				+convert(char(4),@P_PeriodeServiceAA))      -- MOD05
		Insert Into #PARAM Values ( "export PARM_SERVMTH=" 				+convert(char(2),@P_PeriodeServiceMM))      -- MOD05
		Insert Into #PARAM Values ( "export PARM_SUFFTABLE=" 			+@p_SuffixeTable)                           -- MOD05
		Insert Into #PARAM Values ( "export PARM_SSDESPLAN_LL=" 		+@p_SSDESPLAN_LL)                           --[014]
		Insert Into #PARAM Values ( "export PARM_EBSPSTOMGEN_D=" 	+@P_EBSPSTOMGEN_D)                          -- [015] / [23390]
		Insert Into #PARAM Values ( "export PARM_LSTPSTOMGEN_D=" 	+@P_LSTPSTOMGEN_D)                          -- [015] / [23390]
		Insert Into #PARAM Values ( "export PARM_BATCHUSER=" 			+suser_Name())                              -- [017] / [23390]
		Insert Into #PARAM Values ( "export PARM_SETTLEMENT=" 			+@SETTLEMENT_cf)                            -- [017] / [23390]
		Insert Into #PARAM Values ( "export PARM_TECHNICAL=" 			+@TECHNICAL_cf)                             -- [017] / [23390]
		Insert Into #PARAM Values ( "export PARM_EXEPLAN=" 				+convert(char(4), @p_EXEPLAN))                                  -- [101] / [28122]
		Insert Into #PARAM Values ( "export PARM_VSRPLAN=" 				+convert(char(2), @p_VSRPLAN))                                  -- [101] / [28122]
		Insert Into #PARAM Values ( "export PARM_BLCSHTYEALOC_NF=" +convert(char(4), @BLCSHTYEALOC_NF))      -- [104]
		Insert Into #PARAM Values ( "export PARM_BLCSHTMTHLOC_NF="+convert(char(2), @BLCSHTMTHLOC_NF))      -- [104]
		Insert Into #PARAM Values ( "export PARM_LOCALTYPE_CF=" 		+@LOCALTYPE_CF                       )      -- [104]
	--End
    Deallocate Cursor cur_inventaire
--End



Select * From #PARAM Order By 1

Drop Table #PARAM

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End

Return 0

ErreurNom:
       Select @P_SuffixeTable = '0'
Return 0


go
EXEC sp_procxmode 'dbo.PsIfrs17Param_01', 'unchained'
go
IF OBJECT_ID('dbo.PsIfrs17Param_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsIfrs17Param_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsIfrs17Param_01 >>>'
go
GRANT EXECUTE ON dbo.PsIfrs17Param_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsIfrs17Param_01 TO GDBBATCH
go
