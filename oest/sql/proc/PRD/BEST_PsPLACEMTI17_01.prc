use BEST
go

IF OBJECT_ID('#tplacemtI17') IS NOT NULL
BEGIN
    DROP TABLE #tplacemtI17
END
go

IF OBJECT_ID('#ListLobI17') IS NOT NULL
BEGIN
    DROP TABLE #ListLobI17
END
go


/*
 * DROP PROC PsPLACEMTI17_01
 */
IF OBJECT_ID('PsPLACEMTI17_01') IS NOT NULL
BEGIN
    DROP PROC PsPLACEMTI17_01
    PRINT '<<< DROPPED PROC PsPLACEMTI17_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsPLACEMTI17_01(
		@p_clo_date char(8),
		@p_x_days int,
		@norme_cf char(4),
		@p_quarter_end varchar(10), --quarter end for dry run,
		@p_is_transition varchar(3) = 'NO' --transition mode
)

as

/***************************************************

Programme: PsPLACEMTI17_01
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: Arnaud RUFFAULT 
Date de creation: 07/06/2021
Description du programme: 
	Procédure cree a partir de PsPLACEMT_01 utilse dans IFRS4
      Extraction des placements pour les affaires du perimetre retrocession.
	On restreint la selection aux placements valides ou resilies, comptables,
	et non historises, et non rachetes.

Parametres: aucun
Conditions d'execution: 
Commentaires: 
_________________
MODIFICATIONS
[001] ART spira 97478 IFRS17 DryRun- Recognition date test for pericase
[002] ART spira 100168 IFRS17 inception pericase- Extract Run-off if transition mode
[003] ART spira 999999 IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
[004] Suraj P    22/11/2022  :spira :106239 Pericase INI does not include contract recognized on cut off date
*
*****************************************************/

-------------------------
-- Recognition date - X days OR Dry run date retrieval [001]
-------------------------
DECLARE
@v_pos_booking_minus_days datetime

IF(@p_quarter_end = 'NONE')
BEGIN
	DECLARE
	@v_year_clo_date int,
	@v_month_clo_date int,
	@v_pos_booking_d datetime
	
	SELECT @v_year_clo_date = CONVERT(int, substring(@p_clo_date, 1, 4))
	SELECT @v_month_clo_date = CONVERT(int, substring(@p_clo_date, 5, 2))
	SELECT @v_pos_booking_d = PSTOMGEND17_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @v_year_clo_date and BLCSHTMTH_NF =  @v_month_clo_date --003
	SELECT @v_pos_booking_minus_days = dateadd(day, @p_x_days * -1, @v_pos_booking_d)
END
ELSE 
BEGIN
	SELECT @v_pos_booking_minus_days = convert(datetime, @p_quarter_end, 103)
END


CREATE TABLE #tplacemtI17
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

create table #ListLobI17 (
 RETCTR_NF	URETCTR_NF	NOT NULL,
 RTY_NF	UUWY_NF	NOT NULL,
 RETSEC_NF  USEC_NF	NOT NULL,
 LOB_CF	ULOB_CF	NOT NULL
)
                  
insert into #ListLobI17
select distinct a.RETCTR_NF,  a.RTY_NF,  a.RETSEC_NF, a.LOB_CF
from BRET..TRETSEC a
inner join BRET..TRETIFRS RETIFRS
on RETIFRS.RETCTR_NF= a.RETCTR_NF and RETIFRS.RTY_NF= a.RTY_NF
inner join BRET..TRETCTR RETCTR
on a.RETCTR_NF = RETCTR.RETCTR_NF and a.RTY_NF = RETCTR.RTY_NF
where RETIFRS.RETRECOD_D < @v_pos_booking_minus_days			--MODIF[004]
and (
	a.nat_cf IN ('10','11','12','20','21','22','23')
	OR(a.nat_cf NOT IN ('10','11','12','20','21','22','23')  
	 AND RETCTR.CTRINC_D <= CTRINCUWY_D
		AND ( 
	  (@norme_cf = 'I17G' and ( RETIFRS.GRPINISTS_CT  = 0 OR RETIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and RETIFRS.GRPINISTS_CT = 9)))  --[002]
	   or (@norme_cf = 'I17P' and ( RETIFRS.PARINISTS_CT  = 0 OR RETIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and RETIFRS.PARINISTS_CT = 9))) --[002]
		  or (@norme_cf = 'I17L' and ( RETIFRS.LOCINISTS_CT  = 0 OR RETIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and RETIFRS.LOCINISTS_CT = 9))) --[002]
		)
	)
)


create index iListLob on #ListLobI17 (RETCTR_NF,  RTY_NF,  RETSEC_NF, LOB_CF)

--execute PsPlacemt_02



declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr

insert into #tplacemtI17
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
from bret..tplacemt a, #ListLobI17 b, #ssds S
WHERE (a.plcsts_ct=16 or a.plcsts_ct=19)
AND  a.accplc_b=1					
AND  a.his_b=0
AND  a.retctr_nf=b.retctr_nf
AND  a.rty_nf=b.rty_nf
AND  a.SSD_CF = S.SSD_CF
AND  a.LCKCLO_B =1

-- recuperation des champs esb_cf et oricur_b dans la table des contrats
update #tplacemtI17
set esb_cf=b.esb_cf,
    oricur_b=b.oricur_b
from #tplacemtI17 a, bret..tretctr b
where a.retctr_nf=b.retctr_nf
and a.rty_nf=b.rty_nf

-- pour les placements ayant leurs conditions au niveau du contrat (ctrcomcon_b=1),
-- prendre l'indicateur raicom_b dans la table des contrats
update #tplacemtI17
set raicom_b=b.raicom_b
from #tplacemtI17 a, bret..tretctr b
where a.ctrcomcon_b=1
and a.retctr_nf=b.retctr_nf
and a.rty_nf=b.rty_nf

-- elimination des placements rachetes
delete #tplacemtI17
from #tplacemtI17 a
where exists (select 1 from bret..tcmuplct cmu, bret..tcommut com
			where	a.retctr_nf = cmu.retctr_nf
			and	a.rty_nf = cmu.rty_nf
			and	a.plc_nt = cmu.plc_nt
			and	a.lob_cf = cmu.lob_cf
			and   cmu.retctr_nf = com.retctr_nf
			and	cmu.cmu_nt = com.cmu_nt
			and	cmu.inicmuver_ct = 0
			and	com.cmucalsts_cf = "05")





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
from #tplacemtI17 T 
order by T.retctr_nf, T.retend_nt, T.retsec_nf, T.rty_nf, T.retuw_nt

return 0
go

IF OBJECT_ID('PsPLACEMTI17_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsPLACEMTI17_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsPLACEMTI17_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsPLACEMTI17_01
 */
GRANT EXECUTE ON PsPLACEMTI17_01 TO GOMEGA
go
GRANT EXECUTE ON PsPLACEMTI17_01 TO GDBBATCH
go

