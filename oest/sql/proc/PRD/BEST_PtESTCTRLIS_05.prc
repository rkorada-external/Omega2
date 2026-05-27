use BEST
go
if object_id('PtESTCTRLIS_05') is not null
begin
  drop PROC PtESTCTRLIS_05
  print '<<< DROPPED PROC PtESTCTRLIS_05 >>>'
end
go
create procedure PtESTCTRLIS_05
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation: 21/11/97
Description du programme: - mise à jour de la PMD.
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1                      Removed dbo and added ‘with execute as caller as’
2 Florent   20/11/2014 :spot:27747 - ajout multi-devise
*****************************************************/
declare @erreur      int

select @erreur = 0
/* ------------------------
   Mise a jour de la PMD
------------------------ */
set arithabort numeric_truncation off

update BTRAV..TESTCTRLIS
set PMDEGPCUR_M = isnull( A.MINPRVPR1_M, 0) * isnull( A.EXCPR1_R, -1 ) / isnull( A.EXCEGP_R, -1 )
        + isnull( A.MINPRVPR2_M, 0) * isnull( A.EXCPR2_R, -1 ) / isnull( A.EXCEGP_R, -1 )
        + isnull( A.MINPRVPR3_M, 0) * isnull( A.EXCPR3_R, -1 ) / isnull( A.EXCEGP_R, -1 )
        + isnull( A.MINPRVPR4_M, 0) * isnull( A.EXCPR4_R, -1 ) / isnull( A.EXCEGP_R, -1 )
        + isnull( A.MINPRVPR5_M, 0) * isnull( A.EXCPR5_R, -1 ) / isnull( A.EXCEGP_R, -1 )
from  BTRAV..TESTPMDCTR A, BTRAV..TESTCTRLIS C
where  A.CTR_NF = C.CTR_NF
  and A.UWY_NF = C.UWY_NF
  and A.UW_NT = C.UW_NT
  and A.END_NT = C.END_NT
  and A.SEC_NF = C.SEC_NF
select @erreur = @@error
if @erreur != 0  goto fin

set arithabort numeric_truncation on


/**********************************************************************************/
return 0

fin:
return 1
go
if object_id('PtESTCTRLIS_05') is not null
  print '<<< CREATED PROC PtESTCTRLIS_05 >>>'
else
  print '<<< FAILED CREATING PROC PtESTCTRLIS_05 >>>'
go
grant execute on PtESTCTRLIS_05 TO GOMEGA
go
grant execute on PtESTCTRLIS_05 TO GDBBATCH
go
