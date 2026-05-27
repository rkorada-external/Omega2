USE BEST
go
IF OBJECT_ID('dbo.PtREQJOBPLAN_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtREQJOBPLAN_03
    IF OBJECT_ID('dbo.PtREQJOBPLAN_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtREQJOBPLAN_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtREQJOBPLAN_03 >>>'
END
go
create procedure dbo.PtREQJOBPLAN_03
  (
  @p_reqcod_ct char(1)
 ,@p_date      UUPD_D
 ,@p_annee     smallint
 ,@p_mois      tinyint
 ,@p_version   int
  )
as
/***************************************************
Domaine                 : (ES) Estimation
Base principale         : BEST
Version                 : 1
Auteur                  : T.RIPERT
Date de creation        : 30/09/2010
Description du programme: Sélection date inventaire pour les post omega
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  Florent   25/06/2012 :spot:23390 SOLVENCY II
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
3 abdulwsh 08/09/2015 - Fix for defect #39045 & #36482. Modif - MOD0003
*****************************************************/
declare
  @pstomgend_d    datetime  -- modif 1
 ,@ebspstomgend_d datetime  -- modif 1
 ,@version        char(1)   -- modif 1
 ,@date_jour      datetime
 ,@d_deb          datetime
 ,@d_fin          datetime
 ,@date_retour    varchar(64)  -- modif 1
 ,@mois_s         char(2)
 ,@mois2_s        char(2)
 ,@mois           int
 ,@jour           int
 ,@jour2          int
 ,@annee          int
 ,@Diff_Day       smallint
 ,@periode        varchar(30) -- modif 1

if @p_date is null
 select @date_jour=getdate()
else
 select @date_jour=@p_date

declare @site_cf        varchar(10),
        @erreur         int
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

-- pour le mois de février
select @annee=datepart(year,@date_jour)
select @d_deb=convert(Char(4),@annee) + '01' + '01'
select @d_fin=convert(Char(4),@annee+1) + '01' + '01'
select @Diff_Day=datediff(day,@d_deb,@d_fin) - 365

-- on prend la date pstomgend_d pour les demandes F
if @p_reqcod_ct='F'
begin
  if @p_version=null
    select @p_version=0

  -- Récupérer les dates cedend_d et pstomgend_d
  select @pstomgend_d=min(case when @p_version=0 then a.pstomgend_d else a.ebspstomgend_d end)
   from bref..tcalend a, bcta..tblcshtd b
    where a.BLCSHTYEA_NF=b.BLCSHTYEA_NF
      and a.BLCSHTMTH_NF=b.BLCSHTMTH_NF
      and b.DMN_CF=1
      and a.CLOSING_B=1
      and case when @p_version=0 then a.pstomgend_d else a.ebspstomgend_d end >= @date_jour --MOD0003

  select @annee=blcshtyea_nf, @mois=blcshtmth_nf
   from bref..tcalend
    where case when @p_version=0 then pstomgend_d else ebspstomgend_d end=@pstomgend_d
      and CLOSING_B=1

  select @jour=(case when @mois IN(1,3,5,7,8,10,12) then 31
                     when @mois IN(4,6,9,11) then 30
                     when @mois IN(2) then 28+@Diff_Day else 0 end)
  select @mois_s=(case when @mois IN(1,2,3,5,7,8,9) then '0'+convert(char(1),@mois)
                       else convert(char(2), @mois) end)
  -- Retour date
  select @date_retour=convert(char(2),@jour) + '/' + @mois_s + '/' + convert(char(4),@annee) + ';' + convert(char(10),@pstomgend_d,103)
end

if @p_reqcod_ct='T'
begin
  -- trouve une ligne dans tcalend où date planifiée > account_d et inferieur ou egal à pstomega_d ?
  select @annee=0, @mois=0

  select @annee=BLCSHTYEA_NF,@mois=BLCSHTMTH_NF,@pstomgend_d=PSTOMGEND_D,@ebspstomgend_d=EBSPSTOMGEND_D  -- modif 1
   from bref..tcalend
    where account_d < @date_jour and pstomgend_d >= @date_jour and closing_b=1
  order by BLCSHTYEA_NF asc,BLCSHTMTH_NF asc
--  select @periode='POST OMEGA SOCIAL IFRS'  -- modif 1

  -- modif 1
  if @annee=0 or @mois=0
  begin
    select @annee=BLCSHTYEA_NF,@mois=BLCSHTMTH_NF,@pstomgend_d=PSTOMGEND_D,@ebspstomgend_d=EBSPSTOMGEND_D  -- modif 1
     from bref..tcalend
      where pstomgend_d < @date_jour and ebspstomgend_d >= @date_jour and closing_b=1
    order by BLCSHTYEA_NF asc,BLCSHTMTH_NF asc
--    select @periode='POST OMEGA SOCIAL EBS'
  end
  -- modif 1 fin

  if @annee=0 or @mois=0
  begin
    select top 1 @annee=blcshtyea_nf,@mois=blcshtmth_nf,@pstomgend_d=PSTOMGEND_D,@ebspstomgend_d=EBSPSTOMGEND_D  -- modif 1
     from bref..tcalend
      where account_d < @date_jour and closing_b=1
     order by BLCSHTYEA_NF desc, BLCSHTMTH_NF desc
--     select @periode='POST OMEGA CONSO IFRS & EBS'  -- modif 1
  end
  select @jour=case when @mois IN(1,3,5,7,8,10,12) then 31
                     when @mois IN(4,6,9,11) then 30
                     when @mois IN(2) then 28 + @Diff_Day else 0 end
  select @mois2_s=case when @mois IN(1,2,3,5,6,7,8,9) then '0' + convert(char(1), @mois)
                          else convert(char(2), @mois) end
  -- modif 1
  if @p_version=null -- si la valeur qui vient de l'application n'a pas été mise à jour par l'utilisateur
    select @version=convert(char(1),max(vrs_nf)) from BEST..TREQJOBPLAN where reqcod_ct=@p_reqcod_ct and BALSHEYEA_NF=@annee and BALSHTMTH_NF=@mois and SITE_CF=@site_cf
  else
    select @version=convert(char(1),@p_version)

  if @date_jour <= @pstomgend_d
  begin
    if @version=null
      select @version='0'

    if @version='0'
      select @periode='POST OMEGA SOCIAL IFRS'
    else
      select @periode='POST OMEGA SOCIAL EBS'
  end

  if @pstomgend_d < @date_jour and @date_jour <= @ebspstomgend_d
  begin
    if @version=null
      select @version='1'

    if @version='0'
      select @periode='POST OMEGA CONSO IFRS'
    else
      select @periode='POST OMEGA SOCIAL EBS'
  end

  if @ebspstomgend_d < @date_jour
  begin
    if @version=null
      select @version='0'

    if @version='0'
      select @periode='POST OMEGA CONSO IFRS'
    else
      select @periode='POST OMEGA CONSO EBS'
  end
  if @periode=null select @version='1',@periode='POST OMEGA CONSO EBS'
  select @date_retour=@version+';'+@periode+';'+convert(char(2),@jour)+'//'+@mois2_s+'//'+convert(char(4),@annee)
end

-- modif 1
if @p_reqcod_ct in ('D','E')
begin
  select @version=convert(char(1),max(vrs_nf)) from TREQJOBPLAN where reqcod_ct=@p_reqcod_ct and BALSHEYEA_NF=@p_annee and BALSHTMTH_NF=@p_mois and DBCLO_D <= @p_date and SITE_CF=@site_cf
  select @date_retour=isnull(@version,'0')
end

select @date_retour
return 0
go
EXEC sp_procxmode 'dbo.PtREQJOBPLAN_03', 'unchained'
go
IF OBJECT_ID('dbo.PtREQJOBPLAN_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtREQJOBPLAN_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtREQJOBPLAN_03 >>>'
go
GRANT EXECUTE ON dbo.PtREQJOBPLAN_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtREQJOBPLAN_03 TO GDBBATCH
go
