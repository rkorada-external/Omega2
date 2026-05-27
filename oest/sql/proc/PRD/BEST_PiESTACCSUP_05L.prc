USE BEST
go
IF OBJECT_ID('PiESTACCSUP_05L') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_05L
  PRINT '<<< DROPPED PROC PiESTACCSUP_05L >>>'
END
go
create procedure PiESTACCSUP_05L
with execute as caller as
/***************************************************
Programme:               PiESTACCSUP_05L
Fichier script associé : BEST_PiESTACCSUP_05L.prc
Domaine :               (ES) Estimation
Base principale :       BEST
Version:                1
Auteur:                 R. Cassis
Date de creation:       11/09/2017
Description du programme: :spira:61508 Sélection des écritures de services local type 7 et 8

Parametres:
    - date cloture omega
    - date cloture people pour ecritures sociale ou fermeture conso pour ecritures conso

Conditions d'execution:
Commentaires: Procedure cree a partir de la procedure PiESTACCSUP_05
_________________
MODIFICATIONS
[001] JJ/MM/AAA <prog. name> :spira:xxxxx Comment
****************************************************/
declare
 @erreur       int
,@tran_imbr    bit
,@blcshtyea_nf int
,@blcshtmth_nf int
,@startper     int
,@endper       int

select @erreur = 0, @tran_imbr = 1
-- ------------------------------
-- Truncate des tables de travail
-- ------------------------------
truncate table BTRAV..EST_ESLJ0090_TACCSUP
-- ------------------------------------------------------------
-- Début de la transaction
---------------------------------------------------------------
if @@trancount = 0
begin
    select @tran_imbr = 0
    BEGIN TRAN
end

-- Determine les bornes des mois bilans debut fin a extraire 
------------------------------------------------------------
select @blcshtyea_nf=blcshtyea_nf, @blcshtmth_nf=blcshtmth_nf 
from  bref..TCALEND a
where account_d = (select min (account_d) from bref..tcalend
                   where account_d >= getdate()) 

select @startper = case When @blcshtmth_nf in (4,7,10) then @blcshtyea_nf*100+(@blcshtmth_nf-3)
                        When @blcshtmth_nf in (5,8,11) then @blcshtyea_nf*100+(@blcshtmth_nf-4)
                        When @blcshtmth_nf in (6,9,12) then @blcshtyea_nf*100+(@blcshtmth_nf-5)
                        When @blcshtmth_nf in (1,2,3) then (@blcshtyea_nf-1)*100+10
                   end
select @endper = case When @blcshtmth_nf = 1 then (@blcshtyea_nf-1)*100+12
                      else @blcshtyea_nf*100+(@blcshtmth_nf-1)
                 end

-- -----------------------------------------
-- Sélection des écritures de service
-- -----------------------------------------
insert into BTRAV..EST_ESLJ0090_TACCSUP
select TRN_NT,
       ACCTYP_NF,
       SSD_CF,
       ESB_CF,
       ENTPERY_NF,
       ENTPERMTH_NF,
       BALSHEY_NF,
       BALSHRMTH_NF,
       BALSHRDAY_NF,
       VALPERY_NF,
       VALPERMTH_NF,
       TRNCOD_CF,
       DBLTRNCOD_CF,
       RETAUTGEN_B,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       OCCYEA_NF,
       ACY_NF,
       SCOSTRMTH_NF,
       SCOENDMTH_NF,
       CLM_NF,
       CUR_CF,
       AMT_M,
       CED_NF,
       BRK_NF,
       GEMPRMPAY_NF,
       GANPAYORD_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RETRTY_NF,
       RETUW_NT,
       PLC_NT,
       RETOCCYEA_NF,
       RETACY_NF,
       RETSCOSTRMTH_NF,
       RETSCOENDMTH_NF,
       RCL_NF,
       RETCUR_CF,
       RETAMT_M,
       RTO_NF,
       INT_NF,
       RETPAY_NF,
       RETKEY_CF,
       ACCTRN_NT,
       COMMAC_LL,
       CRE_D,
       CREUSR_CF,
       a.LSTUPD_D,
       a.LSTUPDUSR_CF,
       SPEENTTYP_CF,
       SPEENTNAT_CT,
       EVT_NF,
       REVT_NF
from BEST..TACCSUP a
where SPEENTNAT_CT in (7,8)
  and (BALSHEY_NF*100+BALSHRMTH_NF) between @startper and @endper
  and a.SSD_CF in ( select T.SSD_CF from BREF..TBATCHSSD T where T.BATCHUSER_CF = suser_name() )
  and a.TRNCOD_CF LIKE '_[4679CNORSUVWXY]%'
  and a.TRNCOD_CF in (select dettrs_cf from bref..TTRSLNK c 
                      where a.TRNCOD_CF = c.DETTRS_CF
                      and   ((c.prs_cf = 610 and c.acmtrs_nt = 200) OR
                             (c.prs_cf = 605 and c.acmtrs_nt in (300,310,320))))

select @erreur = @@error
if @erreur != 0
  goto fin

-- --------------------------------
-- Descente de la table en fichiers
-- --------------------------------
select SSD_CF,
       ESB_CF,
       BALSHEY_NF,
       BALSHRMTH_NF,
       BALSHRDAY_NF,
       TRNCOD_CF,
       DBLTRNCOD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       OCCYEA_NF,
       ACY_NF,
       SCOSTRMTH_NF,
       SCOENDMTH_NF,
       CLM_NF,
       CUR_CF,
       AMT_M,
       CED_NF,
       BRK_NF,
       GEMPRMPAY_NF,
       GANPAYORD_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RETRTY_NF,
       RETUW_NT,
       RETOCCYEA_NF,
       RETACY_NF,
       RETSCOSTRMTH_NF,
       RETSCOENDMTH_NF,
       RCL_NF,
       RETCUR_CF,
       RETAMT_M,
       PLC_NT,
       RTO_NF,
       INT_NF,
       RETPAY_NF,
       RETKEY_CF,
       RETAUTGEN_B,
       ACCTYP_NF,
       TRN_NT,
       ORICOD_LS="LOCAL"
      ,RETROAUTO_B=case when ACCTYP_NF=0 then 1 else null end 
      ,SPEENTNAT_CT
      ,EVT_NF
      ,REVT_NF
      ,ACCTRN_NT
from BEST..TACCSUP a
where SPEENTNAT_CT in (7,8)
  and (BALSHEY_NF*100+BALSHRMTH_NF) between @startper and @endper
  and a.SSD_CF in ( select T.SSD_CF from BREF..TBATCHSSD T where T.BATCHUSER_CF = suser_name() )
  and a.TRNCOD_CF LIKE '_[4679CNORSUVWXY]%'
  and a.TRNCOD_CF in (select dettrs_cf from bref..TTRSLNK c 
                      where a.TRNCOD_CF = c.DETTRS_CF
                      and   ((c.prs_cf = 610 and c.acmtrs_nt = 200) OR
                             (c.prs_cf = 605 and c.acmtrs_nt in (300,310,320))))
-- ************************************************************

-- ------------------------------------------------------------
-- Fin de la transaction
-- ------------------------------------------------------------
if @tran_imbr = 0
    COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
    ROLLBACK TRAN

return 1
go
IF OBJECT_ID('PiESTACCSUP_05L') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTACCSUP_05L >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTACCSUP_05L >>>'
go
GRANT EXECUTE ON PiESTACCSUP_05L TO GOMEGA
go
GRANT EXECUTE ON PiESTACCSUP_05L TO GDBBATCH
go
