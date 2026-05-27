Use BEST
go

/*
 * DROP PROC PdLIFTHR_01
 */
IF OBJECT_ID('PdLIFTHR_01') IS NOT NULL
    BEGIN
        DROP PROC PdLIFTHR_01
        PRINT '<<< DROPPED PROC PdLIFTHR_01 >>>'
    END
go
      
Create Procedure PdLIFTHR_01 (@p_ssd_cf     ussd_cf,
                              @p_esb_cf     uesb_cf,
                              @p_erreur     varchar(64) = null output)
As

/***************************************************

Programme                   : PdLIFTHR_01

Fichier script associé      : BEST_PdLIFTHR_01.sql

Domaine                     : Estimations

Base principale             : BEST

Version                     : 1

Auteur                      : GIBU

Date de creation            : 15/06/2006

Description du programme    : Suppression de l'enregistrement dans la table TLIFTHR
                              correspondant à la filiale et à l'établissement en paramètre

Parametres                  : @p_ssd_cf     ussd_cf,
                              @p_esb_cf     uesb_cf

Conditions d'execution      :

Commentaires                :
_________________
MODIFICATION                : 

Auteur                      : 
Date                        : 
Version                     : 
Description                 : 

*****************************************************/

Declare @erreur     int

Select @erreur    = 0

BEGIN TRAN

Delete BEST..TLIFTHR
Where  SSD_CF = @p_ssd_cf
And    ESB_CF = @p_esb_cf

Select @erreur=@@error
If @erreur!=0
    Begin
        Select @p_erreur="20004 APPLICATIF;TLIFTHR.AMT_M" + convert(varchar(10),@erreur) + ";"
        Goto fin
    End

COMMIT TRAN
return 0

fin:
ROLLBACK TRAN
return @erreur
go

IF OBJECT_ID('PdLIFTHR_01') IS NOT NULL
    PRINT '<<< CREATED PROC PdLIFTHR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PdLIFTHR_01 >>>'
go

/*
 * Granting/Revoking Permissions on PdLIFTHR_01
 */

GRANT EXECUTE ON PdLIFTHR_01 TO GOMEGA
go

