USE BEST
Go

-- DROP PROC dbo.PuREQJOB_06

IF OBJECT_ID('dbo.PuREQJOB_06') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuREQJOB_06
   PRINT '<<< DROPPED PROC dbo.PuREQJOB_06 >>>'
END
go

-- creation de la procedure

create procedure PuREQJOB_06
     (
      @p_cre_d		        datetime,
     	@p_balsheyea_nf	    smallint,
     	@p_balshtmth_nf	    tinyint,
     	@p_clodat_d	        varchar(8),
     	@p_dbclo_d		      varchar(8),
     	@p_clodatmax_d	    varchar(8),
     	@p_NomTableTTECLEDA varchar(16),
     	@p_LstFiliale       varchar(48)
     )
with execute as caller as

/***************************************************

Programme: PuREQJOB_06

Fichier script associé : BEST_PuREQJOB_06.prc

Domaine : (ES) Estimation
Base principale : BEST
Version: 5.1
Auteur: M. DJELLOULI
Date de creation: 27/06/2005

Description du programme:
	- Inscription d'une Ligne de Booking pour les Filiales ayant demandé un Inventaire
        On se Base sur le même traitement qui met à jour la Launch_Date (PuREQJOB_02)
Parametres:
    - @p_cre_d : la date de traitement
	- @p_balsheyea_nf : année ( période comptable )
	- @p_balshtmth_nf : mois ( période comptable )
	- @p_clodat_d : libellé d'inventaire
	- @p_dbclo_d : date d'arrété
    - @p_SuffixeTable : Suffixe de la Table Chargé dans INFOMEGA / TBOPAR

Conditions d'execution: Uniquement lorsque l'on est en Variante 6
Commentaires:
_________________
MODIFICATION 1
Auteur:   JF VDV
Date:     13/09/2010
Version:    10.1
Description:  [19070] - Ajout controle fin periode normale estimation vie

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 10/04/2014 R. cassis   :spot:25427  - Modifications pour omega2 -1b ajout as caller.
*****************************************************/

declare @erreur int, @tran_imbr	bit

Declare  @p_SuffixeTable char(1), @v_nclodatmax_d numeric(8,0)

select @erreur = 0
select @tran_imbr = 1

declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

Declare @Booking_On int
Select @Booking_On = 0

Select @p_NomTableTTECLEDA = Rtrim(Ltrim(@p_NomTableTTECLEDA))


if (@p_NomTableTTECLEDA != '') Select @p_SuffixeTable = Right(@p_NomTableTTECLEDA, 1)


Select @v_nclodatmax_d = convert(numeric(8,0) , @p_clodatmax_d)

-- -----------------------------------------------------------
--	Début de la transaction
-- -----------------------------------------------------------

if @@trancount = 0
  begin
   select @tran_imbr = 0
  BEGIN TRAN
  end

-- [19070]  contrôle fin période normale vie

UPDATE bref..TPROFIL
SET PRFPAR1_LM = 'EST OUI'
WHERE
    APP_CF = 'EST'
and PRF_cf ='TRT02'

if @@error != 0
goto fin

-- *******************************************
-- Mise à jour de BEST..TREQJOB
-- *******************************************

IF EXISTS (SELECT 1 from BEST..TREQJOB A, BTRAV..TESTSSD B
                where A.SSD_CF       = B.SSD_CF
                and   A.BALSHEYEA_NF = @p_balsheyea_nf
                and	  A.BALSHTMTH_NF = @p_balshtmth_nf
                and 	(
                            convert( char(8), B.CLODAT1_D, 112 ) = @p_clodat_d
                         OR convert( char(8), B.CLODAT2_D, 112 ) = @p_clodat_d
                         OR convert( char(8), B.CLODAT3_D, 112 ) = @p_clodat_d
                         OR convert( char(8), B.CLODAT1_D, 112 ) = @p_clodatmax_d
                        )
                and	( A.REQCOD_CT = "I" or A.REQCOD_CT = "J" or A.REQCOD_CT = "L" )
                and    A.LAUNCH_D =  NULL
                and A.CRE_D = (select min (C.CRE_D)
                        		from BEST..TREQJOB C
                        		where C.SSD_CF       = A.SSD_CF
                        		and   C.BALSHEYEA_NF = A.BALSHEYEA_NF
                        		and	  C.BALSHTMTH_NF = A.BALSHTMTH_NF
                        		and 	C.CLODAT_D     = A.CLODAT_D
                        		and	( C.REQCOD_CT    = "I" or C.REQCOD_CT = "J" or C.REQCOD_CT = "L" )
                        		and 	C.LAUNCH_D     = NULL
                        		and   C.SITE_CF      = @site_cf
                              )
               )
Begin
SELECT @Booking_On = 1
End


-- Ajout dans TREQJOB d'une Ligne de Booking
If (@Booking_On = 1)
Begin
    Insert Into BEST..TREQJOB
        (SSD_CF,
         BALSHEYEA_NF,
         BALSHTMTH_NF,
         CLODAT_D,
         REQCOD_CT,
         CRE_D,
         DBCLO_D,
         LAUNCH_D,
         CLOPER_LS,
         VRS_NF,
         UPDUSR_CF,
         SITE_CF)
    Values
         (99,                               -- Toutes Filiales Par Défaut pour l'Info Booking
         @p_balsheyea_nf,
         @p_balshtmth_nf,
         @p_clodat_d,
         'B',                               -- Type B
         @p_cre_d,
         @p_dbclo_d,
         @p_cre_d,                          -- Launch_Date = Date de Traitement (Date du Booking)
         @p_SuffixeTable + @p_LstFiliale,   -- Nom de Table TBOPAR Stocké dans CLOPER_LS pour REQCOD_CT = 'B'
         @v_nclodatmax_d,
         'Q20',
         @site_cf)
End

select @erreur = @@error
if @erreur != 0  goto fin


if @tran_imbr = 0
	COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go

-- fin de la procedure

IF OBJECT_ID('dbo.PuREQJOB_06') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PuREQJOB_06 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PuREQJOB_06 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuREQJOB_06
 */
GRANT EXECUTE ON dbo.PuREQJOB_06 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuREQJOB_06 TO GDBBATCH
go

