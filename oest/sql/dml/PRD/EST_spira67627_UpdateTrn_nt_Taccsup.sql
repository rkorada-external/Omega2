USE BEST
go

/* Spira:67627  -  Data correction related to bug 67627: duplicated AE id 
Le problème vient du fait que 2 saisies ont été faites à la même seconde sur 2 filiales différentes.
Le dernier cas produit date du 15/03/2016.
Si on veut corriger, on peut affecter un autre numéro de trn_nt qui n'est pas affecté : au lieu de 12078462, on peut lui affecter 12078461.
*/

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Debut  '+convert(char(9),getdate(),6)+' '+ convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
go

print '--> Before update'
select * from best..taccsup
where trn_nt in (12078462,12078461)

print 'update trn_nt to 12078461 for ctr 17ZF09270'
update best..taccsup
   set trn_nt = 12078461
--select * from best..taccsup
where trn_nt in (12078462)
and ctr_nf = '17ZF09270'

print '--> After update'
select * from best..taccsup
where trn_nt in (12078462,12078461)
go

declare @msg varchar(200)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '+convert(char(9),getdate(),6)+' '+convert(char(8),getdate(),8)
+ substring(convert(char(27),getdate(),109),21,4)
print @msg
go
