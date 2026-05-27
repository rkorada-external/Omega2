USE BEST
Go

/*
 * si la procédure existe déjà, il faut l'effacer
 */

IF OBJECT_ID('dbo.PsCURQUOT_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsCURQUOT_01
    PRINT '<<< DAMNED! I CRASHED PsCURQUOT_01 >>>'
END
go

/*
 * creation de la procedure 
 */
 
create procedure PsCURQUOT_01

	@p_SSD_CF		USSD_CF,		/* filiale */
	@p_CUR1_CF		UCUR_CF,		/* devise d'origine */
	@p_CUR2_CF		UCUR_CF,		/* devise de conversion */
	@p_UWY_NF		UUWY_NF,		/* exercice considéré */
	@p_montant1		UAMT_M,		/* montant à convertir */
	@p_montant2		UAMT_M output	/* montant converti */
	

as

/***************************************************
Programme: dbo.PsCURQUOT_01
Fichier script associe: ESSCUR01.prc
Description du programme: Convertion d'un montant exprimé en une
				 devise, en une autre devise; ceci pour 
				 une filiale donnée.
				 Exemple : La filiale 2 veut convertir
				 100 USD (Mt1) en DDM (Mt2).
				 On recherche :
					1- Le cours du USD en devise filiale (t1)
					2- Le cours du DDM en devise filiale (t2)
					3- Mt2 = Mt1 * t1/t2 
				 Les cours recherchés sont les cours valides les plus
				 récents pour l'année considérée.
Paramètres: 
Conditions d'execution: 
Commentaires:
Historique:
	0001	L.Debever (OME01)	14/12/98	creation
	0002	L.CHARPENTIER		07/01/1999	Modification, la recherche du 
	taux de conversion se fait au cours statistique (@p_UWY_NF - 1) et non 
	sur l'exercice courant (@p_UWY_NF)
*****************************************************/

Declare 	@erreur	int,
		@rowcount	int,
		@d_debut	datetime,
		@d_fin		datetime,
		@EXC1_R 	ULNGDEC, 
		@EXC2_R 	ULNGDEC


Set arithabort numeric_truncation off /* éviter 'truncate error ' */

/**********************************************************************************/	
/* Composition de l'année considérée (01/01 - 31/12)                              */
/**********************************************************************************/	

select @d_fin = Convert(datetime, '12-31-' + convert(char(4),(@p_UWY_NF - 1)))
select @d_debut = Convert(datetime, '01-01-' + convert(char(4),(@p_UWY_NF - 1)))


/**********************************************************************************/	
/* Recherche du cours de la devise d'origine en devise filiale                    */
/**********************************************************************************/

Select @EXC1_R = A.EXC_R from BREF..TCURQUOT A
where A.SSD_CF = @p_SSD_CF
and	A.CUR_CF = @p_CUR1_CF
and	A.EXC_D <= @d_fin
and	A.EXC_D >= @d_debut
and	A.ACTCOD_B	= 1
and	A.EXC_D = (select max(B.EXC_D) from BREF..TCURQUOT B		
     			where B.SSD_CF = A.SSD_CF
			and B.CUR_CF = A.CUR_CF
	 		and B.EXC_D <= @d_fin
	  		and B.EXC_D >= @d_debut
			and B.ACTCOD_B = 1)

select @erreur = @@error, @rowcount = @@rowcount

if @erreur = 2601 or @rowcount = 0
begin
  /*raiserror 20009 "APPLICATIF;TCURQUOT, taux de conversion manquant" /* aucune ligne trouvée */*/
  return 2601
end

if @erreur != 0
begin
  /*raiserror 20005 "APPLICATIF;TCURQUOT;" /* erreur  de selection */*/
  return @erreur 
end


/**********************************************************************************/	
/* Recherche du cours de la devise de conversion en devise filiale                */
/**********************************************************************************/

Select @EXC2_R = A.EXC_R from BREF..TCURQUOT A
where A.SSD_CF = @p_SSD_CF
and	A.CUR_CF = @p_CUR2_CF
and	A.EXC_D <= @d_fin
and	A.EXC_D >= @d_debut
and	A.ACTCOD_B	= 1
and	A.EXC_D = (select max(B.EXC_D) from BREF..TCURQUOT B		
     			where B.SSD_CF = A.SSD_CF
			and B.CUR_CF = A.CUR_CF
	 		and B.EXC_D <= @d_fin
	  		and B.EXC_D >= @d_debut
			and B.ACTCOD_B = 1)

select @erreur = @@error, @rowcount = @@rowcount

if @erreur = 2601 or @rowcount = 0
begin
  raiserror 20005 "APPLICATIF;TCURQUOT;" /* erreur  de selection */
  return 2601
end

if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TCURQUOT;" /* erreur  de selection */
  return @erreur 
end


/**********************************************************************************/	
/* Conversion du montant                                                          */
/**********************************************************************************/

Select @p_montant2 = @p_montant1 * @EXC1_R / @EXC2_R

if @p_montant2 = NULL		
begin			
	select	 @p_montant2 = 0		
end


Set arithabort numeric_truncation on


return @erreur 

/*******************************************
 FIN DE PROCEDURE                          */

go

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCUR01', 'PsCURQUOT_01', 'BEST', 'ME01'
go


IF OBJECT_ID('dbo.PsCURQUOT_01') IS NOT NULL
	PRINT '<<< PROCEDURE PsCURQUOT_01 CREEE >>>'
ELSE
	PRINT '<<< ERREUR LORS CREATION PROCEDURE PsCURQUOT_01 >>>'
go

/*
 * Conditions d'accès à dbo.PsCURQUOT_01
 */

GRANT EXECUTE ON dbo.PsCURQUOT_01 TO GOMEGA
go

