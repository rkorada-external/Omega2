use BEST
go

use BEST
go

/***************************************************************************/
/* proc 'temporaire', qui ne tournera qu'une fois, pour selectionner les   */
/* versements au 31 12 96                                                  */
/***************************************************************************/


/*
 * DROP PROC dbo.PsCESSION_02
 */
IF OBJECT_ID('dbo.PsCESSION_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCESSION_02
    PRINT '<<< DROPPED PROC dbo.PsCESSION_02 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsCESSION_02

as

/***************************************************

Programme: PsCESSION_02
Fichier script associé : ESSCES02.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: C.Soulier (CGI)
Date de creation: 6 janvier 1998
Description du programme: 

	Proc 'temporaire' pour la selection des versements fin bilan 1996      

Parametres: aucun
Conditions d'execution: 
Commentaires: 
****************************************************/

declare @erreur int

/************* methode directe  *********************/
select 
 a.CTR_NF,
 0,
 a.SEC_NF,
 a.UWY_NF,
 a.UW_NT	,
 a.RETCTR_NF,
 0,
 a.RETSEC_NF,
 a.RTY_NF,
 1,
 a.CESACCSTA_N,
 a.CESACCEND_N,
 a.CESSH_R,
 a.SSD_CF,
 b.esb_cf,
 b.retctrcat_cf,
 a.ACCADMTYP_CT,
 b.retaccadm_b,
 b.clecutper_b,
 b.clecutper_nb,
 a.LOB_CF,
 '',
 cesord_nt	/* pour selectionner ensuite le max */
from bret..tcession a, bret..tretctr b
where convert(char(8),a.lasbalshe_d,112)='19961231'
and a.retctr_nf*=b.retctr_nf
AND   a.rty_nf*=b.rty_nf
/* 
group by a.ctr_nf, a.sec_nf, a.uwy_nf, a.uw_nt,a.retctr_nf, a.retsec_nf,
a.rty_nf, a.cesaccsta_n, a.cesaccend_n
having cesord_nt=max(cesord_nt)
*/

/** pour verifier que la jointure externe avec tretctr ne modifie
 pas le nombre de lignes selectionnees: ***/
/* ok, fait
select 
 a.CTR_NF,
 0,
 a.SEC_NF,
 a.UWY_NF,
 a.UW_NT	,
 a.RETCTR_NF,
 0,
 a.RETSEC_NF,
 a.RTY_NF,
 1,
 a.CESACCSTA_N,
 a.CESACCEND_N,
 a.CESSH_R,
 a.SSD_CF,
 a.ACCADMTYP_CT,
 a.LOB_CF,
 ''
from bret..tcession a
where convert(char(8),a.lasbalshe_d,112)='19961231'
*/


/******************************************************/


/*************** methode table temporarire *******************************
create table #tcession
(ctr_nf uctr_nf not null,
end_nt uend_nt default 0,
sec_nf usec_nf not null,
uwy_nf uuwy_nf not null,
uwy_nt uuw_nt default 1,
retctr_nf uretctr_nf,
retend_nt uend_nt default 0,
retsec_nf uretsec_nf not null,
rty_nf uuwy_nf not null,
retuw_nt uuw_nt default 1,
cesaccsta_n int not null,
cesaccend_n int not null,
cessh_r ushorat_r not null,
ssd_cf tinyint not null,
esb_cf tinyint null,
retctrcat_cf char(2) default'',
accadmtyp_ct tinyint null,
retaccadm_b bit default 0,
clecutper_b bit default 0,
clecutper_nb int null,
lob_cf char(2) not null,
cur_cf ucur_cf default '')


insert into #tcession
(ctr_nf,
end_nt,
sec_nf,
uwy_nf,
uwy_nt,
retctr_nf,
retend_nt,
retsec_nf,
rty_nf,
retuw_nt,
cesaccsta_n,
cesaccend_n,
cessh_r,
ssd_cf,
accadmtyp_ct,
lob_cf)
select 
 CTR_NF,
 0,
 SEC_NF,
 UWY_NF,
 UW_NT	,
 RETCTR_NF,
 0,
 RETSEC_NF,
 RTY_NF,
 1,
 CESACCSTA_N,
 CESACCEND_N,
 CESSH_R,
 SSD_CF,
 ACCADMTYP_CT,
 LOB_CF
from bret..tcession a
where convert(char(8),a.lasbalshe_d,112)='19961231'

/*create index iCes on #tcession (RETCTR_NF,  RTY_NF)*/

update #tcession
set esb_cf=b.esb_cf,
 retctrcat_cf=b.retctrcat_cf,
 retaccadm_b=b.retaccadm_b,
 clecutper_b=b.clecutper_b,
 clecutper_nb=b.clecutper_nb
from #tcession a, bret..tretctr b
where a.retctr_nf=b.retctr_nf
AND   a.rty_nf=b.rty_nf

-- select final pour le bcpout

select
ctr_nf,
end_nt,
sec_nf,
uwy_nf,
uwy_nt,
retctr_nf,
retend_nt,
retsec_nf,
rty_nf,
retuw_nt,
cesaccsta_n,
cesaccend_n,
cessh_r,
ssd_cf,
esb_cf,
retctrcat_cf,
accadmtyp_ct,
retaccadm_b,
clecutper_b,
clecutper_nb,
lob_cf,
cur_cf
from #tcession

***********************************************************************************************/

return 0
go

IF OBJECT_ID('dbo.PsCESSION_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCESSION_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCESSION_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCESSION_02
 */
GRANT EXECUTE ON dbo.PsCESSION_02 TO GOMEGA
go

