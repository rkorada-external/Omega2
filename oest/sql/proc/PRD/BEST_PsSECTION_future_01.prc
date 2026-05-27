use BEST
go

/*
 * DROP PROC dbo.PsSECTION_future_01
 */
IF OBJECT_ID('dbo.PsSECTION_future_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PsSECTION_future_01
    PRINT '<<< DROPPED PROC dbo.PsSECTION_future_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_future_01
as

/***************************************************

Programme: PsSECTION_future_01


Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: Arnaud RUFFAULT

Date de creation: 13/10/2020

Description du programme: 

Parametres: 

Conditions d'execution: 


Commentaires:

*****************************************************/


declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr

declare @erreur int




-- Sélection des familles de charges itérées (pour calculer le champ CTBCOM_B)

SELECT SECTION.CTR_NF, SECTION.END_NT, SECTION.SEC_NF, SECTION.UWY_NF, SECTION.UW_NT, CHGLIN_NT, RATTYP_B, MAX_R, MINRAT_R, MIN_R, MAXRAT_R
FROM	 BTRT..TSECTION SECTION, 
	 BTRT..TCONTR CONTR, 
       BTRT..TFAMCHG2 FAMCHG2
WHERE	 SECSTS_CT IN(14, 15, 16, 17, 18, 19)
     	 and CTRSTS_CT IN(14, 15, 16, 17, 18, 19)
		 and CTRLCK_B <> 1 
       and SECTION.CTR_NF=FAMCHG2.CTR_NF and SECTION.END_NT=FAMCHG2.END_NT and SECTION.SEC_NF=FAMCHG2.SEC_NF and SECTION.UWY_NF=FAMCHG2.UWY_NF and SECTION.UW_NT=FAMCHG2.UW_NT
	 and SECTION.CTR_NF=CONTR.CTR_NF and SECTION.END_NT=CONTR.END_NT and SECTION.UWY_NF=CONTR.UWY_NF and SECTION.UW_NT=CONTR.UW_NT
	 and SECTION.SSD_CF in ( select SSD_CF from #ssds ) 





   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go
IF OBJECT_ID('dbo.PsSECTION_future_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsSECTION_future_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_future_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_future_01
 */
GRANT EXECUTE ON dbo.PsSECTION_future_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsSECTION_future_01 TO GDBBATCH
go

