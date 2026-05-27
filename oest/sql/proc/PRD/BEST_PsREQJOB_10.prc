USE BEST
go
/*
 * creation de la procedure
*/
IF OBJECT_ID('dbo.PsREQJOB_10') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsREQJOB_10
    IF OBJECT_ID('dbo.PsREQJOB_10') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsREQJOB_10 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsREQJOB_10 >>>'
END
go
create procedure dbo.PsREQJOB_10 (
		@p_ssd_cf        char(2),
		@p_reqcod_ct     char(1),
		@p_clodat_d      datetime,
		@p_dbclo_d       datetime,
		@p_account_d     datetime,
		@p_launch_d      datetime,
		@p_cre_d         datetime,
		@p_balsheyea_nf  integer,
		@p_balshtmth_nf  integer,
		@p_cloper_ls     char(64)    -- [SPOT15758] vde
	)

as

/***************************************************

Programme: PsREQJOB_10

Fichier script associé : BEST_PsREQJOB_10.prc
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI
Date de creation: 06/07/2004
Description du programme:
-	Contrôle en Saisie des Demandes d'Inventaires
    Revoie un Code Erreur TMESSAGE

Parametres:
			@p_ssd_cf        string,
			@p_reqcod_ct     string,
			@p_clodat_d      datetime,
  		@p_dbclo_d       datetime,
			@p_account_d     datetime,
			@p_launch_d      datetime,
			@p_cre_d         datetime,
			@p_balsheyea_nf  integer,
			@p_balshtmth_nf  integer,
			@p_cloper_ls     string

Conditions d'execution:

Commentaires:
        Type de Demandes
        	C   Comptabilisation
        	I   Inventaire
        	J   Inventaire + SNEM
        	L   S/R Vie
        	S   Prop Sin CE
        	Z   Chargemt Inventaire
        	D   Demande Inventaire
        	B   Booking
        	T   Demande PeopleSoft Conso-Social
        	F   BOOKING PeopleSoft Conso-Social


        Message
        2014 Il existe déjà une Demande d'inventaire pour cette Filiale
        2015 Il existe déjà une Demande de Stat/Reporting pour cette Filiale
        2016 Une Demande d'inventaire existe déjà pour cette filiale sur une autre Période
        2017 Pas de demande d'inventaire possible : Comptabilisation Mensuelle
        2018 Cette Filiale a déjà été compabilisé pour cette période
        2020 Cette Filiale fait déjà partie d'une demande groupée.
        2021 Il existe déjà une demande de Chargement d'Inventaire
        2022 Il existe déjà une demande de Chargement d'Inventaire
        2024 Vous n'êtes pas en Période de Service. Comptabilisation Impossible.
        2025 Comptabilisation Impossible. Il existe déjà une demande d'Inventaire non encore traitée pour cette filliale
        2026 Demande Inventaire impossible. Comptabilisation déjà effectuée pour cette période.
        2036 Demande Inventaire PostOmega Conso/Social impossible. ~r~nUne Autre demande d'Inventaire existe déjà pour Aujourd'hui ! §
        2038 Attention. Il existe déjà une demande en cours pour l'une des Filiales de votre sélection. §
        2039 Demande Impossible. Il existe déjà une demande en cours pour l'une des Filiales sur une Période Inventaire différente. §
        2040 Trop Tôt! Vous ne pouvez pas saisir une Demande de Comptabilisation PostOmega avant la Date définie dans le Calendrier Groupe !  §
        2041 Demande de Comptabilisation PostOmega déjà saisie pour ce Trimestre !  §

_________________
MODIFICATION 1
Auteur:  M. DJELLOULI
Date:   30/11/2004
Version:
Description: Ajout du STEP 32 : Vérification Demande Filiale de type 'L' non existante dans une demande Groupée "D"
                 Insertion MSG 2020
_________________
MODIFICATION 2
Auteur:  M. DJELLOULI
Date:   16/02/2005
Version:
Description: Vérification qu'il n'y a pas déjà une Demande d'Inventaire en COURS pour éviter le Blocage TJOBQUEUE
                 Vérification Demande de Comptabilisation par rapport au Calendrier Groupe
                 Insertion MSG 2021, 2022
_________________
MODIFICATION 3
Auteur:  M. DJELLOULI
Date:   13/06/2005
Version:
Description: * ne pas pouvoir saisir de demande de comptabilisation (REQCOD_CT='C') si on n’est pas en période service.

                 * pour un même libellé d’inventaire (clodat_d), ne pas pouvoir saisir de demande de comptabilisation pour
                   une filiale s'il existe déjà une demande d'inventaire non encore traitée pour cette filiale (launch_d = null),

                 * pour un même libellé d’inventaire (clodat_d), ne pas pouvoir saisir de demande d'inventaire (REQCOD_CT='I' ou 'J')
                 pour une filiale si cette filiale a déjà comptabilisé (c’est-à-dire s'il existe une demande de type REQCOD_CT='C'
                 pour cette clodat_d, quelque soit la valeur de launch_d)
_________________
MODIFICATION 4
Auteur:  M. DJELLOULI
Date:   20/07/2005
Version:
Description: * Ne Pas Pouvoir Saisir de Demande de Type T lorsqu'il existe une autre Demande d'Inventaire

                 * Ne pas pouvoir saisir une Demande d'Inventaire lorsqu'il existe une Demande de Type T
_________________
MODIFICATION 5
Auteur:  M. DJELLOULI
Date:   03/08/2005
Version:
Description: * Fiche SPOT 11392
                 * Contrôler les Demandes Inventaires Groupées :
                            Si Une Fililale de la Demande Groupée a déjà demandé un Inventaire
                                - sur la même Période Inventaire -> Msg Information
                                - Sur une Autre Période Inventaire  -> Msg Bloquant
________________
MODIFICATION 6
Auteur:  M. DJELLOULI
Date:   15/09/2005
Version:
Description: * Fiche SPOT 5085
                 * Vérification des Demandes de Comtpabilisation PostOmega :
                    - Il n'est pas possible de saisir une demande de Type Comptabilisation
                      PostOmega avant la Date paramétrée dans le Calendrier Gorupe
                    - Il n'est pas possible de saisir plus d'une Demande de Comptabilisation PostOmega le même Trimestre
________________
MODIFICATION 7
Auteur:  M. DJELLOULI
Date:   09/01/2006
Version:
Description: * Fiche SPOT 12322
                 * Intégration du Contrôle sur les Demandes de Type I,J non existante pour une autre filliale ayant un clodat différent

_________________
MODIFICATION 8
12/09/2008  JF. VDV SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 à 64 caractères
-------------------------------------------------------------------------------------------------
[009]  07/05/2012  R. CASSIS     :spot:23802 - Ajout option E pour Solvency
[010]   31/05/2012 JF VDV  [23390] - SOLVENCY aménagements
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare 	@erreur     	int,
        	@A_traiter     int

declare    @v_codeerrmsg   integer
declare    @v_MsgBloquant   integer          -- 0 : Non , 1 : Oui , 2 : A confirmer (Oui / Non)

declare    @r_SSD_CF       USSD_CF,
           @r_BALSHEYEA_NF smallint,
           @r_BALSHTMTH_NF smallint,
           @r_CLODAT_D     datetime,
           @r_REQCOD_CT    char(1),
           @r_CRE_D        UUPD_D,
           @r_DBCLO_D      UUPD_D,
           @r_LAUNCH_D     UUPD_D,
           @r_CLOPER_LS    UL64,            -- [SPOT15758] vde
           @r_VRS_NF       numeric(10,0),
           @r_UPDUSR_CF    UUSR_CF

declare    @pi_ssd_cf      tinyint

Declare    @r_Account_d    datetime,        -- MOD02
           @r_Specend_d	   datetime         -- MOD02

Declare    @pos_SSD_CF     int ,            -- MOD01
           @Tmp_SSD_CF	   varchar(20)      -- MOD01

-- -------------------------------------------------------------------------------
-- Paramètres PostOmega Conso/Social - Proc. PtREQJOB_05
-- -------------------------------------------------------------------------------
Declare     @P_Booking_D           Char(8),       -- Date de Booking T-1
            @P_PsTomGen_D          Char(8),       -- Date de Fin de Saisie Post Omega Social (Periode T)
            @P_EnConso_D           Char(8),       -- Date de Fin de Saisie Ecritures Conso (Periode T)
            @DateInventaireConso   Char(8),       -- Date Libelle Inventaire Pour Saisie Ecriture Conso & Social (Periode T-1)
            @PeriodeConsoAA        numeric(4,0),  -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
            @PeriodeConsoMM        numeric(2,0),  -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
            @DateInventaireService Char(8),       -- Date Libelle Inventaire Pour Saisie Ecriture Service (Periode T)
            @PeriodeServiceAA      numeric(4,0),  -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
            @PeriodeServiceMM      numeric(2,0),  -- Periode MM Pour Saisie Ecriture Services (Periode T)
            @P_SuffixeTable        char(1),
            @P_Erreur              int,
            @P_EBSPsTomGen_D       char(08),
			@P_Booking17_D         Char(8),
			@P_PsTomGen17_D        Char(8),
			@P_EnConso17_D         Char(8)
Declare     @p_date_t              DateTime
Select @p_date_t = GetDate()

-- MOD01 : Create TABLE #TLSTSSD
CREATE TABLE #TLSTSSD (SSD_CF USSD_CF NOT NULL)

select @pi_ssd_cf = convert(tinyint, @p_ssd_cf)

select @erreur = 0

select @r_REQCOD_CT = null

-- 0. Vérifier si l'on est en Période Service   -- MOD03
Declare @V_Periode_Service char(1)
-- Execute @V_Periode_Service = BEST..PsCALEND_06 'C'


declare 	@CallBLCSHTYEA_NF smallint,
          @CallBLCSHTMTH_NF tinyint,
 	        @CallDATE		      datetime,   	/* date de recherche */
          @CallSPCEND_D     datetime,     /* fin de période exceptionnelle   */
 	        @CallACCOUNT_D	  datetime,  	  /* date de comptabilisation ( fin service )  */
 	        @CallCLOSING_B	  bit,          /* top inventaire groupe */
          @CallEND_D        datetime,
 	        @CallCOUNT_D	    datetime

declare @site_cf        varchar(10)
Execute @erreur = BEST..PsSITE_01 @p_ssd_cf,'2',@site_cf output

/**********************************************************************************************/
/* Select dans BREF..TCALEND                                                                  */
/* Recherche de la période de service                                                         */
/**********************************************************************************************/

select @CallDATE = getdate()

Execute @erreur = BREF..PsCALEND_02
			@CallDATE ,
			'C',
			@CallBLCSHTYEA_NF output,
      @CallBLCSHTMTH_NF output,
			@CallSPCEND_D output,
			@CallACCOUNT_D output,
			@CallCLOSING_B output

if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;TCALEND" /* erreur de lecture */
        	return @erreur
	end

-- Est on en période de service ?
Select  @CallEND_D = @CallSPCEND_D
Select  @CallCOUNT_D = @CallACCOUNT_D

select @V_Periode_Service = 'N'
If convert(Char(10), getdate(),112) > convert(Char(10), @CallEND_D,112)
and convert(Char(10), getdate(),112) <= convert(Char(10), @CallCOUNT_D,112)
Begin
	select @V_Periode_Service = 'O'
End


-- 1. Vérifier Demande Inventaire S/R
if (@p_reqcod_ct = 'L')
    begin
        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
               @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
               @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        FROM BEST..TREQJOB
        WHERE reqcod_ct IN ('I', 'J')
          and launch_d = null
          and SITE_CF  = @site_cf
--          and ssd_cf = @pi_ssd_cf
    end
if (@r_REQCOD_CT != null)
    begin
        select @v_codeerrmsg = 2014     -- 2014 Il existe déjà une Demande d'inventaire pour cette Filiale
        Select @v_MsgBloquant = 1         -- Oui
        goto fin
    end

-- 2. Vérifier Demande Inventaire
if (@p_reqcod_ct = 'I') or (@p_reqcod_ct = 'J')
    begin
        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
               @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
               @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        FROM BEST..TREQJOB
        WHERE reqcod_ct IN ('L')
          and launch_d = null
          and SITE_CF  = @site_cf
--         and ssd_cf = @pi_ssd_cf
    end
if (@r_REQCOD_CT != null)
    begin
        select @v_codeerrmsg = 2015     --  2015 Il existe déjà une Demande de Stat/Reporting pour cette Filiale
        Select @v_MsgBloquant = 1         -- Oui
        goto fin
    end

-- 2. Vérifier qu'une Autre Filliale ne demande pas un Inventaire sur une Autre Date
if (@p_reqcod_ct = 'I') or (@p_reqcod_ct = 'J')
    begin
        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
               @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
               @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        FROM BEST..TREQJOB
        WHERE reqcod_ct IN ('I', 'J')
         and launch_d = null
         and convert(char(8), clodat_d, 112) != convert(char(8), @p_clodat_d, 112)
         and SITE_CF  = @site_cf
         and ssd_cf != @pi_ssd_cf
    end
    if (@r_REQCOD_CT != null)
        begin
            select @v_codeerrmsg = 2039     -- 2039 Demande Impossible. Il existe déjà une demande en cours pour l'une des Filiales sur une Période Inventaire différente. §
            Select @v_MsgBloquant = 1         -- Oui
            goto fin
        end



-- 16. Vérifier pour une demande Groupée, qu'il n'existe pas une demande Inventaire pour une des Filiales
if (@p_reqcod_ct = 'D' or @p_reqcod_ct = 'E')  -- [009]
    begin
        If (Ltrim(rtrim(@p_cloper_ls)) = '') Select @p_cloper_ls = Null

        If (@p_cloper_ls != Null)
        Begin
            -- concatene un "," à la fin de la chaine
            select @p_cloper_ls=RTRIM(@p_cloper_ls) +","
            -- retourne la valeur du premier "," de la chaine
            select  @pos_SSD_CF=charindex(",",@p_cloper_ls)

            -- Stockage dans Table Temporaire de la Liste des Filiales
            while @pos_SSD_CF > 1
            BEGIN
                	select @Tmp_SSD_CF = substring(@p_cloper_ls,1,@pos_SSD_CF - 1)
                	select @p_cloper_ls = substring(@p_cloper_ls,@pos_SSD_CF +1,1000)

                	-- Controle de l'existance de cette filiale dans bref..tsubsid
                	if exists (select null from bref..tsubsid where ssd_cf=convert( smallint,@Tmp_SSD_CF))
                	begin
                	    insert into #TLSTSSD values ( convert( smallint,@Tmp_SSD_CF) )
                 end
                	select  @pos_SSD_CF=charindex(",",@p_cloper_ls)
            END  -- @pos_SSD_CF > 1


            IF EXISTS (SELECT 1 FROM BEST..TREQJOB  A
                           WHERE reqcod_ct IN ('I', 'J', 'L')
                               AND launch_d = null
                               and SITE_CF  = @site_cf
                              and convert(char(8), clodat_d, 112) = convert(char(8), @p_clodat_d, 112)
                               and EXISTS (SELECT 1 FROM #TLSTSSD B
                                                WHERE A.SSD_CF = B.SSD_CF)
                           )
            BEGIN
                SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
                           @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
                           @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
                    FROM BEST..TREQJOB A
                    WHERE reqcod_ct IN ('I', 'J', 'L')
                      and launch_d = null
                      and SITE_CF  = @site_cf
                      and convert(char(8), clodat_d, 112) = convert(char(8), @p_clodat_d, 112)
                      and EXISTS (SELECT 1 FROM #TLSTSSD B
                                        WHERE A.SSD_CF = B.SSD_CF)

                    BEGIN
                        select @v_codeerrmsg = 2038     -- 2038 Attention. Il existe déjà une demande en cours pour l'une des Filiales de votre sélection. §
                        Select @v_MsgBloquant = 0         -- Non
                        goto fin
                    END
            END -- EXISTS Demande I, J, L dans TREQJOB Clodat = P_Cloadt_d - Msg 2038




            IF EXISTS (SELECT 1 FROM BEST..TREQJOB  A
                           WHERE reqcod_ct IN ('I', 'J', 'L')
                               AND launch_d = null
                               and SITE_CF  = @site_cf
                              and convert(char(8), clodat_d, 112) != convert(char(8), @p_clodat_d, 112)
                               and EXISTS (SELECT 1 FROM #TLSTSSD B
                                                WHERE A.SSD_CF = B.SSD_CF)
                           )
            BEGIN
                SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
                           @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
                           @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
                    FROM BEST..TREQJOB A
                    WHERE reqcod_ct IN ('I', 'J', 'L')
                      and launch_d = null
                      and SITE_CF  = @site_cf
                      and convert(char(8), clodat_d, 112) != convert(char(8), @p_clodat_d, 112)
                      and EXISTS (SELECT 1 FROM #TLSTSSD B
                                        WHERE A.SSD_CF = B.SSD_CF)

                    BEGIN
                        select @v_codeerrmsg = 2039     -- 2039 Demande Impossible. Il existe déjà une demande en cours pour l'une des Filiales sur une Période Inventaire différente. §
                        Select @v_MsgBloquant = 1         -- Oui
                        goto fin
                    END
            END -- EXISTS Demande I, J, L dans TREQJOB Clodat <> P_Cloadt_d - Msg 2038

       End -- (@r_CLOPER_LS != Null)

end -- (@p_reqcod_ct = 'D')


-- 3. Vérifier qu'il n'existe pas de Demande sur période différente avec launch_d = null

if (@p_reqcod_ct = 'J') or (@p_reqcod_ct = 'L') or (@p_reqcod_ct = 'D') or (@p_reqcod_ct = 'E')  -- [009]
   begin -- B01
        select @r_BALSHEYEA_NF = null
        select @r_BALSHTMTH_NF = null
        select @r_CLODAT_D = null

        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
               @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
               @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        from BEST..TREQJOB
        where reqcod_ct = @p_reqcod_ct
          and launch_d = null
          and SITE_CF  = @site_cf
          and ( balsheyea_nf <> @p_balsheyea_nf OR balshtmth_nf <> @p_balshtmth_nf )

        If (@r_BALSHEYEA_NF = null) and (@r_BALSHTMTH_NF = null)
        begin
            select @r_CLODAT_D = null

            SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
               @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
               @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
            from BEST..TREQJOB
            where reqcod_ct = @p_reqcod_ct
              and launch_d = null
              and convert(char(10), clodat_d, 112) <> convert(char(10), @p_clodat_d, 112)
              and SITE_CF  = @site_cf
--              and ssd_cf = @pi_ssd_cf
        end

        if (@r_BALSHEYEA_NF != null) or (@r_BALSHTMTH_NF != null) or (@r_CLODAT_D != null)
            begin -- B02
                select @v_codeerrmsg = 2016     --  2016 Une Demande d'inventaire existe déjà pour cette filiale sur une autre Période
                Select @v_MsgBloquant = 1         -- Oui
                goto fin
            end   -- E02
    end -- E01


-- 31. Vérifier qu'il n'existe pas de Demande sur période différente avec launch_d = null

if (@p_reqcod_ct = 'I')
   begin -- B01
        select @r_BALSHEYEA_NF = null
        select @r_BALSHTMTH_NF = null
        select @r_CLODAT_D = null

        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
               @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
               @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        from BEST..TREQJOB
        where reqcod_ct = @p_reqcod_ct
          and launch_d = null
          and ( balsheyea_nf <> @p_balsheyea_nf and balshtmth_nf <> @p_balshtmth_nf )
          and SITE_CF  = @site_cf
          and ssd_cf = @pi_ssd_cf

        If (@r_BALSHEYEA_NF = null) and (@r_BALSHTMTH_NF = null)
        begin
            select @r_CLODAT_D = null

            SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
               @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
               @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
            from BEST..TREQJOB
            where reqcod_ct = @p_reqcod_ct
              and launch_d = null
              and convert(char(10), clodat_d, 112) <> convert(char(10), @p_clodat_d, 112)
              and SITE_CF  = @site_cf
              and ssd_cf = @pi_ssd_cf
        end

        if (@r_BALSHEYEA_NF != null) or (@r_BALSHTMTH_NF != null) or (@r_CLODAT_D != null)
            begin -- B02
                select @v_codeerrmsg = 2016     --  2016 Une Demande d'inventaire existe déjà pour cette filiale sur une autre Période
                Select @v_MsgBloquant = 1         -- Oui
                goto fin
            end   -- E02
    end -- E01


-- MOD01
-- 32. Vérifier que cette demande S/R n'est pas incluse dans une Demande groupée
if (@p_reqcod_ct = 'L') or (@p_reqcod_ct = 'I') or (@p_reqcod_ct = 'J')
    begin

        IF EXISTS (SELECT 1 FROM BEST..TREQJOB WHERE reqcod_ct IN ('D','E') AND launch_d = null and SITE_CF  = @site_cf )  -- [009]
        BEGIN

            SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
                       @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
                       @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
                FROM BEST..TREQJOB
                WHERE reqcod_ct IN ('D','E')  -- [009]
                  and SITE_CF  = @site_cf
                  and launch_d = null

            -- SI @r_CLOPER_LS est Vide, on ne fait rien
            If (Ltrim(rtrim(@r_CLOPER_LS)) = '') Select @r_CLOPER_LS = Null

            If (@r_CLOPER_LS != Null)
            Begin
                -- concatene un "," à la fin de la chaine
                select @r_CLOPER_LS=RTRIM(@r_CLOPER_LS) +","

                -- retourne la valeur du premier "," de la chaine
                select  @pos_SSD_CF=charindex(",",@r_CLOPER_LS)

                -- Stockage dans Table Temporaire de la Liste des Filiales
                while @pos_SSD_CF > 1
                BEGIN
                	select @Tmp_SSD_CF = substring(@r_CLOPER_LS,1,@pos_SSD_CF - 1)
                	select @r_CLOPER_LS = substring(@r_CLOPER_LS,@pos_SSD_CF +1,1000)

                	-- Controle de l'existance de cette filiale dans bref..tsubsid
                	if exists (select null from bref..tsubsid where ssd_cf=convert( smallint,@Tmp_SSD_CF))
                	begin
                	    insert into #TLSTSSD values ( convert( smallint,@Tmp_SSD_CF) )
                    end

                	select  @pos_SSD_CF=charindex(",",@r_CLOPER_LS)

                END  -- @pos_SSD_CF > 1

           End -- (@r_CLOPER_LS != Null)

           If (@r_CLOPER_LS = Null) Select @r_CLOPER_LS = ''
                -- Test d'existance que la demande de type 'L'
                -- n'est pas incluse dans l'une des FIliales de la demande 'D','E'
                IF Exists (SELECT 1 FROM #TLSTSSD WHERE SSD_CF = @pi_ssd_cf)
                BEGIN
                    select @v_codeerrmsg = 2020     -- 2020 Cette Filiale fait déjà partie d'une demande groupée.
                    Select @v_MsgBloquant = 1         -- Oui
                    goto fin
                END

        END -- EXISTS Demande D dans TREQJOB
    end -- (@p_reqcod_ct = 'L')



-- 4. Si Demande Inventaire en Comptabilisation Mensuelle
select @A_traiter=count(*)
from BREF..TCALEND
where closing_b = 0
  and convert(char(10), account_d , 112) = convert(char(10), @p_cre_d, 112)
  and blcshtyea_nf = @p_balsheyea_nf
  and blcshtmth_nf = @p_balshtmth_nf

if (@A_traiter > 0)
    begin

        select @v_codeerrmsg = 2017    --  2017 Pas de demande d'inventaire possible : Comptabilisation Mensuelle
        Select @v_MsgBloquant = 1         -- Oui

        -- On Retourne dans @r_CLODAT_D et @r_DBCLO_D, les Valeurs a affichés dans le MSG
        select @r_BALSHEYEA_NF = -1
        select @r_BALSHTMTH_NF = -1

        Select @r_CLODAT_D = specend_d, @r_DBCLO_D = account_d
        from BREF..TCALEND
        where closing_b = 0
          and blcshtyea_nf = @p_balsheyea_nf
          and blcshtmth_nf = @p_balshtmth_nf
        goto fin
    end


-- 5. Récupérer Account_D
select distinct @p_account_d = account_d
from BREF..TCALEND
where closing_b = 0
  and blcshtyea_nf = @p_balsheyea_nf
  and blcshtmth_nf = @p_balshtmth_nf

-- 6. Vérifier que la Filiale n'a pas déjà été comptabilisée
if (@p_reqcod_ct = 'I') or (@p_reqcod_ct = 'J')
    begin
        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
           @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
           @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        FROM BEST..TREQJOB
        where convert(char(10), clodat_d, 112) = convert(char(10), @p_clodat_d, 112)
          and convert(char(10), cre_d, 112) < convert(char(10), @p_account_d, 112)
          and launch_d is null
          and reqcod_ct = 'C'
          and ssd_cf = @pi_ssd_cf

    if (@r_REQCOD_CT != null)
        begin
            select @v_codeerrmsg = 2018     --  2018 Cette Filiale a déjà été compabilisé pour cette période
            Select @v_MsgBloquant = 1         -- Oui
            goto fin
        end
end


-- 7. Vérifier qu'il n'y a pas déjà une demande en Cours
if (@p_reqcod_ct = 'Z')
Begin
    SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
       @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
       @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
    FROM BEST..TREQJOB
    where launch_d is null
      and reqcod_ct = 'Z'

    if (@r_REQCOD_CT != null)
        begin
            select @v_codeerrmsg = 2021    --  2021 Il existe déjà une demande de Chargement d'Inventaire
            Select @v_MsgBloquant = 1         -- Oui
            goto fin
        end
End


---- 8. Autoriser Demande de Booking de type 'C' uniquement sur Période TCALEND
--if (@p_reqcod_ct = 'C')
--    begin
--        select @A_traiter=count(*)
--        from BREF..TCALEND
--        where closing_b = 0
--          and convert(char(10), specend_d , 112) <  convert(char(10), @p_cre_d, 112)
--          and convert(char(10), @p_cre_d, 112) < convert(char(10), account_d , 112)
--          and blcshtyea_nf = @p_balsheyea_nf
--          and blcshtmth_nf = @p_balshtmth_nf
--
--        if (@A_traiter <= 0) or  (@A_traiter = Null)
--            begin
--                select @v_codeerrmsg = 2022   --  2022 Demande de Comptabilisation incorrect par rapport au Calendrier Groupe ! §
--
--                select @r_BALSHEYEA_NF = -1
--                select @r_BALSHTMTH_NF = -1
--
--                -- On Retourne dans @r_CLODAT_D et @r_DBCLO_D, les Valeurs a affichés dans le MSG
--                Select @r_CLODAT_D = specend_d, @r_DBCLO_D = account_d
--                from BREF..TCALEND
--                where closing_b = 0
--                  and blcshtyea_nf = @p_balsheyea_nf
--                  and blcshtmth_nf = @p_balshtmth_nf
--                goto fin
--            end
--    end


-- 9. Ne pas Saisir de demande de Comptabilisation en Période de Service
if (@p_reqcod_ct = 'C')
Begin
        If (@V_Periode_Service = 'N')
        begin
            select @v_codeerrmsg = 2024    --  2024 Vous n'êtes pas en Période de Service. Comptabilisation Impossible.
            Select @v_MsgBloquant = 1         -- Oui
            goto fin
        end
End

Declare @VDSR char(16)
If (@pi_ssd_cf >= 10)
    Select @VDSR = '%' + Convert(char(2), @pi_ssd_cf) + '%'
Else
    Select @VDSR = '%' + Convert(char(1), @pi_ssd_cf) + '%'

-- 10. Pour un même libellé d'inventaire (clodat_d), ne pas pouvoir saisir de demande de comptabilisation
--      pour une filiale s'il existe déjà une demande d'inventaire non encore traitée pour cette filiale (launch_d = null)
if (@p_reqcod_ct = 'C')
    begin
        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
           @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
           @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        FROM BEST..TREQJOB
        where convert(char(10), clodat_d, 112) = convert(char(10), @p_clodat_d, 112)
          and launch_d is null
          and SITE_CF  = @site_cf
          and ((ssd_cf = @pi_ssd_cf and REQCOD_CT IN ('I', 'J'))
             OR (CLOPER_LS like (@VDSR) and REQCOD_CT in ('D','E'))  -- [009]
              )

    if (@r_REQCOD_CT != null)
        begin
            select @v_codeerrmsg = 2025     --  2025 Comptabilisation Impossible. Il existe déjà une demande d'Inventaire
                                                         --          non encore traitée pour cette filliale
            Select @v_MsgBloquant = 1         -- Oui
            goto fin
        end
end


-- 11. Pour un même libellé d'inventaire (clodat_d), ne pas pouvoir saisir de demande d'inventaire (REQCOD_CT='I' ou 'J') pour
--      une filiale si cette filiale a déjà comptabilisé (c'est-à-dire s'il existe une demande de type REQCOD_CT='C' pour cette
--      clodat_d, quelque soit la valeur de launch_d)
if (@p_reqcod_ct = 'I') or (@p_reqcod_ct = 'J')
    begin
        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
           @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
           @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        FROM BEST..TREQJOB
        where convert(char(8), clodat_d, 112) = convert(char(8), @p_clodat_d, 112)
          and ssd_cf = @pi_ssd_cf
          and reqcod_ct = 'C'

    if (@r_REQCOD_CT != null)
        begin
            select @v_codeerrmsg = 2026     --  2026 Demande Inventaire impossible. Comptabilisation déjà effectuée pour cette période.
            Select @v_MsgBloquant = 1         -- Oui
            goto fin
        end
end


---- 12. Ne pas pouvoir saisir une Demande de Type T ou F si demande déjà existante
--if (@p_reqcod_ct = 'T') or (@p_reqcod_ct = 'F')
--    begin
--        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
--           @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
--           @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
--        FROM BEST..TREQJOB
--        where launch_d is null
--          -- and convert(char(10), clodat_d, 112) = convert(char(10), @p_clodat_d, 112)
--          -- and ssd_cf = @pi_ssd_cf
--          and reqcod_ct IN ('T', 'F')
--
--    if (@r_REQCOD_CT != null)
--        begin
--            select @v_codeerrmsg = 2037     --  2037 Demande impossible. ~r~nUne demande d'Inventaire PostOmega Conso/Social est déjà en Attente !
--            goto fin
--        end
--end



-- 14. Ne pas pouvoir saisir une Autre Demande d'Inventaire lorsqu'une Demande de Type T existe Quelquesoit la Filiale
if (@p_reqcod_ct = 'C') or (@p_reqcod_ct = 'I')  or (@p_reqcod_ct = 'J')  or (@p_reqcod_ct = 'L')  or (@p_reqcod_ct = 'D') or (@p_reqcod_ct = 'E')  -- [009]
    begin
        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
           @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
           @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        FROM BEST..TREQJOB
        where launch_d is null
--          and convert(char(10), clodat_d, 112) = convert(char(10), @p_clodat_d, 112)
          and SITE_CF  = @site_cf
          and reqcod_ct IN ('T', 'F')

    if (@r_REQCOD_CT != null)
        begin
            select @v_codeerrmsg = 2036     --  2036 Demande impossible. ~r~nUne demande Inventaire PostOmega Social/Conso est en Attente ! §
            Select @v_MsgBloquant = 1         -- Oui
            goto fin
        end
end


-- -------------------------------------------------------------------------------
-- Accès aux Paramètres PostOmega Conso/Social
-- -------------------------------------------------------------------------------
-- 15. Ne pas pouvoir saisir une Autre Demande d'Inventaire lorsqu'une Demande de Type T existe Quelquesoit la Filiale
if (@p_reqcod_ct = 'T') or (@p_reqcod_ct = 'F')
Begin

        -- 13. Ne pas pouvoir saisir une Demande de Type T ou F si demande déjà existante
        SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
           @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
           @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
        FROM BEST..TREQJOB
        where launch_d is null
          and SITE_CF  in (@site_cf,'ALL')
          and reqcod_ct IN ('C', 'I', 'J', 'L', 'D', 'E', 'T', 'F')  -- [009]

        if (@r_REQCOD_CT != null)
            begin
                select @v_codeerrmsg = 2037     --  2037 Demande PostOmega Conso/Social impossible. ~r~nUne Autre demande d'Inventaire est déjà en Attente !
                Select @v_MsgBloquant = 1         -- Oui
                goto fin
            end


        if (@p_reqcod_ct = 'F')
        Begin

            -- 20. Demande de Comptabilisation PostOmega déjà saisie pour ce Trimestre. §
            SELECT DISTINCT  @r_SSD_CF = SSD_CF,  @r_BALSHEYEA_NF = BALSHEYEA_NF, @r_BALSHTMTH_NF = BALSHTMTH_NF, @r_CLODAT_D = CLODAT_D,
               @r_REQCOD_CT = REQCOD_CT, @r_CRE_D = CRE_D, @r_DBCLO_D = DBCLO_D, @r_LAUNCH_D = LAUNCH_D, @r_CLOPER_LS = CLOPER_LS,
               @r_VRS_NF = VRS_NF,  @r_UPDUSR_CF = UPDUSR_CF
            FROM BEST..TREQJOB
            where launch_d is null
              and reqcod_ct = 'F'
              and SITE_CF  = @site_cf
              and CLODAT_D = @p_clodat_d

            if (@r_REQCOD_CT != null)
                begin
                    Select @v_codeerrmsg = 2041     -- 2041 Demande de Comptabilisation PostOmega déjà saisie pour ce Trimestre. §
                    Select @v_MsgBloquant = 1         -- Oui
                    goto fin
                end

        End

        -- Chargement des Paramètres PostOmega
        Exec BEST..PtREQJOB_05 @p_date_t,
                        @site_cf,
                        @P_Booking_D           Output,
                        @P_PsTomGen_D          Output,
                        @P_EnConso_D           Output,
                        @DateInventaireConso   Output,           -- Date Libelle Inventaire Pour Saisie Ecriture Conso & Social (Periode T-1)
                        @PeriodeConsoAA        Output,         -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
                        @PeriodeConsoMM        Output,         -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
                        @DateInventaireService Output,            -- Date Libelle Inventaire Pour Saisie Ecriture Service (Periode T)
                        @PeriodeServiceAA      Output,          -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
                        @PeriodeServiceMM      Output,          -- Periode MM Pour Saisie Ecriture Services (Periode T)
                        @P_SuffixeTable        Output,
                        @P_Erreur              Output,
						@P_EBSPsTomGen_D       Output,
						@P_Booking17_D	       Output,       
						@P_PsTomGen17_D        Output,
						@P_EnConso17_D         Output
								
        Select @erreur = @@error
        if @erreur != 0
        	begin
                raiserror 20005 "APPLICATIF;PtREQJOB_05" /* erreur de lecture */
                Select @v_codeerrmsg = @P_Erreur
                Select @v_MsgBloquant = 1         -- Oui
                return @erreur
        	end


        If (@P_SuffixeTable = '0') or (@P_SuffixeTable = Null)
        Begin
                select @v_codeerrmsg = @P_Erreur            -- Code Erreur Récupérée de la Proc en Amont.
                Select @v_MsgBloquant = 1         -- Oui
                goto fin
        End



        if (@p_reqcod_ct = 'F')
         Begin
            -- Ne pas pouvoir Saisir de Demandes Comptabilisation PostOmega, tant que l'on est pas >= P_PsTomGen_D
            If (Convert(char(8), GetDate(), 112) < Convert(char(8), @P_PsTomGen_D, 112))
            Begin
                  Select @v_codeerrmsg = 2040     -- 2040 Trop Tôt! Vous ne pouvez pas saisir une Demande de Comptabilisation PostOmega avant la Date paramétrée. §
                  Select @v_MsgBloquant = 1         -- Oui
                  goto fin
            End
        End

End -- (@p_reqcod_ct = 'T') or (@p_reqcod_ct = 'F')


fin:

SELECT @v_codeerrmsg, @v_MsgBloquant, @r_SSD_CF, @r_BALSHEYEA_NF, @r_BALSHTMTH_NF, convert(char(10), @r_CLODAT_D, 112) , @r_REQCOD_CT,
       convert(char(10), @r_CRE_D, 112), convert(char(10), @r_DBCLO_D, 112) ,
       convert(char(10), @r_LAUNCH_D, 112) , @r_CLOPER_LS, @r_VRS_NF, @r_UPDUSR_CF

return 0
go
EXEC sp_procxmode 'dbo.PsREQJOB_10', 'unchained'
go
IF OBJECT_ID('dbo.PsREQJOB_10') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsREQJOB_10 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsREQJOB_10 >>>'
go
GRANT EXECUTE ON dbo.PsREQJOB_10 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_10 TO GDBBATCH
go
