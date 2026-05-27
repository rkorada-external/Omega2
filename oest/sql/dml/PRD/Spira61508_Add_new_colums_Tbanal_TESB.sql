Use Bref
Go


Alter TABLE TBANAL
drop LOCALAE_B 
go

Alter TABLE TESB
drop LOACALAE_B 
go

Alter TABLE TBANAL
Add  LOCALAE_B bit default 0  not null
go

Alter TABLE TESB
Add  LOACALAE_B bit default 0  not null
go