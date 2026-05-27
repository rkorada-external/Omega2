use BEST
go

IF OBJECT_ID('dbo.PiREQJOB_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiREQJOB_02
    IF OBJECT_ID('dbo.PiREQJOB_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiREQJOB_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiREQJOB_02 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PiREQJOB_02
     (
       @p_cre_d               UUPD_D,
       @p_balsheyea_nf        smallint,
       @p_iclodat_d            datetime,
       @p_erreur	varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiREQJOB_02

Fichier script associé : BEST_PiREQJOB_02
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: Jacky Ribot
Date de creation: 31/03/2004

Description du programme:

      Insertion d'enregistrement dans TREQJOB lors de la creation photo plan vie

      Les types de demandes sont :
	   PLAN A

Parametres:
@p_cre_d               UUPD_D,
       @p_balsheyea_nf        smallint,
       @p_iclodat_d            datetime,
       @p_erreur	varchar(64)=NULL output

Conditions d'execution:
Commentaires:
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur int,
        @tran_imbr	bit

select @erreur = 0

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

select @tran_imbr = 1
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end


insert into BEST..TREQJOB
      (
                ssd_cf,
                balsheyea_nf,
                balshtmth_nf,
                clodat_d,
                reqcod_ct,
                cre_d,
                dbclo_d,
                launch_d,
                cloper_ls,
                vrs_nf,
                updusr_cf,
                site_cf
      )
 values
      (
        99,                      -- ssd_cf,
        @p_balsheyea_nf + 1 ,
        1,                       -- balshtmth_nf,
        @p_iclodat_d,            -- clodat_d,
        'A',                     -- reqcod_ct,
        @p_cre_d,                -
        @p_iclodat_d,            -- dbclo_d,
        @p_iclodat_d,            -- launch_d,
        '',                      -- cloper_ls,
        0,                       -- vrs_nf
        'dbo ',                  -- updusr_cf
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
IF OBJECT_ID('dbo.PiREQJOB_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiREQJOB_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiREQJOB_02 >>>'
go
GRANT EXECUTE ON dbo.PiREQJOB_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiREQJOB_02 TO GDBBATCH
go

