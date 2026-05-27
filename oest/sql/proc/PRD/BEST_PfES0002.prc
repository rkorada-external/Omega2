use BEST
go

IF OBJECT_ID('dbo.PfES0002') IS NOT NULL
    DROP PROC dbo.PfES0002
go

create procedure PfES0002
	@p_nb_lignes              int,
	@p_etape		     char(1)
as

/***************************************************

Programme: PfES0002

Fichier script associé : BESTFET4.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 (P.HOUEE)

Date de creation: 15/07/1997

Description du programme: 

  Curseur de grosse liste de la fenêtre estimation "w_recherche_es0002"

Modif 0001 : L.DEBEVER le 06/12/1999 : BESTFETC.prc éclaté en BESTFET1/2/3/4/5.prc

*****************************************************/



if @p_etape = 'O' 
   begin
	SET cursor rows @p_nb_lignes FOR BigList_Curs_ES0002

	OPEN BigList_Curs_ES0002
	
	select @p_etape  = 'F'
   end

if @p_etape = 'F' 	
   begin
	fetch Biglist_curs_ES0002
	if @@sqlstatus=2
	   begin
		CLOSE BigList_Curs_ES0002
		DEALLOCATE cursor BigList_Curs_ES0002
		raiserror 25000 'fin de liste'
		return -1
	   end
   end

if @p_etape = 'C' 	
   begin
	CLOSE BigList_Curs_ES0002
	DEALLOCATE cursor BigList_Curs_ES0002
   end	

return
Go

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'BESTFET4', 'PfES0002', 'BEST', 'ME34'
go

GRANT EXECUTE ON dbo.PfES0002 TO GOMEGA
Go
