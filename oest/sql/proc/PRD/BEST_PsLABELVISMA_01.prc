USE BEST
GO

/* 
 * DROP PROC dbo.PsLABELVISMA_01 */
IF OBJECT_ID('dbo.PsLABELVISMA_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsLABELVISMA_01
    PRINT '<<< DROPPED PROC dbo.PsLABELVISMA_01 >>>'
END
GO

/*
 * creation de la procedure */
CREATE PROCEDURE dbo.PsLABELVISMA_01(
    @p_CED_NF    UCLI_NF,
    @p_CTR_NF    UCTR_NF,
    @p_UWY_NF    UUWY_NF,
    @p_UW_NT     UUW_NT,
    @p_END_NT    UEND_NT,
    @p_SEC_NF    USEC_NF,
    @p_TRNCOD_CF UDETTRS_CF
)


as
/**************************************************
Programme:              PsLABELVISMA_01
Base principale :       BEST
Version:                8.1
Auteur:                 D.GATIBELZA
Date de creation:       26/05/2008

Description du programme:   Retourne les labels nécessaires pour la génération du fichier mensuel VISMA
                            ESTDOM16015 Specifications for the Omega to Visma interface (phase mensuelle)
_________________
MODIFICATION    []
Auteur:         
Date:           
Version:        
Description:    
*****************************************************/


  declare @CLISHONAM_LD varchar(25),
          @ANLCTY_CF    char(3),
          @LOB_CF       char(2),
          @GAR_CF       char(3),
          @TOP_CF       char(3),
          @LOB_GS       varchar(16),
          @GAR_GS       varchar(16),
          @TOP_GS       varchar(16),
          @SUBTRS_GL    varchar(64)



    ------------------------------------------
    -- sp_help TSECTION
    --  CLI_NF
    ------------------------------------------
    select @CLISHONAM_LD = CLISHONAM_LD
    from BCLI..TCLIENT
    where CLI_NF = @p_CED_NF


    ------------------------------------------
    -- sp_help TSECTION
    --  CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF
    ------------------------------------------
    select @ANLCTY_CF = ANLCTY_CF,
           @LOB_CF    = LOB_CF,
           @GAR_CF    = GAR_CF,
           @TOP_CF    = TOP_CF
    from BTRT..TSECTION
    where CTR_NF = @p_CTR_NF
      and UWY_NF = @p_UWY_NF
      and UW_NT  = @p_UW_NT
      and END_NT = @p_END_NT
      and SEC_NF = @p_SEC_NF


    ------------------------------------------
    -- sp_help TLOBL
    --  LOB_CF, LAG_CF
    ------------------------------------------
    select @LOB_GS  = LOB_GS
    from BREF..TLOBL
    where LOB_CF = @LOB_CF
      and LAG_CF = 'E'


    ------------------------------------------
    -- sp_help TGAR
    --  GAR_CF
    ------------------------------------------
    select @GAR_GS  = GAR_GS
    from BREF..TGAR
    where GAR_CF = @GAR_CF


    ------------------------------------------
    -- sp_help TTOP
    --  TOP_CF
    ------------------------------------------
    select @TOP_GS = TOP_GS
    from BREF..TTOP
    where TOP_CF = @TOP_CF


    ------------------------------------------
    -- sp_help TSUBTRS
    --  PCPTRS_CF, TRS_CF, SUBTRS_CF
    ------------------------------------------
    select @SUBTRS_GL=SUBTRS_GL
    from BREF..TSUBTRS sub, BREF..TDETTRS det
    where sub.PCPTRS_CF = det.PCPTRS_CF
      and sub.TRS_CF    = det.TRS_CF
      and sub.SUBTRS_CF = det.SUBTRS_CF
      and det.DETTRS_CF = @p_TRNCOD_CF



select isnull(@CLISHONAM_LD, ''),
       isnull(@ANLCTY_CF,    ''),
       isnull(@LOB_CF,       ''),
       isnull(@LOB_GS,       ''),
       isnull(@GAR_CF,       ''),
       isnull(@GAR_GS,       ''),
       isnull(@TOP_CF,       ''),
       isnull(@TOP_GS,       ''),
       isnull(@SUBTRS_GL,    '')

fin:

GO  

IF OBJECT_ID('dbo.PsLABELVISMA_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsLABELVISMA_01>>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsLABELVISMA_01>>>'
GO

/*
 * Granting/Revoking Permissions on dbo.PsLABELVISMA_01 */
GRANT EXECUTE ON dbo.PsLABELVISMA_01 TO GOMEGA
GO 


