Use BEST
go

IF OBJECT_ID('dbo.PsACCPAR_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsACCPAR_01
    PRINT '<<< DROPPED PROC dbo.PsACCPAR_01 >>>'
END
go

/*
 * creation de la procedure
*/

Create Procedure PsACCPAR_01 (@p_prs_cf              smallint,
                              @p_ssd_cf              ussd_cf)
As

/***************************************************

Programme                 : PsACCPAR_01

Fichier script associé    : BEST_PsACCPAR_01.prc

Domaine                   : (ES) Estimation

Base principale           : BEST

Version                   : 1

Auteur                    : ANB avec Infotool version 2.0

Date de creation          :

Description du programme  : Sélection d'enregistrement dans TACCPAR

Parametres                : @p_prs_cf              smallint,
                            @p_ssd_cf              ussd_cf

Conditions d'execution:

Commentaires:
_________________
MODIFICATION              : 1

Auteur                    : G. BUISSON
Date                      : 14/06/2006
Version                   : V06.1
Description               : Spot n° 11156 les postes 1184, 1194, 2184 et 2194 viennent plusieurs fois

_________________
MODIFICATION              : [002]

Auteur                    : T. RIPERT
Date                      : 05/11/2010
Version                   : V10
Description               : Remonter les flags SR, LOB_CF, ...

_________________
MODIFICATION              : [003]

Auteur                    : T. RIPERT
Date                      : 29/12/2010
Version                   : V10
Description               : Afficher les postes cumul amlgré l'absence de dettrs dans tdettrs


*****************************************************/

Declare @erreur int

Select a.ACMTRS_NT,
       d.ACMTRS_LS,
       a.PRS_CF,
       a.ADJCOD_CT,
       a.ADJSIG_B,
       a.CRE_D,
       a.CREUSR_CF,
       a.DETTRS_CF,
       c.SUBTRS_HS,
       a.LSTUPD_D,
       a.LSTUPDUSR_CF,
       a.POSITION_NT,
       a.RETCOD_CT,
       a.SPIMOD_CT,
       a.restec_b,  --[002]
       a.resdac_b,
       a.resfin_b,
       a.sumrisk_b,
       a.lob_cf
From   BEST..TACCPAR a, BREF..TDETTRS b, BREF..TSUBTRSH c, BREF..TACMTRSH d
Where  a.PRS_CF     = @p_prs_cf
And    c.SSD_CF     = @p_ssd_cf
And    a.DETTRS_CF  = b.DETTRS_CF
And    a.DETTRS_CF <> ' '
And    a.PRS_CF     = d.PRS_CF
And    a.ACMTRS_NT  = d.ACMTRS_NT
And    b.PCPTRS_CF  = c.PCPTRS_CF
And    b.TRS_CF     = c.TRS_CF
And    b.SUBTRS_CF  = c.SUBTRS_CF
And    c.SSD_CF     = d.SSD_CF
UNION
Select a.ACMTRS_NT,
       d.ACMTRS_LS,
       a.PRS_CF,
       a.ADJCOD_CT,
       a.ADJSIG_B,
       a.CRE_D,
       a.CREUSR_CF,
       a.DETTRS_CF,
       NULL,
       a.LSTUPD_D,
       a.LSTUPDUSR_CF,
       a.POSITION_NT,
       a.RETCOD_CT,
       a.SPIMOD_CT,
       a.restec_b,  --[002]
       a.resdac_b,
       a.resfin_b,
       a.sumrisk_b,
       a.lob_cf
From   BEST..TACCPAR a, BREF..TACMTRSH d
Where  a.PRS_CF    = @p_prs_cf
And    ( a.DETTRS_CF = ' ' OR a.DETTRS_CF not in (select dettrs_cf from bref..tdettrs ) ) -- [003]
And    a.PRS_CF    = d.PRS_CF
And    a.ACMTRS_NT = d.ACMTRS_NT
And    d.SSD_CF    = @p_ssd_cf
UNION
Select a.ACMTRS_NT,
       a.ACMTRS_LS,
       NUlL,
       NULL,
       1,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL
From   BREF..TACMTRSH a
Where  a.PRS_CF         = @p_prs_cf
And    a.SSD_CF         = @p_ssd_cf
And    a.ACMTRS_NT Not In (Select ACMTRS_NT
                           From   BEST..TACCPAR)
Order By a.ACMTRS_NT

Select @erreur = @@error
If @erreur != 0
  Begin
    Raiserror 20005 "APPLICATIF;TACCPAR" /* erreur de modification */
    Return @erreur
  End

Return 0
go

IF OBJECT_ID('dbo.PsACCPAR_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsACCPAR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsACCPAR_01 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PsACCPAR_01
 */

GRANT EXECUTE ON dbo.PsACCPAR_01 TO GOMEGA
go
