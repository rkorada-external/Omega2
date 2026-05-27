USE BEST
go
/*==============================================================*/
/* DBMS name:      Sybase AS Enterprise 15.7                    */
/* Created on:     18/04/2019 15:02:58                          */
/*==============================================================*/


alter table TI17PERMFIL
   add constraint FK_FNCT_PERM foreign key (IDF_CT)
      references TI17FNC (IDF_CT)
go

alter table TI17REQCHN
   add constraint FK_CHAIN_REQST_CHAIN foreign key (CHAIN_CT)
      references TI17CHN (CHAIN_CT)
go

alter table TI17REQCHN
   add constraint FK_FNCT_REQST_CHAIN foreign key (IDF_CT)
      references TI17FNC (IDF_CT)
go

alter table TI17REQCHN
   add constraint FK_REQST_REQST_CHAI foreign key (REQCOD_CT)
      references TI17REQ (REQCOD_CT)
go

alter table dbo.TI17REQJOB
   add constraint FK_REQST_REQJOB_IFRS17 foreign key (REQCOD_CT)
      references TI17REQ (REQCOD_CT)
go

alter table dbo.TI17REQJOBPLAN
   add constraint FK_REQST_REQJOBPLAN_IFRS17 foreign key (REQCOD_CT)
      references TI17REQ (REQCOD_CT)
go

