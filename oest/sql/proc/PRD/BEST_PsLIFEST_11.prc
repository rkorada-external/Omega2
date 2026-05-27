use BEST
go

if object_id('dbo.PsLIFEST_11') IS NOT null
begin
  drop procedure dbo.PsLIFEST_11
  if object_id('dbo.PsLIFEST_11') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PsLIFEST_11 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLIFEST_11 >>>'
end
go

create procedure PsLIFEST_11
(
  @p_CTR_NF       UCTR_NF
 ,@p_SEC_NF       smallint
 ,@p_ACY_NF       smallint
)
as
/***************************************************
Domaine           : Estimation
Base principale   : BEST
Version           : 1
Auteur            : Tony RIPERT
Date de creation  : 29/07/2010

Description du programme:  Sélection du dernier poste modifié (1900 ou 1901, 2900 ou 2901)

*****************************************************/
DECLARE
   @ldt_cre_d_1900   DATETIME,
   @ldt_cre_d_1901   DATETIME,
   @li_acmtrs_nt     INT,
   @ls_ctr_nf        UCTR_NF

select   @ldt_cre_d_1900 = max(cre_d)
 from    BEST..TLIFEST a
  where a.acmtrs_nt  in(1900,2900)
    and a.ctr_nf     =@p_CTR_NF
    and a.sec_nf     =@p_SEC_NF
    and a.acy_nf     =@p_ACY_NF
    and a.oricod_ls	 <> 'CALC'

select   @ldt_cre_d_1901 = max(cre_d)
 from    BEST..TLIFEST a
  where a.acmtrs_nt  in(1901,2901)
    and a.ctr_nf     =@p_CTR_NF
    and a.sec_nf     =@p_SEC_NF
    and a.acy_nf     =@p_ACY_NF
    and a.oricod_ls	 <> 'CALC'    

-- Test si contrat est retro
SELECT   @ls_ctr_nf = retctr_nf
  FROM   BRET..TRETCTR
 WHERE   RETCTR_NF = @p_CTR_NF

IF @ls_ctr_nf = @p_ctr_nf
-- Contrat retro
   BEGIN
      IF @ldt_cre_d_1900 > @ldt_cre_d_1901 OR (@ldt_cre_d_1901 = null) SELECT @li_acmtrs_nt = 2900
      IF @ldt_cre_d_1901 > @ldt_cre_d_1900 OR (@ldt_cre_d_1900 = null) SELECT @li_acmtrs_nt = 2901
   END
Else
   BEGIN
      IF @ldt_cre_d_1900 > @ldt_cre_d_1901 OR (@ldt_cre_d_1901 = null) SELECT @li_acmtrs_nt = 1900
      IF @ldt_cre_d_1901 > @ldt_cre_d_1900 OR (@ldt_cre_d_1900 = null) SELECT @li_acmtrs_nt = 1901
   END

Select @li_acmtrs_nt
go

if object_id('dbo.PsLIFEST_11') IS NOT null
    print '<<< CREATED procedure dbo.PsLIFEST_11 >>>'
else
    print '<<< FAILED CREATING procedure dbo.PsLIFEST_11 >>>'
go
grant execute on dbo.PsLIFEST_11 TO GOMEGA
go
