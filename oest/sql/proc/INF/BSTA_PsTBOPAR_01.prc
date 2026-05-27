USE BSTA
go


/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */

/* DROP PROC dbo.PsTBOPAR_01
*/
IF OBJECT_ID('dbo.PsTBOPAR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsTBOPAR_01
   PRINT '<<< DROPPED PROC dbo.PsTBOPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsTBOPAR_01
	@DOM_CF		char(3),
	@TABLENAME	varchar (30),
	@CLODAT_CF	char(8),
	@BALSHTYEA_NF	int,
	@BALSHTMTH_NF	smallint
as

/***************************************************

Programme: PsTBOPAR_01

Fichier script associ‚ : estsbop1.PRC

Base principale : BCLI

Version: 1

Auteur: ME62 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Idenification du nom de la table miroir pour l'inventaire

Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 0001

Auteur: H. GUIHEUX
Date: 18/12/98
Version: 1.01
Description: 

*****************************************************/
declare @BALSHTDAT_CF	char (8)

select 	@BALSHTDAT_CF = convert (varchar, @BALSHTYEA_NF) +
			replicate ('0', 2 - datalength ( convert (varchar, @BALSHTMTH_NF))) +
			convert (varchar, @BALSHTMTH_NF)


select substring(TABCIBLE_CF,2,16) 
from BSAR..TBOPAR 
where DMN_CF=@DOM_CF and 
 TAB_CF=@TABLENAME and
 FIELD1_CF=@BALSHTDAT_CF and
 FIELD2_CF=@CLODAT_CF and 
 (PAR_D=NULL or PAR_D='') and 
 ARCH_B=0


	
return 0
go

IF OBJECT_ID('dbo.PsTBOPAR_01') IS NOT NULL
   BEGIN
   PRINT '<<< CREATED PROC dbo.PsTBOPAR_01 >>>'
END
go

GRANT EXECUTE ON dbo.PsTBOPAR_01 TO GOMEGA
go
