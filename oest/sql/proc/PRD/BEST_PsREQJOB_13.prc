USE BEST
go
IF OBJECT_ID('dbo.PsREQJOB_13') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsREQJOB_13
    IF OBJECT_ID('dbo.PsREQJOB_13') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsREQJOB_13 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsREQJOB_13 >>>'
END
go
create procedure dbo.PsREQJOB_13
  (
  @p_date_t datetime,
  @p_ssd_cf USSD_CF 
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M.DJELLOULI
Date de creation: 11/07/2005
Description du programme: selection des Dates et Periode Conso par Appel de la Proc PtREQJOB_05
Parametres:
Conditions d'execution:
Commentaires:
_________________
1 Florent     14/02/2012 :spot:23390 SOLVENCY II, ajout @P_EBSPsTomGen_D
MODIFICATION   :  [001]
SPOT           :  
DATE           :  08/03/2013
AUTEUR         :  Amit Deshpande
DESCRIPTION    :  
[001] 08/03/2013 Amit Deshpande : We have modified this procdure to include in the final select statement where we have added the alias.
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[004]nitesh 20/01/2014 : ssd_cf datatype convereted from ussd_cf to char(2) to fix spira 22027
*****************************************************/
declare @erreur     int
declare @con_ssd_cf char(2)--004
declare @site_cf varchar(10)

select @con_ssd_cf= convert(char(2),@p_ssd_cf)--004
Execute @erreur = BEST..PsSITE_01 @con_ssd_cf,'2',@site_cf output--004

declare
  @P_Booking_D           Char(8)      -- Date de Booking T-1  
 ,@P_PsTomGen_D          Char(8)      -- Date de Fin de Saisie Post Omega Social (Periode T) 
 ,@P_EnConso_D           Char(8)      -- Date de Fin de Saisie Ecritures Conso (Periode T)
 ,@DateInventaireConso   Char(8)      -- Date Libelle Inventaire Pour Saisie Ecriture Conso & Social (Periode T-1)
 ,@PeriodeConsoAA        numeric(4,0) -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
 ,@PeriodeConsoMM        numeric(2,0) -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
 ,@DateInventaireService Char(8)      -- Date Libelle Inventaire Pour Saisie Ecriture Service (Periode T)
 ,@PeriodeServiceAA      numeric(4,0) -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
 ,@PeriodeServiceMM      numeric(2,0) -- Periode MM Pour Saisie Ecriture Services (Periode T)
 ,@P_SuffixeTable        char(1)
 ,@P_Erreur              int
 ,@P_EBSPsTomGen_D       Char(8)      -- Date de Fin de Saisie Post Omega Social EBS(Periode R)
 ,@P_Booking17_D            Char(8)
 ,@P_PsTomGen17_D          Char(8)
 ,@P_EnConso17_D           Char(8)

exec BEST..PtREQJOB_05
      @p_date_t
     ,@site_cf
     ,@P_Booking_D           output
	 ,@P_PsTomGen_D          output
	 ,@P_EnConso_D           output
	 ,@DateInventaireConso   output           -- Date Libelle Inventaire Pour Saisie Ecriture Conso & Social (Periode T-1)
     ,@PeriodeConsoAA        output         -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
     ,@PeriodeConsoMM        output         -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
     ,@DateInventaireService output            -- Date Libelle Inventaire Pour Saisie Ecriture Service (Periode T)
     ,@PeriodeServiceAA      output          -- Periode AAAA Pour Saisie Ecriture Services (Periode T)
     ,@PeriodeServiceMM      output          -- Periode MM Pour Saisie Ecriture Services (Periode T)
     ,@P_SuffixeTable        output
     ,@P_Erreur              output
     ,@P_EBSPsTomGen_D       output
	 ,@P_Booking17_D	     output       
	 ,@P_PsTomGen17_D        output
	 ,@P_EnConso17_D         output
select @erreur = @@error
if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;PtREQJOB_05" /* erreur de lecture */
  return @erreur
end

select
  @P_Booking_D as p_booking_d
 ,@P_PsTomGen_D as p_pstomgen_d
 ,@P_EnConso_D as p_enconso_d
 ,@DateInventaireConso as dateinventaireconso
 ,@PeriodeConsoAA as periodeconsoaa
 ,@PeriodeConsoMM as periodeconsomm
 ,@DateInventaireService as dateinventaireservice 
 ,@PeriodeServiceAA as periodeserviceaa
 ,@PeriodeServiceMM as periodeservicemm
 ,@P_SuffixeTable as p_suffixetable
 ,@P_Erreur as  p_erreur
 ,@P_EBSPsTomGen_D as p_ebspstomgen_d1
 ,@P_Booking17_D as p_booking17_d
 ,@P_PsTomGen17_D as p_pstomgen17_d
 ,@P_EnConso17_D as p_enconso17_d
return 0
go
EXEC sp_procxmode 'dbo.PsREQJOB_13', 'unchained'
go
IF OBJECT_ID('dbo.PsREQJOB_13') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsREQJOB_13 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsREQJOB_13 >>>'
go
GRANT EXECUTE ON dbo.PsREQJOB_13 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_13 TO GDBBATCH
go
