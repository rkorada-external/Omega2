use BSTA
go
/*
 * DROP PROC dbo.PtBALAGEE_04
 */
IF OBJECT_ID('dbo.PtBALAGEE_04') IS NOT NULL
BEGIN
    DROP PROC dbo.PtBALAGEE_04
    PRINT '<<< DROPPED PROC dbo.PtBALAGEE_04 >>>'
END
go

-- creation de la procedure

create procedure PtBALAGEE_04
     (
	@p_DATE_T	    datetime,   --closing date
  @p_listssd		char(40)  	-- liste des filiales a prendre en compte ou 99 pour toutes les filiales
     )
as

/***************************************************

Programme: PtBALAGEE_04

Fichierscript associé : BALAGEE4.prc

Base principale : BSTA

Version: 1

Auteur: van de velde

Date de creation: 30/11/98

Description du programme:

control ageing balance exist
Parametres:
		@p_DATE_T        datetime


Conditions d'execution:

Batch asynchrone

Commentaires:
_____________________________________________________
MODIFICATION
Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/02/2006  |la date de cloture arrive directement par le paramétre @p_DATE_T, plus de calcul sur la date
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 29/03/2006  |ajout du paramètre filiale pour le controle de l'existance de la balance agée
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/03/2008  |spot15036: Prise en compte de la nouvelle colonne LOCAL_CF pour le traitement de la nouvelle balance agée

*****************************************************/
/*----------------*/
/* Initialization */
/*----------------*/
declare
		@erreur		  int,
    @tran_imbr	bit,
		@clodat 		char(08),
		@mth_nf		  tinyint,
		@yea_nf		  smallint,
		@datarret		datetime,
		@RetourProc	char(1),			--balance agee = 0 already exist; = 1 not exist
		@mth 			  tinyint,
    @Ret_Proc	  int

select  @erreur = 0
select  @tran_imbr = 1
select  @RetourProc = '0'

--modif 0001
  -- Creation de table temporaire
	-- **************************
CREATE TABLE #TLSTSSD ( SSD_CF 		USSD_CF 	NOT NULL )

exec @Ret_Proc=BREF..PtUTILSTSSD_01 @p_listssd

if @@error<>0 or @Ret_Proc<>0
begin
select @RetourProc = '2'
goto fin
end
-- les filiales sont maintenant dans #TLSTSSD

select  @clodat  = convert(char(8),@p_date_t,112)     -- modif 0001

/*** --- modif 0001
--********************
-- treatment of DATE_T
--********************

select @mth_nf 	= datepart(mm,@p_date_t)	--selected month of DATE_T
select @yea_nf 	= datepart(yy,@p_date_t)	--selected year of DATE_T
select @mth_nf 	= @mth_nf -1
IF @mth_nf = 0
   Begin
   select @mth_nf 	= 12
   select @yea_nf 	= @yea_nf - 1
   end

--************************
-- update the closing date
--************************
IF ( @mth_nf = 12)

begin
	select @mth=1
	select @clodat = dateadd(dd,-1,convert(datetime,convert(char(8),
			(@yea_nf+1)*10000+@mth*100+01,102)))
end

else
	select @clodat = dateadd(dd,-1,convert(datetime,convert(char(8),
			@yea_nf*10000+(@mth_nf+1)*100+01,102)))
 fin de modif 001 **/


--******************************
-- control ageing balance exist
--******************************

IF  not exists (select 1 from BSTA..TDEBCRED tdebcred
          		where  @clodat = convert(char(8), CLODATE_D,112)
                      and tdebcred.tra_nf !=0  -- balance agée
                      and tdebcred.SSD_CF in ( SELECT  SSD_CF FROM #TLSTSSD )		-- sélection des filiales paramétrées
                      and tdebcred.LOCAL_CF = '0' ) -- [15036] Balance agée référencé avec date bilan

  select @RetourProc = '0'	-- ageing balance not exist
ELSE
  select @RetourProc = '1'	-- ageing balance already exist


SELECT @erreur = @@error
   IF @erreur != 0
   BEGIN
   raiserror 20010 "ERROR IN THE REQUEST"
   goto fin
   END

fin:

select @RetourProc

RETURN
go

IF OBJECT_ID('dbo.PtBALAGEE_04') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtBALAGEE_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtBALAGEE_04 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PtBALAGEE_04
 */
GRANT EXECUTE ON dbo.PtBALAGEE_04  TO GOMEGA
go
