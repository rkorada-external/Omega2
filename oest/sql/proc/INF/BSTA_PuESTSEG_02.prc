use BSTA
go


/*
 * DROP PROC dbo.PuESTSEG_02
 */
IF OBJECT_ID('dbo.PuESTSEG_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PuESTSEG_02
    PRINT '<<< DROPPED PROC dbo.PuESTSEG_02 >>>'
END
go

/********************************************************************************
PuESTSEG_02         BSTA_PuESTSEG_02.prc

Description :       Calqué sur BSTA_PuESTSEG_01.prc Pour ESED0411.cmd

Parametres :
                    ssd_cf  integer : filiale
                    segtyp_ct   char(1)     : type de segment (A ou E)

Valeurs de retour :
                    0:  OK
                    -1: Echec

Conditions d'execution : 

Commentaires :

Historique :        M. DJELLOULI - 07/10/2004 - Création

********************************************************************************/
CREATE PROCEDURE PuESTSEG_02
(
    @ssd_cf     integer,
    @segtyp_ct  char(1)
)
AS
BEGIN

DECLARE @ssdlib_cf char(2)

/* On convertit ssd_cf en varchar, on met 0 devant si filiale < 10 */
select @ssdlib_cf = 
            replicate ('0', 2 - datalength ( convert (varchar, @ssd_cf)))
            + convert (varchar, @ssd_cf)

/* On update dans BSAR : TCTRGRO, TSEGEST et TLABOCY
   On rajoute le numéro de filiale (02 ou 12) dans le champ SEG_NF 
   SEG_NF : char(10)
   On a bien verifié que seg_nf avait au plus 8 caracteres (premiers step du ESED0401)
   Cela ne se fait pas pour New-York (ssd_ cf = 10)   */


BEGIN TRANSACTION


if ( @ssd_cf != 10 )
--    RETURN 0     -- on sort pas d update
begin

update BSAR..TCTRGRO
set SEG_NF =  rtrim(SEG_NF) 
            + replicate (' ', 8-datalength(convert(varchar, SEG_NF)))
            + @ssdlib_cf
from BSAR..TCTRGRO
where SSD_CF = @ssd_cf
and   SEGTYP_CT = @segtyp_ct
IF ( @@error != 0 ) GOTO ERREUR

update BSAR..TSEGEST
set SEG_NF =  rtrim(SEG_NF) 
            + replicate (' ', 8-datalength(convert(varchar, SEG_NF)))
            + @ssdlib_cf
from BSAR..TSEGEST
where SSD_CF = @ssd_cf
and   SEGTYP_CT = @segtyp_ct
and datalength(convert(varchar, SEG_NF)) < 9

IF ( @@error != 0 ) GOTO ERREUR

update BSAR..TLABOCY
set SEG_NF =  rtrim(SEG_NF) 
            + replicate (' ', 8-datalength(convert(varchar, SEG_NF)))
            + @ssdlib_cf
from BSAR..TLABOCY
where SSD_CF = @ssd_cf
and   SEGTYP_CT = @segtyp_ct
IF ( @@error != 0 ) GOTO ERREUR

end

/* On insert dans TBOSEGMT les libelles des segments sans notion d'UWY */

INSERT BSAR..TBOSEGMT
    (SSD_CF,
        SEGTYP_CT,
        SEG_NF,
        SEG_LL)
(SELECT distinct A.SSD_CF,
       A.SEGTYP_CT,
       A.SEG_NF,
       A.SEG_LL
FROM   BSAR..TSEGEST A
where
 UWY_NF = (select max( UWY_NF)
FROM BSAR..TSEGEST B
where A.SSD_CF      = B.SSD_CF
and A.SSD_CF=@ssd_cf
and A.SEGTYP_CT = @segtyp_ct
and   A.SEGTYP_CT   = B.SEGTYP_CT
and   A.SEG_NF      = B.SEG_NF))

IF ( @@error != 0 ) GOTO ERREUR


COMMIT TRANSACTION
RETURN 0

    ERREUR:
    ROLLBACK TRANSACTION
    RETURN -1

END
go
IF OBJECT_ID('dbo.PuESTSEG_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuESTSEG_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuESTSEG_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuESTSEG_02
 */
GRANT EXECUTE ON dbo.PuESTSEG_02 TO GOMEGA
go

