USE BSAR
go
/*
 * DROP PROC dbo.PsRATULTIMATES_01
 */
IF OBJECT_ID('dbo.PsRATULTIMATES_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsRATULTIMATES_01
    PRINT '<<< DROPPED PROC dbo.PsRATULTIMATES_01 >>>'
END
go

/*
 * creation de la procedure
*/
create procedure PsRATULTIMATES_01
(
   @p_norme_cf     varchar(4),
   @p_typeinv_cf   varchar(4),
   @p_balshtyea_nf char(4),
   @p_balshtmth_nf char(2)
)
as

/***************************************************
Programme:                PsRATULTIMATES_01
Fichier script associé:   PsRATULTIMATES_01.prc
Domaine:                  (RA) Reinsurance Analytics
Base principale:          BSAR
Version:                  1
Auteur:                   Roger Cassis
Date de creation:         29/06/2016
Description du programme: :spot:30839 Extraction des données TULTIMATES
Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
**********************************************************************************************************/

declare @erreur int

SELECT NORME_CF=@p_norme_cf,
       TYPEINV_CF=@p_typeinv_cf,
       BALSHTYEA_NF=@p_balshtyea_nf,
       BALSHTMTH_NF=@p_balshtmth_nf,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       a.SSD_CF,
       ESB_CF,
       SECINC_D=isnull(convert(char(8),SECINC_D,112),'19000101'),
       EXP_D=isnull(convert(char(8),EXP_D,112),'19000101'),
       DIFMTH_NF,
       CTRNAT_CT,
       CTRRET_B,
       SECSTS_CT,
       LOB_CF,
       TOP_CF,
       SOB_CF,
       PRDCOD_CT,
       NAT_CF,
       GAR_CF,
       DIV_NT,
       PCPRSKTRY_CF,
       USRCRTCOD_CT,
       USRCRTVAL_LM,
       SECQUA_CF,
       SECQUA2_CF,
       SECQUA3_CF,
       SECQUA4_CF,
       SECQUA5_CF,
       WRKCAT_CT,
       UWGRP_CF,
       ADMGRP_CF,
       UWORG_CF,
       ANLCTY_NF,
       CED_NF,
       ORGCED_NF,
       PRD_NF,
       REITYP_CF,
       ACCADMTYP_CF,
       SECACCSTS_CT,
       ACCFRQ_CT,
       CMPACCPER_NF,
       LSTCEDPER_NF,
       PRMPRTSCL_B,
       ERNPRMADM_B,
       INSPOL_R,
       POLDURMTH_NF,
       COMTYP_CT,
       COM_R,
       MINCOM_R,
       OVRCOM_R,
       TAX_R,
       BRK_R,
       REIEXI_B,
       REIFRE_B,
       PRFCOMEXI_B,
       LOSCTBEXI_B,
       LOSCOREXI_B,
       CBIRETCED_R,
       PBIRETCED_R,
       CBERETCED_R,
       PBERETCED_R,
       EGPCUR_CF,
       SBJPRM_M,
       SBJPRMCPT_M,
       SBJCPTDEF_B,
       SCOSHA_R,
       PMLRAT_R,
       SCOEGP_M,
       QUOT_CT,
       PRMFINEFF_R,
       PRMMAXEFF_R,
       PRMFINACT_R,
       PRMMAXACT_R,
       CLMPRMACT_R,
       PRMPRT_M,
       EGPRPCC_M,
       CALAMTPRM_M,
       ENTAMTPRM_M,
       RETAMTPRM_M,
       ADMMODPRM_CT,
       CALAMTCLM_M,
       ENTAMTCLM_M,
       RETAMTCLM_M,
       ADMMODCLM_CT,
       RESPRM_M,
       ULTPMLRAT_R,
       ULTCRE_D=isnull(convert(char(8),ULTCRE_D,112),'19000101'),
       ULTORICOD_LS,
       ULTUPDUSR_CF,
       FLAPRM_M,
       PRVPRM_M,
       LAYCAP_M,
       ESTVRS_NF,
       ESTSEG_NF,
       ESTCUR_CF,
       ESTAMORAT_CT,
       ESTPRMAMT_M,
       ESTCLMAMT_M,
       ESTLOSRAT_R,
       ACTVRS_NF,
       ACTSEG_NF,
       ACTCUR_CF,
       ACTAMORAT_CT,
       ACTPRMAMT_M,
       ACTCLMAMT_M,
       ACTLOSRAT_R,
       CACCPRM_M,
       CACCERNPRM_M,
       CACCPMLRAT_R,
       CACCLOA_R,
       CACCRES_R,
       CACCACR_M,
       ACCPRM_M,
       ACCERNPRM_M,
       ACCPMLRAT_R,
       ACCLOA_R,
       ACCRES_R,
       ACCACR_M,
       CEDORDNBR_NT,
       CEDSORDNBR_NT,
       ORGCEDORDNBR_NT,
       ORGCEDSORDNBR_NT,
       BRKORDNBR_NT,
       BRKSORDNBR_NT,
       FACADMTYP_B
FROM BSAR..TULTIMATES a,
     BREF..TBATCHSSD b
Where b.BATCHUSER_Cf = suser_name()
and   a.SSD_CF = b.SSD_CF

select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TULTIMATES"
   return @erreur
end

return 0
go
IF OBJECT_ID('dbo.PsRATULTIMATES_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsRATULTIMATES_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsRATULTIMATES_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsRATULTIMATES_01
 */
GRANT EXECUTE ON dbo.PsRATULTIMATES_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsRATULTIMATES_01 TO GDBBATCH
go
