USE BEST
go
IF OBJECT_ID('PiESTACCSUP_04L') IS NOT NULL
BEGIN
  DROP PROC PiESTACCSUP_04L
  PRINT '<<< DROPPED PROC PiESTACCSUP_04L >>>'
END
go
create procedure PiESTACCSUP_04L
with execute as caller as
/***************************************************
Programme:               PiESTACCSUP_04L
Fichier script associé : BEST_PiESTACCSUP_04L.prc
Domaine :               (ES) Estimation
Base principale :       BEST
Version:                1
Auteur:                 R. Cassis
Date de creation:       11/09/2017
Description du programme: :spira:61508 recherche de la période comptable en cours
                          - sélection des écritures de services post omega pour generation retro
Parametres:             date de lancement de la chaîne
Conditions d'execution:
Commentaires:           Procedure cree a partir de la procedure PiESTACCSUP_04 
_________________
MODIFICATIONS
[001] 18/10/2022 M.NAJI :spira 107371
*****************************************************/
declare
 @erreur       int
,@tran_imbr    bit
,@blcshtyea_nf int
,@blcshtmth_nf int
,@startper     int
,@endper       int

select @erreur = 0, @tran_imbr = 1

truncate table BTRAV..EST_ESLJ0090_TACCSUP

-- Determine les bornes des mois bilans debut fin a extraire 
------------------------------------------------------------
select @blcshtyea_nf=blcshtyea_nf, @blcshtmth_nf=blcshtmth_nf 
from  bref..TCALEND a
where account_d = (select min (account_d) from bref..tcalend
                   where account_d >= getdate()) 

--select @blcshtyea_nf=2017,@blcshtmth_nf=1
select @startper = case When @blcshtmth_nf in (4,7,10) then @blcshtyea_nf*100+(@blcshtmth_nf-3)
                        When @blcshtmth_nf in (5,8,11) then @blcshtyea_nf*100+(@blcshtmth_nf-4)
                        When @blcshtmth_nf in (6,9,12) then @blcshtyea_nf*100+(@blcshtmth_nf-5)
                        When @blcshtmth_nf in (1,2,3) then (@blcshtyea_nf-1)*100+10
                   end
select @endper = case When @blcshtmth_nf = 1 then (@blcshtyea_nf-1)*100+12
                      else @blcshtyea_nf*100+(@blcshtmth_nf-1)
                 end
--select @startper,@endper

-- Sélection des écritures de service Local
------------------------------------------------------------
insert into BTRAV..EST_ESLJ0090_TACCSUP
select  TRN_NT, ACCTYP_NF, a.SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
        BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
        END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF,
        CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
        RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
        RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
        CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
from  BEST..TACCSUP a, BREF..TBATCHSSD b 
where ( ACCTYP_NF = 1 or ACCTYP_NF = 99 )
and   RETAUTGEN_B = 1 and SPEENTNAT_CT in (7,8)   --
and   (BALSHEY_NF*100+BALSHRMTH_NF) between @startper and @endper
and   a.SSD_CF=b.SSD_CF
AND   b.BATCHUSER_CF = suser_name()
and   a.TRNCOD_CF LIKE '_[4679CNORSUVWXY]%'
and   a.TRNCOD_CF in (select dettrs_cf from bref..TTRSLNK c 
                      where a.TRNCOD_CF = c.DETTRS_CF
                      and   ((c.prs_cf = 610 and c.acmtrs_nt = 200) OR
                             (c.prs_cf = 605 and c.acmtrs_nt in (300,310,320))))

select @erreur = @@error
if @erreur != 0  goto fin

--   Début de la transaction
if @@trancount = 0
begin
  select @tran_imbr = 0
  BEGIN TRAN
end

--[001]
-- Mise à jour de la table des écritures de services BEST..TACCSUP
------------------------------------------------------------
---delete  BEST..TACCSUP
---from    BEST..TACCSUP A, BTRAV..EST_ESLJ0090_TACCSUP B
---where   B.TRN_NT = A.ACCTRN_NT

Execute @erreur = BEST..PdACCSUP_03L  with recompile


select @erreur = @@error
if @erreur != 0  goto fin

--   Fin de la transaction
if @tran_imbr = 0
  COMMIT TRAN

-- Descente de la table en fichiers
------------------------------------------------------------
select TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
       BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
       END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF,
       CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF,
       RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
       RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL,
       convert( char(8), CRE_D, 112 ), CREUSR_CF, convert( char(8), LSTUPD_D, 112 ), LSTUPDUSR_CF ,
       SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
from  BTRAV..EST_ESLJ0090_TACCSUP
return 0

fin:
if @tran_imbr = 0
  ROLLBACK TRAN
return 1
go
IF OBJECT_ID('PiESTACCSUP_04L') IS NOT NULL
  PRINT '<<< CREATED PROC PiESTACCSUP_04L >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC PiESTACCSUP_04L >>>'
go
GRANT EXECUTE ON PiESTACCSUP_04L TO GOMEGA
go
GRANT EXECUTE ON PiESTACCSUP_04L TO GDBBATCH
go
