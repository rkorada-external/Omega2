USE BRET
go

set nocount on

-- Add Initial profitability and IFRS17 segments to P&C retro contracts on existing contracts
-- :spira:94938
-- :Modified by : B. Lagha : 15/12/2021

-- ------------------------ --
-- Definition des variables --
-- ------------------------ --
declare @msg varchar(100)

-- ---------------------------- --
-- Initialisation des variables --
-- ---------------------------- --
select @msg=@@servername + ' => ' + host_name()
                         + ' Debut update TRETIFRS   '
                         + convert(char(9), getdate(), 6) + ' '
                         + convert(char(8),getdate(), 8) + ' '
                         + substring(convert(char(27), getdate(),109), 21, 4)
print @msg

set nocount off
GO

BEGIN TRAN
    SET flushmessage ON

    DECLARE @erreur         int
          , @trans_etat     int
          , @spira          char(4)
          , @datejour       datetime
          
    select @spira      = substring('94938',2,4)
          ,@datejour   = getdate()

    update BRET..TRETIFRS
    
     set GRPINIPRO_CF   = (case when a.GRPINIPRO_CF   is null  then '4'            else a.GRPINIPRO_CF   end)
        ,PARINIPRO_CF   = (case when a.PARINIPRO_CF   is null  then '4'            else a.PARINIPRO_CF   end)
        ,LOCINIPRO_CF   = (case when a.LOCINIPRO_CF   is null  then '4'            else a.LOCINIPRO_CF   end)
        ,GRPIFRSSEG_CT  = (case when a.GRPIFRSSEG_CT  is null  then b.RETCTR_NF    else a.GRPIFRSSEG_CT  end)  -- add this for SAP tests **
        ,GRPIFRSTRA_CT  = (case when a.GRPIFRSTRA_CT  is null  then '1'            else a.GRPIFRSTRA_CT  end)  -- add this for SAP tests **
        ,GRPIFRSSEG1_CT = (case when a.GRPIFRSSEG1_CT is null  then b.RETCTR_NF    else a.GRPIFRSSEG1_CT end)  -- numero contrat
        ,PARIFRSSEG_CT  = (case when a.PARIFRSSEG_CT  is null  then b.RETCTR_NF    else a.PARIFRSSEG_CT  end)  -- add this for SAP tests **
        ,PARIFRSTRA_CT  = (case when a.PARIFRSTRA_CT  is null  then '1'            else a.PARIFRSTRA_CT  end)  -- add this for SAP tests **
        ,PARIFRSSEG1_CT = (case when a.PARIFRSSEG1_CT is null  then b.RETCTR_NF    else a.PARIFRSSEG1_CT end)
        ,LOCIFRSSEG_CT  = (case when a.LOCIFRSSEG_CT  is null  then b.RETCTR_NF    else a.LOCIFRSSEG_CT  end)  -- add this for SAP tests **
        ,LOCIFRSTRA_CT  = (case when a.LOCIFRSTRA_CT  is null  then '1'            else a.LOCIFRSTRA_CT  end)  -- add this for SAP tests **
        ,LOCIFRSSEG1_CT = (case when a.LOCIFRSSEG1_CT is null  then b.RETCTR_NF    else a.LOCIFRSSEG1_CT end)
        ,GRPIFRSSEG1_LL = (case when a.GRPIFRSSEG1_LL is null  then b.CTRPCPNAM_LL else a.GRPIFRSSEG1_LL end)  -- libelle contrat
        ,PARIFRSSEG1_LL = (case when a.PARIFRSSEG1_LL is null  then b.CTRPCPNAM_LL else a.PARIFRSSEG1_LL end)
        ,LOCIFRSSEG1_LL = (case when a.LOCIFRSSEG1_LL is null  then b.CTRPCPNAM_LL else a.LOCIFRSSEG1_LL end)
        ,GRPIFRSSEG_LL  = (case when a.GRPIFRSSEG_LL  is null  then b.CTRPCPNAM_LL else a.GRPIFRSSEG_LL  end)  -- add this for SAP tests **
        ,PARIFRSSEG_LL  = (case when a.PARIFRSSEG_LL  is null  then b.CTRPCPNAM_LL else a.PARIFRSSEG_LL  end)  -- add this for SAP tests **
        ,LOCIFRSSEG_LL  = (case when a.LOCIFRSSEG_LL  is null  then b.CTRPCPNAM_LL else a.LOCIFRSSEG_LL  end)  -- add this for SAP tests **
        ,LSTUPD_D	    = @datejour
        ,LSTUPDUSR_CF   = @spira
         
     from BRET..TRETIFRS a, BRET..TRETCTR b, BREF..TESB c
        where a.RETCTR_NF = b.RETCTR_NF
          and a.RTY_NF = b.RTY_NF
          and b.SSD_CF = c.SSD_CF
          and b.ESB_CF = c.ESB_CF
          and c.LIFE_CF = 2 -- P&C
          and (
               a.GRPINIPRO_CF   is null
            or a.PARINIPRO_CF   is null
            or a.LOCINIPRO_CF   is null
            or a.GRPIFRSSEG_CT  is null  -- add this for SAP tests **
            or a.GRPIFRSTRA_CT  is null  -- add this for SAP tests **
            or a.GRPIFRSSEG1_CT is null
            or a.PARIFRSSEG_CT  is null  -- add this for SAP tests **
            or a.PARIFRSTRA_CT  is null  -- add this for SAP tests **
            or a.PARIFRSSEG1_CT is null
            or a.LOCIFRSSEG_CT  is null  -- add this for SAP tests **
            or a.LOCIFRSTRA_CT  is null  -- add this for SAP tests **
            or a.LOCIFRSSEG1_CT is null
            or a.GRPIFRSSEG1_LL is null
            or a.PARIFRSSEG1_LL is null
            or a.LOCIFRSSEG1_LL is null
            or a.GRPIFRSSEG_LL  is null  -- add this for SAP tests **
            or a.PARIFRSSEG_LL  is null  -- add this for SAP tests **
            or a.LOCIFRSSEG_LL  is null  -- add this for SAP tests **
          )
    -- récuperer codes retour update --
       SELECT @erreur = @@error, @trans_etat = @@transtate
       IF @erreur != 0 OR @trans_etat > 1
             BEGIN
                  PRINT 'UPDATING BRET..TRETIFRS for P&C - ERROR : %1!',@erreur
                    ROLLBACK TRAN
                    GOTO fin
             END
    
    Print '   BRET..TRETIFRS P&C apres maj :  '
    select   a.GRPINIPRO_CF  
            ,a.PARINIPRO_CF  
            ,a.LOCINIPRO_CF  
            ,a.GRPIFRSSEG_CT   -- add this for SAP tests **
            ,a.GRPIFRSTRA_CT   -- add this for SAP tests **
            ,a.GRPIFRSSEG1_CT
            ,a.PARIFRSSEG_CT   -- add this for SAP tests **
            ,a.PARIFRSTRA_CT   -- add this for SAP tests ** 
            ,a.PARIFRSSEG1_CT
            ,a.LOCIFRSSEG_CT   -- add this for SAP tests ** 
            ,a.LOCIFRSTRA_CT   -- add this for SAP tests ** 
            ,a.LOCIFRSSEG1_CT
            ,a.GRPIFRSSEG1_LL
            ,a.PARIFRSSEG1_LL
            ,a.LOCIFRSSEG1_LL
            ,a.*
     from BRET..TRETIFRS a, BRET..TRETCTR b, BREF..TESB c
        where a.RETCTR_NF = b.RETCTR_NF
        and a.RTY_NF = b.RTY_NF
        and b.SSD_CF = c.SSD_CF
        and b.ESB_CF = c.ESB_CF
        and c.LIFE_CF = 2 -- P&C       


COMMIT TRAN
--ROLLBACK TRAN
fin:
go

set nocount on

-- Defintion des variables --
declare @msg varchar(100)

-- Initialisation des variables --
SELECT @msg=@@servername + ' => ' + host_name()
                         + ' Fin update TRETIFRS  '
                         + convert(char(9), getdate(), 6)
                         + ' ' + convert(char(8), getdate(), 8)
                         + substring(convert(char(27), getdate(), 109), 21, 4)
PRINT @msg

set nocount off
go
