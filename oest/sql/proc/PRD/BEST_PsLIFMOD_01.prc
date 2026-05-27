Use BEST
go

If Object_Id('dbo.PsLIFMOD_01') Is Not Null
    Begin
        Drop Procedure dbo.PsLIFMOD_01
        If object_id('dbo.PsLIFMOD_01') IS NOT null
            Print '<<< FAILED DROPPING procedure dbo.PsLIFMOD_01 >>>'
        Else
            Print '<<< DROPPED procedure dbo.PsLIFMOD_01 >>>'
    End
go

Create Procedure PsLIFMOD_01 (@p_CTR_NF       UCTR_NF,
                              @p_SEC_NF       USEC_NF,
                              @p_BALSHEY_NF   smallint,
                              @p_BALSHTMTH_NF tinyint,
                              @p_CRE_D        datetime,
                              @p_MAIL_B       bit = 0,
                              @p_RETRO_B      bit = 0)
As

/***************************************************
Domaine                   : Estimation
Base principale           : BEST
Auteur                    : Florent
Date de creation          : 07/10/2004
Description du programme  : estimation Vie, suivi dépassement du seuil
Conditions d'execution    : par les dw d_seuil_lifmod et d_seuil_lifmod_r
Commentaires              : gestion des montants en milliers
_________________
MODIFICATION              : 1
Auteur                    : G.BUISSON
Date                      : 27/06/2006
Description               : SPOT n° 11102
                            La date de mise à jour Stat Reporting ne doit pas systématiquement être la dernière
                            Si l'appel vient d'une alerte archivée elle doit être à CRE_D de TLIFMOD mais elle
                            n'a de signification que si ORICOD_LS = "ARRETE STAT" sinon elle doit être à blanc.
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/
Declare @erreur     int,
        @lignes     integer,
        @maxCRE_D   datetime,
        @UWGRP_CF   UGRP_CF,
        @CED_LS     varchar(25),
        @CED_NF     UCLI_NF,
        @STAT_REP_D datetime,
        @SSD_CF     USSD_CF,
        @LAG_CF     char(1),
        @MAJSR_D    datetime,
        @LSTUPD_D   datetime,
        @ORICOD_LS  UL16

Select @LAG_CF = IsNull(LAG_CF, 'E') 
From   BREF..TUSR 
Where  USR_CF = suser_name()

If @LAG_CF Is Null 
    Select @LAG_CF = 'E'

declare @site_cf        varchar(10)
        
Execute @erreur = BEST..PsSITE_01 @SSD_CF,'2',@site_cf output

-- Si on vient de l'historique (@p_CRE_D not null) il faut reprendre la date
-- de création et l'ORICOD_LS de TLIFMOD
If @p_CRE_D Is Not Null
    Begin
        Select @MAJSR_D   = CRE_D,
               @LSTUPD_D  = LSTUPD_D,
               @ORICOD_LS = ORICOD_LS
        From   BEST..TLIFMOD
        Where  CTR_NF                       = @p_CTR_NF
        And    SEC_NF                       = @p_SEC_NF
        And    BALSHEY_NF                   = @p_BALSHEY_NF
        And    BALSHTMTH_NF                 = @p_BALSHTMTH_NF
        And    CRE_D                        = @p_CRE_D
--        And    Convert(char(8), CRE_D, 112) = Convert(char(8), @p_CRE_D, 112)
    End

If @p_RETRO_B = 1
    Begin
        Select @SSD_CF   = a.SSD_CF, 
               @UWGRP_CF = b.GRP_CF
        From   BRET..TRETCTR a, BREF..TUSRANFN b
        Where  RETCTR_NF   = @p_ctr_nf
        And    RTY_NF      = (Select Max(RTY_NF) 
                              From   BRET..TRETCTR c 
                              Where  c.RETCTR_NF   = @p_ctr_nf 
                              And    RETCTRSTS_CT in (3, 19))
        And    a.ADMUSR_CF = b.USR_CF
        And    b.PCPGRP_B  = 1

        Select @erreur = @@error
        If @erreur != 0
            Begin
                Raiserror 20005 "APPLICATIF;TCLIENT/TCONTR"
                Return @erreur
            End
    End
Else
    Begin
        Select @CED_NF   = b.CED_NF, 
               @ced_ls   = a.clishonam_ld, 
               @UWGRP_CF = b.UWGRP_CF, 
               @SSD_CF   = b.SSD_CF
        From   BCLI..TCLIENT a, BTRT..TCONTR b
        Where  a.cli_nf   = b.ced_nf
        And    b.CTR_NF   = @p_ctr_nf
--        And    b.LSTUWY_B = 1
        And    UWY_NF     = (Select Max(UWY_NF) 
                             From   BTRT..TCONTR c 
                             Where  c.CTR_NF   = @p_ctr_nf 
                             And    CTRSTS_CT in (14, 16, 17, 19))

        Select @erreur = @@error
        If @erreur != 0
            Begin
                Raiserror 20005 "APPLICATIF;TCLIENT/TCONTR"
                Return @erreur
            End
    End

If @p_CRE_D Is Null
    Begin
        Select @STAT_REP_D = Max(CRE_D)
        From   BEST..TREQJOB
        Where  SSD_CF       = @SSD_CF
        And    REQCOD_CT    = 'L'
        And    BALSHEYEA_NF = 1900
        And    BALSHTMTH_NF = 1
        And    CLODAT_D     = '19000101'
        And    SITE_CF      = @site_cf
    End
Else
    Begin
        Select @STAT_REP_D = @MAJSR_D
        If @ORICOD_LS != 'ARRETE STAT'
            Begin
                Select @STAT_REP_D = convert(datetime,null)
            End
    End

If @@error!=0 Return 101

If @p_CRE_D != Null
    Select @maxCRE_D = @p_CRE_D
Else
    Select @maxCRE_D = Max(CRE_D)
    From   BEST..TLIFMOD
    Where  CTR_NF       = @p_CTR_NF
    And    SEC_NF       = @p_SEC_NF
    And    BALSHEY_NF   = @p_BALSHEY_NF
    And    BALSHTMTH_NF = @p_BALSHTMTH_NF
    And    CRE_D        > @STAT_REP_D

If @@error!=0 return 101

Create Table #TLIFMOD_cre (cre_d datetime)

If @p_SEC_NF = Null
    Begin
        Insert #TLIFMOD_cre
        Select Distinct CRE_D 
        From   BEST..TLIFMOD a 
        Where  CTR_NF       = @p_CTR_NF 
        And    BALSHEY_NF   = @p_BALSHEY_NF 
        And    BALSHTMTH_NF = @p_BALSHTMTH_NF
        And    CRE_D        = (Select Max(CRE_D) 
                               From   BEST..TLIFMOD b 
                               Where  a.CTR_NF       = b.CTR_NF 
                               And    a.BALSHEY_NF   = b.BALSHEY_NF 
                               And    a.BALSHTMTH_NF = b.BALSHTMTH_NF 
                               And    a.SEC_NF       = b.SEC_NF)

        If @@error != 0 Goto fin
    End

If @maxCRE_D != Null Or @p_SEC_NF = Null
    Select CTR_NF,
           SEC_NF,
           CRE_D,
           BALSHEY_NF,
           BALSHTMTH_NF,
           SSD_CF,
           TYPMOD1_CT,
           TYPMOD2_CT,
           CUR_CF,
           CMT_NT        = Case When CMT_NT = 0 Then Null Else CMT_NT End,
           SENMAI_D,
           ORICOD_LS,
           CREUSR_CF,
           LSTUPD_D      = Case When @p_CRE_D Is Not Null Then @LSTUPD_D Else LSTUPD_D End,
           LSTUPDUSR_CF,
           CED_NF        = @CED_NF,
           CED_LS        = IsNull(@CED_LS,''),
           UWGRP_CF      = @UWGRP_CF,
           UWGRP_LS      = IsNull((Select GRP_LS 
                                   From   BREF..TGRP 
                                   Where  GRP_CF = @UWGRP_CF 
                                   And    SSD_CF = @SSD_CF),''),
           STAT_REP_D    = @STAT_REP_D,
           BILAN_PRIME   = (Select Round(Sum(AFTPRMAMT_M - PRIPRMAMT_M) / 1000, 3) 
                            From   BEST..TLIFMOD2 b 
                            Where  a.CTR_NF       = b.CTR_NF 
                            And    a.SEC_NF       = b.SEC_NF 
                            And    a.CRE_D        = b.CRE_D
                            And    a.BALSHEY_NF   = b.BALSHEY_NF 
                            And    a.BALSHTMTH_NF = b.BALSHTMTH_NF 
                            And    b.ACY_NF      <= @p_BALSHEY_NF),
           BILAN_RESTECH = (Select Round(Sum(AFTRESTECAMT_M - PRIRESTECAMT_M) /1000, 3) 
                            From   BEST..TLIFMOD2 c 
                            Where  a.CTR_NF       = c.CTR_NF 
                            And    a.SEC_NF       = c.SEC_NF 
                            And    a.CRE_D        = c.CRE_D
                            And    a.BALSHEY_NF   = c.BALSHEY_NF 
                            And    a.BALSHTMTH_NF = c.BALSHTMTH_NF 
                            And    c.ACY_NF      <= @p_BALSHEY_NF),
           TYPMOD1_LM    = (Select COLVAL_LM 
                            From   BREF..TBANTECL 
                            Where  LAG_CF       = @LAG_CF 
                            And    COL_LS       = 'TYPMOD1_CT' 
                            And    COLVAL_CT    = convert(char(3),a.TYPMOD1_CT) 
                            And    CODVALSSD_CF = Null),
           TYPMOD2_LM    = (Select COLVAL_LM 
                            From   BREF..TBANTECL 
                            Where  LAG_CF       = @LAG_CF 
                            And    COL_LS       = 'TYPMOD2_CT' 
                            And    COLVAL_CT    = convert(char(3),a.TYPMOD2_CT) 
                            And    CODVALSSD_CF = Null)
    From   BEST..TLIFMOD a
    Where  CTR_NF       = @p_CTR_NF
    And  ((SEC_NF       = @p_SEC_NF  And
           CRE_D        = @maxCRE_D) Or 
          (@p_SEC_NF    = Null    And 
           CRE_D       in (Select CRE_D From #TLIFMOD_cre)))
    And    BALSHEY_NF   = @p_BALSHEY_NF
    And    BALSHTMTH_NF = @p_BALSHTMTH_NF
Else                                -- utilisation des convert pour éviter une erreur de retrieve dans PowerBuilder !
    Select CTR_NF        = @p_CTR_NF,
           SEC_NF        = @p_SEC_NF,
           CRE_D         = convert(datetime,null),
           BALSHEY_NF    = @p_BALSHEY_NF,
           BALSHTMTH_NF  = @p_BALSHTMTH_NF,
           SSD_CF        = @SSD_CF,
           TYPMOD1_CT    = convert(tinyint,null),
           TYPMOD2_CT    = convert(tinyint,null),
           CUR_CF        = convert(char(1),null),
           CMT_NT        = convert(int,null),
           SENMAI_D      = convert(datetime,null),
           ORICOD_LS     = convert(char(1),null),
           CREUSR_CF     = substring(suser_name(),1,4),
           LSTUPD_D      = convert(datetime,null),
           LSTUPDUSR_CF  = substring(suser_name(),1,4),
           CED_NF        = @CED_NF,
           CED_LS        = IsNull(@CED_LS,''),
           UWGRP_CF      = @UWGRP_CF,
           UWGRP_LS      = IsNull((Select GRP_LS 
                                   From   BREF..TGRP 
                                   Where  GRP_CF = @UWGRP_CF 
                                   And    SSD_CF = @SSD_CF),''),
           STAT_REP_D    = @STAT_REP_D,
           BILAN_PRIME   = convert(decimal(15,3),null),
           BILAN_RESTECH = convert(decimal(15,3),null)

If @@error!=0 Return 101

-- maj envoi mel
If @p_MAIL_B = 1
    Begin
        BEGIN TRAN
        Update BEST..TLIFMOD
        Set    SENMAI_D     = Getdate(),
               LSTUPD_D     = Getdate(),
               LSTUPDUSR_CF = Suser_name()
        Where  CTR_NF       = @p_CTR_NF
        And    BALSHEY_NF   = @p_BALSHEY_NF
        And    BALSHTMTH_NF = @p_BALSHTMTH_NF
        And  ((SEC_NF       = @p_SEC_NF         And 
               CRE_D        = @maxCRE_D)        Or 
              (@p_SEC_NF    = Null              And 
               CRE_D       in (Select CRE_D From #TLIFMOD_cre)))

        If @@error!=0 Goto fin

        Delete BEST..TLIFPEN
        Where  CTR_NF       = @p_CTR_NF
        And    BALSHEY_NF   = @p_BALSHEY_NF
        And    BALSHTMTH_NF = @p_BALSHTMTH_NF
        And  ((SEC_NF       = @p_SEC_NF         And 
               CRE_D        = @maxCRE_D)        Or 
              (@p_SEC_NF    = Null              And 
               CRE_D       in (Select CRE_D From #TLIFMOD_cre)))
        If @@error!=0 Goto fin

        COMMIT TRAN
    End

If object_id('#TLIFMOD_cre') != Null 
    Drop Table #TLIFMOD_cre
Return 0

fin:
If @@trancount > 0 ROLLBACK TRAN
If object_id('#TLIFMOD_cre') != null Drop Table #TLIFMOD_cre
Return 101
go

If object_id('dbo.PsLIFMOD_01') Is Not Null
    Print '<<< CREATED procedure dbo.PsLIFMOD_01 >>>'
Else
    Print '<<< FAILED CREATING procedure dbo.PsLIFMOD_01 >>>'
go

Grant Execute On dbo.PsLIFMOD_01 To GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFMOD_01 TO GDBBATCH
go

