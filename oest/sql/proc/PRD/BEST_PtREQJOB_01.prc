use BEST
go

/*
   Si modification de la proc : supprimer l'option AUTO dans l'auteur
*/
/*
   DROP PROC dbo.PtREQJOB_01.prc
*/
IF OBJECT_ID('dbo.PtREQJOB_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PtREQJOB_01
   PRINT '<<< DROPPED PROC dbo.PtREQJOB_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PtREQJOB_01
(
@p_cre_d		UUPD_D
)

as

/***************************************************

Programme: PtREQJOB_01
Fichier script associé : BEST_PtREQJOB_01.prc
Domaine : Estimation
Base principale : BEST
Version: 1
Auteur: O.GIRAUX
Date de creation: 09/07/2001
Description du programme: traitement des demandes Z
    Generation d'un fichier contenant des infos extraites de TREQJOB pour utilisation dans ESIJ0090
    lors de demande d'inventaire de type Z.
    Recuperation des infos dans TREQJOB pour metttre a jour ensuite BSAR..TBOPAR.

Parametres:
Conditions d'execution:
Commentaires:
_________________
MODIFICATION 1

12/09/2008  JF. VDE SPOT15758: Augmentation du champ CLOPER_LS (TREQJOB)  de 32 à 64 caractères
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 27/03/2014 R. Cassis   :spot:25427  - Modifications pour omega2 -1b sur treqjobplan

*****************************************************/

declare @erreur        int,
        @w_lignes      int,
        @tran_imbr	   bit,
        @USR_CF        UUSR_CF,
        @CLOPER_LS     varchar(64),     -- [SPOT15758] vde
        @BALSHEYEA_NF  smallint,
        @BALSHTMTH_NF  tinyint,
	      @CLODAT_D		   char(8),
	      @CRE_D         datetime

select @erreur = 0
select @tran_imbr = 1

CREATE TABLE #PARAM
(
    lig      tinyint     ,
    lib      char(20)     null ,
    val      varchar(100) null
)


/* -----------------------------------------------------------
	Début de la transaction
   ----------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_imbr = 0
  BEGIN TRAN
  end


/***************************************************
   Début du traitement.
*****************************************************/

/* Si on a plus d'une demande d'inventaire de type Z, on ne fera pas les mises a jour dans BSAR..TBOPAR */
select @w_lignes = count(*) from BEST..TREQJOB
where LAUNCH_D = NULL
and REQCOD_CT = "Z"

if @@error !=0
   begin
      raiserror 20002 "Pb dans Count BEST..TREQJOB     "
      goto erreur
   end


if @w_lignes >= 1
   begin

    select top 1 @USR_CF = UPDUSR_CF,
                 @CLOPER_LS = CLOPER_LS,
                 @BALSHEYEA_NF = BALSHEYEA_NF,
                 @BALSHTMTH_NF = BALSHTMTH_NF,
                 @CLODAT_D = convert(char(8),CLODAT_D,112),
                 @CRE_D = CRE_D
    from BEST..TREQJOB where LAUNCH_D = NULL and REQCOD_CT = "Z" order by CRE_D DESC

      if @@error !=0
        begin
            raiserror 20004 "Pb dans select BEST..TREQJOB "
            goto erreur
        end


    insert into #PARAM values(1,"USR_CF"       ,@USR_CF)
    insert into #PARAM values(2,"CLOPER_LS"    ,@CLOPER_LS)
    insert into #PARAM values(3,"BALSHEYEA_NF" ,convert(varchar,@BALSHEYEA_NF))
    insert into #PARAM values(4,"BALSHTMTH_NF" ,convert(varchar,@BALSHTMTH_NF))
    insert into #PARAM values(5,"CLODAT_D"     ,@CLODAT_D)

    if @@error !=0
        begin
            raiserror 20005 "Pb dans select BEST..TREQJOB     "
            goto erreur
        end

    /* Mise a jour LAUNCH_D de TREQJOB */

    update BEST..TREQJOB
    set	LAUNCH_D = @p_cre_d
    where LAUNCH_D = NULL
    and REQCOD_CT = "Z"

		/* pour indiquer quelle demande a été traitée si on en a plusieurs */
    update BEST..TREQJOBPLAN
    set	START_D = @p_cre_d, END_D = @p_cre_d
    where LAUNCH_D = NULL
    and REQCOD_CT = "Z"
    and CRE_D = @CRE_D
    and convert( char(8), dbclo_d, 112 ) <= @p_cre_d  -- [101]

												
    if @@error !=0
        begin
            raiserror 20003 "Pb dans update BEST..TREQJOB "
            goto erreur
        end


    select lib + '   ' +val from #PARAM order by lig

end

if @tran_imbr = 0
    COMMIT TRAN
RETURN 0

erreur:
if @tran_imbr = 0
    ROLLBACK TRAN

RETURN -1

GO


IF OBJECT_ID('dbo.PtREQJOB_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PtREQJOB_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PtREQJOB_01 >>>'
Go

/* Granting/Revoking Permissions on dbo.PtREQJOB_01 */
GRANT EXECUTE ON dbo.PtREQJOB_01 TO GOMEGA
Go
GRANT EXECUTE ON dbo.PtREQJOB_01 TO GDBBATCH
go
