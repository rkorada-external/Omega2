USE BEST
Go
IF OBJECT_ID('PiESTCES_03') IS NOT NULL
BEGIN
  DROP PROC PiESTCES_03
  PRINT '<<< DROPPED PROC PiESTCES_03 >>>'
END
go
create procedure PiESTCES_03
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1 Copie de PiESTCES_01
[01]  26/08/2029 SBE  :spira:87674 IFRS 17 - Omega SAP interface - SAS Engine transactions management 
*****************************************************/
declare
 @erreur    int
,@tran_imbr bit

select @erreur=0, @tran_imbr=1

--Début de la transaction
if @@trancount = 0
begin
  select @tran_imbr = 0
  BEGIN TRAN
end

-- Sélection des versements de la table BRET..TCESSION
insert into BTRAV..EST_ESFJ0090_TESTCES
  ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
  RETUW_NT, CESACCSTA_N, CESACCEND_N, CESSH_R, ACCADMTYP_CT, LOB_CF, CUR_CF )
select  distinct A.CTR_NF, A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, B.RETCTR_NF, 0, B.RETSEC_NF, B.RTY_NF, 1,
  B.CESACCSTA_N, B.CESACCEND_N, B.CESSH_R, B.ACCADMTYP_CT, B.LOB_CF, NULL
 from  BTRAV..EST_ESFD0070_TACCSUP A, BRET..TCESSION B
  where A.CTR_NF = B.CTR_NF
    and A.SEC_NF = B.SEC_NF
    and A.UWY_NF = B.UWY_NF
    and A.UW_NT = B.UW_NT
    and ( ( B.CESUPDTYP_CF = '' and B.CESSTS_CF = '01' ) or ( B.CESUPDTYP_CF = 'S' and B.CESSTS_CF = '03' ) )
select @erreur = @@error
if @erreur != 0  goto fin

-- Jointure avec la table BRET..TRETCTR
update BTRAV..EST_ESFJ0090_TESTCES
set RETCTRCAT_CF = B.RETCTRCAT_CF
   ,RETACCADM_B = B.RETACCADM_B
   ,CLECUTPER_B = B.CLECUTPER_B
   ,CLECUTPER_NB = B.CLECUTPER_NB
   ,SSD_CF = B.SSD_CF
   ,ESB_CF = B.ESB_CF
   ,RETPCPCUR_CF = B.RETPCPCUR_CF
   ,CONRETCTR_B = B.CONRETCTR_B 
   ,ACCFAM_CT = B.ACCFAM_CT   
 from BTRAV..EST_ESFJ0090_TESTCES A, BRET..TRETCTR B
  where A.RETCTR_NF = B.RETCTR_NF
    and A.RTY_NF = B.RTY_NF
select @erreur = @@error
if @erreur != 0  goto fin

-- Mettre à jour la devise à partir de la section si cette dernière est renseignée   
update BTRAV..EST_ESFJ0090_TESTCES
   set RETPCPCUR_CF = b.RETSPECUR_CF
 from  BTRAV..EST_ESFJ0090_TESTCES c, BRET..TRETSEC b
 where c.RETCTR_NF = b.RETCTR_NF
   and c.RETSEC_NF = b.RETSEC_NF
   and c.RTY_NF = b.RTY_NF
   and b.RETSPECUR_CF not in(null,' ')

-- Descente de la table BTRAV..TESCES en fichier
select CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
  RETUW_NT, CESACCSTA_N, CESACCEND_N, CESSH_R, SSD_CF, ESB_CF, RETCTRCAT_CF, ACCADMTYP_CT,
  RETACCADM_B, CLECUTPER_B, CLECUTPER_NB, LOB_CF, CUR_CF, RETPCPCUR_CF, CONRETCTR_B, ACCFAM_CT
from BTRAV..EST_ESFJ0090_TESTCES

-- Fin de la transaction
if @tran_imbr = 0
  COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
  ROLLBACK TRAN
return 1
go
IF OBJECT_ID('PiESTCES_03') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTCES_03 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTCES_03 >>>'
go
GRANT EXECUTE ON PiESTCES_03 TO GOMEGA,GDBBATCH
go

