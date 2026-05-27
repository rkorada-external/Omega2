USE BEST
go
IF OBJECT_ID('dbo.PtREQJOB_05') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtREQJOB_05
    IF OBJECT_ID('dbo.PtREQJOB_05') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtREQJOB_05 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtREQJOB_05 >>>'
END
go
create procedure dbo.PtREQJOB_05 (
	    @p_date_t               datetime,
	    @p_site_cf              varchar(10),
      @P_Booking_D            Char(8) Output,               -- Date de Booking T-1	                 
      @P_PsTomGen_D           Char(8) Output,               -- Date de Fin de Saisie Post Omega Social (Periode T)	  
      @P_EnConso_D            Char(8) Output,               -- Date de Fin de Saisie Ecritures Conso (Periode T)	  
      @DateInventaireConso    Char(8) Output,               -- Date Libelle Inventaire Pour Saisie Ecriture Conso & Social (Periode T-1)
      @PeriodeConsoAA         numeric(4,0) Output,          -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
      @PeriodeConsoMM         numeric(2,0) Output,          -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
      @DateInventaireService  Char(8) Output,               -- Date Libelle Inventaire Pour Saisie Ecriture Service (Periode T)
      @PeriodeServiceAA       numeric(4,0) Output,          -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
      @PeriodeServiceMM       numeric(2,0) Output,          -- Periode MM Pour Saisie Ecriture Services (Periode T)
      @P_SuffixeTable         char(1) Output,               -- Nom de Suffixe de TABLE : '0' si Erreur
      @P_Erreur               int Output,                   -- CodeRetour Erreur pour Message Appli
      @P_EBSPsTomGen_D        Char(8) Output,               -- Date de Fin de Saisie Post Omega Social EBS (Periode T)-- [23390]
	  @P_Booking17_D          Char(8) Output,				-- Last IFRS 17 Booking Date
	  @P_PsTomGen17_D		  Char(8) Output,				-- Post Omega Social IFRS 17 Entry End Date
	  @P_EnConso17_D          Char(8) Output				-- Last Post Omega Conso IFRS 17
	)
as
/***************************************************
Programme: PtREQJOB_05

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
_________________
MODIFICATION 1
Auteur:         M.DJELLOULI
Date:           21/10/2005
Version:
Description:    Correction Appel execution PsCALEND_02 par Selection directe dans la proc
_________________
MODIFICATION 2
Auteur:         M.DJELLOULI
Date:           30/03/2006
Version:
Description:    Correction Selection Dates du Dernier Closing

_________________
MODIFICATION
Auteur:         JF VDV
Date:           23/05/2012
Version:
Description:    [23390] - SOLVENCY aménagements

[100] 30/09/2013 P. Pezout :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[004] 19/02/2015 Florent   :spot:28352 correction pour @P_EnConso_D Date de Fin de Saisie Ecritures Conso (Periode T) 
[005] 16/11/2017 R. Cassis :spira:61508 Ajout commandes print pour debug
[006] 22/03/2022 R. Cassis :spira:103111
[007] 22/06/2022 M. NAJI   :spira 105194 modification des paramètres AE pour le décalfge inter norme PROD
*****************************************************/

declare 	@erreur     	int,
        	@tran_imbr	bit,
        	@A_traiter     int 
-- Variables Résultantes de la PROC
declare 	   @Booking_D DateTime,               -- Date de Booking T-1
         	@PsTomGen_D DateTime,              -- Date de Fin de Saisie Post Omega Social (Periode T)
         	@EnConso_D DateTime,                -- Date de Fin de Saisie Ecritures Conso (Periode T)
         	@EBSPsTomGen_D DateTime,   			  -- Date de Fin de Saisie Post Omega Social (Periode T) [23390]
			@PsTomGen17_D DateTime,
			@EnConso17_D DateTime,
      @Booking17_D DateTime   -- [006] Date de Booking T-1 IFRS17
--        @PeriodeConsoDeb numeric(6,0),   -- Periode AAAAMM Pour Saisie Ecriture Conso & Social (Periode T-1)
--        @PeriodeConsoFin numeric(6,0),     -- Periode AAAAMM Pour Saisie Ecriture Conso & Social (Periode T-1)
--        @PeriodeServiceDeb numeric(6,0),        -- Periode AAAAMM Pour Saisie Ecriture Services (Periode T)
--        @PeriodeServiceFin numeric(6,0)        -- Periode AAAAMM Pour Saisie Ecriture Services (Periode T)


-- Variables de Travail
Declare  @Last_BLCSHTYEA_NF  int,            -- Dernière Comptabilisation : Année
            @Last_BLCSHTMTH_NF  int,            -- Dernière Comptabilisation : Mois
            @Last_SPECEND_D     DateTime,       -- Dernière Comptabilisation : Période Exceptionnelle
            @Last_ACCOUNT_D     DateTime,       -- Dernière Comptabilisation : Date Comptabilisation
            @Last_CLOSING_B     Bit,            -- Dernière Comptabilisation : Closing ?
            @Last_PSTOMGEND_D   DateTime,       -- Dernière Comptabilisation : Date Fin Saisie Post Omega Social
            @Last_EBSPSTOMGEND_D   DateTime,     -- Dernière Comptabilisation : Date Fin Saisie Post Omega Social EBS	[23390]
			@Last_PSTOMGEND17_D		DateTime,
			@Last_PSTOMGCONEND17_D		DateTime
            	
Declare  @Next_BLCSHTYEA_NF  int,                -- Prochaine Comptabilisation : Année
            @Next_BLCSHTMTH_NF  int,                -- Prochaine Comptabilisation : Mois
            @Next_SPECEND_D     DateTime,        -- Prochaine Comptabilisation : Période Exceptionnelle
            @Next_ACCOUNT_D     DateTime,        -- Prochaine Comptabilisation : Date Comptabilisation
            @Next_CLOSING_B     Bit,                  -- Prochaine Comptabilisation : Closing ?
            @Next_PSTOMGEND_D   DateTime        -- Prochaine Comptabilisation : Date Fin Saisie Post Omega Social

--Declare  @Current_BLCSHTYEA_NF  int,                -- Prochaine Comptabilisation : Année
--            @Current_BLCSHTMTH_NF  int,                -- Prochaine Comptabilisation : Mois
--            @Current_SPECEND_D     DateTime,        -- Prochaine Comptabilisation : Période Exceptionnelle
--            @Current_ACCOUNT_D     DateTime,        -- Prochaine Comptabilisation : Date Comptabilisation
--            @Current_CLOSING_B     Bit,                  -- Prochaine Comptabilisation : Closing ?
--            @Current_PSTOMGEND_D   DateTime        -- Prochaine Comptabilisation : Date Fin Saisie Post Omega Social

-- Date Définie dans TBLCSHTD
Declare  @TBLC_BLCSHTMTH_NF  int,                -- Prochaine Comptabilisation : Mois
            @TBLC_STR_D     DateTime,        -- Prochaine Comptabilisation : Période Exceptionnelle
            @TBLC_END_D     DateTime,        -- Prochaine Comptabilisation : Date Comptabilisation
            @TBLC_SPCEND_D     DateTime

Declare @P_AAAA_Date_t int,
        @P_MM_Date_t int,
        @P_PeriodeDate_T numeric(6,0)    -- Format AAAAMM Date de Traitement (Paramètre)

Declare @blcshtyea_nf smallint,		/* BLCSHTYEA_NF  exceptionnel */
           @blcshtmth_nf tinyint,		/* BLCSHTYEA_NF   exceptionnel */
	    @specend_d   datetime,
	    @account_d    datetime,
	    @closing_b    bit,
	   @Max_Trimestre_MM tinyint

Declare @V_PeriodeService numeric(6,0)

-- Initialisation des Variables
Select @P_AAAA_Date_t = Year(@p_date_t)
Select @P_MM_Date_t = Month(@p_date_t)
Select @P_PeriodeDate_T = @P_AAAA_Date_t * 100 + @P_MM_Date_t

Select  @Booking_D  = @p_date_t
Select  @PsTomGen_D  = @p_date_t
Select  @EnConso_D  = @p_date_t
Select  @EBSPsTomGen_D  = @p_date_t	--[23390]
select  @PsTomGen17_D = @p_date_t
select  @EnConso17_D = @p_date_t
select  @Booking17_D = @p_date_t --[006]

select @erreur = 0
select @tran_imbr = 1

Select @P_SuffixeTable = '0'


if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end


-- ===================================================
-- Récupération du Date Dernier BOOKING                             BOOKING_D
-- ===================================================
If Not Exists  (Select 1 FROM BEST..TREQJOB
                   WHERE REQCOD_CT = 'B'
                    and LAUNCH_D  <= @p_date_t
                    and SSD_CF     = 99
                    and SITE_CF    = @p_site_cf
                )
Begin
                Select @P_Erreur = 2101             -- Paramétrages de Dernier Booking (REQCOD_CT=B) Non Trouvé dans TREQJOB
                Goto ErreurNom
End

--[006] Get last IFRS17 Tech booking
/*
-- Selection Dates du Dernier Closing
-- Selection Max Année Dernier Closing
Select @Last_BLCSHTYEA_NF = Max(BALSHEYEA_NF)      -- MOD002 @Last_BLCSHTYEA_NF = Max(BALSHEYEA_NF),
--         @Last_BLCSHTMTH_NF = Max(BALSHTMTH_NF)   -- MOD002
FROM BEST..TREQJOB
WHERE REQCOD_CT   = 'B'
    and LAUNCH_D <= @p_date_t
    and SSD_CF    = 99
    and SITE_CF   = @p_site_cf

--------------------------------------------------------------------
print '==> @Last_BLCSHTYEA_NF = %1!', @Last_BLCSHTYEA_NF
--------------------------------------------------------------------  

-- MOD002 Selection Max Month Dernier Closing
Select @Last_BLCSHTMTH_NF = Max(BALSHTMTH_NF)
FROM BEST..TREQJOB
WHERE REQCOD_CT      = 'B'
    and LAUNCH_D     <= @p_date_t
    and SSD_CF       = 99
    and BALSHEYEA_NF = @Last_BLCSHTYEA_NF
    and SITE_CF      = @p_site_cf
-- Fin MOD002
-- Selection Booking_D
If Not Exists  (Select 1 FROM BEST..TREQJOB
                   WHERE REQCOD_CT = 'B'
                    and LAUNCH_D <= @p_date_t
                    and SSD_CF = 99
                    and @Last_BLCSHTYEA_NF = BALSHEYEA_NF
                    and @Last_BLCSHTMTH_NF = BALSHTMTH_NF
                    and SITE_CF = @p_site_cf
                 )
Begin
                Select @P_Erreur = 2102             -- Periodes de Dernier Booking (REQCOD_CT=B) Non Trouvé dans TREQJOB
                Goto ErreurNom
End

--------------------------------------------------------------------
print '==> @Last_BLCSHTMTH_NF = %1!', @Last_BLCSHTMTH_NF
--------------------------------------------------------------------  
*/

--[006] Get last IFRS17 Tech booking

Select @Booking17_D = Max(dbclo_d)
--,@DateInventaireConso =  Convert(varchar(8), Max(clodat_d),112)
--,@Last_BLCSHTYEA_NF = Max(BALSHEYEA_NF)
FROM BEST..TI17REQJOBPLAN where REQCOD_CT in ('I17GQINVB', 'I17GYINVB')
and dbclo_D < @p_date_t
and SITE_CF      = @p_site_cf


--[007]
Select @DateInventaireConso =  Convert(varchar(8), Max(clodat_d),112)
	,@Last_BLCSHTYEA_NF = Max(BALSHEYEA_NF)
FROM BEST..TI17REQJOBPLAN where REQCOD_CT in ('EBSEQINVB', 'EBSEYINVB')
and dbclo_D < @p_date_t
and SITE_CF = @p_site_cf

--------------------------------------------------------------------
print '==> @Booking17_D = %1!', @Booking17_D
print '==> @DateInventaireConso = %1!', @DateInventaireConso
print '==> @Last_BLCSHTYEA_NF = %1!', @Last_BLCSHTYEA_NF
-------------------------------------------------------------------- 

--Select @Last_BLCSHTMTH_NF = Max(BALSHTMTH_NF)
--    FROM BEST..TI17REQJOBPLAN where REQCOD_CT in ('I17GQINVB', 'I17GYINVB')
--    and dbclo_D < @p_date_t
--    and SITE_CF      = @p_site_cf
--  and BALSHEYEA_NF = @Last_BLCSHTYEA_NF

--[007]
Select @Last_BLCSHTMTH_NF = Max(BALSHTMTH_NF)
    FROM BEST..TI17REQJOBPLAN 
	where REQCOD_CT in ('EBSEQINVB', 'EBSEYINVB')
    and dbclo_D < @p_date_t
    and SITE_CF      = @p_site_cf
  and BALSHEYEA_NF = @Last_BLCSHTYEA_NF  
--------------------------------------------------------------------
print '==> @Last_BLCSHTMTH_NF = %1!', @Last_BLCSHTMTH_NF
--------------------------------------------------------------------  

--[006] End of mod

-- ===================================================
-- Récupération de la Periode PostOmega Social/Conso
-- ===================================================
-- Cette Période Correspond à la Dernière Période de Comptabilisation
Select @PeriodeConsoAA = @Last_BLCSHTYEA_NF               -- Periode T-1
Select @PeriodeConsoMM =@Last_BLCSHTMTH_NF               -- Periode T-1

--Select @Booking_D = LAUNCH_D,
--          @P_SuffixeTable = LEFT(CLOPER_LS, 1)
--          --,
--          --@DateInventaireConso  = Convert(char(8), VRS_NF)
--FROM BEST..TREQJOB
--WHERE REQCOD_CT            = 'B'
--    and LAUNCH_D          <= @p_date_t
--    and SSD_CF             = 99
--    and @Last_BLCSHTYEA_NF = BALSHEYEA_NF
--    and @Last_BLCSHTMTH_NF = BALSHTMTH_NF
--    and SITE_CF            = @p_site_cf

--[007]
Select @Booking_D = max(dbclo_D)
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('I4IQINVB', 'I4IYINVB')
and dbclo_D <= @p_date_t
and SITE_CF   = @p_site_cf
and LAUNCH_D != null

--[007]
Select top 1 @P_SuffixeTable = CLOPER_LS
FROM BEST..TI17REQJOBPLAN 
where REQCOD_CT in ('Z')
and dbclo_D <= @p_date_t
--[007] pas de site pour la demande Z
--and SITE_CF   = @p_site_cf
and LAUNCH_D != null
order by dbclo_D desc 

--------------------------------------------------------------------
print '==> @Booking_D = %1!', @Booking_D
print '==> @P_SuffixeTable = %1!', @P_SuffixeTable
print '==> @DateInventaireConso = %1!', @DateInventaireConso
--------------------------------------------------------------------  

-- --------------------------------------------------------------------------------------
-- Récupération Date de Fin de Saisie Post Omega Social selon Dernier Booking
-- --------------------------------------------------------------------------------------
If Not Exists  (Select 1 FROM BREF..TCALEND
                    WHERE BLCSHTYEA_NF = @Last_BLCSHTYEA_NF
                        and BLCSHTMTH_NF = @Last_BLCSHTMTH_NF
                        and Closing_B = 1)
Begin
                Select @P_Erreur = 2103             -- Periodes de Dernier Closing Non Trouvé dans TCALEND
                Goto ErreurNom
End

Select @Last_PSTOMGEND_D = Null
-- Selection Dates du Dernier Closing
Select @Last_SPECEND_D = SPECEND_D
         ,@Last_ACCOUNT_D = ACCOUNT_D
         --@Last_PSTOMGEND_D = PSTOMGEND_D
         --,@Last_EBSPSTOMGEND_D = EBSPSTOMGEND_D	 --[23390]
		 --,@Last_PSTOMGEND17_D = PSTOMGEND17_D
		 --,@Last_PSTOMGCONEND17_D = PSTOMGCONEND17_D
FROM BREF..TCALEND
WHERE BLCSHTYEA_NF = @Last_BLCSHTYEA_NF
    and BLCSHTMTH_NF = @Last_BLCSHTMTH_NF
    and Closing_B = 1


--[007]
Select   @Last_PSTOMGEND_D = min(PSTOMGEND_D)
FROM BREF..TCALEND
WHERE  PSTOMGEND_D >= @p_date_t

Select   @Last_EBSPSTOMGEND_D = min(EBSPSTOMGEND_D)
FROM BREF..TCALEND
WHERE  EBSPSTOMGEND_D >=  @p_date_t

Select   @Last_PSTOMGEND17_D = min(PSTOMGEND17_D)
FROM BREF..TCALEND
WHERE  PSTOMGEND17_D >=  @p_date_t

Select   @Last_PSTOMGCONEND17_D = min(PSTOMGCONEND17_D)
FROM BREF..TCALEND
WHERE  PSTOMGCONEND17_D >=  @p_date_t

--------------------------------------------------------------------
print '==> @Last_SPECEND_D = %1! @Last_SPECEND_D = %2!', @Last_SPECEND_D, @Last_SPECEND_D
print '==> @Last_PSTOMGEND_D = %1! @Last_EBSPSTOMGEND_D = %2!', @Last_PSTOMGEND_D, @Last_EBSPSTOMGEND_D
--------------------------------------------------------------------  

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

If (@Last_PSTOMGEND_D = Null)
Begin
                Select @P_Erreur = 2105             -- Periode PostOmega Social non Défini dans TCALEND
                Goto ErreurNom
End


-- ---------------------------------------------------------------------------------------------
-- Recherche de la période de comptabilisation (service) par rapport à la date du jour
-- ---------------------------------------------------------------------------------------------

If exists (SELECT  1 from BREF..TCALEND A
           WHERE  ((A.blcshtyea_nf * 100) + A.blcshtmth_nf) =
                        (select min((B.blcshtyea_nf * 100) + B.blcshtmth_nf)
           				from BREF..TCALEND B
    					where convert(Char(10),B.account_d,112) >= convert(Char(10),@p_date_t,112))
          )
    Begin
        	Select @blcshtyea_nf = A.blcshtyea_nf,
        	   @blcshtmth_nf = A.blcshtmth_nf,
        	   @specend_d = A.specend_d,
        	   @account_d = A.account_d,
        	   @closing_b = A.closing_b
           	from BREF..TCALEND A
              where ((A.blcshtyea_nf * 100) + A.blcshtmth_nf)= (select min((B.blcshtyea_nf * 100) + B.blcshtmth_nf)
           				from BREF..TCALEND B
        					where convert(Char(10),B.account_d,112) >= convert(Char(10),@p_date_t,112))

    End
Else
Begin
        Select @erreur = -1
End

if @erreur != 0
	begin
          Select @P_Erreur = 2104             -- Erreur d'accès à la Procédure PsCALEND_02
   		raiserror 20005 "APPLICATIF;PsCALEND_02" /* erreur de lecture */
        	return @erreur
	end
if (@blcshtyea_nf = null)
	begin
        Select @P_Erreur = 2104             -- Erreur d'accès à la Procédure PsCALEND_02
   		raiserror 20005 "APPLICATIF;PsCALEND_02" /* erreur de lecture */
        return @erreur
	end

-- Détermination Année Bissextile
Declare @d_deb Datetime, @d_fin Datetime, @Diff_Day int, @TmpDay int
Select @d_deb = Convert(Char(4), @blcshtyea_nf) + '01' + '01'
Select @d_fin = Convert(Char(4), @blcshtyea_nf+1) + '01' + '01'
Select @Diff_Day = datediff(day, @d_deb, @d_fin) - 365

-- Détermination Dernier Date du Mois pour @DateInventaireService
Select @DateInventaireService = Convert(char(8), @account_d, 112)
Select @PeriodeServiceAA = @blcshtyea_nf               -- Periode T-1
Select @PeriodeServiceMM = @blcshtmth_nf               -- Periode T-1
Select @V_PeriodeService = (@PeriodeServiceAA * 100 ) + @PeriodeServiceMM               -- Periode T-1
Select @TmpDay = (case when @blcshtmth_nf IN (1, 3, 5, 7, 8, 10, 12) then 31 when @blcshtmth_nf IN (4, 6, 9, 11) then 30  when @blcshtmth_nf IN (2) then 28 + @Diff_Day else 0 end)

Select @DateInventaireService = Convert(char(6), @V_PeriodeService)  + Convert(char(2), @TmpDay)
-- --------------------------------------------------------------------------------------
-- Récupération Période Bilan M + 3
-- --------------------------------------------------------------------------------------
If @Last_BLCSHTYEA_NF = 12
    Begin
        Select @Next_BLCSHTYEA_NF = @Last_BLCSHTYEA_NF + 1
        Select @Next_BLCSHTMTH_NF = 3                                           -- 1er Trimestre Anné N+1
    End
Else
    Begin
        Select @Next_BLCSHTYEA_NF = @Last_BLCSHTYEA_NF
        Select @Next_BLCSHTMTH_NF = @Last_BLCSHTMTH_NF + 3
    End



-- ===================================================
-- Récupération Date de Prochain Booking (Si Défini)
-- ===================================================
Select @Next_SPECEND_D = Null
Select @Next_ACCOUNT_D = Null
Select @Next_CLOSING_B = 0
Select @Next_PSTOMGEND_D = Null

IF EXISTS (SELECT 1 FROM BREF..TCALEND
                WHERE BLCSHTYEA_NF = @Next_BLCSHTYEA_NF
                     and BLCSHTMTH_NF = @Next_BLCSHTMTH_NF
               )
Begin
        Select @Next_SPECEND_D = SPECEND_D,
                 @Next_ACCOUNT_D = ACCOUNT_D,
                 @Next_PSTOMGEND_D = PSTOMGEND_D,
                 @Next_CLOSING_B = CLOSING_B
        FROM BREF..TCALEND
        WHERE BLCSHTYEA_NF = @Next_BLCSHTYEA_NF
            and BLCSHTMTH_NF = @Next_BLCSHTMTH_NF
End

--------------------------------------------------------------------
print '==> @Next_SPECEND_D = %1! @Next_ACCOUNT_D = %2!', @Next_SPECEND_D, @Next_ACCOUNT_D
print '==> @Next_PSTOMGEND_D = %1! @Next_CLOSING_B = %2!', @Next_PSTOMGEND_D, @Next_CLOSING_B
--------------------------------------------------------------------  



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
                Select @P_Erreur = 2105             -- Periode PostOmega Social non Défini dans TCALEND
                Goto ErreurNom
    End
--        If (@Last_SPECEND_D != Null)
--            Select @PsTomGen_D =  dateadd(month, 3, @Last_SPECEND_D)
--        Else
--            Begin
--                If (@Next_SPECEND_D != Null)
--                    Select @PsTomGen_D =  @Next_SPECEND_D
--            End
-- Sinon, si aucune des règles ci-dessus, @PsTomGen_D est égale à la Date de Traitement (Cf. + Haut en Initialisation des Var.)




-- ======================================================
-- Pour La Récupération de la Date de Fin de Fin Ecriture Conso      @ENCONSO_D
-- ======================================================
-- Récupéraiton de la Date Exceptionnelle Définie au Niveau de TBLCSHTD
Declare @Tmp_Mth  char(2)
If (@blcshtmth_nf >= 10)
    Select @Tmp_Mth = Convert(Char(2), @blcshtmth_nf)
Else
    Select @Tmp_Mth = '0' + Convert(Char(1), @blcshtmth_nf)

Select @d_fin = Convert(Char(4), @blcshtyea_nf) + @Tmp_Mth + '01'

-- Select @d_fin  = YMD( @blcshtyea_nf, @blcshtmth_nf, 1 )
Select @Max_Trimestre_MM = DatePart(Quarter, @d_fin ) * 3
If Not Exists  (Select 1
                   FROM BCTA..TBLCSHTD a, BREF..TBATCHSSD b
                    WHERE DMN_CF = 1                    -- Domaine Compta Estim
                        and BLCSHTYEA_NF = @blcshtyea_nf
                        and BLCSHTMTH_NF = @Max_Trimestre_MM
                        and a.SSD_CF     = b.SSD_CF
                )
--                        and BLCSHTMTH_NF >= @blcshtmth_nf
--                        and BLCSHTMTH_NF <= @Max_Trimestre_MM)
Begin
     Select @P_Erreur = 2106             -- Impossible de Déterminer la Date de Fin Post Omega Conso. ~r~nDate Fin de Trimestre non Défini dans Compta Groupe TBLCSHTD
     Goto ErreurNom
End

--------------------------------------------------------------------
print '==> @Tmp_Mth = %1! @Max_Trimestre_MM = %2!', @Tmp_Mth, @Max_Trimestre_MM
--------------------------------------------------------------------  

Select @TBLC_STR_D = Max(STR_D),
         @TBLC_END_D = Max(END_D),
         @TBLC_SPCEND_D = Max(SPCEND_D), -- En Attendant, on récupère SPCEND_D au lieu de SPCSTR_D
         @EnConso_D = Max(SPCEND_D)                
FROM BCTA..TBLCSHTD a, BREF..TBATCHSSD b
WHERE DMN_CF = 1                    -- Domaine Compta Estim
    and BLCSHTYEA_NF = @blcshtyea_nf
    and BLCSHTMTH_NF = @Max_Trimestre_MM
    and a.SSD_CF     = b.SSD_CF
--    and BLCSHTMTH_NF >= @blcshtmth_nf
--    and BLCSHTMTH_NF <= @Max_Trimestre_MM

--Select @TBLC_STR_D = Max(STR_D)
--         @TBLC_END_D = Max(END_D)
--         @TBLC_SPCEND_D  = Max(SPCEND_D)
--FROM BCTA..TBLCSHTD
--WHERE DMN_CF = 1                    -- Domaine Compta Estim
--    and BLCSHTYEA_NF = @blcshtyea_nf
--    and BLCSHTMTH_NF = @TBLC_BLCSHTMTH_NF

If (@TBLC_END_D = Null)
Begin
    Select @P_Erreur = 2106             -- Impossible de Déterminer la Date de Fin Post Omega Conso. ~r~nDate Fin de Trimestre non Défini dans Compta Groupe TBLCSHTD
    Goto ErreurNom
End

--------------------------------------------------------------------
print '==> @TBLC_STR_D = %1! @TBLC_END_D = %2!', @TBLC_STR_D, @TBLC_END_D
print '==> @TBLC_SPCEND_D = %1! @EnConso_D = %2!', @TBLC_SPCEND_D, @EnConso_D
--------------------------------------------------------------------  

---- Si la Date Exceptionnelle au niveau du Prochain Booking est Correctement Défini, on prend cette Date (SPECEND Next)
---- Autrement, on Prend (Date dernière Période Exceptionnel du Dernier Booking + 3 Mois)
--If (@Next_SPECEND_D != Null)
--    Select @EnConso_D =  @Next_SPECEND_D
--Else
--    Begin
--        If (@Last_SPECEND_D != Null)
--            Select @EnConso_D =  dateadd(month, 3, @Last_SPECEND_D)
--    End
---- Sinon, si aucune des règles ci-dessus, @EnConso_D est égale à la Date de Traitement (Cf. + Haut en Initialisation des Var.)




---- ======================================================
---- Récupération Période T-1 et Période T
---- ======================================================
---- NB :  On peut Saisir des Ecritures Conso et Social uniquement sur la Période T-1
----         Pour les Ecritures Services, on doit Saisir sur la Période T
----         Donc la Proc se charge de Reconstituer ces Périodes.
--Select  @PeriodeConsoDeb = 0
--Select  @PeriodeConsoFin = 0
--Select  @PeriodeServiceDeb = 0
--Select  @PeriodeServiceFin = 0
---- --------------------------------------------------------------------------------------
--Select @PeriodeConsoDeb = (@Last_BLCSHTYEA_NF * 100 ) + (@Last_BLCSHTMTH_NF - 2)      -- Debut Trimestre
--Select @PeriodeConsoFin = (@Last_BLCSHTYEA_NF * 100 ) + @Last_BLCSHTMTH_NF               -- Fin Trimestre
---- --------------------------------------------------------------------------------------
--If (@Next_BLCSHTYEA_NF != Null)
--    Begin
--            Select @PeriodeServiceDeb = (@Next_BLCSHTYEA_NF * 100)  + (@Next_BLCSHTMTH_NF - 2)      -- Debut Trimestre
--            Select @PeriodeServiceFin = (@Next_BLCSHTYEA_NF  * 100) + @Next_BLCSHTMTH_NF               -- Fin Trimestre
--    End
--Else
--    Begin
--        If @Last_BLCSHTYEA_NF = 12
--            Begin
--                Select @PeriodeServiceDeb = (@Last_BLCSHTYEA_NF + 1) * 100 + 1      -- Debut Trimestre
--                Select @PeriodeServiceFin = (@Last_BLCSHTYEA_NF + 1) * 100 + 3      -- Fin Trimestre
--            End
--        Else
--            Begin
--                Select @PeriodeServiceDeb = (@Last_BLCSHTYEA_NF * 100) + (@Last_BLCSHTYEA_NF - 2)      -- Debut Trimestre
--                Select @PeriodeServiceFin = (@Last_BLCSHTYEA_NF * 100) + @Last_BLCSHTYEA_NF     -- Fin Trimestre
--            End
--    End



--SELECT @Current_BLCSHTYEA_NF = BLCSHTYEA_NF,
--            @Current_BLCSHTMTH_NF  = BLCSHTMTH_NF,
--            @Current_SPECEND_D  = SPECEND_D,
--            @Current_ACCOUNT_D = ACCOUNT_D,
--            @Current_CLOSING_B  = CLOSING_B,
--            @Current_PSTOMGEND_D  = PSTOMGEND_D
--FROM BREF..TCALEND
--WHERE BLCSHTYEA_NF = @P_AAAA_Date_t
--    and BLCSHTMTH_NF = @P_MM_Date_t


-- Vérifier Période si Execution du Traitement en RétroActif
-- Vérifier Période Bilan en COURS
--If (@PeriodeServiceDeb > @P_PeriodeDate_T) Select @PeriodeServiceDeb = @P_PeriodeDate_T
--If (@PeriodeServiceDeb > @P_PeriodeDate_T) Select @PeriodeServiceDeb = @P_PeriodeDate_T
--If (@PeriodeServiceDeb > @P_PeriodeDate_T) Select @PeriodeServiceDeb = @P_PeriodeDate_T
--If (@PeriodeServiceDeb > @P_PeriodeDate_T) Select @PeriodeServiceDeb = @P_PeriodeDate_T



Select @erreur = @@error
if @erreur != 0  goto fin


if @tran_imbr = 0
	 COMMIT TRAN

--Select @Booking_D,              -- Date de Booking T-1
--       @PsTomGen_D,             -- Date de Fin de Saisie Post Omega Social (Periode T)
--       @EnConso_D,              -- Date de Fin de Saisie Ecritures Conso (Periode T)
--       @PeriodeConsoDeb,        -- Periode AAAAMM Pour Saisie Ecriture Conso & Social (Periode T-1)
--       @PeriodeConsoFin,        -- Periode AAAAMM Pour Saisie Ecriture Conso & Social (Periode T-1)
--       @PeriodeServiceDeb,      -- Periode AAAAMM Pour Saisie Ecriture Services (Periode T)
--       @PeriodeServiceFin,       -- Periode AAAAMM Pour Saisie Ecriture Services (Periode T)
--       @P_SuffixeTable

Select @P_Booking_D = Convert(Char(8), @Booking_D, 112)
Select @P_PsTomGen_D = Convert(Char(8), @PsTomGen_D, 112)
Select @P_EnConso_D  = Convert(Char(8), @EnConso_D, 112)
Select @P_EBSPsTomGen_D = Convert(Char(8), @EBSPsTomGen_D, 112) --[23390]
--Select @P_Booking17_D = Convert(Char(8), @Booking_D, 112)
--[006]
Select @P_Booking17_D = Convert(Char(8), @Booking17_D, 112)
Select @P_PsTomGen17_D = Convert(Char(8), @PsTomGen17_D, 112)
Select @P_EnConso17_D  = Convert(Char(8), @EnConso17_D, 112)
return 0

ErreurNom:
       Select @P_SuffixeTable = '0'
       if (@tran_imbr = 0) ROLLBACK TRAN
	 return 0

fin:
if @tran_imbr = 0
	 ROLLBACK TRAN

return 1
go
EXEC sp_procxmode 'dbo.PtREQJOB_05', 'unchained'
go
IF OBJECT_ID('dbo.PtREQJOB_05') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtREQJOB_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtREQJOB_05 >>>'
go
GRANT EXECUTE ON dbo.PtREQJOB_05 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtREQJOB_05 TO GDBBATCH
go
