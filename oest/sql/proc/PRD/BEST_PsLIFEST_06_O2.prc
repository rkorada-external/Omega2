USE BEST
go
IF OBJECT_ID('PsLIFEST_06_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsLIFEST_06_O2
    IF OBJECT_ID('PsLIFEST_06_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsLIFEST_06_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsLIFEST_06_O2 >>>'
END
go
create procedure PsLIFEST_06_O2
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
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)
Date de creation         : 07 mai 1997
Description du programme : Sélection d'enregistrement dans RETRO et COMPTA : Info géné d'un traité Rétro dont on liste et maj
                           les estimations.
Conditions d'execution   :
Commentaires             :
_________________
MODIFICATIONS
1  L.DEBEVER 28/04/1998 Rajout "Rétro particulière O/N" et "somme des parts placées" dans select final
2  L.DEBEVER 19/04/1999 Deux select dans RETCTR / exc de souscription le plus récent 1 pour select 'état traité', un pour les autres info ????
                               => tout dans le même select.
3  G.BUISSON 04/02/2003 Recuperation du max de CRE_D dans LIFEST pour alimenter la date de dernier traitement (on ne prend pas
                         en compte les estimations creees par les arretes statistiques (heure de cre_d = 23:59:59)
4  G.BUISSON 24/02/2003 Pour determiner la retro particuliere on ne garde que RETCTRCAT_CF = '06', les autres etant destines aux facs
                         Recuperation du conretctr_b pour alimenter le champ "Mise a Jour Automatique" Recuperation du commentaire general sur TLIFDRI sur
                         contrat/exercice/section, bilan = 1900, mois = 01 AC = 1900 Recuperation du top presence de commentaires par AC
5  G.BUISSON 09/07/2003 Recherche dans BCTA..TBLCSHTD de la periode normale suivante pour deblocage de la saisie estimation en periode exceptionnelle
6  G.BUISSON 03/02/2004 Les as ne sont plus generes a 23:59:59 mais a 23:59:xx De ce fait on ne prend plus en compte les estimations dont l'heure est 23:59
7  Florent   03/09/2004 EST10260, gestion des grappes
8  G.BUISSON 25/05/2005 :spot:10305 La date de dernière mise à jour ne doit plus dépendre de l'exercice pour les traités de type 1 et 4
9  G.BUISSON 20/06/2005 :spot:11214 Permettre la saisie en période exceptionnelle si l'utilisateur a le profil TRT02 et que ce profil présente la mention 'EST OUI' dans PRFPAR1_LM
10 G.BUISSON 15/11/2007 :spot:14286 Ajout d'un poste "Primes liées au Sinistres" pour les traités NON PROP Récupération du PRG_NF sur l'exercice courant du traité (TCONTR)
11 G.BUISSON 16/11/2007 :spot:11245 Neutralisation des postes Echéance et Rachat pour la Lob 31 Récupération de la Lob (LOB_CF de TRETSEC)
12 T.RIPERT  24/09/2010 :spot:19247 Alimentation indicateur rétro interne (@SSDRTO_B)
13 D.OURMIAH 17/05/2011 :spot:21693 Si la devise au niveau de la section retro est renseignee, elle sera prise a la place de la devise de representation
14 Florent   05/09/2011 :spot:21784 Si au moins un placement du CTR est externe alors rétro interne = 0
15 Florent   08/09/2011 :spot:22315 ajout du type comptable de l'exercice
16 P.PEZOUT  28/03/2013 :spot:21693 ANNULATION DE LA SPOT 21693
17 C.CROS	 10/01/2014 :Omega2 Phase2B
18 KBagwe	 16/04/2014 :Updated retro = 1 in final select as sp is for Retro.
19 A.Deshpande 20/08/2014 : Fetched PRG_NF properly
20 A.Deshpande 08/10/2014 : SPira 31585
21 A. Deshpande 08/01/2015 : commented out r.RTY_NF = tp.UWY_NF -- modif 21
22 A. Deshpande 17/04/2015 : EST 29 - Improvements on Retro Life Estimates
23. A.Deshpande 19/11/2014 : Addded changes for EST 24 BT
24. A.Deshpande 19/05/2015 : Production crash in case of retro contracts as under writing order is not set to 1.
25. A.Deshpande 26/05/2015 : Added ESTCRB_CT for EST 41 / EST 39
26. A.Deshpande 01/06/2015 : EST 29 change for Spira 037376
27. Riyadh : Change for defect 69983 Added ESTCRB value instead of empty value 
28. HR : SPIRA 98570 Message devise sur grille
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
		@RETACCTYP_CT 		tinyint,
        @estcrb_ct  char(1) 
        


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
	COMAC            Bit 			,
	LIFCUR_CF  UCTR_NF      NULL)

Create table #TLOADING2 (
    CTR_NF       UCTR_NF       	NOT NULL,
    SEC_NF       USEC_NF       	NOT NULL,
    UWY_NF       UUWY_NF       	NOT NULL,
	MAXUWY_NF    UUWY_NF 	    NOT NULL,
    END_NT       UEND_NT       	NOT NULL,
    UW_NT        UUW_NT        	NOT NULL,
    SSD_CF       USSD_CF       	NOT NULL,
    ESB_CF       UESB_CF       	NOT NULL,
    USR_CF       UUSR_CF       	NOT NULL,
	ACCADMTYP_CT UACCADMTYP_CT	NULL,
	COMAC        Bit 			    ,
	LIFCUR_CF    UCTR_NF      	NULL,
    DERNIER_TRAIT Datetime 	NULL,
	TERCTR_B      bit          		,
	LIFTRTTYP_CF     Char(2) 	NULL,
	FRSUWY_NF        UUWY_NF 	NULL,
	SECCAN_D         Datetime 	NULL) 	
	
Create table #TMPRESULT (
		CTR_NF           UCTR_NF 		NULL,
        END_NT           UEND_NT 		NULL,
        SEC_NF           USEC_NF 		NULL,
        UW_NT            UUW_NT 		NULL,
        UWY_NF           UUWY_NF 		NULL,
		MAXUWY_NF     UUWY_NF 			NULL,
        ACCADMTYP_CT     UACCADMTYP_CT	NULL,
		ACCADMTYP_LL     UL64 			NULL,
        SECCAN_D         Datetime 		NULL,
        GAR_CF           UGAR_CF 		NULL,
        FRSUWY_NF        UUWY_NF 		NULL,
        CLMFUNINT_R      USHORAT_R 		NULL,
        URRFUNINT_R      USHORAT_R 		NULL,
        CUR_CF           UCUR_CF 		NULL,
        SECSTS_CT        UCTRSTS_CT 	NULL,
        NAT_CF           UCTRNAT_CF 	NULL,
        LIFTRTTYP_CF     Char(2) 		NULL,
		monnaie         Tinyint 		NULL,
        DERNIER_TRAIT    Datetime 		NULL, 
        CMT_NT           UCMT_NT 		NULL,
        COMAC            Bit 			,
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
		CUR_CFS          UCUR_CF 		NULL,
		USRCRTVAL_LM	 UL32			NULL,
		RETCTRCAT_CF     char(2)	    NULL,
		partic           Tinyint        NULL,
		TERCTR_B   		 bit            ,
		CONRETCTR_B   	 bit            ,
		--RETSIGSHA_R      USHA_R         NULL,
        RETSIGSHA_R      USHORAT_R         NULL,
		SSDRTO_B         bit,
		PARENTIOTYPE_CT  Tinyint 		NULL,	-- MODIF 23 - EST 24 BT
		LOCALIOTYPE_CT   Tinyint 		NULL,	-- MODIF 23 - EST 24 BT
		FROMRETROIO_B    UBOOLEAN_B				-- MODIF 23 - EST 24 BT
)		
	
	
	




	/**********************************************************************************************/
/* 7- select dans BREF..TCALEND                                                               */
/* Recherche de la période 'année' et 'mois' en cours  ( execptionnelle à la date du jour )   */
/**********************************************************************************************/
select @DATE   = getdate()
select @TYPPER = 'E'

execute @erreur = BREF..PsCALEND_02 @DATE ,
                                    @TYPPER ,
                                    @BLCSHTYEA_NF output,
                                    @BLCSHTMTH_NF output,
                                    @SPCEND_D     output,
                                    @ACCOUNT_D    output,
                                    @CLOSING_B    output
if @erreur != 0
begin
    Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND" /* erreur de lecture */
    return @erreur
end

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
		and p.RETRO_B = 1
		and p.ERRORCODE_CT = null
end
ELSE
Begin

select  @RETACCTYP_CT = RETACCTYP_CT 
from   BRET..TRETCTR
where  RETCTR_NF = @p_CTR_NF
and    RTY_NF    = @p_UWY_NF


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
        @RETACCTYP_CT
		   
    -- Modif 10, Appel de la procedure PSlocktab_01 : Ramène la tête de grappe
    -- No need to retrieve GRAPPE LOCK at file loading
    execute @erreur = BTEC..PsLOCKTAB_01 @p_CTR_NF, 'EST', @timestamp_grappe output
            
    if @erreur!=0 or @@error!=0 return 1
End


/* - Update of MAXUWY_NF used in the Insert in #TMPRESULT
   - Update of COMAC
   - Retrieve the LIF CUR_CF
*/
/* 1- select dans TRETCTR :                                                                 */
/*  Exercice de souscription le plus récent où l'état du contrat est ... :                  */
/*         - Valide (code 03)                                                               */
/*         - Résilié (code 19)                                                              */


Insert into #TLOADING
Select
		tp.CTR_NF,
		tp.SEC_NF,
		tp.UWY_NF AS UWY_NF,
		MAX(sec.RTY_NF) AS MAXUWY_NF, -- MODIF 23 - EST 24 BT sec instead of r
		tp.END_NT,
		tp.UW_NT,
		tp.SSD_CF,
		tp.ESB_CF,
		tp.USR_CF,
		CASE WHEN dri.ctr_nf is null THEN 0 ELSE 1 END,
		lif.CUR_CF
FROM #TMPPERIMETER tp
/*********************************************************************************************/
/* 14- select dans TLIFDRI                                                                   */
/*    Top presence commentaires par AC                                                             */
/*********************************************************************************************/
LEFT OUTER JOIN  BEST..TLIFDRI dri ON
				  dri.CTR_NF        = tp.CTR_NF
           and    dri.END_NT        = tp.END_NT
           and    dri.SEC_NF        = tp.SEC_NF
           and    dri.UW_NT         = tp.UW_NT
           and    dri.BALSHEY_NF    = @BLCSHTYEA_NF
           and    dri.BALSHTMTH_NF <= @BLCSHTMTH_NF
           and    dri.ACY_NF       <= @acy_sup
           and    dri.ACY_NF       >= @acy_inf
           and    dri.CMT_NT       != 0
LEFT OUTER JOIN BEST..TLIFEST lif ON
	   lif.CTR_NF     = tp.CTR_NF
and    lif.END_NT     = tp.END_NT
and    lif.SEC_NF     = tp.SEC_NF
and    lif.UW_NT      = tp.UW_NT
and    lif.BALSHEY_NF = @BLCSHTYEA_NF
and    lif.CRE_D      = (select max(lifcred.CRE_D)
						 from   BEST..TLIFEST lifcred
                         where  lif.CTR_NF			= lifcred.CTR_NF
                         and    lif.END_NT			= lifcred.END_NT
                         and    lif.SEC_NF			= lifcred.SEC_NF
                         and    lif.UW_NT			= lifcred.UW_NT
                         and    lif.UWY_NF			= lifcred.UWY_NF
                         and    lifcred.BALSHEY_NF	= @BLCSHTYEA_NF) --MODIDF - 22
, BRET..TRETCTR r
, BRET..TRETSEC sec -- modif 21
WHERE
        	   r.RETCTR_NF     = tp.CTR_NF
        and   (r.RETCTRSTS_CT = 3 or r.RETCTRSTS_CT = 19 or r.RETCTRSTS_CT = 20)
       -- and   r.RTY_NF = tp.UWY_NF -- MODIF 23 - EST 24 BT
        and   tp.CTR_NF = sec.RETCTR_NF -- MODIF 23 - EST 24 BT
        and   tp.SEC_NF = sec.RETSEC_NF	-- MODIF 23 - EST 24 BT
GROUP BY 
        tp.CTR_NF,
		tp.SEC_NF,
		tp.UWY_NF,
        tp.END_NT,
        tp.UW_NT,
        tp.SSD_CF,
		tp.ESB_CF,
		tp.USR_CF,
		tp.ACCADMTYP_CT,
        dri.ctr_nf,
        lif.CUR_CF


/*********************************************************************************************/
/* 12- select dans TLIFEST                                                                   */
/*    date de dernier traitement                                                             */
/*    max de cre_d dans TLIFEST pour le contrat, la section passés en parametre le bilan     */
/*    calcule et exercice passe en parametre (pas le dernier exercice)                       */
/*    on retire de la selection les estimations crees par les arretes statistiques           */
/*    (heure de cre_d = 23:59:59)                                                            */
/*                                                                                           */
/*    L'heure des as a change donc on retire toutes les estimations dont l'heure est 23:59   */
/*                                                                                           */
/*********************************************************************************************/
/********************************************************************************************/
/* 2- select dans TRETCTR (correspondant au dernier ex de souscription) :                   */
/*  Modif 2 : Etat du contrat le plus récent                                                */
/*  Filiale rétrocessionnaire O/N (ie rétro interne O/N)                                    */
/*    Devise rétro de représentation                                                        */
/*    Rétrocession particulière (code 5,6,7,8)                                              */
/*    Date de résiliation                                                                   */
/*    Type de comptabilisation Retro suit Acceptation O/N                                   */
/*    Terminé comptablement O/N                                                             */
/********************************************************************************************/
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
                    s1.RETACCTYP_CT AS ACCADMTYP_CT,
					A1.COMAC,
                    A1.LIFCUR_CF,
					MAX(lif1.CRE_D) AS DERNIER_TRAIT,
					s1.TERCTR_B,
					s1.LIFTRTTYP_CF,
					datepart(yy,s1.ctrinc_d) AS FRSUWY_NF,
					s1.CAN_DT AS SECCAN_D
FROM #TLOADING A1
LEFT OUTER JOIN BEST..TLIFEST lif1 on
		       lif1.CTR_NF                      = A1.CTR_NF
		and    lif1.END_NT                      = A1.END_NT
		and    lif1.SEC_NF                      = A1.SEC_NF
		and    lif1.UW_NT                       = A1.UW_NT
		and    lif1.BALSHEY_NF                  = @BLCSHTYEA_NF
		,--and    convert(char(5), lif1.CRE_D, 8) != '23:59',
BRET..TRETCTR s1
WHERE (s1.RETACCTYP_CT = 1 or s1.RETACCTYP_CT = 4)	
        and    s1.RETCTR_NF = A1.CTR_NF
        and    s1.RTY_NF = A1.MAXUWY_NF
GROUP BY 			A1.CTR_NF,
                    A1.SEC_NF,
                    A1.UWY_NF,
					A1.MAXUWY_NF,
                    A1.END_NT,
                    A1.UW_NT,
                    A1.SSD_CF,
                    A1.ESB_CF,
                    A1.USR_CF,
                    s1.RETACCTYP_CT,
					A1.COMAC,
                    A1.LIFCUR_CF,
					s1.TERCTR_B,
					s1.LIFTRTTYP_CF,
					datepart(yy,s1.ctrinc_d),
					s1.CAN_DT
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
                    s2.RETACCTYP_CT AS ACCADMTYP_CT,
					A2.COMAC,
                    A2.LIFCUR_CF,
					MAX(lif2.CRE_D) AS DERNIER_TRAIT,
					s2.TERCTR_B,
					s2.LIFTRTTYP_CF,
					datepart(yy,s2.ctrinc_d) AS FRSUWY_NF,
					s2.CAN_DT AS SECCAN_D
FROM #TLOADING A2
LEFT OUTER JOIN BEST..TLIFEST lif2 ON
			   lif2.CTR_NF                    = A2.CTR_NF
        and    lif2.END_NT                      = A2.END_NT
        and    lif2.SEC_NF                      = A2.SEC_NF
        and    lif2.UW_NT                       = A2.UW_NT
        and    lif2.UWY_NF                      = A2.UWY_NF
        and    lif2.BALSHEY_NF                  = @BLCSHTYEA_NF
       ,-- and    convert(char(5), lif2.CRE_D, 8) != '23:59',
BRET..TRETCTR s2
WHERE (s2.RETACCTYP_CT != 1 and s2.RETACCTYP_CT != 4)
        and    s2.RETCTR_NF = A2.CTR_NF
        and    s2.RTY_NF = A2.MAXUWY_NF
GROUP BY            A2.CTR_NF,
                    A2.SEC_NF,
                    A2.UWY_NF,
					A2.MAXUWY_NF,
                    A2.END_NT,
                    A2.UW_NT,
                    A2.SSD_CF,
                    A2.ESB_CF,
                    A2.USR_CF,
                    s2.RETACCTYP_CT,
					A2.COMAC,
                    A2.LIFCUR_CF,
					s2.TERCTR_B,
					s2.LIFTRTTYP_CF,
					datepart(yy,s2.ctrinc_d),
					s2.CAN_DT
 
select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLOADING"
        return @erreur
    end

		
/* Retrieve information for different places like TCONTR, TSECTION, TBANTECL, etc... */
/********************************************************************************************/
/* 11- select dans TLIFEST                                                                  */
/*  Monnaie des estimations                                                               */
/* Maj @monnaie : valeur 1 si la monnaie estimation existe et est différente                */
/* de la devise rétro de représentation, valeur 0 sinon                                     */
/********************************************************************************************/
/* Si @RETCTRCAT_CF = 5 ou 6 ou 7 ou 8, il s'agit d'une rétro particulière */
-- if @RETCTRCAT_CF in ('5', '6', '7', '8')	
/* Recherche du top mise a jour auto sur contrat et exercice parametre */	
/********************************************************************************************/
/* 3- select dans TRETSEC (correspondant au dernier ex de souscription) :                   */
/* Garantie                                                                                 */
/********************************************************************************************/
Insert into #TMPRESULT
select  CTR_NF           = t.CTR_NF, 				
        END_NT           = t.END_NT,				
        SEC_NF           = t.SEC_NF,				
        UW_NT            = t.UW_NT,					
        UWY_NF           = t.UWY_NF,
		MAXUWY_NF        = t.MAXUWY_NF,
		ACCADMTYP_CT     = t.ACCADMTYP_CT,
		ACCADMTYP_LL     = tb.colval_ls,
		SECCAN_D         = t.SECCAN_D,
		GAR_CF  	     = s.GAR_CF,
		FRSUWY_NF	     = t.FRSUWY_NF,
		URRFUNINT_R 	 = CASE TPIN.URRFUNINT_R WHEN null THEN 0 ELSE TPIN.URRFUNINT_R END,
		CLMFUNINT_R 	 = CASE TPIN.CLMFUNINT_R WHEN null THEN 0 ELSE TPIN.CLMFUNINT_R END,
		--CUR_CF			 = CASE WHEN t.LIFCUR_CF != r.RETPCPCUR_CF THEN t.LIFCUR_CF ELSE r.RETPCPCUR_CF END,
		CUR_CF 			 = CASE t.LIFCUR_CF 
								WHEN NULL 
								THEN 
									(CASE Rtrim(Ltrim(s.RETSPECUR_CF)) WHEN NULL then r.RETPCPCUR_CF --MODIF 28
														 WHEN '' THEN r.RETPCPCUR_CF --MODIF 26
														  
											ELSE s.RETSPECUR_CF
									 END)
								ELSE 
									t.LIFCUR_CF 
						   END,-- MODIF 22
		SECSTS_CT        = r.RETCTRSTS_CT,	
		NAT_CF       	 = s.nat_cf,
		LIFTRTTYP_CF	 = t.LIFTRTTYP_CF,
		--monnaie          = CASE WHEN t.LIFCUR_CF != r.RETPCPCUR_CF THEN 1 ELSE 0 END,
		monnaie          = CASE WHEN 
									(t.LIFCUR_CF != r.RETPCPCUR_CF 
										OR (Rtrim(Ltrim(s.RETSPECUR_CF)) != NULL  --MODIF 28
										AND t.LIFCUR_CF != s.RETSPECUR_CF) 
									) 
							THEN 1 
								ELSE 0 
							END, -- MODIF 22
		DERNIER_TRAIT    = t.DERNIER_TRAIT,
		CMT_NT           = dria.cmt_nt,
		COMAC			 = t.COMAC,
		PRG_NF			 = isnull(Rtrim(Ltrim(r.PRG_NF)), '0'),
	    LOB_CF 		     = CASE s.LOB_CF WHEN '31' THEN '1' ELSE '0' END, -- Conversion de la LOB 
		LOB_LS    	     = T4.LOB_GS,	
		SOB_CF     		 = s.SOB_CF,
		SOB_LS       	 = T5.SOB_GS,	
		TOP_CF      	 = s.TOP_CF,
		TOP_LS		     = T7.TOP_GS,		
		GAR_LS           = T6.GAR_GS,
		EXE_ACCADMTYP_CT = CASE r2.RETACCTYP_CT WHEN null THEN t.ACCADMTYP_CT ELSE r2.RETACCTYP_CT END,
		CUR_ACCADMTYP_LL = CASE r2.RETACCTYP_CT WHEN null THEN tb.colval_ls ELSE tb2.colval_ls END,	
		CUR_CFS 	     = r.RETPCPCUR_CF,
  		USRCRTVAL_LM 	 = s.USRCRTVAL_LM,
		RETCTRCAT_CF	 = r.RETCTRCAT_CF,
		partic		     = CASE WHEN r.RETCTRCAT_CF = '06' THEN 1 ELSE 0 END,
		TERCTR_B         = t.TERCTR_B,
		CONRETCTR_B      = r2.CONRETCTR_B,
		CASE tpla2.SUMRETSIGSHA_R WHEN null THEN 0 ELSE tpla2.SUMRETSIGSHA_R END as RETSIGSHA_R,
		SSDRTO_B         = CASE WHEN (tpla1.number is not null and tpla1.number > 0) THEN 0 ELSE 1 END,
		PARENTIOTYPE_CT  = 1,	-- MODIF 23 - EST 24 BT
		LOCALIOTYPE_CT   = 1,	-- MODIF 23 - EST 24 BT
		FROMRETROIO_B    = 0	-- MODIF 23 - EST 24 BT
FROM 
#TLOADING2 t
LEFT OUTER JOIN
(SELECT count(tpla.retctr_nf)AS number, B.CTR_NF  from BRET..TPLACEMT tpla, #TLOADING B where 
                        tpla.retctr_nf=B.CTR_NF
						and tpla.his_b=0 
						and tpla.plcsts_ct in(16,19) 
						and tpla.ssdrto_b=0
                        group by B.CTR_NF) tpla1 ON
tpla1.ctr_nf = t.CTR_NF
LEFT OUTER JOIN
( SELECT SUM(tpla.RETSIGSHA_R) as SUMRETSIGSHA_R, B.CTR_NF, B.MAXUWY_NF FROM BRET..TPLACEMT tpla, (select CTR_NF, MAXUWY_NF FROM #TLOADING group by CTR_NF, MAXUWY_NF) B WHERE
							   tpla.RETCTR_NF = B.CTR_NF
						and    tpla.RTY_NF    = B.MAXUWY_NF
						and    tpla.HIS_B     = 0
						group by B.CTR_NF, B.MAXUWY_NF
) tpla2  ON
tpla2.CTR_NF = t.CTR_NF
and tpla2.MAXUWY_NF = t.MAXUWY_NF
LEFT OUTER JOIN (select a.CLMFUNINT_R,a.URRFUNINT_R, C.CTR_NF, C.MAXUWY_NF, r.RETPCPCUR_CF
from   BRET..TPINTWIT a, BRET..TPLACEMT b, #TLOADING C, BRET..TRETCTR r,BRET..TRETSEC s
where
	    r.RETCTR_NF = C.CTR_NF
		and    r.RETCTR_NF 	  = s.RETCTR_NF
		and    r.RTY_NF       = C.MAXUWY_NF  
		and    r.RTY_NF		  = s.RTY_NF
		and    s.RETSEC_NF    = C.SEC_NF
		and    a.RETCTR_NF    = C.CTR_NF
		and    a.RTY_NF       = C.MAXUWY_NF
		and    a.RETTRTCUR_CF = r.RETPCPCUR_CF
		and    a.RETCTR_NF    = b.RETCTR_NF
		and    a.RTY_NF       = b.RTY_NF
		and    a.PLC_NT       = b.PLC_NT
		and    a.PLCVER_NT    = b.PLCVER_NT
		and    b.HIS_B        = 0
group by a.CLMFUNINT_R,a.URRFUNINT_R, C.CTR_NF, C.MAXUWY_NF, r.RETPCPCUR_CF,s.RETSPECUR_CF) TPIN ON
TPIN.CTR_NF = t.CTR_NF AND
TPIN.MAXUWY_NF = t.MAXUWY_NF
LEFT OUTER JOIN BRET..TRETCTR r2 ON
		r2.RETCTR_NF = t.CTR_NF 
		--and r2.RTY_NF=@P_UWY_NF
		  and r2.RTY_NF= t.UWY_NF -- MODIF 20
LEFT OUTER JOIN bref..tbantecl tb2 ON
   r2.RETACCTYP_CT = convert(tinyint, tb2.colval_ct) and tb2.col_ls = 'RETACCTYP_CT' and tb2.lag_cf = @p_LANGUE
/*********************************************************************************************/
/* 13- select dans TLIFDRI                                                                   */
/*    Commentaire general                                                             		 */
/*********************************************************************************************/
LEFT OUTER JOIN BEST..TLIFDRI dria ON
	   dria.CTR_NF       = t.CTR_NF
and    dria.END_NT       = t.END_NT
and    dria.SEC_NF       = t.SEC_NF
and    dria.UW_NT        = t.UW_NT
and    dria.UWY_NF       = t.UWY_NF
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
BRET..TRETCTR r 
			LEFT OUTER JOIN
			BREF..TBANTECL tb ON
				convert(tinyint, tb.colval_ct) = r.RETACCTYP_CT AND
				tb.col_ls = 'RETACCTYP_CT' AND 
				tb.lag_cf = @p_LANGUE,	
BRET..TRETSEC s
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
				T7.LAG_CF = @p_LANGUE,
/*********************************************************************************************/
/* 14 Bis- select dans TRETCTR                                                               */
/*    Recherche du programme pour déterminer s'il s'agit d'un traité non proportionnel       */
/*********************************************************************************************/
BRET..TRETSEC smax
LEFT OUTER JOIN BREF..TCTRNAT tnat ON
		smax.nat_cf = tnat.ctrnat_cf
		and tnat.CTRNATPRP_B=0
where  
			   r.RETCTR_NF = t.CTR_NF
		and    r.RTY_NF    = t.MAXUWY_NF
		and    s.RETCTR_NF = t.CTR_NF
		and s.RTY_NF =r.RTY_NF -- MODIF 20 Added cross prod on BRET..TRETCTR r BRET..TRETSEC s
		--and    s.RTY_NF    = t.UWY_NF -- MODIF 20
		and    s.RETSEC_NF = t.SEC_NF 
		and    smax.RETCTR_NF = t.CTR_NF
		and    smax.RTY_NF    = t.MAXUWY_NF
		and    smax.RETSEC_NF = t.SEC_NF 
		
/********************************************************************************************/
/* 8- select dans TBLCSHTD :                                                                */
/*  Date de fin de période normale                                                        */
/********************************************************************************************/
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
    Raiserror 20003 "APPLICATIF;TRETCTR"
    return 1
end

/********************************************************************************************/
/*  9- Si date du jour <= Date de fin de période normale                                */
/*          @bilan = 1 (normal) , sinon @bilan = 2  (exceptionnel)             */
/********************************************************************************************/
if @DATE <= @END_D
  select @bilan = 1
else
  select @bilan = 2

/********************************************************************************************/
/* 9 bis : Si on est en période exceptionnelle, il faut rechercher si le                    */
/*         user a une habilitation spéciale (profil TRT02 avec mention 'EST OUI' )          */
/********************************************************************************************/
select @habil_spec = 0

select @habil_spec = 1
from   BREF..TROLES a, BREF..TPROFIL b
where  a.USR_CF   = user
and    a.APP_CF   = 'EST'
and    a.PRF_CF   = 'TRT02'
and    a.APP_CF   = b.APP_CF
and    a.PRF_CF   = b.PRF_CF
and    PRFPAR1_LM = 'EST OUI'

/****************************************************************/
/* 10- Recherche dans BCTA..TBLCSHTD du mois correspondant a la */
/*     prochaine periode normale                                */
/****************************************************************/
select @next_period = 0

select @next_period = isnull(BLCSHTMTH_NF, 0)
from   BCTA..TBLCSHTD
where  SSD_CF       = @p_SSD_CF
and    ESB_CF       = @p_ESB_CF
and    DIR_CF       = @p_DIR_CF
and    DMN_CF       = @p_DMN_CF
and    BLCSHTYEA_NF = @BLCSHTYEA_NF
and    STR_D       !> getdate()
and    END_D       !< getdate()

select @erreur = @@error
if @erreur != 0
begin
  Raiserror 20003 "APPLICATIF;TRETCTR"
  return 1
end

--MODIF 27

select  @estcrb_ct = ESTCRB_CT 
from   BRET..TRETCTR
where  RETCTR_NF = @p_CTR_NF
and    RTY_NF    = @p_UWY_NF



/* Final Select */
select  CTR_NF           = t.CTR_NF, 				
        END_NT           = 0,			
        SEC_NF           = t.SEC_NF,				
        UW_NT            = 1, --MODIF 24
		UWY_NF           = t.MAXUWY_NF,
		OLDUWY_NF        = t.UWY_NF,
        ACCADMTYP_CT     = t.ACCADMTYP_CT,			
		ACCADMTYP_LL     = t.ACCADMTYP_LL,			
        SECCAN_D         = CONVERT(varchar(50), t.SECCAN_D,113) + ' ' + CONVERT(varchar(50), t.SECCAN_D,20),				
        GAR_CF           = t.GAR_CF,				
        FRSUWY_CF        = t.FRSUWY_NF,				
        SECACCSTS_CT     = 0,			
        CLMFUNINT_R      = t.CLMFUNINT_R,
        URRFUNINT_R      = t.URRFUNINT_R, 	 	
        BLCSHTYEA_NF     = @BLCSHTYEA_NF,			
        BLCSHTMTH_NF     = @BLCSHTMTH_NF,			
        CUR_CF           = t.CUR_CF,				
        SECSTS_CT        = t.SECSTS_CT,             
        NAT_CF           = t.NAT_CF,				
        LIFTRTTYP_CF     = t.LIFTRTTYP_CF,			
        BILAN            = @bilan,					
        RETRO            = 1,													--Mod18			
        MONNAIE          = t.monnaie,				
        VISU_YEA         = 0,						
        VISU_MTH         = 0,						
        EXERCICE         = 0,						
        VAL_EXERCICE     = 0,						
        DERNIER_TRAIT    = CONVERT(varchar(50), t.DERNIER_TRAIT,113) + ' ' + CONVERT(varchar(50), t.DERNIER_TRAIT,20),			
        CMT_NT           = t.cmt_nt,				
        COMAC            = t.COMAC,					
        CNATYP_CT        = null,				
        CNATYP_LL        = null,				
        NEXT_PERIOD      = @next_period,			
        TIMESTAMP_GRAPPE = @timestamp_grappe,		
        HABIL_SPEC       = @habil_spec,			    
        PRG_NF           = t.PRG_NF,				
        LOB_CF           = t.LOB_CF,				
		LOB_LS           = t.LOB_LS,				
		SOB_CF           = t.SOB_CF,				
		SOB_LS           = t.SOB_LS,				
		TOP_CF           = t.TOP_CF,				
		TOP_LS           = t.TOP_LS,				
		GAR_LS           = t.GAR_LS,				
        EXE_ACCADMTYP_CT = t.EXE_ACCADMTYP_CT,		
		CUR_ACCADMTYP_LL = t.CUR_ACCADMTYP_LL,		
		CED_NF           = 0,				
		BOQ_NF           = 0,				
		USRCRTVAL_LM	 = t.USRCRTVAL_LM,			
		SSDRTO_B		 = t.SSDRTO_B,						
		TERCTR_B		 = t.TERCTR_B,						
		CONRETCTR_B		 = t.CONRETCTR_B,						
		RETSIGSHA_R      = t.RETSIGSHA_R,						
		PARTIC           = t.partic,						
		RETCTRCAT_CF	 = t.RETCTRCAT_CF,
		PARENTIOTYPE_CT = t.PARENTIOTYPE_CT ,	-- MODIF 23 - EST 24 BT
		LOCALIOTYPE_CT  = t.LOCALIOTYPE_CT ,	-- MODIF 23 - EST 24 BT
		FROMRETROIO_B   = t.FROMRETROIO_B,		-- MODIF 23 - EST 24 BT		
		ESTCRB_CT	    = @estcrb_ct					-- MODIF 25 --MODIF27
FROM #TMPRESULT t


return 0
go
EXEC sp_procxmode 'PsLIFEST_06_O2', 'unchained'
go
IF OBJECT_ID('PsLIFEST_06_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFEST_06_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFEST_06_O2 >>>'
go
GRANT EXECUTE ON PsLIFEST_06_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFEST_06_O2 TO GDBBATCH
go
