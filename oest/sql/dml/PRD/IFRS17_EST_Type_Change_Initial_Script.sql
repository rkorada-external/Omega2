declare
  @erreur      int,
  @p_erreur       varchar(64),
  @ano int
  
PRINT 'UPDATE PROCESS STARTED'  
  
EXECUTE @erreur=Best..PsEST_IFRS17_01_O2 @ano output

if @erreur!=0
begin
  select @p_erreur = "  ERROR IN EXECUTION OF Best..PsEST_IFRS17_01_O2" + convert(varchar(10),@erreur) + ";"
 goto fin
end

if @erreur=0
begin
  select @p_erreur = "EXECUTION OF Best..PsEST_IFRS17_01_O2 COMPLETED;"
  
  IF(@ano=0 or @ano is null)
  Begin
  
  GOTO OK
 END
end
GOTO FIN
OK:
select @p_erreur
Print 'DATABASE  UPDATED'
return
fin: 
select @p_erreur
Print 'DATABASE NOT UPDATED'
