USE BEST
go
IF OBJECT_ID('PsTI17CLOPER_03') IS NOT NULL
BEGIN
  DROP PROC PsTI17CLOPER_03
  PRINT '<<< DROPPED PROC PsTI17CLOPER_03 >>>'
END
go
create procedure PsTI17CLOPER_03(
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
Date de creation: 08/11/2023
Description du programme: 	
	- Check if Ledger is eligible to Norme
Conditions d'execution: 
Commentaires:
_________________
[01] - S.Behague :spira:110524 - SAS AE import- Check the input data is linked to the right quarter
[02] - S.Behague :spira:110827 - SAS AE import - Loading on a ledger not authorized to I7L or I17P is not blocked
*****************************************************/
declare   @erreur       int,
          @tran_imbr    bit,
          @is_ok                      int
select @erreur=0, @tran_imbr=1

if @@trancount = 0
begin
  select @tran_imbr = 0
  BEGIN TRAN
end

if (@p_NORME = 'I17P' )
begin
	SELECT @is_ok = convert(int,parm1) FROM BEST..TI17CLOPER where ssd_cf = @p_ssd_cf and esb_cf = @p_esb_cf
	select @erreur = @@error
	if @erreur != 0  goto fin
end
if (@p_NORME = 'I17L' )
begin
	SELECT @is_ok =  convert(int,parm2) FROM BEST..TI17CLOPER where ssd_cf = @p_ssd_cf and esb_cf = @p_esb_cf
	select @erreur = @@error
	if @erreur != 0  goto fin
end
if (@p_NORME = 'I17G' )
begin
	IF EXISTS (SELECT SSD_CF FROM BEST..TI17CLOPER WHERE SSD_CF = @p_ssd_cf AND ESB_CF = @p_esb_cf)
	BEGIN select @is_ok = 1
	END
	ELSE
	BEGIN select @is_ok = 0
	END
	select @erreur = @@error
	if @erreur != 0  goto fin
end

if (@is_ok <> 1 )
begin
	select "result", @is_ok
end
else
begin
	select "result", @is_ok
end

/**********************************************************************************/
if @tran_imbr = 0
   COMMIT TRAN
return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN
return 1
go
EXEC sp_procxmode 'dbo.PsTI17CLOPER_03', 'unchained'
go
IF OBJECT_ID('dbo.PsTI17CLOPER_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTI17CLOPER_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTI17CLOPER_03 >>>'
go
GRANT EXECUTE ON dbo.PsTI17CLOPER_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTI17CLOPER_03 TO GDBBATCH
go
