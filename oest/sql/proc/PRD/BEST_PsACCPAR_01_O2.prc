USE BEST
go
IF OBJECT_ID('dbo.PsACCPAR_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsACCPAR_01_O2
    IF OBJECT_ID('dbo.PsACCPAR_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsACCPAR_01_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsACCPAR_01_O2 >>>'
END
go
/*
 * creation de la procedure
*/

Create Procedure dbo.PsACCPAR_01_O2 (@p_prs_cf              smallint,
                              @p_lag_cf             char(1))
As

/***************************************************

Programme                 : PsACCPAR_01_O2

Fichier script associé    : BEST_PsACCPAR_01_O2.prc

Domaine                   : (ES) Estimation

Base principale           : BEST

Version                   : 1

Auteur                    : ANB avec Infotool version 2.0

Date de creation          :

Description du programme  : Sélection d'enregistrement dans TACCPAR

Parametres                : @p_prs_cf              smallint,
                            @p_lag_cf              char(1)

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
_________________
MODIFICATION              : [004]

Auteur                    : F. PIRES
Date                      : 07/2012
Version                   : V11
Description               : OMEGA2 : SSL IMPACT
_________________
MODIFICATION              : [005]

Auteur                    : C. CROS
Date                      : 07/2012
Version                   : V12
Description               : OMEGA2 : new joint on TBANTECL table in order to return code label

*****************************************************/

Declare @erreur int

Select a.ACMTRS_NT,
       d.ACMTRS_GS,
       a.PRS_CF,
       a.ADJCOD_CT,
       tec2.COLVAL_LS AS ADJCOD_LS, --[005]
       a.ADJSIG_B,
       tec1.COLVAL_LS AS ADJSIG_LS,--[005]
       a.CRE_D,
       a.CREUSR_CF,
       a.DETTRS_CF,
       c.SUBTRS_GS,
       a.LSTUPD_D,
       a.LSTUPDUSR_CF,
       a.POSITION_NT,
       a.RETCOD_CT,
       tec3.COLVAL_LS AS RETCOD_LS,--[005]
       a.SPIMOD_CT,
       tec4.COLVAL_LS AS SPIMOD_LS,--[005]
       a.restec_b,  --[002]
       a.resdac_b,
       a.resfin_b,
       a.sumrisk_b
From   BEST..TACCPAR a
LEFT OUTER JOIN BREF..TBANTECL tec2 on--[005]
tec2.COL_LS = 'ADJCOD_CT'--[005]
And    tec2.COLVAL_CT = convert(varchar,a.ADJCOD_CT)--[005]
And    tec2.LAG_CF = @p_lag_cf--[005]
LEFT OUTER JOIN BREF..TBANTECL tec3 on--[005]
tec3.COL_LS = 'RETCOD_CT'--[005]
And    tec3.COLVAL_CT = convert(varchar,a.RETCOD_CT)--[005]
And    tec3.LAG_CF = @p_lag_cf--[005]
LEFT OUTER JOIN BREF..TBANTECL tec4 on--[005]
tec4.COL_LS = 'SPIMOD_CT'--[005]
And    tec4.COLVAL_CT = convert(varchar,a.SPIMOD_CT)--[005]
And    tec4.LAG_CF = @p_lag_cf--[005]
, BREF..TDETTRS b, BREF..TSUBTRSL c, BREF..TACMTRSL d, BREF..TBANTECL tec1--[005]
Where  a.PRS_CF     = @p_prs_cf
And    c.LAG_CF     = @p_lag_cf
And    a.DETTRS_CF  = b.DETTRS_CF
And    a.DETTRS_CF <> ' '
And    a.PRS_CF     = d.PRS_CF
And    a.ACMTRS_NT  = d.ACMTRS_NT
And    b.PCPTRS_CF  = c.PCPTRS_CF
And    b.TRS_CF     = c.TRS_CF
And    b.SUBTRS_CF  = c.SUBTRS_CF
And    c.LAG_CF     = d.LAG_CF
And    tec1.COL_LS = 'ADJSIG_B'
And    tec1.COLVAL_CT = convert(varchar,a.ADJSIG_B)
And    tec1.LAG_CF = @p_lag_cf
UNION
Select a.ACMTRS_NT,
       d.ACMTRS_GS,
       a.PRS_CF,
       a.ADJCOD_CT,
       tec2.COLVAL_LS AS ADJCOD_LS,--[005]
       a.ADJSIG_B,
       tec1.COLVAL_LS AS ADJSIG_LS,--[005]
       a.CRE_D,
       a.CREUSR_CF,
       a.DETTRS_CF,
       NULL,
       a.LSTUPD_D,
       a.LSTUPDUSR_CF,
       a.POSITION_NT,
       a.RETCOD_CT,
       tec3.COLVAL_LS AS RETCOD_LS,--[005]
       a.SPIMOD_CT,
       tec4.COLVAL_LS AS SPIMOD_LS,--[005]
       a.restec_b,  --[002]
       a.resdac_b,
       a.resfin_b,
       a.sumrisk_b
From   BEST..TACCPAR a
LEFT OUTER JOIN BREF..TBANTECL tec2 on--[005]
tec2.COL_LS = 'ADJCOD_CT'--[005]
And    tec2.COLVAL_CT = convert(varchar,a.ADJCOD_CT)--[005]
And    tec2.LAG_CF = @p_lag_cf--[005]
LEFT OUTER JOIN BREF..TBANTECL tec3 on--[005]
tec3.COL_LS = 'RETCOD_CT'--[005]
And    tec3.COLVAL_CT = convert(varchar,a.RETCOD_CT)--[005]
And    tec3.LAG_CF = @p_lag_cf--[005]
LEFT OUTER JOIN BREF..TBANTECL tec4 on--[005]
tec4.COL_LS = 'SPIMOD_CT'--[005]
And    tec4.COLVAL_CT = convert(varchar,a.SPIMOD_CT)--[005]
And    tec4.LAG_CF = @p_lag_cf--[005]
, BREF..TACMTRSL d, BREF..TBANTECL tec1--[005]
Where  a.PRS_CF    = @p_prs_cf
And    ( a.DETTRS_CF = ' ' OR a.DETTRS_CF not in (select dettrs_cf from bref..tdettrs ) ) -- [003]
And    a.PRS_CF    = d.PRS_CF
And    a.ACMTRS_NT = d.ACMTRS_NT
And    d.LAG_CF    = @p_lag_cf
And    tec1.COL_LS = 'ADJSIG_B'
And    tec1.COLVAL_CT = convert(varchar,a.ADJSIG_B)
And    tec1.LAG_CF = @p_lag_cf
UNION
Select a.ACMTRS_NT,
       a.ACMTRS_GS,
       NUlL,
       NULL,
       '  ',
       1,
       tec1.COLVAL_LS AS ADJSIG_LS,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       '  ',
       NULL,
       '  ',
       NULL,
       NULL,
       NULL,
       NULL
From   BREF..TACMTRSL a, BREF..TBANTECL tec1--[005]
Where  a.PRS_CF         = @p_prs_cf
And    a.LAG_CF         = @p_lag_cf
And    a.ACMTRS_NT Not In (Select ACMTRS_NT
                           From   BEST..TACCPAR)
And    tec1.COL_LS = 'ADJSIG_B'--[005]
And    tec1.COLVAL_CT = convert(varchar,1)--[005]
And    tec1.LAG_CF = @p_lag_cf--[005]
Order By a.ACMTRS_NT

Select @erreur = @@error
If @erreur != 0
  Begin
    Raiserror 20005 "APPLICATIF;TACCPAR" /* erreur de modification */
    Return @erreur
  End

Return 0
go
EXEC sp_procxmode 'dbo.PsACCPAR_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsACCPAR_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsACCPAR_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsACCPAR_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PsACCPAR_01_O2 TO GOMEGA
go