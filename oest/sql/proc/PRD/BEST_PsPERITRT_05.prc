USE BEST
GO

/*
 * DROP PROC dbo.PsPERITRT_05
 */
IF OBJECT_ID('dbo.PsPERITRT_05') IS NOT NULL
BEGIN
    DROP PROC dbo.PsPERITRT_05
    PRINT '<<< DROPPED PROC dbo.PsPERITRT_05 >>>'
END
GO

/* creation d'une table temporaire #TFAMRSVP */
/* ----------------------------------------- */

create table #TFAMRSVP(
    CTR_NF       UCTR_NF              NOT NULL,
    UWY_NF       UUWY_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT  1,
    END_NT       UEND_NT              DEFAULT  0,
    SEC_NF       USEC_NF              NOT NULL,
    ERNPRMADM_B  tinyint                  NULL,
    POLDURMTH_NF UPERIOD              DEFAULT 12,
    INSPOL_R     USHORAT_R            DEFAULT 1 )
go

/*
 * creation de la procedure
*/

create procedure PsPERITRT_05
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              tinyint
     )
as

/***************************************************

Programme: PsPERITRT_05

Fichier script associé : ESSSEC49.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31

Date de creation:

Description du programme:
    - Descente du périmètre acceptation traités au niveau CASEX sans filtre
sur la date d'effet dans le cadre de la segmentation


Parametres:

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: M.Ha-Thuc

Date: 12/03/1998

Version:

Description: rajout de 2 champs supplémentaires au périmètre
    - USRCRTCOD_CT ( code du critère utilisateur acceptation )
    - USRCRTVAL_LM ( valeur du critère utilisateur acceptation )

_________________
MODIFICATION 2

Auteur: M.Ha-Thuc

Date: 20/03/1998

Version:

Description: rajout de 2 champs supplémentaires au périmètre
    - PRDBRKTYP_CT ( type de courtage apporteur )
    - ACCBRKTYP_CT ( type de courtage émetteur de comptes )
_________________
MODIFICATION 3

Auteur: M.Ha-Thuc

Date: 26/05/1998

Version:

Description: rajout de 2 champs supplémentaires au périmètre
    - UWORG_CF ( origine du portefeuille )

_________________
MODIFICATION 4

Auteur: M.Ha-Thuc

Date: 15/09/1998

Version:

Description:
    - suppression de la jointure avec BTRAV..TESTSSD; on descend maintenant
quotidiennement un périmètre pour toutes les filiales. Le filtre sur les
filiales de l'inventaire sera fait dans la chaîne ESID0560.
    - rajout de champs supplémentaires pour mise à jour des tables de
l'infocentre ( TULTIMATES, TCTRSTAT )
    - plus de restriction sur l'état de la section et l'état du contrat lors
de la descente quotidienne du périmetre. Le filtre sera fait dans la chaîne
ESID0001.


_________________
MODIFICATION 5

Auteur: M.Ha-Thuc

Date: 05/10/1998

Version:

Description:
    - la procédure commune qui descendait le périmètre traités en segmentation
et en inventaire a été scindée 2 procs distinctes. En effet, les restrictions sur
la sélection des affaires n'est plus la même. En segmentation, on ne prend que les
contrats non terminés ( SECACCSTS_CT != 9 ).


_________________
MODIFICATION 6

Auteur: M.Ha-Thuc

Date: 08/10/1998

Version:

Description:
    - suppression de la jointure avec la table BCLI..TCLREPCR ( qui était fausse !! ),
qui permettait de récupérer le champs ORDNBR_NT. Cette donnée n'est pas utilisée par la vie.


_________________
MODIFICATION 7

Auteur: B.MONTAGNAC

Date: 04/01/1999

Version:

Description:
    - exclusion des lob 30 et 31 de l'extraction

_________________
MODIFICATION 8

Auteur: M.Bourdaillet

Date: 05/03/1999

Version:

Description: .
Rajout de six champs pour la segmentation client.
Mais pour ce perimetre les champs n'ontpas besoin d'etre
renseignés; ils sont donc forces à NULL

________________
MODIFICATION 10

Auteur: O.Arik(AURA)

Date: 30/03/2001

Version:

Description:
Ajout de RECBRK_B (Indic d'existance de courtage sur REC)
et de RECBRK_R (taux de court. sur reconstitution)
dans le select.
on renseigne le champ ORGCED_NF dans le select.

_________________
MODIFICATION 11
Auteur: M. DJELLOULI
Date: 18/05/2005
Version:
Description:
      Sélection des Enregistrements de TFAMCHG pour les postes à Risques
      SPOT 11772 - 11775 - Postes à Risques - SOX

-- NB : Important! Concernant COMTYP_CT , la Valeur COMTYP_CT=4 ("Estimation Manuelle") n'existe plus.
--                       Elle est remplacée par la Valeur ESTCOMTYP_CT=1.
--                       Donc, COMTYP_CT prend toutes les Valeurs sauf 4.
--                       Pour le traitement ESID2000 (ESTC1015), on simule COMTYP_CT=4 quand ESTCOMTYP_CT=1

                          IDEM pour CTBTYP_CT et ESTCTBTYP_CT
                          Valeur de ESTCTBTYP_CT & ESTCOMTYP_CT : Manuel=1, A Vérifier=2, Null
_________________
MODIFICATION 12
Auteur: M. DJELLOULI
Date: 25/10/2005
Version:
Description:
                Inclusion ESTCOMTYP_CT, ESTCBTTYP_CT, ESTREITYP_CT, ESTPRMTYP_CT à Test NULL
                NULL Equivalence à Estimation Manuelle (Valeur = 1)
_________________
MODIFICATION 13
Auteur: M. DJELLOULI
Date: 26/01/2006
Version:
Description:
                Inclusion ESTCOMTYP_CT, ESTCBTTYP_CT, ESTREITYP_CT, ESTPRMTYP_CT à Test NULL
                NULL Equivalence à Estimation Manuelle (Valeur = 3)
[014] R. Cassis     01/09/2015 :spot:29052 On extrait pas les traites en statut invalide pour ne plus faire d'estimations --> Annulation de la modif
[015] MZM           05/02/2018 :spira 42213 :   AND CTRLCK_B <> 1  Traites Invalides ne sont plus estimes	
[016] MZM			13/02/2018 :spira:57585 Ajout d'une nouvelle valeur "Suivi Closing" dans la codification TRAITE / ESTCOMTYP_CT
[017] MZM	    18/06/2018 :spira:57585 La nouvelle valeur closing doit fonctionner comme la valeur "Automatic" ESTCOMTYP = 1
*****************************************************/

declare @erreur int

select @erreur = 0


/*************************/
/* Descente du perimetre */
/*************************/

SELECT SECTION.SSD_CF,
       @p_segtyp_ct,
       SECTION.CTR_NF,
       SECTION.END_NT,
       SECTION.SEC_NF,
       SECTION.UWY_NF,
       SECTION.UW_NT,
       ACCESB_CF,
       ADMMODPRM_CT,
       ANLCTY_CF,
       CONVERT(char(8), CAN_DT, 112),
       CED_NF,
       CLICTY_CF,
       CLINAT_CF,
       CLMACT_M,
       COMTYP_CT=(case when ESTCOMTYP_CT=3 then 4                         -- MOD013 - ESTCOMTYP_CT=1 then 4
					  					 when ESTCOMTYP_CT=4 then 2                         -- MOD016 - ESTCOMTYP_CT=4 then 4   [017] le 18/06/2018 then 2 (au lieu de 4 )
                       when ESTCOMTYP_CT=Null then 4
                       else COMTYP_CT
                  end),                                                   -- MOD011 - MDJ 20/05/2005 + MOD012 MDJ 20/10/2005
       CTBGENFEE_R,
       CTBTYP_CT=(case when ESTCBTTYP_CT=3 then 4                         -- MOD013 - ESTCBTTYP_CT=1 then 4
                       when ESTCBTTYP_CT=Null then 4
                       else CTBTYP_CT
                  end),                                                    -- MOD011 - MDJ 20/05/2005 + MOD012 MDJ 20/10/2005
       CONVERT(char(8), CTRINC_D, 112),
       CLISSD_CF, -- Permet l'affectation de CTRRET_B
       CUTSHA_R,
       0,
       EGPCUR_CF,
       CONTR.ESTCRB_CT,
       ESTCTR_NF,
       ESTEND_B,
       NULL, -- ESTSEC_NF par defaut
       CONVERT(char(8), SCOEXP_D, 112), -- EXP_D par defaut
       FIXCOM_R,
       SECTION.FRSUWY_NF,
       GANPAYORD_NT,
       GAR_CF,
       GENPRMPAY_NF,
       GENPRMSEN_NF,
       isnull(INSPOL_R,1),
       LAYCAP_M,
       LIFTRTTYP_CF,
       LOB_CF,
       LOSCOREXI_B,
       LOSCORHIG_R,
       LOSCORLOW_R,
       LOSCORRAT_R,
       LOSCTB_R,
       LOSCTBEXI_B,
       MAXCOM_R,
       MAXRATCLP_R,
       MINCOM_R,
       MINRATCLP_R,
       NAT_CF,
       NULL,        -- modifs du 08/10/1998, le champs ORDNBR_NT est forcé à NULL
       PCPCUR_CF,
       PCPRSKTRY_CF,
       isnull(POLDURMTH_NF,12),
       PRD_NF,
       PRFCOM_R,
       PRFCOMEXI_B,
       PRMEFFLOA_M,
       PRMEFFLOA_R,
       PRMFIXEFF_R,
       PRMFLCRAT_B,
       PRMMAXEFF_R,
       PRMMINEFF_R,
       PRMNETCOM_B,
       PRMPRTSCL_B,
       REIEXI_B,
       REIFRE_B,
       REINBR_N,
       REIUNL_B,
       RESTRFDUR_N,
       RESTRFTYP_CF,
       SBJCPTDEF_B,
       DEFSBJPRM_M,  --SBJPRM_M par defaut
       SCLCOMEXI_B,
       SCLCTBEXI_B,
       SCOGLOEGP_M, --SCOEGP_M par defaut
       CONVERT(char(8), SCOINC_D, 112),
       SECACCSTS_CT,
       CONVERT(char(8), SECINC_D, 112),
       SECSTS_CT,
       SEG_NF,
       SOB_CF,
       SUBNAT_CF,
       SUPLOATYP_CT,
       TOP_CF,
       'N',     -- CTRNAT_CT par defaut
       UWGRP_CF,
       ACCFRQ_CT,
       WRKCAT_CT,
       CONVERT(char(8), ORGINC_D, 112),
       LIARIDSHA_B,
       FLAPRM_B,
       RIDSHA_R,
       CTBCALLVL_CF,
       0, -- CTBCOM_B par defaut
       PRMPRT_M,
       PRMPRTCUR_CF,
       ACCADMTYP_CT,
       SBJPRMCUR_CF,
       CTRSTS_CT,
       OVRCOM_R,
       OVRCOMTYP_CT,
       TAXCNDEXI_B,
       PRDBRK_R,
       ACCBRK_R,
       LIACUR_CF,
       isnull(ERNPRMADM_B, 1),
       CONVERT(char(8), SECCAN_D, 112), -- Permet l'affectation de EXP_D
       SCOORGEGP_M,                     -- Permet l'affectation de SCOEGP_M
       ESTSBJPRM_M,                     -- Permet l'affectation de SBJPRM_M
       SBJPRMCPT_M,                     -- Permet l'affectation de SBJPRM_M

       NULL,    -- Correspond aux champs retro non utilises en acceptation
       NULL,    -- Correspond aux champs retro non utilises en acceptation
       NULL,    -- Correspond aux champs retro non utilises en acceptation
       NULL,  -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire

       SECTION.USRCRTCOD_CT,   -- Champ rajouté au perimètre, modif du 12/03/98
       SECTION.USRCRTVAL_LM,   -- Champ rajouté au perimètre, modif du 12/03/98
       
       FAMCHG.PRDBRKTYP_CT,        -- Champ rajouté au perimètre, modif du 20/03/98
       FAMCHG.ACCBRKTYP_CT,        -- Champ rajouté au perimètre, modif du 20/03/98
       
       CONTR.UWORG_CF,     -- Champ rajouté au perimètre, modif du 26/05/98
       
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       CONTR.ORGCED_NF,  -- ce champs est renseigné à partir de la modif(010) 30/03/2001
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98
       
       NULL,   -- Champ non utilisé (segmentation client), modif 008
       NULL,   -- Champ non utilisé (segmentation client), modif 008
       NULL,   -- Champ non utilisé (segmentation client), modif 008
       NULL,   -- Champ non utilisé (segmentation client), modif 008
       NULL,   -- Champ non utilisé (segmentation client), modif 008
       NULL,    -- Champ non utilisé (segmentation client), modif 008
       0,             --MODIF 008
       CONVERT(char(8), CRTVRSINC_D, 112),             --MODIF 009
       NULL,   -- Champ non utilis\351, modif 010
       NULL    -- Champ non utilis\351, modif 010

FROM     BTRT..TSECTION SECTION,
     BTRT..TCONTR CONTR,
     BTRT..TFAMLIA FAMLIA,
     BTRT..TFAMCHG FAMCHG,
     BTRT..TFAMCOTP FAMCOTP,
     BTRT..TACCSEND ACCSEND,
     BCLI..TCLIENT CLIENT,
--   BCLI..TCLREPCR CLREPCR,    - modifs du 08/10/1998
        #TFAMRSVP FAMRSVP

WHERE  SECTION.SSD_CF=@p_ssd_cf
     and SECSTS_CT IN(14, 16, 17, 19, 23)
     and CTRSTS_CT IN(14, 16, 17, 19, 23)
     and CTRLCK_B <> 1 --[015]	-- Traites Invalides ne sont plus estimes	 
     and SECACCSTS_CT != 9  -- modifs du 05/10/1998, contrats non terminés
     and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT
	 and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT

         and SECTION.CTR_NF*=FAMLIA.CTR_NF and SECTION.END_NT*=FAMLIA.END_NT
		 and SECTION.SEC_NF*=FAMLIA.SEC_NF and SECTION.UWY_NF*=FAMLIA.UWY_NF
		 and SECTION.UW_NT*=FAMLIA.UW_NT

         and SECTION.CTR_NF*=FAMCHG.CTR_NF and SECTION.END_NT*=FAMCHG.END_NT
		 and SECTION.SEC_NF*=FAMCHG.SEC_NF and SECTION.UWY_NF*=FAMCHG.UWY_NF
		 and SECTION.UW_NT*=FAMCHG.UW_NT

         and SECTION.CTR_NF*=FAMCOTP.CTR_NF and SECTION.END_NT*=FAMCOTP.END_NT
		 and SECTION.SEC_NF*=FAMCOTP.SEC_NF and SECTION.UWY_NF*=FAMCOTP.UWY_NF
		 and SECTION.UW_NT*=FAMCOTP.UW_NT

         and SECTION.CTR_NF*=ACCSEND.CTR_NF
     and CONTR.CED_NF*=CLIENT.CLI_NF
--   and CONTR.CED_NF*=CLREPCR.CLI_NF and CONTR.SSD_CF*=CLREPCR.SSD_CF  - modifs du 08/10/1998
       and SECTION.CTR_NF*=FAMRSVP.CTR_NF and SECTION.END_NT*=FAMRSVP.END_NT
	   and SECTION.SEC_NF*=FAMRSVP.SEC_NF and SECTION.UWY_NF*=FAMRSVP.UWY_NF
	   and SECTION.UW_NT*=FAMRSVP.UW_NT
      and LOB_CF<>'30' and LOB_CF<>'31' -- modif du 04/01/1999, lob exclues de l'extraction

      --and CONTR.CTRLCK_B != 1  --[014]


select @erreur = @@error

if @erreur != 0
   begin
      return @erreur
   end

return 0
go


/***********************************************************************************/

/*
 * fin de la procedure
 */

drop table #TFAMRSVP
go

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEC49', 'PsPERITRT_05', 'BEST', 'ME69'
go


IF OBJECT_ID('dbo.PsPERITRT_05') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsPERITRT_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsPERITRT_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPERITRT_05
 */
GRANT EXECUTE ON dbo.PsPERITRT_05 TO GOMEGA
go

