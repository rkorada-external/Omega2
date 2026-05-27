use BEST
go
if object_id('dbo.PuREQJOB_02') is not null
begin
  drop PROC dbo.PuREQJOB_02
  print '<<< DROPPED PROC dbo.PuREQJOB_02 >>>'
end
go
create procedure PuREQJOB_02
  (
  @p_cre_d        datetime,
  @p_balsheyea_nf smallint,
  @p_balshtmth_nf tinyint,
  @p_clodat_d     datetime,
  @p_dbclo_d      datetime,
  @p_clodatmax_d  varchar(8)
  )
with execute as caller as
/***************************************************
Programme:                  PuREQJOB_02
Fichier script associé :    ESUREQ02.PRC
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     ME69 avec Infotool version 2.0 (AUTO)
Description du programme:
    - Mise a jour de la date de traitement ( LAUNCH_D ) dans BEST..TREQJOB pour les filiales d'un inventaire donné
Parametres:     - @p_cre_d : la date de traitement 
                - @p_balsheyea_nf : année ( période comptable )
                - @p_balshtmth_nf : mois ( période comptable )
                - @p_clodat_d : libellé d'inventaire
                - @p_dbclo_d : date d'arrété
                - @p_clodatmax_d :
_________________
MODIFICATION 1
Auteur:	HA-THUC
Date:		28/11/97
Version:	1
Description:	
MODIFICATION 2
Auteur:	Y. BOURDAILLET
Date:		13/05/98
Version:	1
Description:	selection sur inf(CRE_D) et egalite sur le reste de la cle
		ET mise a jour forcee de DBCLO_D
	Le 20/07/98	Maj de LAUNCH_D si REQCOD_CT = I ou J 
			(avant seulement si Reqcod_ct =I)
_________________
MODIFICATION 3
Auteur:	F.Charles
Date:		15/05/2001
Version:	1
Description:	Changmnt critere-> convert( char(8), B.CLODAT1_D, 112 ) = @p_clodatmax_d
et non plus convert( char(8), B.CLODAT4_D, 112 ) = @p_clodat_d
pour 4eme cas
_________________
MODIFICATION    [029]
Auteur:         D.GATIBELZA
Date:           12/03/2010
Version:        10.1
Description:    SRVIE16960 Adaptation de TLIFSTAREP  création d'une version du plan vie à la demande + ES plan à intégrer
_________________
[030] 11/05/2012 Roger Cassis :spot:23802 - Modifications pour Solvency
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/
declare @erreur int,
        @tran_imbr  bit

select @erreur = 0
select @tran_imbr = 1

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

print '--> Site %1! user %2!' , @site_cf, @suser_Name
select * from BTRAV..TESTSSD

/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */
if @@trancount = 0
begin
    select @tran_imbr = 0
    begin tran
end


/* maj quand demande PLAN */
update BEST..TREQJOB
   set LAUNCH_D = @p_cre_d
from BEST..TREQJOB
where REQCOD_CT = "A"
  and LAUNCH_D =  null
  and SITE_CF = @site_cf

select @erreur = @@error
if @erreur != 0
    goto fin


/*******************************************/
/* Mise à jour de BEST..TREQJOB */
/*******************************************/

/* 1er cas: si libellé d'inventaire = CLODAT1_D */
update BEST..TREQJOB
   set LAUNCH_D = @p_cre_d, DBCLO_D = @p_dbclo_d
from BEST..TREQJOB A, BTRAV..TESTSSD B
where A.SSD_CF = B.SSD_CF
  and A.BALSHEYEA_NF = @p_balsheyea_nf
  and A.BALSHTMTH_NF = @p_balshtmth_nf
  and convert( char(8), B.CLODAT1_D, 112 ) = @p_clodat_d
  and ( A.REQCOD_CT = "I" or A.REQCOD_CT = "J" or A.REQCOD_CT = "L" )
  and A.LAUNCH_D =  null
  and A.SITE_CF  = @site_cf
/*  
  and A.CRE_D = ( select min (C.CRE_D) 
                  from BEST..TREQJOB C
                  where C.SSD_CF = A.SSD_CF
                    and C.BALSHEYEA_NF = A.BALSHEYEA_NF
                    and C.BALSHTMTH_NF = A.BALSHTMTH_NF
                    and C.CLODAT_D  = A.CLODAT_D
                    and ( C.REQCOD_CT = "I" or C.REQCOD_CT = "J" or C.REQCOD_CT = "L" )
                    and C.LAUNCH_D = null 
                    and SITE_CF    = @site_cf)
*/
select @erreur = @@error
if @erreur != 0
    goto fin


/* 2ème cas: si libellé d'inventaire = CLODAT2_D */
update BEST..TREQJOB
   set LAUNCH_D = @p_cre_d, DBCLO_D = @p_dbclo_d
from BEST..TREQJOB A, BTRAV..TESTSSD B
where A.SSD_CF = B.SSD_CF
  and A.BALSHEYEA_NF = @p_balsheyea_nf
  and A.BALSHTMTH_NF = @p_balshtmth_nf
  and convert( char(8), B.CLODAT2_D, 112 ) = @p_clodat_d
  and ( A.REQCOD_CT = "I" or A.REQCOD_CT = "J" or A.REQCOD_CT = "L" )
  and A.LAUNCH_D =  null
  and A.SITE_CF  = @site_cf
/*  
  and A.CRE_D = ( select min (C.CRE_D)
                  from BEST..TREQJOB C
                  where C.SSD_CF = A.SSD_CF
                    and C.BALSHEYEA_NF = A.BALSHEYEA_NF
                    and C.BALSHTMTH_NF = A.BALSHTMTH_NF
                    and C.CLODAT_D  = A.CLODAT_D
                    and ( C.REQCOD_CT = "I" or C.REQCOD_CT = "J" or C.REQCOD_CT = "L" )
                    and C.LAUNCH_D = null                    
                    and SITE_CF    = @site_cf)
*/
select @erreur = @@error
if @erreur != 0
    goto fin


/* 3ème cas: si libellé d'inventaire = CLODAT3_D */
update BEST..TREQJOB
   set LAUNCH_D = @p_cre_d, DBCLO_D = @p_dbclo_d
from BEST..TREQJOB A, BTRAV..TESTSSD B
where A.SSD_CF = B.SSD_CF
  and A.BALSHEYEA_NF = @p_balsheyea_nf
  and A.BALSHTMTH_NF = @p_balshtmth_nf
  and convert( char(8), B.CLODAT3_D, 112 ) = @p_clodat_d
  and ( A.REQCOD_CT = "I" or A.REQCOD_CT = "J" or A.REQCOD_CT = "L" )
  and A.LAUNCH_D =  null
  and A.SITE_CF  = @site_cf
/*  
  and A.CRE_D = ( select min (C.CRE_D) 
                  from BEST..TREQJOB C
                  where C.SSD_CF = A.SSD_CF
                    and C.BALSHEYEA_NF = A.BALSHEYEA_NF
                    and C.BALSHTMTH_NF = A.BALSHTMTH_NF
                    and C.CLODAT_D  = A.CLODAT_D
                    and ( C.REQCOD_CT = "I" or C.REQCOD_CT = "J" or C.REQCOD_CT = "L" )
                    and C.LAUNCH_D = null                    
                    and SITE_CF    = @site_cf)
*/

select @erreur = @@error
if @erreur != 0
    goto fin


/* 4ème cas: si libellé d'inventaire = CLODAT4_D */
update BEST..TREQJOB
   set LAUNCH_D = @p_cre_d, DBCLO_D = @p_dbclo_d
from BEST..TREQJOB A, BTRAV..TESTSSD B
where A.SSD_CF = B.SSD_CF
  and A.BALSHEYEA_NF = @p_balsheyea_nf
  and A.BALSHTMTH_NF = @p_balshtmth_nf
  and convert( char(8), B.CLODAT1_D, 112 ) = @p_clodatmax_d
  and ( A.REQCOD_CT = "I" or A.REQCOD_CT = "J" or A.REQCOD_CT = "L" )
  and A.LAUNCH_D =  null
  and A.SITE_CF  = @site_cf
/*  
  and A.CRE_D = ( select min (C.CRE_D)
                  from BEST..TREQJOB C
                  where C.SSD_CF = A.SSD_CF
                    and C.BALSHEYEA_NF = A.BALSHEYEA_NF
                    and C.BALSHTMTH_NF = A.BALSHTMTH_NF
                    and C.CLODAT_D  = A.CLODAT_D
                    and ( C.REQCOD_CT = "I" or C.REQCOD_CT = "J" or C.REQCOD_CT = "L" )
                    and C.LAUNCH_D = null                     
                    and SITE_CF    = @site_cf)
*/  

select @erreur = @@error
if @erreur != 0
    goto fin

/* 5ème cas: pour inventaires Solvency [030] */
update best..TREQJOB
   set LAUNCH_D    = getdate(),
       UPDUSR_CF   = 'iclo'
where reqcod_ct   in ('E') 
  and cloper_ls   is not null
  and LAUNCH_D    = null
  and SITE_CF     = @site_cf


select @erreur = @@error
if @erreur != 0
    goto fin

/**********************************************************************************/
if @tran_imbr = 0
    commit tran

return 0

fin:
if @tran_imbr = 0
    rollback tran

return @erreur
go
if object_id('dbo.PuREQJOB_02') is not null
  print '<<< CREATED PROC dbo.PuREQJOB_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuREQJOB_02 >>>'
go
grant execute on dbo.PuREQJOB_02 TO GOMEGA
go
grant execute on dbo.PuREQJOB_02 TO GDBBATCH
go
