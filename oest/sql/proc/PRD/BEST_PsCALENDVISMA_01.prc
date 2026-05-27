USE BEST
Go

IF OBJECT_ID('dbo.PsCALENDVISMA_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCALENDVISMA_01
   PRINT '<<< DROPPED PROC dbo.PsCALENDVISMA_01 >>>'
END
go

/*
 * creation de la procedure */
create procedure PsCALENDVISMA_01
as

/***************************************************
Programme           :   PsCALENDVISMA_01
Domaine             :   (RF) Références
Base principale     :   BREF
Version             :   8.1
Auteur :                D.GATIBELZA
Date de creation    :   29/05/2008
Description du programme    :   Sélection des enregistrements de TCALEND
                                ESTDOM16015 Specifications for the Omega to Visma interface (phase mensuelle)
_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
*****************************************************/

declare @erreur int


    Select BLCSHTYEA_NF,
           BLCSHTMTH_NF,
           convert(char(8), ACCOUNT_D, 112),
           CLOSING_B
    from BREF..TCALEND
    order by blcshtyea_nf asc, blcshtmth_nf asc

    select @erreur = @@error
    if @erreur != 0
    begin
        raiserror 20005 "APPLICATIF;TCALEND" /* erreur de selection0 */
        return @erreur
    end

return 0
go


/*
 * fin de la procedure  */
IF OBJECT_ID('dbo.PsCALENDVISMA_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsCALENDVISMA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsCALENDVISMA_01 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsCALENDVISMA_01 */
GRANT EXECUTE ON dbo.PsCALENDVISMA_01 TO GOMEGA
go


