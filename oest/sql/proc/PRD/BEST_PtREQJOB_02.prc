USE BEST
go
IF OBJECT_ID('dbo.PtREQJOB_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtREQJOB_02
    IF OBJECT_ID('dbo.PtREQJOB_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtREQJOB_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtREQJOB_02 >>>'
END
go
/* Adaptive Server has expanded all '*' elements in the following statement */ 
-- creation de la procedure
create procedure dbo.PtREQJOB_02 (
     @p_date_t UUPD_D
)

as
/***************************************************
Programme: PtREQJOB_02
Fichier script associé :
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: O. Arik
Date de creation: 30/07/2002
Description du programme:Dispatch des demandes D,A,L en I,J,A,L et ajout des informations segmentation et ajouts eventuels de demandes
    -    Sélection des filiales à traiter (celles présentes dans les paramètres).
    -    Contrôle de non existence d'une demande dans TREQJOB pour cet inventaire et cette filiale
    -    Création de la demande si elle n'existe pas
Parametres:
    - Date de traitement
    - Libellé d'inventaire
    - Liste des filiales
_________________
MODIFICATION 1
Auteur: HV
Date: 21/03/2003
Version:
Description: Correction sur la recherche du n° de version qui n'était pas bon
_________________
MODIFICATION 2
Auteur: M. DJELLOULI
Date: 09/06/2004
Version:
Description: MOD02 - Fiche SPOT 10505 - Suppression Demande Inventaire en Double
_________________
MODIFICATION 3
Auteur: M. DJELLOULI
Date: 28/06/2004
Version:
Description: MOD03 - Fiche SPOT 10505 - Modifiée

                     ------------- Additionnal comment by Helene VALCKE ------------- 28 JUN 2004 16:20
                     Si CRE_D >= ACCOUNT_D et CLOSING_B = 1,
                     on ne génère pas de demande pour les filiales pour lesquelles il existe dans TREQJOB un enregistrement
                     ayant la même CLODAT et REQCOD_CT = "C".
                     Soit on ne génère pas au fur et à mesure du traitement, soit on delete en fin de proc. Le plus simple.

                     ------------- Additionnal comment by Helene VALCKE ------------- 28 JUN 2004 16:21
                     Correction modification du 28/06 :
                     On le fait si CLOSING_B = 1 et CRE_D < ACCOUNT_D

                     ------------- Additionnal comment by Helene VALCKE ------------- 29 JUN 2004 16:29
                     Nouveau controle sur version :
                     Lorsqu'une demande d'inventaire est faite on va chercher la version de segmentation valide.
                     La recherche doit prendre en compte le status de la version : VRSSTS_CT = '' et VRSLOC_B = 0.
_________________
MODIFICATION 4
Auteur: M. DJELLOULI
Date: 16/09/2004
Version:
Description: MOD04 - Modification BUG - SELECTion de Version pour TREQJOB
_________________
MODIFICATION 5
Auteur: M. DJELLOULI
Date: 01/02/2005
Version:
Description: MOD05 - Déplacement les Suppressions du BLOC MOD02 en Fin de PROC
_________________
MODIFICATION 6
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
_________________
MODIFICATION 7
12/09/2008  JF. VDE SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 à 64 caractères
_________________
MODIFICATION 8
18/09/2009  JF. VDV [12363]: Remaniment de la gestion des demandes d'inventaire + lancement de la compta des RGLTS
10/02/2010  D.GATIBELZA[12363]:     [008] le compteur a_traiter doit être recalculé une deuxième fois.
23/02/2010  JF. VDV [12363]: mise en commentaire du controle sur la date de comptabilisation des réglements
_________________
MODIFICATION    [009]
Auteur         : D.GATIBELZA
Date           : 21/05/2010
Version        : 10.1
Description    : ESTDOM12363 Revoir le mécanisme de lancement de la comptabilisation des réglements, de lancement des inventaires
_________________
MODIFICATION    [010]
Auteur         : JF-VDV
Date           : 13/09/2010
Version        : 10.1
Description    : [12363] - Actualisation de la demande 'V' et calcul du dernier jour du mois
                         - DOM: Ajout initialisation @FinMoisCivil
_________________
MODIFICATION    [011]
Auteur         : D.GATIBELZA
Date           : 05/10/2010
Version        : 10.1
Description    : ESTDOM19070 V10 scheduler pour le lancement des inventaires
[012]  07/05/2012  R. CASSIS     :spot:23802 - Ajout option E pour Solvency
[013]  23/03/2013  P. PEZOUT     :spot:25006 - MODIF DES DEMANDES EXISTANTES POUR NE PAS TOMBER EN DUPLICATE KEY
[100]  30/09/2013  P. Pezout     :spot:25427 - Modifications pour omega2 -1b sur treqjob et treqjobplan
[014]  13/05/2014  P. Pezout     :spot:26741 - Demande A et demande D end meme temps ne geneerent plus de violation de DUPLICATE KEY
[015]  11/07/2014  R. Cassis     :spot:27176 - Add trace messages and suppress not null for temp table
[016]  16/01/2015  M. Estrade    :spotXXXXX - modification pour gestion plan A, alimentation star_d  + end_d + cloper_ls
[017]  11/02/2016  R. Cassis     :spot:30163 - Avant insertion dans treqjob, on supprime les records si existent sur même date dbclo
[018]  04/08/2017  R. Cassis     :spira:61508 Gestion plan2 pour le Post-omega des ES locales
*****************************************************/
declare   @erreur         int,
            @tran_imbr     bit,
            @pos_SSD_CF     int ,
            @A_traiter      int ,
            @SSD_CF             varchar(20),
            @blcshtyea_nf   int,            -- année de la période comptable en cours
            @blcshtmth_nf   tinyint,        -- mois de la période comptable en cours
            @specend_d      datetime,       -- variable de travail
            @p_clodat       datetime,
            @ssds_cf        varchar(64),    -- [SPOT15758] vde
            @ID_NF          numeric(15),
            @VRS_NF         numeric(10),
            @reqcod_ct      char(1),
            @end_d          datetime, --[016]
            @balshtmth_nf tinyint --[016]
        
declare   @v_closing_b    bit,             -- MOD02
            @v_account_d    datetime,        -- MOD02
            @fil_01         char(64),
            @lenssd         int ,
            @pos_fil_01     int ,
            @Dem_DIJLA      int,
            @clodat_v       datetime

DECLARE                               -- [12363] 13/09/2010
        @dateformat     char(08),
        @lastday        char(02),
        @dateofFeb       datetime,
        @dayname        char(10),
        @FinMoisCivil   datetime
--[015]
declare @lines int

SELECT @erreur = 0
SELECT @tran_imbr = 1

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name =   suser_Name()

Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

if @erreur != 0
     begin
         raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
     end

-- ------------------------------------------------------------------------------
-- Sélection de la période comptable sur laquelle on est en fonction de DATE_T
-- Sélection de la date d'arrété DBCLO_D
-- ------------------------------------------------------------------------------
SELECT @blcshtyea_nf = a.blcshtyea_nf,
           @blcshtmth_nf = a.blcshtmth_nf,
           @specend_d    = a.specend_d,
           @v_closing_b  = a.closing_b,
           @v_account_d  = a.account_d
from bref..TCALEND a
where ( (a.blcshtyea_nf * 100) + a.blcshtmth_nf ) = ( SELECT min( (b.blcshtyea_nf * 100) + b.blcshtmth_nf)
                                                      from BREF..TCALEND b
                                                      where convert( Char(10),b.account_d,112) >= convert(Char(10),@p_date_t,112) )
--[015]
select @erreur=@@error, @lines=@@rowcount
print 'Processed lines 1 : %1!',@lines
if @erreur != 0  goto fin


-- Identifcation de présence de demande d'inventaire en cours de type D,I,J ou L,[009] ou 'A'
-- ================================================================================
SELECT @Dem_DIJLA = count(*)
from best..TREQJOB
where reqcod_ct in ('D','E','I','J','L', 'A')  -- [012]
--[009] and cloper_ls is not null
  and LAUNCH_D  = NULL
  and SITE_CF = @site_cf

--[015]
select @erreur=@@error, @lines=@@rowcount
print 'Processed lines 2 : %1!',@lines
if @erreur != 0  goto fin

-- si comptabilisation mensuelle et présence de demandes d'inventaire D,I,J,L,[009] ou 'A'
-- alors suppression de ces demandes
-- ===========================================================
If @p_date_t = @v_account_d and @v_closing_b = 0 and @Dem_DIJLA > 0
Begin
    PRINT 'decalage et topage des demandes si comptabilisation mensuelle:'
    SELECT best..TREQJOB.SSD_CF,
                best..TREQJOB.BALSHEYEA_NF,
                best..TREQJOB.BALSHTMTH_NF,
                best..TREQJOB.CLODAT_D,
                best..TREQJOB.REQCOD_CT,
                best..TREQJOB.CRE_D,
                best..TREQJOB.DBCLO_D,
                best..TREQJOB.LAUNCH_D,
                best..TREQJOB.CLOPER_LS,
                best..TREQJOB.VRS_NF,
                best..TREQJOB.UPDUSR_CF,
                best..TREQJOB.SITE_CF,
                best..TREQJOB.ID_NF 
    FROM best..TREQJOB
    where reqcod_ct in ('D','E','I','J','L','A')  -- [012]
      and LAUNCH_D = NULL
      and SITE_CF = @site_cf

    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 3 : %1!',@lines
    if @erreur != 0  goto fin

    --[011] Finalement, je toppe simplement la demande
    update best..TREQJOB
       set --[011]CRE_D    = dateadd(day, 1, CRE_D),
           --[011]DBCLO_D  = dateadd(day, 1, DBCLO_D),
           LAUNCH_D = getdate()
    where reqcod_ct in ('D','E','I','J','L','A')  -- [012]
      and LAUNCH_D = NULL
      and SITE_CF  = @site_cf
      
      
    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 4 : %1!',@lines
    if @erreur != 0  goto fin

    --[011] Mise à jour aussi de TREQJOBPLAN
    update best..TREQJOBPLAN
       set LAUNCH_D = getdate(),
           END_D    = getdate()
    where reqcod_ct in ('D','E','I','J','L','A')  -- [012]
      and LAUNCH_D = NULL
      and DBCLO_D <= @p_date_t
      and SITE_CF  = @site_cf

    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 5 : %1!',@lines
    if @erreur != 0  goto fin
    
    select @Dem_DIJLA=0
End


-- Recherche si présence d'une demande groupée d'inventaire     (@A_traiter # 0)
-- =========================================================
SELECT @A_traiter = count(*)
from best..TREQJOB
where reqcod_ct in ('D','E','A')  -- [012]
  and cloper_ls is not null
  and LAUNCH_D  = NULL
  and SITE_CF   = @site_cf
  
--[015]
select @erreur=@@error, @lines=@@rowcount
print 'Processed lines 6 : %1!',@lines
if @erreur != 0  goto fin


-- si comptabilisation trimestriel ou dernier run avant compta, et aucune demande de type 'D','E' en cours
-- alors création d'une demande 'D','E' avec cloper_ls = '*'
-- ===========================================================

If (@p_date_t = @v_account_d or @p_date_t = @specend_d) and @v_closing_b = 1 and @A_traiter = 0
begin
    INSERT into best..TREQJOB ( ssd_cf,
                                balsheyea_nf,
                                balshtmth_nf,
                                clodat_d,
                                reqcod_ct,
                                cre_d,
                                dbclo_d,
                                launch_d,
                                cloper_ls,
                                vrs_nf,
                                updusr_cf,
                                SITE_CF
                              )
    SELECT 3,          -- ssd_cf,(3 par défaut)
           @blcshtyea_nf,
           @blcshtmth_nf,
           case when @blcshtmth_nf in (1,2,3)    then convert(char(04),@blcshtyea_nf) + '0331'
                when @blcshtmth_nf in (4,5,6)    then convert(char(04),@blcshtyea_nf) + '0630'
                when @blcshtmth_nf in (7,8,9)    then convert(char(04),@blcshtyea_nf) + '0930'
                when @blcshtmth_nf in (10,11,12) then convert(char(04),@blcshtyea_nf) + '1231'
           end,          -- clodat_d,
           'D' ,         -- reqcod_ct
           getdate(),    -- cre_d
           @p_date_t,    -- dbclo_d
           NULL,         -- launch_d
           '*',          -- cloper_ls
           NULL,         -- vrs_nf
           updusr_cf = 'iclo',
           @site_cf

   --[015]
   select @erreur=@@error, @lines=@@rowcount
   print 'Processed lines 7 : %1!',@lines
   if @erreur != 0  goto fin

end


--[008]
-- Recherche si présence d'une demande groupée d'inventaire     (@A_traiter # 0)
-- =========================================================
SELECT @A_traiter = count(*)
from best..TREQJOB
where reqcod_ct in ('D','E','A')  -- [012] [016]
  and cloper_ls is not null
  and LAUNCH_D  = NULL
  and SITE_CF   = @site_cf

--select @@serverName, "PEZOUT5b", @suser_Name, @erreur

--[015]
select @erreur=@@error, @lines=@@rowcount
print 'Processed lines 8 : %1!',@lines
if @erreur != 0  goto fin

-- Pour une demande de type 'D','E' avec cloper_ls égale à '*'
-- on récupère la liste des filiales sur la dernière demande 'B' pour la filiale ssd_cf = 99
-- dans cette chaine, on remplace les '_' par des ',' et on supprime les 2 premiers et le dernier caractère
-- exemple: A_1_2_3_8_17,23_ ==> 1,2,3,8,17,23
-- ========================================================================================================
Select @fil_01    = ""

Declare cur_ssd Cursor For Select convert(varChar,SSD_CF)
                           From BREF..TBATCHSSD WHERE BATCHUSER_CF = @suser_Name
                           Order By SSD_CF
Open cur_ssd

Fetch cur_ssd Into  @SSD_CF
select @fil_01 = rtrim(@SSD_CF)
Fetch cur_ssd Into  @SSD_CF
While (@@sqlstatus = 0)
Begin
     Select @fil_01 = rtrim(@fil_01) + "," + rtrim(@SSD_CF)
Fetch cur_ssd Into  @SSD_CF
End
Close cur_ssd
Deallocate Cursor cur_ssd

--select @@serverName, "PEZOUT6", @suser_Name, @fil_01, @SSD_CF

--select @lenssd = len (rtrim(@fil_01))
--select @fil_01 = substring(@fil_01,1,@lenssd-1)
--select @lenssd = @lenssd -1

/*
SELECT  @fil_01  = CLOPER_LS
from best..TREQJOB
where ssd_cf = 99
  and cloper_ls is not null
  and reqcod_ct = 'B'
  and SITE_CF = @site_cf
group by ssd_cf
having clodat_d = max( clodat_D ) and reqcod_ct = 'B'
order by ssd_cf


-- Mise en forme du nouveau contenu de cloper_ls
-- nouvelle longueur de la chaine après suppression des caractères (2 premiers + dernier)
select @lenssd = len (rtrim(@fil_01))
select @fil_01 = substring(@fil_01,3,@lenssd-3)
select @lenssd = @lenssd -3


-- retourne le rang du premier caractère '_' de la chaine
-- ======================================================
SELECT  @pos_fil_01 = charindex('_',@fil_01)

while @pos_fil_01 < @lenssd
BEGIN
    If  substring(@fil_01,@pos_fil_01,1) = '_'
    begin
        SELECT @fil_01 = substring(@fil_01,1,@pos_fil_01-1) + ','+ substring(@fil_01,@pos_fil_01+1, (@lenssd - (@pos_fil_01 - 1)))
    end

    SELECT @pos_fil_01 = @pos_fil_01 + 1
END
*/

-- MAJ de la liste des filiales
-- ===============================
UPDATE best..TREQJOB
   SET cloper_ls = @fil_01
WHERE reqcod_ct in ('D','E','A','L')  -- [012]
  and LAUNCH_D = NULL
  and cloper_ls like '%*%'
  and SITE_CF = @site_cf

--[015]
select @erreur=@@error, @lines=@@rowcount
print 'Processed lines 9 : %1!',@lines
if @erreur != 0  goto fin

select @@serverName, @suser_Name, @A_traiter

Print
    select @@serverName, @suser_Name, @A_traiter
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
if @A_traiter >= 1
BEGIN
    PRINT '*** Début de ''A TRAITER'' Demande inventaire ***'
    -- stockage de la date de cloture
    -- stockage de la liste des filiales concernées par la demande d'un inventaire groupée
    -- ===================================================================================
--[015]
    CREATE TABLE #TLSTSSD  ( SSD_CF USSD_CF         NOT NULL, 
                                            reqcod_ct char(1) not null,
                                            VRS_NF numeric(10,0)   NULL,
                                            end_d datetime null,
                                            balshtmth_nf tinyint  ) -- [016]
    CREATE TABLE #TSSDVRS  ( SSD_CF USSD_CF         NOT NULL,
                                            VRS_NF numeric(10,0)   NULL  )

    -- Table de stockage pour la sélection des versions
    -- ================================================
    CREATE TABLE #TMAXVER  ( SSD_CF USSD_CF         NOT NULL,
                             VRS_NF numeric(10,0)   NOT NULL  )

   DECLARE curs_ctr CURSOR FOR
    SELECT clodat_d,
               CLOPER_LS,
               reqcod_ct,
               ID_NF,
               VRS_NF,
               end_d,  --[016]
               balshtmth_nf  --[016]
    from best..TREQJOB
    where reqcod_ct in ('D','E','A','L')  -- [012]
      and cloper_ls is not null
      and LAUNCH_D  = NULL
      and SITE_CF   = @site_cf
      order by reqcod_ct


OPEN curs_ctr
PRINT '** Lecture initiale **'

FETCH  curs_ctr
INTO @p_clodat, @ssds_cf, @reqcod_ct, @ID_NF, @VRS_NF, @end_d, @balshtmth_nf --[016]

-------------------------------------------------------------------------------------
-- [017] debut
-- S'il existe des enregistrements REQJOB de même date de la planification en cours et
-- validés, on les supprime pour éviter les duplicate.
-------------------------------------------------------------------------------------

-- 1 . Traitement demande D
delete best..treqjob
from best..treqjob a
--Where a.CRE_D = @p_date_t 
Where a.DBCLO_D = @p_date_t  --[018]
and   a.LAUNCH_D is not null  -- ancienne demande
and   a.REQCOD_CT in ('D','I','J')
and   a.SITE_CF = @site_cf
and exists (select * from best..treqjobplan b
            where a.CRE_D = b.DBCLO_D
            and   b.LAUNCH_D is null  -- nouvelle demande
            and   b.REQCOD_CT in ('D')
            and   a.BALSHEYEA_NF = b.BALSHEYEA_NF
            and   a.BALSHTMTH_NF = b.BALSHTMTH_NF
            and   a.SITE_CF = b.SITE_CF)

select @erreur=@@error, @lines=@@rowcount
print 'Processed lines 9a delete into treqjob D : %1!',@lines
if @erreur != 0  goto fin

-- 1 . Traitement demande T
delete best..treqjob
from best..treqjob a
--Where a.CRE_D = @p_date_t 
Where a.DBCLO_D = @p_date_t  --[018]
and   a.LAUNCH_D is not null  -- ancienne demande
and   a.REQCOD_CT in ('T','Y')  -- [018]
and   a.SITE_CF = @site_cf
and exists (select * from best..treqjobplan b
            where a.DBCLO_D = b.DBCLO_D
            and   b.LAUNCH_D is null  -- nouvelle demande
            and   b.REQCOD_CT in ('T','Y')
            and   a.BALSHEYEA_NF = b.BALSHEYEA_NF
            and   a.BALSHTMTH_NF = b.BALSHTMTH_NF
            and   a.SITE_CF = b.SITE_CF)

select @erreur=@@error, @lines=@@rowcount
print 'Processed lines 9b delete into treqjob T : %1!',@lines
if @erreur != 0  goto fin

-- 3 . Traitement I,J
delete best..treqjob
from best..treqjob a
--Where a.CRE_D = @p_date_t
Where a.DBCLO_D = @p_date_t  --[018]
and   a.LAUNCH_D is null  -- si relance ESCJ0000
and   a.REQCOD_CT in ('I','J')
and   a.BALSHEYEA_NF = @blcshtyea_nf 
and   a.BALSHTMTH_NF = @blcshtmth_nf 
and   a.SITE_CF = @site_cf

select @erreur=@@error, @lines=@@rowcount
print 'Processed lines 9c delete into treqjob I-J : %1!',@lines
if @erreur != 0  goto fin

-------------------------------------------------------------------------------------
-- [017] fin
-------------------------------------------------------------------------------------

WHILE (@@sqlstatus = 0)
BEGIN
    -- concaténe un ',' à la fin de la chaine
    -- =======================================
    SELECT @ssds_cf = RTRIM(@ssds_cf) + ','

    -- ------------------------------------------------------------
    --   Début de la transaction
    -- --------------------------------------------------------------

    -- retourne la valeur du premier ',' de la chaine
    -- ==============================================
    SELECT  @pos_SSD_CF = charindex(',',@ssds_cf)
    if @@trancount = 0
    begin
        SELECT @tran_imbr = 0
        BEGIN TRAN
    end

    -- Boucle sur les filiales contenues dans la chaine de caractère
    -- ==============================================================
    while @pos_SSD_CF > 1
    BEGIN
        SELECT @SSD_CF  = substring(@ssds_cf,1,@pos_SSD_CF - 1)
        SELECT @ssds_cf = substring(@ssds_cf,@pos_SSD_CF +1,1000)
        
        
        
        PRINT
        SELECT @reqcod_ct

        -- controle de l'existance de cette filiale dans bref..TSUBSID
        -- ===========================================================
        if exists (SELECT null from bref..TSUBSID where ssd_cf=convert( smallint,@SSD_CF))
        and exists (SELECT null from bref..TBATCHSSD where ssd_cf=convert( smallint,@SSD_CF) and BATCHUSER_CF=@suser_Name)
            INSERT into #TLSTSSD values ( convert( smallint,@SSD_CF),
                                                        @reqcod_ct,
                                                        @VRS_NF,
                                                        @end_d, -- [016]
                                                        @balshtmth_nf ) -- [016] 
        else
        begin
            SELECT 'Anomalie : La filiale ',@SSD_CF,' inséré dans treqjob n''existe pas dans tsubsid ou dans bref..TBATCHSSD pour la login ',@suser_Name,' active '
            SELECT 'Cette filiale ne sera pas traitée'
        end

        SELECT  @pos_SSD_CF=charindex(',',@ssds_cf)
    END
    -- Fin de la boucle sur filiales

    --------------------------
    PRINT 'liste des filiales données en paramètre ***'
    SELECT 
       '#TLSTSSD',
       SSD_CF, 
       REQCOD_CT,
       VRS_NF,
       END_D,
       BALSHTMTH_NF
    FROM 
       #TLSTSSD
    --------------------------

    -- Création d'une demande d'inventaire pour chacune des filiales
    -- MAJ du type de la demande reqcod-ct = 'I' si filiale 2, sinon = 'J'
    -- ======================================================================
    -- [013] modif des demandes existantes
    /* ??
         UPDATE best..TREQJOB SET cre_d=getdate()
         where balsheyea_nf=@blcshtyea_nf and @blcshtmth_nf=balshtmth_nf
         and clodat_d=@p_clodat and reqcod_ct = case when SSD_CF != 2 then 'I' else 'J' end
         and cre_d=@p_date_t
    */


    --------------------------
    --[017]
    PRINT 'liste de ce qui va etre insere dans Treqjob ***'
    SELECT a.ssd_cf,
           @blcshtyea_nf,
           @blcshtmth_nf,
           clodat_d = @p_clodat,
           reqcod_ct = case when a.reqcod_ct = "D" then case when a.SSD_CF != 2 then 'I' else 'J' end else a.reqcod_ct end,
           cre_d = @p_date_t,
           case when @p_date_t < @specend_d then @p_date_t else @specend_d end,  -- dbclo_d
           NULL,                                                                 -- launch_d
           case when a.reqcod_ct = "A" then isnull(substring(convert(char(6),a.vrs_nf),1,4),convert(char(6),@blcshtyea_nf))+'/'+isnull(substring(convert(char(6),a.vrs_nf),5,2),convert(char(6),@blcshtmth_nf)) else NULL end,
           case when a.reqcod_ct = "A" then a.vrs_nf else NULL end,              -- vrs_nf
           updusr_cf = 'iclo',
           case when a.reqcod_ct = "A" then @p_date_t else NULL end,  -- [016]                 -- start_d pour le plan
           case when a.reqcod_ct = "A" then dateadd(day, 5, @p_date_t) else NULL end, -- [016] -- end_d date pour le plan
           @site_cf,
           @ID_NF
    from #TLSTSSD A
    where not exists (select 1  from best..TREQJOB B 
                      where B.SSD_CF       = a.ssd_cf 
                      and   B.BALSHEYEA_NF = @blcshtyea_nf 
                      and   B.BALSHTMTH_NF = @blcshtmth_nf 
                      and   B.clodat_d     = @p_clodat
                      and   B.reqcod_ct    = case when a.reqcod_ct = "D" then case when B.SSD_CF != 2 then 'I' else 'J' end else a.reqcod_ct end
                      and   B.cre_d        = @p_date_t
                      and   B.DBCLO_D      = case when @p_date_t < @specend_d then @p_date_t else @specend_d end
                      and   B.launch_d     = NULL
                      and   B.SITE_CF      = @site_cf
                     )

    INSERT into best..TREQJOB (ssd_cf,
                               balsheyea_nf,
                               balshtmth_nf,
                               clodat_d,
                               reqcod_ct,
                               cre_d,
                               dbclo_d,
                               launch_d,
                               cloper_ls,
                               vrs_nf,
                               updusr_cf,
                               start_d, --[016]
                               end_d,
                               SITE_CF,
                               ID_NF) --[016]
    SELECT a.ssd_cf,
           @blcshtyea_nf,
           @blcshtmth_nf,
           clodat_d = @p_clodat,
           reqcod_ct = case when a.reqcod_ct = "D" then case when a.SSD_CF != 2 then 'I' else 'J' end else a.reqcod_ct end,
           cre_d = @p_date_t,
           case when @p_date_t < @specend_d then @p_date_t else @specend_d end,  -- dbclo_d
           NULL,                                                                 -- launch_d
           case when a.reqcod_ct = "A" then isnull(substring(convert(char(6),a.vrs_nf),1,4),convert(char(6),@blcshtyea_nf))+'/'+isnull(substring(convert(char(6),a.vrs_nf),5,2),convert(char(6),@blcshtmth_nf)) else NULL end,
           case when a.reqcod_ct = "A" then a.vrs_nf else NULL end,              -- vrs_nf
           updusr_cf = 'iclo',
           case when a.reqcod_ct = "A" then @p_date_t else NULL end,  -- [016]                 -- start_d pour le plan
           case when a.reqcod_ct = "A" then dateadd(day, 5, @p_date_t) else NULL end, -- [016] -- end_d date pour le plan
           @site_cf,
           @ID_NF
    from #TLSTSSD A
    where not exists (select 1  from best..TREQJOB B 
                      where B.SSD_CF       = a.ssd_cf 
                      and   B.BALSHEYEA_NF = @blcshtyea_nf 
                      and   B.BALSHTMTH_NF = @blcshtmth_nf 
                      and   B.clodat_d     = @p_clodat
                      and   B.reqcod_ct    = case when a.reqcod_ct = "D" then case when B.SSD_CF != 2 then 'I' else 'J' end else a.reqcod_ct end
                      and   B.cre_d        = @p_date_t
                      and   B.DBCLO_D      = case when @p_date_t < @specend_d then @p_date_t else @specend_d end
                      and   B.launch_d     = NULL
                      and   B.SITE_CF      = @site_cf
                     )
    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 10 : %1!',@lines
    if @erreur != 0  goto fin


-------
    FETCH  curs_ctr
    INTO @p_clodat, @ssds_cf, @reqcod_ct , @ID_NF, @VRS_NF, @end_d, @balshtmth_nf --[016]
         
------------

END
Close curs_ctr
Deallocate Cursor curs_ctr


    -- Recherche et affectation la version pour chacune des filiales demandées en inventaire
    -- =====================================================================================
    INSERT into #TSSDVRS (SSD_CF,VRS_NF)
    SELECT A.SSD_CF, A.VRS_NF
    FROM best..TVERPAR A, BREF..TBATCHSSD D
    where A.SEGTYP_CT = 'A'   
      and A.SSD_CF    = D.ssd_CF
      and BATCHUSER_CF = @suser_Name
      and exists ( SELECT 1  from best..TVERSION B
                                     where b.SEGTYP_CT = 'A'
                                     and b.VRSSTS_CT <> 'AN' and B.VRSLOC_B = 0
                                     and b.ssd_cf in ( SELECT ssd_cf from #TLSTSSD where REQCOD_CT in ( 'D' ) )
                                     and a.ssd_cf = b.ssd_cf
                                     and a.vrs_nf = b.vrs_nf )
    group by A.ssd_cf
    having   A.PAR_D = max( A.PAR_D )
    order by A.ssd_cf

    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 11 : %1!',@lines
    if @erreur != 0  goto fin


    --  MAJ de la version sur les demandes d'inventaire en cours
    --  ========================================================
    UPDATE best..TREQJOB
      SET vrs_nf = b.vrs_nf
    FROM best..TREQJOB a,
         #TSSDVRS b
    WHERE a.balsheyea_nf = @blcshtyea_nf
      and a.balshtmth_nf = @blcshtmth_nf
      and a.clodat_d     = @p_clodat
      and a.cre_d        = @p_date_t
      and a.updusr_cf    = 'iclo'
      and a.launch_d     is null
      and a.reqcod_ct    in ('I','J')
      and a.ssd_cf       = b.ssd_cf
      and a.site_cf      = @site_cf

    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 12 : %1!',@lines
    if @erreur != 0  goto fin


    -- ===========================================================================================================
    -- Suppression des demandes:
    -- a - de type inventaire demande individuelle (reqcod_ct = I ou J )
    -- b - en cours (launch_d = null)
    -- c - pour des filiales qui ont déjà été comptabilisées (reqcod_ct = C et clodat_d = date de cloture demandée
    -- ===========================================================================================================
    /*
    if (@p_date_t < @v_account_d) and (@v_closing_b = 1)
    Begin
        DELETE FROM best..TREQJOB
        FROM best..TREQJOB A
        where balsheyea_nf = @blcshtyea_nf
          and balshtmth_nf = @blcshtmth_nf
          and clodat_d     = @p_clodat
          and cre_d        < @v_account_d
          and launch_d     is null
          and reqcod_ct    in ('I','J')
          and exists ( SELECT 1
                       FROM best..TREQJOB B
                       where a.clodat_d = b.clodat_d
                         and reqcod_ct  in ('C')
                         and a.ssd_cf   = b.ssd_cf )
    End
    SELECT @erreur = @@error
    if @erreur != 0  goto fin
    */


    UPDATE best..TREQJOB
       set LAUNCH_D   = getdate(),
           UPDUSR_CF  = 'iclo'
    where reqcod_ct   in ('D','E')   --[012] where reqcod_ct   in ('D','E','A') 
      and cloper_ls   is not null
      and LAUNCH_D    = NULL
      and SITE_CF     = @site_cf

    UPDATE best..TREQJOB
       set LAUNCH_D   = getdate(),
           UPDUSR_CF  = 'iclo'
    where reqcod_ct   in ('A')   --[012] where reqcod_ct   in ('D','E','A') 
      and cloper_ls   is not null
      and LAUNCH_D    = NULL
      and SITE_CF     = @site_cf
      and ssd_cf=3
    --[015]


    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 13 : %1!',@lines
    if @erreur != 0  goto fin

    DELETE FROM best..TREQJOB
    where ( launch_d is null )
      and ( ( balsheyea_nf < @blcshtyea_nf ) OR ( balsheyea_nf = @blcshtyea_nf  and  balshtmth_nf <  @blcshtmth_nf ) )
      and reqcod_ct in ('I','J', 'L')
      and SITE_CF = @site_cf
      
    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 14 : %1!',@lines
    if @erreur != 0  goto fin

    -- Suppression d'une demande:
    -- a - pour un inventaire mensuel (reqcod_ct = I ou J) ou pour des stat/Reporting Vie (reqcod_ct =L)
    -- b - en cours (launch_d = null)
    -- c - pour une date hors période du mois Inventaire
    -- ===========================================================================
    if (@p_date_t = @v_account_d) and (@v_closing_b = 0)
    Begin
        DELETE FROM best..TREQJOB
        where ( launch_d is null )
          and reqcod_ct in ('I','J', 'L')
          and SITE_CF = @site_cf
    End

    --[015]
    select @erreur=@@error, @lines=@@rowcount
    print 'Processed lines 15 : %1!',@lines
    if @erreur != 0  goto fin

    -- ------------------------------------------------------------
    --   Fin de la transaction
    --- -----------------------------------------------------------
    if @tran_imbr = 0
        COMMIT TRAN
    return 0

    fin:
    if @tran_imbr = 0
        ROLLBACK TRAN

    return 1
END -- End de if A_traiter!=0  --

FINAL:
go
EXEC sp_procxmode 'dbo.PtREQJOB_02', 'unchained'
go
IF OBJECT_ID('dbo.PtREQJOB_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtREQJOB_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtREQJOB_02 >>>'
go
GRANT EXECUTE ON dbo.PtREQJOB_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PtREQJOB_02 TO GDBBATCH
go
