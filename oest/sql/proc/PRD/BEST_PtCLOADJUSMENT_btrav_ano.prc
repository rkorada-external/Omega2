use BEST
go
if object_id('PtCLOADJUSMENT_btrav_ano') is not null
begin
  drop procedure PtCLOADJUSMENT_btrav_ano
  if object_id('PtCLOADJUSMENT_btrav_ano') is not null
    print '<<< FAILED DROPPING procedure PtCLOADJUSMENT_btrav_ano >>>'
  else
    print '<<< DROPPED procedure PtCLOADJUSMENT_btrav_ano >>>'
end
go
create procedure PtCLOADJUSMENT_btrav_ano
  (
  @p_SITE_CF      UL16
 ,@p_NORM_CF      UL16  
 ,@p_USR_CF       UUSR_CF
 ,@p_DATATYP_CF   UL16
  )
with execute as caller as
/***************************************************
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : HR
Date de creation         : 23/01/2025
Description du programme : : SPIRA 111771
Conditions d'execution :
Commentaires : cette proc est exécutée par le TP pour les erreurs du fichier ajustement
_________________
MODIFICATIONS

*****************************************************/
declare
  @lignes      int
 ,@lignes_load int
 ,@nberrors     int

select @lignes=0 --lignes en erreur

if @p_DATATYP_CF in ('CSM')
begin
-- on vérifie les lignes
select @lignes_load=(select count(*) from BTRAV..EST_ESED0501_CSM_PAFAM_ADJ where CREUSR_CF = @p_USR_CF)

UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20058, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.CREUSR_CF = @p_USR_CF 
  AND NOT EXISTS (SELECT b.SSD_CF FROM BREF..TSUBSID b WHERE b.SSD_CF = a.SSD_CF and b.PRDSIT_CF = @p_SITE_CF)

if @p_NORM_CF in ('I17L')
begin
UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20059, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.CREUSR_CF = @p_USR_CF 
  AND EXISTS (SELECT b.SSD_CF FROM BEST..TI17CLOPER b WHERE b.SSD_CF = a.SSD_CF and b.ESB_CF = a.ESB_CF and b.PARM2 = '0')
end

if @p_NORM_CF in ('I17P')
begin
UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20059, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.CREUSR_CF = @p_USR_CF 
  AND EXISTS (SELECT b.SSD_CF FROM BEST..TI17CLOPER b WHERE b.SSD_CF = a.SSD_CF and b.ESB_CF = a.ESB_CF and b.PARM1 = '0')
end

UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20060, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.CTR_NF != null and a.ACCRET_CF = 'A' AND a.CREUSR_CF = @p_USR_CF 
  AND NOT EXISTS (SELECT b.EGPCUR_CF FROM BTRT..TFAMLIA b WHERE b.CTR_NF = a.CTR_NF and b.END_NT = a.END_NT and b.SEC_NF = a.SEC_NF and b.UW_NT = a.UW_NT and b.UWY_NF = a.UWY_NF and b.EGPCUR_CF = a.CUR_CF)
  AND NOT EXISTS (SELECT b.EGPCUR_CF FROM BFAC..TFAMLIA b WHERE b.CTR_NF = a.CTR_NF and b.END_NT = a.END_NT and b.SEC_NF = a.SEC_NF and b.UW_NT = a.UW_NT and b.UWY_NF = a.UWY_NF and b.EGPCUR_CF = a.CUR_CF)
  AND (EXISTS (SELECT b.EGPCUR_CF FROM BTRT..TFAMLIA b WHERE b.CTR_NF = a.CTR_NF and b.END_NT = a.END_NT and b.SEC_NF = a.SEC_NF and b.UW_NT = a.UW_NT and b.UWY_NF = a.UWY_NF)
  OR EXISTS (SELECT b.EGPCUR_CF FROM BFAC..TFAMLIA b WHERE b.CTR_NF = a.CTR_NF and b.END_NT = a.END_NT and b.SEC_NF = a.SEC_NF and b.UW_NT = a.UW_NT and b.UWY_NF = a.UWY_NF))

UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20061, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.RETCTR_NF != null and a.ACCRET_CF in ('R','RI', 'AI') AND a.CREUSR_CF = @p_USR_CF
  AND NOT EXISTS (SELECT b.RETPCPCUR_CF FROM BRET..TRETCTR b WHERE b.RETCTR_NF = a.RETCTR_NF and b.RTY_NF = a.RTY_NF and b.RETPCPCUR_CF = a.CUR_CF)
  AND NOT EXISTS (SELECT b.RETSPECUR_CF FROM BRET..TRETSEC b WHERE b.RETCTR_NF = a.RETCTR_NF and b.RTY_NF = a.RTY_NF and b.RETSEC_NF = a.RETSEC_NF and b.RETSPECUR_CF = a.CUR_CF)
  AND (EXISTS (SELECT b.RETPCPCUR_CF FROM BRET..TRETCTR b WHERE b.RETCTR_NF = a.RETCTR_NF and b.RTY_NF = a.RTY_NF)
  OR EXISTS (SELECT b.RETSPECUR_CF FROM BRET..TRETSEC b WHERE b.RETCTR_NF = a.RETCTR_NF and b.RTY_NF = a.RTY_NF and b.RETSEC_NF = a.RETSEC_NF))
  
UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20062, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.CREUSR_CF = @p_USR_CF AND a.ACCRET_CF in ('R','RI') and a.NAT_CF in ('P','F') and (a.RETCTR_NF = null or a.RETEND_NT = null or a.RETSEC_NF = null or a.RTY_NF = null or a.RETUW_NT = null
 or a.CTR_NF = null or a.END_NT = null or a.SEC_NF = null or a.UWY_NF = null or a.UW_NT = null)

UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20063, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.CREUSR_CF = @p_USR_CF AND a.ACCRET_CF in ('AI') and (a.RETCTR_NF = null or a.RETEND_NT = null or a.RETSEC_NF = null or a.RTY_NF = null or a.RETUW_NT = null
 or a.CTR_NF = null or a.END_NT = null or a.SEC_NF = null or a.UWY_NF = null or a.UW_NT = null)

UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20064, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.ACCRET_CF in ('A','AI') and a.CREUSR_CF = @p_USR_CF 
  AND NOT EXISTS (SELECT b.CTR_NF FROM BTRT..TCONTR b WHERE b.CTR_NF = a.CTR_NF and b.END_NT = a.END_NT and b.UW_NT = a.UW_NT and b.UWY_NF = a.UWY_NF and b.SSD_CF = a.SSD_CF and b.ACCESB_CF = a.ESB_CF)
  AND NOT EXISTS (SELECT b.CTR_NF FROM BFAC..TCONTR b WHERE b.CTR_NF = a.CTR_NF and b.END_NT = a.END_NT and b.UW_NT = a.UW_NT and b.UWY_NF = a.UWY_NF and b.SSD_CF = a.SSD_CF and b.ACCESB_CF = a.ESB_CF)
  AND (EXISTS (SELECT b.CTR_NF FROM BTRT..TCONTR b WHERE b.CTR_NF = a.CTR_NF and b.END_NT = a.END_NT and b.UW_NT = a.UW_NT and b.UWY_NF = a.UWY_NF)
  OR EXISTS (SELECT b.CTR_NF FROM BFAC..TCONTR b WHERE b.CTR_NF = a.CTR_NF and b.END_NT = a.END_NT and b.UW_NT = a.UW_NT and b.UWY_NF = a.UWY_NF))

UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20065, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.ACCRET_CF in ('R','RI') AND a.CREUSR_CF = @p_USR_CF 
  AND NOT EXISTS (SELECT b.RETPCPCUR_CF FROM BRET..TRETCTR b WHERE b.RETCTR_NF = a.RETCTR_NF and b.RTY_NF = a.RTY_NF and b.SSD_CF = a.SSD_CF and b.ESB_CF = a.ESB_CF)
  AND EXISTS (SELECT b.RETPCPCUR_CF FROM BRET..TRETCTR b WHERE b.RETCTR_NF = a.RETCTR_NF and b.RTY_NF = a.RTY_NF)

UPDATE BTRAV..EST_ESED0501_CSM_PAFAM_ADJ set ANO_CT = 20067, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_CSM_PAFAM_ADJ a
WHERE a.ACCRET_CF in ('A', 'AI', 'R','RI') AND a.NAT_CF != 'N' AND a.CREUSR_CF = @p_USR_CF AND (a.SEG_NF = null OR a.SEG_NF = "")

select count(*) from BTRAV..EST_ESED0501_CSM_PAFAM_ADJ where ANO_CT != 0 and CREUSR_CF = @p_USR_CF

end

else

begin
-- on vérifie les lignes
select @lignes_load=(select count(*) from BTRAV..EST_ESED0501_RETRO_N1_ADJ where CREUSR_CF = @p_USR_CF)

UPDATE BTRAV..EST_ESED0501_RETRO_N1_ADJ set ANO_CT = 633, ERRTYP_CT = 'B', LSTUPD_D = getdate(), LSTUPDUSR_CF = @p_USR_CF
FROM BTRAV..EST_ESED0501_RETRO_N1_ADJ a
WHERE a.CREUSR_CF = @p_USR_CF AND NOT EXISTS (SELECT b.RETCTR_NF FROM BRET..TRETSEC b WHERE b.RETCTR_NF = a.RETCTR_NF and b.RTY_NF = a.RTY_NF and b.RETSEC_NF = a.RETSEC_NF)

select count(*) from BTRAV..EST_ESED0501_RETRO_N1_ADJ where ANO_CT != 0 and CREUSR_CF = @p_USR_CF

end


return 0
go
if object_id('PtCLOADJUSMENT_btrav_ano') is not null
  print '<<< CREATED procedure PtCLOADJUSMENT_btrav_ano >>>'
else
  print '<<< FAILED CREATING procedure PtCLOADJUSMENT_btrav_ano >>>'
go
grant execute on PtCLOADJUSMENT_btrav_ano TO GOMEGA
go
grant execute on PtCLOADJUSMENT_btrav_ano TO GDBBATCH
go
