USE BEST
go
/*
 * creation de la procedure
*/
IF OBJECT_ID('dbo.PsREQJOB_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsREQJOB_03
    IF OBJECT_ID('dbo.PsREQJOB_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsREQJOB_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsREQJOB_03 >>>'
END
go
create procedure PsREQJOB_03
(
   @p_CRE_D		      UUPD_D,
   @p_site_cf        varchar(10),
	@p_BLCSHTYEA_NF 	smallint OUTPUT,
	@p_BLCSHTMTH_NF 	tinyint  OUTPUT,
	@p_SPCEND_D		    char(8) OUTPUT,
	@p_ACCOUNT_D	    char(8)  OUTPUT,
	@p_CLODAT_D		    char(8)  OUTPUT,
	@p_DBCLO_D		    char(8)  OUTPUT,
	@p_PERTYP_CT	    char(1)  OUTPUT,
	@p_CLODATMAX_D	  char(8)  OUTPUT
)
with execute as caller as

/***************************************************

Programme: PsREQJOB_03
Fichier script associ‰ : ESSREQ03.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME65 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: alimentation BTRAV..TESTSSD

      S‰lection d'enregistrement dans TREQJOB ( version Marc de la proc PsREQJOB_03 )

Parametres:
  @p_CRE_D		UUPD_D,
	@p_BLCSHTYEA_NF 	smallint OUTPUT,
	@p_BLCSHTMTH_NF 	tinyint  OUTPUT,
	@p_SPCEND_D		char(8)  OUTPUT,
	@p_ACCOUNT_D		char(8)  OUTPUT,
	@p_CLODAT_D		char(8)  OUTPUT,
	@p_DBCLO_D		char(8)  OUTPUT,
	@p_PERTYP_CT		char(1)OUTPUT,
	@p_SSDDEL_LL		varchar(50)  OUTPUT,
	@p_LSTCLODAT_D	char(8)  OUTPUT

Conditions d'execution:

Commentaires:

_________________
MODIFICATION 1
Auteur:     M. DJELLOULI
Date:        22/08/2005
Version:    5.1
Description: Intégration Demande Inventaire PostOmega (Demande REQCOD_CT = T)
_________________
MODIFICATION 2
Auteur:     M. DJELLOULI
Date:        07/10/2005
Version:    5.1
Description: Correction sur Sélection p_BLCSHTYEA_NF et p_BLCSHTMTH_NF en Sortie Inventaire
_________________
MODIFICATION 3
Auteur:     G. BUISSON
Date:        28/11/2008
Version:    8.2
Description: Spot 16534 : Ajout d'un Order By sur le Declare Cursor
[004] 29/06/2011  R. CASSIS     :spot:21408 - Modif requete de sélection de l'inventaire maximal demandé
[005] 07/05/2012  R. CASSIS     :spot:23802 - Ajout option E pour Solvency
[006] 31/05/2012  JF VDV        :spot:23290 - Amenagements pour Solvency
[007] 02/08/2012  L. RAKOTOZAFY  :spot:24041 - Solvency II corrections techniques
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan - ajout @p_site_cf
[008] 09/02/2015 C. Despret     :spot:28211 - Comparaison dates DBCLO_D et CRE_D au même format
[101] 04/11/2015 R. Cassis  :spot:29654 Gestion plan2 pour le Post-omega.
[102] 04/08/2017 R. Cassis  :spira:61508 Gestion plan2 pour le Post-omega des ES locales
[103] 21/12/2017 R. Cassis  :spira:66334 gestion plus fiable de plusieurs inventaires en parallèle suite a l'ajout du Local
[104] 12/03/2018 R. Cassis  :spira:67729 Correction condition '>=' au lieu de '>' sur VRS_NF pour parallélisme avec inventaire Local
**********************************************************************************************************/

declare @erreur 		    int
declare @CLODAT0		    char(8)
declare @SPCEND_D		    datetime
declare @ACCOUNT_D		  datetime
declare @CLODAT_D 		  datetime
declare @CLOSING_B		  bit
declare @BLCSHTYEA_NF 	smallint
declare @BLCSHTMTH_NF 	tinyint
declare @var			      int
declare @VRS_NF		      numeric(10)
declare @EPOPEOP_EBS    bit
declare	@nb             smallInt

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
	end

/**********************************************************************************************
	Recherche de l'annee et de la periode du libelle d'inventaire principal.
	On affecte provisoirement 1 au jour pour avoir un format date
***********************************************************************************************/
Execute @erreur = BREF..PsCALEND_02
			@p_cre_d ,
			'C',
			@BLCSHTYEA_NF output,
         @BLCSHTMTH_NF output,
			@SPCEND_D output,
			@ACCOUNT_D output,
			@CLOSING_B output

if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;TACCSUP/TCALEND" /* erreur de lecture */
        	return @erreur
	end

/**********************************************************************************************
	periode bilan
**********************************************************************************************/
select @p_BLCSHTYEA_NF = @BLCSHTYEA_NF
select @p_BLCSHTMTH_NF = @BLCSHTMTH_NF

--------------------------------------------------------------------
print '==> Apres PsCALEND_02'
print '==> @p_cre_d = %1! - @BLCSHTYEA_NF = %2! - @BLCSHTMTH_NF = %3!', @p_cre_d, @BLCSHTYEA_NF, @BLCSHTMTH_NF
print '==> @SPCEND_D = %1! - @ACCOUNT_D = %2! - @CLOSING_B = %3!', @SPCEND_D, @ACCOUNT_D, @CLOSING_B
--------------------------------------------------------------------

/**********************************************************************************************
	Convertion de la date de fin de periode exceptionnelle et de comptabilisation en "AAAAMMJJ"
**********************************************************************************************/
select @p_SPCEND_D  = convert( char(8),@SPCEND_D,112)
select @p_ACCOUNT_D = convert( char(8),@ACCOUNT_D	,112)



If Exists (Select 1 FROM BEST..TREQJOB
					 WHERE LAUNCH_D = Null
 							and REQCOD_CT in ('T','Y')  -- [102]
 							and SITE_CF = @site_cf
 					)
	Begin
		/*****************************************************************************************
		    Extraction des parametres fixes pour tous les inventaires (post omega)
		*******************************************************************************************/
		Declare  @P_Erreur                int,        -- CodeRetour Erreur pour Message Appli
    				 @p_BOOKING_D             char(8),
    				 @p_PSTOMGEN_D            char(8),
    				 @p_ENCONSO_D             char(8),
  					 @P_DateInventaireConso   Char(8),
						 @P_PeriodeConsoAA        numeric(4,0),
						 @P_PeriodeConsoMM        numeric(2,0),
						 @P_DateInventaireService Char(8),
						 @P_PeriodeServiceAA      numeric(4,0),
						 @P_PeriodeServiceMM      numeric(2,0),
						 @P_SuffixeTable          Char(1),
						 @P_EBSPsTomGen_D         char(08),			--[23390]
						 @P_Booking17_D           Char(8),
						 @P_PsTomGen17_D          Char(8),
						 @P_EnConso17_D           Char(8)

		execute PtREQJOB_05
		  @p_CRE_D,@p_site_cf,
		  @P_Booking_D             output,     -- Date de Booking T-1
		  @P_PsTomGen_D            output,     -- Date de Fin de Saisie Post Omega Social (Periode T)
		  @P_EnConso_D             output,     -- Date de Fin de Saisie Ecritures Conso (Periode T)
		  @P_DateInventaireConso   output,     -- Periode AAAAMM Pour Saisie Ecriture Conso & Social (Periode T-1)
		  @P_PeriodeConsoAA        output,     -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
		  @P_PeriodeConsoMM        output,     -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
		  @P_DateInventaireService output,     -- Periode AAAAMM Pour Saisie Ecriture Services (Periode T)
		  @P_PeriodeServiceAA      output,     -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
		  @P_PeriodeServiceMM      output,     -- Periode MM Pour Saisie Ecriture Services (Periode T)
		  @P_SuffixeTable          output,
		  @P_Erreur                output,     -- CodeRetour Erreur pour Message Appli
		  @P_EBSPsTomGen_D         output,      -- Date de Fin de Saisie Post Omega Social (Periode T)	-- [23390]
		  @P_Booking17_D	       output,       
		  @P_PsTomGen17_D          output,
		  @P_EnConso17_D           output

		select @erreur= @@error
		if @erreur != 0
		begin
		   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
		   return @erreur
		end

	  if (@P_SuffixeTable != '0')
		Begin
--	MOD002			select @p_BLCSHTYEA_NF = @P_PeriodeConsoAA
--	MOD002			select @p_BLCSHTMTH_NF = @P_PeriodeConsoMM
--				      select @p_SPCEND_D = @P_EnConso_D
				select @p_ACCOUNT_D = @P_Booking_D
				Select @CLODAT_D = @P_DateInventaireConso
		End
--------------------------------------------------------------------
print '==> Execution PtREQJOB_05'
print '==> @p_ACCOUNT_D = %1! - @CLODAT_D = %2!', @p_ACCOUNT_D, @CLODAT_D
--------------------------------------------------------------------
END

/**********************************************************************************************
	LIBELLE INVENTAIRE :
	remplacer la premier jour du mois par le dernier jour du mŠme mois pour
   	obtenir le vrai lib‰ll‰ d inventaire principal
***********************************************************************************************/
select @CLODAT0    = convert(char(6),@BLCSHTYEA_NF*100 +  @BLCSHTMTH_NF) + '01'
select @p_CLODAT_D = convert(char(8),dateadd(dd,-1,dateadd(mm,1,@CLODAT0)),112)

--------------------------------------------------------------------
print '==> Apres PtREQJOB_05'
print '==> @CLODAT0 = %1! - @p_CLODAT_D = %2! - @CLODAT_D = %3!', @CLODAT0, @p_CLODAT_D, @CLODAT_D
print '==> @site_cf = %1! - @P_PsTomGen_D = %2! - @P_EBSPsTomGen_D = %3!', @site_cf, @P_PsTomGen_D, @P_EBSPsTomGen_D
--------------------------------------------------------------------

select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification*/
   return @erreur
end


/**********************************************************************************************
	Recherche si en p‰riode de service
***********************************************************************************************/


select @p_PERTYP_CT = "H"
select @p_DBCLO_D   = convert(char(8),@p_CRE_D,112)

if @p_DBCLO_D > @p_SPCEND_D
begin
	select @p_PERTYP_CT = "S"
	select @p_DBCLO_D  = @p_SPCEND_D
end

Select @EPOPEOP_EBS = 0

-- Type d'inventaire Post-omega ou Local
Select @EPOPEOP_EBS = 1
From BEST..TREQJOB
Where LAUNCH_D Is Null
  And REQCOD_CT in ('T','Y')  --[102]
  And isnull(VRS_NF,0) >= 0   --[104]
	And SITE_CF = @site_cf


/***********************************************************************************************
 insertion dans la table de travail BTRAV..TESTSSD les filiales qui ont damande des inventaires
************************************************************************************************/
delete BTRAV..TESTSSD

select @nb=count(*) from BTRAV..TESTSSD
--------------------------------------------------------------------
print '==> Count TESTSSD 0: rows = %1!', @nb
--------------------------------------------------------------------

--[103]
--Comparaison dates DBCLO_D et CRE_D au même format
/*
If Exists (Select 1 FROM BEST..TREQJOB
					 WHERE LAUNCH_D   = Null
 							and REQCOD_CT in ('T','Y')   --[102]
 							and SITE_CF   = @site_cf
 					)
	Begin
		insert into BTRAV..TESTSSD(SSD_CF)
		select distinct ssd_cf
		from BEST..TREQJOB
		where LAUNCH_D is null and reqcod_ct in('I','J','L','Y','T')
		and convert(char(8), DBCLO_D, 112) <= convert(char(8),@p_CRE_D,112)
		and SITE_CF  = @site_cf
--------------------------------------------------------------------
print '==> Insertion TESTSSD 1 : rows = %1!', @@rowcount
--------------------------------------------------------------------
	End
ELSE
	Begin
		insert into BTRAV..TESTSSD(SSD_CF)
		select distinct ssd_cf
		from BEST..TREQJOB
		where CLODAT_D >= @p_CLODAT_D and LAUNCH_D is null and reqcod_ct in('I','J','L')  							
		and convert(char(8), DBCLO_D, 112)    <= convert(char(8),@p_CRE_D,112)
		and SITE_CF = @site_cf
	End
*/

select @erreur = @@error
if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end

--[103]
if @EPOPEOP_EBS = 1 OR 
   Exists (Select 1 FROM BEST..TREQJOB
					 WHERE LAUNCH_D   = Null
 							and REQCOD_CT = 'T'
 							and SITE_CF   = @site_cf)  -- Pour le POSI ou POCI
Begin
	-- Type d'inventaire Post-omega ou Local
   insert into BTRAV..TESTSSD(SSD_CF,VRS_NF)
   SELECT distinct A.SSD_CF, A.VRS_NF
   FROM best..TVERPAR A, BREF..TBATCHSSD S
   where A.SEGTYP_CT = 'A'
   and A.ssd_cf = S.SSD_CF
   and S.BATCHUSER_CF = @suser_Name
   and exists ( SELECT 1 from best..TVERSION B
                where b.SEGTYP_CT = 'A'
                --and b.VRSSTS_CT <> 'AN' and B.VRSLOC_B = 0
                and b.VRSSTS_CT = 'CO' and B.VRSLOC_B = 0
                and b.ssd_cf = A.SSD_CF 
              )
    group by A.ssd_cf
    having   A.PAR_D = max( A.PAR_D )
    union
    --[103]
    select distinct ssd_cf, null
		from BEST..TREQJOB
		where LAUNCH_D is null and reqcod_ct in ('T','Y')
		and convert(char(8), DBCLO_D, 112) <= convert(char(8),@p_CRE_D,112)
		and SITE_CF  = @site_cf
    union 
    select distinct a.ssd_cf, null
    from  bref..tprintb a,
          bref..tsubsid b, 
          BREF..TBATCHSSD S
    where a.ssd_cf = b.ssd_cf
    and A.ssd_cf = S.SSD_CF
    and S.BATCHUSER_CF = @suser_Name
    and not exists ( SELECT 1 from best..TVERSION B
                     where b.SEGTYP_CT = 'A'
                     and b.VRSSTS_CT = 'CO' and B.VRSLOC_B = 0
                     and b.ssd_cf = A.SSD_CF )
    and   a.CRTTYP_CT = 99
    and   a.CRTVAL_LS='ESB_CF'
    order by A.ssd_cf
--------------------------------------------------------------------
print '==> Insertion TESTSSD 1 post-omega local : rows = %1!', @@rowcount
--------------------------------------------------------------------
End
else
Begin
	-- Autre type d'inventaire IFRS
		insert into BTRAV..TESTSSD(SSD_CF)
		select distinct ssd_cf
		from BEST..TREQJOB
		where LAUNCH_D is null and reqcod_ct in('I','J','L')
		and convert(char(8), DBCLO_D, 112) <= convert(char(8),@p_CRE_D,112)
		and SITE_CF  = @site_cf
--------------------------------------------------------------------
print '==> Insertion TESTSSD 2 : rows = %1!', @@rowcount
--------------------------------------------------------------------
End


/***********************************************************************************************
 mise a jour des colonnes BTRAV..TESTSSD indiquant la presence ou non d'un inventaire pour une
 filiale
**********************************************************************************************/

declare cur_clodat cursor for
	/* L'inventaire principal quand il est demand‰ est priotaire */
	select r.CLODAT_D , 1
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	AND    r.LAUNCH_D = NULL
	AND    convert(char(8),r.CLODAT_D,112) = @p_CLODAT_D
  and 	 r.reqcod_ct in ('I','J','L')                                          -- MOD001 - Ajout Demande T
  and    SITE_CF = @site_cf

	UNION

	/* Pour Post-omega en plus duprincipal [101] */
	select r.CLODAT_D , 1
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	AND    r.LAUNCH_D = NULL
	AND    convert(char(8),r.CLODAT_D,112) = @P_DateInventaireConso
  and 	 r.reqcod_ct in ('T')                                          -- MOD001 - Ajout Demande T
  and    SITE_CF = @site_cf

	UNION

	/* Pour Post-omega en plus duprincipal [102] */
	select r.CLODAT_D , 1
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	AND    r.LAUNCH_D = NULL
	AND    convert(char(8),r.CLODAT_D,112) = @P_DateInventaireConso
  and 	 r.reqcod_ct in ('Y')
  and    SITE_CF = @site_cf

	UNION

	/* L'inventaire semestriel quand il est demand‰ a une priotaire  2 */
	select r.CLODAT_D , 2
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	AND    r.LAUNCH_D = NULL
	AND    r.CLODAT_D > @p_CLODAT_D
  and 	 r.reqcod_ct in ('I','J','L','T','Y')     -- [102]                                    -- MOD001 - Ajout Demande T
	AND    substring(convert(char(8),r.CLODAT_D,112),5,2) = "06"
  and    SITE_CF = @site_cf

	UNION

	/* L'inventaire annuel quand il est demand‰ a une priotaire  3 */
	select r.CLODAT_D , 3
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	AND    r.LAUNCH_D = NULL
	AND    r.CLODAT_D > @p_CLODAT_D
  and 	 r.reqcod_ct in ('I','J','L','T','Y')     -- [102]                                          -- MOD001 - Ajout Demande T
	AND    substring(convert(char(8),r.CLODAT_D,112),5,2) = "12"
  and    SITE_CF = @site_cf

	UNION

	/* Les autres inventaires ont une une priotaire  4 */
	select r.CLODAT_D , 4
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	AND    r.LAUNCH_D = NULL
	AND    r.CLODAT_D > @p_CLODAT_D
  and 	 r.reqcod_ct in ('I','J','L','T','Y')     -- [102]                                       -- MOD001 - Ajout Demande T
	AND    substring(convert(char(8),r.CLODAT_D,112),5,2) not in ("06", "12" )
  and    SITE_CF = @site_cf
	order  by 2, 1


OPEN cur_clodat

/* top pour les filiales ayant demand‰es le 1er inventaire */
fetch cur_clodat into @CLODAT_D, @var
begin
	update BTRAV..TESTSSD
	set	   s.CLODAT1_D = @CLODAT_D, s.CLOPER1_LS = CLOPER_LS,
	         s.CLODAT2_D = @CLODAT_D, s.CLOPER2_LS = CLOPER_LS,   -- [101] Permet de dupliquer Parm1 sur parm2
	         s.CLODAT3_D = @CLODAT_D, s.CLOPER3_LS = CLOPER_LS    -- [102] Permet de dupliquer Parm1 sur parm3
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	  AND	 r.CLODAT_D = @CLODAT_D
    and  SITE_CF = @site_cf
--------------------------------------------------------------------
print '==> Update TESTSSD 1 : @CLODAT_D = %1! - rows = %2!', @CLODAT_D, @@rowcount
--------------------------------------------------------------------
end

/* top pour les fililales ayant demand‰es le 2eme inventaire */
if (@@sqlstatus = 0  ) fetch cur_clodat into @CLODAT_D, @var
if (@@sqlstatus = 0  )
begin
	update BTRAV..TESTSSD
	set	 s.CLODAT2_D = @CLODAT_D, s.CLOPER2_LS = CLOPER_LS
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	AND	   r.CLODAT_D = @CLODAT_D
	and    r.LAUNCH_D = NULL
  and    r.reqcod_ct in ('I','J','L', 'T','Y')                                      -- MOD001 - Ajout Demande T [102]
  and    SITE_CF = @site_cf
--------------------------------------------------------------------
print '==> Update TESTSSD 2 : @CLODAT_D = %1! - rows = %2!', @CLODAT_D, @@rowcount
--------------------------------------------------------------------
end

/* top pour les filiales ayant demand‰es le 3eme inventaire */
if (@@sqlstatus = 0  ) fetch cur_clodat into @CLODAT_D, @var
if (@@sqlstatus = 0  )
begin
	update BTRAV..TESTSSD
	set	 s.CLODAT3_D = @CLODAT_D, s.CLOPER3_LS = CLOPER_LS
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	  AND	 r.CLODAT_D= @CLODAT_D
	  and  r.LAUNCH_D = NULL
    and  r.reqcod_ct in ('I','J','L', 'T','Y')                                      -- MOD001 - Ajout Demande T [102]
    and  SITE_CF = @site_cf
--------------------------------------------------------------------
print '==> Update TESTSSD 3 : @CLODAT_D = %1! - rows = %2!', @CLODAT_D, @@rowcount
--------------------------------------------------------------------
end

/* top pour les filiales ayant demand‰es le 4eme inventaire */
if (@@sqlstatus = 0  ) fetch cur_clodat into @CLODAT_D, @var
if (@@sqlstatus = 0  )
begin
	update BTRAV..TESTSSD
	set	 s.CLODAT4_D = @CLODAT_D, s.CLOPER4_LS = CLOPER_LS
	from   BTRAV..TESTSSD s, BEST..TREQJOB r
	where  s.SSD_CF = r.SSD_CF
	  AND	 r.CLODAT_D = @CLODAT_D
	 and 	 r.LAUNCH_D = NULL
   and 	 r.reqcod_ct in ('I','J','L', 'T','Y')                                      -- MOD001 - Ajout Demande T [102]
   and   SITE_CF = @site_cf
--------------------------------------------------------------------
print '==> Update TESTSSD 4 : @CLODAT_D = %1! - rows = %2!', @CLODAT_D, @@rowcount
--------------------------------------------------------------------
end

/* top pour les fililales ayant demand‰es un inventaire principale*/
update BTRAV..TESTSSD
set	 s.CLOTYP_B = 1
from   BTRAV..TESTSSD s, BEST..TREQJOB r
where  s.SSD_CF = r.SSD_CF
AND	   convert(char(8),r.CLODAT_D,112) = 	@p_CLODAT_D
and 	 r.LAUNCH_D = NULL
and 	 r.reqcod_ct in ('I','J','L', 'T','Y')                                      -- MOD001 - Ajout Demande T [102]
and    SITE_CF = @site_cf
--------------------------------------------------------------------
print '==> Update TESTSSD 5 : @CLODAT_D = %1! - rows = %2!', @CLODAT_D, @@rowcount
--------------------------------------------------------------------

select @nb=count(*) from BTRAV..TESTSSD
--------------------------------------------------------------------
print '==> Count TESTSSD 2: rows = %1!', @nb
--------------------------------------------------------------------


CLOSE cur_clodat

deallocate cursor cur_clodat



/**********************************************************************************************
mise € jour version active : issu de TREQJOB
**********************************************************************************************/

update BTRAV..TESTSSD
set   s.VRS_NF = r.VRS_NF
from  BTRAV..TESTSSD s, best..TREQJOB r
where r.SSD_CF  = s.SSD_CF
and   r.LAUNCH_D = null
and   r.CLODAT_D = s.CLODAT4_D
and   r.reqcod_ct in ('I','J','L', 'T','Y')                                      -- MOD001 - Ajout Demande T [102]
and   SITE_CF = @site_cf

select @erreur = @@error
--------------------------------------------------------------------
print '==> Update TESTSSD VRS_NF 1 : rows = %1!', @@rowcount
--------------------------------------------------------------------

if @erreur!= 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


update BTRAV..TESTSSD
set s.VRS_NF = r.VRS_NF
from  BTRAV..TESTSSD s, best..TREQJOB r
where r.SSD_CF  = s.SSD_CF
and r.LAUNCH_D = null
and r.CLODAT_D = s.CLODAT3_D
and 	 r.reqcod_ct in ('I','J','L', 'T','Y')                                      -- MOD001 - Ajout Demande T [102]
and SITE_CF = @site_cf

select @erreur = @@error
--------------------------------------------------------------------
print '==> Update TESTSSD VRS_NF 2 : rows = %1!', @@rowcount
--------------------------------------------------------------------

if @erreur!= 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


update BTRAV..TESTSSD
set s.VRS_NF = r.VRS_NF
from  BTRAV..TESTSSD s, best..TREQJOB r
where r.SSD_CF  = s.SSD_CF
and r.LAUNCH_D = null
and r.CLODAT_D = s.CLODAT2_D
and 	 r.reqcod_ct in ('I','J','L', 'T','Y')                                      -- MOD001 - Ajout Demande T [102]
and SITE_CF = @site_cf

select @erreur = @@error
--------------------------------------------------------------------
print '==> Update TESTSSD VRS_NF 3 : rows = %1!', @@rowcount
--------------------------------------------------------------------

if @erreur!= 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


update BTRAV..TESTSSD
set s.VRS_NF = r.VRS_NF
from  BTRAV..TESTSSD s, best..TREQJOB r
where r.SSD_CF  = s.SSD_CF
and r.LAUNCH_D = null
and r.CLODAT_D = s.CLODAT1_D
and 	 r.reqcod_ct in ('I','J','L', 'T','Y')                                      -- MOD001 - Ajout Demande T [102]
and SITE_CF = @site_cf

select @erreur = @@error
--------------------------------------------------------------------
print '==> Update TESTSSD VRS_NF 4 : rows = %1!', @@rowcount
--------------------------------------------------------------------

if @erreur!= 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end


if @EPOPEOP_EBS <> 1
begin
   update BTRAV..TESTSSD
      set s.VRS_NF = r.VRS_NF
   from  BTRAV..TESTSSD s, best..TREQJOB r
   where r.SSD_CF  =* s.SSD_CF
   and   r.LAUNCH_D = null
   and   r.CLODAT_D =* s.CLODAT1_D
   and   r.reqcod_ct in ('I','J','L', 'T')                                      -- MOD001 - Ajout Demande T
   and   r.VRS_NF is not null
   and SITE_CF = @site_cf
   select @erreur = @@error
End 
if @erreur!= 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end

/***********************************************************************************************
 s‰lection de l'inventaire maximal demandé
***********************************************************************************************/
/*  [004]
select
	@p_CLODATMAX_D = convert(char(8),max(CLODAT_D),112)
from TREQJOB
where CLODAT_D >= @p_CLODAT_D and LAUNCH_D is null and reqcod_ct in ('I','J','L', 'T')          -- Ajout Demande Type T
and SITE_CF = @site_cf
*/
-- [004]
select
	@p_CLODATMAX_D = convert(char(8),max(CLODAT_D),112)
from  BEST..TREQJOBPLAN
where CLODAT_D >= @p_CLODAT_D
and   BALSHTMTH_NF = @p_BLCSHTMTH_NF
and   LAUNCH_D is null
and   reqcod_ct in ('I','J','L','D','E','T','Y')  -- [005] [102]
and   SITE_CF = @site_cf
--------------------------------------------------------------------
print '==> @p_CLODATMAX_D 1 = %1!', @p_CLODATMAX_D
--------------------------------------------------------------------

-- [006]
if @p_CLODATMAX_D = null
Begin
   select
   @p_CLODATMAX_D = convert(char(8),max(CLODAT_D),112)
  from BEST..TREQJOB
   where CLODAT_D >= @p_CLODAT_D and LAUNCH_D is null and reqcod_ct in ('I','J','L', 'T','Y')          -- Ajout Demande Type T [102]
  and SITE_CF = @site_cf
END  
--------------------------------------------------------------------
print '==> @p_CLODATMAX_D 2 = %1!', @p_CLODATMAX_D
--------------------------------------------------------------------

select @nb=count(*) from BTRAV..TESTSSD
--------------------------------------------------------------------
print '==> Count TESTSSD 3: rows = %1!', @nb
--------------------------------------------------------------------


select @erreur = @@error

if @erreur != 0
begin
   raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
   return @erreur
end



return 0
go
EXEC sp_procxmode 'dbo.PsREQJOB_03', 'unchained'
go
IF OBJECT_ID('dbo.PsREQJOB_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsREQJOB_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsREQJOB_03 >>>'
go
GRANT EXECUTE ON dbo.PsREQJOB_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_03 TO GDBBATCH
go
