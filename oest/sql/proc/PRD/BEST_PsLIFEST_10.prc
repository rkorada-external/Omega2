use BEST
go
if object_id('dbo.PsLIFEST_10') IS NOT null
begin
  drop procedure dbo.PsLIFEST_10
  if object_id('dbo.PsLIFEST_10') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PsLIFEST_10 >>>'
  else
    print '<<< DROPPED procedure dbo.PsLIFEST_10 >>>'
end
go
create procedure PsLIFEST_10
(
  @p_CTR_NF       UCTR_NF
 ,@p_UWY_NF       UUWY_NF
 ,@p_SEC_NF       USEC_NF
 ,@p_ACY_NF       smallint
 ,@p_BALSHEY_NF   smallint
 ,@p_BALSHTMTH_NF tinyint
 ,@p_ACMTRS_NT    smallint
)
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Version: 1
Auteur: Florent
Date de creation: 15/11/2004
Description du programme: Sélection du dernier montant pour les paramètres, pour le calcul de la libération sur la fenêtre
                           w_reponse_seuil_lifmod
Conditions d'execution: Exec uniquement de w_reponse_seuil_lifmod.wf_newpos()
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
1  Florent         28/01/2010 :spot:17244 debug recherche des derniers montants pour calcul positions
*****************************************************/
select ESTMNT_M
 from TLIFEST a
  where a.acmtrs_nt=@p_ACMTRS_NT
    and a.ctr_nf=@p_CTR_NF
    and a.sec_nf=@p_SEC_NF
    and a.acy_nf=@p_ACY_NF
    and a.balshey_nf=@p_BALSHEY_NF
    and a.PRS_CF=500
    and a.BALSHTMTH_NF<=@p_BALSHTMTH_NF
    -- modif 5
    and a.BALSHTMTH_NF=(select max(m.BALSHTMTH_NF) from TLIFEST m
                         where m.ACY_NF=a.ACY_NF
                           and m.CTR_NF=a.CTR_NF
                           and m.UWY_NF=a.UWY_NF  -- modif 6
                           and m.SEC_NF=a.SEC_NF
                           and m.BALSHEY_NF=a.BALSHEY_NF
                           and m.BALSHTMTH_NF<=@p_BALSHTMTH_NF
                           and m.PRS_CF=a.PRS_CF
                           and m.ACMTRS_NT=a.ACMTRS_NT)
    and a.CRE_D=(select max(b.CRE_D) from TLIFEST b
                  where b.CTR_NF=a.CTR_NF
                    and b.UWY_NF=a.UWY_NF
                    and b.SEC_NF=a.SEC_NF
                    and b.ACY_NF=a.ACY_NF
                    and b.BALSHEY_NF=a.BALSHEY_NF
                    and b.BALSHTMTH_NF=a.BALSHTMTH_NF
                    and b.PRS_CF=a.PRS_CF
                    and b.ACMTRS_NT=a.ACMTRS_NT)
go
if object_id('dbo.PsLIFEST_10') IS NOT null
    print '<<< CREATED procedure dbo.PsLIFEST_10 >>>'
else
    print '<<< FAILED CREATING procedure dbo.PsLIFEST_10 >>>'
go
grant execute on dbo.PsLIFEST_10 TO GOMEGA
go
