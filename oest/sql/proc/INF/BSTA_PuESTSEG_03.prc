use BSTA
go
if object_id('dbo.PuESTSEG_03') is not null
begin
  drop PROC dbo.PuESTSEG_03
  print '<<< DROPPED PROC dbo.PuESTSEG_03 >>>'
end
go
create procedure PuESTSEG_03
  (
  @ssd_cf    integer
 ,@segtyp_ct char(1)  --type de segment (A ou E ou S)
  )
as
/********************************************************************************
Domaine : (ES) Estimation
Base principale : BSAR
Description :       Calqué sur BSTA_PuESTSEG_01.prc Pour ESED0421.cmd

Conditions d'execution : Valeurs de retour 0:  OK -1: Echec
Commentaires :
_________________
MODIFICATIONS
1 M. DJELLOULI - 07/10/2004 - Création
2  Florent   14/02/2012 :spot:23390 SOLVENCY II
3  Florent   01/06/2015 :spot:28694 Segmentation VIE
********************************************************************************/
declare
  @ssdlib_cf char(2)
 ,@segtyp_bo USEGTYP_CT     -- modif 2

if @segtyp_ct='S'
  select @segtyp_bo='A'
else
  if @segtyp_ct='A'
    select @segtyp_bo='S'
  else
    select @segtyp_bo=@segtyp_ct

-- on convertit ssd_cf en varchar, on met 0 devant si filiale < 10
select @ssdlib_cf = replicate ('0', 2 - datalength ( convert (varchar, @ssd_cf))) + convert (varchar, @ssd_cf)

-- on update dans BSAR : TCTRGRO, TSEGEST et TLABOCY
-- on rajoute le numéro de filiale (02 ou 12) dans le champ SEG_NF
-- SEG_NF : char(10)
-- on a bien verifié que seg_nf avait au plus 8 caracteres (premiers step du ESED0401)
-- Cela ne se fait pas pour New-York (ssd_ cf = 10)
begin TRANSACTION

if @ssd_cf!=10
--    return 0     -- on sort pas d update
begin
  update BSAR..TSEGEST
   set SEG_NF = rtrim(SEG_NF)+ replicate (' ', 8-datalength(convert(varchar, SEG_NF)))+ @ssdlib_cf
    from BSAR..TSEGEST
     where SSD_CF = @ssd_cf
       and SEGTYP_CT = @segtyp_ct
       and datalength(convert(varchar, SEG_NF)) < 9
  if @@error!=0 goto ERREUR
end

-- on insert dans TBOSEGMT les libelles des segments sans notion d'UWY
-- modif 2 - on s'assure de toujours sélectionner les type de segment A et S qui correspondent à un type A dans BSAR..TBOSEGMT
insert BSAR..TBOSEGMT (SSD_CF,SEGTYP_CT,SEG_NF,SEG_LL)
select distinct A.SSD_CF,case when A.SEGTYP_CT='S' then 'A' else A.SEGTYP_CT end,A.SEG_NF,A.SEG_LL
 from BSAR..TSEGEST A
  where A.SSD_CF=@ssd_cf
    and A.SEGTYP_CT in(@segtyp_ct,@segtyp_bo)
    and UWY_NF*10000+ACY_NF=(select max(UWY_NF*10000+ACY_NF) from BSAR..TSEGEST B where A.SSD_CF=B.SSD_CF and A.SSD_CF=@ssd_cf and A.SEGTYP_CT in(@segtyp_ct,@segtyp_bo) and A.SEG_NF=B.SEG_NF)
if @@error!=0 goto ERREUR

commit TRANSACTION
return 0

ERREUR:
rollback TRANSACTION
return -1
go
if object_id('dbo.PuESTSEG_03') is not null
  print '<<< CREATED PROC dbo.PuESTSEG_03 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuESTSEG_03 >>>'
go
grant execute on dbo.PuESTSEG_03 TO GOMEGA, GDBBATCH
go
