USE BEST
go
IF OBJECT_ID('PsCESSION_04') IS NOT NULL
BEGIN
    DROP PROCEDURE PsCESSION_04
    IF OBJECT_ID('PsCESSION_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsCESSION_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsCESSION_04 >>>'
END
go
/*
 * creation de la procedure
 */

create procedure PsCESSION_04

as

/***************************************************
Programme: PsCESSION_04
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: D.DA SILVA TEIXEIRA
Date de creation: 9 Juin 2023
Description du programme:
   Extraction des versements de la base retrocession
   avec selection des les versements valides et actifs
   ou historises.
Parametres: aucun
Conditions d'execution:
Commentaires:
1 -- DAD -- 11/06/2023 -- spira:109759 -- New file FCES type to be created including the RETRO link that will include the historical links
2 -- DAD -- 21/06/2023 -- spira:109759 -- Remove CESSIONCAT_CF
3 -- DAD -- 21/07/2023 -- spira:110209 -- update for select distinct
*****************************************************/

declare @erreur int

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr



select
   a.CTR_NF,
   0 END_NT,
   a.SEC_NF,
   a.UWY_NF,
   a.UW_NT	,
   a.RETCTR_NF,
   0 RETEND_NT,
   a.RETSEC_NF,
   a.RTY_NF,
   1 RETUW_NT,
   a.CESACCSTA_N,
   a.CESACCEND_N,
   a.CESSH_R,
   b.SSD_CF,
   b.esb_cf,
   b.retctrcat_cf,
   a.ACCADMTYP_CT,
   b.retaccadm_b,
   b.clecutper_b,
   b.clecutper_nb,
   a.LOB_CF,
   '' CUR_CF,
   b.retpcpcur_cf ,
   b.CONRETCTR_B,
   b.ACCFAM_CT
into #CESSION    
from	bret..tcession a, bret..tretctr b, #ssds s
where ((a.cesupdtyp_cf='' AND a.cessts_cf='01') OR (a.cessts_cf='03'))
   -- and a.CESSIONCAT_CF= "1"  -- 2 --
   and a.retctr_nf*=b.retctr_nf
   and a.rty_nf*=b.rty_nf
   and a.ssd_cf = s.ssd_cf


select @erreur = @@error

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TCESSION"
   return @erreur
end
   
-- Mettre � jour la devise � partir de la section si cette derni�re est renseign�e   
update #CESSION
set retpcpcur_cf = b.RETSPECUR_CF
from  #CESSION c, bret..tretsec b
where c.retctr_nf = b.retctr_nf
   and c.retsec_nf = b.retsec_nf
   and c.rty_nf = b.rty_nf
   and b.RETSPECUR_CF is not null 
   and b.RETSPECUR_CF != ' '


select @erreur = @@error

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TCESSION"
   return @erreur
end
   
-- 3 --
select distinct
   CTR_NF,
   END_NT,
   SEC_NF,
   UWY_NF,
   UW_NT	,
   RETCTR_NF,
   RETEND_NT,
   RETSEC_NF,
   RTY_NF,
   RETUW_NT
from #CESSION
order by CTR_NF, END_NT,SEC_NF,UWY_NF, UW_NT


select @erreur = @@error

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TCESSION"
   return @erreur
end

return 0
go
EXEC sp_procxmode 'PsCESSION_04', 'unchained'
go
IF OBJECT_ID('PsCESSION_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsCESSION_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsCESSION_04 >>>'
go
GRANT EXECUTE ON PsCESSION_04 TO GOMEGA,GDBBATCH
go
