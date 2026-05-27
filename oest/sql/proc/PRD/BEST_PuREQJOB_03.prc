USE BEST
Go
 /* DROP PROC dbo.PuREQJOB_03
*/
IF OBJECT_ID('dbo.PuREQJOB_03') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuREQJOB_03
   PRINT '<<< DROPPED PROC dbo.PuREQJOB_03 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PuREQJOB_03
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint
     )
as

/***************************************************

Programme: PuREQJOB_03

Fichier script associé : BEST_PuREQJOB_03
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI
Date de creation: 31-12-2003

Description du programme:

      Mise a jour des Ultimes au moment des comptes complet en Période Exceptionnelle.
      Maj de la date de début de prise en compte complet (launch_d de TREQJOB) par la Période Normale (end_d de BCTA..TBLCSHTD)

Parametres:
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint

Conditions d'execution:

Commentaires:

_________________
MODIFICATION 1

12/09/2008  JF. VDE SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 à 64 caractères
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur int, @tran_imbr	bit

declare @v_clodat_d            datetime,
        @v_cre_d               UUPD_D,
        @v_reqcod_ct           char(1),
        @v_ssd_cf              USSD_CF,
        @v_cloper_ls           UL64,        -- [SPOT15758] vde
        @v_dbclo_d             UUPD_D,
        @v_launch_d            UUPD_D,
        @v_updusr_cf           UUSR_CF,
        @v_vrs_nf              numeric,
        @v_end_d              UUPD_D

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

/* Recuperation de la Periode Normale */
SELECT @v_end_d = min(end_d)
FROM BCTA..TBLCSHTD a, BREF..TBATCHSSD b
WHERE DMN_CF = 1
  AND A.SSD_CF       = B.SSD_CF
  AND B.BATCHUSER_CF = @suser_Name
  AND BLCSHTYEA_NF   = @p_balsheyea_nf
  AND BLCSHTMTH_NF   = @p_balshtmth_nf

 select @erreur = @@error
 if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;BEST..TREQJOB - Erreur Selection Periode Normale" /* erreur de selection */
      goto fin
   end

if @v_end_d = NULL
    begin
        goto fin
    end

select @v_clodat_d = @v_end_d
select @v_cre_d = @v_end_d
select @v_reqcod_ct = 'U'
select @v_ssd_cf = 99
select @v_cloper_ls = getdate()
select @v_dbclo_d   = @v_end_d
select @v_launch_d = @v_end_d
select @v_updusr_cf = 'HV'
select @v_vrs_nf  = 2



/* Verification si Mise à Jour de Ligne */
select @p_maj_ligne = count(*)
from   TREQJOB
WHERE  reqcod_ct = 'U' and ssd_cf = 99
AND    SITE_CF = @site_cf

IF @p_maj_ligne > 0
    BEGIN
        /* Mise a Jour */
        Update TREQJOB
        set launch_d = @v_end_d
        where reqcod_ct = 'U' and ssd_cf = 99
        AND    SITE_CF = @site_cf
       if @erreur != 0
          begin
 	        print "Erreur de mise a jour TREQJOB "   /* cle dupliquée */
          end
    END
ELSE
    BEGIN

        /* INSERTION */
        insert into TREQJOB
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
                    SITE_CF
                  )
       values
                  (
                    @p_balsheyea_nf,
                    @p_balshtmth_nf,
                    @v_clodat_d,
                    @v_cre_d,
                    @v_reqcod_ct,
                    @v_ssd_cf,
                    @v_cloper_ls,
                    @v_dbclo_d,
                    @v_launch_d,
                    @v_updusr_cf,
                    @v_vrs_nf,
                    @site_cf
                   )

       select @erreur = @@error
       if @@transtate = 2
          begin
            print "ERREUR TRIGGER"
            goto fin
          end

       if @erreur != 0
          begin
           if @erreur = 2601
 	        print "20002 Erreur Cle duplique ! TREQJOB "   /* cle dupliquée */
          else
 	        print "20001 APPLICATIF;"
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

/*
 * fin de la procedure
 */


IF OBJECT_ID('dbo.PuREQJOB_03') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuREQJOB_03 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuREQJOB_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuREQJOB_03
 */
GRANT EXECUTE ON dbo.PuREQJOB_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuREQJOB_03 TO GDBBATCH
go

