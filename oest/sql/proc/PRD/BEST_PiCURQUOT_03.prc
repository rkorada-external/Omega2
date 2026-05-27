USE BEST
Go

/*
 * DROP PROC PiCURQUOT_03 */
IF OBJECT_ID('PiCURQUOT_03') IS NOT NULL
BEGIN
    DROP PROC PiCURQUOT_03
    PRINT '<<< DROPPED PROC PiCURQUOT_03 >>>'
END
go

/*
 * creation de la procedure */
create procedure PiCURQUOT_03

as
/***************************************************
Programme                : PiCURQUOT_03
Domaine                  : Estimation
Base principale          : BEST
Auteur                   : D.GATIBELZA
Date de creation         : 21/07/2010
Description du programme : ESTDOM19231 V10 Inventaires de janvier sans taux sur Bilan en cours:
                           -> au closing annuel, charger le taux de décembre YY dans janvier YY+1
_________________
MODIFICATION    [001]
Auteur :        D.GATIBELZA
Date :          18/01/2011
Version :       11.1
Description :   ESTVIE21235  Inventaires de janvier sans taux sur Bilan en cours  au closing annuel, charger le taux de décembre YY dans janvier YY+1 adaptations Mutré
*****************************************************/
declare @date_max  datetime,
        @new_EXC_D datetime,
        @erreur    int,
        @tran_imbr bit

-- Création table temporaire
if object_id('#TCURQUOT') is not null
	drop table #TCURQUOT

CREATE TABLE #TCURQUOT (
    SSD_CF       USSD_CF    NOT NULL,
    CUR_CF       UCUR_CF    NOT NULL,
    EXC_D        datetime   NOT NULL,
    EXC_R        ULNGDEC    NOT NULL,
    EXCTYP_CF    int            NULL,
    EXCORI_CF    int            NULL,
    ACTCOD_B     bit        NOT NULL,
    LSTUPDUSR_CF UUPDUSR_CF NOT NULL,
    LSTUPD_D     UUPD_D         NULL)


BEGIN TRAN

    -- On récupère la dernière date de TCURQUOT
    -- on la prend maintenant sur filiale 99 au lieu de filiale 2
    select @date_max = max(EXC_D)
    from BREF..TCURQUOT
    --[001]where SSD_CF = 99

    select @erreur = @@error
    if @erreur != 0
    begin
        goto fin
    end

    -- on recherche le dernier jour du mois suivant
    select @new_EXC_D = dateadd( dd, -1, dateadd( mm, 1, dateadd ( dd, 1, @date_max )))


    if datepart(MM, @new_EXC_D) = 1
    begin
        -- On récupère tous les cours à cette date
        -- pour toutes les filiales presentes dans TSUBSID
        insert into BREF..TCURQUOT ( SSD_CF, CUR_CF, EXC_D, EXC_R, EXCTYP_CF, EXCORI_CF, ACTCOD_B, LSTUPDUSR_CF, LSTUPD_D )
        select a.SSD_CF, a.CUR_CF, @new_EXC_D, a.EXC_R, a.EXCTYP_CF, a.EXCORI_CF, a.ACTCOD_B, a.LSTUPDUSR_CF, a.LSTUPD_D
        from BREF..TCURQUOT a, BREF..TSUBSID b
        where a.EXC_D  = @date_max
          and a.SSD_CF = b.SSD_CF
          and not exists ( select 1
                           from BREF..TCURQUOT b
                           where b.SSD_CF = a.SSD_CF
                             and b.CUR_CF = a.CUR_CF
                             and b.EXC_D  = @new_EXC_D )

        select @erreur = @@error
        if @erreur != 0
        begin
            goto fin
        end
    end
COMMIT TRAN
return 0

fin:
ROLLBACK TRAN
return @erreur
go

/*
 * fin de la procedure  */
IF OBJECT_ID('PiCURQUOT_03') IS NOT NULL
    PRINT '<<< CREATED PROC PiCURQUOT_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PiCURQUOT_03 >>>'
go

/*
 * Granting/Revoking Permissions on PiCURQUOT_03 */
GRANT EXECUTE ON PiCURQUOT_03 TO GOMEGA
go

