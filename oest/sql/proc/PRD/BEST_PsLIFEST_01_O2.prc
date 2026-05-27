USE BEST
go
IF OBJECT_ID('PsLIFEST_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsLIFEST_01_O2
    IF OBJECT_ID('PsLIFEST_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsLIFEST_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsLIFEST_01_O2 >>>'
END
go
create procedure PsLIFEST_01_O2
(@p_END_NT      UEND_NT,
@p_SEC_NF       USEC_NF,
@p_UW_NT        UUW_NT,
@p_UWY_NF       UUWY_NF,
@p_SSD_CF       USSD_CF,
@p_ESB_CF       UESB_CF,
@p_DIR_CF       UDIR_CF,
@p_DMN_CF       tinyint,
@p_CTR_NF       UCTR_NF,
@p_LANGUE       char(1),
@p_usr_cf 		UUSR_CF,
@p_lower_bound_year smallint,
@p_higher_bound_year smallint,
@p_loading_b          bit)
with execute as caller as
/***************************************************
Domaine                   : (ES) Estimation
Base principale           : BEST
Version                   : 1
Auteur                    : ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)
Date de creation          : 03 Avril 1997
Description du programme  : Sélection d'enregistrement dans TRAITE et COMPTA
                            Info géné d'un traité Acceptation dont on liste et maj les estimations.
Conditions d'execution    :
Commentaires              :
_________________
MODIFICATIONS
1  L.DEBEVER 29/09/1997 Recherche monnaire principale de la section @CUR_CFS
2  L.DEBEVER 07/10/1997 Etat de la section correspondant à l'exc de souscription
3  L.DEBEVER 19/04/1999 Description: Deux select dans TSECTION / exc de souscription le plus récent. 1 pour select 'état traité', un pour les autres info ????
                         => tout dans le même select. + select 'nature section' (TSECTION) + select 'caractérisation affaire' (TCONTR)
4  G.BUISSON 20/01/2003 Recuperation du max de CRE_D dans LIFEST pour alimenter la date de dernier traitement (on ne prend pas en compte les estimations
                        creees par les arretes statistiques (heure de cre_d = 23:59:59)
5  G.BUISSON 26/02/2003 Recuperation du commentaire general sur TLIFDRI sur contrat/exercice/section, bilan = 1900, mois = 01 AC = 1900 Recuperation du top presence de commentaires par AC
6  G.BUISSON 26/03/2003 Recuperation du type de calcul des CNA dans BRET..TCONTR
7  G.BUISSON 28/04/2003 Ajout argument langue pour recuperation libelle du type de calcul cna
8  G.BUISSON 09/07/2003 Recherche dans BCTA..TBLCSHTD de la periode normale suivante pour deblocage de la saisie estimation en periode exceptionnelle
9  G.BUISSON 03/02/2004 Les as ne sont plus generes a 23:59:59 mais a 23:59:xx. De ce fait on ne prend plus en compte les estimations dont l'heure est 23:59
10 Florent   19/07/2004 EST10260, gestion des grappes
11 DJELLOULI 02/08/2004 selection Min Periode Comptable
12 G.BUISSON 25/05/2005 :spot:10305 La date de dernière mise à jour ne doit plus dépendre de l'exercice pour les traités de type 1 et 4
13 G.BUISSON 20/06/2005 :spot:11214 Permettre la saisie en période exceptionnelle si l'utilisateur a le profil TRT02 et que ce profil présente la mention 'EST OUI' dans PRFPAR1_LM
14 G.BUISSON 20/06/2006 :spot:12865 Le message d'alerte de la période exceptionnelle ne doit apparaitre que s'il s'agit d'une clôture trimestrielle (CLOSING_B = 1)
                        et pas lors d'une clôture mensuelle (CLOSING_B = 0)
15 G.BUISSON 14/11/2007 :spot:14286 Ajout d'un poste "Primes liées au Sinistres" pour les traités NON PROP Récupération du PRG_NF sur l'exercice courant du traité (TCONTR)
16 G.BUISSON 16/11/2007 :spot:11245 Neutralisation des postes Echéance et Rachat pour la Lob 31 Récupération de la Lob (LOB_CF de TSECTION)
17 Florent   08/09/2011 :spot:22315 ajout du type comptable de l'exercice
18 cycros 	 08/01/2013 : Omega2 Phase2B
19 A.Deshpande 20/08/2014 : Fetched PRG_NF properly
20 P.Colle 11/09/2014 : Upgrade perfromances
21. A.Deshpande 06/10/2014 - 031323 - blocking message when loading DAC on non existing UWY (acc type )= 1
22. A.Deshpande 19/11/2014 - Addded changes for EST 24 BT
23. A.Deshpande 18/05/2015 - Added ESTCR_BT - Estimation Type column for EST 41 evo card
24. A.Deshpande 23/07/2015 - 034897 EST24BT : Not posssible to load estimates when the IO GAAP = Manual 
25. A.Deshpande 12/01/2015 - Added for EXT-ESTLIFE-806641 - EST 30 - the "last update date" field in the estimate grid is not updated when the batch makes modifications 
26. Sumit Gupta 15/02/2016 - 45846 : Impossibility to update DAC estimates : Treaties DAC compute mode at Manual1 and DAC fields in IFRS GRID  disabled
27. Sumit Gupta 15/03/2016 - 46959 : EST30 /R3 : After havaing changed status, estimates are not accessible
28. Sumit Gupta 15/03/2016 - 48394 : EST30 / R3 : After change of status, estimates grid of previous UWY is not editable
29. D.Fillinger 06/09/2017 - 60970 : retrieve ESTCRB_CT for each line
30. D.BERTÉ 22/05/2018 - 63238 : SQL Exception in EST Domain
31. L. Wernert 17/01/2020 - 84119: TECH: Gestion des années futures au niveau Treaty
32. HR 23/03/2022 - 96107: Accès à la grille période exceptionnelle ( LIFE01)
*****************************************************/
declare @timestamp_grappe   Char(21),
        @erreur             Int,
        @ligne              Int,
		@DATE               Datetime,   -- date de recherche
		@END_D              Datetime,
        @bilan              Tinyint,    -- mois/année bilan entre début et fin pér. normale (1) ou except. (2)
        @TYPPER             Char(1),    -- type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)
        @BLCSHTYEA_NF       Smallint,
        @BLCSHTMTH_NF       Tinyint,
		@SPCEND_D           Datetime,
        @ACCOUNT_D          Datetime,   -- date de comptabilisation ( fin service )
        @CLOSING_B          Bit,        -- top inventaire groupe
        @habil_spec         Tinyint,    -- Profil TRT02 avec habilitation spéciale
		@next_period        Tinyint,    -- Mois de la prochaine periode normale
        @acy_sup            Smallint,   -- AC bilan + Upper bound (4)
        @acy_inf            Smallint,   -- AC bilan - lower boud (4)
		@ACCADMTYP_CT       UACCADMTYP_CT,
		@CTR_NF             UCTR_NF,    -- zones table Contrat TCONTR (base TRAITE)
        @END_NT             UEND_NT,
        @UW_NT              UUW_NT,
        @UWY_NF             UUWY_NF


DECLARE 
    @StartTime  datetime,
    @Time1      datetime,
    @Time2      datetime,
    @Time3      datetime,  
    @Time4      datetime,    
    @Time5      datetime,    
    @Time6      datetime  

SELECT @StartTime = GETDATE()


Create table #TMPPERIMETER (
    CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NOT NULL,
    UWY_NF      UUWY_NF       NOT NULL,
	MAXUWY_NF   	 UUWY_NF  NOT NULL,
    END_NT      UEND_NT       NOT NULL,
    UW_NT       UUW_NT        NOT NULL,
    SSD_CF      USSD_CF       NOT NULL,
    ESB_CF      UESB_CF       NOT NULL,
    USR_CF      UUSR_CF       NOT NULL,
    ACCADMTYP_CT UACCADMTYP_CT NULL) 
	
Create table #TLOADING (
    CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NOT NULL,
    UWY_NF      UUWY_NF       NOT NULL,
	MAXUWY_NF   	 UUWY_NF  NOT NULL,
    END_NT      UEND_NT       NOT NULL,
    UW_NT       UUW_NT        NOT NULL,
    SSD_CF      USSD_CF       NOT NULL,
    ESB_CF      UESB_CF       NOT NULL,
    USR_CF      UUSR_CF       NOT NULL,
    ACCADMTYP_CT UACCADMTYP_CT NULL,
	COMAC        bit      DEFAULT 0        NOT NULL,
    LIFCUR_CF  UCTR_NF      NULL) 

Create table #TLOADING2(
    CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NOT NULL,
    UWY_NF      UUWY_NF       NOT NULL,
	MAXUWY_NF   	 UUWY_NF  NOT NULL,
    END_NT      UEND_NT       NOT NULL,
    UW_NT       UUW_NT        NOT NULL,
    SSD_CF      USSD_CF       NOT NULL,
    ESB_CF      UESB_CF       NOT NULL,
    USR_CF      UUSR_CF       NOT NULL,
    ACCADMTYP_CT UACCADMTYP_CT NULL,
	COMAC        bit      DEFAULT 0        NOT NULL,
    LIFCUR_CF  UCTR_NF      NULL,
    DERNIER_TRAIT    Datetime 		NULL)      

	
Create table #TMPRESULT (
		CTR_NF           UCTR_NF 		NULL,
        END_NT           UEND_NT 		NULL,
        SEC_NF           USEC_NF 		NULL,
        UW_NT            UUW_NT 		NULL,
        UWY_NF           UUWY_NF 		NULL,
		MAXUWY_NF     UUWY_NF 		NULL,
        ACCADMTYP_CT     UACCADMTYP_CT	NULL,
		ACCADMTYP_LL     UL64 			NULL,
        SECCAN_D         Datetime 		NULL,
        GAR_CF           UGAR_CF 		NULL,
        FRSUWY_NF        UUWY_NF 		NULL,
        SECACCSTS_CT     UACCSTS_CT 	NULL,
        CLMFUNINT_R      USHORAT_R 		NULL,
        URRFUNINT_R      USHORAT_R 		NULL,
        CUR_CF           UCUR_CF 		NULL,
        SECSTS_CT        UCTRSTS_CT 	NULL,
        NAT_CF           UCTRNAT_CF 	NULL,
        LIFTRTTYP_CF     Char(2) 		NULL,
        RETRO            Tinyint 		NULL,
		monnaie         Tinyint 		NULL,
        DERNIER_TRAIT    Datetime 		NULL, 
        CMT_NT           UCMT_NT 		NULL,
        COMAC            Bit 			,
        CNATYP_CT        Char(1) 		NULL,
        CNATYP_LL        UL16 			NULL,
        PRG_NF           UCTRGRP_NF 	NULL,
        LOB_CF           ULOB_CF 		NULL,
		LOB_LS           UL64 			NULL,
		SOB_CF           USOB_CF 		NULL,
		SOB_LS           UL64 			NULL,
		TOP_CF           UTOP_CF 		NULL,
		TOP_LS           UL64 			NULL,
		GAR_LS           UL64 			NULL,
        EXE_ACCADMTYP_CT UACCADMTYP_CT 	NULL,
		CUR_ACCADMTYP_LL UL64 			NULL,
		CED_NF           UCLI_NF 		NULL,
		BOQ_NF           Int 			NULL,
		CUR_CFS          UCUR_CF 		NULL,
		USRCRTVAL_LM	 UL32			NULL,
		PARENTIOTYPE_CT  Tinyint 		NULL, -- MODIF 22 - EST 24 BT
		LOCALIOTYPE_CT   Tinyint 		NULL,-- MODIF 22 - EST 24 BT
		FROMRETROIO_B    UBOOLEAN_B,         -- MODIF 22 - EST 24 BT
        ESTCRB_CT        char(1)             -- MODIF 29
)	

-- 6 select dans BREF..TCALEND, Recherche de la période 'année' et 'mois' en cours
--   (execptionnelle à la date du jour)

/* Test SSD -- MODIF 30 */
if @p_SSD_CF = null
begin
    select @p_SSD_CF = 0
end
/* Test SSD -- MODIF 30 */

select @DATE = getdate(), @TYPPER = 'E'
execute @erreur = BREF..PsCALEND_02 @DATE,@TYPPER,@BLCSHTYEA_NF output,@BLCSHTMTH_NF output,@SPCEND_D output,@ACCOUNT_D output,@CLOSING_B output

if @erreur != 0
    begin
        Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND"
        return @erreur
    end

-- 13 select dans TLIFDRI, Top presence commentaires par AC
select @acy_sup = @blcshtyea_nf + @p_higher_bound_year, @acy_inf = @blcshtyea_nf - @p_lower_bound_year
	
/* Initialization of the ESTIMATES PERIMETER 
n lines for file loading
1 line for manual estimation
*/
IF (@p_loading_b = 1)
begin
	Insert into #TMPPERIMETER
	SELECT DISTINCT
		p.CTR_NF,
		p.SEC_NF,
		p.UWY_NF AS UWY_NF,
		p.UWY_NF AS MAXUWY_NF,
		p.END_NT,
		p.UW_NT,
		p.SSD_CF,
		p.ESB_CF,
		p.USR_CF,
		p.ACCADMTYP_CT
	FROM BTRAV..EST_ESID0811_PERIMETER p
	WHERE
			p.USR_CF = @p_usr_cf
		and p.ESB_CF = @p_esb_cf
		and p.SSD_CF = @p_ssd_cf
		and p.RETRO_B = 0
		and p.ERRORCODE_CT = null
end
ELSE
Begin

select  @ACCADMTYP_CT = ACCADMTYP_CT 
from    BTRT..TSECTION 
where   CTR_NF = @p_CTR_NF 
and     END_NT = @p_END_NT 
and     SEC_NF = @p_SEC_NF 
and     UW_NT  = @p_UW_NT 
and     UWY_NF = @UWY_NF


	Insert into #TMPPERIMETER
    Select
		@p_ctr_nf,
        @p_sec_nf,
        @p_uwy_nf AS UWY_NF,
        @p_uwy_nf AS MAXUWY_NF,
        @p_end_nt,
        @p_uw_nt,
        @p_ssd_cf,
        @p_esb_cf,
        @p_usr_cf,
        @ACCADMTYP_CT --As per the rule(R_ACCADMTYP_CT) associated to ACCADMTYP_CT which takes the values from 1 to 5 only
		   
    -- Modif 10, Appel de la procedure PSlocktab_01 : Ramène la tête de grappe
    -- No need to retrieve GRAPPE LOCK at file loading
    execute @erreur = BTEC..PsLOCKTAB_01 @p_CTR_NF, 'EST', @timestamp_grappe output
            
    if @erreur!=0 or @@error!=0 return 1
End

/* - Update of MAXUWY_NF used in the Insert in #TMPRESULT
   - Update of COMAC
   - Retrieve the LIF CUR_CF
*/
CREATE INDEX TMPPERIMETER_00 ON #TMPPERIMETER(CTR_NF, END_NT, UW_NT, SEC_NF) --20 Add index
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TMPPERIMETER"
        return @erreur
        goto fin
    end
	
INSERT INTO #TLOADING --20 begin Split Select statement 
Select
		tp.CTR_NF,
		tp.SEC_NF,
		tp.UWY_NF AS UWY_NF,
		MAX(s.UWY_NF) AS MAXUWY_NF,
		tp.END_NT,
		tp.UW_NT,
		tp.SSD_CF,
		tp.ESB_CF,
		tp.USR_CF,
		tp.ACCADMTYP_CT,
        0,
        null
FROM #TMPPERIMETER tp, BTRT..TSECTION s
WHERE
        	   s.CTR_NF     = tp.CTR_NF
        and    s.END_NT     = tp.END_NT
        and    s.UW_NT      = tp.UW_NT
        and    s.SEC_NF     = tp.SEC_NF
        and    s.SECSTS_CT in (14,16,17,19,22) -- Mod 27
GROUP BY 
        tp.CTR_NF,
		tp.SEC_NF,
		tp.UWY_NF,
        tp.END_NT,
        tp.UW_NT,
        tp.SSD_CF,
		tp.ESB_CF,
		tp.USR_CF,
		tp.ACCADMTYP_CT

UPDATE #TLOADING
SET COMAC = CASE WHEN dri.ctr_nf is null THEN 0 ELSE 1 END
FROM #TLOADING tp, BEST..TLIFDRI dri WHERE 
				  dri.CTR_NF        = tp.CTR_NF
           and    dri.END_NT        = tp.END_NT
           and    dri.UW_NT         = tp.UW_NT
           and    dri.SEC_NF        = tp.SEC_NF
           and    dri.BALSHEY_NF    = @BLCSHTYEA_NF
           and    dri.BALSHTMTH_NF <= @BLCSHTMTH_NF
           and    dri.ACY_NF       <= @acy_sup
           and    dri.ACY_NF       >= @acy_inf
           and    dri.CMT_NT       != 0

UPDATE #TLOADING
SET LIFCUR_CF =  lif.CUR_CF
FROM #TLOADING tp, BEST..TLIFEST lif WHERE
	   lif.CTR_NF     = tp.CTR_NF
and    lif.END_NT     = tp.END_NT
and    lif.UW_NT      = tp.UW_NT
and    lif.SEC_NF     = tp.SEC_NF
and    lif.BALSHEY_NF = @BLCSHTYEA_NF --20 End Split Select statement 
  
/* Retrieve DERNIER_TRAIT and ACCADMTYP 	
-- 11 select dans TLIFEST, date de dernier traitement, max de cre_d dans TLIFEST pour
--    le contrat, la section passés en parametre le bilan calcule et exercice passe en
--    parametre (pas le dernier exercice)
--    on retire de la selection les estimations crees par les arretes statistiques
--    (heure de cre_d = 23:59:59)                                                            
--    Modif GIBU le 03/02/2004 : on ne garde que les estimations passees avant 23:59
--    Modif GIBU le 25/05/2005 : Fiche Spot 10305, il n'y aplus de relation
--                               sur l'exercice pour les types 1 et 4*/
CREATE INDEX TLOADING_00 ON #TLOADING(CTR_NF, END_NT, SEC_NF, UW_NT) --20 Add Index
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLOADING"
        return @erreur
        goto fin
    end
	
Insert into #TLOADING2
Select 			    A1.CTR_NF,
                    A1.SEC_NF,
                    A1.UWY_NF,
					A1.MAXUWY_NF,
                    A1.END_NT,
                    A1.UW_NT,
                    A1.SSD_CF,
                    A1.ESB_CF,
                    A1.USR_CF,
                    s1.ACCADMTYP_CT,
                    A1.COMAC,
                    A1.LIFCUR_CF,
					MAX(lif1.CRE_D) AS DERNIER_TRAIT
FROM #TLOADING A1
LEFT OUTER JOIN BEST..TLIFEST lif1 on
		       lif1.CTR_NF                      = A1.CTR_NF
		and    lif1.END_NT                      = A1.END_NT
		and    lif1.SEC_NF                      = A1.SEC_NF
		and    lif1.UW_NT                       = A1.UW_NT
		and    lif1.BALSHEY_NF                  = @BLCSHTYEA_NF
		,--and    convert(char(5), lif1.CRE_D, 8) != '23:59', --Modif 25
BTRT..TSECTION s1
WHERE (s1.ACCADMTYP_CT = 1 or s1.ACCADMTYP_CT = 4)	
        and    s1.CTR_NF = A1.CTR_NF
        and    s1.END_NT = A1.END_NT
        and    s1.SEC_NF = A1.SEC_NF
        and    s1.UW_NT  = A1.UW_NT
        and    s1.UWY_NF = CASE WHEN A1.UWY_NF>A1.MAXUWY_NF THEN A1.MAXUWY_NF ELSE A1.UWY_NF END
GROUP BY A1.        CTR_NF,
                    A1.SEC_NF,
                    A1.UWY_NF,
					A1.MAXUWY_NF,
                    A1.END_NT,
                    A1.UW_NT,
                    A1.SSD_CF,
                    A1.ESB_CF,
                    A1.USR_CF,
                    s1.ACCADMTYP_CT,
                    A1.COMAC,
                    A1.LIFCUR_CF
UNION
Select 
					A2.CTR_NF,
                    A2.SEC_NF,
                    A2.UWY_NF,
					A2.MAXUWY_NF,
                    A2.END_NT,
                    A2.UW_NT,
                    A2.SSD_CF,
                    A2.ESB_CF,
                    A2.USR_CF,
                    s2.ACCADMTYP_CT,
                    A2.COMAC,
                    A2.LIFCUR_CF,
					MAX(lif2.CRE_D) AS DERNIER_TRAIT
FROM #TLOADING A2
LEFT OUTER JOIN BEST..TLIFEST lif2 ON
			   lif2.CTR_NF                    = A2.CTR_NF
        and    lif2.END_NT                      = A2.END_NT
        and    lif2.SEC_NF                      = A2.SEC_NF
        and    lif2.UW_NT                       = A2.UW_NT
        and    lif2.UWY_NF                      = A2.UWY_NF
        and    lif2.BALSHEY_NF                  = @BLCSHTYEA_NF
       ,-- and    convert(char(5), lif2.CRE_D, 8) != '23:59',--Modif 25
BTRT..TSECTION s2
WHERE (s2.ACCADMTYP_CT != 1 and s2.ACCADMTYP_CT != 4)
        and    s2.CTR_NF = A2.CTR_NF
        and    s2.END_NT = A2.END_NT
        and    s2.SEC_NF = A2.SEC_NF
        and    s2.UW_NT  = A2.UW_NT
        and    s2.UWY_NF = CASE WHEN A2.UWY_NF>A2.MAXUWY_NF THEN A2.MAXUWY_NF ELSE A2.UWY_NF END
GROUP BY            A2.CTR_NF,
                    A2.SEC_NF,
                    A2.UWY_NF,
					A2.MAXUWY_NF,
                    A2.END_NT,
                    A2.UW_NT,
                    A2.SSD_CF,
                    A2.ESB_CF,
                    A2.USR_CF,
                    s2.ACCADMTYP_CT,
                    A2.COMAC,
                    A2.LIFCUR_CF
 
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLOADING"
        return @erreur
    end
 
/* Retrieve information for different places like TCONTR, TSECTION, TBANTECL, etc... 
 10 select dans TLIFEST : Monnaie des estimations
    Maj @monnaie : valeur 1 si la monnaie estimation existe et est différente de
    la monnaie de la section, valeur 0 sinon   */

Insert into #TMPRESULT
select  CTR_NF           = t.CTR_NF, 				
        END_NT           = t.END_NT,				
        SEC_NF           = t.SEC_NF,				
        UW_NT            = t.UW_NT,					
        UWY_NF           = t.UWY_NF,
		MAXUWY_NF        = t.MAXUWY_NF,
		ACCADMTYP_CT     = t.ACCADMTYP_CT,
		ACCADMTYP_LL     = tb.colval_ls,
		SECCAN_D         = CASE s.SECCAN_D WHEN null THEN sec.SECCAN_D ELSE s.SECCAN_D END, --MOD 28
		GAR_CF  	     = CASE s.GAR_CF WHEN null THEN sec.GAR_CF ELSE s.GAR_CF END, --MOD 28
		FRSUWY_NF	     = CASE s.FRSUWY_NF WHEN null THEN sec.FRSUWY_NF ELSE s.FRSUWY_NF END, --MOD 28
		SECACCSTS_CT 	 = CASE WHEN (t.ACCADMTYP_CT = 1 OR t.ACCADMTYP_CT = 4) THEN sec.SECACCSTS_CT ELSE s.SECACCSTS_CT END,
		URRFUNINT_R 	 = tfam.URRFUNINT_R,
		CLMFUNINT_R 	 = tfam.CLMFUNINT_R,
		CUR_CF			 = CASE WHEN t.LIFCUR_CF != sec.PCPCUR_CF THEN t.LIFCUR_CF ELSE sec.PCPCUR_CF END,
		SECSTS_CT        = CASE s.SECSTS_CT WHEN null THEN sec.SECSTS_CT ELSE s.SECSTS_CT END, --MOD 28
		NAT_CF       	 = CASE s.NAT_CF WHEN null THEN sec.NAT_CF ELSE s.NAT_CF END, --MOD 28
		LIFTRTTYP_CF	 = ctr.LIFTRTTYP_CF,
		RETRO 			 = CASE WHEN cli.CLISSD_CF != null THEN 1 ELSE 0 END,
		monnaie          = CASE WHEN t.LIFCUR_CF != sec.PCPCUR_CF THEN 1 ELSE 0 END,
		DERNIER_TRAIT    = t.DERNIER_TrAIT,
		CMT_NT           = dria.cmt_nt,
		COMAC			 = t.COMAC,
		CNATYP_CT        = CASE @p_SSD_CF WHEN 14 THEN '3' ELSE (CASE WHEN t.MAXUWY_NF >= t.UWY_NF THEN oldctr.cnatyp_ct ELSE ctr.cnatyp_ct END) END, --MOD21 --MOD26
        CNATYP_LL        = CASE @p_SSD_CF WHEN 14 THEN 'Manuel 2' ELSE bctr.COLVAL_LS END,
		PRG_NF			 = isnull(Rtrim(Ltrim(ctr.PRG_NF)), '0'),
	    LOB_CF 		     = CASE sec.LOB_CF WHEN '31' THEN '1' ELSE '0' END, -- Conversion de la LOB
		LOB_LS    	     = T4.LOB_GS,	
		SOB_CF     		 = CASE s.SOB_CF WHEN null THEN sec.SOB_CF ELSE s.SOB_CF END,
		SOB_LS       	 = T5.SOB_GS,	
		TOP_CF      	 = CASE s.TOP_CF WHEN null THEN sec.TOP_CF ELSE s.TOP_CF END,
		TOP_LS		     = T7.TOP_GS,		
		GAR_LS           = T6.GAR_GS,
		EXE_ACCADMTYP_CT = CASE s.ACCADMTYP_CT WHEN null THEN sec.ACCADMTYP_CT ELSE s.ACCADMTYP_CT END, --modif 15 --MOD 28
		CUR_ACCADMTYP_LL = CASE tb.colval_ls WHEN null THEN tb2.colval_ls ELSE tb.colval_ls END, --modif 15	--MOD 28
		CED_NF 			 = ctr.CED_NF, 
        BOQ_NF			 = isnull(Len(Rtrim(Ltrim(ctr.BOQ_NF))), 0),
		CUR_CFS 	     = CASE s.PCPCUR_CF WHEN null THEN sec.PCPCUR_CF ELSE s.PCPCUR_CF END,      -- zones table TSECTION - monnaie section (base Traité) ?????????????????????????
  		USRCRTVAL_LM 	 = CASE s.USRCRTVAL_LM WHEN null THEN sec.USRCRTVAL_LM ELSE s.USRCRTVAL_LM END,
		PARENTIOTYPE_CT  = CASE WHEN sec.PARENTGAAPIO_CT = null THEN 1 ELSE sec.PARENTGAAPIO_CT END , -- MODIF 22 - EST 24 BT
		LOCALIOTYPE_CT   = CASE WHEN sec.LOCALGAAPIO_CT = null THEN 1 ELSE sec.LOCALGAAPIO_CT END ,  -- MODIF 22 - EST 24 BT
		FROMRETROIO_B    = CASE WHEN cli.CLISSD_CF != null THEN 1 ELSE 0 END , -- MODIF 22 - EST 24 BT
        ESTCRB_CT        = ctr.ESTCRB_CT -- MODIF 29
FROM 
#TLOADING2 t 
-- 2 select dans TCONTR : N° de cédante (correspondant au dernier ex de souscription)
--   Modif 3 : Caractérisation Affaire (donnée VIE)
-- Recherche du programme pour déterminer s'il s'agit d'un traité non proportionnel
LEFT OUTER JOIN BTRT..TCONTR ctr ON
	   ctr.CTR_NF = t.CTR_NF
and    ctr.END_NT = t.END_NT
and    ctr.UW_NT  = t.UW_NT
--and    ctr.UWY_NF = t.MAXUWY_NF
-- 14 select dans TCONTR (exercice parametre) du type de calcul des CNA et de son
-- libelle dans BREF..TBANTECL
LEFT OUTER JOIN BTRT..TCONTR oldctr ON
	   oldctr.CTR_NF    = t.CTR_NF
and    oldctr.END_NT    = t.END_NT
and    oldctr.UW_NT     = t.UW_NT
and    oldctr.UWY_NF    = CASE WHEN t.UWY_NF<=t.MAXUWY_NF THEN t.UWY_NF ELSE t.MAXUWY_NF END
LEFT OUTER JOIN BREF..TBANTECL bctr ON
       oldctr.CNATYP_CT = bctr.colval_ct
and    bctr.COL_LS    = 'CNATYP_CT'
and    bctr.LAG_CF    = @p_LANGUE
-- 3 select dans TCLIENT : Position hiérarchique du client
LEFT OUTER JOIN BCLI..TCLIENT cli ON
	   cli.CLI_NF = ctr.CED_NF
-- Si type comptable = 1 ou 4, l'état comptable est celui de la section courante
LEFT OUTER JOIN BTRT..TSECTION sec ON	   
			   sec.CTR_NF = t.CTR_NF
        and    sec.END_NT = t.END_NT
        and    sec.SEC_NF = t.SEC_NF
        and    sec.UW_NT  = t.UW_NT
        and    sec.UWY_NF = t.MAXUWY_NF
LEFT OUTER JOIN BREF..TBANTECL tb2 ON
				convert(tinyint, tb2.colval_ct) = sec.ACCADMTYP_CT AND
				tb2.col_ls = 'ACCADMTYP_CT' AND 
				tb2.lag_cf = @p_LANGUE		
-- 5 select dans TFAMFUNW, Taux d'intêrêt dépôt espèces primes + Taux d'intêrêt dépôt
-- espèces sinistre (correspondant au dernier ex de souscription)
LEFT OUTER JOIN BTRT..TFAMFUNW tfam ON
	   tfam.CTR_NF = t.CTR_NF
and    tfam.END_NT = t.END_NT
and    tfam.SEC_NF = t.SEC_NF
and    tfam.UW_NT  = t.UW_NT
and    tfam.UWY_NF = t.MAXUWY_NF
-- 12 select dans TLIFDRI, Commentaire general
LEFT OUTER JOIN BEST..TLIFDRI dria ON
	   dria.CTR_NF       = t.CTR_NF
and    dria.END_NT       = t.END_NT
and    dria.SEC_NF       = t.SEC_NF
and    dria.UW_NT        = t.UW_NT
and    dria.UWY_NF       = CASE WHEN t.UWY_NF<=t.MAXUWY_NF THEN t.UWY_NF ELSE t.MAXUWY_NF END
and    dria.BALSHEY_NF   = 1900
and    dria.BALSHTMTH_NF = 1
and    dria.ACY_NF       = 1900
and    dria.CRE_D        = (select max(drib.CRE_D)
                         from   BEST..TLIFDRI drib
                         where  dria.CTR_NF     = drib.CTR_NF
                         and    dria.END_NT       = drib.END_NT
                         and    dria.SEC_NF       = drib.SEC_NF
                         and    dria.UW_NT        = drib.UW_NT
                         and    dria.UWY_NF       = drib.UWY_NF
                         and    drib.BALSHEY_NF   = 1900
                         and    drib.BALSHTMTH_NF = 1
                         and    drib.ACY_NF       = 1900),
-- 4 select dans TSECTION  (correspondant au dernier ex de souscription)
--   Modif 3 : Etat de la section, Type comptable, Date de résiliation, Garantie,
--             Premier exercice de souscription, Monnaie section
BTRT..TSECTION s
LEFT OUTER JOIN
             BREF..TLOBL T4 ON
				T4.LOB_CF = s.LOB_CF AND
				T4.LAG_CF = @p_LANGUE
		LEFT OUTER JOIN
			 BREF..TSOBL T5 ON
				T5.SOB_CF = s.SOB_CF AND
				T5.LAG_CF = @p_LANGUE
		LEFT OUTER JOIN
			BREF..TGARL T6 ON
				T6.GAR_CF = s.GAR_CF AND
				T6.LAG_CF = @p_LANGUE
		LEFT OUTER JOIN
			BREF..TTOPL T7 ON
				T7.TOP_CF = s.TOP_CF AND
				T7.LAG_CF = @p_LANGUE
		LEFT OUTER JOIN
			BREF..TBANTECL tb ON
				convert(tinyint, tb.colval_ct) = s.ACCADMTYP_CT AND
				tb.col_ls = 'ACCADMTYP_CT' AND 
				tb.lag_cf = @p_LANGUE
where   s.CTR_NF = t.CTR_NF
and     s.END_NT = t.END_NT
and     s.SEC_NF = t.SEC_NF
and     s.UW_NT  = t.UW_NT
and     s.UWY_NF = CASE WHEN t.UWY_NF<=t.MAXUWY_NF THEN t.UWY_NF ELSE t.MAXUWY_NF END
		
-- 7 select dans TBLCSHTD : Date de fin de période normale

select @END_D = END_D
from   BCTA..TBLCSHTD
where  SSD_CF       = @p_SSD_CF
and    ESB_CF       = @p_ESB_CF
and    DIR_CF       = @p_DIR_CF
and    DMN_CF       = @p_DMN_CF
and    BLCSHTYEA_NF = @BLCSHTYEA_NF
and    BLCSHTMTH_NF = @BLCSHTMTH_NF

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TBLCSHTD"
        return 1
    end

-- 8 Si date du jour <= Date de fin de période normale @bilan = 1(normal), sinon
--   @bilan = 2(exceptionnel)

if @DATE <= @END_D
    select @bilan = 1
else
    select @bilan = 2

-- 8 bis : Si on est en période exceptionnelle, il faut rechercher si le
--         user a une habilitation spéciale (profil TRT02 avec mention 'EST OUI' )

select @habil_spec = 0

select @habil_spec = 1
from   BREF..TROLES a, BREF..TPROFIL b
where  a.USR_CF   = user
and    a.APP_CF   = 'EST'
and    a.PRF_CF   = 'TRT02'
and    a.APP_CF   = b.APP_CF
and    a.PRF_CF   = b.PRF_CF
and    PRFPAR1_LM = 'EST OUI'

-- 8 ter : Si le paramètre CLOSING_B = 0, il s'agit d'une clôture mensuelle et non
--         trimestrielle. Il n'y a donc pas lieu de bloquer

if @CLOSING_B = 0
    begin
        select @habil_spec = 1
    end

-- 9 Recherche dans BCTA..TBLCSHTD du mois correspondant a la prochaine periode normale
--   La prochaine periode normale est celle qui commence apres la fin de la periode
--   comptable en cours dans TBLCSHTD

select @next_period = 0

select @next_period = isnull(Min(BLCSHTMTH_NF), 0)   -- MOD011 isnull(BLCSHTMTH_NF, 0)
from   BCTA..TBLCSHTD
where  SSD_CF        = @p_SSD_CF
and    ESB_CF        = @p_ESB_CF
and    DIR_CF        = @p_DIR_CF
and    DMN_CF        = @p_DMN_CF
and    BLCSHTYEA_NF  = @BLCSHTYEA_NF
and    STR_D        !< @END_D

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TBLCSHTD"
        return 1
    end
	
-- si pas de nexte_periode sur l'annee bilan @BLCSHTYEA_NF au mois 12 alors next_period est forcement sur @BLCSHTYEA_NF + 1
if @next_period = 0 AND @BLCSHTMTH_NF = 12
begin
	select @next_period = isnull(Min(BLCSHTMTH_NF), 0)   -- MOD011 isnull(BLCSHTMTH_NF, 0)
	from   BCTA..TBLCSHTD
	where  SSD_CF        = @p_SSD_CF
	and    ESB_CF        = @p_ESB_CF
	and    DIR_CF        = @p_DIR_CF
	and    DMN_CF        = @p_DMN_CF
	and    BLCSHTYEA_NF  = @BLCSHTYEA_NF + 1
	and    STR_D        !< @END_D

	select @erreur = @@error
	if @erreur != 0
	begin
		Raiserror 20003 "APPLICATIF;TBLCSHTD"
		return 1
	end
end

/* Final Select */
select  CTR_NF           = t.CTR_NF, 				--done
        END_NT           = t.END_NT,				--done
        SEC_NF           = t.SEC_NF,				--done
        UW_NT            = t.UW_NT,					--done
        UWY_NF           = t.MAXUWY_NF,			--done
        OLDUWY_NF        = t.UWY_NF,
        ACCADMTYP_CT     = t.ACCADMTYP_CT,			--done
        ACCADMTYP_LL     = t.ACCADMTYP_LL,			--done
        SECCAN_D         = CONVERT(varchar(50), t.SECCAN_D,113) + ' ' + CONVERT(varchar(50), t.SECCAN_D,20),
        GAR_CF           = t.GAR_CF,				--done
        FRSUWY_CF        = t.FRSUWY_NF,				--done
        SECACCSTS_CT     = t.SECACCSTS_CT,			--done
        CLMFUNINT_R      = t.CLMFUNINT_R * 100, 	--done
        URRFUNINT_R      = t.URRFUNINT_R * 100,	 	--done
        BLCSHTYEA_NF     = @BLCSHTYEA_NF,			--var
        BLCSHTMTH_NF     = @BLCSHTMTH_NF,			--var
        CUR_CF           = t.CUR_CF,				--done
        SECSTS_CT        = t.SECSTS_CT,             --done
        NAT_CF           = t.NAT_CF,				--done
        LIFTRTTYP_CF     = t.LIFTRTTYP_CF,			--done
        BILAN            = @bilan,					--var
        RETRO            = t.retro,					--done
        MONNAIE          = t.monnaie,				--done
        VISU_YEA         = 0,						--0
        VISU_MTH         = 0,						--0
        EXERCICE         = 0,						--0
        VAL_EXERCICE     = 0,						--0
        DERNIER_TRAIT    = CONVERT(varchar(50), t.DERNIER_TRAIT,113) + ' ' + CONVERT(varchar(50), t.DERNIER_TRAIT,20),
        CMT_NT           = t.cmt_nt,				--done
        COMAC            = t.comac,					--done
        CNATYP_CT        = t.cnatyp_ct,				--done
        CNATYP_LL        = t.cnatyp_ll,				--done
        NEXT_PERIOD      = @next_period,			--var
        TIMESTAMP_GRAPPE = @timestamp_grappe,		--var
        HABIL_SPEC       = @habil_spec,			    --var
        PRG_NF           = t.prg_nf,				--done
        LOB_CF           = t.lob_cf,				--done
		LOB_LS           = t.lob_ls,				--done
		SOB_CF           = t.sob_cf,				--done
		SOB_LS           = t.sob_ls,				--done
		TOP_CF           = t.top_cf,				--done
		TOP_LS           = t.top_ls,				--done
		GAR_LS           = t.gar_ls,				--done
        EXE_ACCADMTYP_CT = t.EXE_ACCADMTYP_CT,		--done
		CUR_ACCADMTYP_LL = t.CUR_ACCADMTYP_LL,		--done
		CED_NF           = t.CED_NF,				--done
		BOQ_NF           = t.boq_nf,				--done
		USRCRTVAL_LM	 = t.usrcrtval_lm,			--done
		SSDRTO_B		 = 0,						--0
		TERCTR_B		 = 0,						--0
		CONRETCTR_B		 = 0,						--0
		RETSIGSHA_R      = 0,						--0
		PARTIC           = 0,						--0
		RETCTRCAT_CF	 = 0,						--0
		PARENTIOTYPE_CT  = t.PARENTIOTYPE_CT,		-- MODIF 22 - EST 24 BT
		LOCALIOTYPE_CT   = t.LOCALIOTYPE_CT,		-- MODIF 22 - EST 24 BT
		FROMRETROIO_B    = t.FROMRETROIO_B,			-- MODIF 22 - EST 24 BT
		ESTCRB_CT		 = t.ESTCRB_CT 				-- MODIF 29
FROM #TMPRESULT t

fin:
if object_id('#TMPRESULT')     is not null drop Table #TMPRESULT
if object_id('#TLOADING2')     is not null drop Table #TLOADING2
if object_id('#TLOADING')     is not null drop Table #TLOADING
if object_id('#TMPPERIMETER')     is not null drop Table #TMPPERIMETER


return 0
go
EXEC sp_procxmode 'PsLIFEST_01_O2', 'unchained'
go
IF OBJECT_ID('PsLIFEST_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFEST_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFEST_01_O2 >>>'
go
GRANT EXECUTE ON PsLIFEST_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFEST_01_O2 TO GDBBATCH
go
