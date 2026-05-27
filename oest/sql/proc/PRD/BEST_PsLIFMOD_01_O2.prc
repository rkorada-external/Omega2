USE BEST
go
IF OBJECT_ID('PsLIFMOD_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE PsLIFMOD_01_O2
    IF OBJECT_ID('PsLIFMOD_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PsLIFMOD_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PsLIFMOD_01_O2 >>>'
END
go
Create Procedure PsLIFMOD_01_O2 (@p_CTR_NF       UCTR_NF,
                              @p_SEC_NF       USEC_NF,
                              @p_BALSHEY_NF   smallint,
                              @p_BALSHTMTH_NF tinyint,
                              @p_CRE_D        datetime,
                              @p_MAIL_B       bit = 0,
                              @p_RETRO_B      bit = 0,
							  @p_usr_cf       UUSR_CF,
							  @p_ssd_cf       USSD_CF,
							  @p_esb_cf       UESB_CF,
							  @p_loading_b    bit)
with execute as caller as

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
							_________________
MODIFICATION              : 2
Auteur                    : C.CROS
Date                      : 29/10/2012
Description               : OMEGA2 - LSTUPD_D = Getdate(). retreive date from db for initial select (new modification of the grid)
_________________
MODIFICATION              : 3
Auteur                    : J.CHOCHON
Date                      : 17/12/2012
Description               : SSL IMPACT => obsolet table reoved
											TUSRANFN => TUSR
											TGRP ==> TGRP2
_________________
MODIFICATIONS
M  Auteur          Date       Description
4 C.Cros   24/05/2013 :OMEGA2 - spira17670:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2

_________________
MODIFICATIONS
M  Auteur          Date       Description
5  KBagwe   	10/04/2014 :OMEGA2 - Modified for file upload. Added p_loading_b flag and join on BTRAV..EST_ESID0811_PERIMETER 

_________________
MODIFICATIONS
M  Auteur          Date       Description
6  KBagwe   	25/06/2014 :OMEGA2 - Modified for showing BILAN_PRIME & BILAN_RESTECH considering IFRS gaap.

MODIFICATIONS
M  Auteur          Date       Description
7  A.Deshpande   	07/08/2014 :For SPIRA - 29132 added changed table to #MAXCRED when mail_b =1 and from MAXCRED taken CRE_D.

MODIFICATIONS
M  Auteur          Date       Description
8  G.Pujari   	27/10/2015  :EST 23a added DISPLAY_B.

*****************************************************/
Declare @erreur     int,
        @lignes     integer,		
		@maxCRE_D   datetime,
		@STAT_REP_D datetime,
        @LAG_CF     char(1)
    
Create table #TDATA(
	MAJSR_D    datetime,
	LSTUPD_D   datetime,
    ORICOD_LS  UL16,
	CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NULL,
    UWY_NF      UUWY_NF       NOT NULL
)

create table  #UWGRPCF(
    CED_NF     UCLI_NF,
    CED_LS     varchar(25),
	UWGRP_CF   UGRP_CF,
	SSD_CF     USSD_CF,
	CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NULL,
    UWY_NF      UUWY_NF       NOT NULL
)

create table #MAXCRED(
	maxCRE_D   datetime,
	CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NULL

)

Create table #TLOADING (
    CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NULL,
    UWY_NF      UUWY_NF       NOT NULL,
    END_NT      UEND_NT       NOT NULL,
    UW_NT       UUW_NT        NOT NULL,
    SSD_CF      USSD_CF       NOT NULL,
    ESB_CF      UESB_CF       NOT NULL,
    USR_CF      UUSR_CF       NOT NULL,
    ACCADMTYP_CT UACCADMTYP_CT NULL,
    RETRO_B     bit           DEFAULT 0 NOT NULL,
	PROCE       smallint      DEFAULT 3 NOT NULL)
		

create table #STATREPD(
	STAT_REP_D 	datetime null,
	CTR_NF      UCTR_NF       NOT NULL,
    SEC_NF      USEC_NF       NULL,
)
		
Select @LAG_CF = IsNull(LAG_CF, 'E') 
From   BREF..TUSR 
Where  USR_CF = suser_name()

If @LAG_CF Is Null 
    Select @LAG_CF = 'E'

	
	
IF (@p_loading_b = 1)
begin
Insert into #TLOADING
Select 			    CTR_NF,
                    SEC_NF,
                    UWY_NF,
                    END_NT,
                    UW_NT,
                    SSD_CF,
                    ESB_CF,
                    USR_CF,
                    ACCADMTYP_CT,
                    RETRO_B,
					PROCE
FROM BTRAV..EST_ESID0811_PERIMETER 
WHERE 
USR_CF = @p_usr_cf AND
SSD_CF = @p_ssd_cf AND
ESB_CF = @p_esb_cf AND
ERRORCODE_CT = null

select @erreur = @@error
if @erreur != 0
    begin
        raiserror 20001 "APPLICATIF;#TLOADING"
        return @erreur
    end
end
ELSE
Begin
Insert into #TLOADING ( CTR_NF, SEC_NF, UWY_NF, END_NT, UW_NT, SSD_CF, ESB_CF, USR_CF, ACCADMTYP_CT, RETRO_B, PROCE) 
        VALUES (@p_ctr_nf,@p_sec_nf,0,0,0,@p_ssd_cf,@p_esb_cf,@p_usr_cf,1,@p_RETRO_B, 0)
End
	
	
-- Si on vient de l'historique (@p_CRE_D not null) il faut reprendre la date
-- de création et l'ORICOD_LS de TLIFMOD
If @p_CRE_D Is Not Null OR @p_CRE_D != ''
    Begin
		insert into #TDATA
        Select t.CRE_D,
               t.LSTUPD_D,
               t.ORICOD_LS,
			   l.CTR_NF,
			   l.SEC_NF,
			   l.UWY_NF
        From   BEST..TLIFMOD t, #TLOADING l
        Where  t.CTR_NF                       = l.CTR_NF
        And    t.SEC_NF                       = l.SEC_NF
        And    t.BALSHEY_NF                   = @p_BALSHEY_NF
        And    t.BALSHTMTH_NF                 = @p_BALSHTMTH_NF
        And    t.CRE_D                        = @p_CRE_D
--        And    Convert(char(8), t.CRE_D, 112) = Convert(char(8), @p_CRE_D, 112)
    End

		Insert into #UWGRPCF
        Select 0, 
               '', 
               b.GRP_CF, 
               a.SSD_CF,
			   l.CTR_NF,
			   l.SEC_NF,
			   l.UWY_NF
        --From   BRET..TRETCTR a, BREF..TUSRANFN b
		From   BRET..TRETCTR a, BREF..TUSR b, #TLOADING l
        Where  RETCTR_NF   = l.ctr_nf
        And    RTY_NF      = (Select Max(RTY_NF) 
                              From   BRET..TRETCTR c 
                              Where  c.RETCTR_NF   = l.ctr_nf
                              And    RETCTRSTS_CT in (3, 19))
        And    a.ADMUSR_CF = b.USR_CF
        --And    b.PCPGRP_B  = 1
        and l.RETRO_B =1

        Select @erreur = @@error
        If @erreur != 0
            Begin
                Raiserror 20005 "APPLICATIF;TCLIENT/TCONTR"
                Return @erreur
            End

		Insert into #UWGRPCF
        Select b.CED_NF, 
               a.clishonam_ld, 
               b.UWGRP_CF, 
               b.SSD_CF,
			   l.CTR_NF,
			   l.SEC_NF,
			   l.UWY_NF
        From   BCLI..TCLIENT a, BTRT..TCONTR b, #TLOADING l
        Where  a.cli_nf   = b.ced_nf
        And    b.CTR_NF   = l.ctr_nf
--        And    b.LSTUWY_B = 1
       and l.RETRO_B = 0
        And    b.UWY_NF     = (Select Max(c.UWY_NF) 
                             From   BTRT..TCONTR c 
                             Where  c.CTR_NF   = l.ctr_nf
                             And   c.CTRSTS_CT in (14, 16, 17, 19))

        Select @erreur = @@error
        If @erreur != 0
            Begin
                Raiserror 20005 "APPLICATIF;TCLIENT/TCONTR"
                Return @erreur
            End


If @p_CRE_D Is Null OR @p_CRE_D = ''
    Begin
		insert into #STATREPD
        Select Max(CRE_D),
		l.CTR_NF,
		l.SEC_NF
        From   BEST..TREQJOB a, #TLOADING l
        Where  a.SSD_CF       = l.ssd_cf
        And    a.REQCOD_CT    = 'L'
        And    a.BALSHEYEA_NF = 1900
        And    a.BALSHTMTH_NF = 1
        And    a.CLODAT_D     = '19000101'
		And    l.ssd_cf = @p_SSD_CF
		And	   l.esb_cf = @p_ESB_CF
		group by l.CTR_NF, l.SEC_NF
    End
Else
    Begin
		insert into #STATREPD
		select  Case When a.ORICOD_LS != 'ARRETE STAT' Then convert(datetime,null) Else max(MAJSR_D) End,
		l.CTR_NF,
		l.SEC_NF
		from #TDATA a, #TLOADING l
		Where  a.CTR_NF       = l.CTR_NF
		And    a.SEC_NF       = l.SEC_NF
		group by l.CTR_NF, l.SEC_NF
    End

If @@error!=0 Return 101

If @p_CRE_D Is Null OR @p_CRE_D = ''
	Begin
		INSERT INTO #MAXCRED
		Select Max(CRE_D), a.CTR_NF, a.SEC_NF
		From   BEST..TLIFMOD a, #TLOADING l
		Where  a.CTR_NF       = l.CTR_NF
		And    a.SEC_NF       = l.SEC_NF
		And    a.BALSHEY_NF   = @p_BALSHEY_NF
		And    a.BALSHTMTH_NF = @p_BALSHTMTH_NF
		And    ((a.CREUSR_CF  = @p_usr_cf
				And (a.CRE_D  > (select STAT_REP_D from #STATREPD s where s.CTR_NF = l.CTR_NF and s.SEC_NF = l.SEC_NF)))
			OR DISPLAY_B = 0) --mod 8
		group by a.CTR_NF, a.SEC_NF
	End
Else
	Begin
		INSERT INTO #MAXCRED
		Select @p_CRE_D,@p_CTR_NF, @p_SEC_NF
	End

If @@error!=0 return 101

Create Table #TLIFMOD_cre (cre_d datetime, CTR_NF      UCTR_NF       NOT NULL, SEC_NF      USEC_NF       NULL)

If @p_SEC_NF = Null
 Begin
        Insert #TLIFMOD_cre
        Select Distinct a.CRE_D, l.CTR_NF, l.SEC_NF		
        From   BEST..TLIFMOD a, #TLOADING l
        Where  a.CTR_NF       = l.CTR_NF 
        And    a.BALSHEY_NF   = @p_BALSHEY_NF 
        And    a.BALSHTMTH_NF = @p_BALSHTMTH_NF
        And    a.CRE_D        = (Select Max(CRE_D) 
                               From   BEST..TLIFMOD b
                               Where  a.CTR_NF       = b.CTR_NF 
                               And    a.BALSHEY_NF   = b.BALSHEY_NF 
                               And    a.BALSHTMTH_NF = b.BALSHTMTH_NF 
                               And    a.SEC_NF       = b.SEC_NF)
		group by a.CTR_NF, a.SEC_NF
        If @@error != 0 Goto fin
    End

IF (@p_loading_b = 0)
	IF ((select maxCRE_D from #MAXCRED) <> NULL) OR @p_SEC_NF = Null
		Select l.CTR_NF,
			   l.SEC_NF,
			   a.CRE_D,
			   BALSHEY_NF,
			   BALSHTMTH_NF,
			   a.SSD_CF,
			   TYPMOD1_CT,
			   TYPMOD2_CT,
			   a.CUR_CF,
			   CMT_NT        = Case When CMT_NT = 0 Then Null Else CMT_NT End,
			   SENMAI_D,
			   ORICOD_LS,
			   CREUSR_CF,
			   LSTUPD_D      = Case When @p_CRE_D Is Not Null Then (SELECT DISTINCT(LSTUPD_D) FROM #TDATA tc where tc.CTR_NF = a.CTR_NF and tc.SEC_NF = a.SEC_NF) Else LSTUPD_D End,
			   LSTUPDUSR_CF,
			   CED_NF        = (SELECT DISTINCT(CED_NF) FROM #UWGRPCF tc where tc.CTR_NF = a.CTR_NF and tc.SEC_NF = a.SEC_NF),
			   CED_LS        = IsNull((select DISTINCT(CED_LS) from #UWGRPCF tc where tc.CTR_NF = a.CTR_NF and tc.SEC_NF = a.SEC_NF),''),
			   UWGRP_CF      = (select DISTINCT(UWGRP_CF) from #UWGRPCF tc where tc.CTR_NF = a.CTR_NF and tc.SEC_NF = a.SEC_NF),
			   UWGRP_LS      = IsNull((Select GRP_LS 
									   --From   BREF..TGRP 
									   From   BREF..TGRP2
									   Where  GRP_CF = (select DISTINCT(UWGRP_CF) from #UWGRPCF tc where tc.CTR_NF = a.CTR_NF and tc.SEC_NF = a.SEC_NF) ),''),
									   --And    SSD_CF = @p_SSD_CF),''),												--003 delete
			   STAT_REP_D    = (select STAT_REP_D from #STATREPD s where s.CTR_NF = l.CTR_NF and s.SEC_NF = l.SEC_NF),
			   /**  spira17670:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2 **/
			   BILAN_PRIME   = (Select Round(Sum(AFTPRMAMT_M - PRIPRMAMT_M), 3) 
								From   BEST..TLIFMOD2 b 
								Where  a.CTR_NF       = b.CTR_NF 
								And    a.SEC_NF       = b.SEC_NF 
								And    a.CRE_D        = b.CRE_D
								And    a.BALSHEY_NF   = b.BALSHEY_NF 
								And    a.BALSHTMTH_NF = b.BALSHTMTH_NF 
								And    b.ACY_NF      <= @p_BALSHEY_NF
								AND    b.GAAP_NT	=	2),		--mod06
			   /**  spira17670:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2 **/
			   BILAN_RESTECH = (Select Round(Sum(AFTRESTECAMT_M - PRIRESTECAMT_M), 3) 
								From   BEST..TLIFMOD2 c 
								Where  a.CTR_NF       = c.CTR_NF 
								And    a.SEC_NF       = c.SEC_NF 
								And    a.CRE_D        = c.CRE_D
								And    a.BALSHEY_NF   = c.BALSHEY_NF 
								And    a.BALSHTMTH_NF = c.BALSHTMTH_NF 
								And    c.ACY_NF      <= @p_BALSHEY_NF
								AND    c.GAAP_NT	=	2),		--mod06
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
		From   BEST..TLIFMOD a, #TLOADING l, #MAXCRED m
		Where  a.CTR_NF       = l.CTR_NF
		And    a.SSD_CF		  = l.SSD_CF
		And    a.CTR_NF       = m.CTR_NF
		And    a.SEC_NF		  = m.SEC_NF
		--And    m.maxCRE_D	  != null
		And  ((a.SEC_NF       = l.SEC_NF  And
			   a.CRE_D        = m.maxCRE_D) Or 
			  (l.SEC_NF    = Null    And 
			   a.CRE_D       in (Select CRE_D From #TLIFMOD_cre c where c.CTR_NF = a.CTR_NF and c.SEC_NF = a.SEC_NF)))
		And    a.BALSHEY_NF   = @p_BALSHEY_NF
		And    a.BALSHTMTH_NF = @p_BALSHTMTH_NF

	ELSE 		 -- utilisation des convert pour éviter une erreur de retrieve dans PowerBuilder !
		Select CTR_NF        = @p_CTR_NF,
			   SEC_NF        = @p_SEC_NF,
			   CRE_D         = convert(datetime,null),
			   BALSHEY_NF    = @p_BALSHEY_NF,
			   BALSHTMTH_NF  = @p_BALSHTMTH_NF,
			   SSD_CF        = @p_SSD_CF,
			   TYPMOD1_CT    = convert(tinyint,null),
			   TYPMOD2_CT    = convert(tinyint,null),
			   CUR_CF        = convert(char(1),null),
			   CMT_NT        = convert(int,null),
			   SENMAI_D      = convert(datetime,null),
			   ORICOD_LS     = convert(char(1),null),
			   CREUSR_CF     = substring(suser_name(),1,4),
			   LSTUPD_D      = Getdate(), -- Mofid 2: OMEGA2 - retreive date from db for initial select (new modification of the grid)
			   LSTUPDUSR_CF  = substring(suser_name(),1,4),
			   CED_NF        = (SELECT DISTINCT(CED_NF) FROM #UWGRPCF tc where tc.CTR_NF = @P_CTR_NF and tc.SEC_NF = @P_SEC_NF),
			   CED_LS        = IsNull((SELECT DISTINCT(CED_LS) FROM #UWGRPCF tc where tc.CTR_NF = @P_CTR_NF and tc.SEC_NF = @P_SEC_NF),''),
			   UWGRP_CF      = (SELECT DISTINCT(UWGRP_CF) FROM #UWGRPCF tc where tc.CTR_NF = @P_CTR_NF and tc.SEC_NF = @P_SEC_NF),
			   UWGRP_LS      = IsNull((Select GRP_LS 
									   --From   BREF..TGRP 
									   From   BREF..TGRP2 
									   Where  GRP_CF = (SELECT DISTINCT(UWGRP_CF) FROM #UWGRPCF tc where tc.CTR_NF = @P_CTR_NF and tc.SEC_NF = @P_SEC_NF)),''),
									   --And    SSD_CF = @p_SSD_CF),''),
			   STAT_REP_D    = (select STAT_REP_D from #STATREPD),
			   BILAN_PRIME   = convert(decimal(15,3),null),
			   BILAN_RESTECH = convert(decimal(15,3),null),
			   TYPMOD1_LM    = NULL, -- Add Reasons Labels in creation (cre_d is null)
			   TYPMOD2_LM    = NULL 	
	
ELSE  		-- if @p_loading_b = 1                
		Select DISTINCT l.CTR_NF,
			   l.SEC_NF,
			   a.CRE_D,
			   BALSHEY_NF = (Case When BALSHEY_NF = NULL Then @p_BALSHEY_NF Else BALSHEY_NF End),
			   BALSHTMTH_NF = (Case When BALSHTMTH_NF = NULL Then @p_BALSHTMTH_NF Else BALSHTMTH_NF End),
			   SSD_CF        = @p_SSD_CF,
			   TYPMOD1_CT,
			   TYPMOD2_CT,
			   CUR_CF = (Case When a.CUR_CF = null Then convert(char(1),null) Else a.CUR_CF End),
			   CMT_NT        = Case When CMT_NT = 0 Then Null Else CMT_NT End,
			   SENMAI_D,
			   ORICOD_LS = (Case When ORICOD_LS = NULL Then convert(char(1),null)  Else ORICOD_LS End),
			   CREUSR_CF = (Case When CREUSR_CF = null Then substring(suser_name(),1,4) Else a.CREUSR_CF End),
			   LSTUPD_D      = Case When @p_CRE_D Is Not Null Then (SELECT DISTINCT(LSTUPD_D) FROM #TDATA tc where tc.CTR_NF = l.CTR_NF and tc.SEC_NF = l.SEC_NF) Else Getdate() End,
			   LSTUPDUSR_CF = (Case When LSTUPDUSR_CF = null Then substring(suser_name(),1,4) Else a.LSTUPDUSR_CF End),
			   CED_NF        = (SELECT DISTINCT(CED_NF) FROM #UWGRPCF tc where tc.CTR_NF = l.CTR_NF and tc.SEC_NF = l.SEC_NF),
			   CED_LS        = IsNull((select DISTINCT(CED_LS) from #UWGRPCF tc where tc.CTR_NF = l.CTR_NF and tc.SEC_NF = l.SEC_NF),''),
			   UWGRP_CF      = (select DISTINCT(UWGRP_CF) from #UWGRPCF tc where tc.CTR_NF = l.CTR_NF and tc.SEC_NF = l.SEC_NF),
			   			   UWGRP_LS      = IsNull((Select GRP_LS 
									   --From   BREF..TGRP 
									   From   BREF..TGRP2
									   Where  GRP_CF = (select DISTINCT(UWGRP_CF) from #UWGRPCF tc where tc.CTR_NF = l.CTR_NF and tc.SEC_NF = l.SEC_NF) ),''),
									   --And    SSD_CF = @p_SSD_CF),''),												--003 delete
			   STAT_REP_D    = (select STAT_REP_D from #STATREPD s where s.CTR_NF = l.CTR_NF and s.SEC_NF = l.SEC_NF),
			   /**  spira17670:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2 **/
			   BILAN_PRIME   = (Select Round(Sum(AFTPRMAMT_M - PRIPRMAMT_M), 3) 
								From   BEST..TLIFMOD2 b 
								Where  a.CTR_NF       = b.CTR_NF 
								And    a.SEC_NF       = b.SEC_NF 
								And    a.CRE_D        = b.CRE_D
								And    a.BALSHEY_NF   = b.BALSHEY_NF 
								And    a.BALSHTMTH_NF = b.BALSHTMTH_NF 
								And    b.ACY_NF      = @p_BALSHEY_NF
								AND    b.GAAP_NT	=	2),		--mod06
			   /**  spira17670:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2 **/
			   BILAN_RESTECH = (Select Round(Sum(AFTRESTECAMT_M - PRIRESTECAMT_M), 3) 
								From   BEST..TLIFMOD2 c 
								Where  a.CTR_NF       = c.CTR_NF 
								And    a.SEC_NF       = c.SEC_NF 
								And    a.CRE_D        = c.CRE_D
								And    a.BALSHEY_NF   = c.BALSHEY_NF 
								And    a.BALSHTMTH_NF = c.BALSHTMTH_NF 
								And    c.ACY_NF      = @p_BALSHEY_NF
								AND    c.GAAP_NT	=	2),		--mod06
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
								
		From   #TLOADING l
		LEFT OUTER JOIN #MAXCRED m ON
					l.CTR_NF     = m.CTR_NF
			And    	l.SEC_NF	 = m.SEC_NF
			And    	m.maxCRE_D	 != null
		LEFT OUTER JOIN BEST..TLIFMOD a ON 
					a.CTR_NF    = l.CTR_NF
			And    	a.SSD_CF	= l.SSD_CF
			And    	a.BALSHEY_NF   = @p_BALSHEY_NF
			And    	a.BALSHTMTH_NF = @p_BALSHTMTH_NF
			And    	a.CREUSR_CF = @p_USR_CF
			And  ((a.SEC_NF       = l.SEC_NF  And
				   a.CRE_D        = m.maxCRE_D) Or 
				  (l.SEC_NF    = Null    And 
				   a.CRE_D       in (Select CRE_D From #TLIFMOD_cre c where c.CTR_NF = a.CTR_NF and c.SEC_NF = a.SEC_NF)))
				
		
If @@error!=0 Return 101

-- maj envoi mel
If @p_MAIL_B = 1	
    Begin
        BEGIN TRAN
        Update BEST..TLIFMOD
        Set    SENMAI_D     = Getdate(),
               LSTUPD_D     = Getdate(),
               LSTUPDUSR_CF = Suser_name()
        from BEST..TLIFMOD a, #TLOADING l,#MAXCRED m --Added a join for MAXCRED as CRED was fetched null
		Where  a.CTR_NF       = l.CTR_NF
        And    a.BALSHEY_NF   = @p_BALSHEY_NF
        And    a.BALSHTMTH_NF = @p_BALSHTMTH_NF
        And  ((a.SEC_NF       = l.SEC_NF         And 
               a.CRE_D        = m.maxCRE_D)        Or 
              (@p_SEC_NF    = Null              And 
               a.CRE_D       in (Select CRE_D From #TLIFMOD_cre c where c.CTR_NF = l.CTR_NF and c.SEC_NF = l.SEC_NF)))
		
		
		
        If @@error!=0 Goto fin

        Delete BEST..TLIFPEN
		from BEST..TLIFMOD a, #TLOADING l
        Where  a.CTR_NF       = l.CTR_NF
        And    a.BALSHEY_NF   = @p_BALSHEY_NF
        And    a.BALSHTMTH_NF = @p_BALSHTMTH_NF
        And  ((a.SEC_NF       = l.SEC_NF         And 
               a.CRE_D        = @maxCRE_D)        Or 
              (@p_SEC_NF    = Null              And 
               a.CRE_D       in (Select CRE_D From #TLIFMOD_cre c where c.CTR_NF = l.CTR_NF and c.SEC_NF = l.SEC_NF)))
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
EXEC sp_procxmode 'PsLIFMOD_01_O2', 'unchained'
go
IF OBJECT_ID('PsLIFMOD_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsLIFMOD_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsLIFMOD_01_O2 >>>'
go
GRANT EXECUTE ON PsLIFMOD_01_O2 TO GOMEGA
go
GRANT EXECUTE ON PsLIFMOD_01_O2 TO GDBBATCH
go
