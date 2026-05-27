use BEST
go
if object_id('dbo.PsTI17PRODUCT_02') is not null
begin
  drop PROC dbo.PsTI17PRODUCT_02
  print '<<< DROPPED PROC dbo.PsTI17PRODUCT_02 >>>'
end
go

create procedure dbo.PsTI17PRODUCT_02
(
   @site         varchar(5)
)
with execute as caller as 


/**************************************************************************************************
Programme                : PsTI17PRODUCT_02
Fichier script associé   : BEST_PsTI17PRODUCT_02.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Auteur                   : JYP - PERSEE 
Date de creation         : 25/01/2022
Description du programme : Extraction table TI17PRODUCT by site
                      
_____________________________________________________
[001] 25/01/2022 JYP  :SPIRA 101782: création
[002] 08/06/2022 JYP  :SPIRA 104771: defaulting product codes
************************************************************************************************/


SELECT * FROM BEST..TI17PRODUCT 
WHERE BCHUSR_CF = @site

GO

if object_id('dbo.PsTI17PRODUCT_02') is not null
  print '<<< CREATED PROC dbo.PsTI17PRODUCT_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsTI17PRODUCT_02 >>>'
go
grant execute on dbo.PsTI17PRODUCT_02 TO GOMEGA
go
grant execute on dbo.PsTI17PRODUCT_02 TO GDBBATCH
go



	 