USE BSEG
go

print 'Data selection before udpate'

select * from bseg..tsegrun where sgt_nt in ( 1485, 1486 ) and sgtrunsts_ct = '4'

update bseg..tsegrun
set sgtobsolete_b = 1
where sgt_nt in ( 1485, 1486 ) and sgtrunsts_ct = '4'

select @@rowcount, 'rows updated'

print 'Data selection after udpate'

select * from bseg..tsegrun where sgt_nt in ( 1485, 1486 )

go
