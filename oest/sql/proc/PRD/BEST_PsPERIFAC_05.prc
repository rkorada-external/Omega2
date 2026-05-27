USE BEST
go

/*
 * DROP PROC dbo.PsPERIFAC_05
 */
IF OBJECT_ID('dbo.PsPERIFAC_05') IS NOT NULL
BEGIN
    DROP PROC dbo.PsPERIFAC_05
    PRINT '<<< DROPPED PROC dbo.PsPERIFAC_05 >>>'
END
go

/* creation d'une table temporaire #TCTRULT pour la compilation */
/* ------------------------------------------------------------ */

create table #TCTRULT(
    CTR_NF      UCTR_NF     not null,
    END_NT      UEND_NT     not null,
    SEC_NF      USEC_NF     not null,
    UWY_NF      UUWY_NF     not null,
    UW_NT       UUW_NT          not null,
    ADMMODPRM_CT    char(1)     DEFAULT 'M',
    CRE_D       datetime        null )
go
 
/*
 * creation de la procedure 
*/

create procedure PsPERIFAC_05
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              tinyint
            )
as

/***************************************************

Programme: PsPERIFAC_05

Fichier script associé : ESSSEC51.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 

Date de creation: 

Description du programme: 
    Descente du périmètre acceptation des bases facs au niveau CASEX pour la segmentation.
Le filtre sur la date d'effet est fait ultérieurement par un programme C
 
Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: M.HA-THUC

Date: 12/03/98

Version: 1

Description: rajout de 2 champs supplémentaire au périmètre
    - USRCRTCOD_CT ( code du critère utilisateur acceptation )
    - USRCRTVAL_LM ( valeur du critère utilisateur acceptation )

_________________
MODIFICATION 2

Auteur: M.Ha-Thuc

Date: 20/03/1998

Version: 2

Description: rajout de 2 champs supplémentaires au périmètre
    - PRDBRKTYP_CT ( type de courtage apporteur )
    - ACCBRKTYP_CT ( type de courtage émetteur de comptes )

_________________
MODIFICATION 3

Auteur: M.Ha-Thuc

Date: 26/05/1998

Version: 2

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
    - plus de restriction sur l'état de la section et du contrat lors de 
la descente quotidienne du périmètre. Le filtre sera fait dans la chaîne
ESID0001.


_________________
MODIFICATION 5

Auteur: M.Ha-Thuc

Date: 05/10/1998

Version: 

Description: 
    - la procédure commune qui descendait le périmètre facs en segmentation
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
MODIFICATION 8

Auteur: M.Bourdaillet

Date: 05/03/1999

Version: 

Description: .
Rajout de six champs pour la segmentation client. 
Mais pour ce perimetre les champs n'ontpas besoin d'etre
renseignés; ils sont donc forces à NULL

_________________
MODIFICATION 9

Auteur: MONTAGNAC(ASCOTT)

Date: 25/08/1999

Version: 

Description: .
Ajout du bit FACADMTYP_B dans le select.

_________________
MODIFICATION 10

Auteur: FCharles

Date: 06/05/2000

Version: 

Description: .
Ajout de la date CRTVRSINC_D dans le select.

_________________
MODIFICATION 11

Auteur: O.Arik(AURA)

Date: 30/03/2001

Version:

Description:
Ajout de RECBRK_B (Indic d'existance de courtage sur REC)
et de RECBRK_R (taux de court. sur reconstitution)
dans le select.
on renseigne le champ ORGCED_NF dans le select.

_________________
MODIFICATION 12

Auteur: MZM

Date: 05/02/2018

Version:

Description:
Arret des Estimations pour les traites invalides (CTRLCK_B = 0) 
et les FAC dont l'avenant est invalide (CTRLCK_B = 1)
*****************************************************/

declare @erreur int

select @erreur = 0




/*************************/
/* Descente du perimetre */
/*************************/

SELECT   SECTION.SSD_CF,        
       @p_segtyp_ct,            
     SECTION.CTR_NF,        
     SECTION.END_NT,        
     SECTION.SEC_NF,        
     SECTION.UWY_NF,        
     SECTION.UW_NT,             
     ACCESB_CF,             
       isnull( CTRULT.ADMMODPRM_CT, 'M' ),      
     ANLCTY_CF,             
     CONVERT(char(8), CAN_DT, 112),
     CED_NF,            
       CLICTY_CF,           
       CLINAT_CF,           
       NULL,            
       1,           -- en Facs, il s agit toujours de commissions fixes
       CTBGENFEE_R,             
       CTBTYP_CT,           
     CONVERT(char(8), CTRINC_D, 112),
       CLISSD_CF, -- Permet l'affectation de CTRRET_B
       CUTSHA_R,            
     DIV_NT,            
       EGPCUR_CF,           
       CONTR.ESTCRB_CT,         
       ESTCTR_NF,           
       ESTEND_B,
       NULL, -- ESTSEC_NF par defaut
       CONVERT(char(8), CTREXP_D, 112),
       FIXCOM_R,            
     SECTION.FRSUWY_NF,         
     GANPAYORD_NT,          
     GAR_CF,                
     GENPRMPAY_NF,          
     GENPRMSEN_NF,          
       NULL, -- Non renseigne pour les facs         
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
       NULL,        -- modifs du 08/10/1998, la champs ORDNBR_NT est forcé à NULL           
     PCPCUR_CF,             
     PCPRSKTRY_CF,          
       NULL,  -- Non renseigne pour les facs            
     PRD_NF,            
       PRFCOM_R,            
       PRFCOMEXI_B,             
       NULL,            
       NULL,            
       NULL,            
       NULL,            
       NULL,            
       NULL,            
       PRMNETCOM_B,             
       NULL, -- Non renseigne pour les facs         
       REIEXI_B,            
       REIFRE_B,            
       REINBR_N,            
       REIUNL_B,            
       RESTRFDUR_N,         
       RESTRFTYP_CF,            
       NULL,            
       NULL,
       SCLCOMEXI_B,             
       SCLCTBEXI_B,             
       SCOADDEGP_M, -- SCOEGP_M par defaut anciennement scogloegp modif fc 23/12/98
     CONVERT(char(8), SCOINC_D, 112),
     SECACCSTS_CT,          
         CONVERT(char(8), CTRINC_D, 112),  -- Affectation de SECINC_D 
     SECSTS_CT,             
       SEG_NF,          
     SOB_CF,            
     SUBNAT_CF,             
       NULL,            
     TOP_CF,            
       'F',     -- CTRNAT_CT            
     UWGRP_CF,          
    NULL,           
       NULL,     -- Non renseigne pour les facs
       CONVERT(char(8), ORGINC_D, 112),
       LIARIDSHA_B,             
       NULL,            
       RIDSHA_R,            
       CTBCALLVL_CF,            
       NULL, -- Non renseigne pour les facs         
       NULL,                
   NULL,                
       ACCADMTYP_CT,            
       NULL,                
       CTRSTS_CT,           
       OVRCOM_R,            
       OVRCOMTYP_CT,            
       TAXCNDEXI_B,             
       PRDBRK_R,            
       ACCBRK_R,
       NULL, -- LIACUR_CF : non utilisé pour les facs
       NULL, -- ERNPRMADM_B : non utilisé pour les facs

       CONVERT(char(8), SECCAN_D, 112), -- Permet l'affectation de EXP_D
       SCOADDEGP_M,                     -- Permet l'affectation de SCOEGP_M anciennement scoorgegp

       NULL, -- Correspond aux champs retro non utilises en acceptation
       NULL, -- Correspond aux champs retro non utilises en acceptation
       NULL, -- Correspond aux champs retro non utilises en acceptation
       NULL, -- Correspond aux champs retro non utilises en acceptation
       NULL, -- Correspond aux champs retro non utilises en acceptation
       NULL, -- Correspond au champ DIFMTH rempli plus loin dans l'inventaire

    SECTION.USRCRTCOD_CT,   -- Champ rajouté au perimètre, modif du 12/03/98
    SECTION.USRCRTVAL_LM,   -- Champ rajouté au perimètre, modif du 12/03/98

    FAMCHG.PRDBRKTYP_CT,        -- Champ rajouté au perimètre, modif du 20/03/98
    FAMCHG.ACCBRKTYP_CT,        -- Champ rajouté au perimètre, modif du 20/03/98

    CONTR.UWORG_CF,         -- Champ rajouté au perimètre, modif du 26/05/98

    NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98    
    NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98    
    NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98    
    NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98    
    NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98    
    NULL,   -- Champ non utilisés en segmentation, modif du 15/09/98    
    CONTR.ORGCED_NF,  -- ce champs est renseigné à partir de la modif(011) 30/03/2001    
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

    NULL,   -- Champ non utilisé (segmentation client), modif 007    
    NULL,   -- Champ non utilisé (segmentation client), modif 007    
    NULL,   -- Champ non utilisé (segmentation client), modif 007    
    NULL,   -- Champ non utilisé (segmentation client), modif 007    
    NULL,   -- Champ non utilisé (segmentation client), modif 007    
    NULL,    -- Champ non utilisé (segmentation client), modif 007    
    FACADMTYP_B, --MODIF 009
    CONVERT(char(8), CRTVRSINC_D, 112),    --MODIF 10
    NULL,   -- Champ non utilis\351, modif 011
    NULL    -- Champ non utilis\351, modif 011

FROM     BFAC..TSECTION SECTION, 
     BFAC..TCONTR CONTR, 
     BFAC..TFAMLIA FAMLIA, 
     BFAC..TFAMCHG FAMCHG, 
     BCLI..TCLIENT CLIENT, 
--   BCLI..TCLREPCR CLREPCR,    - modifs du 08/10/1998
     #TCTRULT CTRULT

WHERE  SECTION.SSD_CF=@p_ssd_cf
       and CTRLCK_B != 0 -- modif du 05/02/2018 ;   FAC Invalides
       and SECSTS_CT IN(16, 18, 19)
       and CTRSTS_CT IN(16, 18, 19)
    and SECACCSTS_CT != 9   -- modifs du 06/10/1998, contrats non terminés
	
     and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT
	 and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
	 
     and SECTION.CTR_NF*=FAMLIA.CTR_NF and SECTION.END_NT*=FAMLIA.END_NT
	 and SECTION.SEC_NF*=FAMLIA.SEC_NF and SECTION.UWY_NF*=FAMLIA.UWY_NF
	 and SECTION.UW_NT*=FAMLIA.UW_NT
	 
         and SECTION.CTR_NF*=FAMCHG.CTR_NF and SECTION.END_NT*=FAMCHG.END_NT
		 and SECTION.SEC_NF*=FAMCHG.SEC_NF and SECTION.UWY_NF*=FAMCHG.UWY_NF
		 and SECTION.UW_NT*=FAMCHG.UW_NT
		 
     and SECTION.CTR_NF*=CTRULT.CTR_NF and SECTION.END_NT*=CTRULT.END_NT
	 and SECTION.SEC_NF*=CTRULT.SEC_NF and SECTION.UWY_NF*=CTRULT.UWY_NF
	 and SECTION.UW_NT*=CTRULT.UW_NT
	 
     and CONTR.CED_NF*=CLIENT.CLI_NF
--   and CONTR.CED_NF*=CLREPCR.CLI_NF and CONTR.SSD_CF*=CLREPCR.SSD_CF  - modifs du 08/10/1998


select @erreur = @@error

if @erreur != 0
   begin
      return @erreur
   end

return 0
go

/*
 * fin de la procedure 
 */

drop table #TCTRULT
go

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEC51', 'PsPERIFAC_05', 'BEST', 'ME69'
go


IF OBJECT_ID('dbo.PsPERIFAC_05') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsPERIFAC_05 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsPERIFAC_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPERIFAC_05
 */
GRANT EXECUTE ON dbo.PsPERIFAC_05 TO GOMEGA
go

