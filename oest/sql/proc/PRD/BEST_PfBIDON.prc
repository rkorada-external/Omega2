use BEST
go

IF OBJECT_ID('dbo.PfBIDON') IS NOT NULL
    DROP PROC dbo.PfBIDON
go

create procedure PfBIDON
	@p_nb_lignes              int,
	@p_etape		     char(1)
as

/***************************************************

Programme: PfBIDON

Fichier script associé : BESTFET5.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 (P.HOUEE)

Date de creation: 15/07/1997

Description du programme: 

  Curseur de grosse liste de la fenêtre estimation "w_feuille_es0207"

Modif 0001 : L.DEBEVER le 06/12/1999 : BESTFETC.prc éclaté en BESTFET1/2/3/4/5.prc

*****************************************************/




if @p_etape = 'O' 
   begin
	SET cursor rows @p_nb_lignes FOR BigList_Curs_BIDON

	OPEN BigList_Curs_BIDON
	
	select @p_etape  = 'F'
   end

if @p_etape = 'F' 	
   begin
	fetch Biglist_curs_BIDON
	if @@sqlstatus=2
	   begin
		CLOSE BigList_Curs_BIDON
		DEALLOCATE cursor BigList_Curs_BIDON
		raiserror 25000 'fin de liste'
		return -1
	   end
   end

if @p_etape = 'C' 	
   begin
	CLOSE BigList_Curs_BIDON
	DEALLOCATE cursor BigList_Curs_BIDON
   end	

return
Go


/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'BESTFET5', 'PfBIDON', 'BEST', 'ME34'
go

GRANT EXECUTE ON dbo.PfBIDON TO GOMEGA
Go


