use BEST
go
if object_id('dbo.PuLIFMOD_03') IS NOT null
begin
  drop procedure dbo.PuLIFMOD_03
  if object_id('dbo.PuLIFMOD_03') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PuLIFMOD_03 >>>'
  else
    print '<<< DROPPED procedure dbo.PuLIFMOD_03 >>>'
end
go
create procedure PuLIFMOD_03
  (
   @p_CRE_D        datetime
  ,@p_BALSHEY_NF   smallint
  ,@p_BALSHTMTH_NF tinyint
  )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: S.Behague
Date de creation: 04/01/2016
Description du programme: estimation Vie, suivi dépassement du seuil
Commentaires: Mise à jour du flag DISPLAY_B si CRE_D inférieure à SPECEND_D pour BALSHYEA et BALSHMTH
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@lignes    int
 ,@retour    int
 ,@specend   datetime
 
select @erreur = 0, @tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end


SELECT @specend=SPECEND_D FROM BREF..TCALEND WHERE BLCSHTYEA_NF = @p_BALSHEY_NF AND BLCSHTMTH_NF =  @p_BALSHTMTH_NF

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#ESID1530_TLIFMOD"
        return @erreur
        goto fin
    end

UPDATE BEST..TLIFMOD SET DISPLAY_B = 1 
FROM BEST..TLIFMOD LIF , BREF..TBATCHSSD T
WHERE T.BATCHUSER_CF = suser_name()
AND     T.SSD_CF = LIF.SSD_CF
AND     LIF.DISPLAY_B = 0
AND     LIF.SSD_CF = T.SSD_CF
AND     LIF.CRE_D < @specend

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#ESID1530_TLIFMOD"
        return @erreur
        goto fin
    end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PuLIFMOD_03') IS NOT null
  print '<<< CREATED procedure dbo.PuLIFMOD_03 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PuLIFMOD_03 >>>'
go
grant execute on dbo.PuLIFMOD_03 TO GOMEGA
go
grant execute on dbo.PuLIFMOD_03 TO GDBBATCH
go