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
 * DROP PROC dbo.PsPLACEMT_10
 */
IF OBJECT_ID('dbo.PsPLACEMT_10') IS NOT NULL
BEGIN
    DROP PROC dbo.PsPLACEMT_10
    PRINT '<<< DROPPED PROC dbo.PsPLACEMT_10 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsPLACEMT_10

as

/***************************************************

Programme: PsPLACEMT_10
Fichier script associé : BEST_PsPLACEMT_10.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: S. Llorente
Date de creation: 12 04 2001
Description du programme: 

      	Extraction des placements pour les affaires du perimetre retrocession.
	On restreint la selection aux placements rachetes.
	On descend les placements de toutes les filiales. 
	order by sur la clé : RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, SSDRTO_B

Parametres: aucun
Conditions d'execution: 
Commentaires: 

[001] -=Dch=- 07/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD, dans PsPlacemt_11 

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
 RTOCTY_CF    UCTY_CF           DEFAULT '')

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

execute PsPlacemt_11



---------------------------------------
-- sortie du resultat pour le bcp out
---------------------------------------

select
	 ssd_cf,
	 esb_cf,
	 retctr_nf,
	 retend_nt,
	 retsec_nf,
	 rty_nf,
       retuw_nt,
	 plc_nt,
	 ovrcom_r,
	 rto_nf,
	 int_nf,
	 pay_nf,
	 key_cf,
	 oricur_b,
	 ssdrto_b,
	 retsigsha_r,
	 lob_cf,
	 raicom_b,
	 retovrcom_b,
	 ctr_nf,
	 end_nt,
 	 sec_nf,
	 uwy_nf,
	 uw_nt,
	 cur_cf,
 	 cessh_r,
  	 clmfun_r,
	 urrfun_r,
	 clmfunmod_ct,
 	 urrfunmod_ct,
       rtocty_cf
from #TPLACEMT
order by retctr_nf, retend_nt, retsec_nf, rty_nf, retuw_nt

return 0
go

IF OBJECT_ID('dbo.PsPLACEMT_10') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsPLACEMT_10 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsPLACEMT_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPLACEMT_10
 */
GRANT EXECUTE ON dbo.PsPLACEMT_10 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPLACEMT_10 TO GDBBATCH
go

