USE BEST
go

/** Drop procedure if already exists **/
IF OBJECT_ID('dbo.PuGAPACCPRO_LSTUPDUSR') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuGAPACCPRO_LSTUPDUSR
    IF OBJECT_ID('dbo.PuGAPACCPRO_LSTUPDUSR') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuGAPACCPRO_LSTUPDUSR >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuGAPACCPRO_LSTUPDUSR >>>'
END
go


/** creation de la procedure **/
CREATE PROCEDURE dbo.PuGAPACCPRO_LSTUPDUSR
AS

/***************************************************

Programme: PuGAPACCPRO_LSTUPDUSR

Fichier script associé :

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ESSE Nicolas

Date de creation: 12/10/2015

Description du programme:
Ajout du LSTUPDUSR dans la table TGAPACCPRO


Parametres:

Conditions d'execution:

Commentaires:

*****************************************************/

UPDATE  BEST..TGAPACCPRO
SET     e.LSTUPDUSR_CF  = t.LSTUPDUSR_CF
FROM    BEST..TGAPACCPRO e,
        BCTA..TACCTRN t
        
WHERE   e.LSTUPDUSR_CF  = "    "
  AND   e.ACY_NF        = t.ACY_NF
  AND   e.CTR_NF        = t.CTR_NF
  AND   e.ESB_CF        = t.ESB_CF
  AND   e.SEC_NF        = t.SEC_NF
  AND   e.SSD_CF        = t.SSD_CF
  AND   e.UWY_NF        = t.UWY_NF
  AND   e.DETTRNCOD_CF  = SUBSTRING (t.TRNCOD_CF, 3, 5)
  AND   t.TRN_NT        = ( SELECT MAX(TRN_NT)
                            FROM BCTA..TACCTRN t2
                            WHERE t2.SSD_CF    = t.SSD_CF
                              AND t2.ESB_CF    = t.ESB_CF
                              AND t2.ACY_NF    = t.ACY_NF
                              AND t2.SEC_NF    = t.SEC_NF
                              AND t2.UWY_NF    = t.UWY_NF
                              AND t2.CTR_NF    = t.CTR_NF
                              AND t2.TRNCOD_CF = t.TRNCOD_CF )
print 'Lignes modifieés %1!',@@rowcount

UPDATE  BEST..TGAPACCPRO
SET     e.LSTUPDUSR_CF  = r.CREUSR_CF                         
FROM    BEST..TGAPACCPRO e,
        BRET..TRACCTRN r
        
WHERE   e.LSTUPDUSR_CF  = "    "
  AND   e.ACY_NF        = r.RETACCYER_NF
  AND   e.CTR_NF        = r.RETCTR_NF
  AND   e.ESB_CF        = r.ESB_CF
  AND   e.SEC_NF        = r.RETSEC_NF
  AND   e.SSD_CF        = r.SSD_CF
  AND   e.UWY_NF        = r.RTY_NF
  AND   e.DETTRNCOD_CF  = SUBSTRING (r.TRNCOD_CF, 3, 5)
  AND   r.RETTRN_NT     = ( SELECT MAX(r2.RETTRN_NT)
                            FROM BRET..TRACCTRN r2
                            WHERE r2.SSD_CF    = r.SSD_CF
                              AND r2.ESB_CF    = r.ESB_CF
                              AND r2.RETACCYER_NF    = r.RETACCYER_NF
                              AND r2.RETSEC_NF = r.RETSEC_NF
                              AND r2.RTY_NF    = r.RTY_NF
                              AND r2.RETCTR_NF = r.RETCTR_NF
                              AND r2.TRNCOD_CF = r.TRNCOD_CF )
print 'Lignes modifieés %1!',@@rowcount

UPDATE  BEST..TGAPACCPRO
SET     e.LSTUPDUSR_CF  = c.LSTUPDUSR_CF
FROM    BEST..TGAPACCPRO e,
        BTRT..TCONTR c
        
WHERE   e.LSTUPDUSR_CF  = "    "
  AND   e.SSD_CF        = c.SSD_CF
  AND   e.CTR_NF        = c.CTR_NF
  AND   lstuwy_b = 1
print 'Lignes modifieés %1!',@@rowcount
go
IF OBJECT_ID('dbo.PuGAPACCPRO_LSTUPDUSR') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuGAPACCPRO_LSTUPDUSR >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuGAPACCPRO_LSTUPDUSR >>>'
go
GRANT EXECUTE ON dbo.PuGAPACCPRO_LSTUPDUSR TO GOMEGA
go
GRANT EXECUTE ON dbo.PuGAPACCPRO_LSTUPDUSR TO GDBBATCH
go