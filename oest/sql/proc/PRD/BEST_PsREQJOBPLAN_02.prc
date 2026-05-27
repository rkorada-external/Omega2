USE BEST
Go

IF OBJECT_ID('dbo.PsREQJOBPLAN_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsREQJOBPLAN_02
   PRINT '<<< DROPPED PROC dbo.PsREQJOBPLAN_02 >>>'
END
go

create procedure PsREQJOBPLAN_02
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_cloper_ls           char(64),
       @p_dbclo_d             datetime
     )
as

/***************************************************

Programme               : PsREQJOBPLAN_02

Fichier script associé  : BEST_PsREQJOBPLAN_02.PRC

Domaine                 : (ES) Estimation

Base principale         : BEST

Version                 : 1

Auteur                  : Tony RIPERT

Date de creation        :

Description du programme:

      Controle d'existence pour ne pas créer de doublons.

Parametres:
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_cloper_ls           char(64),
       @p_dbclo_d             datetime

Conditions d'execution  :


Commentaires            :

*****************************************************/


declare @ret bit

If Exists(  Select   1
            from     BEST..TREQJOBPLAN
            where    balsheyea_nf = @p_balsheyea_nf
            and      balshtmth_nf = @p_balshtmth_nf
            and      convert(varchar(8),clodat_d,112) = @p_clodat_d
            and      convert(varchar(8),dbclo_d,112)  = @p_dbclo_d
            and      convert(char(9),cre_d,112) = convert(char(9),@p_cre_d,112)   -- MOD002
            and      reqcod_ct   =  @p_reqcod_ct
            and      cloper_ls   =  @p_cloper_ls
            and      (
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

IF OBJECT_ID('dbo.PsREQJOBPLAN_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsREQJOBPLAN_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsREQJOBPLAN_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOB_PLAN_01
 */
GRANT EXECUTE ON dbo.PsREQJOBPLAN_02 TO GOMEGA
go

