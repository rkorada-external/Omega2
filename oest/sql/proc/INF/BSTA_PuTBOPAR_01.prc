USE BSTA
go


/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */

/* DROP PROC dbo.PuTBOPAR_01
*/
IF OBJECT_ID('dbo.PuTBOPAR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PuTBOPAR_01
   PRINT '<<< DROPPED PROC dbo.PuTBOPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PuTBOPAR_01
	@DOM_CF		char(3),
	@TABLENAME	varchar (30),
	@CLODAT_CF	char(8),
	@BALSHTYEA_NF	int,
	@BALSHTMTH_NF	smallint,
	@CRE_D	char(8),
	@LSTUPDUSR_CF UUPDUSR_CF
as

/***************************************************

Programme: PuTBOPAR_01

Fichier script associ‚ : estubop1.PRC

Base principale : BSTA

Version: 1

Auteur: ME20 avec Textpad (MANUEL)

Date de creation: 6/7/1999

Description du programme: 

      Mise à jour après identification du nom de la table miroir pour l'inventaire

Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 0001

Auteur: 
Date:
Version:
Description: 

*****************************************************/
declare @BALSHTDAT_CF	char (8)

select 	@BALSHTDAT_CF = convert (varchar, @BALSHTYEA_NF) +
			replicate ('0', 2 - datalength ( convert (varchar, @BALSHTMTH_NF))) +
			convert (varchar, @BALSHTMTH_NF)

update BSAR..TBOPAR
set LSTUPD_D=@CRE_D, LSTUPDUSR_CF=@LSTUPDUSR_CF
where    DMN_CF=@DOM_CF
     and TAB_CF=@TABLENAME
     and FIELD1_CF=@BALSHTDAT_CF
     and FIELD2_CF=@CLODAT_CF
     and (PAR_D=NULL or PAR_D='')
     and ARCH_B=0
	
return 0
go

IF OBJECT_ID('dbo.PuTBOPAR_01') IS NOT NULL
   BEGIN
   PRINT '<<< CREATED PROC dbo.PuTBOPAR_01 >>>'
END
go

GRANT EXECUTE ON dbo.PuTBOPAR_01 TO GOMEGA
go
