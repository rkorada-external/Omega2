use BSTA
go
-- DROP PROC dbo.PtBALAGEE_14

IF OBJECT_ID('dbo.PtBALAGEE_14') IS NOT NULL
BEGIN
    DROP PROC dbo.PtBALAGEE_14
    PRINT '<<< DROPPED PROC dbo.PtBALAGEE_14 >>>'
END
go

-- creation de la procedure

create procedure PtBALAGEE_14
   (
	@p_DATE_T	    datetime,   -- closing date
  @p_listssd		char(40)   	-- liste des filiales à prendre en compte ou 99 pour toutes les filiales
     )
as

/***************************************************

Programme: PtBALAGEE_14
Fichier script associé : bsta_PtBALAGEE_14.prc

Base principale : bsta
Version: 1
Auteur: van de velde
Date de creation: 08/02/2008
Description du programme:  control ageing balance exist  on bsta..TDEBCRED
Parametres:
		@p_DATE_T     datetime ,
    @p_listssd		char(40)

Conditions d'execution:
Batch asynchrone
Commentaires:
__________________
MODIFICATIONS

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/03/2008  |spot15036: Prise en compte de la nouvelle colonne LOCAL_CF pour le traitement de la nouvelle balance agée
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 27/03/2008  |spot15036: Aménagement du traitement pour une ou plusieurs filiales
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 19/05/2008  |spot15036: suppression des "PRINT"

MODIFICATION 1 : JBG - 22/08/2013 - DATA SELECTION BASED ON SSD CF/SITE ID

*****************************************************/

-- Initialization

declare
		@erreur		   int,
    @tran_imbr	 bit,
		@clodat 		 char(08),
		@mth_nf		   tinyint,
		@yea_nf		   smallint,
		@datarret		 datetime,
		@RetourProc	 char(1),			--balance agee = 0 already exist; = 1 not exist
		@mth 			   tinyint,
    @Ret_Proc	   int,
    @RetourProc1 int,
    @nbre_ssd    int

select  @erreur = 0
select  @tran_imbr = 1
select  @RetourProc = '0'
select  @RetourProc1 = 0
select  @nbre_ssd = 0

select  @clodat  = convert(char(8),@p_date_t,112)

-- Chargement des filiales en table  #TLSTSSD
--==================================

CREATE TABLE #TLSTSSD
             ( SSD_CF 		USSD_CF 	NOT NULL )

exec @RetourProc1 = bref..PtUTILSTSSD_01
                    @p_listssd

if @@error <> 0 or @RetourProc1 <> 0 return

--******************************
-- control ageing balance exist
--******************************

select @nbre_ssd = (select count(*) FROM #TLSTSSD )
If @nbre_ssd = 1
   begin
   --PRINT '-- 1) si une seule filiale demandée - on stoppe le traitement si la BA correspondante existe déjà'
   IF  not exists (select 1 from bsta..TDEBCRED tdebcred
          		where  @clodat = convert(char(8), CLODATE_D,112)
                      and tdebcred.tra_nf !=0  -- balance agée
                      and tdebcred.SSD_CF in (SELECT T1.SSD_CF FROM #TLSTSSD T1, BREF..TBATCHSSD TSSD WHERE T1.SSD_CF = TSSD.SSD_CF AND TSSD.BATCHUSER_CF = suser_name()) 	-- sélection de la filiale paramétrée / MODIFICATION vi 1
                      and tdebcred.LOCAL_CF = '1')    -- [15036] Balance agée référencé avec date du document

      select @RetourProc = '0'	-- ageing balance not exist
   ELSE
      select @RetourProc = '1'	-- ageing balance already exist in bsta...TDEBCRED
  end
ELSE
   begin
  -- PRINT '-- 2) si plusieurs filiales demandées - on stoppe le traitement si présence d''au moins une balance agée'
  IF  not exists (select 1 from bsta..TDEBCRED tdebcred
          		where  @clodat = convert(char(8), CLODATE_D,112)
                      and tdebcred.tra_nf !=0  -- balance agée
                      and tdebcred.SSD_CF in (SELECT  T1.SSD_CF FROM #TLSTSSD T1, BREF..TBATCHSSD TSSD WHERE T1.SSD_CF = TSSD.SSD_CF AND TSSD.BATCHUSER_CF = suser_name()) 	-- sélection des filiales demandées / MODIFICATION 1
                      and tdebcred.LOCAL_CF = '1')    -- [15036] Balance agée référencé avec date du document

      select @RetourProc = '0'	-- ageing balance not exist
   ELSE
      select @RetourProc = '1'	-- ageing balance already exist in bsta...TDEBCRED
   end

fin:
DROP TABLE #TLSTSSD
select @RetourProc

RETURN
go

IF OBJECT_ID('dbo.PtBALAGEE_14') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtBALAGEE_14 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtBALAGEE_14 >>>'
go

--  Granting/Revoking Permissions on dbo.PtBALAGEE_14

GRANT EXECUTE ON dbo.PtBALAGEE_14  TO GOMEGA
go
