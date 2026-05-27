use BEST
go

IF OBJECT_ID('dbo.PsPLACEMT_22') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPLACEMT_22
    IF OBJECT_ID('dbo.PsPLACEMT_22') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPLACEMT_22 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPLACEMT_22 >>>'
END
go
/*
 * creation de la procedure
 
 
 PsPLACEMT_22 0
*/

create procedure PsPLACEMT_22 


as

begin

CREATE TABLE #TPLACEMT
(SSD_CF	USSD_CF	NOT NULL,
 ESB_CF	tinyint	NULL,		-- provient de tretctr
 RETCTR_NF	URETCTR_NF	NOT NULL,
 RETEND_NT	UEND_NT	DEFAULT 0,
 RETSEC_NF	URETSEC_NF	NOT NULL,	-- provient de tcession
 RTY_NF	UUWY_NF	NOT NULL,
 RETUW_NT	UUW_NT		DEFAULT 1,
 PLC_NT	UPLC_NT	NOT NULL,
 PLCSTS_CT    UPLCSTS_CT   NOT NULL,
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
 BASIS_NT smallint null,
 OVRBASIS_NT smallint null,
 FIXCOM_R USHORAT_R null,
 TOTRETSIGSHA_R		USHA_R		NULL 
 )

create table #ListLob 
( RETCTR_NF	URETCTR_NF	NOT NULL,
 RTY_NF	UUWY_NF	NOT NULL,
 RETSEC_NF  USEC_NF	NOT NULL,
 LOB_CF	ULOB_CF	NOT NULL
  )

insert into #ListLob
select distinct RETCTR_NF,  RTY_NF,  RETSEC_NF, LOB_CF
from BRET..TRETSEC

create index iListLob on #ListLob (RETCTR_NF,  RTY_NF,  RETSEC_NF, LOB_CF)


/***************************************************

Programme: PsPLACEMT_22
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: MZM
Date de creation: 12/04/2019
Description du programme:
           pour SPIRA 70671

      Extraction des placements pour les affaires du perimetre retrocession.
      	copie de la proc BEST..PsPLACEMT_02.prc + ajout colonne TOTRETSIGSHA_R

Parametres: aucun
Conditions d'execution:
Commentaires:

*****************************************************/

--select BATCHUSER_CF, SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr


insert into #tplacemt
(SSD_CF,
 RETCTR_NF,
 RETEND_NT,
 RETSEC_NF,
 rty_NF,
 RETUW_NT,
 PLC_NT,
 PLCSTS_CT,
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
 BASIS_NT ,
 OVRBASIS_NT,
 FIXCOM_R, 
 TOTRETSIGSHA_R
 )
select
 a.SSD_CF,
 a.RETCTR_NF,
 0, -- RETEND_NT,
 b.RETSEC_NF,
 a.RTY_NF,
 1,  -- retuw_nt
 a.PLC_NT,
 a.PLCSTS_CT,
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
 a.BASIS_NT ,
 a.OVRBASIS_NT,
 a.FIXCOM_R,  
 1       --c.CEDSHA_R  /* Total du placement */
from bret..tplacemt a,  #ListLob b   --, --#ssds01 S, BREF..TBATCHSSD S
WHERE (a.plcsts_ct=16 or a.plcsts_ct=19)
--AND  a.retctr_nf = c.retctr_nf
AND  a.accplc_b=1
AND  a.his_b=0
AND  a.retctr_nf=b.retctr_nf
AND  a.rty_nf=b.rty_nf

--select * from #ListLob

update #tplacemt
set TOTRETSIGSHA_R= c3.CEDSHA_R
from #tplacemt a, bret..trfamli c3
where a.retctr_nf = c3.retctr_nf
and a.rty_nf=c3.rty_nf
and c3.CEDSHA_R != 0
and c3.RETSEC_NF = (select min(c2.RETSEC_NF) from bret..trfamli c2 where c2.retctr_nf = c3.RETCTR_NF and c2.rty_nf = c3.RTY_NF and c2.cedsha_r != 0)

--and  a.SSD_CF = @p_ssd_cf 
--and  S.BATCHUSER_CF = @curr_usr

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
      
select * from #tplacemt    

end 

return 0
go

EXEC sp_procxmode 'dbo.PsPLACEMT_22', 'unchained'
go

IF OBJECT_ID('dbo.PsPLACEMT_22') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPLACEMT_22 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPLACEMT_22 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsPLACEMT_22
 */
GRANT EXECUTE ON dbo.PsPLACEMT_22 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPLACEMT_22 TO GDBBATCH
go

