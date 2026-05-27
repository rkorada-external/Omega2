USE BEST
go
IF OBJECT_ID('PsCESSION_SERQ_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PsCESSION_SERQ_01
    IF OBJECT_ID('PsCESSION_SERQ_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsCESSION_SERQ_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsCESSION_SERQ_01 >>>'
END
go
/*
 * creation de la procedure
 */

create procedure PsCESSION_SERQ_01

as

/***************************************************

Programme: PsCESSION_SERQ_01
Fichier script associé : BEST_PsCESSION_01_SERQ.prc
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: M.NAJI
Date de creation: 05/05/2025
Description du programme:

SPIRA 111672  Evolution SERQ : Merge  files

Parametres: aucun
Conditions d'execution:
Commentaires:

[001] 13/08/2025 : M.NAJI US5850 SERQS - Impact estimation IFRS17
[002] 12/11/2025 :M.NAJI la US 7359 SERQS - Impact estimation IFRS17 – Closing suite aux tests BU en INT
*****************************************************/

declare @erreur int

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

 select
            a.CTR_NF,
            0 END_NT,
            a.SEC_NF,
            a.UWY_NF,
            a.UW_NT     ,
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
            retpcpcur_cf=case when    c.RETSPECUR_CF is not null and c.RETSPECUR_CF != ' ' then c.RETSPECUR_CF else c.RETSPECUR_CF end,
            b.CONRETCTR_B,
            b.ACCFAM_CT
    from    bret..tcession a
			join   BREF..TBATCHSSD bssd on   bssd.ssd_cf = a.ACCSSD_CF and bssd.BATCHUSER_CF =@curr_usr
			left outer join  bret..tretctr b on   a.retctr_nf=b.retctr_nf    and        a.rty_nf=b.rty_nf
			left outer join   bret..tretsec c on    a.retctr_nf = c.retctr_nf         and a.retsec_nf = c.retsec_nf   and a.rty_nf = c.rty_nf
			left outer join   BREF..TBATCHSSD acc on   a.ACCSSD_CF = acc.SSD_CF
			left outer join   BREF..TBATCHSSD ret on    a.RETSSD_CF = ret.SSD_CF
			where       (   (a.cesupdtyp_cf='' AND a.cessts_cf='01') OR
						   (a.cesupdtyp_cf='S' AND a.cessts_cf='03')
						)
			and         a.CESSIONCAT_CF= '1'
			and 	( ( a.ssd_cf = 99 and acc.BATCHUSER_CF  = ret. BATCHUSER_CF ) or (acc.BATCHUSER_CF != ret.BATCHUSER_CF and a.ssd_cf = 99 ) )

select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCESSION"
      return @erreur
   end

return 0
go
EXEC sp_procxmode 'PsCESSION_SERQ_01', 'unchained'
go
IF OBJECT_ID('PsCESSION_SERQ_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsCESSION_SERQ_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsCESSION_SERQ_01 >>>'
go
GRANT EXECUTE ON PsCESSION_SERQ_01 TO GOMEGA,GDBBATCH
go
