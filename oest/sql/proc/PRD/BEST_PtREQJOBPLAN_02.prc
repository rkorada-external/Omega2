use BEST
go

/* DROP PROC PtREQJOBPLAN_02 */
If OBJECT_ID('PtREQJOBPLAN_02') IS NOT NULL
Begin
    DROP PROC PtREQJOBPLAN_02
    PRINT '<<< DROPPED PROC PtREQJOBPLAN_02 >>>'
End
go
/*
 * creation de la procedure
*/

create procedure PtREQJOBPLAN_02 (
	@p_date_t      datetime,
   @p_closing_b   int
	)

as

/***************************************************

Programme               : PtREQJOBPLAN_02

Domaine                 : (ES) Estimation
Base principale         : BEST

Version                 : 1

Auteur                  : T.RIPERT

Date de creation        : 14/09/2010

Description du programme:
-	Sélection date inventaire pour les demandes

Parametres:
	- Date de traitement

Conditions d'execution:

Commentaires:


*****************************************************/

Declare  @mois       int  , @annee  int,
         @Diff_Day   int  , @jour   int
Declare  @d_deb Datetime   , @d_fin Datetime

Declare  @date_inventaire  char(8)

-- Rechercher la premiere closing_b jsute pares la date demande

-- Si trimestrielle
If @p_closing_b = 1
Begin
   select   top 1 @annee = blcshtyea_nf, @mois = blcshtmth_nf
     from   bref..tcalend
    where   account_d >= @p_date_t
      and   closing_b = 1
   order by account_d asc
End

-- Mensuelle
If @p_closing_b = 0
Begin
   select   @annee = blcshtyea_nf,  @mois=blcshtmth_nf
     from   bref..tcalend
    where   account_d = (select   min(account_d)
                           from   bref..tcalend
                          where   account_d >= @p_date_t)
End

-- Détermination Année Bissextile
Select @d_deb     = Convert(Char(4), @annee) + '01' + '01'
Select @d_fin     = Convert(Char(4), @annee+1) + '01' + '01'
Select @Diff_Day  = datediff(day, @d_deb, @d_fin) - 365

Select @jour = (case  when @mois IN (1, 3, 5, 7, 8, 10, 12)  then 31
                        when @mois IN (4, 6, 9, 11)            then 30
                        when @mois IN (2) then 28 + @Diff_Day else 0 end)

-- Contruction de la date
Select convert(char(2),@jour), convert(char(2),@mois), convert(char(4),@annee)

return 0

If OBJECT_ID('PtREQJOBPLAN_02') IS NOT NULL
    PRINT '<<< CREATED PROC PtREQJOBPLAN_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PtREQJOBPLAN_02 >>>'
go

/*
 * Granting/Revoking Permissions on PiLIFEST_02 */
GRANT EXECUTE ON PtREQJOBPLAN_02 TO GOMEGA
go
