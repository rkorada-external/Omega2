-- SPIRA 75813
-- Script to add new column in table BEST..TI17REQJOBPLAN 

USE BEST
go

IF EXISTS( select 1 from syscolumns
       where id = object_id('TI17REQJOBPLAN')
         and name = 'CMT_NT')
BEGIN
exec(" ALTER TABLE TI17REQJOBPLAN
  DROP CMT_NT ")
END
go


ALTER TABLE BEST..TI17REQJOBPLAN
ADD CMT_NT UCMT_NT NULL
go