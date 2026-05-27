USE BEST
go

/*
 * Cr�ation de la Proc�dure */
IF OBJECT_ID('dbo.PsREQJOB_04') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsREQJOB_04
    IF OBJECT_ID('dbo.PsREQJOB_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsREQJOB_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsREQJOB_04 >>>'
END
go 
Create Procedure PsREQJOB_04 ( @p_CRE_D                 UUPD_D,
                               @p_CLONUM                Tinyint ,
                               @p_BLCSHTYEA_NF          Smallint     = 0    OUTPUT,
                               @p_BLCSHTMTH_NF          Tinyint      = 0    OUTPUT,
                               @p_SPCEND_D              Char(8)      = '?'  OUTPUT,
                               @p_ACCOUNT_D             Char(8)      = '?'  OUTPUT,
                               @p_CLODAT_D              Char(8)      = '?'  OUTPUT,
                               @p_DBCLO_D               Char(8)      = '?'  OUTPUT,
                               @p_PERTYP_CT             Char(1)      = '?'  OUTPUT,
                               @p_CLODATMAX_D           Char(8)      = '?'  OUTPUT,
                               @p_SSDACC_LL             Varchar(50)  = '?'  OUTPUT,
                               @p_SSDULT_LL             Varchar(50)  = '?'  OUTPUT,
                               @p_SSDDEL_LL             Varchar(50)  = '?'  OUTPUT,
                               @p_LSTCLODAT_LL          Varchar(150) = '?'  OUTPUT,
                               @p_VRSULT_LL             Varchar(50)  = '?'  OUTPUT,
                               @p_SSDCLO_LL             Varchar(50)  = '?'  OUTPUT,
                               @p_SSDPEOP_LL            Varchar(50)  = '?'  OUTPUT,
                               @p_BOOKING_D             Char(8)      = '?'  OUTPUT,        -- MOD005
                               @p_PSTOMGEN_D            Char(8)      = '?'  OUTPUT,        -- MOD005
                               @p_ENCONSO_D             Char(8)      = '?'  OUTPUT,        -- MOD005
                               @P_DateInventaireConso   char(8)      = '?'  OUTPUT,        -- MOD005
                               @P_PeriodeConsoAA        Numeric(4,0) = 0    OUTPUT,        -- MOD005
                               @P_PeriodeConsoMM        Numeric(2,0) = 0    OUTPUT,        -- MOD005
                               @P_DateInventaireService Char(8)      = '?'  OUTPUT,        -- MOD005
                               @P_PeriodeServiceAA      Numeric(4,0) = 0    OUTPUT,        -- MOD005
                               @P_PeriodeServiceMM      Numeric(2,0) = 0    OUTPUT,        -- MOD005
                               @P_SuffixeTable          Char(1)      = '?'  OUTPUT,
                               @P_EBSPSTOMGEN_D 		char(08)     = '?'	OUTPUT,
                               @P_LSTPSTOMGEN_D 		char(08)	 = '?'	OUTPUT,				--[23390]
							   @P_Booking17_D           Char(8)      = '?'	OUTPUT,
							   @P_PsTomGen17_D          Char(8)      = '?'	OUTPUT,
							   @P_EnConso17_D           Char(8)		 = '?'	OUTPUT)
with execute as caller as




/***************************************************
Programme                : PsREQJOB_04
Fichier script associ�   : BEST_PsREQJOB_04.prc
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : ME65 avec Infotool version 2.0
Date de creation         :
Description du programme : S�lection d'enregistrement dans TREQJOB
Parametres               : @p_CRE_D                 UUPD_D,
                           @p_CLONUM                Tinyint ,
                           @p_BLCSHTYEA_NF          Smallint     = 0    OUTPUT,
                           @p_BLCSHTMTH_NF          Tinyint      = 0    OUTPUT,
                           @p_SPCEND_D              Char(8)      = '?'  OUTPUT,
                           @p_ACCOUNT_D             Char(8)      = '?'  OUTPUT,
                           @p_CLODAT_D              Char(8)      = '?'  OUTPUT,
                           @p_DBCLO_D               Char(8)      = '?'  OUTPUT,
                           @p_PERTYP_CT             Char(1)      = '?'  OUTPUT,
                           @p_CLODATMAX_D           Char(8)      = '?'  OUTPUT,
                           @p_SSDACC_LL             Varchar(50)  = '?'  OUTPUT,
                           @p_SSDULT_LL             Varchar(50)  = '?'  OUTPUT,
                           @p_SSDDEL_LL             Varchar(50)  = '?'  OUTPUT,
                           @p_LSTCLODAT_LL          Varchar(150) = '?'  OUTPUT,
                           @p_VRSULT_LL             Varchar(50)  = '?'  OUTPUT,
                           @p_SSDCLO_LL             Varchar(50)  = '?'  OUTPUT,
                           @p_SSDPEOP_LL            Varchar(50)  = '?'  OUTPUT,
                           @p_BOOKING_D             Char(8)      = '?'  OUTPUT,        -- MOD005
                           @p_PSTOMGEN_D            Char(8)      = '?'  OUTPUT,        -- MOD005
                           @p_ENCONSO_D             Char(8)      = '?'  OUTPUT,        -- MOD005
                           @P_DateInventaireConso   char(8)      = '?'  OUTPUT,        -- MOD005
                           @P_PeriodeConsoAA        Numeric(4,0) = 0    OUTPUT,        -- MOD005
                           @P_PeriodeConsoMM        Numeric(2,0) = 0    OUTPUT,        -- MOD005
                           @P_DateInventaireService Char(8)      = '?'  OUTPUT,        -- MOD005
                           @P_PeriodeServiceAA      Numeric(4,0) = 0    OUTPUT,        -- MOD005
                           @P_PeriodeServiceMM      Numeric(2,0) = 0    OUTPUT,        -- MOD005
                           @P_SuffixeTable          Char(1)      = '?'  OUTPUT
_________________
MODIFICATION             : 1  --MOD001--
Auteur                   : DELVALLEZ
Date                     : 14/11/1997
Version                  :
Description              : D�termination des filiales demandant un PLAN en vie
_________________
MODIFICATION             : 2  --MOD002--
Auteur                   : O. Arik
Date                     : 06/08/2002
Version                  :
Description              : CLOPER_LS passe de 16 caract�res � 32 caract�res
_________________
MODIFICATION             : 3  --MOD003--
Auteur                   : J. Ribot
Date                     : 29/01/2004
Version                  :
Description              : @p_LSTCLODAT_LL passe de 80 caract�res � 120 caract�res
_________________
MODIFICATION             : 4  --MOD004--
Auteur                   : J. Ribot
Date                     : 02/06/2004
Version                  :
Description              : modification gestion @p_SSDACC_LL (treqjob ayant reqcod_ct = 'C' et launch_d = NULL)
                           et ajout @p_SSDPEOP_LL (treqjob ayant reqcod_ct = 'C' et launch_d != NULL)
_________________
MODIFICATION             : 5  --MOD005--
Auteur                   : J. Ribot
Date                     : 22/06/2005
Version                  :
Description              : ajout @p_BOOKING_D @p_PSTOMGEN_D@p_ENCOSO_D @P_SuffixeTable pour traitement ecritures post omega
_________________
MODIFICATION             : 6  --MOD006--
Auteur                   : M. DJELLOULI
Date                     : 20/07/2005
Version                  : 5.1
Description              : Ajout Code Erreur Retour Fonction PsREQJOB_04
_________________
MODIFICATION             : 7  --MOD007--
Auteur                   : M. DJELLOULI
Date                     : 01/09/2005
Version                  : 5.1
Description              : Ajout Liste Filliales pour Demande PostOmega
_________________
MODIFICATION             : 8  --MOD008--
Auteur                   : J. Ribot
Date                     : 04/04/2008
Version                  : 5.1
Description              : SPOT15253 @p_LSTCLODAT_LL passe de 120 caract�res a 150 caract�res
                           val passe de 100 caract�res a 150 caract�res
_________________
MODIFICATION             : 9
Auteur                   : JF. VDE
Date                     : 12/09/2008
Version                  : 8.1
Description              : SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 � 64 caract�res
_________________
MODIFICATION             : [010]
Auteur                   : D.GATIBELZA
Date                     : 24/09/2008
Version                  : 8.1
Description              : ESTDOM16107 correction temporaire pour rallonger la zone SSDCLO_LL pour pouvoir r�cup�rer
                           la liste des filiales
_________________
MODIFICATION             : [011]
Auteur                   : G. BUISSON
Date                     : 30/10/2008
Version                  : 8.1
Description              : Spot 16343 : Suppression de la modif temporaire pr�c�dente
_________________
MODIFICATION             : [012]
Auteur                   : J.Ribot
Date                     : 18/12/2008
Version                  : 8.1
Description              : ESTDOM16640 correction temporaire pour rallonger la zone SSDCLO_LL pour pouvoir r�cup�rer
                           la liste des filiales  lors de traitements post omega (table A pour Paris)
_________________
MODIFICATION             : [013]
Auteur                   : J.Ribot
Date                     : 03/03/2009
Version                  : 8.1
Description              : ESTDOM16991   suppression de la spot  ESTDOM16640
                            correction temporaire pour rallonger la zone SSDCLO_LL pour pouvoir r�cup�rer
                           la liste des filiales  lors de traitements post omega (table A pour Paris)
_________________
MODIFICATION             : [014]
Auteur                   : D.GATIBELZA
Date                     : 01/03/2010
Version                  : 10.1
Description              : SRVIE16960 Adaptation de TLIFSTAREP  cr�ation d'une version du plan vie � la demande + ES plan � int�grer
_________________
MODIFICATION             : [015]
Auteur                   : D.GATIBELZA
Date                     : 07/03/2011
Version                  : 11.1
Description              : ESTDOM21408 OneLedger
[012] 28/10/2011 Roger Cassis   :spot:22752 - Remplissage table des filiales TESTSSD si comptabilisation
_________________
MODIFICATION
Auteur:         JF VDV
Date:           23/05/2012
Version:
Description:    [23390] - SOLVENCY am�nagments
[014] 04/06/2012 Roger Cassis   :spot:23802 - solvency : varchar de 2 � 3.
[015] 31/10/2012 Roger Cassis   :spot:24041 - solvency : correction sur calcul date closing

_________________
MODIFICATION
Description: Removed dbo and added �with execute as caller as�

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan - ajout @site_cf sur proc _03
_________________
MODIFICATION             : [101] -> Une modification [017] est non renseign�. Reprise � 101.
Auteur                   : M.Estrade / P. Menant
Date                     : 06/03/2015
Version                  : 11.1
Description              : EST48 :spot:28122
[102] 05/06/2015 R. cassis :spot:28876 Test date compta reglement en jointure avec le calendrier au lieu du mois/an Comptable technique
                                       Test date compta technique en jointure avec le calendrier uniquement
[103] 22/12/2016 R. cassis :spot:31263 Ajout condition pour ne pas inserer de doubles dans la table TESTSSD
[104] 11/07/2017 R. Cassis :Spira:61508 Mise a jour pour chaines ecritures locales ESLD..
[105] 20/07/2022 MBRIK :Spira: Impact pr�prod >> InvConso sur le Q4 � cause du d�calage entre I17 et Post Omega Local ( blcMthLoc & BlcYeaLoc sont null dans Parm3 )
*****************************************************/
Declare @erreur          Int,
        @CLODAT0         Char(8),
        @SSD_CF          Tinyint,
        @REQCOD_CT       Char(1),
        @CLODATPRE_D     Datetime,
        @CLODATPRE       Char(8),
        @VRS_NF          Numeric(10),
        @ISSDCLO_LL      Varchar(50),
        @SSDVRS_LL       Varchar(50),
        @ICLODAT_D       Char(8),
        @CLOTYP_B        Bit,
        @CLOTYP_CT       Char(1),
        @i               Tinyint,
        @CLOEXIST_CT     Bit,
        @SSDPLAN_LL      Varchar(50),        -- MOD001--
        @CLOPER_LS       Varchar(64),        -- MOD001, MOD002,  [SPOT15758]
        @LAUNCH_D        Datetime,           -- MOD004
        @EPOPEOP         Bit,                -- MOD005
        @p_SSDESPLAN_LL  Varchar(50),        -- [014]
        @p_EXEPLAN       int,            -- [101] EXE Year Number
        @p_VSRPLAN       int,            -- [101] Plan Number
        @p_COMPTA_MENS   BIT,                 -- [015]
        @SETTLEMENT_cf   Char(4),
        @TECHNICAL_cf    Char(4),
        @BLCSHTYEALOC_NF Smallint,      -- [104]
        @BLCSHTMTHLOC_NF tinyint,       -- [104]
        @LOCALTYPE_CF    char(3)        -- [104]
declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output
if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end


/*****************************************************************************************
    Extraction des param�tres fixes pour tous les inventaires
*******************************************************************************************/
Execute PsREQJOB_03 @p_CRE_D,@site_cf,
                    @p_BLCSHTYEA_NF     OUTPUT,
                    @p_BLCSHTMTH_NF     OUTPUT,
                    @p_SPCEND_D         OUTPUT,
                    @p_ACCOUNT_D        OUTPUT,
                    @p_CLODAT_D         OUTPUT,
                    @p_DBCLO_D          OUTPUT,
                    @p_PERTYP_CT        OUTPUT,
                    @p_CLODATMAX_D      OUTPUT

Select @erreur= @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End


/*****************************************************************************************
    Extraction des parametres fixes pour tous les inventaires (post omega)
*******************************************************************************************/
Declare  @P_Erreur   int        -- CodeRetour Erreur pour Message Appli

print '====> Avant  PtREQJOB_05 => @P_Booking_D = %1!', @P_Booking_D

Execute PtREQJOB_05 @p_CRE_D,@site_cf,
                    @P_Booking_D             OUTPUT,      -- Date de Booking T-1
                    @P_PsTomGen_D            OUTPUT,      -- Date de Fin de Saisie Post Omega Social (Periode T)
                    @P_EnConso_D             OUTPUT,      -- Date de Fin de Saisie Ecritures Conso (Periode T)
                    @P_DateInventaireConso   OUTPUT,      -- Periode AAAAMM Pour Saisie Ecriture Conso & Social (Periode T-1)
                    @P_PeriodeConsoAA        OUTPUT,      -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
                    @P_PeriodeConsoMM        OUTPUT,      -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
                    @P_DateInventaireService OUTPUT,      -- Periode AAAAMM Pour Saisie Ecriture Services (Periode T)
                    @P_PeriodeServiceAA      OUTPUT,      -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
                    @P_PeriodeServiceMM      OUTPUT,      -- Periode MM Pour Saisie Ecriture Services (Periode T)
                    @P_SuffixeTable          OUTPUT,
                    @P_Erreur                OUTPUT,       -- CodeRetour Erreur pour Message Appli
                    @P_EBSPsTomGen_D         OUTPUT,       -- Date de Fin de Saisie Post Omega Social EBS (Periode T) [23390]
					@P_Booking17_D	         OUTPUT,       
					@P_PsTomGen17_D          OUTPUT,
					@P_EnConso17_D           OUTPUT
print '====> Apr�s PtREQJOB_05 => @P_Booking_D = %1!', @P_Booking_D
Select @erreur= @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End


Select @EPOPEOP = 0

Select @EPOPEOP = 1
From BEST..TREQJOB
Where LAUNCH_D Is Null
  And REQCOD_CT in ('T','Y')  --[104]
  and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site 

--------------------------------------------------------------------
print '==> @EPOPEOP = %1!', @EPOPEOP
--------------------------------------------------------------------  

-- [014] Ecritures service PLAN
/*****************************************************************************************
 Calcul de @p_SSDESPLAN_LL
 ****************************************************************************************/
Declare cur_esplan Cursor For Select Distinct SSD_CF
                              From BEST..TREQJOB
                              Where REQCOD_CT = 'A'
                                And LAUNCH_D Is NULL
                                and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site
                              Order By SSD_CF

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End

Select @p_SSDESPLAN_LL = '_'


-- [101] Start ----------------------------


select @p_EXEPLAN = YEAR(getdate()) -- Pour eviter l'absence de valeur
select @p_VSRPLAN = MONTH(getdate()) -- Pour eviter l'absence de valeur
select @p_EXEPLAN = convert(int,isnull(substring(convert(char(6),VRS_NF),1,4), convert(char(4),BALSHEYEA_NF))), 
       @p_VSRPLAN = convert(int,isnull(substring(convert(char(6),VRS_NF),5,2), convert(char(2),BALSHTMTH_NF)))
                              From BEST..TREQJOB
                              Where REQCOD_CT = 'A'
                                and convert(char(8),DBCLO_D, 112) <= convert(char(8),@p_CRE_D, 112)
                                and convert(char(8),DBCLO_D, 112) = (select max(DBCLO_D) from BEST..TREQJOB
                                                                     where REQCOD_CT = 'A'
                                                                     and convert(char(8),DBCLO_D, 112) <= convert(char(8),@p_CRE_D , 112)
                                                                     and SITE_CF = @site_cf)

-- [101] End -----------------------------

--------------------------------------------------------------------
print '==> @p_EXEPLAN = %1!', @p_EXEPLAN
print '==> @p_VSRPLAN = %1!', @p_VSRPLAN
--------------------------------------------------------------------  

OPEN cur_esplan
Fetch cur_esplan Into @SSD_CF

    While (@@sqlstatus = 0)
    Begin
        Select @p_SSDESPLAN_LL = @p_SSDESPLAN_LL + Convert(Varchar, @SSD_CF) + '_'

Fetch cur_esplan Into @SSD_CF
End
Close cur_esplan
Deallocate Cursor cur_esplan

--------------------------------------------------------------------
print '==> @p_SSDESPLAN_LL = %1!', @p_SSDESPLAN_LL
--------------------------------------------------------------------  

--[015] Indicateur Comptabilisation mensuelle
select @p_COMPTA_MENS = 0

select @p_COMPTA_MENS = 1
from BREF..TCALEND
where @p_CRE_D = ACCOUNT_D
  and CLOSING_B = 0

-- [012]
if @p_COMPTA_MENS = 1
   insert BTRAV..TESTSSD ( SSD_CF )
   select distinct a.ssd_cf
   from  bref..tprintb a,
         bref..tsubsid b,
         bref..TBATCHSSD c
   where a.ssd_cf = b.ssd_cf
   and   a.CRTTYP_CT = 99
   and   a.CRTVAL_LS='ESB_CF'
   and   a.SSD_CF       = c.ssd_cf
   and   c.BATCHUSER_CF = @suser_Name   -- PHP O21B ajout du controle sur le site 
   and   not exists (select 1 from BTRAV..TESTSSD t
                     where a.ssd_cf = t.ssd_cf)  -- [103]
   
--[015]									
select top 1
       @ICLODAT_D=convert(char(8), dateadd(day, -1, dateadd(month, 1, convert( datetime, ( convert(varchar, a.BLCSHTMTH_NF) +
                                                             '/01/' + convert(varchar,(a.BLCSHTYEA_NF)) ) ) ) ), 112 )
from BREF..TCALEND a
where a.ACCOUNT_D > @p_CRE_D
  and a.CLOSING_B = 1
order by a.BLCSHTYEA_NF, a.BLCSHTMTH_NF
--       @ICLODAT_D=convert(char(8), dateadd(month, 1, dateadd(day, -1, convert( datetime, ( convert(varchar, a.BLCSHTMTH_NF) +
--                                                             "/01/" +
--
select @P_LSTPSTOMGEN_D = convert(char(8),dateadd(QQ,-1,@ICLODAT_D), 112)

--------------------------------------------------------------------
print '==> @P_LSTPSTOMGEN_D = %1! @ICLODAT_D = %2!', @P_LSTPSTOMGEN_D, @ICLODAT_D
--------------------------------------------------------------------  

/*****************************************************************************************
 Calcul de @SETTLEMENT_cf
 ****************************************************************************************/
 --[102]
select @SETTLEMENT_cf = 'SIMU'
if exists ( select 1 from BEST..TREQJOBPLAN a, BREF..TCALEND b
            where a.REQCOD_CT    = 'V'
              and a.LAUNCH_D     = NULL
              and a.DBCLO_D      = @p_CRE_D
              and a.DBCLO_D      = b.SACCOUNT_D
              and a.BALSHEYEA_NF = b.BLCSHTYEA_NF
              and a.BALSHTMTH_NF = b.BLCSHTMTH_NF
              and a.SITE_CF      = @site_cf    -- PHP O21B ajout du controle sur le site 
          )
begin
    select @SETTLEMENT_cf = 'BOOK'      
end

/*****************************************************************************************
 Calcul de @TECHNICAL_cf
 ****************************************************************************************/
select @TECHNICAL_cf = 'SIMU'
-- [102]
if exists ( select 1 from BREF..TCALEND
            where ACCOUNT_D    = @p_CRE_D
              and BLCSHTYEA_NF = @p_BLCSHTYEA_NF
              and BLCSHTMTH_NF = @p_BLCSHTMTH_NF 
          )
begin
    select @TECHNICAL_cf = 'BOOK'      
end
/*
if exists ( select 1 from BEST..TREQJOBPLAN, BREF..TCALEND
            where REQCOD_CT    = 'D'
              and LAUNCH_D     = NULL
              and DBCLO_D      = @p_CRE_D
              and ACCOUNT_D    = @p_CRE_D
              and BALSHEYEA_NF = @p_BLCSHTYEA_NF
              and BALSHTMTH_NF = @p_BLCSHTMTH_NF 
              and BLCSHTYEA_NF = @p_BLCSHTYEA_NF
              and BLCSHTMTH_NF = @p_BLCSHTMTH_NF 
              and SITE_CF      = @site_cf    -- PHP O21B ajout du controle sur le site 
              )
begin
    select @TECHNICAL_cf = 'BOOK'      
end
*/

/*****************************************************************************************
 Calcul de @SSDULT_CF
 ****************************************************************************************/
Declare cur_treqjob Cursor For Select Distinct SSD_CF, VRS_NF
                               From BEST..TREQJOB
                               Where REQCOD_CT = 'S'
                                 And LAUNCH_D Is NULL
                                 and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site 
                               Order By SSD_CF

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End

Select @p_SSDULT_LL = '_0_',
       @p_VRSULT_LL = '_0_'

OPEN cur_treqjob
Fetch cur_treqjob Into @SSD_CF, @VRS_NF

While (@@sqlstatus = 0)
Begin
    Select @p_SSDULT_LL = @p_SSDULT_LL + Convert(Varchar, @SSD_CF) + '_'
    Select @p_VRSULT_LL = @p_VRSULT_LL + Convert(Varchar, @VRS_NF) + '_'

Fetch cur_treqjob Into @SSD_CF, @VRS_NF
End

Close cur_treqjob
Deallocate Cursor cur_treqjob

--------------------------------------------------------------------
print '==> @p_SSDULT_LL = %1! @p_VRSULT_LL = %2!', @p_SSDULT_LL, @p_VRSULT_LL
--------------------------------------------------------------------  


/*****************************************************************************************
   Calcul de @SSDACC_CF , @SSDPEOP_ll              MOD004
 ****************************************************************************************/
Declare cur_ssdpeop Cursor For Select Distinct SSD_CF, LAUNCH_D
                               From BEST..TREQJOB
                               Where REQCOD_CT = 'C'
                                 And CLODAT_D >= @p_CLODAT_D
                               Order By SSD_CF

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End

Select @p_SSDACC_LL = '_',
       @p_SSDPEOP_LL = '_'


Open cur_ssdpeop
Fetch cur_ssdpeop Into @SSD_CF, @LAUNCH_D

While (@@sqlstatus = 0)
Begin
    If @launch_d = NULL
    Begin
        Select @p_SSDACC_LL = @p_SSDACC_LL + Convert(Varchar, @SSD_CF) + '_'
    End

    If @launch_d Is Not Null
    Begin
        Select @p_SSDPEOP_LL = @p_SSDPEOP_LL + Convert(Varchar, @SSD_CF) + '_'
    End

Fetch cur_ssdpeop Into @SSD_CF, @LAUNCH_D
End
Close cur_ssdpeop
Deallocate Cursor cur_ssdpeop

--------------------------------------------------------------------
print '==> @p_SSDPEOP_LL = %1!', @p_SSDPEOP_LL
--------------------------------------------------------------------  

/*  fin MOD004 */
/*****************************************************************************************
 Chaine de la liste des filiales en 1er inventaire
 *****************************************************************************************/
Declare cur_ssd Cursor For Select SSD_CF
                           From BTRAV..TESTSSD
                           Order By SSD_CF
Open cur_ssd

Select @p_SSDDEL_LL    = "_",
       @p_LSTCLODAT_LL = "_"

Fetch cur_ssd Into  @SSD_CF
While (@@sqlstatus = 0)
Begin
    /* recherche de l'inventaire principal pr�c�dent l'inventaire   en cours de la filiale en 1er  */
    /* passage d'inventaire   */
    Select @CLODATPRE_D = Max(CLODAT_D)
    From BEST..TREQJOB
    Where BALSHEYEA_NF = Convert(Smallint, Substring(Convert(Char(8), CLODAT_D, 112), 1, 4))
      And BALSHTMTH_NF = Convert(Smallint, Substring(Convert(Char(8), CLODAT_D, 112), 5, 2))
      And SSD_CF = @SSD_CF
      And LAUNCH_D Is Not null
      And REQCOD_CT In ('I','J','L')
      and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site 
      
    Select @CLODATPRE = Convert(Char(8), @CLODATPRE_D, 112)
    If @CLODATPRE < @p_CLODAT_D
    Begin
        Select @p_LSTCLODAT_LL = @p_LSTCLODAT_LL  + @CLODATPRE + '_'
        Select @p_SSDDEL_LL    = @p_SSDDEL_LL     + Convert(Varchar, @SSD_CF) + '_'
    End

Fetch cur_ssd Into  @SSD_CF
End
Close cur_ssd
Deallocate Cursor cur_ssd

--------------------------------------------------------------------
print '==> @p_LSTCLODAT_LL = %1! @p_SSDDEL_LL = %2!', @p_LSTCLODAT_LL, @p_SSDDEL_LL
--------------------------------------------------------------------  


/*****************************************************************************************
 Chaine de la liste des filiales en inventaire
 *****************************************************************************************/
Declare cur_ssd Cursor For Select Distinct SSD_CF
                           From BTRAV..TESTSSD
                           Order By SSD_CF

Open cur_ssd

Select @p_SSDCLO_LL = "_",
       @CLOEXIST_CT = 0

Fetch cur_ssd into  @SSD_CF
While (@@sqlstatus = 0)
Begin
    if @p_COMPTA_MENS != 1 Select @CLOEXIST_CT = 1
    Select @p_SSDCLO_LL = @p_SSDCLO_LL + Convert(Varchar, @SSD_CF) + '_'

Fetch cur_ssd Into  @SSD_CF
End
Close cur_ssd
Deallocate Cursor cur_ssd


-- 20050901- Modif Insertion Liste des Filliales ayant demand� Inventaire
If (@EPOPEOP = 1)
Begin
    Select @p_SSDCLO_LL = Right(CLOPER_LS, DATALENGTH(CLOPER_LS) - 1)
    From BEST..TREQJOB
    Where REQCOD_CT = 'B'
      And BALSHEYEA_NF = @P_PeriodeConsoAA
      And BALSHTMTH_NF = @P_PeriodeConsoMM
      And CLODAT_D     = @P_DateInventaireConso
      and SITE_CF = @site_cf    -- PHP O21B ajout du controle sur le site 
end




/*****************************************************************************************
 s�lection des inventaires et fililale de TREQJOB
 *****************************************************************************************/
Create Table #PARAM ( lig Tinyint,
                      lib Char(50) NULL,
                      val Varchar(500) NULL )

Select @ISSDCLO_LL = '_',
       @SSDVRS_LL  = '_',
       @SSDPLAN_LL = '_'

If (Convert(Char(8), @p_CRE_D, 112) < @p_SPCEND_D)
    Select @p_DBCLO_D = Convert(Char(8), @p_CRE_D, 112)
Else
    Select @p_DBCLO_D = @p_SPCEND_D

If  @p_CLONUM = 0
Begin
    Insert Into #PARAM Values (1, "SSDCLO_LL",    @p_SSDCLO_LL)
    Insert Into #PARAM Values (2, "BLCSHTYEA_NF", Convert(Varchar, @p_BLCSHTYEA_NF))
    Insert Into #PARAM Values (3, "BLCSHTMTH_NF", Convert(Varchar, @p_BLCSHTMTH_NF))
    Insert Into #PARAM Values (4, "CRE_D",        Convert(Char(8), @p_CRE_D, 112))
    Insert Into #PARAM Values (5, "DBCLO_D",      @p_DBCLO_D)
    Insert Into #PARAM Values (6, "CLODAT_D",     @p_CLODAT_D)
    Insert Into #PARAM Values (7, "SPCEND_D",     @p_SPCEND_D)
    Insert Into #PARAM Values (8, "SEGTYPCLO_CT", 'A')
    Insert Into #PARAM Values (9, "PERTYP_CT",    @p_PERTYP_CT)
    Insert Into #PARAM Values (10,"ACCOUNT_D",    @p_ACCOUNT_D)

    Select @i = 11
    While (@i <= 105)		--[23390]
    Begin
        Insert Into #PARAM Values (@i, "---" + Convert(Varchar(3), @i) + "---","----")   -- [014]
        Select @i = @i + 1
    End

    Update #PARAM Set lib = "RETTHRESHOLD_R", val = '0.01'                                             where lig = 15
    Update #PARAM Set lib = "SEGTYP_CT",      val = 'A'                                                where lig = 20
    Update #PARAM Set lib = "CLOEXIST_CT",    val = IsNull(convert(char(3),@CLOEXIST_CT)  ,'---')      where lig = 21
    Update #PARAM Set lib = "CLODATMAX_D",    val = IsNull(@p_CLODATMAX_D,'---')                       where lig = 22
    Update #PARAM Set lib = "BOOKING_D",      val = IsNull(@p_BOOKING_D,'---')                         where lig = 30   --MOD05
    Update #PARAM Set lib = "PSTOMGEN_D",     val = IsNull(@p_PSTOMGEN_D,'---')                        where lig = 31   --MOD05
    Update #PARAM Set lib = "ENCONSO_D",      val = IsNull(@p_ENCONSO_D,'---')                         where lig = 32   --MOD05
    Update #PARAM Set lib = "INVCONSO_D",     val = IsNull(@P_DateInventaireConso,'---')               where lig = 33   --MOD05
    Update #PARAM Set lib = "CONSOYEA",       val = IsNull(convert(char(4),@P_PeriodeConsoAA),'---')   where lig = 34   --MOD05
    Update #PARAM Set lib = "CONSOMTH",       val = IsNull(convert(char(2),@P_PeriodeConsoMM),'---')   where lig = 35   --MOD05
    Update #PARAM Set lib = "INVSERV_D",      val = IsNull(@P_DateInventaireService,'---')             where lig = 36   --MOD05
    Update #PARAM Set lib = "SERVYEA",        val = IsNull(convert(char(4),@P_PeriodeServiceAA),'---') where lig = 37   --MOD05
    Update #PARAM Set lib = "SERVMTH",        val = IsNull(convert(char(2),@P_PeriodeServiceMM),'---') where lig = 38   --MOD05
    Update #PARAM Set lib = "SUFFTABLE",      val = IsNull(@P_SuffixeTable,'---')                      where lig = 39   --MOD05
    Update #PARAM Set lib = "UPDULTTYP_CT",   val = 'Q'                                                where lig = 40
    Update #PARAM Set lib = "SSDACC_LL",      val = IsNull(@p_SSDACC_LL ,'---')                        where lig = 60
    Update #PARAM Set lib = "SSDPEOP_LL",     val = IsNull(@p_SSDPEOP_LL ,'---')                       where lig = 70   --MOD04
    Update #PARAM Set lib = "EPOPEOP",        val = IsNull(convert(char(1), @EPOPEOP),'---')           where lig = 71   --MOD05
    Update #PARAM Set lib = "SEGTYPULT_CT",   val = 'E'                                                where lig = 80
    Update #PARAM Set lib = "SSDULT_LL",      val = IsNull(@p_SSDULT_LL  ,'---')                       where lig = 81
    Update #PARAM Set lib = "VRSULT_LL",      val = IsNull(@p_VRSULT_LL   ,'---')                      where lig = 82
    Update #PARAM Set lib = "ALLSSD_CF",      val = '99'                                               where lig = 99
    Update #PARAM Set lib = "EBSPSTOMGEN_D",  val = IsNull(@P_EBSPSTOMGEN_D,'---')                     where lig = 100	--[23390]
    Update #PARAM Set lib = "LSTPSTOMGEN_D",  val = IsNull(@P_LSTPSTOMGEN_D,'---')                     where lig = 101	--[23390]
    Update #PARAM Set lib = "ICLODAT_D",      val = IsNull(@ICLODAT_D,'---')                           where lig = 102	--[23390]
    Update #PARAM Set lib = "BATCHUSER",      val = IsNull(suser_Name(),'---')                         where lig = 103	--
    Update #PARAM Set lib = "SETTLEMENT",     val = IsNull(@SETTLEMENT_cf,'---')                       where lig = 104	--
    Update #PARAM Set lib = "TECHNICAL",      val = IsNull(@TECHNICAL_cf,'---')                        where lig = 105	--
End


If  @p_CLONUM = 1
Begin
    Declare cur_inventaire Cursor For Select SSD_CF, VRS_NF, Convert(Char(8), CLODAT1_D, 112), CLOTYP_B,
                                             Upper(CLOPER1_LS)                                      --MOD001--
                                      From BTRAV..TESTSSD
                                      Where CLODAT1_D Is Not Null
                                      Order By SSD_CF
End


If  @p_CLONUM = 2
Begin
    Declare cur_inventaire Cursor For Select SSD_CF, VRS_NF, Convert(Char(8), CLODAT2_D, 112), CLOTYP_B,
                                             Upper(CLOPER2_LS)                                      --MOD001--
                                      From BTRAV..TESTSSD
                                      Where CLODAT2_D Is Not Null
                                      Order By SSD_CF
End


If  @p_CLONUM = 3
Begin
    Declare cur_inventaire cursor for Select SSD_CF, VRS_NF, Convert(Char(8), CLODAT3_D, 112), CLOTYP_B,
                                             Upper(CLOPER3_LS)                                      --MOD001--
                                      From BTRAV..TESTSSD
                                      Where CLODAT3_D Is Not Null
                                      Order By SSD_CF
End


If  @p_CLONUM = 4
Begin
    Declare cur_inventaire Cursor For Select  SSD_CF, VRS_NF, Convert(Char(8), CLODAT4_D, 112), CLOTYP_B,
                                              Upper(CLOPER4_LS)                                     --MOD001--
                                      From BTRAV..TESTSSD
                                      Where CLODAT4_D Is Not Null
                                      Order By SSD_CF
End


If  @p_CLONUM != 0
Begin
    Open cur_inventaire
    Fetch cur_inventaire Into @SSD_CF, @VRS_NF, @ICLODAT_D, @CLOTYP_B, @CLOPER_LS                   --MOD001--

    If @CLOTYP_B = 1
        Select @CLOTYP_CT = 'P'
    Else
        Select  @CLOTYP_CT = 'A'

    While (@@sqlstatus = 0)
    Begin
        Select @ISSDCLO_LL = @ISSDCLO_LL + Convert(varchar, @SSD_CF) + '_'
        Select @SSDVRS_LL  = @SSDVRS_LL  + Convert(varchar, @VRS_NF) + '_'
        If (Charindex("PLAN", @CLOPER_LS) != 0)                                                     --MOD001--
            Select @SSDPLAN_LL = @SSDPLAN_LL + Convert(Varchar,@SSD_CF) + '_'                       --MOD001--

    Fetch cur_inventaire Into @SSD_CF, @VRS_NF, @ICLODAT_D, @CLOTYP_B, @CLOPER_LS                   --MOD001--
    End
    Close cur_inventaire

   if (@p_SSDCLO_LL = '_' and @p_SSDESPLAN_LL != '_') 
      select @p_SSDCLO_LL = @p_SSDESPLAN_LL

   if (@ISSDCLO_LL = '_' and @p_SSDESPLAN_LL != '_') 
      select @ISSDCLO_LL = @p_SSDESPLAN_LL

--------------------------------------------------------------------
print '==> @p_SSDCLO_LL = %1! @p_SSDESPLAN_LL = %2!', @p_SSDCLO_LL, @p_SSDESPLAN_LL
--------------------------------------------------------------------  

   -- [104]
	Select @BLCSHTYEALOC_NF = (SELECT distinct a.BALSHEYEA_NF FROM BEST..TREQJOBPLAN a, bref..tcalend b
                              WHERE a.REQCOD_CT = 'Y'
                                and a.LAUNCH_D = Null
                                and isnull(a.VRS_Nf,0) = 0
                                and a.SITE_CF = @site_cf
                                --[105] >= au lieu de =
                                and a.CLODAT_D >= @P_DateInventaireConso
                                and datepart(yy,a.CLODAT_D) = b.BLCSHTYEA_NF
                                and datepart(mm,a.CLODAT_D) = b.BLCSHTMTH_NF
                                and DBCLO_D <= @p_CRE_D
                                and DBCLO_D <= (select min(SPECEND_D) from BREF..TCALEND c 
                                                where CLOSING_B = 1
                                                and   ACCOUNT_D > a.DBCLO_D
                                                and   ACCOUNT_D > (select max(DBCLO_D) from BEST..TREQJOB r
                                                                   where r.REQCOD_CT = 'B'
                                                                   and   a.DBCLO_D > r.DBCLO_D
                                                                   and   r.SITE_CF = @site_cf)
                                               )
                             )

--------------------------------------------------------------------
print '==> @BLCSHTYEALOC_NF = %1!', @BLCSHTYEALOC_NF
--------------------------------------------------------------------  
   -- [104]
	Select @BLCSHTMTHLOC_NF = (SELECT distinct a.BALSHTMTH_NF FROM BEST..TREQJOBPLAN a, bref..tcalend b
                              WHERE a.REQCOD_CT = 'Y'
                                and a.LAUNCH_D = Null
                                and isnull(a.VRS_Nf,0) = 0
                                and a.SITE_CF = @site_cf
                                --[105] >= au lieu de =
                                and a.CLODAT_D >= @P_DateInventaireConso
                                and datepart(yy,a.CLODAT_D) = b.BLCSHTYEA_NF
                                and datepart(mm,a.CLODAT_D) = b.BLCSHTMTH_NF
                                and DBCLO_D <= @p_CRE_D
                                and DBCLO_D <= (select min(SPECEND_D) from BREF..TCALEND c 
                                                where CLOSING_B = 1
                                                and   ACCOUNT_D > a.DBCLO_D
                                                and   ACCOUNT_D > (select max(DBCLO_D) from BEST..TREQJOB r
                                                                   where r.REQCOD_CT = 'B'
                                                                   and   a.DBCLO_D > r.DBCLO_D
                                                                   and   r.SITE_CF = @site_cf)
                                               )
                             )
--------------------------------------------------------------------
print '==> @BLCSHTMTHLOC_NF = %1!', @BLCSHTMTHLOC_NF
--------------------------------------------------------------------  

   -- [104]
   if (@BLCSHTYEALOC_NF is not null and @BLCSHTMTHLOC_NF is not null)
   begin                                
   	if (@BLCSHTYEALOC_NF*100+@BLCSHTMTHLOC_NF) > (@P_PeriodeConsoAA*100+@P_PeriodeConsoMM)
   	   select @LOCALTYPE_CF = 'MTH'
   	else
   	   select @LOCALTYPE_CF = 'QTR'
   end

    If( @ISSDCLO_LL != '_' or @p_SSDESPLAN_LL != "_" or @p_COMPTA_MENS = 1 ) -- au moins une filiale a demand� un inventaire         --[014] ou demande PLAN --[015] ou comptabilisation mensuelle
    Begin
        Insert Into #PARAM Values (1,  "SSDCLO_LL"     , @p_SSDCLO_LL)
        Insert Into #PARAM Values (2,  "ISSDCLO_LL"    , @ISSDCLO_LL)
        Insert Into #PARAM Values (3,  "BLCSHTYEA_NF"  , Convert(Varchar, @p_BLCSHTYEA_NF))
        Insert Into #PARAM Values (4,  "BLCSHTMTH_NF"  , Convert(Varchar, @p_BLCSHTMTH_NF))
        Insert Into #PARAM Values (5,  "CRE_D"         , Convert(Char(8), @p_CRE_D, 112))
        Insert Into #PARAM Values (6,  "DBCLO_D"       , @p_DBCLO_D)
        Insert Into #PARAM Values (7,  "ICLODAT_D"     , @ICLODAT_D)
        Insert Into #PARAM Values (8,  "CLODAT_D"      , @p_CLODAT_D)
        Insert Into #PARAM Values (9,  "SPCEND_D"      , @p_SPCEND_D)
        Insert Into #PARAM Values (10, "CLOTYP_CT"     , @CLOTYP_CT)
        Insert Into #PARAM Values (11, "SEGTYP_CT"     , 'A'    )
        Insert Into #PARAM Values (12, "SSDDEL_LL"     , @p_SSDDEL_LL)
        Insert Into #PARAM Values (13, "LSTCLODAT_LL"  , @p_LSTCLODAT_LL)
        Insert Into #PARAM Values (14, "SSDVRS_LL"     , @SSDVRS_LL)
        Insert Into #PARAM Values (15, "RETTHRESHOLD_R", '0.01')
        Insert Into #PARAM Values (16, "PERTYP_CT"     , @p_PERTYP_CT)
        Insert Into #PARAM Values (17, "SSDPLAN_LL"    , @SSDPLAN_LL)                               -- MOD001
        Insert Into #PARAM Values (18, "BOOKING_D"     , @p_BOOKING_D)                              -- MOD05
        Insert Into #PARAM Values (19, "PSTOMGEN_D"    , @p_PSTOMGEN_D)                             -- MOD05
        Insert Into #PARAM Values (20, "ENCONSO_D"     , @p_ENCONSO_D)                              -- MOD05
        Insert Into #PARAM Values (21, "INVCONSO_D"    , @P_DateInventaireConso)                    -- MOD05
        Insert Into #PARAM Values (22, "CONSOYEA"      , convert(char(4),@P_PeriodeConsoAA))        -- MOD05
        Insert Into #PARAM Values (23, "CONSOMTH"      , convert(char(2),@P_PeriodeConsoMM))        -- MOD05
        Insert Into #PARAM Values (24, "INVSERV_D"     , @P_DateInventaireService)                  -- MOD05
        Insert Into #PARAM Values (25, "SERVYEA"       , convert(char(4),@P_PeriodeServiceAA))      -- MOD05
        Insert Into #PARAM Values (26, "SERVMTH"       , convert(char(2),@P_PeriodeServiceMM))      -- MOD05
        Insert Into #PARAM Values (27, "SUFFTABLE"     , @p_SuffixeTable)                           -- MOD05
        Insert Into #PARAM Values (28, "SSDESPLAN_LL"  , @p_SSDESPLAN_LL)                           --[014]
        Insert Into #PARAM Values (29, "EBSPSTOMGEN_D" , @P_EBSPSTOMGEN_D)                          -- [015] / [23390]
        Insert Into #PARAM Values (30, "LSTPSTOMGEN_D" , @P_LSTPSTOMGEN_D)                          -- [015] / [23390]
        Insert Into #PARAM Values (31, "BATCHUSER"     , suser_Name())                              -- [017] / [23390]
        Insert Into #PARAM Values (32, "SETTLEMENT"    , @SETTLEMENT_cf)                            -- [017] / [23390]
        Insert Into #PARAM Values (33, "TECHNICAL"     , @TECHNICAL_cf)                             -- [017] / [23390]
        Insert Into #PARAM Values (34, "EXEPLAN"       , convert(char(4), @p_EXEPLAN))                                  -- [101] / [28122]
        Insert Into #PARAM Values (35, "VSRPLAN"       , convert(char(2), @p_VSRPLAN))                                  -- [101] / [28122]
        Insert Into #PARAM Values (36, "BLCSHTYEALOC_NF" , convert(char(4), @BLCSHTYEALOC_NF))      -- [104]
        Insert Into #PARAM Values (37, "BLCSHTMTHLOC_NF" , convert(char(2), @BLCSHTMTHLOC_NF))      -- [104]
        Insert Into #PARAM Values (38, "LOCALTYPE_CF"  , @LOCALTYPE_CF                       )      -- [104]


        ------ [023]

            declare @EST_SORT_CONDITION_AS varchar(1000) ,
                @EST_SORT_CONDITION_EU varchar(1000) ,
                @EST_SORT_CONDITION_AM varchar(1000) 


            declare  curs_ssd_all cursor for
            
            select SSD_CF, BATCHUSER_CF
            from   BREF..TBATCHSSD 
            
            declare @PARM_BATCHUSER_ALL varchar(20),
                     @ssd tinyint

            select 	@EST_SORT_CONDITION_AS ='(1=1' ,
                    @EST_SORT_CONDITION_EU ='(1=1' ,
                    @EST_SORT_CONDITION_AM ='(1=1' 
            
            OPEN curs_ssd_all

            fetch curs_ssd_all into @ssd,@PARM_BATCHUSER_ALL
            While (@@sqlstatus = 0)
            BEGIN
                
                if ( @PARM_BATCHUSER_ALL  = "UBAS" ) select @EST_SORT_CONDITION_AS = @EST_SORT_CONDITION_AS + " OR SSD_CF=" + convert(varchar(2),@ssd) 
                if ( @PARM_BATCHUSER_ALL  = "UBEU" ) select @EST_SORT_CONDITION_EU = @EST_SORT_CONDITION_EU + " OR SSD_CF=" + convert(varchar(2),@ssd) 
                if ( @PARM_BATCHUSER_ALL  = "UBAM" ) select @EST_SORT_CONDITION_AM = @EST_SORT_CONDITION_AM + " OR SSD_CF=" + convert(varchar(2),@ssd) 
                fetch curs_ssd_all into @ssd, @PARM_BATCHUSER_ALL
            END

            CLOSE curs_ssd_all



            deallocate cursor curs_ssd_all

            select 	@EST_SORT_CONDITION_AS = "'" + str_replace(@EST_SORT_CONDITION_AS,'(1=1 OR','(') + ")" +"'"
            select 	@EST_SORT_CONDITION_EU = "'" + str_replace(@EST_SORT_CONDITION_EU,'(1=1 OR','(') + ")" +"'"
            select 	@EST_SORT_CONDITION_AM = "'" + str_replace(@EST_SORT_CONDITION_AM,'(1=1 OR','(') + ")" +"'"

            Insert Into #PARAM Values (39, "EST_SORT_CONDITION_AS"  , @EST_SORT_CONDITION_AS                       )      -- [104]
            Insert Into #PARAM Values (40, "EST_SORT_CONDITION_EU"  , @EST_SORT_CONDITION_EU                       )      -- [104]
            Insert Into #PARAM Values (41, "EST_SORT_CONDITION_AM"  , @EST_SORT_CONDITION_AM                       )      -- [104]

        ------ end [023]

    End
    Deallocate Cursor cur_inventaire
End



Select lib + '   ' +val From #PARAM Order By lig

Drop Table #PARAM

Select @erreur = @@error
If @erreur != 0
Begin
    Raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
    Return @erreur
End

Return 0
go
EXEC sp_procxmode 'dbo.PsREQJOB_04', 'unchained'
go
IF OBJECT_ID('dbo.PsREQJOB_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsREQJOB_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsREQJOB_04 >>>'
go
GRANT EXECUTE ON dbo.PsREQJOB_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_04 TO GDBBATCH
go
