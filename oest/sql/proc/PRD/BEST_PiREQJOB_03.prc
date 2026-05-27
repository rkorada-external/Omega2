USE BEST
go

IF OBJECT_ID('dbo.PiREQJOB_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiREQJOB_03
    IF OBJECT_ID('dbo.PiREQJOB_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiREQJOB_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiREQJOB_03 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PiREQJOB_03
     (
       @p_ssd_cf              USSD_CF,
       @p_cre_d               UUPD_D,
       @p_erreur	varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiREQJOB_03

Fichier script associé : BEST_PiREQJOB_03
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: Jacky Ribot
Date de creation: 24/08/2004

Description du programme:

      Insertion d'enregistrement dans TREQJOB lors du passage S/R

      Les types de demandes sont :
	   PLAN A

Parametres:
       @p_ssd_cf              USSD_CF,
       @p_cre_d               UUPD_D,
       @p_erreur	varchar(64)=NULL output

Conditions d'execution:
Commentaires:
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[002] 07/04/2022 S.Behague   :spira:103647 NS Mind - Estimates automatic upload - ESIJ0810 failure when no IFRS 4 closing planned
*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @erreur = 0
select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

delete BEST..TREQJOB
 where SSD_CF = @p_ssd_cf
   and BALSHEYEA_NF = 1900
   and BALSHTMTH_NF = 1
   and CLODAT_D = '19000101'
   and REQCOD_CT = 'L'

select @erreur = @@error
  if @erreur != 0
  begin
     raiserror 20001 "Error in delete/PiREQJOB_03"
     return 1
  end

insert into BEST..TREQJOB
      (
                ssd_cf,
                balsheyea_nf,
                balshtmth_nf,
                clodat_d,
                reqcod_ct,
                cre_d,
                DBCLO_D,
                launch_d,
                cloper_ls,
                vrs_nf,
                updusr_cf,
                site_cf
      )
 values
      (
        @p_ssd_cf,                                                 -- ssd_cf,
        1900,                                                      -- balsheyea_nf,
        1,                                                         -- balshtmth_nf,
        '19000101',                                                -- clodat_d,
        'L',                                                       -- reqcod_ct,
        convert( char(8),@p_cre_d,112) + ' ' + '23:59:59:010',     -- cre_d,
        convert( char(8),@p_cre_d,112) + ' ' + '23:59:59:010',     -- DBCLO_D,
        convert( char(8),@p_cre_d,112) + ' ' + '23:59:59:010',     -- launch_d,
        'DATE DERNIER TRAITEMENT S&R ',                            -- cloper_ls,
        0,                                                         -- vrs_nf
        'dbo ',                                                    -- updusr_cf    
        @site_cf 
      )


select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   if @erreur = 2601
 	   select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliquée */
   else
 	   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

   goto fin
  end

if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur
go
IF OBJECT_ID('dbo.PiREQJOB_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiREQJOB_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiREQJOB_03 >>>'
go
GRANT EXECUTE ON dbo.PiREQJOB_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiREQJOB_03 TO GDBBATCH
go

