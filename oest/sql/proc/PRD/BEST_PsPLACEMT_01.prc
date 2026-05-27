use BEST
go

IF OBJECT_ID('#tplacemt') IS NOT NULL
BEGIN
    DROP TABLE #tplacemt
END
go

IF OBJECT_ID('#ListLob') IS NOT NULL
BEGIN
    DROP TABLE #ListLob
END
go


/*
 * DROP PROC PsPLACEMT_01
 */
IF OBJECT_ID('PsPLACEMT_01') IS NOT NULL
BEGIN
    DROP PROC PsPLACEMT_01
    PRINT '<<< DROPPED PROC PsPLACEMT_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsPLACEMT_01

as

/***************************************************

Programme: PsPLACEMT_01
Fichier script associé : ESSPLC01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: C.Soulier (CGI)
Date de creation: 5 aout 1997
Description du programme: 

      Extraction des placements pour les affaires du perimetre retrocession.
	On restreint la selection aux placements valides ou resilies, comptables,
	et non historises, et non rachetes.

Parametres: aucun
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur: M.HA-THUC
Date:  14/09/1998
Version:
Description: la jointure avec la table de travail TESTSSD a été supprimée ( dans PsPLACEMT_02 ). 
	On descend maintenant les placements de toutes les filiales. De plus, un tri ( order by ) 
	a été rajouté sur la clé : RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, SSDRTO_B


[002] -=Dch=- 07/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD dans PsPlacemt_02 
[003] -=Dch=- 07/08/2013 :spot:29162 -- Impact Retro P&C -- Ajout de 3 champs supplémentaires
[004] MZM     03/12/2020 :spira:91769 NDIC Ajout de colonne PRETAX_R
*****************************************************/



CREATE TABLE #TPLACEMT
(SSD_CF	USSD_CF	NOT NULL,
 ESB_CF	tinyint	NULL,		-- provient de tretctr
 RETCTR_NF	URETCTR_NF	NOT NULL,
 RETEND_NT	UEND_NT	DEFAULT 0,
 RETSEC_NF	URETSEC_NF	NOT NULL,	-- provient de tcession
 rty_NF	UUWY_NF	NOT NULL,
 RETUW_NT	UUW_NT		DEFAULT 1,
 PLC_NT	UPLC_NT	NOT NULL,
 OVRCOM_R	USHORAT_R	NULL,
 RTO_NF	UCLI_NF	NULL,
 INT_NF	UCLI_Nf	NULL,
 PAY_NF	UCLI_NF	NULL,
 KEY_CF	char(1)	DEFAULT '',
 ORICUR_B	bit		default 0,   -- provient de tretctr   
 SSDRTO_B		bit,
 RETSIGSHA_R		USHA_R		NULL,
 LOB_CF		char(2),   -- provient de tcession
 RAICOM_B		bit,
 RETOVRCOM_B		bit,
 CTR_NF	UCTR_NF	NULL,  -- tous les champs a partir de celui-ci (ctr_nf)
 END_NT 	UEND_NT	NULL,  -- ne sont pas alimentes par le procedure
 SEC_NF	USEC_NF	NULL,   -- mais seront alimentes plus tard
 UWY_NF	UUWY_NF	NULL,   
 UW_NT		UUW_NT		NULL,
 CUR_CF	UCUR_CF	NULL,
 CESSH_R	USHORAT_R	NULL,
 CLMFUN_R	USHA_R		NULL,
 URRFUN_R	USHA_R		NULL,
 CLMFUNMOD_CT	UFUNMOD_CT	NULL,
 URRFUNMOD_CT	UFUNMOD_CT	NULL,
 CTRCOMCON_B		bit	DEFAULT 0,
 RTOCTY_CF    UCTY_CF           DEFAULT '',
 FIXCOM_R USHORAT_R null,
 BASIS_NT smallint null,
 OVRBASIS_NT smallint null,
 PRETAX_R USHA_R  null 
 )

create table #ListLob (
 RETCTR_NF	URETCTR_NF	NOT NULL,
 RTY_NF	UUWY_NF	NOT NULL,
 RETSEC_NF  USEC_NF	NOT NULL,
 LOB_CF	ULOB_CF	NOT NULL
)
                  
insert into #ListLob
select distinct RETCTR_NF,  RTY_NF,  RETSEC_NF, LOB_CF
from BRET..TRETSEC

create index iListLob on #ListLob (RETCTR_NF,  RTY_NF,  RETSEC_NF, LOB_CF)

execute PsPlacemt_02



---------------------------------------
-- sortie du resultat pour le bcp out
---------------------------------------

select
	 T.ssd_cf,
	 T.esb_cf,
	 T.retctr_nf,
	 T.retend_nt,
	 T.retsec_nf,
	 T.rty_nf,
     T.retuw_nt,
	 T.plc_nt,
	 T.ovrcom_r,
	 T.rto_nf,
	 T.int_nf,
	 T.pay_nf,
	 T.key_cf,
	 T.oricur_b,
	 T.ssdrto_b,
	 T.retsigsha_r,
	 T.lob_cf,
	 T.raicom_b,
	 T.retovrcom_b,
	 T.ctr_nf,
	 T.end_nt,
 	 T.sec_nf,
	 T.uwy_nf,
	 T.uw_nt,
	 T.cur_cf,
 	 T.cessh_r,
  	 T.clmfun_r,
	 T.urrfun_r,
	 T.clmfunmod_ct,
 	 T.urrfunmod_ct,
	 CONRETCTR_B=null,
	 DEPORI_B=null,
     T.rtocty_cf,
	 T.BASIS_NT,
	 T.OVRBASIS_NT,
	 T.FIXCOM_R,
	 T.PRETAX_R
from #TPLACEMT T 
order by T.retctr_nf, T.retend_nt, T.retsec_nf, T.rty_nf, T.retuw_nt

return 0
go

IF OBJECT_ID('PsPLACEMT_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsPLACEMT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsPLACEMT_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsPLACEMT_01
 */
GRANT EXECUTE ON PsPLACEMT_01 TO GOMEGA
go
GRANT EXECUTE ON PsPLACEMT_01 TO GDBBATCH
go

