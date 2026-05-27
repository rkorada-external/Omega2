use BRET
go


/*
 * DROP PROC dbo.PsPLACEMTI17_35 */
IF OBJECT_ID('dbo.PsPLACEMTI17_35') IS NOT NULL
BEGIN
    DROP PROC dbo.PsPLACEMTI17_35
    PRINT '<<< DROPPED PROC dbo.PsPLACEMTI17_35 >>>'
END
go

create procedure PsPLACEMTI17_35
(
   @p_clo_date char(8),
		 @p_x_days int,
		 @norme_cf char(4),
		 @p_quarter_end varchar(10), --quarter end for dry run
			@p_is_transition varchar(3),  --transition mode
			@TYPE_CF   CHAR(3)  = 'INT'  -- si INT -> placements internes - si ALL -> tous les placements		
)
as

/***************************************************
Domaine :                   Retro et Estimation
Base principale :           BRET
Version:                    1
Auteur:                     Arnaud RUFFAULT
Date de creation:           08/06/2021
Description du programme:   Extrait les placements
                            pour les affaires du perimetre retrocession.
                            on restreint la selection aux placements valides ou resilies, comptables,
                            et non historises, et non rachetes.
                            on cumule les taux sur la selection + les taux retro interne
Parametres:                 aucun
_________________
_________________
MODIFICATIONS
[001] ART spira 97478 IFRS17 DryRun- Recognition date test for pericase
[002] ART spira 100168 IFRS17 inception pericase- Extract Run-off if transition mode
[003] ART spira 102075 IFRS17 inception pericase- change POS BOOKING DATE EBS to POS BOOKING DATE I17
[004] Suraj P    22/11/2022  :spira :106239 Pericase INI does not include contract recognized on cut off date
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

declare @erreur int,
        @SSDRTO_B int
select @SSDRTO_B = case when @TYPE_CF ='INT' then 1
                        when @TYPE_CF ='EXT' then 0
                        else 2
                   end

create TABLE #TPLACEMT (
    RETCTR_NF   URETCTR_NF  NOT null,
    RETSEC_NF   URETSEC_NF  NOT null, -- provient de tcession
    RTY_NF      UUWY_NF     NOT null,
    PLC_NT      UPLC_NT         null,
    RTO_NF      UCLI_NF         null,   
    NB_LIGNE    int             null,   
    SSDRTO_B    bit,
    RETSIGSHA_R USHA_R          null,
    LOB_CF     char(2)                 -- provient de tcession
)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20001 "Erreur create table #TPLACEMT"
    return 1
end

create TABLE #TPLACEMT2 (
    RETCTR_NF       URETCTR_NF  NOT null,
    RETSEC_NF       URETSEC_NF  NOT null, -- provient de tcession
    RTY_NF          UUWY_NF     NOT null,
    PLC_NT          UPLC_NT         null,
    RTO_NF          UCLI_NF         null,   
    NB_LIGNE        int             null,   
    RETSIGSHA1_R    USHA_R          null,
    RETSIGSHA2_R    USHA_R          null,
    RETSIGSHA3_R    USHA_R          null,
    SSDRTO_B        bit
)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20003 "Erreur create table #TPLACEMT2"
    return 1
end


create TABLE #TPLACEMT3 (
    RETCTR_NF       URETCTR_NF  NOT null,
    RETSEC_NF       URETSEC_NF  NOT null, -- provient de tcession
    RTY_NF          UUWY_NF     NOT null,
    PLC_NT          UPLC_NT         null,
    RTO_NF          UCLI_NF         null,   
    NB_LIGNE        int             null,   
    RETSIGSHA1_R    USHA_R          null,
    RETSIGSHA2_R    USHA_R          null,
    RETSIGSHA3_R    USHA_R          null,
    SSDRTO_B    bit
)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20004 "Erreur create table #TPLACEMT3"
    return 1
end


create table #ListLob (
    RETCTR_NF   URETCTR_NF  NOT null,
    RTY_NF      UUWY_NF     NOT null,
    RETSEC_NF   USEC_NF     NOT null,
    LOB_CF      ULOB_CF     NOT null
)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20005 "Erreur create table #LISTLOB"
    return 1
end

-- Récup des contrats, exercices, sections et LOB
insert into #ListLob
select distinct a.RETCTR_NF, a.RTY_NF, a.RETSEC_NF, a.LOB_CF
from BRET..TRETSEC a, BREF..TBATCHSSD c, BRET..TRETIFRS RETIFRS, BRET..TRETCTR RETCTR
 where a.SSD_CF=c.SSD_CF
	and RETIFRS.RETCTR_NF= a.RETCTR_NF and RETIFRS.RTY_NF= a.RTY_NF
	and RETCTR.RETCTR_NF= a.RETCTR_NF and RETCTR.RTY_NF= a.RTY_NF
 and c.BATCHUSER_CF=suser_name()
	and RETIFRS.RETRECOD_D < @v_pos_booking_minus_days 			--MODIF[004]
	and (
	 a.nat_cf IN ('10','11','12','20','21','22','23')
	 OR(a.nat_cf NOT IN ('10','11','12','20','21','22','23')  
	  AND RETCTR.CTRINC_D <= CTRINCUWY_D
	 	AND ( 
	   (@norme_cf = 'I17G' and ( RETIFRS.GRPINISTS_CT  = 0 OR RETIFRS.GRPINISTS_CT = 1 OR (@p_is_transition = 'YES' and RETIFRS.GRPINISTS_CT = 9))) --[002]
	    or (@norme_cf = 'I17P' and ( RETIFRS.PARINISTS_CT  = 0 OR RETIFRS.PARINISTS_CT = 1 OR (@p_is_transition = 'YES' and RETIFRS.PARINISTS_CT = 9))) --[002]
	 	  or (@norme_cf = 'I17L' and ( RETIFRS.LOCINISTS_CT  = 0 OR RETIFRS.LOCINISTS_CT = 1 OR (@p_is_transition = 'YES' and RETIFRS.LOCINISTS_CT = 9))) --[002]
	 	)
	 )
 )
select @erreur = @@error
if @erreur != 0
begin
    raiserror 20007 "Erreur insert #LISTLOB"
    return 1
end

create index iListLob on #ListLob (RETCTR_NF,  RTY_NF,  RETSEC_NF, LOB_CF)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20009 "Erreur create index ILISTLOB"
    return 1
end


--  Recup des placements valides ou resilies et maj section et LOB
--Ajout RTO_NF, NB_LIGNE
insert into #tplacemt ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, SSDRTO_B, RETSIGSHA_R, LOB_CF )
select a.RETCTR_NF,
       b.RETSEC_NF,
       a.RTY_NF,
       a.PLC_NT,
       a.RTO_NF,        
       1 "NB_LIGNE",    
       a.SSDRTO_B,
       a.RETSIGSHA_R,
       b.LOB_CF
from bret..tplacemt a, #ListLob b
where a.plcsts_ct in (16 , 19)                    
  and a.accplc_b=1
  and a.his_b=0
  and a.retctr_nf=b.retctr_nf
  and a.rty_nf=b.rty_nf
select @erreur = @@error
if @erreur != 0
begin
    raiserror 20011 "Erreur insert #tplacemt"
    return 1
end

create index itplacemt00 on #tplacemt (RETCTR_NF,  RTY_NF)     
select @erreur = @@error
if @erreur != 0
begin
    raiserror 20012 "Erreur create index itplacemt00"
    return 1
end

-- on met à jour RETSIGSHA1_R avec le taux global placé sur plc valides ou résiliés
-- on met à jour RETSIGSHA2_R avec le taux global placé en rétro interne sur plc valides ou resiliés
insert #TPLACEMT2 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R,SSDRTO_B )
select a.RETCTR_NF,
       a.RETSEC_NF,
       a.RTY_NF,
       null     "PLC_NT",       
       null     "RTO_NF",       
       null     "NB_LIGNE",    
       sum(a.RETSIGSHA_R),
       case when @TYPE_CF='ALL' then sum(a.RETSIGSHA_R)
                                else sum(case when a.SSDRTO_B = @SSDRTO_B then a.RETSIGSHA_R else 0 end)
       end,
       0
from #tplacemt a
where not exists ( select 1 from BRET..tcurcvsn b
                   where a.retctr_nf = b.retctr_nf
                     and a.rty_nf = b.rty_nf
                     and a.plc_nt = b.plc_nt )
group by RETCTR_NF, RTY_NF, RETSEC_NF


select @erreur = @@error
if @erreur != 0
begin
    raiserror 20014 "Erreur insert #tplacemt2"
    return 1
end




create index itplacemt20 on #tplacemt2 (RETCTR_NF,  RETSEC_NF,  RTY_NF)   
select @erreur = @@error
if @erreur != 0
begin
    raiserror 20014 "Erreur create index itplacemt20"
    return 1
end





-- on ajoute des lignes contenant les placements internes avec leur taux de placement
-- sur un seul placement avec des devises specifiques
if @TYPE_CF='ALL'
begin
   insert #TPLACEMT3 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R,SSDRTO_B )
   select a.RETCTR_NF,
          a.RETSEC_NF,
          a.RTY_NF,
          null,                    ---PLC_NT,
          null,                    
          sum(a.NB_LIGNE),         
          sum(a.RETSIGSHA_R),
          sum(a.RETSIGSHA_R),  
          SSDRTO_B
   from #tplacemt a
   where not exists ( select 1 from #tplacemt2 b
                      where a.retctr_nf = b.retctr_nf
                      and   a.retsec_nf = b.retsec_nf
                      and   a.rty_nf    = b.rty_nf )
   group by RETCTR_NF, RTY_NF, RETSEC_NF

end
else
begin
   insert #TPLACEMT3 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R,SSDRTO_B )
   select a.RETCTR_NF,
          a.RETSEC_NF,
          a.RTY_NF,
          null,                    ---PLC_NT,
          null,                    
          sum(a.NB_LIGNE),         
          sum(a.RETSIGSHA_R),
          sum(case when a.SSDRTO_B = @SSDRTO_B then a.RETSIGSHA_R else 0 end),  
          SSDRTO_B
   from #tplacemt a
   where a.SSDRTO_B = @SSDRTO_B
   and not exists ( select 1 from #tplacemt2 b
                    where a.retctr_nf = b.retctr_nf
                    and   a.retsec_nf = b.retsec_nf
                    and   a.rty_nf    = b.rty_nf )
   group by RETCTR_NF, RTY_NF, RETSEC_NF
end
select @erreur = @@error
if @erreur != 0
begin
    raiserror 20015 "Erreur insert2 #tplacemt2"
    return 1
end


-- Ajout RTO_NF
insert #TPLACEMT2 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R,SSDRTO_B )
select RETCTR_NF,
       RETSEC_NF,
       RTY_NF,
       PLC_NT,
       RTO_NF,         
       NB_LIGNE,       
       RETSIGSHA1_R,
       RETSIGSHA2_R,
       SSDRTO_B
from #TPLACEMT3

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20016 "Erreur insert #tplacemt2"
    return 1
end



-- on ajoute des lignes contenant les placements internes avec leur taux de placement
if @TYPE_CF='ALL'
begin
   insert #TPLACEMT2 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R,SSDRTO_B )
   select a.RETCTR_NF,
          a.RETSEC_NF,
          a.RTY_NF,
          a.PLC_NT,
          a.RTO_NF,        
          a.NB_LIGNE,     
          a.RETSIGSHA_R,
          a.RETSIGSHA_R,
          SSDRTO_B
   from #tplacemt a
   where not exists ( select 1
                      from bret..tcmuplct cmu, bret..tcommut com
                      where a.retctr_nf = cmu.retctr_nf
                        and a.rty_nf    = cmu.rty_nf
                        and a.plc_nt    = cmu.plc_nt
                        and a.lob_cf    = cmu.lob_cf
                        and cmu.retctr_nf = com.retctr_nf
                        and cmu.cmu_nt    = com.cmu_nt
                        and cmu.inicmuver_ct = 0
                        and com.cmucalsts_cf = "05" )
end
else
begin
   insert #TPLACEMT2 ( RETCTR_NF, RETSEC_NF, RTY_NF, PLC_NT, RTO_NF, NB_LIGNE, RETSIGSHA1_R, RETSIGSHA2_R, SSDRTO_B )
   select a.RETCTR_NF,
          a.RETSEC_NF,
          a.RTY_NF,
          a.PLC_NT,
          a.RTO_NF,      
          a.NB_LIGNE,     
          a.RETSIGSHA_R,
          a.RETSIGSHA_R,
          SSDRTO_B
   from #tplacemt a
   where a.SSDRTO_B = @SSDRTO_B
     and not exists ( select 1
                      from bret..tcmuplct cmu, bret..tcommut com
                      where a.retctr_nf = cmu.retctr_nf
                        and a.rty_nf    = cmu.rty_nf
                        and a.plc_nt    = cmu.plc_nt
                        and a.lob_cf    = cmu.lob_cf
                        and cmu.retctr_nf    = com.retctr_nf
                        and cmu.cmu_nt  = com.cmu_nt
                        and cmu.inicmuver_ct = 0
                        and com.cmucalsts_cf = "05" )

end
select @erreur = @@error
if @erreur != 0
begin
    raiserror 20017 "Erreur insert #tplacemt2"
    return 1
end


update #TPLACEMT2
   set a.RETSIGSHA1_R = b.RETSIGSHA1_R
from #TPLACEMT2 a, #TPLACEMT2 b
where a.retctr_nf = b.retctr_nf
  and a.retsec_nf = b.retsec_nf
  and a.rty_nf    = b.rty_nf
  and a.PLC_NT is not null
  and b.PLC_NT is null

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20018 "Erreur update #tplacemt2"
    return 1
end


select retctr_nf 'tmp_retctr_nf',
       retsec_nf 'tmp_retsec_nf',
       rty_nf    'tmp_rty_nf',
       count(*)  'tmp_nb_ligne'
into #tmp_TPLACEMT2
from #TPLACEMT2
group by retctr_nf, retsec_nf, rty_nf

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20018 "Erreur select into #tplacemt2"
    return 1
end



--[002]
update #TPLACEMT2
   set NB_LIGNE = b.tmp_nb_ligne
from #TPLACEMT2 a, #tmp_TPLACEMT2 b
where a.retctr_nf = b.tmp_retctr_nf
  and a.retsec_nf = b.tmp_retsec_nf
  and a.rty_nf    = b.tmp_rty_nf

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20020 "Erreur update #Tplacemt2"
    return 1
end


-- Le taux RETSIGSHA3 contient la part de placements internes / part de placement total
set arithabort numeric_truncation off

update #TPLACEMT2
   set RETSIGSHA3_R = (case when RETSIGSHA2_R NOT in (0,null)
                            then convert( decimal(9,8),RETSIGSHA2_R / RETSIGSHA1_R )
                            else 0
                       end)

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20020 "Erreur update #Tplacemt2"
    return 1
end


if @TYPE_CF='ALL'
begin
   select retctr_nf 'tmp_retctr_nf',
          retsec_nf 'tmp_retsec_nf',
          rty_nf    'tmp_rty_nf',
          count(*)  'tmp_nb_ligne',
          sum(case when SSDRTO_B = 0 then 0 else RETSIGSHA2_R end) 'tmp_sum_RETSIGSHA2_R',
          sum(RETSIGSHA3_R) 'tmp_sum_RETSIGSHA3_R'
   into #tmp_TPLACEMT3
   from #TPLACEMT2
   where isnull(PLC_NT,0) >0
   group by retctr_nf, retsec_nf, rty_nf

   update #TPLACEMT2
      set RETSIGSHA2_R = b.tmp_sum_RETSIGSHA2_R,
          RETSIGSHA3_R = b.tmp_sum_RETSIGSHA3_R
   from #TPLACEMT2 a, #tmp_TPLACEMT3 b
   where a.retctr_nf = b.tmp_retctr_nf
     and a.retsec_nf = b.tmp_retsec_nf
     and a.rty_nf    = b.tmp_rty_nf
     and a.plc_nt is null
end

select RETCTR_NF,
       RETSEC_NF,
       RTY_NF,
       PLC_NT,
       RETSIGSHA1_R,
       case when SSDRTO_B = 0 then 0 else RETSIGSHA2_R end RETSIGSHA2_R,
       RETSIGSHA3_R,
       RTO_NF,         
       NB_LIGNE        
from #TPLACEMT2 where  RETSIGSHA3_R NOT in (0,null)
order by RETCTR_NF, RTY_NF, RETSEC_NF, PLC_NT

select @erreur = @@error
if @erreur != 0
begin
   raiserror 20022 "APPLICATIF;TPLACEMT" /* erreur de lecture */
   return 1
end

return 0
go

IF OBJECT_ID('dbo.PsPLACEMTI17_35') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsPLACEMTI17_35 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsPLACEMTI17_35 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsPLACEMTI17_35 */
GRANT EXECUTE ON dbo.PsPLACEMTI17_35 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPLACEMTI17_35 TO GDBBATCH
go

