USE BEST
go

IF OBJECT_ID('dbo.PuREQJOB_04') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuREQJOB_04
    IF OBJECT_ID('dbo.PuREQJOB_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuREQJOB_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuREQJOB_04 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PuREQJOB_04
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_cre_d               UUPD_D,
       @p_dbclo_d             UUPD_D,
       @p_clodat_d            UUPD_D
     )
as

/***************************************************

Programme: PuREQJOB_04

Fichier script associé : BEST_PuREQJOB_04
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI
Date de creation: 31-12-2003

Description du programme:
      Les calculs de ESIJ1000.cmd ne sont executés que si le cours de change a évolué depuis la dernière
      execution du JOB.

      Mise a jour de la Date LAUNCH_D de TREQJOB (REQCOD_CT = 'M') par la date de dernière mise à jour
      des cours de change MAX(LSTUPD_D) contenue dans la TABLE BREF..TCURQUOT (SSD_CF = 99).

      Le traitement ESIJ1000.cmd est conditionné de la manière suivante :
            - SI                      [Max(LSTUPD_D) de BREF..TCURQUOT (SSD_CF = 99)]
                 est différente de   [LAUNCH_D de BEST..TREQJOB (REQCOD_CT = 'M')]
             ALORS [EXECUTION DU TRAITEMENT ESIJ1000] et [Nouvelle MAJ de LAUNCH_D]
            - SINON [RIEN]


Parametres:
       @p_balsheyea_nf        smallint
       @p_balshtmth_nf        tinyint
       @p_cre_d               UUPD_D
       @p_dbclo_d             UUPD_D
       @p_clodat_d            datetime


Conditions d'execution:

Commentaires:

_________________
MODIFICATION 001

17/09/2008  JF. VDE SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 à 64 caractères
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur int, @tran_imbr	bit

declare @v_reqcod_ct           char(1),
        @v_cloper_ls           UL64,      -- [SPOT15758] vde
        @v_updusr_cf           UUSR_CF,
        @v_vrs_nf              numeric,
        @v_ssd_cf              USSD_CF

declare @v_maj_datecours       UUPD_D

declare @p_maj_ligne int

select @erreur = 0
select @tran_imbr = 1

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

select @v_reqcod_ct = 'M'
select @v_ssd_cf = 99
select @v_cloper_ls = getdate()
select @v_updusr_cf = 'HV'
select @v_vrs_nf  = 2

/* Recuperation de la DAte du Cours de CHANGE */
SELECT DISTINCT @v_maj_datecours = MAX(lstupd_d)
FROM BREF..TCURQUOT
WHERE ssd_cf = @v_ssd_cf

select @erreur = @@error
 if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;PuREQJOB_04 : BREF..TCURQUOT - Erreur Selection Dernière Date de MAJ de Cours de Change" /* erreur de selection */
      goto fin
   end


/* Verification si Mise à Jour de Ligne dans TREQJOB */
select @p_maj_ligne = count(*)
from   BEST..TREQJOB
WHERE  reqcod_ct = @v_reqcod_ct and ssd_cf = @v_ssd_cf and SITE_CF = @site_cf

IF @p_maj_ligne > 0
    BEGIN
        /* Mise a Jour */
        Update BEST..TREQJOB
        set launch_d = @v_maj_datecours,
            balsheyea_nf = @p_balsheyea_nf,
            balshtmth_nf = @p_balshtmth_nf,
            clodat_d = @p_clodat_d,
            cre_d = @p_cre_d,
            cloper_ls = @v_cloper_ls,
            dbclo_d = @p_dbclo_d,
            updusr_cf = @v_updusr_cf,
            vrs_nf = @v_vrs_nf
        where reqcod_ct = @v_reqcod_ct and ssd_cf = @v_ssd_cf and SITE_CF = @site_cf
       if @erreur != 0
          begin
 	        print "PuREQJOB_04 : Erreur de mise a jour TREQJOB "   /* cle dupliquée */
          end
    END
ELSE
    BEGIN

        /* INSERTION */
        insert into BEST..TREQJOB
                  (
                    balsheyea_nf,
                    balshtmth_nf,
                    clodat_d,
                    cre_d,
                    reqcod_ct,
                    ssd_cf,
                    cloper_ls,
                    dbclo_d,
                    launch_d,
                    updusr_cf,
                    vrs_nf,
                    site_cf
                  )
       values
                  (
                    @p_balsheyea_nf,
                    @p_balshtmth_nf,
                    @p_clodat_d,
                    @p_cre_d,
                    @v_reqcod_ct,
                    @v_ssd_cf,
                    @v_cloper_ls,
                    @p_dbclo_d,
                    @v_maj_datecours,
                    @v_updusr_cf,
                    @v_vrs_nf,
                    @site_cf
                   )

       select @erreur = @@error
       if @@transtate = 2
          begin
            print "PuREQJOB_04 : ERREUR TRIGGER"
            goto fin
          end

       if @erreur != 0
          begin
           if @erreur = 2601
 	        print "PuREQJOB_04 : 20002 Erreur Cle duplique ! TREQJOB "   /* cle dupliquée */
          else
 	        print "PuREQJOB_04 : 20001 APPLICATIF;"
            goto fin
          end
    END


if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur
go
IF OBJECT_ID('dbo.PuREQJOB_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuREQJOB_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuREQJOB_04 >>>'
go
GRANT EXECUTE ON dbo.PuREQJOB_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuREQJOB_04 TO GDBBATCH
go
