use BEST
go

if object_id('dbo.PsCONTR_19') IS NOT null
    begin
        drop PROC dbo.PsCONTR_19
        print '<<< DROPPED PROC dbo.PsCONTR_19 >>>'
    end
go

create procedure PsCONTR_19 (
                    @p_CTR_NF       UCTR_NF,
                    @p_SEC_NF       USEC_NF,
                    @p_UWY_NF       UUWY_NF)
as

/***************************************************
Domaine                 : Estimation
Base principale         : BEST
Version                 : 1
Auteur                  : G. BUISSON
Date de creation        : 06 Juillet 2005
Description du programme: Application Estimations - Historique des dépassements
                          Recherche des informations traité + section soit sur
                          BTRT soit sur BRET
Conditions d'execution  :
Commentaires            : En relation avec la fiche Spot 10991
_________________
MODIFICATION            : 1
Auteur                  : 
Date                    : 
Description             : 

*****************************************************/

declare @erreur         int,
        @CTRSTS_CT      UCTRSTS_CT,
        @CED_NF         UCLI_NF,
        @PRG_NF         UCTRGRP_NF,
        @BOQ_NF         UCTRGRP_NF,
        @CTRPCPNAM_LL   UL64,
        @ESTCRB_CT      char(1),
        @SSD_CF         USSD_CF,
        @LOB_CF         ULOB_CF,
        @SOB_CF         USOB_CF,
        @TOP_CF         UTOP_CF,
        @GAR_CF         UGAR_CF,
        @NAT_CF         UCTRNAT_CF,
        @SUBNAT_CF      UCTRSUBNAT_CF,
        @ORIGINE        char(3)

If exists (Select 1
           From   BTRT..TCONTR
           Where  CTR_NF = @p_CTR_NF)
    begin
        Select @CTRSTS_CT    = a.CTRSTS_CT,
               @CED_NF       = a.CED_NF,
               @PRG_NF       = a.PRG_NF,
               @BOQ_NF       = a.BOQ_NF,
               @CTRPCPNAM_LL = a.CTRPCPNAM_LL,
               @ESTCRB_CT    = a.ESTCRB_CT,
               @SSD_CF       = a.SSD_CF,
               @LOB_CF       = b.LOB_CF,
               @SOB_CF       = b.SOB_CF,
               @TOP_CF       = b.TOP_CF,
               @GAR_CF       = b.GAR_CF,
               @NAT_CF       = b.NAT_CF,
               @SUBNAT_CF    = b.SUBNAT_CF,
               @ORIGINE      = 'TRT'
        From   BTRT..TCONTR a, BTRT..TSECTION b
        Where  a.CTR_NF = @p_CTR_NF
        And    a.CTR_NF = b.CTR_NF
        And    a.UWY_NF = b.UWY_NF
        And    b.SEC_NF = @p_SEC_NF
        And    a.UWY_NF = (select max(c.UWY_NF)
                           from   BTRT..TCONTR c
                           where  a.CTR_NF     = c.CTR_NF
                           and    c.CTRSTS_CT in (14, 16, 17, 19))
    end
Else
    begin
        Select @CTRSTS_CT    = a.RETCTRSTS_CT,
               @CED_NF       = a.FLABRK_NF,
               @PRG_NF       = a.PRG_NF,
               @BOQ_NF       = NULL,
               @CTRPCPNAM_LL = a.CTRPCPNAM_LL,
               @ESTCRB_CT    = NULL,
               @SSD_CF       = a.SSD_CF,
               @LOB_CF       = b.LOB_CF,
               @SOB_CF       = b.SOB_CF,
               @TOP_CF       = b.TOP_CF,
               @GAR_CF       = b.GAR_CF,
               @NAT_CF       = b.NAT_CF,
               @SUBNAT_CF    = b.SUBNAT_CF,
               @ORIGINE      = 'RET'
        From   BRET..TRETCTR a, BRET..TRETSEC b
        Where  a.RETCTR_NF = @p_CTR_NF
        And    a.RETCTR_NF = b.RETCTR_NF
        And    a.RTY_NF    = b.RTY_NF
        And    b.RETSEC_NF = @p_SEC_NF
        And    a.RTY_NF    = (select max(c.RTY_NF)
                              from   BRET..TRETCTR c
                              where  a.RETCTR_NF     = c.RETCTR_NF
                              and    c.RETCTRSTS_CT in (3, 19))
    end

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20003 "APPLICATIF;TCONTR/TRETCTR"
        return 1
    end

-- Select Final

Select  @CTRSTS_CT      CTRSTS_CT, 
        @CED_NF         CED_NF, 
        @PRG_NF         PRG_NF, 
        @BOQ_NF         BOQ_NF, 
        @CTRPCPNAM_LL   CTRPCPNAM_LL, 
        @ESTCRB_CT      ESTCRB_CT, 
        @SSD_CF         SSD_CF, 
        @LOB_CF         LOB_CF, 
        @SOB_CF         SOB_CF, 
        @TOP_CF         TOP_CF, 
        @GAR_CF         GAR_CF, 
        @NAT_CF         NAT_CF, 
        @SUBNAT_CF      SUBNAT_CF, 
        @ORIGINE        ORIGINE

return 0
go

if object_id('dbo.PsCONTR_19') IS NOT null
  print '<<< CREATED PROC dbo.PsCONTR_19 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsCONTR_19 >>>'
go

grant execute on dbo.PsCONTR_19 TO GOMEGA
go

