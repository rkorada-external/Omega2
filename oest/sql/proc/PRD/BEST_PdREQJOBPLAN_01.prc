USE BEST
Go

IF OBJECT_ID('dbo.PdREQJOBPLAN_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdREQJOBPLAN_01
   PRINT '<<< DROPPED PROC dbo.PdREQJOBPLAN_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PdREQJOBPLAN_01
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
      @p_erreur       varchar(64)=NULL output
     )
as

/***************************************************

Programme               : PdREQJOBPLAN_01

Fichier script associé  : BEST_PdREQJOBPLAN_01.PRC

Domaine                 : (ES) Estimation

Base principale         : BEST

Version                 : 1

Auteur                  : Tony RIPERT

Date de creation        : 06/09/2010

Description du programme:

      suppression d'enregistrement dans TREQJOBPLAN

Parametres:
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @nbligne  smallint,
        @nbtime   smallint

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
begin
   select @tran_imbr = 0
   BEGIN TRAN
end

 delete BEST..TREQJOBPLAN
  where balsheyea_nf = @p_balsheyea_nf
    and balshtmth_nf = @p_balshtmth_nf
--    and ssd_cf       = @p_ssd_cf
    and reqcod_ct    = @p_reqcod_ct
    and cre_d        = @p_cre_d
    and convert(varchar(8),clodat_d)   = convert(varchar(8),@p_clodat_d)


select @erreur = @@error, @nbligne = @@rowcount

if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
   goto fin
  end


if @nbligne = 0
  begin
   if @nbtime = 0
     begin
      select @p_erreur = "20012 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
     end
   else
     begin
      select @p_erreur = "20013 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
     end
  end

-- Supprimer les demandes dans best..treqjob
/*If @p_reqcod_ct = 'D'
 BEGIN
    delete BEST..TREQJOB
     where launch_d is null
       and reqcod_ct in ('D','I','J')
 END
ELSE
   BEGIN
      delete BEST..TREQJOB
       where launch_d is null
         and reqcod_ct = @p_reqcod_ct
   ENd

if @erreur != 0
  begin
   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
   goto fin
  end


if @nbligne = 0
  begin
   if @nbtime = 0
     begin
      select @p_erreur = "20012 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
     end
   else
     begin
      select @p_erreur = "20013 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
     end
  end
*/
if @tran_imbr = 0
	COMMIT TRAN

return @erreur

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go

IF OBJECT_ID('dbo.PdREQJOBPLAN_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdREQJOBPLAN_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdREQJOBPLAN_01 >>>'
go

GRANT EXECUTE ON dbo.PdREQJOBPLAN_01 TO public
go

GRANT EXECUTE ON dbo.PdREQJOBPLAN_01 TO GOMEGA
go

