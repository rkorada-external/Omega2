USE BEST
go

/*
[001] 18/02/2020 RC  :spira:84424 Add column INCURREDCI_M into Best..TCTREST for IBNR process
*/

if NOT exists(select 1 from syscolumns where Id = Object_ID('dbo.TCTREST') and Name = 'INCURREDCI_M')
begin
  ALTER TABLE dbo.TCTREST
    ADD INCURREDCI_M UAMT_M NULL
end

if @@error!=0 select syb_quit()
go
