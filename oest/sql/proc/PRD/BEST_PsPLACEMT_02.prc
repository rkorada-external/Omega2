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





CREATE TABLE #TPLACEMT
(SSD_CF	USSD_CF	NOT NULL,
 ESB_CF	tinyint	NULL,		-- provient de tretctr
 RETCTR_NF	URETCTR_NF	NOT NULL,
 RETEND_NT	UEND_NT	DEFAULT 0,
 RETSEC_NF	URETSEC_NF	NOT NULL,	-- provient de tcession
 RTY_NF	UUWY_NF	NOT NULL,
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

/*
 * DROP PROC PsPLACEMT_02
 */
IF OBJECT_ID('PsPLACEMT_02') IS NOT NULL
BEGIN
    DROP PROC PsPLACEMT_02
    PRINT '<<< DROPPED PROC PsPLACEMT_02 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsPLACEMT_02

as

/***************************************************

Programme: PsPLACEMT_02
Fichier script associé : ESSPLC02.PRC
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
Date: 14/09/1998
Version:
Description: la jointure avec la table de travail TESTSSD a été supprimée. On descend 
	maintenant les versements de toutes les filiales

[002] -=Dch=- 07/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
[003] -=Dch=- 07/08/2013 :spot:29162 -- Impact Retro P&C -- Ajout de 3 champs supplémentaires
[004] -=Dch=- 16/08/2016 :spot:31041 -- Impact Retro P&C -- Ajout du champ LCKCLO_B (locking for estimate Y=1, N=0)
[005] MZM     03/12/2020 :spira:91769 NDIC Ajout de colonne  PRETAX_R

*****************************************************/

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr

insert into #tplacemt
(SSD_CF,
 RETCTR_NF,
 RETEND_NT,
 RETSEC_NF,
 rty_NF,
 RETUW_NT,
 PLC_NT,
 OVRCOM_R,
 RTO_NF,
 INT_NF,
 PAY_NF,
 KEY_CF,
 SSDRTO_B,
 RETSIGSHA_R,
 LOB_CF,
 RETOVRCOM_B,
 CTRCOMCON_B,
 RAICOM_B,
 RTOCTY_CF,
 FIXCOM_R ,
 BASIS_NT ,
 OVRBASIS_NT,
 PRETAX_R  
 )
select 
 a.SSD_CF,
 a.RETCTR_NF,
 0, -- RETEND_NT,
 b.RETSEC_NF,
 a.RTY_NF,
 1,  -- retuw_nt
 a.PLC_NT,
 a.OVRCOM_R,
 a.RTO_NF,
 a.INT_NF,
 a.PAY_NF,
 a.KEY_CF,
 a.SSDRTO_B,
 a.RETSIGSHA_R,
 b.LOB_CF,
 a.RETOVRCOM_B,
 a.CTRCOMCON_B,
 a.RAICOM_B,	/* raicom_b au niveau du placement */ 
 a.RTOCTY_CF,
 a.FIXCOM_R,
 a.BASIS_NT,
 a.OVRBASIS_NT,
 a.PRETAX_R  
from bret..tplacemt a, #ListLob b, #ssds S
WHERE (a.plcsts_ct=16 or a.plcsts_ct=19)
AND  a.accplc_b=1					
AND  a.his_b=0
AND  a.retctr_nf=b.retctr_nf
AND  a.rty_nf=b.rty_nf
AND  a.SSD_CF = S.SSD_CF
AND  a.LCKCLO_B =1

-- recuperation des champs esb_cf et oricur_b dans la table des contrats
update #tplacemt
set esb_cf=b.esb_cf,
    oricur_b=b.oricur_b
from #tplacemt a, bret..tretctr b
where a.retctr_nf=b.retctr_nf
and a.rty_nf=b.rty_nf

-- pour les placements ayant leurs conditions au niveau du contrat (ctrcomcon_b=1),
-- prendre l'indicateur raicom_b dans la table des contrats
update #tplacemt
set raicom_b=b.raicom_b
from #tplacemt a, bret..tretctr b
where a.ctrcomcon_b=1
and a.retctr_nf=b.retctr_nf
and a.rty_nf=b.rty_nf

-- elimination des placements rachetes
delete #tplacemt
from #tplacemt a
where exists (select 1 from bret..tcmuplct cmu, bret..tcommut com
			where	a.retctr_nf = cmu.retctr_nf
			and	a.rty_nf = cmu.rty_nf
			and	a.plc_nt = cmu.plc_nt
			and	a.lob_cf = cmu.lob_cf
			and   cmu.retctr_nf = com.retctr_nf
			and	cmu.cmu_nt = com.cmu_nt
			and	cmu.inicmuver_ct = 0
			and	com.cmucalsts_cf = "05")


return 0
go

IF OBJECT_ID('PsPLACEMT_02') IS NOT NULL
    PRINT '<<< CREATED PROC PsPLACEMT_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsPLACEMT_02 >>>'
go
/*
 * Granting/Revoking Permissions on PsPLACEMT_02
 */
GRANT EXECUTE ON PsPLACEMT_02 TO GOMEGA
go
GRANT EXECUTE ON PsPLACEMT_02 TO GDBBATCH
go

