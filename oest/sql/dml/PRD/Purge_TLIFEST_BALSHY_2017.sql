use BEST
go

set nocount on
declare @msg varchar(60)
select @msg = @@servername + ' => ' + host_name() + '  Debut  '
+ convert(char(9), getdate(),6) + ' ' + convert(char(8), getdate(),8)
+ substring(convert(char(27), getdate(), 109), 21, 4)
print @msg
go

BEGIN TRAN
	SET flushmessage ON

	DECLARE		@erreur			int,
				@trans_etat		int,
				@enr			int,
				@totenr			int
 
 	select	@enr=1,
	 		@totenr = 0
 	set rowcount 50000
	while @enr != 0
	begin
		DELETE BEST..TLIFEST FROM BEST..TLIFEST a
		WHERE BALSHEY_NF = 2017

 		select	@erreur = @@error,
		 		@enr = @@rowcount,
				@totenr = @totenr + @@rowcount
		if @@transtate > 1 break
		if @erreur != 0 break
		if @enr = 0 break
		COMMIT TRAN
	end
	set rowcount 0

	-- récuperer codes retour --
	SELECT	@erreur = @@error,
			@trans_etat = @@transtate
	IF @erreur != 0 OR @trans_etat > 1
	BEGIN
		PRINT 'DELETE BREF..TLIFEST - ERROR : %1!', @erreur
		ROLLBACK TRAN
		GOTO fin
	END

fin:
go

set nocount on
declare @msg varchar(60)
select @msg=@@servername + ' => ' + host_name() + '  Fin  '
+ convert(char(9),getdate(),6) + ' ' + convert(char(8), getdate(), 8)
+ substring(convert(char(27), getdate(), 109), 21, 4)
print @msg
set nocount off
go
