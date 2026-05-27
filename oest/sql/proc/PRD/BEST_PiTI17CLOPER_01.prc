USE BEST
go
IF OBJECT_ID('PiTI17CLOPER_01') IS NOT NULL
BEGIN
  DROP PROC PiTI17CLOPER_01
  PRINT '<<< DROPPED PROC PiTI17CLOPER_01 >>>'
END
go
create procedure PiTI17CLOPER_01(
  @p_ssd_cf int,
  @p_esb_cf UESB_CF,
  @p_CRE_D  date,
  @p_NORME      varchar(4))
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: S.Behague
Date de creation: 26/07/2023
Description du programme: 	
	- sélection des informations période étendue ou non dans TI17CLOPER
Conditions d'execution: 
Commentaires:
_________________
[01] - S.Behague :spira:109059 - Life - SAS/Omega interface management during local entity extended period
*****************************************************/
declare   @erreur       int,
          @tran_imbr    bit,
          @datedernierclosing         date,
          @datefinperiode             date,
          @nbjour                     int
select @erreur=0, @tran_imbr=1

if @@trancount = 0
begin
  select @tran_imbr = 0
  BEGIN TRAN
end


-- Sélection de la derniere date de Closing
select @datedernierclosing = max(PSTOMGEND17_D) from bref..tcalend where PSTOMGEND17_D < @p_CRE_D
select @erreur = @@error
if @erreur != 0  goto fin

SELECT @nbjour = 0
if (@p_NORME = 'I17P' )
begin
	SELECT @nbjour =  convert(int,parm5) FROM BEST..TI17CLOPER where ssd_cf = @p_ssd_cf and esb_cf = @p_esb_cf and PARM1 = '1'
	select @erreur = @@error
	if @erreur != 0  goto fin
end
if (@p_NORME = 'I17L' )
begin
	SELECT @nbjour =  convert(int,parm5) FROM BEST..TI17CLOPER where ssd_cf = @p_ssd_cf and esb_cf = @p_esb_cf and PARM2 = '1'
	select @erreur = @@error
	if @erreur != 0  goto fin
end


SELECT @datefinperiode =  dateadd(day,  isnull(@nbjour,0), @datedernierclosing)
select @erreur = @@error
if @erreur != 0  goto fin

if @datefinperiode >= @p_CRE_D
select isnull(@nbjour,0), @datefinperiode, @p_CRE_D, "OK"
else
select isnull(@nbjour,0), @datefinperiode, @p_CRE_D, "KO"




/**********************************************************************************/
if @tran_imbr = 0
   COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN
return 1
go
EXEC sp_procxmode 'dbo.PiTI17CLOPER_01', 'unchained'
go
IF OBJECT_ID('dbo.PiTI17CLOPER_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiTI17CLOPER_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiTI17CLOPER_01 >>>'
go
GRANT EXECUTE ON dbo.PiTI17CLOPER_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiTI17CLOPER_01 TO GDBBATCH
go
