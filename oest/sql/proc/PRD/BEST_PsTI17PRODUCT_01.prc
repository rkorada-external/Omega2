use BEST
go
if object_id('dbo.PsTI17PRODUCT_01') is not null
begin
  drop PROC dbo.PsTI17PRODUCT_01
  print '<<< DROPPED PROC dbo.PsTI17PRODUCT_01 >>>'
end
go

create procedure dbo.PsTI17PRODUCT_01
(
   @p_norm_cf	 varchar(5),
   @site         varchar(5)
)
with execute as caller as 


/**************************************************************************************************
Programme                : PsTI17PRODUCT_01
Fichier script associé   : BEST_PsTI17PRODUCT_01.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : JYP - PERSEE 
Date de creation         : 02/09/2020
Description du programme : Extraction table TI17PRODUCT by site
                      
_____________________________________________________
[001] 02/09/2020 JYP  :SPIRA 83614: création
[002] 11/09/2020 JYP  :SPIRA 83614: extract by site
************************************************************************************************/


SELECT * FROM BEST..TI17PRODUCT 
WHERE BCHUSR_CF = @site
and
(  
     ( @p_norm_cf = 'I17G' and substring(I17PRDCOD_CT,3,1) = 'G') 
  or ( @p_norm_cf = 'I17L' and substring(I17PRDCOD_CT,3,1) = 'L')
  or ( @p_norm_cf = 'I17P' and substring(I17PRDCOD_CT,3,1) = 'P')
)
  
GO

if object_id('dbo.PsTI17PRODUCT_01') is not null
  print '<<< CREATED PROC dbo.PsTI17PRODUCT_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsTI17PRODUCT_01 >>>'
go
grant execute on dbo.PsTI17PRODUCT_01 TO GOMEGA
go
grant execute on dbo.PsTI17PRODUCT_01 TO GDBBATCH
go



	 