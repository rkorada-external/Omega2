USE BSAR
go
set nocount on
go


setuser 'dbo'
go

if not exists (select name from systypes where name='UGAAPCOD_NT')
begin

	exec sp_addtype 'UGAAPCOD_NT', 'numeric(18, 0)', 'null'
end
go



--25/03/2020 NLD :spira:83103 -- in BSAR.dbo.TTECLEDA_[*], rename NEWCOLS2_NF to GAAPCOD_NT having numeric(18, 0) as new datatype

declare
 @erreur     int
,@LETTRE     char(1)
,@CIBLE 	 char(1)
,@maj        datetime


select @CIBLE='T' -- si traiter table par table, modifie la cible ici et garder la condition if @LETTRE in(@CIBLE) en bas
select @LETTRE='A' -- point de départ, ne pas changer

print 'Script de mise a jour TTECLEDA.GAAPCODE_NT'


while @LETTRE <= 'T' -- point de fin boucle, ne pas changer
begin 
  -- si on veux traiter plusieurs table, prendre la ligne IF avec l'ensemble de suffixes comme un exemple suivant	
  -- if @LETTRE in(@CIBLE)  -- condition  quelle table devrait etre traitée
  -- if @LETTRE in('A','B','C','D','E','F','H','P','T') -- La table 'S' n'est pas dans la cible
  if @LETTRE in('H','P','T')
  and not exists(select 1 from syscolumns col, sysobjects obj where col.name='UGAAPCOD_NT' and obj.name = 'TTECLEDA_'+@LETTRE and col.id = obj.id)
  begin
    select @maj=getdate()

    print '**** Debut alter table TTECLEDA_%1! à %2!', @LETTRE,@maj

    exec('alter table TTECLEDA_'+@LETTRE+ ' modify NEWCOLS2_NF UGAAPCOD_NT null')

    print 'Alter table TTECLEDA_%1!, lignes %2!',@LETTRE,@@rowcount

    exec('sp_rename "TTECLEDA_'+@LETTRE+'.NEWCOLS2_NF", "GAAPCOD_NT"')

    print 'exec sp_rename TTECLEDA_%1!,  lignes %2!',@LETTRE,@@rowcount

    select @maj=getdate()
    print '**** Fin alter table TTECLEDA_%1! à %2!', @LETTRE, @maj
  end
  else
    print '!!!!! Pas de traitmement pour la table TTECLEDA_%1!',@LETTRE


  select @LETTRE=char(ascii(@LETTRE)+1)
end
go
 
