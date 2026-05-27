USE BEST
go
IF OBJECT_ID('PiESTCES_02') IS NOT NULL
BEGIN
  DROP PROC PiESTCES_02
  PRINT '<<< DROPPED PROC PiESTCES_02 >>>'
END
go
create procedure PiESTCES_02
(
  @p_ctr_nf char(9)  -- contrat ( saisi en TP )
 ,@p_end_nt tinyint  -- avenant ( saisi en TP )
 ,@p_sec_nf tinyint  -- section ( saisi en TP )
 ,@p_uwy_nf smallint -- exercice ( saisi en TP )
 ,@p_uw_nt  tinyint  -- n° exercice ( saisi en TP )
 ,@p_cur_cf char(3)  -- devise ( saisi en TP )
)
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation: 03/10/97
Description du programme: préparation des données nécessaires à la génération d'un fichier des versements
Conditions d'execution: lancée par un batch asynchrone
Commentaires:
_________________
MODIFICATIONS
1 M.DJELLOULI 31/03/2006 :spot:11445 MOD001 EST_ESIJ0090_TESTCES remplace TESTCES
                                     Removed dbo and added ‘with execute as caller as’
3  Florent     03/12/2015 :spot:29162 ajout RETPCPCUR_CF, CONRETCTR_B, ACCFAM_CT
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
insert  into BTRAV..EST_ESIJ0090_TESTCES
  ( CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
  RETUW_NT, CESACCSTA_N, CESACCEND_N, CESSH_R, ACCADMTYP_CT, LOB_CF, CUR_CF )
select  @p_ctr_nf, @p_end_nt, @p_sec_nf, @p_uwy_nf, @p_uw_nt, RETCTR_NF, 0, RETSEC_NF, RTY_NF, 1,
  CESACCSTA_N, CESACCEND_N, CESSH_R, ACCADMTYP_CT, LOB_CF, @p_cur_cf
 from BRET..TCESSION
  where CTR_NF = @p_ctr_nf
    and SEC_NF = @p_sec_nf
    and UWY_NF = @p_uwy_nf
    and UW_NT = @p_uw_nt
    and ( ( CESUPDTYP_CF = '' and CESSTS_CF = '01' ) or ( CESUPDTYP_CF = 'S' and CESSTS_CF = '03' ) )
select @erreur = @@error
if @erreur != 0  goto fin

-- Jointure avec la table BRET..TRETCTR
update BTRAV..EST_ESIJ0090_TESTCES
set RETCTRCAT_CF = B.RETCTRCAT_CF
   ,RETACCADM_B = B.RETACCADM_B
   ,CLECUTPER_B = B.CLECUTPER_B
   ,CLECUTPER_NB = B.CLECUTPER_NB
   ,SSD_CF = B.SSD_CF
   ,ESB_CF = B.ESB_CF
   ,RETPCPCUR_CF = B.RETPCPCUR_CF
   ,CONRETCTR_B = B.CONRETCTR_B 
   ,ACCFAM_CT = B.ACCFAM_CT   
 from BTRAV..EST_ESIJ0090_TESTCES A, BRET..TRETCTR B
  where A.RETCTR_NF = B.RETCTR_NF
    and A.RTY_NF = B.RTY_NF
select @erreur = @@error
if @erreur != 0  goto fin


-- Mettre à jour la devise à partir de la section si cette dernière est renseignée   
update BTRAV..EST_ESIJ0090_TESTCES
   set RETPCPCUR_CF = b.RETSPECUR_CF
 from  BTRAV..EST_ESIJ0090_TESTCES c, BRET..TRETSEC b
 where c.RETCTR_NF = b.RETCTR_NF
   and c.RETSEC_NF = b.RETSEC_NF
   and c.RTY_NF = b.RTY_NF
   and b.RETSPECUR_CF not in(null,' ')

-- Descente de la table BTRAV..TESCES en fichier
select  CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF,
  RETUW_NT, CESACCSTA_N, CESACCEND_N, CESSH_R, SSD_CF, ESB_CF, RETCTRCAT_CF, ACCADMTYP_CT,
  RETACCADM_B, CLECUTPER_B, CLECUTPER_NB, LOB_CF, CUR_CF, RETPCPCUR_CF, CONRETCTR_B, ACCFAM_CT
from  BTRAV..EST_ESIJ0090_TESTCES

-- Fin de la transaction
if @tran_imbr = 0
   COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
  ROLLBACK TRAN
return 1
go
IF OBJECT_ID('PiESTCES_02') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTCES_02 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTCES_02 >>>'
go
GRANT EXECUTE ON PiESTCES_02 TO GOMEGA,GDBBATCH
go
