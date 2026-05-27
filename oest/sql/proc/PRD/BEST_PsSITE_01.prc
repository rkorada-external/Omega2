USE BEST
go
/*
 * DROP PROC dbo.PsSITE_01
 */
IF OBJECT_ID('dbo.PsSITE_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSITE_01
    PRINT '<<< DROPPED PROC dbo.PsSITE_01 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsSITE_01
(
  @p_param1		  varchar(20),
  @p_mode_cf	  char(1),
  @p_site_cf	  varchar(10)  OUTPUT
)
as

/***************************************************
Programme: PsSITE_01
Fichier script associe : 
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: Ph Pezout
Date de creation:
Description du programme:
          mode_cf = 0 : a partir d'une login obtention du site (mode_cf=0), ou 
          mode_cf = 1 : a partir du site, obtention de la login (mode_cf=1)
          mode_cf = 2 : a partir du SSD_CF, obtention du site (mode_cf=2)

Parametres:
Conditions d'execution:
Commentaires:
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
**********************************************************************************************************/

declare @erreur 		    int

if @p_mode_cf = '' or @p_mode_cf = null
begin
	select @p_mode_cf = '0'
end

if @p_param1 = '' or @p_param1 = null
begin
    if @p_mode_cf = '0'
    begin
	select @p_param1 = suser_Name()
    end
end

    if @p_param1 = 'batch'
    begin
	 select @p_param1 = 'UBEU'
    end

/* temporaire on shinte l'appel à la table TBATCHNIGHT qui n'existe pas encore */


if @p_mode_cf = '0'
begin
	select top 1 @p_site_cf = PRDSIT_CF	    from BREF..TBATCHNIGHT where BATCHUSER_CF=@p_param1
end

if @p_mode_cf = '1'
begin
	select top 1 @p_site_cf = BATCHUSER_CF	from BREF..TBATCHNIGHT where PRDSIT_CF=@p_param1
end

if @p_mode_cf = '2'
begin
	select top 1 @p_site_cf = b.PRDSIT_CF   from bref..TBATCHSSD a, BREF..TBATCHNIGHT b 
	where a.BATCHUSER_CF=b.BATCHUSER_CF and a.SSD_CF=convert(numeric,@p_param1) 
    and a.BATCHUSER_CF<>"batch"
end

return 0

fin:
return 1

go

/*
 * fin de la procedure
 */


IF OBJECT_ID('dbo.PsSITE_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSITE_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSITE_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSITE_01
 */
GRANT EXECUTE ON dbo.PsSITE_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSITE_01 TO GDBBATCH
go

