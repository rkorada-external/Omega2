USE BEST
Go
IF OBJECT_ID('dbo.PiCTRGRO_03') IS NOT NULL
BEGIN
  DROP PROC dbo.PiCTRGRO_03
  PRINT '<<< DROPPED PROC dbo.PiCTRGRO_03 >>>'
END
go
create procedure PiCTRGRO_03
(
@p_ssd_cf              USSD_CF,
@p_vrs_nf              numeric(10,0),
@p_segtyp_ct           char(1),
@p_option              tinyint
)
as
/***************************************************
Programme: PiCTRGRO_03
Domaine : Estimations
Base principale : BEST
Auteur: ME31 avec Infotool version 2.0 (AUTO)
Date de creation: 
Description du programme: Last controls for segment and contract and update version
Parametres: 
Conditions d'execution: 
Commentaires:
_____________________
MODIFICATIONS
1 Florent 24/05/2017 :spira:58025 maj pour la gestion option 3 qui est traitée comme la 1
*****************************************************/
declare
 @erreur  int
,@tran_on smallint

select @erreur=0, @tran_on=0
begin tran
select @tran_on=1
-- Suppression totale version et rechargement total

IF @p_option in(1,3)
BEGIN
  if @tran_on=1 commit tran

  select @tran_on=0
  begin tran
  select @tran_on=1
  EXECUTE @erreur = BEST..PuVERSION_05 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct with recompile
  if @erreur!=0 goto fin
END

-- Suppression partielle version et rechargement partiel
ELSE IF @p_option=2
BEGIN
  EXECUTE @erreur = BEST..PuVERSION_03 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct with recompile
  if @erreur!=0 goto fin
END

if @tran_on=1 commit tran
return 0

fin:
if @erreur != 0
begin
  if @tran_on = 1
  begin
    rollback tran
    IF @p_option in(1,3)
    BEGIN
      DELETE BEST..TCTRANO
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
      DELETE BEST..TSEGANO
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
      DELETE BEST..TSEGEST
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
      DELETE BEST..TLABOCY
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
      DELETE BEST..TSEGMENT
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
      DELETE BEST..TCTRGRO
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
    END
    ELSE IF @p_option=2
    BEGIN
      DELETE BEST..TSEGANO
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
      DELETE BEST..TSEGEST
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
      DELETE BEST..TLABOCY
       WHERE VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
    END
  end   -- fin du RollBack
  raiserror 20005 "FAILED: PiCTRGRO_03 " 
  return @erreur
end
go
IF OBJECT_ID('dbo.PiCTRGRO_03') IS NOT NULL
  PRINT '<<< CREATED PROC dbo.PiCTRGRO_03 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC dbo.PiCTRGRO_03 >>>'
go
GRANT EXECUTE ON dbo.PiCTRGRO_03 TO GOMEGA, GDBBATCH
go
