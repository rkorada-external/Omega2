USE BEST
Go


IF OBJECT_ID('dbo.PsESB_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsESB_02
    PRINT '<<< DROPPED PROC dbo.PsESB_02 >>>'
END
go

-- creation de la procedure

create procedure PsESB_02
     (
	 @p_type            int,
	 @p_end_nt 	    UEND_NT,
	 @p_uw_nt           UUW_NT,
	@p_uwy_nf           UUWY_NF,
	@p_ctr_nf           UCTR_NF,
	@p_ssd_cf           USSD_CF

     )
as

/***************************************************

Programme: PsESB_02

Fichier script associé : ESSESB02.PRC

Base principale : BTRT, BRET, BREF

Version: 1

Auteur: ME01

Date de creation: 06/10/2000

Description du programme:

      Recherche de l'établissement d'un contrat   (sert au domaine ESTIMATION)

Parametres:
	 @p_type            int,
	 @p_end_nt 	    UEND_NT,
	 @p_uw_nt           UUW_NT,
	@p_uwy_nf           UUWY_NF,
	@p_ctr_nf           UCTR_NF,
	@p_ssd_cf           USSD_CF

Conditions d'execution:
Commentaires:

_________________
MODIFICATIONS
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
Auteur          |	Date      |  	Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 16/09/2009  |[18053] saisie écriture service : pour les fac xxLyyyyy, on ne cherche pas l'établissement dans BFAC mais dans TRT.
                |             | Remplacement du test sur les lettres par un interval qui couvre l'ensemble du domaine des FACs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
                |             |
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------

*************************************************************************************************/

declare @erreur int,
	@esb_cf int,
	@info   char(19),
	@ESB_LS char(16),
    @ctr_typ  char(1)


select @ctr_typ = substring(@p_ctr_nf, 3, 1 )

/* ------------------ Select dans la table BTRT..TCONTR ou dans BFAC..TCONTR --------------------- */

if  @p_type = 1

BEGIN

   -- If @ctr_typ in ('F', 'G', 'L')

    If @ctr_typ between 'A' and 'M' -- sélection des Facultatives
    BEGIN
    Select @esb_cf = accesb_cf

    from BFAC..TCONTR

    where ctr_nf = @p_ctr_nf
        and uwy_nf = @p_uwy_nf
        and end_nt = @p_end_nt
        and uw_nt = @p_uw_nt

    select @erreur = @@error

    if @erreur != 0
    begin
        raiserror 20005 "APPLICATIF;BFAC..TCONTR" /* erreur de lecture */
        return @erreur
    end
    END
ELSE
    BEGIN
    Select @esb_cf = accesb_cf

    from BTRT..TCONTR

    where ctr_nf = @p_ctr_nf
        and uwy_nf = @p_uwy_nf
        and end_nt = @p_end_nt
        and uw_nt = @p_uw_nt

    select @erreur = @@error

    if @erreur != 0
    begin
      raiserror 20005 "APPLICATIF;BTRT..TCONTR" /* erreur de lecture */
      return @erreur
    end
    END

END

/* ------------------------- Select dans la table BRET..TRETCTR ---------------------------- */

ELSE

BEGIN

Select @esb_cf = esb_cf

 from BRET..TRETCTR

 where retctr_nf = @p_ctr_nf
    and rty_nf = @p_uwy_nf

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TRETCTR" /* erreur de lecture */
  return @erreur

END

END

/* ---------------------- Libellé de l'établissement ------------------------------*/

 Select @ESB_LS = ESB_LS
   	from BREF..TESB
  where SSD_CF = @p_SSD_CF
    and ESB_CF = @esb_cf

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TESB"
      return 1
   end

/* ----------- retour des info sous la forme d'une chaine de caractères -------------*/

select @info = convert(char(2),@esb_cf) + "/" + @ESB_LS

select @info


return 0
/* ### DEFNCOPY: END OF DEFINITION */
/* ### DEFNCOPY: END OF DEFINITION */

go
IF OBJECT_ID('dbo.PsESB_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsESB_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsESB_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsESB_02
 */
GRANT EXECUTE ON dbo.PsESB_02 TO GOMEGA
go

