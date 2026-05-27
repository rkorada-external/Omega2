USE BEST
go

IF OBJECT_ID('dbo.PdCTRULT_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdCTRULT_02
   PRINT '<<< DROPPED PROC dbo.PdCTRULT_02 >>>'
END
go


/*
 * creation de la procedure
*/

create procedure PdCTRULT_02
as
/***************************************************

Programme: PdCTRULT_02
Fichier script associé : ESDULT02.PRC
Domaine : (ES) Estimation
Base principale : BEST

Version: 1
Auteur: O.GIRAUX
Date de creation:04/01/2000
Description du programme:
      Purge des facultatives dans les ultimes +
	Purge de l'historique des estimations pour les positions
	dont la date de création < derniere situation - 2 ans

Parametres: Aucun
Conditions d'execution:
Commentaires:

_________________
MODIFICATION 1

Auteur: Florence Charles
Date: 28/11/2000
Version:
Description: On ne supprime pas la 1ère ligne des ultimes

_________________
MODIFICATION 2

Auteur: O. Arik
Date: 15/07/2002
Version:
Description: Le delete doit se faire contrat par contrat
suivant le min de cre_d et le max de cre_d et non
par le min et la max de cre_d de tous les contrats.

MODIFICATION 3
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
*****************************************************/


declare @erreur int,
	 @tran_on smallint,
     @cred_max datetime,
     @cred_min datetime


select @erreur = 0
select @tran_on = 0

/* create  par j. Ribot (MOD2b)  */
CREATE TABLE #ult
(
    CTR_NF       UCTR_NF           NOT NULL,
    END_NT       UEND_NT           NOT NULL,
    SEC_NF       USEC_NF           NOT NULL,
    UWY_NF       UUWY_NF           NOT NULL,
    UW_NT        UUW_NT            NOT NULL,
    MAX_CRE_D    UUPD_D            DEFAULT getdate(),
    MIN_CRE_D    UUPD_D            DEFAULT getdate()
)

/* Mis en commentaire par O. Arik (MOD2)
CREATE TABLE #ult
(
    CTR_NF       UCTR_NF           NOT NULL,
    END_NT       UEND_NT           NOT NULL,
    SEC_NF       USEC_NF           NOT NULL,
    UWY_NF       UUWY_NF           NOT NULL,
    UW_NT        UUW_NT            NOT NULL,
    CRE_D        UUPD_D            DEFAULT getdate(),
    SSD_CF       USSD_CF           NOT NULL,
    DIV_NT       UDIV_NT           NOT NULL,
    CUR_CF       UCUR_CF           DEFAULT '',
    CALAMTPRM_M  UAMT_M                NULL,
    ENTAMTPRM_M  UAMT_M                NULL,
    RETAMTPRM_M  UAMT_M                NULL,
    ADMMODPRM_CT char(1)           DEFAULT '',
    RESPRM_M     UAMT_M                NULL,
    CALAMTCLM_M  UAMT_M                NULL,
    ENTAMTCLM_M  UAMT_M                NULL,
    RETAMTCLM_M  UAMT_M                NULL,
    ADMMODCLM_CT char(1)           DEFAULT '',
    ORICOD_LS    UL16                  NULL,
    UPDUSR_CF    char(10)              NULL,
    CREUSR_CF    UUPDUSR_CF        DEFAULT user,
    LSTUPD_D     UUPD_D            DEFAULT getdate(),
    LSTUPDUSR_CF UUPDUSR_CF        DEFAULT user
)
*/
/* ------------------------------------------------------------
   Début de la transaction
 -------------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_on = 1
   BEGIN TRAN
  end

/* Mis en commentaire par O. Arik (MOD2)*/
/*insert into #ult
select * from BEST..TCTRULT
group by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt
having (cre_d = max(cre_d) ) or  (cre_d = min(cre_d))
order by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt
*/

insert into #ult
select ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt,
max_cre_d=max(cre_d),min_cre_d = min(cre_d)   ---into #ult
from BEST..TCTRULT
group by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt
order by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20003 "Erreur lors du select dans #ult"
    goto fin
end

/* Mis en commentaire par O. Arik (MOD2)
select @cred_min = ( select min(cre_d) from #ult )
select @cred_max = ( select max(cre_d) from #ult )
*/

delete TCTRULT
from BEST..TCTRULT a, #ult b
where a.ctr_nf = b.ctr_nf
and a.end_nt = b.end_nt
and a.uwy_nf = b.uwy_nf
and a.sec_nf = b.sec_nf
and a.uw_nt = b.uw_nt
--and a.cre_d< dateadd(yy,-2, @cred_max)
and a.cre_d< dateadd(yy,-2, max_cre_d)
--and a.cre_d> @cred_min
and a.cre_d> min_cre_d


select @erreur = @@error
if @erreur != 0
begin
    raiserror 20005 "Erreur lors de la suppression des lignes datant de plus de 2 ans"
    goto fin
end



/* ------------------------------------------------------------
   Fin de la transaction
 -------------------------------------------------------------- */

if @tran_on = 1
	 COMMIT TRAN

DROP TABLE #ult

return 0


fin:
if @tran_on = 1
begin
	 ROLLBACK TRAN
	return @erreur
end

go


/*
 * fin de la procedure
 */


IF OBJECT_ID('dbo.PdCTRULT_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PdCTRULT_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PdCTRULT_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdCTRULT_02
 */
GRANT EXECUTE ON dbo.PdCTRULT_02 TO GOMEGA
go

