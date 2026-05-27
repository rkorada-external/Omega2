USE BEST
Go
/* DROP PROC dbo.PsREQJOBPLAN_06
*/
IF OBJECT_ID('dbo.PsREQJOBPLAN_06') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsREQJOBPLAN_06
   PRINT '<<< DROPPED PROC dbo.PsREQJOBPLAN_06 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsREQJOBPLAN_06
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            char(8),
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
	@p_cre_d               datetime
     )
as

/***************************************************

Programme               : PsREQJOBPLAN_06

Fichier script associé  : PsREQJOBPLAN_06.PRC

Domaine                 : (ES) Estimation

Base principale         : BEST

Version                 : 1

Auteur                  : T.RIPERT

Date de creation        : 08/09/2010

Description du programme:

      Controle d'existence pour ne pas créer de doublons.

Parametres:
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            char(8),
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
	    @p_cre_d               datetime

Conditions d'execution:


Commentaires:

_________________


*****************************************************/

declare @ret bit

If Exists( Select 1
             from BEST..TREQJOBPLAN
             where
                balsheyea_nf = @p_balsheyea_nf
                and balshtmth_nf = @p_balshtmth_nf
                and convert(varchar(8),clodat_d,112) = @p_clodat_d
		        and convert(char(9),cre_d,112) = convert(char(9),@p_cre_d,112)   -- MOD002

                and reqcod_ct = @p_reqcod_ct
                and (
                        (reqcod_ct not in ("Z,","D")
                            and ssd_cf = @p_ssd_cf )
                        OR
                        reqcod_ct in ("Z","D")
                     )
              )
   select @ret = 1
Else
   select @ret = 0

/*************** Select FINAL ***************/

 Select @ret

return 0
go

/*
 * fin de la procedure
 */

IF OBJECT_ID('dbo.PsREQJOBPLAN_06') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsREQJOBPLAN_06 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsREQJOBPLAN_06 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOBPLAN_06
 */
GRANT EXECUTE ON dbo.PsREQJOBPLAN_06 TO GOMEGA
go

GRANT EXECUTE ON dbo.PsREQJOBPLAN_06 TO PUBLIC
go
