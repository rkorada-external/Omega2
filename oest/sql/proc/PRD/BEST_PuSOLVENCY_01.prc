USE BEST
Go
IF OBJECT_ID('dbo.PuSOLVENCY_01') IS NOT NULL
BEGIN
  DROP PROC dbo.PuSOLVENCY_01
  PRINT '<<< DROPPED PROC dbo.PuSOLVENCY_01 >>>'
END
go
create procedure PuSOLVENCY_01
 (
  @p_clodat_d  datetime
 ,@p_CRE_D datetime
  )
as
/***************************************************
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     P.PEZOUT
Description du programme: :spot:24516
    - Mise a jour de la date de comptabilisation des tables solvency
Parametres:     - @p_CRE_D : la date de traitement
                - @p_clodat_d : libellé d'inventaire
_________________
MODIFICATIONS
[001] 26/03/2013 R. Cassis :spot:25006 Ajout not exists sur les mise a jour
*****************************************************/
declare @erreur int,
        @tran_imbr  bit,
        @account_d datetime

select @erreur=0, @tran_imbr=1

if @@trancount=0
begin
  select @tran_imbr=0
  BEGIN TRAN
end

select @account_d=isnull((select account_d from bref..tcalend
                          where datepart(yy,@p_clodat_d) = blcshtyea_nf
                          and   datepart(mm,@p_clodat_d) = blcshtmth_nf),@p_CRE_D)
                     
update TCURSII
 set CLOSING_D=@p_clodat_d,
    LSTUPDUSR_CF='dbo',
    LSTUPD_D=@p_CRE_D
  from TCURSII a
   where CRE_D=(select max(CRE_D) from TCURSII b
                 where b.CUR_CF=a.CUR_CF
                   and isnull(b.VALEND_D,@p_clodat_d)>=@p_clodat_d and b.CLOSING_D=null
               )
--[001]               
   and   CRE_D<@account_d

select @erreur=@@error
if @erreur != 0
    goto fin

update TLOBSII
 set CLOSING_D=@p_clodat_d
    ,LSTUPDUSR_CF='dbo'
    ,LSTUPD_D=@p_CRE_D
 from TLOBSII a
  where CRE_D=(select max(CRE_D) from TLOBSII b
               where a.LOB_CF=b.LOB_CF and a.SEGNAT_CT=b.SEGNAT_CT and a.NORME_CF=b.NORME_CF
                 and isnull(b.VALEND_D,@p_clodat_d)>=@p_clodat_d and b.CLOSING_D=null
              )
--[001]               
   and   CRE_D<@account_d

select @erreur=@@error
if @erreur != 0
  goto fin

update TRATINGSII
 set CLOSING_D=@p_clodat_d
    ,LSTUPDUSR_CF='dbo'
    ,LSTUPD_D=@p_CRE_D
 from TRATINGSII a
  where CRE_D=(select max(CRE_D) from TRATINGSII b
                where a.RATING_CF=b.RATING_CF and a.NORME_CF=b.NORME_CF
                  and isnull(b.VALEND_D,@p_clodat_d)>=@p_clodat_d and b.CLOSING_D=null
              )
--[001]               
   and   CRE_D<@account_d

select @erreur=@@error
if @erreur != 0
    goto fin

if @tran_imbr=0
  COMMIT TRAN
return 0

fin:
if @tran_imbr=0
  ROLLBACK TRAN
return @erreur
go
IF OBJECT_ID('dbo.PuSOLVENCY_01') IS NOT NULL
  PRINT '<<< CREATED PROC dbo.PuSOLVENCY_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROC dbo.PuSOLVENCY_01 >>>'
go
GRANT EXECUTE ON dbo.PuSOLVENCY_01 TO GOMEGA
go
