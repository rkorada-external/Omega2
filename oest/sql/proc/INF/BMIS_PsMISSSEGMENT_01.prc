USE BMIS
Go
 /* DROP PROC dbo.PsMISSSEGMENT_01
*/
IF OBJECT_ID('dbo.PsMISSSEGMENT_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsMISSSEGMENT_01
   PRINT '<<< DROPPED PROC dbo.PsMISSSEGMENT_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsMISSSEGMENT_01  ( @p_ssd_cf  USSD_CF)

as

/***************************************************

Programme: PsMISSSEGMENT_01

Fichier script associé : BMIS_PsMISSSEGMENT_01.PRC

Domaine : Estimations

Base principale : BMIS

Version: 1

Auteur: ME57

Date de creation: 05/07/2004

Description du programme:
   Selection d'enregistrement dans mis_segment_type_table executé par la datawindow  d_tb_sp_2001

Parametres:

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int


         SELECT 	SEGTYPE_CF, SEGTYPE_NM
        FROM   BMIS..mis_segment_type_table
        WHERE     SSD_CF = @p_ssd_cf

           select @erreur = @@error

           if @erreur != 0
           begin
              return @erreur
           end

return 0
go


exec sp_SCOR_INSPRC 'ESSSEC21', 'PsMISSSEGMENT_01', 'BEST', 'ME57'
go

IF OBJECT_ID('dbo.PsMISSSEGMENT_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsMISSSEGMENT_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsMISSSEGMENT_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsMISSSEGMENT_01
 */
GRANT EXECUTE ON dbo.PsMISSSEGMENT_01 TO GOMEGA
go

