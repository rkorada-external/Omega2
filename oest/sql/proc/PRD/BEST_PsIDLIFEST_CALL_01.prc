USE BEST
go

/** Drop procedure if already exists **/
IF OBJECT_ID('dbo.PsIDLIFEST_CALL_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsIDLIFEST_CALL_01
    IF OBJECT_ID('dbo.PsIDLIFEST_CALL_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsIDLIFEST_CALL_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsIDLIFEST_CALL_01 >>>'
END
go


/** creation de la procedure **/
CREATE PROCEDURE dbo.PsIDLIFEST_CALL_01
(
    @p_balshtyea_nf  smallint
)
AS

/***************************************************

Programme: PsIDLIFEST_CALL_01

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ESSE Nicolas

Date de creation: 30/07/2015

Description du programme:



Parametres:

Conditions d'execution:

Commentaires:
[001] MBO 22/03/2016 spot:30352: SPIRA:44672 ajout des millisecondes dans le retour fait de START_D et END_D
[002] DFI 14/06/2016 spot:30747: SPIRA:44675 Rapports sur type comptable 1 (survenance) : extraire tous les UWY
*****************************************************/

SELECT  distinct a.ID_CF ,
        a.UPDTYP_CT ,
        a.SSD_CF ,
        a.ESB_CF ,
        a.LSTUPDUSR_CF ,
        a.CTR_NF ,
        a.SEC_NF ,
        s.UWY_NF ,
        a.FLAG_B ,
        Convert(Char(8), a.START_D, 112) + ' ' + Convert(Char(12), a.START_D, 20) ,
        Convert(Char(8), a.END_D, 112) + ' ' + Convert(Char(12), a.END_D, 20)
FROM    BEST..TIDLIFEST_CALL  a,
        BREF..TBATCHSSD b,
        BTRT..TSECTION s
WHERE   FLAG_B = 1
    AND a.SSD_CF = b.SSD_CF
    AND b.BATCHUSER_CF = suser_name()    
    AND (
        s.CTR_NF=a.CTR_NF
        AND s.SEC_NF=a.SEC_NF 
        AND (
            (s.ACCADMTYP_CT=1 AND s.UWY_NF BETWEEN @p_balshtyea_nf - 4 AND @p_balshtyea_nf)
            OR
            (s.ACCADMTYP_CT !=1 AND s.UWY_NF = a.UWY_NF)
        )
    )
go
EXEC sp_procxmode 'dbo.PsIDLIFEST_CALL_01', 'unchained'
go
IF OBJECT_ID('dbo.PsIDLIFEST_CALL_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsIDLIFEST_CALL_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsIDLIFEST_CALL_01 >>>'
go
GRANT EXECUTE ON dbo.PsIDLIFEST_CALL_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsIDLIFEST_CALL_01 TO GDBBATCH
go
