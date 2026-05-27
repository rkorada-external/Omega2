use BEST
go

if object_id('dbo.PsACCPAR_03') IS NOT null
begin
  drop procedure dbo.PsACCPAR_03
  if object_id('dbo.PsACCPAR_03') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PsACCPAR_03 >>>'
  else
    print '<<< DROPPED procedure dbo.PsACCPAR_03 >>>'
end
go

create procedure PsACCPAR_03    (
   @p_restec_b    tinyint = 0,
   @p_resdac_b    tinyint = 0,
   @p_resfin_b    tinyint = 0,
   @p_sumrisk_b   tinyint = 0
                                 )
as

/***************************************************

Programme               :  PsACCPAR_03

Fichier script associé  :  PsACCPAR_03.PRC

Domaine                 :  (ES) Estimation

Base principale         :  BEST

Version                 :  1

Auteur                  :  T.RIPERT

Date de creation        :  20/07/2010

Description du programme:

 	ESTIMATIONS VIE Acceptation et Rétro :
	Sélection dans TACCPAR des postes en fonction du flag

Parametres              :
   @p_restec_b    tinyint = 0,
   @p_resdac_b    tinyint = 0,
   @p_resfin_b    tinyint = 0,
   @p_sumrisk_b   tinyint = 0

*****************************************************/

select   ACMTRS_NT
FROM     BEST..TACCPAR
WHERE
(restec_b = @p_restec_b OR @p_restec_b = 0) AND
(resdac_b = @p_resdac_b OR @p_resdac_b = 0) AND
(resfin_b = @p_resfin_b OR @p_resfin_b = 0) AND
(sumrisk_b = @p_sumrisk_b OR @p_sumrisk_b = 0)

return 0
go

if object_id('dbo.PsACCPAR_03') IS NOT null
    print '<<< CREATED procedure dbo.PsACCPAR_03 >>>'
else
    print '<<< FAILED CREATING procedure dbo.PsACCPAR_03 >>>'
go

grant execute on dbo.PsACCPAR_03 TO GOMEGA
go
