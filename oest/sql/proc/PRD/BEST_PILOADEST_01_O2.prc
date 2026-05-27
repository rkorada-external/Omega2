USE BEST
go

IF OBJECT_ID ('dbo.PiTLOADEST_01_O2') IS NOT NULL
   BEGIN
      DROP PROCEDURE dbo.PiTLOADEST_01_O2

      IF OBJECT_ID ('dbo.PiTLOADEST_01_O2') IS NOT NULL
         PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiTLOADEST_01_O2 >>>'
      ELSE
         PRINT '<<< DROPPED PROCEDURE dbo.PiTLOADEST_01_O2 >>>'
   END
go

CREATE PROCEDURE dbo.PiTLOADEST_01_O2 (@p_ssd_cf             USSD_CF,
                                       @p_esb_cf             UESB_CF,
                                       @p_FILE_LL            UL64,
                                       @p_FILEUNIXNAME_LL    UL64,
                                       @p_FILETYPE_NT        tinyint,
                                       @p_CREUSR_CF          UUSR_CF,
                                       @p_STATUS_CF          tinyint,
                                       @p_NBLINES_NT         int)
AS
   /***************************************************
   Domaine : (ES) Estimation
   Base principale : BEST
   Version: 1
   Auteur:
   Date de creation:
   Description du programme:
         *
   Conditions d'execution:
   Commentaires:
   _________________
   MODIFICATIONS
   1





   *****************************************************/
   DECLARE
      @FILENO_NT   UUWENTNBR_NT,
      @erreur      int,
      @tran_imbr   bit,
      @p_erreur    VARCHAR (64)

   SELECT @erreur = 0,
          @tran_imbr = 1

   IF @@trancount = 0
      BEGIN
         SELECT @tran_imbr = 0
         BEGIN TRAN
      END


-- maj numÃ©ro de la ligne de participation variable crÃ©Ã©e
select @FILENO_NT=max(FILENO_NT)+1 from TLOADEST
select @erreur=@@error
if @erreur!= 0 goto fin

-- init @FILENO_NT si aucun enreg
if @FILENO_NT=null select @FILENO_NT=1

insert into TLOADEST
  (
 FILENO_NT         ,
    SSD_CF             ,
    ESB_CF              ,
    FILE_LL           ,
    FILEUNIXNAME_LL          ,
    FILETYPE_NT             ,
    CRE_D       ,
    NBLINES_NT   ,
    NBLINESKO_NT   ,
    NBANO_NT   ,
    CREUSR_CF       ,
    STATUS_CF
  )
 values
  (
  @FILENO_NT,
  @p_ssd_cf      ,
  @p_esb_cf         ,
  @p_FILE_LL                 ,
  @p_FILEUNIXNAME_LL ,
  @p_FILETYPE_NT ,
  getdate(),
  @p_NBLINES_NT,
  0,
  0,
  @p_CREUSR_CF ,
  0
  )
  
  select * from TLOADEST where FILENO_NT = @FILENO_NT
select @erreur=@@error
if @erreur != 0
begin
  if @erreur=2601
    select @p_erreur='20002 APPLICATIF;2601;'
  else
    select @p_erreur='20001 APPLICATIF;' + convert(varchar(10),@erreur) + ';'
  goto fin
end

if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
EXEC sp_procxmode 'dbo.PiTLOADEST_01_O2', 'unchained'
go

IF OBJECT_ID ('dbo.PiTLOADEST_01_O2') IS NOT NULL
   PRINT '<<< CREATED PROCEDURE dbo.PiTLOADEST_01_O2 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROCEDURE dbo.PiTLOADEST_01_O2 >>>'
go

GRANT EXECUTE ON dbo.PiTLOADEST_01_O2 TO GOMEGA
go