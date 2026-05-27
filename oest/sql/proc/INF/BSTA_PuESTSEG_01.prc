use BSTA
go
if object_id('dbo.PuESTSEG_01') is not null
begin
  drop PROC dbo.PuESTSEG_01
  print '<<< DROPPED PROC dbo.PuESTSEG_01 >>>'
end
go
create procedure PuESTSEG_01
  (
  @ssd_cf    integer
 ,@segtyp_ct char(1) --type de segment (A ou E ou S)
  )
as
/********************************************************************************
Domaine : (ES) Estimation
Base principale : BSAR
Description : on met les deux derniers caracteres du champ SEG_NF = numero de filiale.
              Dans les 3 progs C du ESED0401 on a verifie que la longueur ne dépassait pas 8 caracteres.
              Pour toutes les filiales sauf New-York.
Conditions d'execution : Valeurs de retour 0:  OK -1: Echec
Commentaires :
_________________
MODIFICATIONS
1 Yves B     21/06/1999 Création
2  Florent   14/02/2012 :spot:23390 SOLVENCY II
3  Florent   15/11/2012 :spot:24041 le libellé du segment S doit être le même que le libellé du segment A s'il existe
4  Florent   01/06/2015 :spot:28694 Segmentation VIE
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
--    return 0  -- on sort pas d'update
begin
  if @segtyp_ct!='S'
  begin
    update BSAR..TCTRGRO
     set SEG_NF = rtrim(SEG_NF) + replicate (' ', 8-datalength(convert(varchar, SEG_NF))) + @ssdlib_cf
      from BSAR..TCTRGRO
       where SSD_CF = @ssd_cf
         and SEGTYP_CT = @segtyp_ct
    if @@error!=0 goto ERREUR

    update BSAR..TLABOCY
    set SEG_NF = rtrim(SEG_NF) + replicate (' ', 8-datalength(convert(varchar, SEG_NF))) + @ssdlib_cf
     from BSAR..TLABOCY
      where SSD_CF = @ssd_cf
        and SEGTYP_CT = @segtyp_ct
    if @@error!=0 goto ERREUR
  end

  update BSAR..TSEGEST
   set SEG_NF = rtrim(SEG_NF) + replicate (' ', 8-datalength(convert(varchar, SEG_NF))) + @ssdlib_cf
    from BSAR..TSEGEST
     where SSD_CF = @ssd_cf
       and SEGTYP_CT = @segtyp_ct
  if @@error!=0 goto ERREUR

  -- modif 3 le libellé du segment S doit être le même que le libellé du segment A s'il existe
  if @segtyp_ct='S'
  begin
    update BSAR..TSEGEST
     set SEG_LL = a.SEG_LL
      from BSAR..TSEGEST s, BSAR..TSEGEST a
       where s.SSD_CF = @ssd_cf
         and s.SEGTYP_CT = @segtyp_ct
         and a.SSD_CF = @ssd_cf
         and a.SSD_CF = s.SSD_CF
         and a.SEGTYP_CT = 'A'
         and a.SEG_NF=s.SEG_NF
         and a.UWY_NF*10000+a.ACY_NF=(select max(UWY_NF*10000+ACY_NF) from BSAR..TSEGEST x where x.SSD_CF=a.SSD_CF and x.SEGTYP_CT=a.SEGTYP_CT and x.SEG_NF=a.SEG_NF)
         and s.SEG_LL!=a.SEG_LL
    if @@error!=0 goto ERREUR
  end
end

-- on insert dans TBOSEGMT les libelles des segments sans notion d'UWY
-- modif 2 - on s'assure de toujours sélectionner les type de segment A et S qui correspondent à un type A dans BSAR..TBOSEGMT
insert BSAR..TBOSEGMT (SSD_CF,SEGTYP_CT,SEG_NF,SEG_LL)
select distinct A.SSD_CF,case when A.SEGTYP_CT='S' then 'A' else A.SEGTYP_CT end,A.SEG_NF,A.SEG_LL
 from BSAR..TSEGEST A
  where A.SSD_CF=@ssd_cf
    and A.SEGTYP_CT in(@segtyp_ct,@segtyp_bo)
    and UWY_NF*10000+ACY_NF=(select max(UWY_NF*10000+ACY_NF) from BSAR..TSEGEST B where A.SSD_CF=B.SSD_CF and B.SEGTYP_CT in(@segtyp_ct,@segtyp_bo) and A.SEG_NF=B.SEG_NF)
if @@error!=0 goto ERREUR

commit TRANSACTION
return 0

ERREUR:
rollback TRANSACTION
return -1
go
if object_id('dbo.PuESTSEG_01') is not null
  print '<<< CREATED PROC dbo.PuESTSEG_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuESTSEG_01 >>>'
go
grant execute on dbo.PuESTSEG_01 TO GOMEGA, GDBBATCH
go
